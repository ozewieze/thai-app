-- Automatisch gegenereerd uit supabase/generation/vocabulary-examples/a1_dialog_02_examples.json.
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


-- where / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'where'),
  'e1',
  1,
  'คุณไปที่ไหนคะ',
  'kun bpai tîi-nǎi ká',
  'Where are you going?'
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

-- go / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'go'),
  'e1',
  1,
  'ผมไปครับ',
  'pǒm bpai kráp',
  'I''m going.'
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

-- drink / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'drink'),
  'e1',
  1,
  'คุณดื่มอะไรครับ',
  'kun dʉ̀ʉm à-rai kráp',
  'What do you drink?'
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

-- coffee / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'coffee'),
  'e1',
  1,
  'ฉันดื่มกาแฟค่ะ',
  'chǎn dʉ̀ʉm gaa-faae kâ',
  'I drink coffee.'
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

-- can / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'can'),
  'e1',
  1,
  'ผมไปได้ครับ',
  'pǒm bpai dâai kráp',
  'I can go.'
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

-- together / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'together'),
  'e1',
  1,
  'ดื่มกาแฟด้วยกันค่ะ',
  'dʉ̀ʉm gaa-faae dûai-gan kâ',
  'We drink coffee together.'
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

-- question_particle_mai / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'question_particle_mai'),
  'e1',
  1,
  'คุณชื่อฝนไหมคะ',
  'kun chʉ̂ʉ fǒn mǎi ká',
  'Is your name Fon?'
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
