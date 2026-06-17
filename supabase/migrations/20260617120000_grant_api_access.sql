-- Grant SELECT via de Data API (PostgREST) aan anon en authenticated.
-- Zonder deze grants toont Supabase Studio "API DISABLED" op elke tabel
-- en geeft PostgREST "permission denied" terug, ook als RLS correct is.
-- Nieuwere Supabase-versies kennen deze rechten niet meer automatisch toe.


-- =========================================================
-- lessons
-- =========================================================
grant select on public.lessons to anon, authenticated;


-- =========================================================
-- dialogs
-- =========================================================
grant select on public.dialogs to anon, authenticated;


-- =========================================================
-- revisions
-- =========================================================
grant select on public.revisions to anon, authenticated;


-- =========================================================
-- vocabulary_master / vocabulary_status / lesson_vocabulary
-- =========================================================
grant select on public.vocabulary_master  to anon, authenticated;
grant select on public.vocabulary_status  to anon, authenticated;
grant select on public.lesson_vocabulary  to anon, authenticated;


-- =========================================================
-- grammar_master / grammar_status / lesson_grammar
-- =========================================================
grant select on public.grammar_master  to anon, authenticated;
grant select on public.grammar_status  to anon, authenticated;
grant select on public.lesson_grammar  to anon, authenticated;


-- =========================================================
-- pattern_master / pattern_status / lesson_pattern
-- =========================================================
grant select on public.pattern_master  to anon, authenticated;
grant select on public.pattern_status  to anon, authenticated;
grant select on public.lesson_pattern  to anon, authenticated;


-- =========================================================
-- phrase_master / phrase_status / lesson_phrase
-- =========================================================
grant select on public.phrase_master  to anon, authenticated;
grant select on public.phrase_status  to anon, authenticated;
grant select on public.lesson_phrase  to anon, authenticated;


-- =========================================================
-- character_profiles / relationship_pairs / relationship_pair_rules
-- =========================================================
grant select on public.character_profiles      to anon, authenticated;
grant select on public.relationship_pairs      to anon, authenticated;
grant select on public.relationship_pair_rules to anon, authenticated;


-- =========================================================
-- dialog_blueprint_specs
-- =========================================================
grant select on public.dialog_blueprint_specs to anon, authenticated;
