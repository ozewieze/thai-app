-- ============================================================
-- Verificatie van 20260802120000_single_introduction_allow_reseed
-- ============================================================
-- Twee vragen:
--   A. Kan dezelfde les zichzelf opnieuw seeden?  (moet nu WEL)
--   B. Kan een andere les een al geïntroduceerd concept als target
--      claimen?                                   (moet nog steeds NIET)
--
-- Test B draait in een transactie die altijd terugrolt: er verandert
-- niets aan je data, ook niet als de test onverwacht slaagt.
--
-- Draaien met:
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres \
--     -P pager=off -f supabase/qa/verify_single_introduction_reseed.sql
-- ============================================================

\echo ''
\echo '=== A. Re-seed van dezelfde les -- verwacht: geen fout ==='
\echo '(draai hierna ook het seedbestand zelf nog een tweede keer)'

\i supabase/seed-data/links/lesson_links_a1-dialog-03.seed.sql


\echo ''
\echo '=== A2. Status na de re-seed -- verwacht: introduced, first_lesson = a1-dialog-03 ==='

select
  vm.source_key,
  vs.status,
  l.lesson_key as first_lesson,
  lv.requires_explanation
from public.lesson_vocabulary lv
join public.vocabulary_master vm on vm.id = lv.vocabulary_id
join public.vocabulary_status vs on vs.vocabulary_id = vm.id
left join public.lessons l on l.id = vs.first_lesson_id
where lv.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-03')
order by lv.display_order;


\echo ''
\echo '=== A3. Geen dubbele rijen ontstaan -- verwacht: 4 ==='

select count(*) as rijen_lesson_vocabulary
from public.lesson_vocabulary
where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-03');


\echo ''
\echo '=== B. Andere les claimt hetzelfde woord als target -- verwacht: ERROR ==='
\echo '(ชา is in les 03 geintroduceerd; les 05 mag dat niet overdoen)'

begin;

insert into public.lesson_vocabulary (
  lesson_id,
  vocabulary_id,
  role,
  requires_explanation,
  display_order,
  notes
)
values (
  (select id from public.lessons where lesson_key = 'a1-dialog-05'),
  (select id from public.vocabulary_master where source_key = 'tea'),
  'target',
  false,
  99,
  'TESTRIJ -- deze transactie rolt terug'
);

rollback;

\echo ''
\echo '=== Klaar. A zonder fout + B met fout = migratie werkt zoals bedoeld. ==='
