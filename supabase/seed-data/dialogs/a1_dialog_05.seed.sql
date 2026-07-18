begin;

-- =========================================================
-- a1_dialog_05 — Dialog 5: Enjoying the Food
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
  (select id from public.lessons where lesson_key = 'a1-dialog-05'),
  'Dialog 5',
  'Enjoying the Food',
  'Express likes, describe food, and talk about eating habits using simple adverbs.',
  'Their drinks and snacks have arrived. Mali and Narin taste the food, talk about whether they like it, describe it as delicious and sweet, and briefly talk about how often they eat snacks.',
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
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-05')
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
  (0, 'mali',  'มะลิ: เค้กอร่อยไหมคะ',       'Mali: kéek à-rɔ̀i mǎi ká',         'Mali: Is the cake delicious?'),
  (1, 'narin', 'นริน: อร่อยมากครับ',          'Narin: à-rɔ̀i mâak kráp',          'Narin: It''s very delicious.'),
  (2, 'narin', 'นริน: ชอบเค้กไหมครับ',        'Narin: chɔ̂ɔp kéek mǎi kráp',      'Narin: Do you like cake?'),
  (3, 'mali',  'มะลิ: ชอบค่ะ เค้กหวานค่ะ',    'Mali: chɔ̂ɔp kâ. kéek wǎan kâ.',   'Mali: I do. The cake is sweet.'),
  (4, 'mali',  'มะลิ: ชอบไอศกรีมไหมคะ',       'Mali: chɔ̂ɔp ai-sà-griim mǎi ká',  'Mali: Do you like ice cream?'),
  (5, 'narin', 'นริน: ชอบครับ',               'Narin: chɔ̂ɔp kráp',               'Narin: I do.'),
  (6, 'mali',  'มะลิ: กินขนมบ่อยไหมคะ',       'Mali: gin kà-nǒm bɔ̀i mǎi ká',     'Mali: Do you often eat snacks?'),
  (7, 'narin', 'นริน: ไม่กินขนมบ่อยครับ',      'Narin: mâi gin kà-nǒm bɔ̀i kráp',  'Narin: I don''t eat snacks often.')
) as block(block_index, speaker_key, thai_text, transliteration, translation_en)
on conflict (dialog_id, block_index) do update set
  speaker_key     = excluded.speaker_key,
  thai_text       = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en  = excluded.translation_en,
  updated_at      = now();

commit;
