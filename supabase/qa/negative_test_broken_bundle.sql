-- ============================================================
-- Negatieve test: gebroken partikel/voornaamwoord-bundel
--
-- Doel. Bewijzen dat de audioscripts een zin met ฉัน aan het begin
-- en ครับ aan het einde hard weigeren, en dat ze dat doen vóórdat
-- er ook maar één TTS-aanroep gedaan is.
--
-- Waarom dit bestand bestaat en niet één keer met de hand gedaan
-- is. De stemafleiding in scripts/voice-config.mjs is drie keer
-- herzien voordat hij deugde, telkens omdat een categorie gevallen
-- niet was opgesomd. De zelftest in dat bestand dekt de regel; dit
-- bestand dekt de kéten eromheen -- dat een fout in de database
-- ook echt tot een exitcode leidt en niet ergens onderweg tot een
-- waarschuwing verwatert. Draai het opnieuw zodra iemand aan die
-- afleiding komt.
--
-- Waarom het schrift hier in een bestand staat en niet in een
-- -c-parameter: Thais schrift op een Windows-console overleeft de
-- reis naar de server niet betrouwbaar. Een bestand met
-- PGCLIENTENCODING=UTF8 wel -- zelfde route als de seedbestanden.
--
-- ------------------------------------------------------------
-- GEBRUIK
--
--   chcp 65001
--   $env:PGCLIENTENCODING = "UTF8"
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -v ON_ERROR_STOP=1 -P pager=off -f supabase/qa/negative_test_broken_bundle.sql
--
-- Daarna:
--
--   npm run audio:note-examples -- --dry-run
--
-- Verwacht: exitcode 1, een FOUT-blok met
-- [a1-dialog-01-note-1/b3/e1], en géén regel "te verwerken".
--
-- HERSTELLEN -- draai het seedbestand van les 01 opnieuw:
--
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -v ON_ERROR_STOP=1 -P pager=off -f supabase/seed-data/language-notes/a1_dialog_01_notes.seed.sql
--
-- Doe deze test vóór je de echte audiorun draait. De upsert die de
-- tekst herstelt, zet audio_url en voice_key van die rij namelijk
-- op null zodra thai_script wijzigt -- precies zoals bedoeld, maar
-- dan mag je die ene opname opnieuw laten maken.
-- ============================================================

begin;

-- ฉันชื่อฝนค่ะ ("My name is Fon", vrouwelijk) wordt
-- ฉันชื่อนัทครับ: hetzelfde zinspatroon, maar met het mannelijke
-- slotpartikel achter het vrouwelijke voornaamwoord. Correct Thai
-- bestaat niet in deze vorm; het is een redactionele fout die
-- vandaag alleen door de schrijverprompt tegengehouden wordt.
update public.language_note_examples e
set thai_script = 'ฉันชื่อนัทครับ'
from public.language_note_blocks b
join public.language_notes n on n.id = b.language_note_id
where e.block_id = b.id
  and n.note_key = 'a1-dialog-01-note-1'
  and b.block_key = 'b3'
  and e.example_key = 'e1';

-- Faalt luid als de doelrij niet bestaat: zonder deze controle zou
-- een hernoemde sleutel een test opleveren die nul rijen wijzigt en
-- daarna vrolijk 'geslaagd' meldt omdat er niets te vinden was.
do $$
declare
  gevonden integer;
begin
  select count(*) into gevonden
  from public.language_note_examples e
  join public.language_note_blocks b on b.id = e.block_id
  join public.language_notes n on n.id = b.language_note_id
  where n.note_key = 'a1-dialog-01-note-1'
    and b.block_key = 'b3'
    and e.example_key = 'e1';

  if gevonden <> 1 then
    raise exception
      'Doelrij a1-dialog-01-note-1/b3/e1 niet gevonden (% rijen). Is les 01 geseed?',
      gevonden;
  end if;
end $$;

commit;

\echo ''
\echo 'Bundel gebroken in a1-dialog-01-note-1/b3/e1.'
\echo 'Draai nu:  npm run audio:note-examples -- --dry-run   (verwacht exitcode 1)'
\echo 'Herstel:   psql ... -f supabase/seed-data/language-notes/a1_dialog_01_notes.seed.sql'
\echo ''
