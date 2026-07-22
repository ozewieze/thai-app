begin;

-- =========================================================
-- Principle of least privilege voor dialog_blocks en
-- dialog_slides.
--
-- De create-migraties van deze twee tabellen gaven
-- 'grant all' (incl. sequences) aan anon, authenticated en
-- service_role. Dat was ruimer dan nodig en week af van de
-- projectconventie (grant_api_access en de incrementele
-- grant_service_role_*-migraties geven per rol exact wat
-- nodig is).
--
-- Werkelijke behoefte, geverifieerd tegen de scripts
-- (2026-07-22):
--   - anon/authenticated: alleen SELECT (RLS beperkt verder
--     tot published lessons; er bestaan geen write-policies)
--   - service_role (bypasst RLS, dus grants zijn hier de
--     enige poort):
--       dialog_blocks: SELECT + UPDATE
--         (generate-audio.mjs: audio_url;
--          merge-audio.mjs: full_start_ms/full_end_ms)
--       dialog_slides: SELECT + UPDATE
--         (upload-slides.mjs: image_url/updated_at, en
--          nested select via dialogs)
--   - sequences: niemand; INSERTs gebeuren uitsluitend via
--     seeds/migraties als postgres, en alleen een
--     INSERTende rol heeft sequence-USAGE nodig
-- =========================================================

-- schone lei
revoke all on table public.dialog_blocks from anon, authenticated, service_role;
revoke all on table public.dialog_slides from anon, authenticated, service_role;

revoke all on sequence public.dialog_blocks_id_seq from anon, authenticated, service_role;
revoke all on sequence public.dialog_slides_id_seq from anon, authenticated, service_role;

-- minimale rechten terug
grant select on table public.dialog_blocks to anon, authenticated;
grant select on table public.dialog_slides to anon, authenticated;

grant select, update on table public.dialog_blocks to service_role;
grant select, update on table public.dialog_slides to service_role;

commit;
