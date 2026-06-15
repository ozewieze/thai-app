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
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select id from public.grammar_master where concept_key = 'adjective_after_noun'),
  'target',
  true,
  1,
  'In Thai, adjectives follow the noun: กาแฟร้อน, ชาเย็น.'
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
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'tea' limit 1),
    'target',
    true,
    1,
    'Second drink option; paired with ร้อน or เย็น.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'hot' limit 1),
    'target',
    true,
    2,
    'Adjective for hot drink; follows the noun directly.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'cool' limit 1),
    'target',
    true,
    3,
    'Adjective for cold or iced drink; follows the noun directly.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'or' limit 1),
    'target',
    true,
    4,
    'Conjunction used to offer a choice between two options.'
  );

insert into public.lesson_pattern (
  lesson_id,
  pattern_id,
  role,
  requires_explanation,
  display_order,
  notes
)
values (
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select id from public.pattern_master where pattern_key = 'ja_verb'),
  'target',
  true,
  1,
  'จะ + VERB expresses future intention; used here to order or offer a drink.'
);

-- vocabulary_status en grammar_status worden automatisch
-- bijgewerkt door de respectieve state machine triggers op het moment dat
-- lesson_vocabulary, lesson_grammar en lesson_pattern worden geseed.
-- Expliciete inserts hier zijn niet langer nodig.
