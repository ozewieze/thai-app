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
  (select id from public.lessons where lesson_key = 'a1-dialog-04'),
    1,
  'Ask whether someone wants something, choose between simple food items, and express a different choice.',
  'After deciding what they will drink, Narin asks Mali if she would like a snack. Mali agrees. Narin asks which snack she wants, and she chooses cake. Mali then asks whether Narin will also take cake. He answers that he will take ice cream instead.',
  'Café conversation continuation',
  'Same café table as Dialogue 3',
  'polite',
  '6-8 lines',
  '["Mali uses ฉัน",
    "Narin uses ผม"]'::jsonb
);