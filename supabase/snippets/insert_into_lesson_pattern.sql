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
  (select id from public.pattern_master where pattern_key = 'mai_verb'),
  'target',
  true,
  1,
  'Negates an action or state.'
);