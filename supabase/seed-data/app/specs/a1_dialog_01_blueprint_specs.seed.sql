insert into public.dialogue_blueprint_specs (
  lesson_id,
  relationship_pair_id,
  learning_focus,
  scene_summary,
  scene_type,
  suggested_location,
  allowed_register,
  estimated_line_count,
  extra_constraints
)
values (
  1,
  1,
  'Say hello, ask someone''s name, say your own name, and say nice to meet you.',
  'A first, polite introduction between Mali and Narin in an everyday setting.',
  'first meeting',
  'quiet everyday setting',
  'formal_polite',
  '6-8 lines',
  '[
    "Mali uses ฉัน",
    "Narin uses ผม"
  ]'::jsonb
);