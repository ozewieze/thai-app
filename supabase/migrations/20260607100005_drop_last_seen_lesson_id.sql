-- Stap 6: Verwijder last_seen_lesson_id uit alle status-tabellen
-- ============================================================
-- last_seen_lesson_id is een afgeleide waarde die altijd
-- herberekend kan worden uit de koppeltabellen (lesson_vocabulary,
-- lesson_grammar, lesson_phrase, lesson_pattern).
--
-- Het opslaan ervan creëert een synchronisatierisico: de waarde
-- kan verouderd raken zonder dat de database dit signaleert.
--
-- Per tabel: eerst de foreign key constraint droppen,
-- dan de kolom zelf.
-- ============================================================

-- vocabulary_status
alter table public.vocabulary_status
  drop constraint vocabulary_status_last_seen_lesson_fk;

alter table public.vocabulary_status
  drop column last_seen_lesson_id;

-- grammar_status
alter table public.grammar_status
  drop constraint grammar_status_last_seen_lesson_fk;

alter table public.grammar_status
  drop column last_seen_lesson_id;

-- phrase_status
alter table public.phrase_status
  drop constraint phrase_status_last_seen_lesson_fk;

alter table public.phrase_status
  drop column last_seen_lesson_id;

-- pattern_status
alter table public.pattern_status
  drop constraint pattern_status_last_seen_lesson_fk;

alter table public.pattern_status
  drop column last_seen_lesson_id;
