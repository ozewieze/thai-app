-- ============================================================
-- service_role heeft al GRANT SELECT op dialogs
-- (zie 20260627110000_grant_service_role_read_access.sql),
-- maar mist UPDATE.
--
-- scripts/merge-audio.mjs werkt als service_role en moet
-- dialogs.audio_url kunnen bijwerken na het samenvoegen
-- van per-blok MP3s tot een full-dialog audiobestand.
-- ============================================================

grant update on public.dialogs to service_role;
