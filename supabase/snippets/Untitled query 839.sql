select
  lesson_key,
  jsonb_array_length(all_vocabulary) as vocabulary_count,
  jsonb_array_length(all_phrases) as phrase_count,
  jsonb_array_length(all_grammar) as grammar_count,
  jsonb_array_length(all_patterns) as pattern_count
from public.lesson_blueprint_view
where lesson_key = 'lesson_01';