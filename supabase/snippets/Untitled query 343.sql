update public.lesson_vocabulary
set vocabulary_id = (select id from public.vocabulary_master where source_key = 'can' limit 1),
    notes = 'Modal verb for ability, possibility, and permission; also marks completed actions.'
where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-02')
  and display_order = 5;