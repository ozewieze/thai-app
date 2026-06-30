begin;

-- =========================================================
-- full_start_ms / full_end_ms op dialog_blocks
--
-- Tijdstippen (milliseconden) van elk blok binnen de
-- samengevoegde full-dialog audio (dialogs.audio_url).
-- Worden ingevuld door scripts/merge-audio.mjs.
-- Zijn null zolang de full dialog audio nog niet bestaat.
--
-- Losstaan van audio_url (= per-blok audio): die twee
-- kolommen zijn volledig onafhankelijk van elkaar.
-- =========================================================

alter table public.dialog_blocks
  add column full_start_ms integer,
  add column full_end_ms   integer;

-- =========================================================
-- dialog_slides
--
-- Één rij per visuele slide van een dialoog.
-- Een slide kan één of meerdere aaneengesloten blokken
-- beslaan: first_block_index t/m last_block_index.
--
-- image_url verwijst naar Supabase Storage (bucket 'audio').
-- Wordt ingevuld door scripts/upload-slides.mjs.
--
-- De starttijd van een slide = full_start_ms van het blok
-- met block_index = first_block_index.
-- De eindtijd     = full_end_ms   van het blok
-- met block_index = last_block_index.
-- Er worden geen aparte timestamps opgeslagen: dialog_blocks
-- is de enige bron van waarheid voor tijdstippen.
-- =========================================================

create table public.dialog_slides (
  id                bigint generated always as identity primary key,
  dialog_id         bigint      not null,
  slide_index       integer     not null,
  first_block_index integer     not null,
  last_block_index  integer     not null,
  image_url         text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),

  -- één slide per positie per dialoog
  constraint dialog_slides_dialog_slide_unique
    unique (dialog_id, slide_index), 

  constraint dialog_slides_dialog_fk
    foreign key (dialog_id)
    references public.dialogs (id)
    on delete cascade,

  -- last >= first: een slide loopt altijd vooruit
  constraint dialog_slides_block_order_check
    check (last_block_index >= first_block_index),

  constraint dialog_slides_slide_index_check
    check (slide_index >= 0),

  constraint dialog_slides_first_block_index_check
    check (first_block_index >= 0)
);

-- =========================================================
-- RLS
-- Zelfde patroon als dialog_blocks: leesbaar voor iedereen
-- zodra de bovenliggende les gepubliceerd is.
-- =========================================================

alter table public.dialog_slides enable row level security;

create policy "Slides of published dialogs are readable by everyone"
on public.dialog_slides
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.dialogs d
    join public.lessons l on l.id = d.lesson_id
    where d.id = dialog_slides.dialog_id
      and l.is_published = true
  )
);

-- =========================================================
-- Grants
-- Zelfde patroon als dialog_blocks.
-- =========================================================

grant all on table public.dialog_slides to anon;
grant all on table public.dialog_slides to authenticated;
grant all on table public.dialog_slides to service_role;

grant all on sequence public.dialog_slides_id_seq to anon;
grant all on sequence public.dialog_slides_id_seq to authenticated;
grant all on sequence public.dialog_slides_id_seq to service_role;

commit;
