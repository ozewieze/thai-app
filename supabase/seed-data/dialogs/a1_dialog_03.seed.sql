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
insert into public.dialog_blocks (dialog_id, block_index, speaker_key, thai_text, transliteration, translation_en)
select
  dialog.id,
  block.block_index,
  block.speaker_key,
  block.thai_text,
  block.transliteration,
  block.translation_en
from dialog
cross join (values
  (0, 'narin', 'นริน: จะดื่มอะไรครับ',           'Narin: jà dʉ̀ʉm à-rai kráp',                  'Narin: What will you drink?'),
  (1, 'mali',  'มะลิ: กาแฟค่ะ',                  'Mali: gaa-faae kâ',                             'Mali: Coffee.'),
  (2, 'narin', 'นริน: กาแฟร้อนหรือกาแฟเย็นครับ', 'Narin: gaa-faae rɔ́ɔn rʉ̌ʉ gaa-faae yen kráp',  'Narin: Hot coffee or iced coffee?'),
  (3, 'mali',  'มะลิ: กาแฟเย็นค่ะ',              'Mali: gaa-faae yen kâ',                         'Mali: Iced coffee.'),
  (4, 'mali',  'มะลิ: คุณจะดื่มอะไรคะ',          'Mali: kun jà dʉ̀ʉm à-rai ká',                 'Mali: What will you drink?'),
  (5, 'narin', 'นริน: ชาครับ',                   'Narin: chaa kráp',                              'Narin: Tea.')
) as block(block_index, speaker_key, thai_text, transliteration, translation_en)
on conflict (dialog_id, block_index) do update set
  speaker_key     = excluded.speaker_key,
  thai_text       = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en  = excluded.translation_en,
  updated_at      = now();

commit;
