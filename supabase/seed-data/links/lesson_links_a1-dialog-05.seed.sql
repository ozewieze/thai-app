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
    (select id from public.vocabulary_master where source_key = 'like' limit 1),
    'target',
    true,
    1,
    'also commonly expresses preference'
  ),
    (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'eat' limit 1),
    'target',
    true,
    2,
    'also often used for drink in everyday speech'
  ),
      (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'delicious' limit 1),
    'target',
    true,
    3,
    ''
  ),
      (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'sweet' limit 1),
    'target',
    true,
    4,
    ''
  ),
      (
    (select id from public.lessons where lesson_key = 'a1-dialog-05'),
    (select id from public.vocabulary_master where source_key = 'often' limit 1),
    'target',
    true,
    5,
    ''
  )
;
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
    (select id from public.grammar_master where concept_key = 'adverbs_after_verbs_and_adjectives' limit 1),
    'target',
    true,
    1,
    'In Thai, many common adverbs such as บ่อย and มาก come after the verb or adjective'
  )  
;

