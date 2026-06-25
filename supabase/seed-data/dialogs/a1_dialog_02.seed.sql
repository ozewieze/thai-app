begin;

-- =========================================================
-- a1_dialog_02 — Dialog 2: Where are you going?
-- =========================================================

-- 1. dialog metadata
insert into public.dialogs (
  lesson_id,
  title,
  subtitle,
  learning_focus,
  scene_summary,
  register
) values (
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  'Dialog 2',
  'Where are you going?',
  'Ask where someone is going, invite them to do something together, and accept an invitation.',
  'Continuation of the first, polite introduction between Mali and Narin in an everyday setting. Narin asks where she is going and invites her for coffee.',
  'polite'
)
on conflict (lesson_id) do update set
  title          = excluded.title,
  subtitle       = excluded.subtitle,
  learning_focus = excluded.learning_focus,
  scene_summary  = excluded.scene_summary,
  register       = excluded.register,
  updated_at     = now();

-- 2. dialog blocks
with dialog as (
  select id
  from public.dialogs
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-02')
)
insert into public.dialog_blocks (dialog_id, block_index, thai_text, transliteration, translation_en)
select
  dialog.id,
  block.block_index,
  block.thai_text,
  block.transliteration,
  block.translation_en
from dialog
cross join (values
  (0, 'นริน: ไปที่ไหนครับ',           'Narin: bpai thîi-nǎi khráp',                   'Narin: Where are you going?'),
  (1, 'มะลิ: ไปดื่มกาแฟค่ะ',          'Mali: bpai dʉ̀ʉm gaa-faae khâ',                 'Mali: I am going to drink coffee.'),
  (2, 'นริน: ดื่มกาแฟด้วยกันไหมครับ', 'Narin: dʉ̀ʉm gaa-faae dûai-gan mǎi khráp',     'Narin: Would you like to drink coffee together?'),
  (3, 'มะลิ: ได้ค่ะ',                 'Mali: dâai khâ',                                'Mali: Yes, I''d like to.'),
  (4, 'มะลิ: ไปด้วยกันค่ะ',           'Mali: bpai dûai-gan khâ',                       'Mali: Let''s go together.'),
  (5, 'นริน: ครับ',                   'Narin: khráp',                                  'Narin: Okay.')
) as block(block_index, thai_text, transliteration, translation_en)
on conflict (dialog_id, block_index) do update set
  thai_text       = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en  = excluded.translation_en,
  updated_at      = now();

commit;
