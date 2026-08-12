select string_agg(
         format('- %s (%s) = %s  [key: %s]  ·  %s%s',
                w->>'thai_script', w->>'paiboon',
                w->>'english_gloss', w->>'source_key',
                w->>'part_of_speech',
                case when w->>'usage_note' is null then ''
                     else '  ·  ' || (w->>'usage_note') end),
         E'\n' order by (w->>'display_order')::int nulls first)
from public.vocabulary_example_brief_view v,
     lateral jsonb_array_elements(v.target_words) w
where v.lesson_key = 'a1-dialog-04'
  and (w->>'needs_example')::boolean;

