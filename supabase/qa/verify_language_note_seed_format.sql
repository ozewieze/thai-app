-- ============================================================
-- Verificatie van het Language Note-seedformaat
-- ============================================================
-- Genereer eerst de fixture-SQL uit de twee JSON-bestanden, en draai dan
-- dit script vanuit de projectroot:
--
--   node scripts/generate-language-note-seed.mjs \
--     --in  supabase/qa/fixtures/language_note_format_fixture_a1_dialog_03.json \
--     --out supabase/qa/fixtures/language_note_format_fixture_a1_dialog_03.seed.sql
--
--   node scripts/generate-language-note-seed.mjs \
--     --in  supabase/qa/fixtures/language_note_format_fixture_a1_dialog_01.json \
--     --out supabase/qa/fixtures/language_note_format_fixture_a1_dialog_01.seed.sql
--
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres \
--     -P pager=off -f supabase/qa/verify_language_note_seed_format.sql
--
-- Waarom genereren en niet een handgeschreven fixture inlezen: de JSON is
-- de bron, de SQL is afleidbaar. Een handgeschreven kopie ernaast zou
-- dezelfde inhoud een tweede keer vastleggen en vroeg of laat uit elkaar
-- lopen -- precies de stille drift die dit hele ontwerp probeert te
-- voorkomen. Bijkomend voordeel: elke run test meteen ook de generator.
--
-- Dit script SCHRIJFT: het draait de fixture twee keer, doet er metingen
-- op, en ruimt aan het eind alles op. Het raakt uitsluitend rijen met
-- een note_key die met 'zz-fixture-' begint. Toch: draai het niet op
-- productie, en lees eerst deze kop -- dat is de afspraak voor alles wat
-- schrijft.
--
-- Wat hier bewezen wordt, en niet alleen beweerd:
--   1. het bestand is idempotent (twee keer draaien = één keer draaien)
--   2. Thais schrift en apostroffen overleven de rondgang ongeschonden
--   3. herordenen werkt via display_order zonder rijen te dupliceren,
--      en de sleutels blijven bij hun rij
--   4. een ontbrekend concept faalt luid in plaats van stil
--   5. een claim op een koppelrij van een ándere les wordt geblokkeerd
-- ============================================================

\set ON_ERROR_STOP on

\echo ''
\echo '=== 0. Schone start ==='
delete from public.language_notes where note_key like 'zz-fixture-%';

\echo ''
\echo '=== 1. Fixture twee keer draaien ==='
\i supabase/qa/fixtures/language_note_format_fixture_a1_dialog_03.seed.sql
\i supabase/qa/fixtures/language_note_format_fixture_a1_dialog_01.seed.sql
\i supabase/qa/fixtures/language_note_format_fixture_a1_dialog_03.seed.sql
\i supabase/qa/fixtures/language_note_format_fixture_a1_dialog_01.seed.sql

\echo ''
\echo '    Verwacht: notes 3, blocks 8, examples 4, concepts 5.'
\echo '    Twee runs mogen niet meer opleveren dan één.'
\echo ''

select 'notes' as wat, count(*) from public.language_notes
  where note_key like 'zz-fixture-%'
union all
select 'blocks', count(*)
  from public.language_note_blocks b
  join public.language_notes n on n.id = b.language_note_id
  where n.note_key like 'zz-fixture-%'
union all
select 'examples', count(*)
  from public.language_note_examples e
  join public.language_note_blocks b on b.id = e.block_id
  join public.language_notes n on n.id = b.language_note_id
  where n.note_key like 'zz-fixture-%'
union all
select 'concepts', count(*)
  from public.language_note_concepts c
  join public.language_notes n on n.id = c.language_note_id
  where n.note_key like 'zz-fixture-%'
order by 1;

\echo ''
\echo '=== 2. Alle vijf de bloktypes en beide example_group-vormen ==='
\echo '    Verwacht: paragraph, subheading, formula, usage_tip met'
\echo '    content en zonder heading; example_group een keer mét kop en'
\echo '    intro en een keer zonder beide.'
\echo ''

