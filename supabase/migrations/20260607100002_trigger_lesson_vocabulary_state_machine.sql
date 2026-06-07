-- Stap 3: Overgangstrigger op lesson_vocabulary
-- ============================================================
-- Deze trigger vuurt af vóór elke INSERT in lesson_vocabulary
-- en doet twee dingen:
--
--   1. VALIDATIE — blokkeer rollen die de didactische regels schenden
--   2. STATUSUPDATE — bij role = 'target': promoveer het woord
--      automatisch naar introduced_core in vocabulary_status
--
-- Toegestane overgangen:
--   new            → target   : status wordt introduced_core
--   theme_exposed  → target   : status wordt introduced_core
--                               (first_exposure_type en first_lesson_id
--                                blijven ongewijzigd via COALESCE)
--
-- Geblokkeerde situaties:
--   new of theme_exposed + role supporting/review/bonus → FOUT
--   introduced_core      + role target (opnieuw)        → FOUT
-- ============================================================

create or replace function public.fn_lesson_vocabulary_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status text;
begin
  -- Haal de huidige status op van het woord
  select status into v_status
  from public.vocabulary_status
  where vocabulary_id = new.vocabulary_id;

  -- Veiligheidscheck: elk woord hoort een statusrij te hebben na Stap 1 & 2.
  -- Dit zou normaal nooit mogen voorkomen.
  if v_status is null then
    raise exception
      'Woord (id: %) heeft geen rij in vocabulary_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      new.vocabulary_id;
  end if;

  -- Blokkeer dubbele target-introductie (Single Introduction Rule).
  -- Extra vangnet bovenop de partial unique index uit Stap 4.
  if new.role = 'target' and v_status = 'introduced_core' then
    raise exception
      'Woord (id: %) is al geïntroduceerd als target (status: introduced_core). '
      'De Single Introduction Rule verbiedt een tweede target-introductie.',
      new.vocabulary_id;
  end if;

  -- Blokkeer ongeldige rollen voor woorden die nog niet volledig geïntroduceerd zijn.
  -- Een woord met status "new" of "theme_exposed" mag niet als supporting, review
  -- of bonus verschijnen — het is immers nog niet verondersteld gekend bij de leerling.
  if v_status in ('new', 'theme_exposed') and new.role in ('supporting', 'review', 'bonus') then
    raise exception
      'Woord (id: %) heeft status "%" en mag daarom niet als "%" in een les verschijnen. '
      'Introduceer het woord eerst als target.',
      new.vocabulary_id, v_status, new.role;
  end if;

  -- Bij role = 'target': promoveer het woord naar introduced_core.
  -- COALESCE zorgt dat first_exposure_type en first_lesson_id ongewijzigd blijven
  -- als ze al ingevuld zijn (geval: woord was eerder theme_exposed).
  if new.role = 'target' then
    update public.vocabulary_status
    set
      status              = 'introduced_core',
      first_exposure_type = coalesce(first_exposure_type, 'core'),
      first_lesson_id     = coalesce(first_lesson_id, new.lesson_id),
      updated_at          = now()
    where vocabulary_id = new.vocabulary_id;
  end if;

  return new;
end;
$$;

create trigger trg_lesson_vocabulary_state_machine
before insert on public.lesson_vocabulary
for each row
execute function public.fn_lesson_vocabulary_state_machine();
