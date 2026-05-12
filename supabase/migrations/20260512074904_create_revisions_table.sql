create table public.revisions (
  id bigint generated always as identity primary key,
  lesson_id bigint not null,
  range_label text,
  summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint revisions_lesson_id_unique unique (lesson_id),

  constraint revisions_lesson_fk
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade
);