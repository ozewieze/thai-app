-- Stap 7: Herbouw lesson_available_vocabulary_view op basis van sequence_number
-- ============================================================
-- De vorige versie vergeleek vs.first_lesson_id < l.id (database-ID).
-- Dit werkt alleen als lessen altijd in curriculum-volgorde worden ingevoegd.
-- Als een les later wordt verwijderd en opnieuw aangemaakt, kan de auto-increment
-- ID afwijken van de curriculum-positie, waardoor de filter verkeerde resultaten geeft.
--
-- De robuuste versie vergelijkt op sequence_number: de curriculaire positie.
-- Dit vereist een extra join op de lessons-tabel (als alias 'intro') om het
-- sequence_number van de introductieles op te halen.
--
-- Wijzigingen t.o.v. vorige versie:
--   - Join op lessons intro om sequence_number van de introductieles te kennen
--   - Filter: intro.sequence_number < l.sequence_number  (i.p.v. < l.id)
--   - intro_sequence_number toegevoegd aan jsonb voor sortering in laterals
--   - Sortering: intro.sequence_number, vm.id  (i.p.v. first_lesson_id, vm.id)
--
-- Afhankelijkheid: vereist dat last_seen_lesson_id al verwijderd is
-- (migratie 20260607100005).
-- ============================================================

drop view if exists public.lesson_available_vocabulary_view;

create or replace view public.lesson_available_vocabulary_view as
select
  l.id             as lesson_id,
  l.lesson_key,
  l.sequence_number,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'vocabulary_id',        vm.id,
        'source_key',           vm.source_key,
        'thai_script',          vm.thai_script,
        'paiboon',              vm.paiboon,
        'english_gloss',        vm.english_gloss,
        'part_of_speech',       vm.part_of_speech,
        'register',             vm.register,
        'status',               vs.status,
        'first_lesson_id',      vs.first_lesson_id,
        'intro_sequence_number', intro.sequence_number
      )
      order by intro.sequence_number, vm.id
    )
    from public.vocabulary_status vs
    join public.vocabulary_master vm    on vm.id    = vs.vocabulary_id
    join public.lessons           intro on intro.id = vs.first_lesson_id
    where vs.first_lesson_id is not null
      and intro.sequence_number < l.sequence_number
  ), '[]'::jsonb) as previously_introduced_vocabulary

from public.lessons l;
