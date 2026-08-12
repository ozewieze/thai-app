select string_agg(
         format('- %s (%s) = %s  [key: %s]',
                w->>'thai_script', w->>'paiboon',
                w->>'english_gloss', w->>'source_key'),
         E'\n' order by (w->>'intro_sequence_number')::int nulls last,
                        w->>'source_key')
from public.vocabulary_example_brief_view v,
     lateral jsonb_array_elements(v.example_vocabulary_budgets) b,
     lateral jsonb_array_elements(b->'words') w
where v.lesson_key = 'a1-dialog-05';



