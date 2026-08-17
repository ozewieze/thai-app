-- ============================================================
-- service_role heeft GRANT ALL op dialog_blocks
-- (zie 20260625090652_create_dialog_blocks_table.sql),
-- maar mist SELECT op dialogs en lessons.
--
-- Deze grants zijn nodig voor server-side scripts (bijv. het
-- TTS-generatiescript) die via PostgREST een geneste join
-- uitvoeren van dialog_blocks → dialogs → lessons.
--
-- service_role bypast RLS maar heeft nog steeds expliciete
-- GRANT nodig voor toegang via PostgREST.
-- ============================================================

grant select on public.dialogs to service_role;
grant select on public.lessons to service_role;
