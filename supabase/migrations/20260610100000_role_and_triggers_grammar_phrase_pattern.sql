-- Migratie: role-kolom, backfill en triggers voor grammar, phrase en pattern
-- ============================================================
-- Onderdelen:
--   1. role kolom toevoegen aan lesson_grammar
--   2. role kolom toevoegen aan lesson_pattern
--   3. Backfill grammar_status voor bestaande grammar_master records
--   4. Backfill phrase_status voor bestaande phrase_master records
--   5. Backfill pattern_status voor bestaande pattern_master records
--   6. Initialisatietrigger op grammar_master
--   7. Initialisatietrigger op phrase_master
--   8. Initialisatietrigger op pattern_master
--   9. State machine trigger op lesson_grammar
--  10. State machine trigger op lesson_phrase
--  11. State machine trigger op lesson_pattern
--
-- Opmerking over de state machine (verschil met vocabulary):
--   Bij vocabulary wordt een rol 'supporting'/'review'/'bonus' geblokkeerd
--   als het woord nog status 'new' heeft. Voor grammar, phrases en patterns
--   geldt deze blokkade NIET: een concept kan in een les voorkomen vóór de
--   formele introductie als target. De AI kan dergelijke concepten inbrengen;
--   de auteur herkent ze achteraf en voegt ze eventueel toe aan de mastertabellen.
--
--   Wél gehandhaafd: de Single Introduction Rule — elk concept mag slechts
--   eenmaal als 'target' worden gemarkeerd.
-- ============================================================


-- ============================================================
-- 1. role kolom toevoegen aan lesson_grammar
-- ============================================================
-- Tijdelijk default 'target' zodat bestaande rijen een geldige waarde krijgen.
-- Default wordt daarna verwijderd: role is verplicht bij nieuwe inserts.

alter table public.lesson_grammar
  add column role text not null default 'target';

alter table public.lesson_grammar
  alter column role drop default;

alter table public.lesson_grammar
  add constraint lesson_grammar_role_check
    check (role in ('target', 'supporting', 'review', 'bonus'));


-- ============================================================
-- 2. role kolom toevoegen aan lesson_pattern
-- ============================================================

alter table public.lesson_pattern
  add column role text not null default 'target';

alter table public.lesson_pattern
  alter column role drop default;

alter table public.lesson_pattern
  add constraint lesson_pattern_role_check
    check (role in ('target', 'supporting', 'review', 'bonus'));


-- ============================================================
-- 3. Backfill grammar_status
-- ============================================================
-- Maakt een 'new'-rij aan voor elk grammar_master record dat nog geen
-- corresponderende rij in grammar_status heeft.

insert into public.grammar_status (grammar_id, status)
select id, 'new'
from public.grammar_master
on conflict (grammar_id) do nothing;


-- ============================================================
-- 4. Backfill phrase_status
-- ============================================================

insert into public.phrase_status (phrase_id, status)
select id, 'new'
from public.phrase_master
on conflict (phrase_id) do nothing;


-- ============================================================
-- 5. Backfill pattern_status
-- ============================================================

insert into public.pattern_status (pattern_id, status)
select id, 'new'
from public.pattern_master
on conflict (pattern_id) do nothing;


-- ============================================================
-- 6. Initialisatietrigger op grammar_master
-- ============================================================

create or replace function public.fn_initialize_grammar_status()
returns trigger
language plpgsql
as $$
begin
  insert into public.grammar_status (grammar_id, status)
  values (new.id, 'new');
  return new;
end;
$$;

create trigger trg_initialize_grammar_status
after insert on public.grammar_master
for each row
execute function public.fn_initialize_grammar_status();


-- ============================================================
-- 7. Initialisatietrigger op phrase_master
-- ============================================================

create or replace function public.fn_initialize_phrase_status()
returns trigger
language plpgsql
as $$
begin
  insert into public.phrase_status (phrase_id, status)
  values (new.id, 'new');
  return new;
end;
$$;

create trigger trg_initialize_phrase_status
after insert on public.phrase_master
for each row
execute function public.fn_initialize_phrase_status();


-- ============================================================
-- 8. Initialisatietrigger op pattern_master
-- ============================================================

create or replace function public.fn_initialize_pattern_status()
returns trigger
language plpgsql
as $$
begin
  insert into public.pattern_status (pattern_id, status)
  values (new.id, 'new');
  return new;
end;
$$;

create trigger trg_initialize_pattern_status
after insert on public.pattern_master
for each row
execute function public.fn_initialize_pattern_status();


-- ============================================================
-- 9. State machine trigger op lesson_grammar
-- ============================================================

create or replace function public.fn_lesson_grammar_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status text;
begin
  select status into v_status
  from public.grammar_status
  where grammar_id = new.grammar_id;

  if v_status is null then
    raise exception
      'Grammar concept (id: %) heeft geen rij in grammar_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      new.grammar_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  if new.role = 'target' and v_status = 'introduced' then
    raise exception
      'Grammar concept (id: %) is al geïntroduceerd als target (status: introduced). '
      'De Single Introduction Rule verbiedt een tweede target-introductie.',
      new.grammar_id;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if new.role = 'target' then
    update public.grammar_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, new.lesson_id),
      updated_at      = now()
    where grammar_id = new.grammar_id;
  end if;

  return new;
end;
$$;

create trigger trg_lesson_grammar_state_machine
before insert on public.lesson_grammar
for each row
execute function public.fn_lesson_grammar_state_machine();


-- ============================================================
-- 10. State machine trigger op lesson_phrase
-- ============================================================

create or replace function public.fn_lesson_phrase_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status text;
begin
  select status into v_status
  from public.phrase_status
  where phrase_id = new.phrase_id;

  if v_status is null then
    raise exception
      'Phrase (id: %) heeft geen rij in phrase_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      new.phrase_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  if new.role = 'target' and v_status = 'introduced' then
    raise exception
      'Phrase (id: %) is al geïntroduceerd als target (status: introduced). '
      'De Single Introduction Rule verbiedt een tweede target-introductie.',
      new.phrase_id;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if new.role = 'target' then
    update public.phrase_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, new.lesson_id),
      updated_at      = now()
    where phrase_id = new.phrase_id;
  end if;

  return new;
end;
$$;

create trigger trg_lesson_phrase_state_machine
before insert on public.lesson_phrase
for each row
execute function public.fn_lesson_phrase_state_machine();


-- ============================================================
-- 11. State machine trigger op lesson_pattern
-- ============================================================

create or replace function public.fn_lesson_pattern_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status text;
begin
  select status into v_status
  from public.pattern_status
  where pattern_id = new.pattern_id;

  if v_status is null then
    raise exception
      'Pattern (id: %) heeft geen rij in pattern_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      new.pattern_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  if new.role = 'target' and v_status = 'introduced' then
    raise exception
      'Pattern (id: %) is al geïntroduceerd als target (status: introduced). '
      'De Single Introduction Rule verbiedt een tweede target-introductie.',
      new.pattern_id;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if new.role = 'target' then
    update public.pattern_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, new.lesson_id),
      updated_at      = now()
    where pattern_id = new.pattern_id;
  end if;

  return new;
end;
$$;

create trigger trg_lesson_pattern_state_machine
before insert on public.lesson_pattern
for each row
execute function public.fn_lesson_pattern_state_machine();
