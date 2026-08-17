-- ============================================================
-- Rechten voor de audiostap op lemma's en voorbeelden.
--
-- Drie scripts gaan als service_role via PostgREST lezen en
-- schrijven: scripts/generate-lemma-audio.mjs,
-- scripts/generate-vocab-example-audio.mjs en
-- scripts/generate-note-example-audio.mjs. Ze lezen de rijen
-- zonder audio, zetten een MP3 in de 'audio'-bucket, en
-- schrijven audio_url en voice_key terug.
--
-- Conform de grant_service_role_*-reeks: rechten volgen per
-- concrete scriptbehoefte, in een eigen migratie, en niet
-- vooruit. 20260721120000 en 20260722130000 hielden de rechten
-- op deze tabellen daarom bewust achter tot dit moment; die
-- twee koppen verwijzen er expliciet naar.
--
-- service_role bypast RLS maar heeft nog steeds een expliciete
-- GRANT nodig voor toegang via PostgREST.
-- ============================================================


-- ============================================================
-- 1. SELECT op de Language Note-keten
--
-- De drie tabellen waren nog volledig ongegrant voor
-- service_role. Alle drie zijn nodig, en niet alleen de
-- onderste:
--
--   language_note_examples  de rijen zelf (thai_script,
--                           audio_url, voice_key)
--   language_note_blocks    block_key, voor het opslagpad
--   language_notes          note_key, voor het opslagpad
--
-- Waarom de sleutels en niet de id's: het opslagpad wordt uit
-- natuurlijke sleutels opgebouwd, zodat hetzelfde voorbeeld na
-- een db reset op hetzelfde pad terechtkomt. Identity-id's
-- worden bij een herbouw opnieuw uitgedeeld en zijn daarvoor
-- onbruikbaar.
--
-- lessons staat er niet bij, en dat is geen omissie:
-- note_key luidt 'a1-dialog-01-note-1' en draagt de lesleutel
-- dus al. De lesgroepering in de opslag is een gevolg van de
-- sleutel, niet van een join.
--
-- vocabulary_master (20260713120000) en vocabulary_examples
-- (20260812093000) hebben hun SELECT al; die staan hier niet
-- nog een keer.
-- ============================================================

grant select on public.language_notes         to service_role;
grant select on public.language_note_blocks   to service_role;
grant select on public.language_note_examples to service_role;


-- ============================================================
-- 2. UPDATE, uitsluitend op de twee audiokolommen
--
-- Waarom kolomspecifiek en niet tabelbreed, zoals
-- 20260629100001 dat voor dialogs deed. Twee van deze drie
-- tabellen worden redactioneel beheerd via seedbestanden, en
-- vocabulary_master is DB-first. De tekstkolommen hebben dus
-- een andere eigenaar dan de audiokolommen. Een tabelbrede
-- UPDATE zou het audioscript de macht geven thai_script of
-- paiboon te overschrijven -- een typfout in een .update({...})
-- ver -- en die schade is stil: het seedbestand herstelt haar
-- pas bij de volgende db reset, en tot dan staat er andere
-- tekst dan de redactie heeft goedgekeurd.
--
-- dialogs had die spanning niet: daar is het script de enige
-- schrijver en zijn er geen door seeds beheerde tekstkolommen.
--
-- LET OP bij een toekomstige kolom. Wordt hier ooit iets als
-- audio_duration toegevoegd (zoals bij dialogs is gebeurd, zie
-- 20260708120000), dan faalt het audioscript met
--
--   permission denied for column audio_duration
--
-- en niet met iets wat naar deze migratie wijst. De grant moet
-- dan mee uitgebreid worden. Dat is de prijs van kolomniveau,
-- en hij wordt hier bewust betaald: de melding is luid, en een
-- stille tekstoverschrijving zou dat niet zijn.
--
-- Geen sequence-grants: UPDATE raakt geen sequence, alleen
-- INSERT doet dat, en geen van deze rollen mag inserten.
--
-- anon en authenticated blijven select-only. Zij lezen
-- audio_url om af te spelen; schrijven doet alleen het script.
-- ============================================================

grant update (audio_url, voice_key) on public.vocabulary_master      to service_role;
grant update (audio_url, voice_key) on public.vocabulary_examples    to service_role;
grant update (audio_url, voice_key) on public.language_note_examples to service_role;


-- ============================================================
-- 3. De opslagkant vraagt niets
--
-- Genoteerd zodat de vraag niet opnieuw gesteld hoeft te
-- worden. De 'audio'-bucket bestaat al (20260626140000), staat
-- op public met een SELECT-policy voor anon en authenticated,
-- accepteert audio/mpeg en heeft een limiet van 50 MB per
-- bestand. Uploaden gebeurt door service_role, die RLS op
-- storage.objects bypast -- daar is geen policy en geen grant
-- voor nodig. Dat is precies zoals scripts/generate-audio.mjs
-- vandaag al werkt.
-- ============================================================
