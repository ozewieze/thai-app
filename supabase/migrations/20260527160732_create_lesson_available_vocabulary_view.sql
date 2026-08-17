drop view if exists public.lesson_available_vocabulary_view;

create or replace view public.lesson_available_vocabulary_view as
select
  l.id as lesson_id,
  l.lesson_key,
  l.sequence_number,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'vocabulary_id', vm.id,
        'source_key', vm.source_key,
        'thai_script', vm.thai_script,
        'paiboon', vm.paiboon,
        'english_gloss', vm.english_gloss,
        'part_of_speech', vm.part_of_speech,
        'register', vm.register,
        'status', vs.status,
        'first_lesson_id', vs.first_lesson_id,
        'last_seen_lesson_id', vs.last_seen_lesson_id
      )
      order by vs.first_lesson_id, vm.id
    )
    from public.vocabulary_status vs
    join public.vocabulary_master vm on vm.id = vs.vocabulary_id
    where vs.first_lesson_id is not null
      and vs.first_lesson_id < l.id
  ), '[]'::jsonb) as previously_introduced_vocabulary

from public.lessons l;