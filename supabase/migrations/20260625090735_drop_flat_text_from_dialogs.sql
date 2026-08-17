begin;

-- =========================================================
-- remove flat text columns from dialogs
-- dialog content now lives in dialog_blocks (one row per block)
-- =========================================================

alter table public.dialogs
  drop column thai_text,
  drop column transliteration,
  drop column translation_en;

commit;
