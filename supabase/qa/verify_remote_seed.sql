-- =============================================================
-- verify-remote-seed.sql
--
-- Controleert na het seeden van de remote database of alles
-- erin staat wat erin hoort, met de aantallen die uit de
-- seedbestanden zijn geteld (stand 2026-08-17).
--
-- Draai dit in de SQL-editor van Supabase Studio, of met:
--   psql "<connection-string>" -f verify-remote-seed.sql
--
-- Elke rij geeft 'OK' of 'FOUT'. Eén FOUT is genoeg om te
-- stoppen en te kijken -- niet doorgaan naar stap 3.
-- =============================================================

-- 12 lessen, niet 5: 5 dialogen + 1 revisie + 5 premium-placeholders
-- + 1 premium-revisie. Alle twaalf staan in core.seed.sql op
-- is_published = true, dus een anonieme bezoeker ziet ze alle twaalf.
select
  'lessons' as wat,
  count(*) as gevonden,
  12 as verwacht,
  case when count(*) = 12 then 'OK' else 'FOUT' end as status
from public.lessons

union all
select
  'lessons gepubliceerd',
  count(*),
  12,
  case when count(*) = 12 then 'OK' else 'FOUT' end
from public.lessons where is_published

-- De vijf lessen met echte inhoud. Dit is het getal dat telt voor
-- de demo; het getal hierboven telt de placeholders mee.
union all
select
  'lessons met een dialoog',
  count(*),
  5,
  case when count(*) = 5 then 'OK' else 'FOUT' end
from public.lessons l
where exists (select 1 from public.dialogs d where d.lesson_id = l.id)

union all
select
  'vocabulary_master',
  count(*),
  514,
  case when count(*) = 514 then 'OK' else 'FOUT' end
from public.vocabulary_master

union all
select
  'lesson_vocabulary',
  count(*),
  30,
  case when count(*) = 30 then 'OK' else 'FOUT' end
from public.lesson_vocabulary

union all
select
  'vocabulary_examples',
  count(*),
  30,
  case when count(*) = 30 then 'OK' else 'FOUT' end
from public.vocabulary_examples

union all
select
  'dialogs',
  count(*),
  5,
  case when count(*) = 5 then 'OK' else 'FOUT' end
from public.dialogs

union all
select
  'dialog_blocks',
  count(*),
  32,
  case when count(*) = 32 then 'OK' else 'FOUT' end
from public.dialog_blocks

union all
select
  'dialog_slides',
  count(*),
  15,
  case when count(*) = 15 then 'OK' else 'FOUT' end
from public.dialog_slides

-- 14 notes, niet 5: les 01 heeft er 2, les 02 vier, les 03 twee,
-- les 04 drie, les 05 drie. Eén notitie per concept, niet per les.
union all
select
  'language_notes',
  count(*),
  14,
  case when count(*) = 14 then 'OK' else 'FOUT' end
from public.language_notes

union all
select
  'language_note_examples',
  count(*),
  35,
  case when count(*) = 35 then 'OK' else 'FOUT' end
from public.language_note_examples

order by wat;


-- =============================================================
-- Encodingcontrole: staat het Thaise schrift er echt in?
--
-- Dit is de test die je niet mag overslaan. Bij een verkeerde
-- clientencoding komt er geen foutmelding -- er komen alleen
-- vraagtekens in je database, en dat zie je pas als de jury
-- naar het scherm kijkt.
--
-- 'lengte_tekens' hoort duidelijk kleiner te zijn dan
-- 'lengte_bytes' (Thais is 3 bytes per teken in UTF-8). Zijn ze
-- gelijk, dan is het schrift verminkt.
-- =============================================================

select
  thai_script,
  length(thai_script)          as lengte_tekens,
  octet_length(thai_script)    as lengte_bytes,
  case
    when thai_script like '%?%'                       then 'FOUT: vraagtekens'
    when octet_length(thai_script) = length(thai_script) then 'FOUT: geen multibyte'
    else 'OK'
  end as status
from public.vocabulary_master
where source_key in ('hello', 'you')
order by source_key;


-- =============================================================
-- Audio- en beeldkolommen: horen NU allemaal leeg te zijn.
--
-- Na het seeden en vóór stap 3 moet alles null zijn. Staat hier
-- iets gevuld, dan is er data uit een andere omgeving
-- binnengekomen -- controleer of de URL naar 127.0.0.1 wijst.
-- =============================================================

select 'dialog_blocks.audio_url'          as kolom, count(*) filter (where audio_url is not null) as gevuld from public.dialog_blocks
union all
select 'dialogs.audio_url',                       count(*) filter (where audio_url is not null) from public.dialogs
union all
select 'dialog_slides.image_url',                 count(*) filter (where image_url is not null) from public.dialog_slides
union all
select 'vocabulary_master.audio_url',             count(*) filter (where audio_url is not null) from public.vocabulary_master
union all
select 'vocabulary_examples.audio_url',           count(*) filter (where audio_url is not null) from public.vocabulary_examples
union all
select 'language_note_examples.audio_url',        count(*) filter (where audio_url is not null) from public.language_note_examples
order by kolom;
