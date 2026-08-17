begin;

-- =========================================================
-- dialog_blocks
-- one row per block (line) of a dialog
-- replaces runtime splitting of flat text in dialogs table
-- =========================================================

create table public.dialog_blocks (
  id             bigint generated always as identity primary key,
  dialog_id      bigint      not null,
  block_index    integer     not null,
  thai_text      text        not null,
  transliteration text,
  translation_en text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  constraint dialog_blocks_dialog_block_unique
    unique (dialog_id, block_index),

  constraint dialog_blocks_dialog_fk
    foreign key (dialog_id)
    references public.dialogs (id)
    on delete cascade,

  constraint dialog_blocks_block_index_check
    check (block_index >= 0)
);

-- =========================================================
-- RLS
-- =========================================================

alter table public.dialog_blocks enable row level security;

create policy "Blocks of published dialogs are readable by everyone"
on public.dialog_blocks
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.dialogs d
    join public.lessons l on l.id = d.lesson_id
    where d.id = dialog_blocks.dialog_id
      and l.is_published = true
  )
);

-- =========================================================
-- grants
-- =========================================================

grant all on table public.dialog_blocks to anon;
grant all on table public.dialog_blocks to authenticated;
grant all on table public.dialog_blocks to service_role;

grant all on sequence public.dialog_blocks_id_seq to anon;
grant all on sequence public.dialog_blocks_id_seq to authenticated;
grant all on sequence public.dialog_blocks_id_seq to service_role;

commit;
