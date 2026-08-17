drop view if exists public.lesson_vocabulary_control_view;

create or replace view public.lesson_vocabulary_control_view as
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
        'lesson_role', lv.role,
        'display_order', lv.display_order,
        'requires_explanation', lv.requires_explanation,
        'lesson_notes', lv.notes,
        'status', vs.status,
        'first_lesson_id', vs.first_lesson_id
      )
      order by lv.display_order nulls first, lv.id
    )
    from public.lesson_vocabulary lv
    join public.vocabulary_master vm
      on vm.id = lv.vocabulary_id
    join public.vocabulary_status vs
      on vs.vocabulary_id = vm.id
    where lv.lesson_id = l.id
      and vs.first_lesson_id = l.id
  ), '[]'::jsonb) as new_vocabulary,

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
        'lesson_role', lv.role,
        'display_order', lv.display_order,
        'requires_explanation', lv.requires_explanation,
        'lesson_notes', lv.notes,
        'status', vs.status,
        'first_lesson_id', vs.first_lesson_id
      )
      order by vs.first_lesson_id, lv.display_order nulls first, lv.id
    )
    from public.lesson_vocabulary lv
    join public.vocabulary_master vm
      on vm.id = lv.vocabulary_id
    join public.vocabulary_status vs
      on vs.vocabulary_id = vm.id
    where lv.lesson_id = l.id
      and vs.first_lesson_id is not null
      and vs.first_lesson_id < l.id
  ), '[]'::jsonb) as linked_previous_vocabulary

from public.lessons l;