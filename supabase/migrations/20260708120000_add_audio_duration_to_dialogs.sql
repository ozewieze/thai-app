begin;

-- =========================================================
-- audio_duration_ms op dialogs
-- Exacte totale duur (in milliseconden) van de samengevoegde
-- full-dialog audio, berekend en gezet door scripts/merge-audio.mjs
-- (dezelfde "cursor"-waarde die al gebruikt wordt voor de
-- tijdlijn-log). Voorkomt dat de browser deze duur zelf uit het
-- MP3-bestand moet destilleren — bij bestanden die via
-- `ffmpeg -c copy` zijn samengevoegd, is die browser-berekening
-- onbetrouwbaar (soms NaN/Infinity, zie FullDialogPlayer.tsx).
-- Nullable: bestaande dialogen die vóór deze migratie al
-- samengevoegd zijn, krijgen deze waarde pas bij een nieuwe
-- (--force) merge-run.
-- =========================================================

alter table public.dialogs
  add column audio_duration_ms integer;

commit;
