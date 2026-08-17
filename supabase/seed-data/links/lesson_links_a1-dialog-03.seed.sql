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
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'tea'),
    'target',
    false, -- requires_explanation: gewoon zelfstandig naamwoord, de vocabulary card volstaat
    1,
    'Second drink option; paired with ร้อน or เย็น.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'hot'),
    'target',
    true, -- requires_explanation: samen met เย็น en adjective_after_noun in één note
    2,
    'Adjective for hot drink; follows the noun directly.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'cool'),
    'target',
    true, -- requires_explanation: samen met ร้อน en adjective_after_noun in één note
    3,
    'Adjective for cold or iced drink; follows the noun directly.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'or'),
    'target',
    false, -- requires_explanation: keuze-conjunctie, gelijk aan het Nederlandse "of"
    4,
    'Conjunction used to offer a choice between two options.'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-03'),
    (select id from public.vocabulary_master where source_key = 'will'),
    'target',
    false, -- requires_explanation: ja_verb legt de vorm al uit; een tweede note zou hetzelfde herhalen
    5,
    'Auxiliary marking intention or future. Toegevoegd 2026-08-13: จะ stond al in de dialoog en werd hier al aangeleerd, maar zonder link-rij bleef het buiten het woordbudget van elke latere les.'
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
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select id from public.pattern_master where pattern_key = 'ja_verb'),
  'target',
  true,
  1,
  'จะ + VERB expresses future intention; used here to order or offer a drink.'
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
