insert into public.lesson_grammar (
  lesson_id,
  grammar_id,
  role,
  requires_explanation,
  display_order,
  notes
)
values (
  (select id from public.lessons where lesson_key = 'a1-dialog-02'),
  (select id from public.grammar_master where concept_key = 'movement_pai'),
  'target',
  true,
  2,
  'Use ไป with a place or verb to show movement away or going to do something.'
);