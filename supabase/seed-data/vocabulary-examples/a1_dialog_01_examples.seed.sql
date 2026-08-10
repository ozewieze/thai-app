-- Automatisch gegenereerd uit supabase/generation/vocabulary-examples/a1_dialog_01_examples.json.
-- Niet met de hand bewerken: draai scripts/generate-vocabulary-example-seed.mjs opnieuw.
--
-- Het bestand is idempotent. Opnieuw draaien is de manier om een correctie
-- door te voeren -- voor toevoegen en wijzigen. Verwijderen niet: haal je een
-- voorbeeld uit de JSON, dan blijft de rij in de database staan. Dat is een
-- aparte, expliciete handeling.
--
-- Waarom de `values ((select ...))`-vorm en niet `select ... join`: vindt de
-- subquery de source_key niet, dan levert deze vorm null op en botst hij op
-- NOT NULL. Het bestand faalt dan luid. De join-vorm zou nul rijen invoegen
-- en zwijgen -- en dan mist er stil een voorbeeld waarvan de
-- publicatievalidatie later denkt dat het bestaat.
--
-- Waarom audio_url op null gaat bij gewijzigde thai_script: audio die bij een
-- oudere zin hoort is erger dan geen audio. Het audioscript slaat een item met
-- een gevulde audio_url over ('er is al audio'), en de leerling hoort dan de
-- oude zin zonder dat iemand een foutmelding ziet. voice_key blijft wel staan:
-- dat is een redactionele keuze en geen verwijzing die kan verouderen.
--
-- Geen `updated_at = now()`: trg_vocabulary_examples_set_updated_at zet dat
-- veld zelf.

begin;


-- hello / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'hello'),
  'e1',
  1,
  'สวัสดีครับ',
  'sà-wàt-dii kráp',
  'Hello.'
)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.audio_url
                   end;

-- you / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'you'),
  'e1',
  1,
  'คุณชื่ออะไรคะ',
  'kun chʉ̂ʉ à-rai ká',
  'What is your name?'
)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.audio_url
                   end;

-- name / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'name'),
  'e1',
  1,
  'ฉันชื่อมายค่ะ',
  'chǎn chʉ̂ʉ maai kâ',
  'My name is Mai.'
)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.audio_url
                   end;

-- what / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'what'),
  'e1',
  1,
  'คุณชื่ออะไรครับ',
  'kun chʉ̂ʉ à-rai kráp',
  'What is your name?'
)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.audio_url
                   end;

-- i / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'i'),
  'e1',
  1,
  'ฉันชื่อฝนค่ะ',
  'chǎn chʉ̂ʉ fǒn kâ',
  'I''m Fon.'
)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.audio_url
                   end;

-- i_male / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'i_male'),
  'e1',
  1,
  'ผมชื่อก้องครับ',
  'pǒm chʉ̂ʉ gɔ̂ng kráp',
  'I''m Kong.'
)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.audio_url
                   end;

commit;
