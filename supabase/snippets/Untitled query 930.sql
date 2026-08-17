select string_agg(
         format('%s: %s / %s / %s',
                b->>'speaker_key', b->>'thai_text',
                b->>'transliteration', b->>'translation_en'),
         E'\n' order by (b->>'block_index')::int)
from public.language_note_brief_view v,
     lateral jsonb_array_elements(v.dialog->'blocks') b
where v.lesson_key = 'a1-dialog-02';