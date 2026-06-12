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
  2,
  1,
  'Ask where someone is going, invite them to do something together, and accept an invitation.',  
  'Continuation of the  first, polite introduction between Mali and Narin in an everyday setting.  Narin asks where she is going and invites her for coffee.',
  'first meeting',
  'quiet everyday setting',
  'formal_polite',
  '6-8 lines',
  '[
    "Mali uses ฉัน",
    "Narin uses ผม"
  ]'::jsonb
);