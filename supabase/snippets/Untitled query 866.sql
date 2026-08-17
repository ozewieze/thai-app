select previously_introduced_vocabulary
from public.lesson_available_vocabulary_view
where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-02');