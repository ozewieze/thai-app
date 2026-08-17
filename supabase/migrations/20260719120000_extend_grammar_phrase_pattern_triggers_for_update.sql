-- Migratie: Extend lesson_grammar/lesson_phrase/lesson_pattern state machine
--           triggers voor UPDATE
-- ============================================================
-- Probleem: net als bij lesson_vocabulary (zie 20260612100000) vuurden deze
-- drie triggers alleen af bij INSERT. Bij een UPDATE van grammar_id/phrase_id/
-- pattern_id (concept verwisselen in een les) gebeurde er twee dingen niet:
--   1. Het nieuwe concept bleef op status 'new' — het werd niet gepromoveerd.
--   2. Het oude concept bleef op 'introduced' — ook al zit het nergens meer
--      in een les.
--
-- Oplossing: dezelfde UPDATE-tak als in 20260612100000, per concepttype.
-- De revert-check (bestaat het oude concept nog elders in de koppeltabel,
-- met uitsluiting van de rij die nu geüpdatet wordt) is identiek aan de
-- AFTER DELETE-varianten uit 20260717120000, enkel BEFORE UPDATE i.p.v.
-- AFTER DELETE, en met `id <> OLD.id` omdat de rij hier nog bestaat.
--
-- Geen extra validatie overgenomen uit de vocabulary-trigger: grammar/phrase/
-- pattern kennen geen blokkade op role 'supporting'/'review'/'bonus' bij
-- status 'new' (zie het commentaar in 20260610100000) — dat verschil blijft
-- ongewijzigd.
-- ============================================================


-- ============================================================
-- 1. Grammar
-- ============================================================

create or replace function public.fn_lesson_grammar_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status     text;
  v_still_used boolean;
begin

  -- ── UPDATE: grammar_id is gewisseld ─────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.grammar_id is distinct from NEW.grammar_id then

    select exists (
      select 1
      from public.lesson_grammar
      where grammar_id = OLD.grammar_id
        and id <> OLD.id
    ) into v_still_used;

    if not v_still_used then
      update public.grammar_status
      set
        status          = 'new',
        first_lesson_id = null,
        updated_at      = now()
      where grammar_id = OLD.grammar_id;
    end if;

  end if;

  -- ── INSERT + UPDATE: validatie en statusupdate voor het nieuwe concept ──

  select status into v_status
  from public.grammar_status
  where grammar_id = NEW.grammar_id;

  if v_status is null then
    raise exception
      'Grammar concept (id: %) heeft geen rij in grammar_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.grammar_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  -- Bij UPDATE: alleen blokkeren als het een ánder concept is dan het oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if TG_OP = 'INSERT' or OLD.grammar_id is distinct from NEW.grammar_id then
      raise exception
        'Grammar concept (id: %) is al geïntroduceerd als target (status: introduced). '
        'De Single Introduction Rule verbiedt een tweede target-introductie.',
        NEW.grammar_id;
    end if;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if NEW.role = 'target' then
    update public.grammar_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, NEW.lesson_id),
      updated_at      = now()
    where grammar_id = NEW.grammar_id;
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_lesson_grammar_state_machine on public.lesson_grammar;

create trigger trg_lesson_grammar_state_machine
before insert or update on public.lesson_grammar
for each row
execute function public.fn_lesson_grammar_state_machine();


-- ============================================================
-- 2. Phrase
-- ============================================================

create or replace function public.fn_lesson_phrase_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status     text;
  v_still_used boolean;
begin

  -- ── UPDATE: phrase_id is gewisseld ──────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.phrase_id is distinct from NEW.phrase_id then

    select exists (
      select 1
      from public.lesson_phrase
      where phrase_id = OLD.phrase_id
        and id <> OLD.id
    ) into v_still_used;

    if not v_still_used then
      update public.phrase_status
      set
        status          = 'new',
        first_lesson_id = null,
        updated_at      = now()
      where phrase_id = OLD.phrase_id;
    end if;

  end if;

  -- ── INSERT + UPDATE: validatie en statusupdate voor de nieuwe phrase ────

  select status into v_status
  from public.phrase_status
  where phrase_id = NEW.phrase_id;

  if v_status is null then
    raise exception
      'Phrase (id: %) heeft geen rij in phrase_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.phrase_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  -- Bij UPDATE: alleen blokkeren als het een ándere phrase is dan de oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if TG_OP = 'INSERT' or OLD.phrase_id is distinct from NEW.phrase_id then
      raise exception
        'Phrase (id: %) is al geïntroduceerd als target (status: introduced). '
        'De Single Introduction Rule verbiedt een tweede target-introductie.',
        NEW.phrase_id;
    end if;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if NEW.role = 'target' then
    update public.phrase_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, NEW.lesson_id),
      updated_at      = now()
    where phrase_id = NEW.phrase_id;
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_lesson_phrase_state_machine on public.lesson_phrase;

create trigger trg_lesson_phrase_state_machine
before insert or update on public.lesson_phrase
for each row
execute function public.fn_lesson_phrase_state_machine();


-- ============================================================
-- 3. Pattern
-- ============================================================

create or replace function public.fn_lesson_pattern_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status     text;
  v_still_used boolean;
begin

  -- ── UPDATE: pattern_id is gewisseld ─────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.pattern_id is distinct from NEW.pattern_id then

    select exists (
      select 1
      from public.lesson_pattern
      where pattern_id = OLD.pattern_id
        and id <> OLD.id
    ) into v_still_used;

    if not v_still_used then
      update public.pattern_status
      set
        status          = 'new',
        first_lesson_id = null,
        updated_at      = now()
      where pattern_id = OLD.pattern_id;
    end if;

  end if;

  -- ── INSERT + UPDATE: validatie en statusupdate voor het nieuwe pattern ──

  select status into v_status
  from public.pattern_status
  where pattern_id = NEW.pattern_id;

  if v_status is null then
    raise exception
      'Pattern (id: %) heeft geen rij in pattern_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.pattern_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  -- Bij UPDATE: alleen blokkeren als het een ánder pattern is dan het oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if TG_OP = 'INSERT' or OLD.pattern_id is distinct from NEW.pattern_id then
      raise exception
        'Pattern (id: %) is al geïntroduceerd als target (status: introduced). '
        'De Single Introduction Rule verbiedt een tweede target-introductie.',
        NEW.pattern_id;
    end if;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if NEW.role = 'target' then
    update public.pattern_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, NEW.lesson_id),
      updated_at      = now()
    where pattern_id = NEW.pattern_id;
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_lesson_pattern_state_machine on public.lesson_pattern;

create trigger trg_lesson_pattern_state_machine
before insert or update on public.lesson_pattern
for each row
execute function public.fn_lesson_pattern_state_machine();
