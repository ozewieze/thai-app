-- Auto-generated lesson-to-master links. Seeded after lessons, vocabulary, grammar, and patterns.

insert into public.lesson_grammar (
  lesson_id,
  grammar_id,
  role,
  requires_explanation,
  display_order,
  notes
)
values
(
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select id from public.grammar_master where concept_key = 'subject_omission_when_clear'),
  'target',
  true,
  1,
  'Subject is often dropped when context makes the speaker or listener obvious.'
),
(
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select id from public.grammar_master where concept_key = 'movement_pai'),
  'target',
  true,
  2,
  'Use ไป with a place or verb to show movement away or going to do something.'
)
;

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
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'where' limit 1),
    'target',
    true,
    1,
    'Question word for location.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'go' limit 1),
    'target',
    true,
    2,
    'Verb for movement; also marks direction or future intention in simple patterns.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'drink' limit 1),
    'target',
    true,
    3,
    'Verb for drinking.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'coffee' limit 1),
    'target',
    true,
    4,
    'Common drink used as a natural object in this dialog.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'can' limit 1),
    'target',
    true,
    5,
    'Modal verb for ability, possibility, and permission; also marks completed actions.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'together' limit 1),
    'target',
    true,
    6,
    'Adverb indicating shared action; pairs naturally with go and drink.'
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
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select id from public.pattern_master where pattern_key = 'statement_mai'),
  'target',
  true,
  1,
  'Core yes/no question pattern: adds ไหม at the end of a statement.'
);

-- vocabulary_status en grammar_status worden automatisch
-- bijgewerkt door de respectieve state machine triggers op het moment dat
-- lesson_vocabulary, lesson_grammar en lesson_pattern worden geseed.
-- Expliciete inserts hier zijn niet langer nodig.
