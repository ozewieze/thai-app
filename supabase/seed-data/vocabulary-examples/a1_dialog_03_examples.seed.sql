-- Automatisch gegenereerd uit supabase/generation/vocabulary-examples/a1_dialog_03_examples.json.
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
-- oude zin zonder dat iemand een foutmelding ziet. voice_key gaat mee op null:
-- die kolom is een verslag van welke stem de opname insprak, geen redactionele
-- invoer -- zonder opname valt er niets te verslaan, en een achtergebleven
-- voice_key zou een uitspraak zijn over een bestand dat niet meer bestaat.
-- De audiostap leidt de stem opnieuw af uit de gecorrigeerde zin en schrijft
-- hem terug. De twee kolommen horen samen gevuld en samen leeg te zijn.
--
-- Geen `updated_at = now()`: trg_vocabulary_examples_set_updated_at zet dat
-- veld zelf.

begin;


-- tea / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'tea'),
  'e1',
  1,
  'ฉันดื่มชาค่ะ',
  'chǎn dʉ̀ʉm chaa kâ',
  'I drink tea.'
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
                   end,
  voice_key      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.voice_key
                   end;

-- hot / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'hot'),
  'e1',
  1,
  'ผมดื่มชาร้อนครับ',
  'pǒm dʉ̀ʉm chaa rɔ́ɔn kráp',
  'I drink hot tea.'
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
                   end,
  voice_key      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.voice_key
                   end;

-- cool / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'cool'),
  'e1',
  1,
  'ฉันดื่มกาแฟเย็นค่ะ',
  'chǎn dʉ̀ʉm gaa-fɛɛ yen kâ',
  'I drink iced coffee.'
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
                   end,
  voice_key      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.voice_key
                   end;

-- or / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'or'),
  'e1',
  1,
  'คุณดื่มชาหรือกาแฟครับ',
  'kun dʉ̀ʉm chaa rʉ̌ʉ gaa-fɛɛ kráp',
  'Do you drink tea or coffee?'
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
                   end,
  voice_key      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.voice_key
                   end;

-- will / e1
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'will'),
  'e1',
  1,
  'ฉันจะไปค่ะ',
  'chǎn jà bpai kâ',
  'I will go.'
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
                   end,
  voice_key      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.voice_key
                   end;

commit;
