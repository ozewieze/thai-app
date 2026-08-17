-- Stap 2: Initialisatietrigger op vocabulary_master
-- ============================================================
-- Telkens wanneer een nieuw woord wordt ingevoegd in
-- vocabulary_master, maakt deze trigger automatisch een
-- corresponderende rij aan in vocabulary_status met status = 'new'.
--
-- Dit zorgt ervoor dat de volledige dekking van vocabulary_status
-- (hersteld in Stap 1) nooit meer kan breken voor nieuwe woorden.
-- ============================================================

create or replace function public.fn_initialize_vocabulary_status()
returns trigger
language plpgsql
as $$
begin
  insert into public.vocabulary_status (vocabulary_id, status)
  values (new.id, 'new');

  return new;
end;
$$;

create trigger trg_initialize_vocabulary_status
after insert on public.vocabulary_master
for each row
execute function public.fn_initialize_vocabulary_status();
