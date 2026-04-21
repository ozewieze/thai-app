-- Optional but common in Supabase:
create extension if not exists pgcrypto;

-- =========================================================
-- lessons
-- =========================================================
create table public.lessons (
  id bigint generated always as identity primary key,
  lesson_key text not null,
  cefr_level text not null,
  lesson_type text not null,
  title text not null,
  sequence_number integer,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint lessons_lesson_key_unique unique (lesson_key),
  constraint lessons_sequence_number_unique unique (sequence_number),

  constraint lessons_cefr_level_check
    check (cefr_level in ('A1')),

  constraint lessons_lesson_type_check
    check (lesson_type in ('dialogue', 'theme', 'revision'))
);

-- =========================================================
-- dialogues
-- =========================================================
create table public.dialogues (
  id bigint generated always as identity primary key,
  lesson_id bigint not null,
  title text,
  thai_text text not null,
  transliteration text,
  translation_en text,
  register text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint dialogues_lesson_id_unique unique (lesson_id),

  constraint dialogues_lesson_fk
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade,

  constraint dialogues_register_check
    check (
      register is null
      or register in ('neutral', 'formal', 'informal', 'polite', 'colloquial')
    )
);

-- =========================================================
-- vocabulary_master
-- =========================================================
create table public.vocabulary_master (
  id bigint generated always as identity primary key,
  source_key text not null,
  cefr_level text not null,
  thai_script text not null,
  paiboon text,
  english_gloss text not null,
  part_of_speech text,
  register text,
  default_theme text,
  is_multifunctional boolean not null default false,
  usage_note text,
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint vocabulary_master_source_key_unique unique (source_key),

  constraint vocabulary_master_cefr_level_check
    check (cefr_level in ('A1')),

  constraint vocabulary_master_part_of_speech_check
    check (
      part_of_speech is null
      or part_of_speech in (
        'noun',
        'verb',
        'adjective',
        'adverb',
        'pronoun',
        'particle',
        'classifier',
        'question_word',
        'expression',
        'number',
        'other'
      )
    ),

  constraint vocabulary_master_register_check
    check (
      register is null
      or register in ('neutral', 'formal', 'informal', 'polite', 'colloquial')
    )
);

-- =========================================================
-- vocabulary_status
-- one row per vocabulary item
-- =========================================================
create table public.vocabulary_status (
  id bigint generated always as identity primary key,
  vocabulary_id bigint not null,
  status text not null default 'new',
  first_exposure_type text,
  first_lesson_id bigint,
  last_seen_lesson_id bigint,
  updated_at timestamptz not null default now(),

  constraint vocabulary_status_vocabulary_id_unique unique (vocabulary_id),

  constraint vocabulary_status_vocabulary_fk
    foreign key (vocabulary_id)
    references public.vocabulary_master (id)
    on delete cascade,

  constraint vocabulary_status_first_lesson_fk
    foreign key (first_lesson_id)
    references public.lessons (id)
    on delete set null,

  constraint vocabulary_status_last_seen_lesson_fk
    foreign key (last_seen_lesson_id)
    references public.lessons (id)
    on delete set null,

  constraint vocabulary_status_status_check
    check (status in ('new', 'theme_exposed', 'introduced_core')),

  constraint vocabulary_status_first_exposure_type_check
    check (
      first_exposure_type is null
      or first_exposure_type in ('theme', 'core')
    ),

  constraint vocabulary_status_first_context_required_check
    check (
      (status = 'new' and first_exposure_type is null and first_lesson_id is null)
      or
      (status in ('theme_exposed', 'introduced_core') and first_exposure_type is not null and first_lesson_id is not null)
    )
);

-- =========================================================
-- lesson_vocabulary
-- =========================================================
create table public.lesson_vocabulary (
  id bigint generated always as identity primary key,
  lesson_id bigint not null,
  vocabulary_id bigint not null,
  role text not null,
  requires_explanation boolean not null default false,
  display_order integer,
  notes text,
  created_at timestamptz not null default now(),

  constraint lesson_vocabulary_lesson_vocab_unique
    unique (lesson_id, vocabulary_id),

  constraint lesson_vocabulary_lesson_fk
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade,

  constraint lesson_vocabulary_vocabulary_fk
    foreign key (vocabulary_id)
    references public.vocabulary_master (id)
    on delete cascade,

  constraint lesson_vocabulary_role_check
    check (
      role in ('target', 'supporting', 'review', 'bonus')
    ),

  constraint lesson_vocabulary_display_order_check
    check (display_order is null or display_order >= 1)
);

-- =========================================================
-- grammar_master
-- =========================================================
create table public.grammar_master (
  id bigint generated always as identity primary key,
  concept_key text not null,
  cefr_level text not null,
  title text not null,
  short_explanation text,
  concept_type text,
  register text,
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint grammar_master_concept_key_unique unique (concept_key),

  constraint grammar_master_cefr_level_check
    check (cefr_level in ('A1')),

  constraint grammar_master_concept_type_check
    check (
      concept_type is null
      or concept_type in (
        'pattern',
        'particle',
        'word_order',
        'question_form',
        'negation',
        'classifier_usage',
        'politeness',
        'other'
      )
    ),

  constraint grammar_master_register_check
    check (
      register is null
      or register in ('neutral', 'formal', 'informal', 'polite', 'colloquial')
    )
);

-- =========================================================
-- grammar_status
-- one row per grammar item
-- =========================================================
create table public.grammar_status (
  id bigint generated always as identity primary key,
  grammar_id bigint not null,
  status text not null default 'new',
  first_lesson_id bigint,
  last_seen_lesson_id bigint,
  updated_at timestamptz not null default now(),

  constraint grammar_status_grammar_id_unique unique (grammar_id),

  constraint grammar_status_grammar_fk
    foreign key (grammar_id)
    references public.grammar_master (id)
    on delete cascade,

  constraint grammar_status_first_lesson_fk
    foreign key (first_lesson_id)
    references public.lessons (id)
    on delete set null,

  constraint grammar_status_last_seen_lesson_fk
    foreign key (last_seen_lesson_id)
    references public.lessons (id)
    on delete set null,

  constraint grammar_status_status_check
    check (status in ('new', 'introduced_core')),

  constraint grammar_status_first_context_required_check
    check (
      (status = 'new' and first_lesson_id is null)
      or
      (status = 'introduced_core' and first_lesson_id is not null)
    )
);

-- =========================================================
-- lesson_grammar
-- =========================================================
create table public.lesson_grammar (
  id bigint generated always as identity primary key,
  lesson_id bigint not null,
  grammar_id bigint not null,
  requires_explanation boolean not null default false,
  display_order integer,
  notes text,
  created_at timestamptz not null default now(),

  constraint lesson_grammar_lesson_grammar_unique
    unique (lesson_id, grammar_id),

  constraint lesson_grammar_lesson_fk
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade,

  constraint lesson_grammar_grammar_fk
    foreign key (grammar_id)
    references public.grammar_master (id)
    on delete cascade,

  constraint lesson_grammar_display_order_check
    check (display_order is null or display_order >= 1)
);