-- Stap 4: Partial unique index voor de Single Introduction Rule
-- ============================================================
-- Een woord mag slechts één keer als role = 'target' verschijnen
-- in lesson_vocabulary, over alle lessen heen.
--
-- Een gewone unique index op vocabulary_id zou te streng zijn:
-- hetzelfde woord mag wél meerdere keren als supporting, review
-- of bonus verschijnen. De WHERE-clausule beperkt de uniciteitseis
-- tot enkel de target-rijen.
--
-- Dit is het structurele vangnet op databaseniveau, bovenop de
-- trigger uit Stap 3 die dezelfde regel afdwingt met een
-- leesbare foutmelding.
-- ============================================================

create unique index uq_lesson_vocabulary_single_target
  on public.lesson_vocabulary (vocabulary_id)
  where role = 'target';
