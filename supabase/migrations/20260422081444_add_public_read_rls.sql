-- Enable RLS
alter table public.lessons enable row level security;
alter table public.dialogues enable row level security;
alter table public.vocabulary_master enable row level security;
alter table public.vocabulary_status enable row level security;
alter table public.lesson_vocabulary enable row level security;
alter table public.grammar_master enable row level security;
alter table public.grammar_status enable row level security;
alter table public.lesson_grammar enable row level security;

-- LESSONS: only published lessons are public
create policy "Published lessons are readable by everyone"
on public.lessons
for select
to anon, authenticated
using (is_published = true);

-- DIALOGUES: only if parent lesson is published
create policy "Dialogues of published lessons are readable by everyone"
on public.dialogues
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lessons l
    where l.id = dialogues.lesson_id
      and l.is_published = true
  )
);

-- LESSON VOCABULARY: only if parent lesson is published
create policy "Lesson vocabulary of published lessons are readable by everyone"
on public.lesson_vocabulary
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lessons l
    where l.id = lesson_vocabulary.lesson_id
      and l.is_published = true
  )
);

-- LESSON GRAMMAR: only if parent lesson is published
create policy "Lesson grammar of published lessons are readable by everyone"
on public.lesson_grammar
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lessons l
    where l.id = lesson_grammar.lesson_id
      and l.is_published = true
  )
);

-- VOCABULARY MASTER: public only when used in at least one published lesson
create policy "Vocabulary used in published lessons is readable by everyone"
on public.vocabulary_master
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lesson_vocabulary lv
    join public.lessons l on l.id = lv.lesson_id
    where lv.vocabulary_id = vocabulary_master.id
      and l.is_published = true
  )
);

-- GRAMMAR MASTER: public only when used in at least one published lesson
create policy "Grammar used in published lessons is readable by everyone"
on public.grammar_master
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lesson_grammar lg
    join public.lessons l on l.id = lg.lesson_id
    where lg.grammar_id = grammar_master.id
      and l.is_published = true
  )
);

-- No public read policy yet for status tables
-- vocabulary_status
-- grammar_status