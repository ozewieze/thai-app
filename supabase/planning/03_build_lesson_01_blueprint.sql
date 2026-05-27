select jsonb_build_object(
  'lesson_identity', jsonb_build_object(
    'lesson_id', lb.lesson_id,
    'lesson_key', lb.lesson_key,
    'lesson_title', lb.lesson_title,
    'subtitle', lb.subtitle,
    'cefr_level', lb.cefr_level,
    'lesson_type', lb.lesson_type,
    'sequence_number', lb.sequence_number,
    'section_key', lb.section_key,
    'is_published', lb.is_published
  ),

  'content_scope', jsonb_build_object(
    'all_vocabulary', lb.all_vocabulary,
    'new_vocabulary', lvc.new_vocabulary,
    'linked_previous_vocabulary', lvc.linked_previous_vocabulary,
    'all_phrases', lb.all_phrases,
    'all_grammar', lb.all_grammar,
    'all_patterns', lb.all_patterns
  ),

  'continuity_context', jsonb_build_object(
    'relationship_pair_id', lc.relationship_pair_id,
    'start_state', lc.start_state,
    'current_stage', lc.current_stage,
    'function_summary', lc.function_summary,
    'allowed_progression', lc.allowed_progression,

    'speaker_a', jsonb_build_object(
      'character_id', lc.character_a_id,
      'character_key', lc.character_a_key,
      'display_name', lc.character_a_name,
      'role_summary', lc.character_a_role_summary,
      'age_impression', lc.character_a_age_impression,
      'default_tone', lc.character_a_default_tone,
      'default_usage', lc.character_a_default_usage
    ),

    'speaker_b', jsonb_build_object(
      'character_id', lc.character_b_id,
      'character_key', lc.character_b_key,
      'display_name', lc.character_b_name,
      'role_summary', lc.character_b_role_summary,
      'age_impression', lc.character_b_age_impression,
      'default_tone', lc.character_b_default_tone,
      'default_usage', lc.character_b_default_usage
    ),

    'relationship_rules', lc.relationship_rules
  ),

  'vocabulary_control', jsonb_build_object(
    'must_use_new', lvc.new_vocabulary,
    'may_reuse_previous', lvc.linked_previous_vocabulary,
    'must_avoid_rule',
      'Do not introduce vocabulary outside must_use_new and may_reuse_previous unless extremely basic and unavoidable for natural Thai.'
  ),

  'dialogue_design', jsonb_build_object(
    'communicative_goal',
      'Say hello, ask someone''s name, say your own name, and say nice to meet you.',
    'scene_type', 'first meeting',
    'suggested_location', 'quiet everyday setting',
    'allowed_register', 'formal_polite',
    'estimated_line_count', '6-8 lines',
    'constraints', jsonb_build_array(
      'short lines only',
      'one communicative move per line',
      'beginner-safe Thai only',
      'Mali uses ฉัน',
      'Narin uses ผม',
      'use polite particles consistently',
      'no flirting or intimacy',
      'no important new grammar outside lesson scope'
    )
  )
) as lesson_blueprint
from public.lesson_blueprint_view lb
join public.lesson_vocabulary_control_view lvc
  on lvc.lesson_id = lb.lesson_id
join public.lesson_continuity_options_view lc
  on lc.relationship_pair_id = 1
where lb.lesson_key = 'a1-dialog-01';