-- ============================================================
-- Normaliseer de stijl van vocabulary_master.usage_note
-- ============================================================
-- Regel: hoofdletter aan het begin, leesteken aan het eind.
--
-- Waarom deze conventie en niet de huidige kleine letters:
-- usage_note wordt in VocabularyCard.tsx gerenderd als een eigen
-- alinea met een icoon -- het is dus zelfstandige lopende tekst voor
-- de leerling, geen label dat achter de vertaling geplakt wordt. Een
-- fragment zonder hoofdletter leest in een eigen alinea als een
-- afgebroken zin.
--
-- Doorslaggevend argument: usage_note is het enige veld in de hele
-- dataset dat de conventie niet volgt. Alle 85 short_explanation-
-- waarden in grammar_master, alle 76 in pattern_master en beide in
-- phrase_master beginnen al met een hoofdletter en eindigen op een
-- punt -- 163 van de 163. Dit script haalt de laatste 149 rijen bij.
--
-- Zuiver mechanisch: alleen hoofdletter en eindpunt. Geen enkele
-- formulering verandert. Inhoudelijke correcties per dialoog zijn een
-- aparte, latere ronde -- juist daarom moet deze in één keer gebeuren:
-- de diff blijft dan triviaal te reviewen en jouw latere inhoudelijke
-- wijzigingen verdrinken niet in 149 regels ruis.
--
-- Idempotent: rijen die al aan de conventie voldoen worden door de
-- where-clausule overgeslagen, en de transformatie van een al
-- genormaliseerde waarde levert diezelfde waarde op. Geverifieerd
-- tegen alle 149 huidige waarden.
--
-- Herbruikbaar: draai dit opnieuw na elke ronde nieuwe masterwoorden
-- (de DB-first authoring-flow uit de dialoogworkflowgids). Het raakt
-- dan alleen de rijen die nog niet voldoen.
--
-- VOLGORDE -- dit script gaat als eerste, niet als laatste:
--   1. dit script          (database)
--   2. npm run export:vocab of node scripts/export-vocabulary-master.mjs
--                          (database -> csv)
--   3. npm run seed:vocab  (csv -> vocabulary_master.seed.sql)
--   4. git diff op csv en seed nakijken, dan committen
--
-- De database gaat voorop omdat daar wijzigingen staan die nergens
-- anders bestaan (de aangescherpte usage_notes van ร้อน en เย็น zijn
-- rechtstreeks in de database gezet). Zou je eerst de CSV aanpassen,
-- dan overschrijft de export in stap 2 die aanpassing stilzwijgend
-- met de oude waarden uit de database.
--
-- Draaien met:
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres \
--     -P pager=off -f supabase/maintenance/normalize_usage_note_style.sql
-- ============================================================

\echo '--- Voor: rijen die nog niet aan de conventie voldoen (verwacht bij de eerste run: 149) ---'

select count(*) as te_normaliseren
from public.vocabulary_master
where usage_note is not null
  and btrim(usage_note) <> ''
  and (
    substring(btrim(usage_note) from 1 for 1)
      <> upper(substring(btrim(usage_note) from 1 for 1))
    or right(btrim(usage_note), 1) not in ('.', '!', '?')
  );


begin;

update public.vocabulary_master
set usage_note =
      upper(substring(btrim(usage_note) from 1 for 1))
      || substring(btrim(usage_note) from 2)
      || case
           when right(btrim(usage_note), 1) in ('.', '!', '?') then ''
           else '.'
         end,
    updated_at = now()
where usage_note is not null
  and btrim(usage_note) <> ''
  and (
    -- begint niet met een hoofdletter. Let op: upper() laat Thais
    -- schrift ongemoeid, dus een usage_note die met Thai begint wordt
    -- hier terecht niet als "fout" gezien.
    substring(btrim(usage_note) from 1 for 1)
      <> upper(substring(btrim(usage_note) from 1 for 1))
    -- of eindigt niet op een leesteken
    or right(btrim(usage_note), 1) not in ('.', '!', '?')
  );

commit;


\echo '--- Na: rijen die nog niet voldoen (verwacht: 0) ---'

select count(*) as resterend
from public.vocabulary_master
where usage_note is not null
  and btrim(usage_note) <> ''
  and (
    substring(btrim(usage_note) from 1 for 1)
      <> upper(substring(btrim(usage_note) from 1 for 1))
    or right(btrim(usage_note), 1) not in ('.', '!', '?')
  );


\echo '--- Steekproef (verwacht: hoofdletter voorop, punt achteraan, formulering onveranderd) ---'

select source_key, thai_script, usage_note
from public.vocabulary_master
where source_key in ('yes', 'no', 'i', 'excuse_me', 'hot', 'cool')
order by source_key;
