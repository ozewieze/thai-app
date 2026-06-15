insert into public.dialog_blueprint_specs (
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
  3,
  1,
  'Ask what someone will drink and talk about drink choices. ',  
  'Mali and Narin are seated at a café after deciding to have coffee together. They talk about what they will drink.',
  'first meeting',
  'quiet everyday setting',
  'formal_polite',
  '6-8 lines',
  '[
    "Mali uses ฉัน",
    "Narin uses ผม"
  ]'::jsonb
);