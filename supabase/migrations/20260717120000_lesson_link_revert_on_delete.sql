-- Migratie: status terugdraaien bij DELETE uit lesson_vocabulary/lesson_grammar/
--           lesson_pattern/lesson_phrase
-- ============================================================
-- Probleem: de bestaande state machine triggers reageren alleen op INSERT
-- (en voor vocabulary ook op UPDATE). Verwijder je een rij uit een van de
-- vier lesson_*-koppeltabellen (bijv. omdat een target-woord/-concept toch
-- niet gebruikt wordt), dan blijft de bijbehorende *_status rij op
-- 'introduced' staan — ook al verwijst nergens meer een les naar dat concept.
-- Door de Single Introduction Rule kan dat concept daarna nooit meer als
-- 'target' geïntroduceerd worden, want de status is nog steeds 'introduced'.
--
-- Oplossing:
--   Voor elk van de vier concepttypes komt er een AFTER DELETE trigger die,
--   ná het verwijderen van een koppelrij, checkt of het concept nog ergens
--   anders in dezelfde koppeltabel voorkomt. Zo niet: status terug naar
--   'new' en first_lesson_id naar null (analoog aan de bestaande UPDATE-tak
--   van fn_lesson_vocabulary_state_machine uit 20260612100000).
--
--   Deze check kijkt puur naar "bestaat er nog een andere rij met dit
--   concept_id", ongeacht role — zodat een status niet wordt teruggedraaid
--   terwijl er bijvoorbeeld nog een 'supporting'-rij naar het concept wijst.
--
--   AFTER DELETE (i.p.v. BEFORE) omdat de rij dan al weg is; er hoeft geen
--   uitsluiting op id te gebeuren zoals bij de UPDATE-tak, en de trigger
--   vuurt ook mee bij cascade-deletes (bijv. een hele les verwijderen via
--   ON DELETE CASCADE op lesson_vocabulary_lesson_fk e.d.).
-- ============================================================


-- ============================================================
-- 1. Vocabulary
-- ============================================================

create or replace function public.fn_lesson_vocabulary_revert_on_delete()
returns trigger
language plpgsql
as $$
declare
  v_still_used boolean;
begin
  select exists (
    select 1
    from public.lesson_vocabulary
    where vocabulary_id = OLD.vocabulary_id
  ) into v_still_used;

  if not v_still_used then
    update public.vocabulary_status
    set
      status          = 'new',
      first_lesson_id = null,
      updated_at      = now()
    where vocabulary_id = OLD.vocabulary_id;
  end if;

  return OLD;
end;
$$;

create trigger trg_lesson_vocabulary_revert_on_delete
after delete on public.lesson_vocabulary
for each row
execute function public.fn_lesson_vocabulary_revert_on_delete();


-- ============================================================
-- 2. Grammar
-- ============================================================

create or replace function public.fn_lesson_grammar_revert_on_delete()
returns trigger
language plpgsql
as $$
declare
  v_still_used boolean;
begin
  select exists (
    select 1
    from public.lesson_grammar
    where grammar_id = OLD.grammar_id
  ) into v_still_used;

  if not v_still_used then
    update public.grammar_status
    set
      status          = 'new',
      first_lesson_id = null,
      updated_at      = now()
    where grammar_id = OLD.grammar_id;
  end if;

  return OLD;
end;
$$;

create trigger trg_lesson_grammar_revert_on_delete
after delete on public.lesson_grammar
for each row
execute function public.fn_lesson_grammar_revert_on_delete();


-- ============================================================
-- 3. Pattern
-- ============================================================

create or replace function public.fn_lesson_pattern_revert_on_delete()
returns trigger
language plpgsql
as $$
declare
  v_still_used boolean;
begin
  select exists (
    select 1
    from public.lesson_pattern
    where pattern_id = OLD.pattern_id
  ) into v_still_used;

  if not v_still_used then
    update public.pattern_status
    set
      status          = 'new',
      first_lesson_id = null,
      updated_at      = now()
    where pattern_id = OLD.pattern_id;
  end if;

  return OLD;
end;
$$;

create trigger trg_lesson_pattern_revert_on_delete
after delete on public.lesson_pattern
for each row
execute function public.fn_lesson_pattern_revert_on_delete();


-- ============================================================
-- 4. Phrase
-- ============================================================

create or replace function public.fn_lesson_phrase_revert_on_delete()
returns trigger
language plpgsql
as $$
declare
  v_still_used boolean;
begin
  select exists (
    select 1
    from public.lesson_phrase
    where phrase_id = OLD.phrase_id
  ) into v_still_used;

  if not v_still_used then
    update public.phrase_status
    set
      status          = 'new',
      first_lesson_id = null,
      updated_at      = now()
    where phrase_id = OLD.phrase_id;
  end if;

  return OLD;
end;
$$;

create trigger trg_lesson_phrase_revert_on_delete
after delete on public.lesson_phrase
for each row
execute function public.fn_lesson_phrase_revert_on_delete();
