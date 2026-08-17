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
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'like'),
    'target',
    false,
    1,
    'also commonly expresses preference'
  ),
    (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'eat'),
    'target',
    true,
    2,
    'also often used for drink in everyday speech'
  ),
      (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'delicious'),
    'target',
    false,
    3,
    ''
  ),
      (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'sweet'),
    'target',
    false,
    4,
    ''
  ),
      (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'often'),
    'target',
    false,
    5,
    'placement after the verb is explained by adverbs_after_verbs_and_adjectives'
  ),
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'very'),
    'target',
    false,
    6,
    'placement after the verb or adjective is explained by adverbs_after_verbs_and_adjectives'
  )

on conflict (lesson_id, vocabulary_id) do update
set role                 = excluded.role,
    requires_explanation = excluded.requires_explanation,
    display_order        = excluded.display_order,
    notes                = excluded.notes;
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
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.grammar_master where concept_key = 'adverbs_after_verbs_and_adjectives'),
    'target',
    true,
    1,
    'In Thai, many common adverbs such as บ่อย and มาก come after the verb or adjective'
  )

on conflict (lesson_id, grammar_id) do update
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
values
  (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.pattern_master where pattern_key = 'chop_noun'),
    'target',
    true,
    1,
    'ชอบ followed by a thing or category. Only the noun form occurs in this dialogue; chop_verb is kept for a later lesson that can anchor it.'
  )

on conflict (lesson_id, pattern_id) do update
set role                 = excluded.role,
    requires_explanation = excluded.requires_explanation,
    display_order        = excluded.display_order,
    notes                = excluded.notes;
