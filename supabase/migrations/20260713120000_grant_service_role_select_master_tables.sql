-- ============================================================
-- service_role mist SELECT op vocabulary_master, grammar_master
-- en pattern_master (alleen anon/authenticated zijn gegrant, zie
-- 20260617120000_grant_api_access.sql).
--
-- Deze grant is nodig voor scripts/export-vocabulary-master.mjs,
-- scripts/export-grammar-master.mjs en scripts/export-pattern-master.mjs
-- (de DB-to-CSV sync-scripts, zie docs/thai_a1_dialog_workflow_guide.md),
-- die via PostgREST met de service-rolesleutel de huidige
-- mastertabelinhoud uitlezen.
--
-- service_role bypast RLS maar heeft nog steeds expliciete
-- GRANT nodig voor toegang via PostgREST.
-- ============================================================

grant select on public.vocabulary_master to service_role;
grant select on public.grammar_master to service_role;
grant select on public.pattern_master to service_role;
