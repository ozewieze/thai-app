insert into public.lesson_grammar (lesson_id, grammar_id, role, requires_explanation, display_order, notes)
values (
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select id from public.grammar_master where concept_key = 'adjective_after_noun'),
  'target', true, 1, 'In Thai adjectives follow the noun: กาแฟร้อน, ชาเย็น.'
);