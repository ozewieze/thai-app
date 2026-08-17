-- =============================================================
-- verify_remote_storage.sql
--
-- Controle na stap 3 van de livegang: audio gegenereerd en
-- slides geupload tegen de REMOTE omgeving.
--
-- Draai dit in de SQL-editor van Supabase Studio, of met:
--   psql "<connection-string>" -f supabase/qa/verify_remote_storage.sql
--
-- Waarom dit meer is dan "de kolommen zijn niet meer leeg":
-- audio_url en image_url bevatten een ABSOLUTE URL inclusief de
-- Supabase-host (zie scripts/upload-slides.mjs r. 242). Een rij
-- die gevuld is met een 127.0.0.1-URL ziet er in Studio net zo
-- gevuld uit als een goede, maar is stil op elk ander apparaat
-- dan dat van de ontwikkelaar. Sectie 2 is dus de belangrijkste.
-- =============================================================

-- =============================================================
-- 1. Volledigheid: is alles gevuld wat gevuld moet zijn?
-- =============================================================

select
  'dialog_blocks.audio_url' as kolom,
  count(*) filter (where audio_url is not null) as gevuld,
  count(*) as totaal,
  32 as verwacht,
  case when count(*) filter (where audio_url is not null) = 32 then 'OK' else 'FOUT' end as status
from public.dialog_blocks

union all
select
  'dialogs.audio_url',
  count(*) filter (where audio_url is not null),
  count(*),
  5,
  case when count(*) filter (where audio_url is not null) = 5 then 'OK' else 'FOUT' end
from public.dialogs

-- Zonder audio_duration_ms kan DialogFullSection de slide-timings
-- niet afleiden: de slideshow blijft dan op slide 0 staan terwijl
-- de audio doorloopt.
union all
select
  'dialogs.audio_duration_ms',
  count(*) filter (where audio_duration_ms is not null),
  count(*),
  5,
  case when count(*) filter (where audio_duration_ms is not null) = 5 then 'OK' else 'FOUT' end
from public.dialogs

-- De blok-timestamps die merge-audio.mjs terugschrijft. Dit is de
-- enige tijdbron voor de slidewissels; ontbreken ze, dan speelt de
-- audio wel maar wisselt het beeld niet.
union all
select
  'dialog_blocks.full_start_ms',
  count(*) filter (where full_start_ms is not null),
  count(*),
  32,
  case when count(*) filter (where full_start_ms is not null) = 32 then 'OK' else 'FOUT' end
from public.dialog_blocks

union all
select
  'dialog_blocks.full_end_ms',
  count(*) filter (where full_end_ms is not null),
  count(*),
  32,
  case when count(*) filter (where full_end_ms is not null) = 32 then 'OK' else 'FOUT' end
from public.dialog_blocks

-- Slides: dit is de stap die je makkelijk vergeet, want
-- upload-slides.mjs staat los van de audioscripts.
union all
select
  'dialog_slides.image_url',
  count(*) filter (where image_url is not null),
  count(*),
  15,
  case when count(*) filter (where image_url is not null) = 15 then 'OK' else 'FOUT' end
from public.dialog_slides

union all
select
  'vocabulary_master.audio_url (gekoppeld)',
  count(*) filter (where m.audio_url is not null),
  count(*),
  30,
  case when count(*) filter (where m.audio_url is not null) = 30 then 'OK' else 'FOUT' end
from public.vocabulary_master m
where exists (select 1 from public.lesson_vocabulary lv where lv.vocabulary_id = m.id)

union all
select
  'vocabulary_examples.audio_url',
  count(*) filter (where audio_url is not null),
  count(*),
  30,
  case when count(*) filter (where audio_url is not null) = 30 then 'OK' else 'FOUT' end
from public.vocabulary_examples

union all
select
  'language_note_examples.audio_url',
  count(*) filter (where audio_url is not null),
  count(*),
  35,
  case when count(*) filter (where audio_url is not null) = 35 then 'OK' else 'FOUT' end
from public.language_note_examples

order by kolom;


-- =============================================================
-- 2. Herkomst: wijst elke URL naar de REMOTE host?
--
-- Dit is de controle die "gevuld" onderscheidt van "goed". Eén
-- rij met een 127.0.0.1-URL is genoeg om een demo stil te maken,
-- en je ziet het nergens anders aan.
--
-- 'verkeerd' moet overal 0 zijn.
-- =============================================================

with alle_urls as (
  select 'dialog_blocks'          as bron, audio_url as url from public.dialog_blocks          where audio_url is not null
  union all
  select 'dialogs',                         audio_url        from public.dialogs                where audio_url is not null
  union all
  select 'dialog_slides',                   image_url        from public.dialog_slides          where image_url is not null
  union all
  select 'vocabulary_master',               audio_url        from public.vocabulary_master      where audio_url is not null
  union all
  select 'vocabulary_examples',             audio_url        from public.vocabulary_examples    where audio_url is not null
  union all
  select 'language_note_examples',          audio_url        from public.language_note_examples where audio_url is not null
)
select
  bron,
  count(*) as urls,
  count(*) filter (where url like 'https://%.supabase.co/storage/v1/object/public/%') as remote,
  count(*) filter (where url not like 'https://%.supabase.co/storage/v1/object/public/%') as verkeerd,
  case
    when count(*) filter (where url not like 'https://%.supabase.co/storage/v1/object/public/%') = 0
    then 'OK' else 'FOUT'
  end as status
from alle_urls
group by bron
order by bron;


-- Staan er verkeerde bij, dan toont dit welke. Lege uitkomst = goed.
with alle_urls as (
  select 'dialog_blocks'          as bron, audio_url as url from public.dialog_blocks          where audio_url is not null
  union all
  select 'dialogs',                         audio_url        from public.dialogs                where audio_url is not null
  union all
  select 'dialog_slides',                   image_url        from public.dialog_slides          where image_url is not null
  union all
  select 'vocabulary_master',               audio_url        from public.vocabulary_master      where audio_url is not null
  union all
  select 'vocabulary_examples',             audio_url        from public.vocabulary_examples    where audio_url is not null
  union all
  select 'language_note_examples',          audio_url        from public.language_note_examples where audio_url is not null
)
select bron, url
from alle_urls
where url not like 'https://%.supabase.co/storage/v1/object/public/%'
order by bron, url;


-- =============================================================
-- 3. Voice_key: samen gevuld of samen leeg.
--
-- De seeds zetten audio_url en voice_key allebei op null bij een
-- gewijzigde thai_script. Een rij met audio maar zonder voice_key
-- (of andersom) betekent dat een script halverwege is gestopt.
-- =============================================================

select
  'vocabulary_master' as tabel,
  count(*) filter (where audio_url is not null and voice_key is null) as audio_zonder_stem,
  count(*) filter (where audio_url is null and voice_key is not null) as stem_zonder_audio
from public.vocabulary_master

union all
select
  'vocabulary_examples',
  count(*) filter (where audio_url is not null and voice_key is null),
  count(*) filter (where audio_url is null and voice_key is not null)
from public.vocabulary_examples

union all
select
  'language_note_examples',
  count(*) filter (where audio_url is not null and voice_key is null),
  count(*) filter (where audio_url is null and voice_key is not null)
from public.language_note_examples

order by tabel;
