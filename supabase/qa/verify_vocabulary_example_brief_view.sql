-- ============================================================
-- Verificatie van vocabulary_example_brief_view
-- ============================================================
-- Draaien met (PowerShell, één regel):
--   $env:PGCLIENTENCODING="UTF8"; psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -P pager=off -f supabase/qa/verify_vocabulary_example_brief_view.sql
--
-- PGCLIENTENCODING is niet optioneel: zonder UTF-8 komt het Thaise
-- schrift als vraagtekens terug en beoordeel je iets anders dan wat er
-- in de database staat.
--
-- Alleen lezen. Elke query zegt onder de titel wat de verwachte
-- uitkomst is.
--
-- ------------------------------------------------------------
-- Twee soorten controles, en het verschil is wezenlijk
-- ------------------------------------------------------------
-- DATACONTROLES (3, 4, 5, 8, 9, 10) vuren op kapotte inhoud. Ze zijn
-- stuk voor stuk negatief getest: de fout is in een transactie
-- geinjecteerd, de sectie gaf de verwachte rij, en de transactie is
-- teruggedraaid.
--
-- INVARIANTCONTROLES (6, 7, 13, 14) vuren NIET op kapotte data. Ze
-- vergelijken de view met zijn eigen definitie of met een andere
-- implementatie, en bewaken dus een toekomstige HERSCHRIJVING van de
-- view, niet de inhoud van de database.
--
-- Dat geldt in het bijzonder voor sectie 7, de progressieregel. Het
-- budgetpredicaat van de view is
--   intro.sequence_number <= sequence_number(anker)
-- waardoor een schending in de output structureel onmogelijk is: de
-- sectie kan per constructie geen rij geven zolang dat predicaat er
-- staat. Dat is negatief bevestigd -- ook op moedwillig kapotte data
-- bleef sectie 7 leeg. Ze staat er als regressiewacht: wie het
-- predicaat ooit verruimt, hoort het hier te merken. Wie hier een groen
-- vinkje leest als "de data klopt", leest iets wat er niet staat.
--
-- Sectie 14 is de sterkste van de vier: die vergelijkt het budget met
-- lesson_available_vocabulary_view, een onafhankelijk geschreven view.
-- ============================================================

\echo '--- 1. Werklijst en budget per les (verwacht: elke les met doelwoorden heeft precies 1 budgetblok) ---'

select
  lesson_key,
  sequence_number                                as les,
  jsonb_array_length(target_words)               as doelwoorden,
  jsonb_array_length(example_vocabulary_budgets) as budgetblokken,
  (
    select sum((b ->> 'word_count')::int)
    from jsonb_array_elements(example_vocabulary_budgets) b
  )                                              as budgetwoorden_totaal
from public.vocabulary_example_brief_view
order by sequence_number;


\echo '--- 2. Kruiscontrole: doelwoorden rechtstreeks op lesson_vocabulary (moet identiek zijn aan kolom doelwoorden in 1) ---'

select
  l.lesson_key,
  count(*) filter (where lv.role = 'target') as doelwoorden
from public.lessons l
left join public.lesson_vocabulary lv on lv.lesson_id = l.id
group by l.lesson_key, l.sequence_number
order by l.sequence_number;


\echo '--- 3. Elke lesson_vocabulary_id in de werklijst bestaat en hoort bij deze les (verwacht: 0 rijen) ---'

select v.lesson_key, (w ->> 'lesson_vocabulary_id')::bigint as ontbrekend_id
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.target_words) w
where not exists (
  select 1 from public.lesson_vocabulary lv
  where lv.id = (w ->> 'lesson_vocabulary_id')::bigint
    and lv.lesson_id = v.lesson_id
    and lv.role = 'target'
);


\echo '--- 4. RTGS-lek: geen paiboon met kh/th/ph, in werklijst, budget en bestaande voorbeelden (verwacht: 0 rijen) ---'
-- Paiboon schrijft geaspireerde medeklinkers zonder h: ข/ค = k, ถ/ท = t,
-- ผ/พ/ภ = p. kh/th/ph is RTGS. Deze fout moest op 2026-07-13 over 167
-- vocabulairerijen gecorrigeerd worden en verstopt zich goed -- vandaar
-- een controle op alle drie de plaatsen waar paiboon de view verlaat.

select 'werklijst' as bron, w ->> 'source_key' as sleutel, w ->> 'paiboon' as paiboon
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.target_words) w
where w ->> 'paiboon' ~ '(kh|th|ph)'
union
select 'budget', b ->> 'source_key', b ->> 'paiboon'
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budgets) blk,
     jsonb_array_elements(blk -> 'words') b
