-- Migratie: NOT NULL constraint op lessons.sequence_number
-- ============================================================
-- sequence_number is de curriculaire positie van een les en wordt gebruikt
-- in lesson_available_vocabulary_view om te bepalen welke woorden al gekend
-- zijn door de leerling (intro.sequence_number < l.sequence_number).
--
-- Een NULL-waarde in sequence_number geeft stilzwijgend een lege
-- previously_introduced_vocabulary terug, zonder foutmelding. Dit risico
-- wordt hier weggenomen door de kolom NOT NULL te maken.
--
-- Veiligheid: alle bestaande lessen in de seed hebben een expliciete
-- sequence_number. De constraint kan onmiddellijk worden toegevoegd.
-- ============================================================

alter table public.lessons
  alter column sequence_number set not null;
