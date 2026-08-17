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
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'where'),
    'target',
    false,
    1,
    'Question word for location.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'go'),
    'target',
    false,
    2,
    'Verb for movement; also marks direction or future intention in simple patterns.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'drink'),
    'target',
    false,
    3,
    'Verb for drinking.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'coffee'),
    'target',
    false,
    4,
    'Common drink used as a natural object in this dialog.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'can'),
    'target',
    false,
    5,
    'Modal verb for ability, possibility, and permission; also marks completed actions.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'together'),
    'target',
    false,
    6,
    'Adverb indicating shared action; pairs naturally with go and drink.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-02'),
    (select id from public.vocabulary_master where source_key = 'question_particle_mai'),
    'target',
    false, -- requires_explanation: statement_mai legt de vorm al uit; een tweede note zou hetzelfde herhalen
    7,
    'Yes/no question particle. Toegevoegd 2026-08-13: ไหม stond al in de dialoog en werd hier al aangeleerd, maar zonder link-rij bleef het buiten het woordbudget van elke latere les.'
  )
on conflict (lesson_id, vocabulary_id) do update
set role                 = excluded.role,
    requires_explanation = excluded.requires_explanation,
    display_order        = excluded.display_order,
    notes                = excluded.notes;

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
),
(
 (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select id from public.pattern_master where pattern_key = 'verb_dai'),
  'target',
  true,
  2,
  'Placed after the whole verb phrase to say that something can be done.'
)
on conflict (lesson_id, pattern_id) do update
set role                 = excluded.role,
    requires_explanation = excluded.requires_explanation,
    display_order        = excluded.display_order,
    notes                = excluded.notes;

-- vocabulary_status en grammar_status worden automatisch
-- bijgewerkt door de respectieve state machine triggers op het moment dat
-- lesson_vocabulary, lesson_grammar en lesson_pattern worden geseed.
-- Expliciete inserts hier zijn niet langer nodig.
