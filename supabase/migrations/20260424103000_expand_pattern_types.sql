-- Expand pattern type support to match seeded pattern CSV categories.

alter table public.pattern_master
  drop constraint if exists pattern_master_pattern_type_check;

alter table public.pattern_master
  add constraint pattern_master_pattern_type_check
  check (
    pattern_type is null
    or pattern_type in (
      'sentence_frame',
      'negation_frame',
      'ability_frame',
      'request_frame',
      'preference_frame',
      'permission_frame',
      'question_frame',
      'location_frame',
      'time_frame',
      'quantity_frame',
      'classifier_frame',
      'result_frame',
      'comparison_frame',
      'politeness_frame',
      'response_frame'
    )
  );
