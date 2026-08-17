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
  (select id from public.lessons where lesson_key = 'a1-dialog-05'),  
  1,
  'Talk about food preferences, describe taste and express frequency.',
  'The drinks and snacks have arrived. Mali and Narin talk about whether they like cake and ice cream, whether the food is delicious, and how often they eat snacks.',
  'Food preference conversation',
  'Same café table as Dialogue 3 and 4',
  'polite',
  '6-8 lines',
  '["Subject omission is already taught (Dialog 2, subject_omission_when_clear) -- keep omitting คุณ/ผม/ฉัน when context makes the subject clear, do not reintroduce them"]'::jsonb
);