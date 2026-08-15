-- Automatisch gegenereerd uit supabase/generation/language-notes/a1_dialog_01_notes.json.
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
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    'a1-dialog-01-note-1',
    'Introducing yourself when you meet someone',
    1
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    'a1-dialog-01-note-2',
    'Speaking politely with ครับ, ค่ะ and คะ',
    2
  )
on conflict (note_key) do update set
  lesson_id     = excluded.lesson_id,
  title         = excluded.title,
  display_order = excluded.display_order;

-- 2. Note 'a1-dialog-01-note-1'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-01-note-1'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Mali says ฉันชื่อมะลิค่ะ — "My name is Mali." — and asks คุณชื่ออะไรคะ — "What is your name?". Asking someone''s name and giving your own name form a simple first-meeting exchange. For "I", a female speaker uses ฉัน, while a male speaker uses ผม.'),
  ('b2', 2, 'formula', null, '[pronoun] + ชื่อ + [name] = giving your own name'),
  ('b3', 3, 'example_group', null, null),
  ('b4', 4, 'paragraph', null, 'Narin then says ยินดีที่ได้รู้จักครับ — "Nice to meet you.". ยินดีที่ได้รู้จัก is a fixed expression you can use when meeting someone for the first time. The expression itself stays the same; only the polite particle changes with the speaker.'),
  ('b5', 5, 'usage_tip', null, 'Do not try to break ยินดีที่ได้รู้จัก into separate words yet. Learn it as one complete phrase for now — you will meet the individual words later.')
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
  where n.note_key = 'a1-dialog-01-note-1'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'ฉันชื่อฝนค่ะ', 'chǎn chʉ̂ʉ fǒn kâ', 'My name is Fon.'),
  ('b3', 'e2', 2, 'ผมชื่อนัทครับ', 'pǒm chʉ̂ʉ nát kráp', 'My name is Nat.')
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

-- phrase: self_introduction_name
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_phrase_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-01-note-1'),
  (select id from public.lessons where lesson_key = 'a1-dialog-01'),
  (select link.id
     from public.lesson_phrase link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-01')
      and link.phrase_id = (select id from public.phrase_master where phrase_key = 'self_introduction_name'))
)
on conflict (lesson_phrase_id, language_note_id)
  where lesson_phrase_id is not null
do nothing;

-- phrase: yin_di_thi_dai_ru_jak
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_phrase_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-01-note-1'),
  (select id from public.lessons where lesson_key = 'a1-dialog-01'),
  (select link.id
     from public.lesson_phrase link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-01')
      and link.phrase_id = (select id from public.phrase_master where phrase_key = 'yin_di_thi_dai_ru_jak'))
)
on conflict (lesson_phrase_id, language_note_id)
  where lesson_phrase_id is not null
do nothing;

-- 3. Note 'a1-dialog-01-note-2'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-01-note-2'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Mali says สวัสดีค่ะ — "Hello." — while Narin says สวัสดีครับ — "Hello.". Thai often marks politeness with a particle at the end of an utterance. A female speaker uses ค่ะ in a statement, while a male speaker uses ครับ.'),
  ('b2', 2, 'formula', null, '[statement] + ค่ะ / ครับ = polite statement'),
  ('b4', 3, 'paragraph', null, 'For a female speaker, the polite ending changes with the sentence: ค่ะ is used for a statement, but คะ is used for a question. A male speaker uses ครับ for both statements and questions. Keeping these female forms separate is important because they are not interchangeable.'),
  ('b5', 4, 'example_group', null, 'The first two are both said by a female speaker: only the ending changes with the type of sentence. The third shows a male speaker asking the same question.'),
  ('b6', 5, 'usage_tip', null, 'Pay attention to the tone difference between ค่ะ (kâ) and คะ (ká).')
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
  where n.note_key = 'a1-dialog-01-note-2'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b5', 'e1', 1, 'ฉันชื่อฟ้าค่ะ', 'chǎn chʉ̂ʉ fáa kâ', 'My name is Fah.'),
  ('b5', 'e2', 2, 'คุณชื่ออะไรคะ', 'kun chʉ̂ʉ à-rai ká', 'What is your name?'),
  ('b5', 'e3', 3, 'คุณชื่ออะไรครับ', 'kun chʉ̂ʉ à-rai kráp', 'What is your name?')
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

-- grammar: polite_particles_khrab_kha
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_grammar_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-01-note-2'),
  (select id from public.lessons where lesson_key = 'a1-dialog-01'),
  (select link.id
     from public.lesson_grammar link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-01')
      and link.grammar_id = (select id from public.grammar_master where concept_key = 'polite_particles_khrab_kha'))
)
on conflict (lesson_grammar_id, language_note_id)
  where lesson_grammar_id is not null
do nothing;

commit;
