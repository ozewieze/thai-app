-- ============================================================
-- a1-dialog-03-note-2: twee voorbeelden verwijderen
-- 2026-08-11
--
-- De groep toonde vier voorbeelden in een 2x2-raster: กาแฟร้อน, กาแฟเย็น,
-- ชาร้อน, ชาเย็น. Twee daarvan zijn redundant -- het patroon is na de
-- diagonaal al zichtbaar. Wat overblijft is กาแฟร้อน en ชาเย็น: beide
-- zelfstandige naamwoorden en beide bijvoeglijke naamwoorden komen precies
-- één keer voor.
--
-- DRAAI DIT VÓÓR de herseed, niet erna.
--
-- Waarom: het seedbestand werkt bij zonder te verwijderen. Laat je e2 en
-- e3 staan, dan wil e4 naar display_order 2 terwijl e2 daar nog zit, en
-- botst de seed op language_note_examples_block_order_unique. Gemeten:
--
--   ERROR: duplicate key value violates unique constraint
--          "language_note_examples_block_order_unique"
--
-- Dat is luid falen, en dat is de bedoeling -- maar het betekent wel dat
-- de volgorde van deze twee stappen niet vrij is.
--
-- e4 houdt bewust zijn sleutel. Een sleutel verhuist niet mee met de
-- volgorde; hernummeren naar e2 zou de seed een nieuwe rij laten invoegen
-- in plaats van de bestaande te verplaatsen.
-- ============================================================

delete from public.language_note_examples e
using public.language_note_blocks b, public.language_notes n
where b.id = e.block_id
  and n.id = b.language_note_id
  and n.note_key   = 'a1-dialog-03-note-2'
  and b.block_key  = 'b3'
  and e.example_key in ('e2', 'e3');

-- Verwacht: DELETE 2

-- Daarna:
--   node scripts/generate-language-note-seed.mjs --lesson a1-dialog-03
--   psql ... -f supabase/seed-data/language-notes/a1_dialog_03_notes.seed.sql
--
-- Controle achteraf -- verwacht e1 (กาแฟร้อน) op 1 en e4 (ชาเย็น) op 2:

select e.example_key, e.display_order, e.thai_script, e.translation_en
from public.language_note_examples e
join public.language_note_blocks b on b.id = e.block_id
join public.language_notes n on n.id = b.language_note_id
where n.note_key = 'a1-dialog-03-note-2'
order by e.display_order;
