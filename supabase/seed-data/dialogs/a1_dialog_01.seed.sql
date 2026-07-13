begin;

-- =========================================================
-- a1_dialog_01 — Dialog 1: Greetings and introductions
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
  (select id from public.lessons where lesson_key = 'a1-dialog-01'),
  'Dialog 1',
  'Greetings and introductions',
  'Say hello, ask someone''s name, say your own name, and say nice to meet you.',
  'A first, polite introduction between Mali and Narin in an everyday setting.',
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
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-01')
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
  (0, 'mali',  'มะลิ: สวัสดีค่ะ',             'Mali: sà-wàt-dii kâ',                    'Mali: Hello.'),
  (1, 'narin', 'นริน: สวัสดีครับ',             'Narin: sà-wàt-dii kráp',                 'Narin: Hello.'),
  (2, 'mali',  'มะลิ: ฉันชื่อมะลิค่ะ',         'Mali: chǎn chʉ̂ʉ Mali kâ',                'Mali: My name is Mali.'),
  (3, 'mali',  'มะลิ: คุณชื่ออะไรคะ',          'Mali: kun chʉ̂ʉ à-rai ká',               'Mali: What is your name?'),
  (4, 'narin', 'นริน: ผมชื่อนรินครับ',          'Narin: pǒm chʉ̂ʉ Narin kráp',            'Narin: My name is Narin.'),
  (5, 'narin', 'นริน: ยินดีที่ได้รู้จักครับ',  'Narin: yin-dii tîi dâai rúu-jàk kráp',  'Narin: Nice to meet you.'),
  (6, 'mali',  'มะลิ: ยินดีที่ได้รู้จักค่ะ',  'Mali: yin-dii tîi dâai rúu-jàk kâ',     'Mali: Nice to meet you.')
) as block(block_index, speaker_key, thai_text, transliteration, translation_en)
on conflict (dialog_id, block_index) do update set
  speaker_key     = excluded.speaker_key,
  thai_text       = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en  = excluded.translation_en,
  updated_at      = now();

commit;
