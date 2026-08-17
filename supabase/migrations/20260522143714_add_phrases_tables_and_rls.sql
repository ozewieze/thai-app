-- =========================================================
-- phrases_master
-- =========================================================
create table public.phrases_master (
  id bigint generated always as identity primary key,
  phrase_key text not null,
  cefr_level text not null,
  thai_script text not null,
  transliteration text,
  english_gloss text not null,
  phrase_type text,
  register text,
  fixedness_level text not null default 'fixed',
  is_productive boolean not null default false,
  usage_note text,
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint phrases_master_phrase_key_unique
    unique (phrase_key),

  constraint phrases_master_cefr_level_check
    check (cefr_level in ('A1')),

  constraint phrases_master_register_check
    check (
      register is null
      or register in ('neutral', 'formal', 'informal', 'polite', 'colloquial')
    ),

  constraint phrases_master_fixedness_level_check
    check (
      fixedness_level in ('fixed', 'semi_fixed')
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

  constraint phrase_status_phrase_id_unique unique (phrase_id),

  constraint phrase_status_phrase_fk
    foreign key (phrase_id)
    references public.phrases_master (id)
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
    references public.phrases_master (id)
    on delete cascade,

  constraint lesson_phrase_role_check
    check (
      role in ('target', 'supporting', 'review', 'bonus')
    ),

  constraint lesson_phrase_display_order_check
    check (display_order is null or display_order >= 1)
);

-- =========================================================
-- RLS
-- =========================================================
alter table public.phrases_master enable row level security;
alter table public.phrase_status enable row level security;
alter table public.lesson_phrase enable row level security;

-- =========================================================
-- phrases_master policies
-- =========================================================
create policy "Phrases used in published lessons are readable by everyone"
on public.phrases_master
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lesson_phrase lp
    join public.lessons l on l.id = lp.lesson_id
    where lp.phrase_id = phrases_master.id
      and l.is_published = true
  )
);

-- =========================================================
-- lesson_phrase policies
-- =========================================================
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