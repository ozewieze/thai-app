begin;

-- =========================================================
-- a1_dialog_04 — Dialog 4: Choosing a snack
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
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  'Dialog 4',
  'Choosing a snack',
  'Ask whether someone wants something, choose between simple food items, and express a different choice.',
  'After deciding what they will drink, Narin asks Mali if she would like a snack. Mali agrees. Narin asks which snack she wants, and she chooses cake. Mali then asks whether Narin will also take cake. He answers that he will take ice cream instead.',
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
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-04')
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
  (0, 'narin', 'นริน: เอาขนมไหมครับ',       'Narin: ao kà-nǒm mǎi kráp',    'Narin: Would you like a snack?'),
  (1, 'mali',  'มะลิ: เอาค่ะ',               'Mali: ao kâ',                   'Mali: Yes, I will.'),
  (2, 'narin', 'นริน: เอาขนมอะไรครับ',      'Narin: ao kà-nǒm à-rai kráp',  'Narin: What snack would you like?'),
  (3, 'mali',  'มะลิ: เอาเค้กค่ะ',           'Mali: ao kéek kâ',              'Mali: I''ll have cake.'),
  (4, 'mali',  'มะลิ: เอาเค้กด้วยไหมคะ',    'Mali: ao kéek dûai mǎi ká',    'Mali: Will you have cake too?'),
  (5, 'narin', 'นริน: ไม่เอาเค้กครับ',       'Narin: mâi ao kéek kráp',      'Narin: I won''t have cake.'),
  (6, 'narin', 'นริน: เอาไอศกรีมครับ',       'Narin: ao ai-sà-griim kráp',   'Narin: I''ll have ice cream.')
) as block(block_index, speaker_key, thai_text, transliteration, translation_en)
on conflict (dialog_id, block_index) do update set
  speaker_key     = excluded.speaker_key,
  thai_text       = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en  = excluded.translation_en,
  updated_at      = now();

commit;
