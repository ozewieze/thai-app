-- =========================================================
-- pattern_master
-- =========================================================
create table public.pattern_master (
  id bigint generated always as identity primary key,
  pattern_key text not null,
  cefr_level text not null,
  title text not null,
  pattern_formula text,
  short_explanation text,
  pattern_type text,
  register text,
  fixedness_level text,
  is_productive boolean not null default false,
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint pattern_master_pattern_key_unique unique (pattern_key),

  constraint pattern_master_cefr_level_check    
    check (cefr_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),

  constraint pattern_master_pattern_type_check
    check (
      pattern_type is null
      or pattern_type in (
        'sentence_frame',
        'collocation',
        'formulaic_expression',
        'functional_pattern',
        'discourse_pattern',
        'other'
      )
    ),

  constraint pattern_master_register_check
    check (
      register is null
      or register in ('neutral', 'formal', 'informal', 'polite', 'colloquial')
    ),

  constraint pattern_master_fixedness_level_check
    check (
      fixedness_level is null
      or fixedness_level in ('fixed', 'semi_fixed', 'productive')
    )
);

-- =========================================================
-- pattern_status
-- one row per pattern item
-- =========================================================
create table public.pattern_status (
  id bigint generated always as identity primary key,
  pattern_id bigint not null,
  status text not null default 'new',
  first_lesson_id bigint,
  last_seen_lesson_id bigint,
  updated_at timestamptz not null default now(),

  constraint pattern_status_pattern_id_unique unique (pattern_id),

  constraint pattern_status_pattern_fk
    foreign key (pattern_id)
    references public.pattern_master (id)
    on delete cascade,

  constraint pattern_status_first_lesson_fk
    foreign key (first_lesson_id)
    references public.lessons (id)
    on delete set null,

  constraint pattern_status_last_seen_lesson_fk
    foreign key (last_seen_lesson_id)
    references public.lessons (id)
    on delete set null,

  constraint pattern_status_status_check
    check (status in ('new', 'introduced_core')),

  constraint pattern_status_first_context_required_check
    check (
      (status = 'new' and first_lesson_id is null)
      or
      (status = 'introduced_core' and first_lesson_id is not null)
    )
);

-- =========================================================
-- lesson_pattern
-- =========================================================
create table public.lesson_pattern (
  id bigint generated always as identity primary key,
  lesson_id bigint not null,
  pattern_id bigint not null,
  requires_explanation boolean not null default false,
  display_order integer,
  notes text,
  created_at timestamptz not null default now(),

  constraint lesson_pattern_lesson_pattern_unique
    unique (lesson_id, pattern_id),

  constraint lesson_pattern_lesson_fk
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade,

  constraint lesson_pattern_pattern_fk
    foreign key (pattern_id)
    references public.pattern_master (id)
    on delete cascade,

  constraint lesson_pattern_display_order_check
    check (display_order is null or display_order >= 1)
);