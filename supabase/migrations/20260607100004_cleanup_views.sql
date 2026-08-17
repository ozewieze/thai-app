-- Stap 5: Verwijder last_seen_lesson_id uit lesson_available_vocabulary_view
-- ============================================================
-- last_seen_lesson_id is een redundant veld: het is altijd
-- herberekend uit lesson_vocabulary en wordt niet automatisch
-- bijgehouden. Het uit de view-output verwijderen voorkomt dat
-- consumers van deze view verouderde of onjuiste data krijgen.
--
-- De kern van de view (welke woorden zijn beschikbaar voor een
-- bepaalde les?) blijft ongewijzigd.
--
-- lesson_vocabulary_control_view vereist geen aanpassingen:
-- die view bevatte last_seen_lesson_id al niet in zijn output.
-- ============================================================

drop view if exists public.lesson_available_vocabulary_view;

create or replace view public.lesson_available_vocabulary_view as
select
  l.id as lesson_id,
  l.lesson_key,
  l.sequence_number,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'vocabulary_id',  vm.id,
        'source_key',     vm.source_key,
        'thai_script',    vm.thai_script,
        'paiboon',        vm.paiboon,
        'english_gloss',  vm.english_gloss,
        'part_of_speech', vm.part_of_speech,
        'register',       vm.register,
        'status',         vs.status,
        'first_lesson_id', vs.first_lesson_id
      )
      order by vs.first_lesson_id, vm.id
    )
    from public.vocabulary_status vs
    join public.vocabulary_master vm on vm.id = vs.vocabulary_id
    where vs.first_lesson_id is not null
      and vs.first_lesson_id < l.id
  ), '[]'::jsonb) as previously_introduced_vocabulary

from public.lessons l;
