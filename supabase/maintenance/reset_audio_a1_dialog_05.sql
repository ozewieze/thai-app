-- ============================================================
-- Audio ongeldig maken na de tekstwijziging van a1-dialog-05
-- ============================================================
-- Aanleiding: blok 1 is gewijzigd van 'อร่อยค่ะ ...' naar
-- 'อร่อยมากค่ะ ...' om มาก in de dialoog te introduceren.
--
-- Waarom dit script nodig is: de on-conflict van
-- seed-data/dialogs/a1_dialog_05.seed.sql werkt thai_text,
-- transliteration en translation_en bij, maar raakt audio_url niet
-- aan -- en anders dan bij vocabulary_examples bestaat er geen
-- trigger die audio_url nult bij een tekstwijziging. Zonder deze
-- stap leest de leerling de nieuwe zin en hoort hij de oude. Beide
-- velden zijn op zichzelf geldig, dus geen enkele datacontrole slaat
-- hierop aan.
--
-- Drie dingen worden ongeldig, niet één:
--   1. dialog_blocks.audio_url van blok 1 (de per-blok opname).
--   2. full_start_ms / full_end_ms van *alle* blokken: blok 1 wordt
--      langer, dus alles daarna schuift op. dialog_blocks is de enige
--      bron van waarheid voor slide-tijdstippen, dus de slideshow
--      loopt anders uit de pas.
--   3. dialogs.audio_url, het samengevoegde bestand.
--
-- Daarna:
--   node scripts/generate-audio.mjs
--     -- pikt blok 1 op, want het script zoekt op audio_url is null
--   node scripts/merge-audio.mjs --dialog a1-dialog-05 --force
--     -- herbouwt het samengevoegde bestand en vult de tijden opnieuw
--
-- Idempotent: een tweede keer draaien zet dezelfde velden opnieuw op
-- null. Verwijdert niets.
-- ============================================================

begin;

update public.dialog_blocks b
set audio_url = null
from public.dialogs d
join public.lessons l on l.id = d.lesson_id
where b.dialog_id = d.id
  and l.lesson_key = 'a1-dialog-05'
  and b.block_index = 1;

update public.dialog_blocks b
set full_start_ms = null,
    full_end_ms   = null
from public.dialogs d
join public.lessons l on l.id = d.lesson_id
where b.dialog_id = d.id
  and l.lesson_key = 'a1-dialog-05';

update public.dialogs d
set audio_url = null
from public.lessons l
where l.id = d.lesson_id
  and l.lesson_key = 'a1-dialog-05';

commit;
