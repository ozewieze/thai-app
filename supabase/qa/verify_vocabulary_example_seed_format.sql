-- ============================================================
-- Verificatie van het seedformaat voor canonieke voorbeelden
-- ============================================================
-- Genereer eerst de fixture-SQL uit de JSON, en draai dan dit script vanuit
-- de projectroot (PowerShell, één regel per commando):
--
--   node scripts/generate-vocabulary-example-seed.mjs --in supabase/qa/fixtures/vocabulary_example_format_fixture.json --out supabase/qa/fixtures/vocabulary_example_format_fixture.seed.sql
--
--   $env:PGCLIENTENCODING = "UTF8"
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -P pager=off -f supabase/qa/verify_vocabulary_example_seed_format.sql
--
-- PGCLIENTENCODING is niet optioneel: dit script zet Thais schrift en
-- Paiboon-toontekens over de verbinding, en op een console met codepage 850
-- of 1252 kan die tekst onderweg beschadigd raken. Dan meet je de console in
-- plaats van de database.
--
-- Waarom genereren en niet een handgeschreven fixture inlezen: de JSON is de
-- bron, de SQL is afleidbaar. Een handgeschreven kopie ernaast zou dezelfde
-- inhoud een tweede keer vastleggen en vroeg of laat uit elkaar lopen --
-- precies de stille drift die dit hele ontwerp probeert te voorkomen.
-- Bijkomend voordeel: elke run test meteen ook de generator.
--
-- Dit script SCHRIJFT, en het schrijft ook in vocabulary_master. Het maakt
-- twee tijdelijke woorden aan ('zz_fixture_word_1' en '..._2') en ruimt die
-- aan het eind weer op; de voorbeelden verdwijnen mee via de cascade. Het
-- raakt uitsluitend rijen waarvan de source_key met 'zz_fixture_' begint.
-- Toch: draai het niet op productie, en lees eerst deze kop -- dat is de
-- afspraak voor alles wat schrijft.
--
-- Waarom eigen fixture-woorden en niet een echt woord uit de masterlijst:
-- vocabulary_examples heeft nog steeds unique (vocabulary_id, display_order).
-- Een fixture die aan een echt woord hangt, botst op het moment dat dat woord
-- zijn eigen canonieke voorbeeld heeft gekregen -- dus precies wanneer het
-- curriculum vordert. Eigen woorden kunnen per definitie niet botsen.
--
-- Let op de opruimconditie: starts_with(source_key, 'zz_fixture_') en niet
-- `like 'zz_fixture_%'`. In LIKE is de underscore een wildcard voor één teken,
-- dus dat patroon zou meer matchen dan het lijkt.
--
-- Wat hier bewezen wordt, en niet alleen beweerd:
--   1. de bestaande deferrable constraint kan géén arbiter zijn (gemeten,
--      niet met EXPLAIN)
--   2. het seedbestand is idempotent (twee keer draaien = één keer draaien)
--   3. Thais schrift en apostroffen overleven de rondgang ongeschonden
--   4. herordenen werkt via display_order zonder rijen te dupliceren, en de
--      sleutels blijven bij hun rij
--   5. een tekstwijziging ruimt de verouderde audio_url op, een ongewijzigde
--      run niet
--   6. een onbekende source_key faalt luid in plaats van stil
-- ============================================================

\set ON_ERROR_STOP on

\echo ''
\echo '=== 0. Schone start ==='

delete from public.vocabulary_master where starts_with(source_key, 'zz_fixture_');

insert into public.vocabulary_master
  (source_key, cefr_level, thai_script, paiboon, english_gloss, part_of_speech, register, source_note)
values
  ('zz_fixture_word_1', 'A1', 'ชา',   'chaa',     'fixture tea',    'noun', 'formal', 'qa_fixture'),
  ('zz_fixture_word_2', 'A1', 'กาแฟ', 'gaa-faae', 'fixture coffee', 'noun', 'formal', 'qa_fixture');

\echo ''
\echo '=== 1. De bestaande constraint kan geen arbiter zijn ==='
\echo '    Dit is de bewering waar de hele sleutelmigratie op rust, dus'
\echo '    wordt hij hier gemeten in plaats van geloofd.'
\echo ''
\echo '    LET OP: met EXPLAIN meet je het tegenovergestelde. Dezelfde'
\echo '    statement met `explain (costs off)` ervoor slaagt gewoon en drukt'
\echo '    zelfs "Conflict Arbiter Indexes: vocabulary_examples_vocab_order_'
\echo '    unique" af. Het is een uitvoeringsfout, geen planfout.'
\echo ''