where b ->> 'paiboon' ~ '(kh|th|ph)'
union
select 'voorbeeld', w ->> 'source_key', e ->> 'paiboon'
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.target_words) w,
     jsonb_array_elements(w -> 'existing_examples') e
where e ->> 'paiboon' ~ '(kh|th|ph)';


\echo '--- 5. Elk budgetwoord heeft een niet-lege paiboon (verwacht: 0 rijen) ---'
-- Een budgetwoord zonder paiboon dwingt het model tot reconstrueren, en
-- dat is precies waar de RTGS-fout vandaan komt. paiboon is nullable in
-- vocabulary_master, dus dit is een echte mogelijkheid.

select distinct v.lesson_key, b ->> 'source_key' as sleutel, b ->> 'thai_script' as thai
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budgets) blk,
     jsonb_array_elements(blk -> 'words') b
where coalesce(b ->> 'paiboon', '') = '';


\echo '--- 6. Geen dubbele source_key binnen een budgetblok (verwacht: 0 rijen) ---'

select v.lesson_key, blk ->> 'intro_lesson_key' as blok, b ->> 'source_key' as sleutel, count(*)
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budgets) blk,
     jsonb_array_elements(blk -> 'words') b
group by 1, 2, 3
having count(*) > 1;


\echo '--- 7. PROGRESSIEREGEL, invariant: geen budgetwoord uit een latere les dan het anker van zijn blok (verwacht: 0 rijen) ---'
-- Het anker is de introductieles van het doelwoord, niet de les waarin
-- geschreven wordt. LET OP: dit is een invariantcontrole, geen
-- datacontrole -- zie de kop. Ze kan per constructie niet vuren zolang
-- het budgetpredicaat ongewijzigd is. Sectie 14 is de controle die de
-- progressieregel wel onafhankelijk toetst.

select
  v.lesson_key,
  blk ->> 'intro_lesson_key'              as anker,
  (blk ->> 'intro_sequence_number')::int  as anker_les,
  b   ->> 'source_key'                    as budgetwoord,
  (b   ->> 'intro_sequence_number')::int  as woord_les
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budgets) blk,
     jsonb_array_elements(blk -> 'words') b
where (b ->> 'intro_sequence_number')::int > (blk ->> 'intro_sequence_number')::int;


\echo '--- 8. Elk doelwoord verwijst naar een bestaand budgetblok (verwacht: 0 rijen) ---'
-- Een doelwoord zonder blok betekent dat de schrijver geen budget heeft
-- en dus niet kan beginnen. Vangt ook het geval first_lesson_id is null.

select v.lesson_key, w ->> 'source_key' as doelwoord, w ->> 'intro_lesson_key' as anker
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.target_words) w
where not exists (
  select 1
  from jsonb_array_elements(v.example_vocabulary_budgets) blk
  where blk ->> 'intro_lesson_id' is not distinct from w ->> 'intro_lesson_id'
    and w ->> 'intro_lesson_id' is not null
);


\echo '--- 9. DIVERGENTIESIGNAAL: doelwoorden waarvan de introductieles niet deze les is (verwacht: 0 rijen) ---'
-- Kan volgens fn_lesson_vocabulary_state_machine niet ontstaan. Geeft dit
-- rijen, dan is er upstream iets gebeurd buiten de trigger om -- en dan
-- is het budget van dat woord krapper dan dat van de les, precies het
-- geval waarvoor deze view per introductieles groepeert. Bestaande
-- voorbeelden van dat woord opnieuw controleren (gids, "Onderhoudsgeval").

select
  v.lesson_key                            as werkles,
  v.sequence_number                       as werkles_nr,
  w ->> 'source_key'                      as doelwoord,
  w ->> 'intro_lesson_key'                as introductieles,
  (w ->> 'intro_sequence_number')::int    as introductieles_nr
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.target_words) w
where (w ->> 'is_introduced_here')::boolean is distinct from true;


\echo '--- 10. Doelwoorden met meer dan een canoniek voorbeeld (verwacht: 0 rijen) ---'
-- Vastgelegde beslissing 2: precies een voorbeeld per doelwoord. Twee is
-- geen aanvulling maar een fout.

select v.lesson_key, w ->> 'source_key' as doelwoord,
       (w ->> 'existing_example_count')::int as aantal
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.target_words) w
where (w ->> 'existing_example_count')::int > 1;


\echo '--- 11. Werklijst van a1-dialog-03 (verwacht: needs_example overal true, budget nog leeg van voorbeelden) ---'