select
  n.note_key,
  b.block_key,
  b.display_order as volgorde,
  b.block_type,
  coalesce(b.heading, '(geen)') as kop,
  case when b.content is null then '(geen)' else left(b.content, 40) end as inhoud
from public.language_note_blocks b
join public.language_notes n on n.id = b.language_note_id
where n.note_key like 'zz-fixture-%'
order by n.note_key, b.display_order;

\echo ''
\echo '=== 3. Tekencodering en escaping ==='
\echo '    Verwacht: Thais schrift met toontekens intact, en drie'
\echo '    apostroffen die als één apostrof zijn opgeslagen.'
\echo ''

select
  e.example_key,
  e.thai_script,
  e.paiboon,
  e.translation_en
from public.language_note_examples e
join public.language_note_blocks b on b.id = e.block_id
join public.language_notes n on n.id = b.language_note_id
where n.note_key like 'zz-fixture-%'
order by n.note_key, b.display_order, e.display_order;

select
  count(*) filter (where content like '%''%')   as blokken_met_apostrof,
  count(*) filter (where content like '%''''%') as blokken_met_dubbele_apostrof_fout
from public.language_note_blocks b
join public.language_notes n on n.id = b.language_note_id
where n.note_key like 'zz-fixture-%';

\echo ''
\echo '=== 4. Herordenen: sleutel blijft bij de rij ==='
\echo '    We wisselen b1 en b3 van plaats, zoals een auteur dat in het'
\echo '    seedbestand zou doen, en kijken of de rij-ids ongemoeid'
\echo '    blijven. Zo niet, dan is er een nieuwe rij ingevoegd en staat'
\echo '    de oude als wees in de tabel.'
\echo ''
\echo '    LET OP: dit moet binnen een transactie met'
\echo '    `set constraints ... deferred`. Zonder dat botst de'
\echo '    tussenstand op de unique constraint. Precies daarvoor is die'
\echo '    constraint deferrable aangemaakt.'
\echo ''

create temporary table zz_ids_voor as
select b.block_key, b.id, b.display_order
from public.language_note_blocks b
join public.language_notes n on n.id = b.language_note_id
where n.note_key = 'zz-fixture-note-1';

begin;
set constraints public.language_note_blocks_note_order_unique deferred;

with note as (
  select id from public.language_notes where note_key = 'zz-fixture-note-1'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b3', 1, 'formula',    null::text, '[noun] + [adjective] = descriptive phrase'::text),
  ('b1', 3, 'paragraph',  null,       'In the dialogue, Narin asks what Mali will drink. Here''s the pattern behind her answer.')
) as b(block_key, display_order, block_type, heading, content)
on conflict (language_note_id, block_key) do update set
  display_order = excluded.display_order,
  block_type    = excluded.block_type,
  heading       = excluded.heading,
  content       = excluded.content;

commit;

\echo '    Verwacht: 2 rijen (b1 en b3), verplaatst, met hetzelfde id.'
\echo ''

select
  v.block_key,
  v.display_order as volgorde_voor,
  na.display_order as volgorde_na,
  (v.id = na.id)   as zelfde_rij
from zz_ids_voor v
join public.language_note_blocks na on na.id = v.id
where v.display_order is distinct from na.display_order
order by v.block_key;

\echo '    Verwacht: nog steeds 6 blokken in note-1, geen wees.'
\echo ''

select count(*) as blokken_in_note_1
from public.language_note_blocks b
join public.language_notes n on n.id = b.language_note_id
where n.note_key = 'zz-fixture-note-1';

\echo ''
\echo '=== 5. Luide fouten ==='
\echo '    5a: een concept dat niet aan de les gekoppeld is, moet de'
\echo '        exactly-one-check schenden in plaats van nul rijen in te'
\echo '        voegen. Dit is de reden dat de conceptclaims de'
\echo '        values-vorm gebruiken en niet `select ... from ... where`.'
\echo '    5b: dezelfde claim in de select-vorm demonstreert het stille'
\echo '        alternatief -- die voegt zwijgend niets in.'
\echo '    5c: een koppelrij van een ándere les moet door de'
\echo '        samengestelde FK geweigerd worden.'
\echo ''

do $$
declare
  v_aantal_voor int;
  v_aantal_na   int;
begin
  -- 5a. values-vorm met een woord dat niet aan les 3 gekoppeld is
  begin
    insert into public.language_note_concepts
      (language_note_id, lesson_id, lesson_vocabulary_id)
    values (
      (select id from public.language_notes where note_key = 'zz-fixture-note-1'),
      (select id from public.lessons where lesson_key = 'a1-dialog-03'),
      (select lv.id
         from public.lesson_vocabulary lv
        where lv.lesson_id     = (select id from public.lessons where lesson_key = 'a1-dialog-03')
          and lv.vocabulary_id = (select id from public.vocabulary_master where source_key = 'hello'))
    )
    on conflict (lesson_vocabulary_id, language_note_id)
      where lesson_vocabulary_id is not null
    do nothing;
    raise notice '5a MISLUKT -- de insert ging door terwijl het concept niet aan de les hangt.';
  exception when check_violation then
    raise notice '5a geslaagd, luid geweigerd: %', sqlerrm;
  when others then
    raise notice '5a geweigerd, maar met een andere fout: %', sqlerrm;
  end;

  -- 5b. select-vorm: hetzelfde geval, maar stil
  select count(*) into v_aantal_voor
  from public.language_note_concepts c
  join public.language_notes n on n.id = c.language_note_id
  where n.note_key like 'zz-fixture-%';

  insert into public.language_note_concepts
    (language_note_id, lesson_id, lesson_vocabulary_id)
  select n.id, lv.lesson_id, lv.id
  from public.language_notes n
  cross join public.lesson_vocabulary lv
  where n.note_key = 'zz-fixture-note-1'
    and lv.lesson_id     = (select id from public.lessons where lesson_key = 'a1-dialog-03')
    and lv.vocabulary_id = (select id from public.vocabulary_master where source_key = 'hello')
  on conflict (lesson_vocabulary_id, language_note_id)
    where lesson_vocabulary_id is not null
  do nothing;

  select count(*) into v_aantal_na
  from public.language_note_concepts c
  join public.language_notes n on n.id = c.language_note_id
  where n.note_key like 'zz-fixture-%';

  if v_aantal_voor = v_aantal_na then
    raise notice '5b bevestigd: de select-vorm voegde stil 0 rijen in (% -> %). Daarom gebruikt het seedformaat de values-vorm.',
      v_aantal_voor, v_aantal_na;
  else
    raise notice '5b ONVERWACHT: de select-vorm voegde wel iets in (% -> %).', v_aantal_voor, v_aantal_na;
  end if;

  -- 5c. koppelrij van een andere les
  begin
    insert into public.language_note_concepts
      (language_note_id, lesson_id, lesson_vocabulary_id)
    values (
      (select id from public.language_notes where note_key = 'zz-fixture-note-1'),
      (select id from public.lessons where lesson_key = 'a1-dialog-03'),
      (select lv.id
         from public.lesson_vocabulary lv
        where lv.lesson_id     = (select id from public.lessons where lesson_key = 'a1-dialog-01')
          and lv.vocabulary_id = (select id from public.vocabulary_master where source_key = 'hello'))
    )
    on conflict (lesson_vocabulary_id, language_note_id)
      where lesson_vocabulary_id is not null
    do nothing;
    raise notice '5c MISLUKT -- een koppelrij van les 1 werd door een note van les 3 geclaimd.';
  exception when foreign_key_violation then
    raise notice '5c geslaagd, luid geweigerd door de samengestelde FK.';
  when others then
    raise notice '5c geweigerd, maar met een andere fout: %', sqlerrm;
  end;
end $$;

\echo ''
\echo '=== 6. Claims tegen language_note_brief_view ==='
\echo '    De seed zoekt de koppelrij op via de sleutels; de view geeft'
\echo '    diezelfde koppelrij-id rechtstreeks. Als die twee uiteenlopen,'
\echo '    is er iets mis met de les of met de subquery.'
\echo ''
\echo '    Verwacht: 0 rijen -- elke claim van de fixture is terug te'
\echo '    vinden in de view.'
\echo ''
\echo '    Kanttekening: dit is een geldige controle omdat élk concept dat'
\echo '    de fixture claimt requires_explanation = true heeft. In het'
\echo '    algemeen mag een note ook een niet-gevlagd concept behandelen;'
\echo '    zo een claim staat terecht niet in de view en zou hier ten'
\echo '    onrechte als fout verschijnen.'
\echo ''

select
  n.note_key,
  'vocabulary'           as arm,
  c.lesson_vocabulary_id as koppelrij_uit_de_seed
from public.language_note_concepts c
join public.language_notes n on n.id = c.language_note_id
where n.note_key like 'zz-fixture-%'
  and c.lesson_vocabulary_id is not null
  and not exists (
    select 1
    from public.language_note_brief_view v,
         jsonb_array_elements(v.vocabulary_to_explain) w
    where v.lesson_id = c.lesson_id
      and (w ->> 'lesson_vocabulary_id')::bigint = c.lesson_vocabulary_id)

union all

select n.note_key, 'grammar', c.lesson_grammar_id
from public.language_note_concepts c
join public.language_notes n on n.id = c.language_note_id
where n.note_key like 'zz-fixture-%'
  and c.lesson_grammar_id is not null
  and not exists (
    select 1
    from public.language_note_brief_view v,
         jsonb_array_elements(v.grammar_to_explain) w
    where v.lesson_id = c.lesson_id
      and (w ->> 'lesson_grammar_id')::bigint = c.lesson_grammar_id)

union all

select n.note_key, 'phrase', c.lesson_phrase_id
from public.language_note_concepts c
join public.language_notes n on n.id = c.language_note_id
where n.note_key like 'zz-fixture-%'
  and c.lesson_phrase_id is not null
  and not exists (
    select 1
    from public.language_note_brief_view v,
         jsonb_array_elements(v.phrases_to_explain) w
    where v.lesson_id = c.lesson_id
      and (w ->> 'lesson_phrase_id')::bigint = c.lesson_phrase_id)

union all

select n.note_key, 'pattern', c.lesson_pattern_id
from public.language_note_concepts c
join public.language_notes n on n.id = c.language_note_id
where n.note_key like 'zz-fixture-%'
  and c.lesson_pattern_id is not null
  and not exists (
    select 1
    from public.language_note_brief_view v,
         jsonb_array_elements(v.patterns_to_explain) w
    where v.lesson_id = c.lesson_id
      and (w ->> 'lesson_pattern_id')::bigint = c.lesson_pattern_id)

order by 1, 2;

\echo '    Tegenproef: dezelfde query moet de vier armen wél vinden.'
\echo '    Verwacht: vocabulary 2, grammar 1, phrase 1, pattern 1.'
\echo ''

select
  case
    when c.lesson_vocabulary_id is not null then 'vocabulary'
    when c.lesson_grammar_id    is not null then 'grammar'
    when c.lesson_phrase_id     is not null then 'phrase'
    else 'pattern'
  end as arm,
  count(*) as claims
from public.language_note_concepts c
join public.language_notes n on n.id = c.language_note_id
where n.note_key like 'zz-fixture-%'
group by 1
order by 1;

\echo ''
\echo '=== 7. Opruimen ==='
\echo '    Verwacht: 0 op alle vier de tabellen -- de cascades ruimen'
\echo '    blokken, voorbeelden en claims mee op.'
\echo ''

drop table if exists zz_ids_voor;
delete from public.language_notes where note_key like 'zz-fixture-%';

select 'language_notes' as tabel, count(*) from public.language_notes
union all
select 'language_note_blocks',   count(*) from public.language_note_blocks
union all
select 'language_note_examples', count(*) from public.language_note_examples
union all
select 'language_note_concepts', count(*) from public.language_note_concepts
order by 1;

\echo ''
\echo '=== Einde ==='
