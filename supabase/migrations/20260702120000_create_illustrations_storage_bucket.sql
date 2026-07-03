begin;

-- =========================================================
-- Storage bucket: illustrations
--
-- Doel: container voor alle illustratie-afbeeldingen van het
-- platform (dialoogslides, hero images, lesillustraties).
-- Structuur: illustrations/dialogs/{level}/{dialog-slug}/slides/slide-{nn}.png
--
-- Waarom een eigen bucket, gescheiden van 'audio':
--   - De bestaande 'audio'-bucket staat alleen audio-mimetypes
--     toe (audio/mpeg, audio/mp4, audio/ogg, audio/wav) en zou
--     een afbeelding-upload weigeren.
--   - Audio en beeld hebben een eigen levenscyclus (audio wordt
--     automatisch samengevoegd via merge-audio.mjs, beeld wordt
--     per slide extern gegenereerd en handmatig gecureerd).
--   - Zie docs/illustration-system/05_storage_strategy.md voor
--     de volledige motivatie.
--
-- Toegangsmodel:
--   - Lezen: iedereen (anon + authenticated) — illustraties zijn
--     publieke content, zelfde patroon als de audio-bucket
--   - Uploaden/wijzigen/verwijderen: alleen service_role
--     (admin-scripts / handmatige upload via Studio)
--     service_role bypast RLS automatisch, dus geen aparte policy nodig
-- =========================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'illustrations',
  'illustrations',
  true,
  10485760,  -- 10 MB per bestand
  array['image/png', 'image/jpeg', 'image/webp']
)
on conflict (id) do nothing;

-- =========================================================
-- RLS-beleid: publiek lezen
--
-- Waarom: ook al is de bucket 'public', Supabase vereist
-- een expliciete RLS-policy op storage.objects voor SELECT.
-- Zonder deze policy kunnen anonieme gebruikers geen
-- illustraties tonen via de Storage API-URL.
-- =========================================================

create policy "Publiek lezen van illustratie-afbeeldingen"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'illustrations');

commit;
