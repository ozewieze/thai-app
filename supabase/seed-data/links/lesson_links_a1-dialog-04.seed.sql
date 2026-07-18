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
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  (select id from public.grammar_master where concept_key = 'negative_mai_general'),
  'target',
  true,
  1,
  'Use ไม่ before a verb adjective or modal to make it negative.'
),
(
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  (select id from public.grammar_master where concept_key = 'addition_duai'),
  'target',
  true,
  2,
  'Use ด้วย to add the meaning of also or too.'
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
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    (select id from public.vocabulary_master where source_key = 'take' limit 1),
    'target',
    true,
    1,
    'can mean take bring or choose depending on context'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    (select id from public.vocabulary_master where source_key = 'also' limit 1),
    'target',
    true,
    2,
    'placed at the end of a sentence to mean also or too; also means with or by means of'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    (select id from public.vocabulary_master where source_key = 'no' limit 1),
    'target',
    true,
    3,
    'basic negation; also used in answers and before verbs or adjectives'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    (select id from public.vocabulary_master where source_key = 'snack' limit 1),
    'target',
    true,
    4,
    'a small treat or snack; can be sweet or savory'
  ), 
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    (select id from public.vocabulary_master where source_key = 'cake' limit 1),
    'target',
    true,
    5,
    'a sweet baked dessert; can be a small snack or a larger cake for celebrations'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    (select id from public.vocabulary_master where source_key = 'ice_cream' limit 1),
    'target',
    true,
    6,
    'a frozen dessert made from dairy; can be a small snack or a larger treat'
  )
  ;

insert into public.lesson_pattern (
  lesson_id,
  pattern_id,
  role,
  requires_explanation,
  display_order,
  notes
)
values (
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  (select id from public.pattern_master where pattern_key = 'ao_noun'),
  'target',
  true,
  1,
  'Used to choose or ask for something in simple situations.'
),(
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
  (select id from public.pattern_master where pattern_key = 'mai_verb'),
  'target',
  true,
  2,
  'Negates an action or state.'
);

-- vocabulary_status en grammar_status worden automatisch
-- bijgewerkt door de respectieve state machine triggers op het moment dat
-- lesson_vocabulary, lesson_grammar en lesson_pattern worden geseed.
-- Expliciete inserts hier zijn niet langer nodig.