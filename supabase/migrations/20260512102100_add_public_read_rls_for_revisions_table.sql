alter table public.revisions enable row level security;

create policy "Revisions of published lessons are readable by everyone"
on public.revisions
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lessons l
    where l.id = revisions.lesson_id
      and l.is_published = true
  )
);