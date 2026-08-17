-- ============================================================
-- Rechten op de twee brief-views rechtzetten: service_role erbij,
-- anon en authenticated eraf.
--
-- Dezelfde omissie als bij phrase_master en de statustabellen (zie
-- 20260716120000 en 20260716120100): de twee brief-views zijn alleen
-- aan anon en authenticated gegrant.
--
--   20260731120000_create_language_note_brief_view.sql:297
--     grant select on table public.language_note_brief_view to anon, authenticated;
--   20260807120000_create_vocabulary_example_brief_view.sql:348
--     grant select on table public.vocabulary_example_brief_view to anon, authenticated;
--
-- Anders dan die eerdere twee is dit geen preventieve reparatie: er is
-- een script dat erop stukloopt. scripts/fill-note-prompt.mjs leest deze
-- views via de service-rolesleutel om prompttemplates te vullen, en
-- faalde op:
--
--   FOUT bij het lezen van language_note_brief_view:
--   permission denied for view language_note_brief_view
--
-- service_role bypast RLS maar heeft nog steeds een expliciete GRANT
-- nodig voor toegang via PostgREST. Alleen SELECT: het script leest en
-- schrijft nooit.
--
-- Tegelijk gaan anon en authenticated eraf. Dit zijn auteursviews, geen
-- leerlingdata: ze bevatten de volledige dialoogtekst, de conceptlijsten
-- met hun koppelrij-id's en het woordbudget van de les. De frontend
-- gebruikt ze niet -- gecontroleerd over de hele codebase, ze komen
-- alleen voor in scripts, QA-bestanden, prompttemplates en documentatie,
-- in geen enkel .ts- of .tsx-bestand. Ze aan anon granten betekende dat
-- ze zonder inloggen via de publieke API te lezen waren; via
-- authenticated gold hetzelfde voor elke ingelogde leerling.
--
-- Na deze migratie zijn beide views alleen nog bereikbaar met de
-- service-rolesleutel, en dat is precies de doelgroep: de authoring-
-- scripts. Zie ook 20260617120000_grant_api_access.sql, waar de
-- oorspronkelijke anon/authenticated-conventie vandaan komt -- die is
-- bedoeld voor tabellen die de lespagina rendert, en deze views vielen
-- er ten onrechte onder.
-- ============================================================

grant select on public.language_note_brief_view      to service_role;
grant select on public.vocabulary_example_brief_view to service_role;

revoke select on public.language_note_brief_view      from anon, authenticated;
revoke select on public.vocabulary_example_brief_view from anon, authenticated;
