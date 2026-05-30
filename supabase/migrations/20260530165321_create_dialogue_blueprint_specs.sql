create table public.dialogue_blueprint_specs (
  id bigint generated always as identity primary key,
  lesson_id bigint not null unique references public.lessons(id) on delete cascade,
  relationship_pair_id bigint not null references public.relationship_pairs(id),
  learning_focus text not null,
  scene_summary text not null,
  scene_type text,
  suggested_location text,
  allowed_register text,
  estimated_line_count text,
  extra_constraints jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (jsonb_typeof(extra_constraints) = 'array')
);