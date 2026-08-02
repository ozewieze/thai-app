-- ============================================================
-- Verificatie van language_note_brief_view
-- ============================================================
-- Draaien met:
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres \
--     -P pager=off -f supabase/qa/verify_language_note_brief_view.sql
--
-- Elke query zegt onder de titel wat de verwachte uitkomst is.
-- ============================================================

\echo '--- 1. Aantallen gevlagde concepten voor a1-dialog-03 (verwacht: vocab 2, grammar 1, phrase 0, pattern 1) ---'

select
  jsonb_array_length(vocabulary_to_explain) as vocab,
  jsonb_array_length(grammar_to_explain)    as grammar,
  jsonb_array_length(phrases_to_explain)    as phrases,
  jsonb_array_length(patterns_to_explain)   as patterns,
  jsonb_array_length(example_vocabulary_budget) as budget_woorden
from public.language_note_brief_view
where lesson_key = 'a1-dialog-03';


\echo '--- 2. Kruiscontrole: dezelfde telling rechtstreeks op de link-tabellen (moet identiek zijn aan 1) ---'

select
  (select count(*) from public.lesson_vocabulary lv
     where lv.lesson_id = l.id and lv.requires_explanation) as vocab,
  (select count(*) from public.lesson_grammar lg
     where lg.lesson_id = l.id and lg.requires_explanation) as grammar,
  (select count(*) from public.lesson_phrase lp
     where lp.lesson_id = l.id and lp.requires_explanation) as phrases,
  (select count(*) from public.lesson_pattern lpat
     where lpat.lesson_id = l.id and lpat.requires_explanation) as patterns
from public.lessons l
where l.lesson_key = 'a1-dialog-03';


\echo '--- 3. Welke concepten precies (verwacht: ร้อน, เย็น, adjective_after_noun, ja_verb) ---'

select
  'vocabulary' as soort,
  c ->> 'source_key' as sleutel,
  c ->> 'thai_script' as thai,
  c ->> 'paiboon' as paiboon,
  c ->> 'usage_note' as usage_note
from public.language_note_brief_view v,
     jsonb_array_elements(v.vocabulary_to_explain) c
where v.lesson_key = 'a1-dialog-03'
union all
select 'grammar', c ->> 'concept_key', c ->> 'title', null, c ->> 'short_explanation'
from public.language_note_brief_view v,
     jsonb_array_elements(v.grammar_to_explain) c
where v.lesson_key = 'a1-dialog-03'
union all
select 'pattern', c ->> 'pattern_key', c ->> 'title', null, c ->> 'short_explanation'
from public.language_note_brief_view v,
     jsonb_array_elements(v.patterns_to_explain) c
where v.lesson_key = 'a1-dialog-03';


\echo '--- 4. Link-ids bestaan echt in hun link-tabel (verwacht: 0 rijen) ---'

select 'vocab' as soort, (c ->> 'lesson_vocabulary_id')::bigint as ontbrekend_id
from public.language_note_brief_view v,
     jsonb_array_elements(v.vocabulary_to_explain) c
where not exists (
  select 1 from public.lesson_vocabulary lv
  where lv.id = (c ->> 'lesson_vocabulary_id')::bigint
    and lv.lesson_id = v.lesson_id
)
union all
select 'grammar', (c ->> 'lesson_grammar_id')::bigint
from public.language_note_brief_view v,
     jsonb_array_elements(v.grammar_to_explain) c
where not exists (
  select 1 from public.lesson_grammar lg
  where lg.id = (c ->> 'lesson_grammar_id')::bigint
    and lg.lesson_id = v.lesson_id
)
union all
select 'pattern', (c ->> 'lesson_pattern_id')::bigint
from public.language_note_brief_view v,
     jsonb_array_elements(v.patterns_to_explain) c
where not exists (
  select 1 from public.lesson_pattern lpat
  where lpat.id = (c ->> 'lesson_pattern_id')::bigint
    and lpat.lesson_id = v.lesson_id
);


\echo '--- 5. Geen dubbele woorden in enig woordbudget, over alle lessen (verwacht: 0 rijen) ---'

select v.lesson_key, w ->> 'source_key' as source_key, count(*)
from public.language_note_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budget) w
group by v.lesson_key, w ->> 'source_key'
having count(*) > 1;


\echo '--- 6. Elk budgetwoord heeft een paiboon-vorm, over alle lessen (verwacht: 0 rijen) ---'

select v.lesson_key, w ->> 'source_key' as source_key
from public.language_note_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budget) w
where coalesce(w ->> 'paiboon', '') = '';


\echo '--- 7. Geen paiboon met kh/th/ph (RTGS-lek), over alle lessen (verwacht: 0 rijen) ---'

select distinct w ->> 'source_key' as source_key, w ->> 'paiboon' as paiboon
from public.language_note_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budget) w
where w ->> 'paiboon' ~ '(kh|th|ph)';


\echo '--- 8. Woordbudget van les 03 (verwacht: 16 woorden, lessen 1-3, geen woord uit een latere les) ---'

select
  w ->> 'source_key'            as source_key,
  w ->> 'thai_script'           as thai,
  w ->> 'paiboon'               as paiboon,
  w ->> 'availability'          as beschikbaarheid,
  w ->> 'intro_sequence_number' as intro_les
from public.language_note_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budget) w
where v.lesson_key = 'a1-dialog-03'
order by (w ->> 'intro_sequence_number')::int, w ->> 'source_key';


\echo '--- 9. Geen budgetwoord uit een latere les, over alle lessen (verwacht: 0 rijen) ---'

select v.lesson_key, w ->> 'source_key' as source_key,
       (w ->> 'intro_sequence_number')::int as intro_les, v.sequence_number
from public.language_note_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budget) w
where (w ->> 'intro_sequence_number')::int > v.sequence_number;


\echo '--- 10. Dialoog van les 03 (verwacht: blokken op volgorde, thai + transliteratie + vertaling) ---'

select
  b ->> 'block_index'     as idx,
  b ->> 'speaker_key'     as spreker,
  b ->> 'thai_text'       as thai,
  b ->> 'transliteration' as translit,
  b ->> 'translation_en'  as vertaling
from public.language_note_brief_view v,
     jsonb_array_elements(v.dialog -> 'blocks') b
where v.lesson_key = 'a1-dialog-03'
order by (b ->> 'block_index')::int;


\echo '--- 11. Controleles: a1-dialog-01 staat nog volledig op true (verwacht: vocab 6, grammar 1, phrases 2) ---'

select
  jsonb_array_length(vocabulary_to_explain) as vocab,
  jsonb_array_length(grammar_to_explain)    as grammar,
  jsonb_array_length(phrases_to_explain)    as phrases,
  jsonb_array_length(example_vocabulary_budget) as budget_woorden
from public.language_note_brief_view
where lesson_key = 'a1-dialog-01';
