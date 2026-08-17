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
),
-- cleanup: deze herziening ging van 8 naar 6 blokken (block_index 0-5).
-- on conflict ... do update hieronder werkt alleen bij/voegt toe, het
-- verwijdert nooit rijen die niet meer in de values-lijst staan -- zonder
-- deze delete blijven de oude block_index 6 en 7 als wees-rijen staan.
-- Als data-wijzigende CTE binnen dezelfde with-clausule als de insert,
-- zodat beide in één statement lopen en "dialog" in scope blijft.
cleanup as (
  delete from public.dialog_blocks
  where dialog_id = (select id from dialog)
    and block_index >= 6
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
  (0, 'narin', 'นริน: เค้กอร่อยไหมครับ',                 'Narin: kéek à-rɔ̀i mǎi kráp',                              'Narin: Is the cake delicious?'),
  (1, 'mali',  'มะลิ: อร่อยมากค่ะ เค้กหวาน ชอบขนมหวานค่ะ',  'Mali: à-rɔ̀i mâak kâ. kéek wǎan. chɔ̂ɔp kà-nǒm wǎan kâ.',       'Mali: It is very delicious. The cake is sweet. I like sweet snacks.'),
  (2, 'mali',  'มะลิ: ชอบเค้กด้วยไหมคะ',                 'Mali: chɔ̂ɔp kéek dûai mǎi ká',                            'Mali: Do you like cake too?'),
  (3, 'narin', 'นริน: ชอบครับ คุณชอบไอศกรีมด้วยไหมครับ', 'Narin: chɔ̂ɔp kráp. kun chɔ̂ɔp ai-sà-griim dûai mǎi kráp', 'Narin: I do. Do you like ice cream too?'),
  (4, 'mali',  'มะลิ: ชอบค่ะ กินขนมบ่อยไหมคะ',           'Mali: chɔ̂ɔp kâ. gin kà-nǒm bɔ̀i mǎi ká',                  'Mali: I do. Do you often eat snacks?'),
  (5, 'narin', 'นริน: ไม่กินขนมบ่อยครับ',                'Narin: mâi gin kà-nǒm bɔ̀i kráp',                          'Narin: I don''t eat snacks often.')
) as block(block_index, speaker_key, thai_text, transliteration, translation_en)
on conflict (dialog_id, block_index) do update set
  speaker_key     = excluded.speaker_key,
  thai_text       = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en  = excluded.translation_en,
  updated_at      = now();

commit;
