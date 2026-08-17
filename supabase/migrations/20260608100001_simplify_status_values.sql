-- Migratie: Vereenvoudig statuswaarden in alle vier statustabellen
-- ============================================================
-- Drie wijzigingen:
--
--   1. theme_exposed verwijderd uit vocabulary_status
--      theme_exposed was bedoeld voor woorden die in een thema-les gezien zijn
--      maar nog niet formeel geïntroduceerd. Er bestaat echter geen trigger die
--      woorden naar theme_exposed zet, en thema-lessen zullen vocabulaire bevatten
--      buiten vocabulary_master. Thema-tracking krijgt een eigen systeem.
--
--   2. introduced_core hernoemd naar introduced in alle vier tabellen
--      (vocabulary_status, grammar_status, phrase_status, pattern_status)
--      voor consistentie en leesbaarheid.
--
--   3. first_exposure_type verwijderd uit vocabulary_status
--      Dit veld had alleen waarde bij theme_exposed (om bij te houden of een woord
--      via een thema of direct via een dialoog was geïntroduceerd). Zonder
--      theme_exposed is er maar één introductiepad, waardoor het veld overbodig is.
--
-- Volgorde per tabel:
--   a. Drop old constraints
--   b. Update bestaande data
--   c. Drop kolom (alleen vocabulary_status: first_exposure_type)
--   d. Add new constraints
--
-- Afsluitend: fn_lesson_vocabulary_state_machine vereenvoudigd.
-- ============================================================


-- ============================================================
-- 1. vocabulary_status
-- ============================================================

-- Drop alle constraints die de oude waarden of kolom bevatten
alter table public.vocabulary_status
  drop constraint vocabulary_status_status_check;

alter table public.vocabulary_status
  drop constraint vocabulary_status_first_context_required_check;

alter table public.vocabulary_status
  drop constraint vocabulary_status_first_exposure_type_check;

-- Hernoem introduced_core → introduced in bestaande data
-- (theme_exposed bestaat niet in de data: er is nooit een trigger geweest
--  die woorden naar theme_exposed heeft gezet)
update public.vocabulary_status
set status = 'introduced'
where status = 'introduced_core';

-- Drop first_exposure_type kolom
alter table public.vocabulary_status
  drop column first_exposure_type;

-- Voeg nieuwe constraints toe
alter table public.vocabulary_status
  add constraint vocabulary_status_status_check
    check (status in ('new', 'introduced'));

alter table public.vocabulary_status
  add constraint vocabulary_status_first_context_required_check
    check (
      (status = 'new'          and first_lesson_id is null) or
      (status = 'introduced'   and first_lesson_id is not null)
    );


-- ============================================================
-- 2. grammar_status
-- ============================================================

alter table public.grammar_status
  drop constraint grammar_status_status_check;

alter table public.grammar_status
  drop constraint grammar_status_first_context_required_check;

update public.grammar_status
set status = 'introduced'
where status = 'introduced_core';

alter table public.grammar_status
  add constraint grammar_status_status_check
    check (status in ('new', 'introduced'));

alter table public.grammar_status
  add constraint grammar_status_first_context_required_check
    check (
      (status = 'new'        and first_lesson_id is null) or
      (status = 'introduced' and first_lesson_id is not null)
    );


-- ============================================================
-- 3. phrase_status
-- ============================================================

alter table public.phrase_status
  drop constraint phrase_status_status_check;

alter table public.phrase_status
  drop constraint phrase_status_first_context_required_check;

update public.phrase_status
set status = 'introduced'
where status = 'introduced_core';

alter table public.phrase_status
  add constraint phrase_status_status_check
    check (status in ('new', 'introduced'));

alter table public.phrase_status
  add constraint phrase_status_first_context_required_check
    check (
      (status = 'new'        and first_lesson_id is null) or
      (status = 'introduced' and first_lesson_id is not null)
    );


-- ============================================================
-- 4. pattern_status
-- ============================================================

alter table public.pattern_status
  drop constraint pattern_status_status_check;

alter table public.pattern_status
  drop constraint pattern_status_first_context_required_check;

update public.pattern_status
set status = 'introduced'
where status = 'introduced_core';

alter table public.pattern_status
  add constraint pattern_status_status_check
    check (status in ('new', 'introduced'));

alter table public.pattern_status
  add constraint pattern_status_first_context_required_check
    check (
      (status = 'new'        and first_lesson_id is null) or
      (status = 'introduced' and first_lesson_id is not null)
    );


-- ============================================================
-- 5. Vereenvoudig fn_lesson_vocabulary_state_machine
-- ============================================================
-- Wijzigingen t.o.v. vorige versie:
--   - theme_exposed-check verwijderd (bestond niet meer als geldige status)
--   - introduced_core vervangen door introduced
--   - COALESCE voor first_exposure_type verwijderd
--   - Foutmelding voor ongeldige rol vereenvoudigd (alleen 'new' blokkeren)

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

  -- Veiligheidscheck: elk woord hoort een statusrij te hebben na de backfill.
  if v_status is null then
    raise exception
      'Woord (id: %) heeft geen rij in vocabulary_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      new.vocabulary_id;
  end if;

  -- Blokkeer dubbele target-introductie (Single Introduction Rule).
  -- Extra vangnet bovenop de partial unique index uit migratie 20260607100003.
  if new.role = 'target' and v_status = 'introduced' then
    raise exception
      'Woord (id: %) is al geïntroduceerd als target (status: introduced). '
      'De Single Introduction Rule verbiedt een tweede target-introductie.',
      new.vocabulary_id;
  end if;

  -- Blokkeer ongeldige rollen voor woorden die nog niet geïntroduceerd zijn.
  -- Een woord met status "new" mag niet als supporting, review of bonus verschijnen
  -- — het is immers nog niet verondersteld gekend bij de leerling.
  if v_status = 'new' and new.role in ('supporting', 'review', 'bonus') then
    raise exception
      'Woord (id: %) heeft status "new" en mag daarom niet als "%" in een les verschijnen. '
      'Introduceer het woord eerst als target.',
      new.vocabulary_id, new.role;
  end if;

  -- Bij role = 'target': promoveer het woord naar introduced.
  -- COALESCE als vangnet: overschrijf first_lesson_id nooit als het al gezet is.
  if new.role = 'target' then
    update public.vocabulary_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, new.lesson_id),
      updated_at      = now()
    where vocabulary_id = new.vocabulary_id;
  end if;

  return new;
end;
$$;
