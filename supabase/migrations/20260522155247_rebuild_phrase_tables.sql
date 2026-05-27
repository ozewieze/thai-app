begin;

-- =========================================================
-- clean up current phrase-related objects if they exist
-- =========================================================

drop policy if exists "Phrases used in published lessons are readable by everyone"
on public.phrases_master;

drop policy if exists "Lesson phrases of published lessons are readable by everyone"
on public.lesson_phrase;


drop policy if exists "Lesson phrases of published lessons are readable by everyone"
on public.lesson_phrase;

drop table if exists public.phrase_status cascade;
drop table if exists public.lesson_phrase cascade;
drop table if exists public.phrases_master cascade;
drop table if exists public.phrase_master cascade;

-- =========================================================
-- phrase_master
-- =========================================================

create table public.phrase_master (
  id bigint generated always as identity primary key,
  phrase_key text not null,
  cefr_level text not null,
  title text not null,
  phrase_formula text,
  short_explanation text,
  phrase_type text,
  register text,
  fixedness_level text,
  is_productive boolean not null default false,
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint phrase_master_phrase_key_unique
    unique (phrase_key),

  constraint phrase_master_cefr_level_check
    check (cefr_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),

  constraint phrase_master_phrase_type_check
    check (
      phrase_type is null
      or phrase_type in (
        'sentence_frame',
        'collocation',
        'formulaic_expression',
        'functional_pattern',
        'discourse_pattern',
        'question_answer_exchange',
        'other'
      )
    ),

  constraint phrase_master_register_check
    check (
      register is null
      or register in ('neutral', 'formal', 'informal', 'polite', 'colloquial')
    ),

  constraint phrase_master_fixedness_level_check
    check (
      fixedness_level is null
      or fixedness_level in ('fixed', 'semi_fixed', 'productive')
    )
);

-- =========================================================
-- phrase_status
-- one row per phrase item
-- =========================================================

create table public.phrase_status (
  id bigint generated always as identity primary key,
  phrase_id bigint not null,
  status text not null default 'new',
  first_lesson_id bigint,
  last_seen_lesson_id bigint,
  updated_at timestamptz not null default now(),

  constraint phrase_status_phrase_id_unique
    unique (phrase_id),

  constraint phrase_status_phrase_fk
    foreign key (phrase_id)
    references public.phrase_master (id)
    on delete cascade,

  constraint phrase_status_first_lesson_fk
    foreign key (first_lesson_id)
    references public.lessons (id)
    on delete set null,

  constraint phrase_status_last_seen_lesson_fk
    foreign key (last_seen_lesson_id)
    references public.lessons (id)
    on delete set null,

  constraint phrase_status_status_check
    check (status in ('new', 'introduced_core')),

  constraint phrase_status_first_context_required_check
    check (
      (status = 'new' and first_lesson_id is null)
      or
      (status = 'introduced_core' and first_lesson_id is not null)
    )
);

-- =========================================================
-- lesson_phrase
-- =========================================================

create table public.lesson_phrase (
  id bigint generated always as identity primary key,
  lesson_id bigint not null,
  phrase_id bigint not null,
  role text not null,
  requires_explanation boolean not null default false,
  display_order integer,
  notes text,
  created_at timestamptz not null default now(),

  constraint lesson_phrase_lesson_phrase_unique
    unique (lesson_id, phrase_id),

  constraint lesson_phrase_lesson_fk
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade,

  constraint lesson_phrase_phrase_fk
    foreign key (phrase_id)
    references public.phrase_master (id)
    on delete cascade,

  constraint lesson_phrase_role_check
    check (role in ('target', 'supporting', 'review', 'bonus')),

  constraint lesson_phrase_display_order_check
    check (display_order is null or display_order >= 1)
);

-- =========================================================
-- RLS
-- =========================================================

alter table public.phrase_master enable row level security;
alter table public.phrase_status enable row level security;
alter table public.lesson_phrase enable row level security;

-- =========================================================
-- public read policies
-- =========================================================

create policy "Phrases used in published lessons are readable by everyone"
on public.phrase_master
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lesson_phrase lp
    join public.lessons l
      on l.id = lp.lesson_id
    where lp.phrase_id = phrase_master.id
      and l.is_published = true
  )
);

create policy "Lesson phrases of published lessons are readable by everyone"
on public.lesson_phrase
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lessons l
    where l.id = lesson_phrase.lesson_id
      and l.is_published = true
  )
);

commit;