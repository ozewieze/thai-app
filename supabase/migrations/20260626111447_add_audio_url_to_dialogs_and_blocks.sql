begin;

-- =========================================================
-- audio_url op dialog_blocks
-- per-blok audio (studietool, fase 1: AI-gegenereerd)
-- =========================================================

alter table public.dialog_blocks
  add column audio_url text;

-- =========================================================
-- audio_url op dialogs
-- volledige dialoog audio (fase 2: voice actors + montage)
-- =========================================================

alter table public.dialogs
  add column audio_url text;

commit;
