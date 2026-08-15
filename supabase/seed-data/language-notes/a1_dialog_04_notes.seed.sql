-- Automatisch gegenereerd uit supabase/generation/language-notes/a1_dialog_04_notes.json.
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
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    'a1-dialog-04-note-1',
    'Asking for and choosing things with เอา',
    1
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    'a1-dialog-04-note-2',
    'Making something negative with ไม่',
    2
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    'a1-dialog-04-note-3',
    'Adding "too" with ด้วย',
    3
  )
on conflict (note_key) do update set
  lesson_id     = excluded.lesson_id,
  title         = excluded.title,
  display_order = excluded.display_order;

-- 2. Note 'a1-dialog-04-note-1'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-04-note-1'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Narin asks เอาขนมไหมครับ — "Would you like a snack?", and Mali later says เอาเค้กค่ะ — "I''ll have cake.". เอา is used both to ask what someone wants and to state your own choice. The English translation changes with the situation, but the Thai word เอา stays the same.'),
  ('b2', 2, 'formula', null, 'เอา + [noun] = choose or ask for something'),
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
  where n.note_key = 'a1-dialog-04-note-1'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'เอาชาร้อนค่ะ', 'ao chaa rɔ́ɔn kâ', 'I''ll have hot tea.'),
  ('b3', 'e2', 2, 'คุณเอาเค้กหรือไอศกรีมครับ', 'kun ao kéek rʉ̌ʉ ai-sà-griim kráp', 'Would you like cake or ice cream?'),
  ('b3', 'e3', 3, 'คุณเอาอะไรครับ', 'kun ao à-rai kráp', 'What would you like?')
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

-- pattern: ao_noun
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_pattern_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-04-note-1'),
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  (select link.id
     from public.lesson_pattern link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-04')
      and link.pattern_id = (select id from public.pattern_master where pattern_key = 'ao_noun'))
)
on conflict (lesson_pattern_id, language_note_id)
  where lesson_pattern_id is not null
do nothing;

-- 3. Note 'a1-dialog-04-note-2'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-04-note-2'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Narin says ไม่เอาเค้กครับ — "I won''t have cake.". ไม่ goes directly before the word it makes negative. That word can be an action or a describing word.'),
  ('b2', 2, 'formula', null, 'ไม่ + [verb] = negative'),
  ('b3', 3, 'formula', null, '[noun] + ไม่ + [describing word] = saying something is not that way'),
  ('b4', 4, 'example_group', null, null)
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
  where n.note_key = 'a1-dialog-04-note-2'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b4', 'e1', 1, 'ไม่เอาชาค่ะ', 'mâi ao chaa kâ', 'I won''t have tea.'),
  ('b4', 'e2', 2, 'ผมไม่ไปครับ', 'pǒm mâi bpai kráp', 'I''m not going.'),
  ('b4', 'e3', 3, 'กาแฟไม่ร้อน', 'gaa-fɛɛ mâi rɔ́ɔn', 'The coffee isn''t hot.')
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

-- grammar: negative_mai_general
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_grammar_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-04-note-2'),
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  (select link.id
     from public.lesson_grammar link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-04')
      and link.grammar_id = (select id from public.grammar_master where concept_key = 'negative_mai_general'))
)
on conflict (lesson_grammar_id, language_note_id)
  where lesson_grammar_id is not null
do nothing;

-- pattern: mai_verb
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_pattern_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-04-note-2'),
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  (select link.id
     from public.lesson_pattern link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-04')
      and link.pattern_id = (select id from public.pattern_master where pattern_key = 'mai_verb'))
)
on conflict (lesson_pattern_id, language_note_id)
  where lesson_pattern_id is not null
do nothing;

-- 4. Note 'a1-dialog-04-note-3'

with note as (
  select id from public.language_notes where note_key = 'a1-dialog-04-note-3'
)
insert into public.language_note_blocks
  (language_note_id, block_key, display_order, block_type, heading, content)
select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content
from note
cross join (values
  ('b1', 1, 'paragraph', null::text, 'In the dialogue, Mali asks เอาเค้กด้วยไหมคะ — "Will you have cake too?". ด้วย adds the meaning "also" or "too". It comes at the end of the verb phrase, after the object when there is one.'),
  ('b2', 2, 'formula', null, '[verb phrase] + ด้วย = also or too'),
  ('b3', 3, 'example_group', null, null),
  ('b4', 4, 'usage_tip', null, 'ด้วย means "too" when you add one more thing or person. It is different from ด้วยกัน, which means "together" when people do something jointly.')
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
  where n.note_key = 'a1-dialog-04-note-3'
)
insert into public.language_note_examples
  (block_id, example_key, display_order, thai_script, paiboon, translation_en)
select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en
from (values
  ('b3', 'e1', 1, 'ผมดื่มชาด้วยครับ', 'pǒm dʉ̀ʉm chaa dûai kráp', 'I drink tea too.'),
  ('b3', 'e2', 2, 'ฉันไปด้วยค่ะ', 'chǎn bpai dûai kâ', 'I''ll go too.')
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

-- grammar: addition_duai
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_grammar_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-04-note-3'),
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  (select link.id
     from public.lesson_grammar link
    where link.lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-04')
      and link.grammar_id = (select id from public.grammar_master where concept_key = 'addition_duai'))
)
on conflict (lesson_grammar_id, language_note_id)
  where lesson_grammar_id is not null
do nothing;

commit;
