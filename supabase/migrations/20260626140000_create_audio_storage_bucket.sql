begin;

-- =========================================================
-- Storage bucket: audio
--
-- Doel: container voor alle audio-bestanden van het platform
-- Structuur: audio/dialogs/{level}/{dialog-slug}/blocks/block-{nn}.mp3
--
-- Toegangsmodel:
--   - Lezen: iedereen (anon + authenticated) — audio is publieke content
--   - Uploaden/wijzigen/verwijderen: alleen service_role (admin-scripts)
--     service_role bypast RLS automatisch, dus geen aparte policy nodig
-- =========================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'audio',
  'audio',
  true,
  52428800,  -- 50 MB per bestand
  array['audio/mpeg', 'audio/mp4', 'audio/ogg', 'audio/wav']
)
on conflict (id) do nothing;

-- =========================================================
-- RLS-beleid: publiek lezen
--
-- Waarom: ook al is de bucket 'public', Supabase vereist
-- een expliciete RLS-policy op storage.objects voor SELECT.
-- Zonder deze policy kunnen anonieme gebruikers geen audio
-- afspelen via de Storage API-URL.
-- =========================================================

create policy "Publiek lezen van audio-bestanden"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'audio');

commit;
