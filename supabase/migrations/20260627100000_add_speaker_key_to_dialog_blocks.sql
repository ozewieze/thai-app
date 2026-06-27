-- ============================================================
-- Voeg speaker_key toe aan dialog_blocks
--
-- speaker_key verwijst naar character_profiles.character_key.
-- Geen FK constraint: nullable text geeft maximale flexibiliteit
-- voor functionele one-off personages (winkelbediende, ober, etc.)
-- die wel in character_profiles staan maar geen vaste relatie hebben.
--
-- De backfill hieronder is een EENMALIGE operatie voor de 19
-- bestaande rijen. Alle toekomstige inserts bevatten speaker_key
-- expliciet in het seed-bestand.
-- ============================================================

alter table public.dialog_blocks
add column speaker_key text;

-- Backfill: leid speaker_key af uit het character-prefix in thai_text.
-- Formaat is altijd "CharacterName: spoken text" (zie seed-bestanden).
update public.dialog_blocks
set speaker_key = case
  when thai_text like 'มะลิ:%'  then 'mali'
  when thai_text like 'นริน:%' then 'narin'
end
where speaker_key is null;
