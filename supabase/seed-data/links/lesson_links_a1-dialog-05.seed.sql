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
    true,
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
    true,
    3,
    ''
  ),
      (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'sweet'),
    'target',
    true,
    4,
    ''
  ),
      (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'often'),
    'target',
    true,
    5,
    ''
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

