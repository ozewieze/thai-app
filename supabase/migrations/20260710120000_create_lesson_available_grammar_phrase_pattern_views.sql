-- Views: previously introduced grammar / phrases / patterns per les
-- ============================================================
-- Doel: hetzelfde continuïteitspatroon toepassen op grammar, phrases
-- en patterns als wat al bestaat voor vocabulaire via
-- lesson_available_vocabulary_view.
--
-- Aanleiding: de dialoog-builder-query gaf voor grammar/phrases/patterns
-- alleen de eigen doel-items van de huidige les mee (required_*_list).
-- Er was geen signaal voor "dit concept is al in een eerdere les
-- geïntroduceerd" — waardoor de AI zulke concepten soms ten onrechte
-- als nieuw behandelde.
--
-- De onderliggende statustabellen (grammar_status, phrase_status,
-- pattern_status) bestaan al sinds migratie
-- 20260610100000_role_and_triggers_grammar_phrase_pattern.sql en hebben
-- exact dezelfde vorm als vocabulary_status (status, first_lesson_id).
-- Deze migratie voegt enkel de ontbrekende views toe, naar analogie van
-- lesson_available_vocabulary_view (sequence_number-gebaseerde filter,
-- security_invoker = true zodat RLS op de onderliggende tabellen niet
-- wordt omzeild).
-- ============================================================

-- ---------------------------------------------------------
-- 1. lesson_available_grammar_view
-- ---------------------------------------------------------

drop view if exists public.lesson_available_grammar_view;

create or replace view public.lesson_available_grammar_view
  with (security_invoker = true)
as
select
  l.id             as lesson_id,
  l.lesson_key,
  l.sequence_number,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'grammar_id',            gm.id,
        'concept_key',           gm.concept_key,
        'title',                 gm.title,
        'short_explanation',     gm.short_explanation,
        'concept_type',          gm.concept_type,
        'register',              gm.register,
        'status',                gs.status,
        'first_lesson_id',       gs.first_lesson_id,
        'intro_sequence_number', intro.sequence_number
      )
      order by intro.sequence_number, gm.id
    )
    from public.grammar_status gs
    join public.grammar_master gm    on gm.id    = gs.grammar_id
    join public.lessons        intro on intro.id = gs.first_lesson_id
    where gs.first_lesson_id is not null
      and intro.sequence_number < l.sequence_number
  ), '[]'::jsonb) as previously_introduced_grammar

from public.lessons l;


-- ---------------------------------------------------------
-- 2. lesson_available_phrase_view
-- ---------------------------------------------------------

drop view if exists public.lesson_available_phrase_view;

create or replace view public.lesson_available_phrase_view
  with (security_invoker = true)
as
select
  l.id             as lesson_id,
  l.lesson_key,
  l.sequence_number,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'phrase_id',             pm.id,
        'phrase_key',            pm.phrase_key,
        'title',                 pm.title,
        'phrase_formula',        pm.phrase_formula,
        'short_explanation',     pm.short_explanation,
        'phrase_type',           pm.phrase_type,
        'register',              pm.register,
        'fixedness_level',       pm.fixedness_level,
        'is_productive',         pm.is_productive,
        'status',                ps.status,
        'first_lesson_id',       ps.first_lesson_id,
        'intro_sequence_number', intro.sequence_number
      )
      order by intro.sequence_number, pm.id
    )
    from public.phrase_status ps
    join public.phrase_master pm    on pm.id    = ps.phrase_id
    join public.lessons       intro on intro.id = ps.first_lesson_id
    where ps.first_lesson_id is not null
      and intro.sequence_number < l.sequence_number
  ), '[]'::jsonb) as previously_introduced_phrases

from public.lessons l;


-- ---------------------------------------------------------
-- 3. lesson_available_pattern_view
-- ---------------------------------------------------------

drop view if exists public.lesson_available_pattern_view;

create or replace view public.lesson_available_pattern_view
  with (security_invoker = true)
as
select
  l.id             as lesson_id,
  l.lesson_key,
  l.sequence_number,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'pattern_id',            pm.id,
        'pattern_key',           pm.pattern_key,
        'title',                 pm.title,
        'pattern_formula',       pm.pattern_formula,
        'short_explanation',     pm.short_explanation,
        'pattern_type',          pm.pattern_type,
        'register',              pm.register,
        'fixedness_level',       pm.fixedness_level,
        'is_productive',         pm.is_productive,
        'status',                pas.status,
        'first_lesson_id',       pas.first_lesson_id,
        'intro_sequence_number', intro.sequence_number
      )
      order by intro.sequence_number, pm.id
    )
    from public.pattern_status pas
    join public.pattern_master pm    on pm.id    = pas.pattern_id
    join public.lessons        intro on intro.id = pas.first_lesson_id
    where pas.first_lesson_id is not null
      and intro.sequence_number < l.sequence_number
  ), '[]'::jsonb) as previously_introduced_patterns

from public.lessons l;
