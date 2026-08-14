-- Automatisch gegenereerd uit supabase/generation/vocabulary-examples/a1_dialog_05_examples.json.
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


-- like / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'like'),
  'e1',
  1,
  'ผมชอบกาแฟครับ',
  'pǒm chɔ̂ɔp gaa-fɛɛ kráp',
  'I like coffee.'
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

-- eat / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'eat'),
  'e1',
  1,
  'ฉันกินขนมค่ะ',
  'chǎn gin kà-nǒm kâ',
  'I eat snacks.'
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

-- delicious / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'delicious'),
  'e1',
  1,
  'เค้กอร่อย',
  'kéek à-rɔ̀i',
  'The cake is delicious.'
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

-- sweet / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'sweet'),
  'e1',
  1,
  'ไอศกรีมหวาน',
  'ai-sà-griim wǎan',
  'Ice cream is sweet.'
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

-- often / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'often'),
  'e1',
  1,
  'ผมกินเค้กบ่อยครับ',
  'pǒm gin kéek bɔ̀i kráp',
  'I often eat cake.'
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

-- very / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'very'),
  'e1',
  1,
  'กาแฟร้อนมาก',
  'gaa-fɛɛ rɔ́ɔn mâak',
  'The coffee is very hot.'
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