select
  w ->> 'source_key'            as sleutel,
  w ->> 'thai_script'           as thai,
  w ->> 'paiboon'               as paiboon,
  w ->> 'english_gloss'         as gloss,
  w ->> 'part_of_speech'        as woordsoort,
  w ->> 'intro_lesson_key'      as introles,
  w ->> 'needs_example'         as nodig,
  w ->> 'existing_example_count' as bestaand
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.target_words) w
where v.lesson_key = 'a1-dialog-03'
order by (w ->> 'display_order')::int nulls first;


\echo '--- 12. Woordbudget van a1-dialog-03 (verwacht: dezelfde 16 woorden als sectie 8 van verify_language_note_brief_view.sql) ---'
-- Vergelijkbaar omdat alle doelwoorden van les 03 daar ook geintroduceerd
-- worden; het anker valt samen met de les. Wijkt dit af, dan is dat het
-- eerste teken dat een doelwoord elders geintroduceerd is -- zie 9.

select
  b ->> 'source_key'            as sleutel,
  b ->> 'thai_script'           as thai,
  b ->> 'paiboon'               as paiboon,
  b ->> 'availability'          as herkomst,
  b ->> 'in_intro_lesson_set'   as in_lesset,
  b ->> 'intro_sequence_number' as introles
from public.vocabulary_example_brief_view v,
     jsonb_array_elements(v.example_vocabulary_budgets) blk,
     jsonb_array_elements(blk -> 'words') b
where v.lesson_key = 'a1-dialog-03'
order by (b ->> 'intro_sequence_number')::int, b ->> 'source_key';


\echo '--- 13. Kruiscontrole budgetomvang, rechtstreeks geteld per les ---'
-- Vergelijk met budgetwoorden_totaal uit sectie 1, maar ALLEEN voor
-- lessen met doelwoorden. Een les zonder doelwoorden heeft geen anker
-- en dus geen budgetblok; daar staat in sectie 1 terecht null terwijl
-- deze telling gewoon doorloopt.

select
  l.lesson_key,
  (select count(*) from public.lesson_vocabulary lv
    where lv.lesson_id = l.id and lv.role = 'target')     as doelwoorden,
  (select count(*)
     from public.vocabulary_status vs
     join public.lessons il on il.id = vs.first_lesson_id
    where il.sequence_number <= l.sequence_number)        as budgetwoorden_verwacht
from public.lessons l
order by l.sequence_number;


\echo '--- 14. PROGRESSIEREGEL, onafhankelijk: budget getoetst aan lesson_available_vocabulary_view (verwacht: 0 rijen) ---'
-- De sterkste controle op het budget, omdat de referentie een
-- onafhankelijk geschreven view is (20260527160732, aangepast in
-- 20260608100000). Die geeft strikt "eerder geintroduceerd"
-- (sequence_number <), het budget geeft "eerder of in de introductieles
-- zelf" (<=). Het verschil hoort dus precies de woorden te zijn die in
-- de ankerles geintroduceerd worden -- clausule 2 van de
-- progressieregel, de bewuste redactionele keuze uit de gids.
--
-- Twee richtingen, want een ontbrekend woord is even fout als een woord
-- te veel: 'te_veel' = het budget bevat iets wat de leerling nog niet
-- kan kennen; 'ontbreekt' = de schrijver krijgt minder ruimte dan hij
-- volgens de regel heeft.

with budget as (
  select
    v.lesson_key,
    (blk ->> 'intro_lesson_id')::bigint as anker_id,
    (b ->> 'vocabulary_id')::bigint     as vocabulary_id
  from public.vocabulary_example_brief_view v,
       jsonb_array_elements(v.example_vocabulary_budgets) blk,
       jsonb_array_elements(blk -> 'words') b
),
referentie as (
  select
    a.lesson_id as anker_id,
    (w ->> 'vocabulary_id')::bigint as vocabulary_id
  from public.lesson_available_vocabulary_view a,
       jsonb_array_elements(a.previously_introduced_vocabulary) w
  union
  select vs.first_lesson_id, vs.vocabulary_id--clausule 2: de ankerles zelf
  from public.vocabulary_status vs
  where vs.first_lesson_id is not null
)
select 'te_veel' as afwijking, budget.lesson_key, budget.anker_id, vm.source_key
from budget
join public.vocabulary_master vm on vm.id = budget.vocabulary_id
where not exists (
  select 1 from referentie r
  where r.anker_id = budget.anker_id and r.vocabulary_id = budget.vocabulary_id)
union all
select 'ontbreekt', b2.lesson_key, r.anker_id, vm.source_key
from referentie r
join (select distinct lesson_key, anker_id from budget) b2 on b2.anker_id = r.anker_id
join public.vocabulary_master vm on vm.id = r.vocabulary_id
where not exists (
  select 1 from budget
  where budget.anker_id = r.anker_id
    and budget.vocabulary_id = r.vocabulary_id
    and budget.lesson_key = b2.lesson_key);