do $$
begin
  -- 1a. de oude, deferrable constraint: moet weigeren
  begin
    insert into public.vocabulary_examples
      (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
    values (
      (select id from public.vocabulary_master where source_key = 'zz_fixture_word_1'),
      'e1', 1, 'x', 'y', 'z'
    )
    on conflict (vocabulary_id, display_order) do nothing;
    raise notice '1a MISLUKT -- de deferrable constraint werd wél als arbiter geaccepteerd.';
  exception when others then
    -- classificeren, niet alleen waarnemen: een NOT NULL-fout op example_key
    -- zou hier ook als "geweigerd" langskomen en iets heel anders meten.
    if sqlerrm like '%deferrable unique constraints%' then
      raise notice '1a geslaagd, luid geweigerd: %', sqlerrm;
    else
      raise notice '1a geweigerd, maar met een ANDERE fout (dit meet niet wat het lijkt): %', sqlerrm;
    end if;
  end;

  -- 1b. de nieuwe, niet-deferrable constraint: moet slagen
  begin
    insert into public.vocabulary_examples
      (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
    values (
      (select id from public.vocabulary_master where source_key = 'zz_fixture_word_1'),
      'e1', 1, 'x', 'y', 'z'
    )
    on conflict (vocabulary_id, example_key) do nothing;
    raise notice '1b geslaagd: (vocabulary_id, example_key) wordt wél als arbiter geaccepteerd.';
  exception when others then
    raise notice '1b MISLUKT -- de nieuwe sleutel werkt niet als arbiter: %', sqlerrm;
  end;
end $$;

-- de proefrij van 1b weer weg, zodat sectie 2 op een lege tabel telt
delete from public.vocabulary_examples e
using public.vocabulary_master v
where v.id = e.vocabulary_id
  and starts_with(v.source_key, 'zz_fixture_');

\echo ''
\echo '=== 2. Fixture twee keer draaien ==='
\i supabase/qa/fixtures/vocabulary_example_format_fixture.seed.sql
\i supabase/qa/fixtures/vocabulary_example_format_fixture.seed.sql

\echo ''
\echo '    Verwacht: 2 woorden, 2 voorbeelden, elk met display_order 1.'
\echo '    Twee runs mogen niet meer opleveren dan één.'
\echo ''

select
  v.source_key,
  e.example_key,
  e.display_order as volgorde,
  count(*) over () as voorbeelden_totaal
from public.vocabulary_examples e
join public.vocabulary_master v on v.id = e.vocabulary_id
where starts_with(v.source_key, 'zz_fixture_')
order by v.source_key, e.display_order;

\echo ''
\echo '=== 3. Tekencodering en escaping ==='
\echo '    De verwachte waarden komen uit de JSON, uitgerekend met:'
\echo '      node -e "const d=require(''./supabase/qa/fixtures/vocabulary_example_format_fixture.json''),c=require(''crypto'');for(const e of d.examples)console.log(e.source_key,[...e.thai_script].length,[...e.paiboon].length,c.createHash(''md5'').update(e.thai_script+''|''+e.paiboon).digest(''hex''))"'
\echo ''
\echo '    Vergelijken op md5 en niet op het oog: de Windows-console berekent'
\echo '    kolombreedtes verkeerd bij Thais schrift met combinerende toontekens,'
\echo '    en overschrijft dan regels. De data is dan ongeschonden en het scherm'
\echo '    liegt. Deze sectie toont daarom geen enkel Thais teken.'
\echo ''
\echo '    Verwacht: 0 rijen.'
\echo ''

select
  v.source_key,
  e.example_key,
  length(e.thai_script) as thai_len,
  length(e.paiboon)     as pb_len,
  md5(e.thai_script || '|' || e.paiboon) as md5_gemeten
from public.vocabulary_examples e
join public.vocabulary_master v on v.id = e.vocabulary_id
where starts_with(v.source_key, 'zz_fixture_')
  and (v.source_key, md5(e.thai_script || '|' || e.paiboon)) not in (
    ('zz_fixture_word_1', 'd81b753fd8d238e38ff03559d2f20127'),
    ('zz_fixture_word_2', '0099808ea4ab4f792d9a50b76f1a0666')
  )
order by v.source_key;

\echo '    Verwacht: 2 vertalingen met één apostrof, 0 met een dubbele.'
\echo '    Een dubbele apostrof betekent dat de SQL-escaping is opgeslagen'
\echo '    in plaats van toegepast.'
\echo ''

select
  count(*) filter (where e.translation_en like '%''%')   as met_apostrof,
  count(*) filter (where e.translation_en like '%''''%') as met_dubbele_apostrof_fout
from public.vocabulary_examples e
join public.vocabulary_master v on v.id = e.vocabulary_id
where starts_with(v.source_key, 'zz_fixture_');

\echo ''
\echo '=== 4. Herordenen: sleutel blijft bij de rij ==='
\echo '    We geven woord 1 tijdelijk een tweede voorbeeld en wisselen e1 en'
\echo '    e2 van plaats, zoals een auteur dat in het seedbestand zou doen.'
\echo '    Blijven de rij-ids gelijk, dan is de rij verplaatst; veranderen ze,'
\echo '    dan is er een nieuwe rij ingevoegd en staat de oude als wees in de'
\echo '    tabel -- inclusief zijn audio.'
\echo ''
\echo '    Deze sectie is met de hand geschreven en komt niet uit de generator:'
\echo '    die weigert een tweede voorbeeld op hetzelfde woord (vastgelegde'
\echo '    beslissing 2). Dat is meteen het verschil in beeld -- de bovengrens'
\echo '    zit in het script, het schema laat twee rijen toe.'
\echo ''
\echo '    LET OP: dit moet binnen een transactie met `set constraints ...'
\echo '    deferred`. Zonder dat botst de tussenstand op de unique constraint'
\echo '    (vocabulary_id, display_order). Precies daarvoor is die constraint'
\echo '    deferrable aangemaakt.'
\echo ''

insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'zz_fixture_word_1'),
  'e2', 2, 'ชาร้อนค่ะ', 'chaa rɔ́ɔn kâ', 'Hot tea, please.'
);

create temporary table zz_ids_voor as
select e.example_key, e.id, e.display_order
from public.vocabulary_examples e
join public.vocabulary_master v on v.id = e.vocabulary_id
where v.source_key = 'zz_fixture_word_1';

begin;
set constraints public.vocabulary_examples_vocab_order_unique deferred;

insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
select
  (select id from public.vocabulary_master where source_key = 'zz_fixture_word_1'),
  x.example_key, x.display_order, x.thai_script, x.paiboon, x.translation_en
from (values
  ('e2', 1, 'ชาร้อนค่ะ'::text,       'chaa rɔ́ɔn kâ'::text,          'Hot tea, please.'::text),
  ('e1', 2, 'ฉันชอบชาเย็นค่ะ',       'chǎn chɔ̂ɔp chaa yen kâ',      'I''d like iced tea.')
) as x(example_key, display_order, thai_script, paiboon, translation_en)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en;

commit;

\echo '    Verwacht: 2 rijen (e1 en e2), verplaatst, met hetzelfde id.'
\echo ''

select
  v.example_key,
  v.display_order  as volgorde_voor,
  na.display_order as volgorde_na,
  (v.id = na.id)   as zelfde_rij
from zz_ids_voor v
join public.vocabulary_examples na on na.id = v.id
where v.display_order is distinct from na.display_order
order by v.example_key;

\echo '    Verwacht: nog steeds 2 voorbeelden op woord 1, geen wees.'
\echo ''

select count(*) as voorbeelden_op_woord_1
from public.vocabulary_examples e
join public.vocabulary_master v on v.id = e.vocabulary_id
where v.source_key = 'zz_fixture_word_1';

-- terugbrengen naar de toestand van het seedbestand, zodat sectie 5 de fixture
-- opnieuw kan draaien zonder op display_order te botsen
delete from public.vocabulary_examples e
using public.vocabulary_master v
where v.id = e.vocabulary_id
  and v.source_key = 'zz_fixture_word_1'
  and e.example_key = 'e2';

update public.vocabulary_examples e
set display_order = 1
from public.vocabulary_master v
where v.id = e.vocabulary_id
  and v.source_key = 'zz_fixture_word_1';

\echo ''
\echo '=== 5. Verouderde audio_url ==='
\echo '    Een voorbeeld met audio krijgt nieuwe tekst. Blijft de oude'
\echo '    audio_url staan, dan slaat het audioscript het item over ("er is al'
\echo '    audio") en hoort de leerling de vorige zin -- zonder foutmelding.'
\echo '    Dit is de enige plek waar het seedformaat bewust afwijkt van dat'
\echo '    van de Language Notes, dus het wordt hier bewezen.'
\echo ''

update public.vocabulary_examples e
set audio_url = 'https://example.invalid/zz-fixture.mp3',
    voice_key = 'narrator_female'
from public.vocabulary_master v
where v.id = e.vocabulary_id
  and starts_with(v.source_key, 'zz_fixture_');

\echo '    5a. Ongewijzigde run: audio_url MOET blijven staan.'
\echo '        Verwacht: 2x audio_url gevuld.'
\echo ''

\i supabase/qa/fixtures/vocabulary_example_format_fixture.seed.sql

select
  v.source_key,
  (e.audio_url is not null) as audio_bewaard,
  (e.voice_key is not null) as stem_bewaard
from public.vocabulary_examples e
join public.vocabulary_master v on v.id = e.vocabulary_id
where starts_with(v.source_key, 'zz_fixture_')
order by v.source_key;

\echo '    5b. Gewijzigde thai_script: audio_url MOET op null gaan,'
\echo '        voice_key blijft (dat is een redactionele keuze, geen'
\echo '        verwijzing die kan verouderen).'
\echo '        Verwacht: woord 1 zonder audio, woord 2 mét.'
\echo ''

insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'zz_fixture_word_1'),
  'e1', 1, 'ฉันชอบชาร้อนค่ะ', 'chǎn chɔ̂ɔp chaa rɔ́ɔn kâ', 'I''d like hot tea.'
)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.audio_url
                   end;

select
  v.source_key,
  (e.audio_url is not null) as audio_nog_aanwezig,
  (e.voice_key is not null) as stem_nog_aanwezig
from public.vocabulary_examples e
join public.vocabulary_master v on v.id = e.vocabulary_id
where starts_with(v.source_key, 'zz_fixture_')
order by v.source_key;

\echo ''
\echo '=== 6. Luide fouten ==='
\echo '    6a: een onbekende source_key moet op NOT NULL botsen. Dit is de'
\echo '        reden dat het seedformaat de values-vorm gebruikt en niet'
\echo '        `select ... join vocabulary_master`.'
\echo '    6b: dezelfde regel in de join-vorm demonstreert het stille'
\echo '        alternatief -- die voegt zwijgend niets in.'
\echo ''

do $$
declare
  v_voor int;
  v_na   int;
begin
  -- 6a. values-vorm met een woord dat niet bestaat
  begin
    insert into public.vocabulary_examples
      (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
    values (
      (select id from public.vocabulary_master where source_key = 'zz_fixture_bestaat_niet'),
      'e1', 1, 'x', 'y', 'z'
    )
    on conflict (vocabulary_id, example_key) do nothing;
    raise notice '6a MISLUKT -- de insert ging door met een onbekende source_key.';
  exception when not_null_violation then
    raise notice '6a geslaagd, luid geweigerd: %', sqlerrm;
  when others then
    raise notice '6a geweigerd, maar met een andere fout: %', sqlerrm;
  end;

  -- 6b. join-vorm: hetzelfde geval, maar stil
  select count(*) into v_voor
  from public.vocabulary_examples e
  join public.vocabulary_master v on v.id = e.vocabulary_id
  where starts_with(v.source_key, 'zz_fixture_');

  insert into public.vocabulary_examples
    (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
  select v.id, 'e9', 1, 'x', 'y', 'z'
  from public.vocabulary_master v
  where v.source_key = 'zz_fixture_bestaat_niet'
  on conflict (vocabulary_id, example_key) do nothing;

  select count(*) into v_na
  from public.vocabulary_examples e
  join public.vocabulary_master v on v.id = e.vocabulary_id
  where starts_with(v.source_key, 'zz_fixture_');

  if v_voor = v_na then
    raise notice '6b bevestigd: de join-vorm voegde stil 0 rijen in (% -> %). Daarom gebruikt het seedformaat de values-vorm.',
      v_voor, v_na;
  else
    raise notice '6b ONVERWACHT: de join-vorm voegde wel iets in (% -> %).', v_voor, v_na;
  end if;
end $$;

\echo ''
\echo '=== 7. Opruimen ==='
\echo '    Verwacht: 0 fixture-woorden en 0 fixture-voorbeelden. De cascade op'
\echo '    vocabulary_examples_vocabulary_fk ruimt de voorbeelden mee op.'
\echo ''

drop table if exists zz_ids_voor;
delete from public.vocabulary_master where starts_with(source_key, 'zz_fixture_');

select
  (select count(*) from public.vocabulary_master
    where starts_with(source_key, 'zz_fixture_')) as fixture_woorden,
  (select count(*) from public.vocabulary_examples e
     join public.vocabulary_master v on v.id = e.vocabulary_id
    where starts_with(v.source_key, 'zz_fixture_')) as fixture_voorbeelden,
  (select count(*) from public.vocabulary_examples) as voorbeelden_totaal;

\echo ''
\echo '=== Einde ==='
