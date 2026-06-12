-- Migratie: Extend lesson_vocabulary state machine trigger voor UPDATE
-- ============================================================
-- Probleem: de trigger vuurde alleen af bij INSERT. Bij een UPDATE van
-- vocabulary_id (woord verwisselen in een les) gebeurde er twee dingen niet:
--   1. Het nieuwe woord bleef op status 'new' — het werd niet gepromoveerd.
--   2. Het oude woord bleef op 'introduced' — ook al zit het nergens meer in een les.
--
-- Oplossing:
--   - Trigger uitgebreid naar BEFORE INSERT OR UPDATE.
--   - Bij UPDATE: als vocabulary_id veranderd is, wordt het oude woord teruggedraaid
--     naar 'new' (met first_lesson_id = null) als het nergens anders meer voorkomt
--     in lesson_vocabulary. Daarna loopt de bestaande INSERT-logica door voor het
--     nieuwe woord.
-- ============================================================

create or replace function public.fn_lesson_vocabulary_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status     text;
  v_still_used boolean;
begin

  -- ── UPDATE: vocabulary_id is gewisseld ─────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.vocabulary_id is distinct from NEW.vocabulary_id then

    -- Controleer of het oude woord nog ergens anders in lesson_vocabulary voorkomt.
    select exists (
      select 1
      from public.lesson_vocabulary
      where vocabulary_id = OLD.vocabulary_id
        and id <> OLD.id        -- sluit de rij die nu geüpdatet wordt uit
    ) into v_still_used;

    -- Als het nergens anders voorkomt: status terugdraaien naar 'new'.
    if not v_still_used then
      update public.vocabulary_status
      set
        status          = 'new',
        first_lesson_id = null,
        updated_at      = now()
      where vocabulary_id = OLD.vocabulary_id;
    end if;

  end if;

  -- ── INSERT + UPDATE: validatie en statusupdate voor het nieuwe woord ────────

  select status into v_status
  from public.vocabulary_status
  where vocabulary_id = NEW.vocabulary_id;

  if v_status is null then
    raise exception
      'Woord (id: %) heeft geen rij in vocabulary_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.vocabulary_id;
  end if;

  -- Blokkeer dubbele target-introductie (Single Introduction Rule).
  -- Bij UPDATE: alleen blokkeren als het een ánder woord is dan het oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if TG_OP = 'INSERT' or OLD.vocabulary_id is distinct from NEW.vocabulary_id then
      raise exception
        'Woord (id: %) is al geïntroduceerd als target (status: introduced). '
        'De Single Introduction Rule verbiedt een tweede target-introductie.',
        NEW.vocabulary_id;
    end if;
  end if;

  -- Blokkeer ongeldige rollen voor woorden die nog niet geïntroduceerd zijn.
  if v_status = 'new' and NEW.role in ('supporting', 'review', 'bonus') then
    raise exception
      'Woord (id: %) heeft status "new" en mag daarom niet als "%" in een les verschijnen. '
      'Introduceer het woord eerst als target.',
      NEW.vocabulary_id, NEW.role;
  end if;

  -- Promoveer naar introduced bij role = 'target'.
  if NEW.role = 'target' then
    update public.vocabulary_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, NEW.lesson_id),
      updated_at      = now()
    where vocabulary_id = NEW.vocabulary_id;
  end if;

  return NEW;
end;
$$;

-- Trigger opnieuw aanmaken zodat hij ook op UPDATE vuurt.
drop trigger if exists trg_lesson_vocabulary_state_machine on public.lesson_vocabulary;

create trigger trg_lesson_vocabulary_state_machine
before insert or update on public.lesson_vocabulary
for each row
execute function public.fn_lesson_vocabulary_state_machine();
