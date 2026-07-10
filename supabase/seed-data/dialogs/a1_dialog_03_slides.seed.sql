begin;

-- =========================================================
-- a1_dialog_03 — dialog_slides
--
-- Hoort bij de illustratieworkflow, niet bij de basis-
-- dialoogworkflow: deze segmentatie wordt pas bepaald in
-- Stap 3 van docs/illustration-system/04_illustration_workflow_guide.md,
-- ruim na goedkeuring van de dialoog zelf (dialogs/dialog_blocks,
-- zie docs/thai_a1_dialog_workflow_guide.md Stap 10). Daarom een
-- eigen bestand in plaats van een derde blok in
-- a1_dialog_03.seed.sql.
--
-- Segmentatie-bron: docs/illustration-system/slide-specs/a1_dialog_03_slide_specs.md
-- slide_index is 0-based, net als block_index in dialog_blocks.
-- image_url blijft null -- die vult scripts/upload-slides.mjs later
-- in, na handmatige generatie en goedkeuring van de illustraties.
-- =========================================================

with dialog as (
  select id
  from public.dialogs
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-03')
)
insert into public.dialog_slides (dialog_id, slide_index, first_block_index, last_block_index)
select
  dialog.id,
  slide.slide_index,
  slide.first_block_index,
  slide.last_block_index
from dialog
cross join (values
  (0, 0, 1), -- Slide 1: Narin vraagt wat Mali wil drinken; zij antwoordt koffie (blokken 0-1)
  (1, 2, 3), -- Slide 2: Warm of ijskoffie; zij specificeert ijskoffie (blokken 2-3)
  (2, 4, 5)  -- Slide 3: Mali kaatst de vraag terug; Narin antwoordt thee (afsluiting, blokken 4-5)
) as slide(slide_index, first_block_index, last_block_index)
on conflict (dialog_id, slide_index) do update set
  first_block_index = excluded.first_block_index,
  last_block_index  = excluded.last_block_index,
  updated_at         = now();

commit;
