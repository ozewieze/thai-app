create table public.character_profiles (
  id bigint generated always as identity primary key,
  character_key text not null,
  display_name text not null,
  role_summary text not null,
  age_impression text,
  default_tone text[] not null default '{}',
  default_usage text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint character_profiles_character_key_unique unique (character_key)
);


create table public.relationship_pairs (
  id bigint generated always as identity primary key,
  character_a_id bigint not null,
  character_b_id bigint not null,
  start_state text not null,
  current_stage text not null,
  function_summary text not null,
  allowed_progression text[] not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint relationship_pairs_unique_pair unique (character_a_id, character_b_id),

  constraint relationship_pairs_character_a_fk
    foreign key (character_a_id)
    references public.character_profiles (id)
    on delete cascade,

  constraint relationship_pairs_character_b_fk
    foreign key (character_b_id)
    references public.character_profiles (id)
    on delete cascade,

  constraint relationship_pairs_distinct_characters_check
    check (character_a_id <> character_b_id)
);


create table public.relationship_pair_rules (
  id bigint generated always as identity primary key,
  relationship_pair_id bigint not null,
  rule_key text not null,
  rule_text text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint relationship_pair_rules_relationship_pair_fk
    foreign key (relationship_pair_id)
    references public.relationship_pairs (id)
    on delete cascade
);