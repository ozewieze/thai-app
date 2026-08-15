-- Automatisch gegenereerd uit supabase/generation/language-notes/a1_dialog_03_notes.json.
-- Niet met de hand bewerken: draai scripts/generate-language-note-seed.mjs opnieuw.
--
-- Het bestand is idempotent. Opnieuw draaien is de manier om een correctie
-- door te voeren -- voor toevoegen en wijzigen. Verwijderen niet: haal je een
-- note, blok, voorbeeld of claim uit de JSON, dan blijft de rij in de database
-- staan. Dat is een aparte, expliciete handeling.
--
-- Herorden je blokken of notes, draai dit bestand dan binnen een transactie met
--   set constraints all deferred;
-- De tussenstand van een herordening botst anders op de display_order-
-- constraints; precies daarvoor zijn die deferrable aangemaakt.
--
-- Waarom audio_url op null gaat bij gewijzigde thai_script: audio die bij een
-- oudere zin hoort is erger dan geen audio. Het audioscript slaat een item met
-- een gevulde audio_url over ('er is al audio'), en de leerling hoort dan de
-- oude zin zonder dat iemand een foutmelding ziet. Dat maakt voorlopige notes
-- veilig herzienbaar: corrigeer de tekst, draai opnieuw, en de audio hoort
-- vanzelf bij het volgende audioscript opnieuw gegenereerd te worden.
-- voice_key gaat mee op null: die kolom is een verslag van welke stem de opname
-- insprak, geen redactionele invoer -- zonder opname valt er niets te verslaan.
-- De audiostap leidt de stem opnieuw af uit de gecorrigeerde zin en schrijft hem
-- terug. Zelfde constructie als in generate-vocabulary-example-seed.mjs.

begin;


-- 1. De notes van deze les

insert into public.language_notes (lesson_id, note_key, title, display_order)
values
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    'a1-dialog-03-note-1',
    'Talking about what you’ll do with จะ',
    1
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    'a1-dialog-03-note-2',
    'Describing things: the noun comes first',
    2
  )
on conflict (note_key) do update set
  lesson_id     = excluded.lesson_id,
  title         = excluded.title,
  display_order = excluded.display_order;

-- 2. Note 'a1-dialog-03-note-1'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-03-note-1'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Narin and Mali both ask จะดื่มอะไร — "What will you drink?". จะ comes before a verb and shows what someone intends or is going to do. Here, จะดื่ม asks about what someone plans to drink.'),
  ('b2', 2, 'formula', null, 'จะ + [verb] = future intention'),
  ('b3', 3, 'example_group', null, null)
) as b(block_key, display_order, block_type, heading, content)
on conflict (language_note_id, block_key) do update set
  display_order = excluded.display_order,
  block_type    = excluded.block_type,
  heading       = excluded.heading,
  content       = excluded.content;

with blocks as (
  select blk.id, blk.block_key
  from public.language_note_blocks blk
  join public.language_notes n on n.id = blk.language_note_id
  where n.note_key = 'a1-dialog-03-note-1'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'จะไปด้วยกันครับ', 'jà bpai dûai-gan kráp', 'We''ll go together.'),
  ('b3', 'e2', 2, 'ฉันจะดื่มกาแฟค่ะ', 'chǎn jà dʉ̀ʉm gaa-fɛɛ kâ', 'I will drink coffee.'),
  ('b3', 'e3', 3, 'คุณจะไปที่ไหนคะ', 'kun jà bpai tîi-nǎi ká', 'Where will you go?')
) as e(block_key, example_key, display_order, thai_script, paiboon, translation_en)
join blocks on blocks.block_key = e.block_key
on conflict (block_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when language_note_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else language_note_examples.audio_url
                   end,
  voice_key      = case
                     when language_note_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else language_note_examples.voice_key
                   end;

-- pattern: ja_verb
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_pattern_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-03-note-1'),
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select link.id
     from public.lesson_pattern link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-03')
      and link.pattern_id = (select id from public.pattern_master where pattern_key = 'ja_verb'))
)
on conflict (lesson_pattern_id, language_note_id)
  where lesson_pattern_id is not null
do nothing;

-- 3. Note 'a1-dialog-03-note-2'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-03-note-2'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Narin asks about กาแฟร้อน and กาแฟเย็น — hot coffee and iced coffee. ร้อน means "hot", while เย็น can describe a drink as cold or iced. Notice that the describing word comes after the drink in Thai.'),
  ('b2', 2, 'formula', null, '[noun] + [adjective] = descriptive phrase'),
  ('b3', 3, 'example_group', null, null),
  ('b4', 4, 'usage_tip', null, 'English usually puts the description before the noun, as in "hot coffee". In this Thai pattern, the order is reversed: say กาแฟร้อน, with the description after the noun.')
) as b(block_key, display_order, block_type, heading, content)
on conflict (language_note_id, block_key) do update set
  display_order = excluded.display_order,
  block_type    = excluded.block_type,
  heading       = excluded.heading,
  content       = excluded.content;

with blocks as (
  select blk.id, blk.block_key
  from public.language_note_blocks blk
  join public.language_notes n on n.id = blk.language_note_id
  where n.note_key = 'a1-dialog-03-note-2'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'กาแฟร้อน', 'gaa-fɛɛ rɔ́ɔn', 'hot coffee'),
  ('b3', 'e4', 2, 'ชาเย็น', 'chaa yen', 'iced tea')
) as e(block_key, example_key, display_order, thai_script, paiboon, translation_en)
join blocks on blocks.block_key = e.block_key
on conflict (block_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when language_note_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else language_note_examples.audio_url
                   end,
  voice_key      = case
                     when language_note_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else language_note_examples.voice_key
                   end;

-- vocabulary: hot
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_vocabulary_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-03-note-2'),
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select link.id
     from public.lesson_vocabulary link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-03')
      and link.vocabulary_id = (select id from public.vocabulary_master where source_key = 'hot'))
)
on conflict (lesson_vocabulary_id, language_note_id)
  where lesson_vocabulary_id is not null
do nothing;

-- vocabulary: cool
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_vocabulary_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-03-note-2'),
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select link.id
     from public.lesson_vocabulary link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-03')
      and link.vocabulary_id = (select id from public.vocabulary_master where source_key = 'cool'))
)
on conflict (lesson_vocabulary_id, language_note_id)
  where lesson_vocabulary_id is not null
do nothing;

-- grammar: adjective_after_noun
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_grammar_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-03-note-2'),
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select link.id
     from public.lesson_grammar link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-03')
      and link.grammar_id = (select id from public.grammar_master where concept_key = 'adjective_after_noun'))
)
on conflict (lesson_grammar_id, language_note_id)
  where lesson_grammar_id is not null
do nothing;

commit;
