-- ============================================================
-- service_role mist SELECT op phrase_master (alleen anon/authenticated
-- zijn gegrant, zie 20260617120000_grant_api_access.sql).
--
-- Dezelfde omissie als vocabulary_master/grammar_master/pattern_master,
-- gefixt in 20260713120000_grant_service_role_select_master_tables.sql
-- -- phrase_master werd daar per ongeluk niet meegenomen.
--
-- Deze grant is nodig voor scripts/export-phrase-master.mjs
-- (de DB-to-CSV sync-script, zie docs/thai_a1_dialog_workflow_guide.md),
-- die via PostgREST met de service-rolesleutel de huidige
-- phrase_master-inhoud uitleest.
--
-- service_role bypast RLS maar heeft nog steeds expliciete
-- GRANT nodig voor toegang via PostgREST.
-- ============================================================

grant select on public.phrase_master to service_role;
