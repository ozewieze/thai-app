-- Enable RLS
alter table public.pattern_master enable row level security;
alter table public.pattern_status enable row level security;
alter table public.lesson_pattern enable row level security;


-- LESSON PATTERN: only if parent lesson is published
create policy "Lesson pattern of published lessons are readable by everyone"
on public.lesson_pattern
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lessons l
    where l.id = lesson_pattern.lesson_id
      and l.is_published = true
  )
);


-- PATTERN MASTER: public only when used in at least one published lesson
create policy "Patterns used in published lessons are readable by everyone"
on public.pattern_master
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lesson_pattern lp
    join public.lessons l on l.id = lp.lesson_id
    where lp.pattern_id = pattern_master.id
      and l.is_published = true
  )
);

-- No public read policy yet for status table
-- pattern_status