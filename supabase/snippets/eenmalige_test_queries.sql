select status, first_lesson_id from public.pattern_status
where pattern_id = (select id from public.pattern_master where pattern_key = 'mai_verb');