-- ============================================================
-- Voeg speaker_key toe aan dialog_blocks
--
-- speaker_key verwijst naar character_profiles.character_key.
-- Geen FK constraint: nullable text geeft maximale flexibiliteit
-- voor functionele one-off personages (winkelbediende, ober, etc.)
-- die wel in character_profiles staan maar geen vaste relatie hebben.

-- ============================================================

alter table public.dialog_blocks
add column speaker_key text;
