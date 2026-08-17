select
  l.lesson_key,
  g.concept_key,
  g.title,
  lg.requires_explanation,
  lg.display_order
from public.lesson_grammar lg
join public.lessons l on l.id = lg.lesson_id
join public.grammar_master g on g.id = lg.grammar_id
where l.lesson_key = 'a1-dialog-01';