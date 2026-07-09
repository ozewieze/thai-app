begin;



with dialog as (
  select id
  from public.dialogs
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-02')
)
insert into public.dialog_slides (dialog_id, slide_index, first_block_index, last_block_index)
select
  dialog.id,
  slide.slide_index,
  slide.first_block_index,
  slide.last_block_index
from dialog
cross join (values
  (0, 0, 1), -- Slide 1: Narin vraagt waar Mali heen gaat; zij antwoordt (blokken 0-1)
  (1, 2, 3), -- Slide 2: Uitnodiging om samen koffie te drinken; acceptatie (blokken 2-3)
  (2, 4, 5)  -- Slide 3: Bevestiging en afsluiting (blokken 4-5)
) as slide(slide_index, first_block_index, last_block_index)
on conflict (dialog_id, slide_index) do update set
  first_block_index = excluded.first_block_index,
  last_block_index  = excluded.last_block_index,
  updated_at         = now();

commit;