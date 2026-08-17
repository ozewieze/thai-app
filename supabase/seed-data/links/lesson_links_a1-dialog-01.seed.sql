-- Auto-generated lesson-to-master links. Seeded after lessons, vocabulary, grammar, and patterns.
insert into public.lesson_grammar (
  lesson_id,
  grammar_id,
  role,
  requires_explanation,
  display_order,
  notes
)
values (
  (select id from public.lessons where lesson_key = 'a1-dialog-01'),
  (select id from public.grammar_master where concept_key = 'polite_particles_khrab_kha'),
  'target',
  true,
  1,
  'Polite sentence-final particles used in first-meeting introductions.'
)
on conflict (lesson_id, grammar_id) do update
set role                 = excluded.role,
    requires_explanation = excluded.requires_explanation,
    display_order        = excluded.display_order,
    notes                = excluded.notes;

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
    (select id from public.vocabulary_master where source_key = 'hello'),
    'target',
    false,
    1,
    'Greeting word for first contact.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'you'),
    'target',
    false,
    2,
    'You / polite address in introductions.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'name'),
    'target',
    false,
    3,
    'Name.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'what'),
    'target',
    false,
    4,
    'What.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'i'),
    'target',
    false,
    5,
    'I / me for female speaker.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-01'),
    (select id from public.vocabulary_master where source_key = 'i_male'),
    'target',
    false,
    6,
    'I / me for male speaker.'
  )
on conflict (lesson_id, vocabulary_id) do update
set role                 = excluded.role,
    requires_explanation = excluded.requires_explanation,
    display_order        = excluded.display_order,
    notes                = excluded.notes;


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
  )
on conflict (lesson_id, phrase_id) do update
set role                 = excluded.role,
    requires_explanation = excluded.requires_explanation,
    display_order        = excluded.display_order,
    notes                = excluded.notes;

-- vocabulary_status, phrase_status en grammar_status worden automatisch
-- bijgewerkt door de respectieve state machine triggers op het moment dat
-- lesson_vocabulary, lesson_phrase en lesson_grammar worden geseed.
-- Expliciete inserts hier zijn niet langer nodig.

