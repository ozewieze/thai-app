-- Auto-generated lesson-to-master links. Seeded after lessons, vocabulary, grammar, and patterns.

-- TODO deze seed mag verwijderd worden zodra de state machine is geïmplementeerd en er een geautomatiseerde manier is om deze links te genereren op basis van de status van de lesinhoud. De huidige inhoud van deze seed is handmatig gemaakt op basis van de eerste les, maar in de toekomst zou dit automatisch moeten gebeuren op basis van de status van de inhoud in de lessen.

insert into public.lesson_grammar (
  lesson_id,
  grammar_id,
  requires_explanation,
  display_order,
  notes
)
values (
  (select id from public.lessons where lesson_key = 'a1-dialog-01'),
  (select id from public.grammar_master where concept_key = 'polite_particles_khrab_kha'),
  true,
  1,
  'Polite sentence-final particles used in first-meeting introductions.'
);

insert into public.lesson_vocabulary (
  lesson_id,
  vocabulary_id,
  role,
  requires_explanation,
  display_order,
  notes
)
values
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'hello' limit 1),
    'target',
    true,
    1,
    'Greeting word for first contact.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'you' limit 1),
    'target',
    true,
    2,
    'You / polite address in introductions.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'name' limit 1),
    'target',
    true,
    3,
    'Name.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'what' limit 1),
    'target',
    true,
    4,
    'What.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'i' limit 1),
    'target',
    true,
    5,
    'I / me for female speaker.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'i_male' limit 1),
    'target',
    true,
    6,
    'I / me for male speaker.'
  );


insert into public.lesson_phrase (
  lesson_id,
  phrase_id,
  role,
  requires_explanation,
  display_order,
  notes
)
values
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.phrase_master where phrase_key = 'self_introduction_name'),
    'target',
    true,
    1,
    'Core first-meeting exchange: asking and giving a name.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.phrase_master where phrase_key = 'yin_di_thi_dai_ru_jak'),
    'target',
    true,
    2,
    'Polite fixed expression used when meeting someone for the first time.'
  );

insert into public.phrase_status (
  phrase_id,
  status,
  first_lesson_id
)
values
  (
    (select id from public.phrase_master where phrase_key = 'self_introduction_name'),
    'introduced_core',
    (select id from public.lessons where lesson_key = 'a1-dialog-01')
  ),
  (
    (select id from public.phrase_master where phrase_key = 'yin_di_thi_dai_ru_jak'),
    'introduced_core',
    (select id from public.lessons where lesson_key = 'a1-dialog-01')
  );

insert into public.grammar_status (
  grammar_id,
  status,
  first_lesson_id
)
values
  (
    (select id from public.grammar_master where concept_key = 'polite_particles_khrab_kha'),
    'introduced_core',
    (select id from public.lessons where lesson_key = 'a1-dialog-01')
  );

-- vocabulary_status wordt automatisch bijgewerkt door de trigger
-- trg_lesson_vocabulary_state_machine op het moment dat lesson_vocabulary
-- wordt geseed. Expliciete inserts hier zijn niet langer nodig.

