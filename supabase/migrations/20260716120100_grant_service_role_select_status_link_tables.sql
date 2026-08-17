-- ============================================================
-- Zelfde omissie als phrase_master (zie
-- 20260716120000_grant_service_role_select_phrase_master.sql):
-- service_role mist ook SELECT op phrase_status, lesson_phrase,
-- pattern_status en lesson_pattern (alleen anon/authenticated zijn
-- gegrant, zie 20260617120000_grant_api_access.sql).
--
-- Geen script gebruikt deze grant vandaag, maar het is dezelfde
-- structurele gap als bij de mastertabellen -- preventief gedicht
-- zodat een toekomstig sync- of debug-script via de service-rolesleutel
-- niet opnieuw op "permission denied" botst.
--
-- service_role bypast RLS maar heeft nog steeds expliciete
-- GRANT nodig voor toegang via PostgREST.
-- ============================================================

grant select on public.phrase_status  to service_role;
grant select on public.lesson_phrase  to service_role;
grant select on public.pattern_status to service_role;
grant select on public.lesson_pattern to service_role;
