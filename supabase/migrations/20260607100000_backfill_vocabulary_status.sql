-- Stap 1: Backfill vocabulary_status
-- ============================================================
-- Voor elk woord in vocabulary_master dat nog geen rij heeft
-- in vocabulary_status, maak een rij aan met status = 'new'.
--
-- Dit is een eenmalige correctie. Na Stap 2 (initialisatietrigger)
-- kan dit nooit meer nodig zijn voor nieuwe woorden.
-- ============================================================

insert into public.vocabulary_status (vocabulary_id, status)
select vm.id, 'new'
from public.vocabulary_master vm
where not exists (
  select 1
  from public.vocabulary_status vs
  where vs.vocabulary_id = vm.id
);
