-- Automatisch gegenereerd uit supabase/generation/language-notes/a1_dialog_02_notes.json.
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
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    'a1-dialog-02-note-1',
    'Saying where you are going and what you are going to do',
    1
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    'a1-dialog-02-note-2',
    'Asking yes/no questions with ไหม',
    2
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    'a1-dialog-02-note-3',
    'Saying something can be done with ได้',
    3
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    'a1-dialog-02-note-4',
    'Thai often leaves out the subject',
    4
  )
on conflict (note_key) do update set
  lesson_id     = excluded.lesson_id,
  title         = excluded.title,
  display_order = excluded.display_order;

-- 2. Note 'a1-dialog-02-note-1'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-02-note-1'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Narin asks ไปที่ไหนครับ — "Where are you going?", and Mali says ไปดื่มกาแฟค่ะ — "I am going to drink coffee.". ไป can show where someone is going, or it can come before an action to show what someone is going to do. The second use is the one you will practise below.'),
  ('b2', 2, 'formula', null, 'ไป + [verb phrase] = going to do something'),
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
  where n.note_key = 'a1-dialog-02-note-1'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'ฉันไปดื่มกาแฟค่ะ', 'chǎn bpai dʉ̀ʉm gaa-fɛɛ kâ', 'I am going to drink coffee.'),
  ('b3', 'e2', 2, 'ไปดื่มกาแฟด้วยกันครับ', 'bpai dʉ̀ʉm gaa-fɛɛ dûai-gan kráp', 'Let''s go and drink coffee together.')
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

-- grammar: movement_pai
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_grammar_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-02-note-1'),
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select link.id
     from public.lesson_grammar link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-02')
      and link.grammar_id = (select id from public.grammar_master where concept_key = 'movement_pai'))
)
on conflict (lesson_grammar_id, language_note_id)
  where lesson_grammar_id is not null
do nothing;

-- 3. Note 'a1-dialog-02-note-2'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-02-note-2'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Narin asks ดื่มกาแฟด้วยกันไหมครับ — "Would you like to drink coffee together?". Thai does not reorder the sentence to make this kind of question. Keep the statement as it is and add ไหม at the end.'),
  ('b2', 2, 'formula', null, '[statement] + ไหม = yes/no question'),
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
  where n.note_key = 'a1-dialog-02-note-2'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'คุณดื่มกาแฟไหมคะ', 'kun dʉ̀ʉm gaa-fɛɛ mǎi ká', 'Do you drink coffee?'),
  ('b3', 'e2', 2, 'คุณไปไหมครับ', 'kun bpai mǎi kráp', 'Are you going?')
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

-- pattern: statement_mai
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_pattern_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-02-note-2'),
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select link.id
     from public.lesson_pattern link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-02')
      and link.pattern_id = (select id from public.pattern_master where pattern_key = 'statement_mai'))
)
on conflict (lesson_pattern_id, language_note_id)
  where lesson_pattern_id is not null
do nothing;

-- 4. Note 'a1-dialog-02-note-3'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-02-note-3'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Mali answers ได้ค่ะ — "Yes, I''d like to.". Here she is saying that what Narin suggested can be done. In the full construction, ได้ comes after everything you can do; the standalone ได้ is simply a short answer form of the same idea.'),
  ('b2', 2, 'formula', null, '[verb phrase] + ได้ = ability or possibility'),
  ('b3', 3, 'example_group', null, null),
  ('b4', 4, 'usage_tip', null, 'ได้ goes at the very end, after the object: ดื่มกาแฟได้. The object comes between the verb and ได้, not the other way around.')
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
  where n.note_key = 'a1-dialog-02-note-3'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'ผมดื่มกาแฟได้ครับ', 'pǒm dʉ̀ʉm gaa-fɛɛ dâai kráp', 'I can drink coffee.'),
  ('b3', 'e2', 2, 'ฉันไปได้ค่ะ', 'chǎn bpai dâai kâ', 'I can go.')
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

-- pattern: verb_dai
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_pattern_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-02-note-3'),
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select link.id
     from public.lesson_pattern link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-02')
      and link.pattern_id = (select id from public.pattern_master where pattern_key = 'verb_dai'))
)
on conflict (lesson_pattern_id, language_note_id)
  where lesson_pattern_id is not null
do nothing;

-- 5. Note 'a1-dialog-02-note-4'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-02-note-4'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Mali says ไปดื่มกาแฟค่ะ — "I am going to drink coffee.". There is no word for "I" in the Thai sentence. Thai often leaves the subject out when the context already makes it clear who or what the sentence is about.'),
  ('b2', 2, 'example_group', null, null)
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
  where n.note_key = 'a1-dialog-02-note-4'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b2', 'e1', 1, 'ชื่อฝนค่ะ', 'chʉ̂ʉ fǒn kâ', 'My name is Fon.'),
  ('b2', 'e2', 2, 'ดื่มกาแฟครับ', 'dʉ̀ʉm gaa-fɛɛ kráp', 'I am drinking coffee.')
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

-- grammar: subject_omission_when_clear
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_grammar_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-02-note-4'),
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select link.id
     from public.lesson_grammar link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-02')
      and link.grammar_id = (select id from public.grammar_master where concept_key = 'subject_omission_when_clear'))
)
on conflict (lesson_grammar_id, language_note_id)
  where lesson_grammar_id is not null
do nothing;

commit;
