begin;

-- =========================================================
-- a1_dialog_03 — Dialog 3: At the café
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
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  'Dialog 3',
  'At the café',
  'Ask what someone will drink and talk about drink choices.',
  'Mali and Narin are seated at a café after deciding to have coffee together. They talk about what they will drink.',
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
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-03')
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
  (0, 'นริน: จะดื่มอะไรครับ',          'Narin: jà dʉ̀ʉm à-rai khráp',                  'Narin: What will you drink?'),
  (1, 'มะลิ: กาแฟค่ะ',                 'Mali: gaa-faae khâ',                             'Mali: Coffee.'),
  (2, 'นริน: กาแฟร้อนหรือกาแฟเย็นครับ','Narin: gaa-faae rɔ́ɔn rʉ̌ʉ gaa-faae yen khráp',  'Narin: Hot coffee or iced coffee?'),
  (3, 'มะลิ: กาแฟเย็นค่ะ',             'Mali: gaa-faae yen khâ',                         'Mali: Iced coffee.'),
  (4, 'มะลิ: คุณจะดื่มอะไรคะ',         'Mali: khun jà dʉ̀ʉm à-rai khá',                 'Mali: What will you drink?'),
  (5, 'นริน: ชาครับ',                  'Narin: chaa khráp',                              'Narin: Tea.')
) as block(block_index, thai_text, transliteration, translation_en)
on conflict (dialog_id, block_index) do update set
  thai_text       = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en  = excluded.translation_en,
  updated_at      = now();

commit;
