-- ============================================================
-- Vervolg op 20260812090000: de brief-views zelf waren gegrant, hun
-- brontabellen niet allemaal.
--
-- Waarom een grant op de view niet volstaat: beide views zijn
-- `security_invoker = true` (zie 20260731120000 regel 46 en
-- 20260807120000 regel 136, de conventie voor alle views in dit
-- project). Postgres toetst de rechten dan op de *aanroeper* tegen de
-- onderliggende tabellen, niet op de eigenaar van de view. Toegang tot
-- de view is dus nodig én onvoldoende:
--
--   permission denied for table lesson_vocabulary
--
-- Dat is precies de bedoeling van security_invoker -- een view mag geen
-- achterdeur zijn naar tabellen waar je niets te zoeken hebt -- maar het
-- betekent dat een leesrecht op een view altijd samen moet gaan met
-- leesrecht op alles wat hij leest.
--
-- De twee views lezen samen twaalf tabellen. Acht daarvan had
-- service_role al, via 20260627110000, 20260713120000, 20260716120000
-- en 20260716120100. Deze vier ontbraken:
--
--   language_note_brief_view      -> lesson_vocabulary, lesson_grammar,
--                                    vocabulary_status
--   vocabulary_example_brief_view -> lesson_vocabulary, vocabulary_status,
--                                    vocabulary_examples
--
-- Alleen SELECT. scripts/fill-note-prompt.mjs leest en schrijft nooit;
-- het schrijven naar deze tabellen gebeurt via seedbestanden met psql,
-- niet via PostgREST.
--
-- LET OP bij toekomstige views: dezelfde valkuil ligt klaar. Een nieuwe
-- authoring-view die een tabel toevoegt, heeft opnieuw een grant nodig
-- op díe tabel. De vraag is niet "mag de rol bij de view" maar "mag de
-- rol bij alles wat de view aanraakt".
-- ============================================================

grant select on public.lesson_vocabulary   to service_role;
grant select on public.lesson_grammar      to service_role;
grant select on public.vocabulary_status   to service_role;
grant select on public.vocabulary_examples to service_role;
