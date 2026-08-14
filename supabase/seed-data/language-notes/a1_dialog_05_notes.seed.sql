-- Automatisch gegenereerd uit supabase/generation/language-notes/a1_dialog_05_notes.json.
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
-- voice_key blijft wel staan: dat is een redactionele keuze en geen verwijzing
-- die kan verouderen. Zelfde constructie als in
-- generate-vocabulary-example-seed.mjs.

begin;


-- 1. De notes van deze les

insert into public.language_notes (lesson_id, note_key, title, display_order)
values
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    'a1-dialog-05-note-1',
    'Saying what you like with ชอบ',
    1
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    'a1-dialog-05-note-2',
    'Adding detail after verbs and adjectives',
    2
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    'a1-dialog-05-note-3',
    'Using กิน for food and drinks',
    3
  )
on conflict (note_key) do update set
  lesson_id     = excluded.lesson_id,
  title         = excluded.title,
  display_order = excluded.display_order;

-- 2. Note 'a1-dialog-05-note-1'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-05-note-1'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Mali says ชอบขนมหวานค่ะ — "I like sweet snacks.". ชอบ comes directly before the thing or category you like. The Thai word ชอบ does not change when you talk about yourself or ask someone what they like.'),
  ('b2', 2, 'formula', null, 'ชอบ + [noun] = liking a thing or category'),
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
  where n.note_key = 'a1-dialog-05-note-1'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'ชอบชาค่ะ', 'chɔ̂ɔp chaa kâ', 'I like tea.'),
  ('b3', 'e2', 2, 'คุณชอบกาแฟไหมครับ', 'kun chɔ̂ɔp gaa-fɛɛ mǎi kráp', 'Do you like coffee?'),
  ('b3', 'e3', 3, 'ไม่ชอบเค้กครับ', 'mâi chɔ̂ɔp kéek kráp', 'I don''t like cake.')
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
                   end;

-- pattern: chop_noun
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_pattern_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-05-note-1'),
  (select id from public.lessons where lesson_key = 'a1-dialog-05'),
  (select link.id
     from public.lesson_pattern link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-05')
      and link.pattern_id = (select id from public.pattern_master where pattern_key = 'chop_noun'))
)
on conflict (lesson_pattern_id, language_note_id)
  where lesson_pattern_id is not null
do nothing;

-- 3. Note 'a1-dialog-05-note-2'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-05-note-2'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Mali says อร่อยมากค่ะ — "It is very delicious.". Words such as มาก and บ่อย come after the word they give more information about. That word can be a describing word, as here, or an action.'),
  ('b2', 2, 'formula', null, '[verb or adjective] + [adverb] = more detail about the action or the description'),
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
  where n.note_key = 'a1-dialog-05-note-2'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'ขนมอร่อยมาก', 'kà-nǒm à-rɔ̀i mâak', 'The snack is very delicious.'),
  ('b3', 'e2', 2, 'ฉันชอบไอศกรีมมากค่ะ', 'chǎn chɔ̂ɔp ai-sà-griim mâak kâ', 'I like ice cream very much.'),
  ('b3', 'e3', 3, 'ผมดื่มกาแฟบ่อยครับ', 'pǒm dʉ̀ʉm gaa-fɛɛ bɔ̀i kráp', 'I often drink coffee.')
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
                   end;

-- grammar: adverbs_after_verbs_and_adjectives
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_grammar_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-05-note-2'),
  (select id from public.lessons where lesson_key = 'a1-dialog-05'),
  (select link.id
     from public.lesson_grammar link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-05')
      and link.grammar_id = (select id from public.grammar_master where concept_key = 'adverbs_after_verbs_and_adjectives'))
)
on conflict (lesson_grammar_id, language_note_id)
  where lesson_grammar_id is not null
do nothing;

-- 4. Note 'a1-dialog-05-note-3'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-05-note-3'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Narin says ไม่กินขนมบ่อยครับ — "I don''t eat snacks often.". Here กิน means "eat". In everyday Thai, กิน is also commonly used with drinks, so its English translation depends on what comes after it.'),
  ('b2', 2, 'example_group', null, null),
  ('b3', 3, 'usage_tip', null, 'ดื่ม is the specific, more formal word for drinking. กิน is an everyday word that can be used for both eating and drinking. Both forms are correct Thai.')
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
  where n.note_key = 'a1-dialog-05-note-3'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b2', 'e1', 1, 'ผมกินกาแฟครับ', 'pǒm gin gaa-fɛɛ kráp', 'I drink coffee.'),
  ('b2', 'e2', 2, 'กินชาไหมคะ', 'gin chaa mǎi ká', 'Do you drink tea?'),
  ('b2', 'e3', 3, 'ไม่กินเค้กค่ะ', 'mâi gin kéek kâ', 'I don''t eat cake.')
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
                   end;

-- vocabulary: eat
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_vocabulary_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-05-note-3'),
  (select id from public.lessons where lesson_key = 'a1-dialog-05'),
  (select link.id
     from public.lesson_vocabulary link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-05')
      and link.vocabulary_id = (select id from public.vocabulary_master where source_key = 'eat'))
)
on conflict (lesson_vocabulary_id, language_note_id)
  where lesson_vocabulary_id is not null
do nothing;

commit;
