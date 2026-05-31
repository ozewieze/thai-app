-- select jsonb_build_object(
--   'lesson_identity', jsonb_build_object(
--     'lesson_id', lb.lesson_id,
--     'lesson_key', lb.lesson_key,
--     'lesson_title', lb.lesson_title,
--     'subtitle', lb.subtitle,
--     'cefr_level', lb.cefr_level,
--     'lesson_type', lb.lesson_type,
--     'sequence_number', lb.sequence_number,
--     'section_key', lb.section_key,
--     'is_published', lb.is_published
--   ),

--   'content_scope', jsonb_build_object(
--     'all_vocabulary', lb.all_vocabulary,
--     'new_vocabulary', lvc.new_vocabulary,
--     'linked_previous_vocabulary', lvc.linked_previous_vocabulary,
--     'all_phrases', lb.all_phrases,
--     'all_grammar', lb.all_grammar,
--     'all_patterns', lb.all_patterns
--   ),

--   'continuity_context', jsonb_build_object(
--     'relationship_pair_id', lc.relationship_pair_id,
--     'start_state', lc.start_state,
--     'current_stage', lc.current_stage,
--     'function_summary', lc.function_summary,
--     'allowed_progression', lc.allowed_progression,

--     'speaker_a', jsonb_build_object(
--       'character_id', lc.character_a_id,
--       'character_key', lc.character_a_key,
--       'display_name', lc.character_a_name,
--       'display_name_thai', lc.character_a_name_thai,
--       'role_summary', lc.character_a_role_summary,
--       'age_impression', lc.character_a_age_impression,
--       'default_tone', lc.character_a_default_tone,
--       'default_usage', lc.character_a_default_usage
--     ),

--     'speaker_b', jsonb_build_object(
--       'character_id', lc.character_b_id,
--       'character_key', lc.character_b_key,
--       'display_name', lc.character_b_name,
--       'display_name_thai', lc.character_b_name_thai,
--       'role_summary', lc.character_b_role_summary,
--       'age_impression', lc.character_b_age_impression,
--       'default_tone', lc.character_b_default_tone,
--       'default_usage', lc.character_b_default_usage
--     ),

--     'relationship_rules', lc.relationship_rules
--   ),

--   'vocabulary_control', jsonb_build_object(
--     'must_use_new', lvc.new_vocabulary,
--     'may_reuse_previous', lvc.linked_previous_vocabulary,
--     'must_avoid_rule',
--       'Do not introduce vocabulary outside must_use_new and may_reuse_previous unless extremely basic and unavoidable for natural Thai.'
--   ),

--   'dialogue_design', jsonb_build_object(
--     'learning_focus', ds.learning_focus,
--     'scene_summary', ds.scene_summary,
--     'scene_type', ds.scene_type,
--     'suggested_location', ds.suggested_location,
--     'allowed_register', ds.allowed_register,
--     'estimated_line_count', ds.estimated_line_count,
--     'constraints',
--       jsonb_build_array(
--         'short lines only',
--         'one communicative move per line',
--         'beginner-safe Thai only',
--         'use polite particles consistently',
--         'no flirting or intimacy',
--         'no important new grammar outside lesson scope'
--       ) || coalesce(ds.extra_constraints, '[]'::jsonb)
--   ),

--   'prompt_render', jsonb_build_object(
--     'required_vocabulary_list', coalesce(rv.required_vocabulary_list, '- none'),
--     'allowed_review_vocabulary_list', coalesce(arv.allowed_review_vocabulary_list, '- none'),
--     'required_phrases_list', coalesce(rp.required_phrases_list, '- none'),
--     'required_grammar_list', coalesce(rg.required_grammar_list, '- none'),
--     'required_patterns_list_or_none', coalesce(rpat.required_patterns_list_or_none, '- none'),
--     'speaker_a_default_tone', coalesce(sa.speaker_a_default_tone, '- none'),
--     'speaker_a_default_usage', coalesce(sau.speaker_a_default_usage, '- none'),
--     'speaker_b_default_tone', coalesce(sb.speaker_b_default_tone, '- none'),
--     'speaker_b_default_usage', coalesce(sbu.speaker_b_default_usage, '- none'),
--     'allowed_progression', coalesce(ap.allowed_progression, '- none'),
--     'relationship_rules_list', coalesce(rr.relationship_rules_list, '- none'),
--     'dialogue_constraints_list', coalesce(dc.dialogue_constraints_list, '- none'),
--     'must_use_new_list', coalesce(mun.must_use_new_list, '- none'),
--     'may_reuse_previous_list', coalesce(mrp.may_reuse_previous_list, '- none')
--   )
-- ) as lesson_blueprint
-- from public.lesson_blueprint_view lb
-- join public.lesson_vocabulary_control_view lvc
--   on lvc.lesson_id = lb.lesson_id
-- join public.dialog_blueprint_specs ds
--   on ds.lesson_id = lb.lesson_id
-- join public.lesson_continuity_options_view lc
--   on lc.relationship_pair_id = ds.relationship_pair_id

-- left join lateral (
--   select string_agg(
--     concat(
--       '- ',
--       x->>'thai_script',
--       ' (',
--       x->>'paiboon',
--       ') = ',
--       x->>'english_gloss'
--     ),
--     E'\n'
--     order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
--   ) as required_vocabulary_list
--   from jsonb_array_elements(coalesce(lb.all_vocabulary, '[]'::jsonb)) x
-- ) rv on true

-- left join lateral (
--   select string_agg(
--     concat(
--       '- ',
--       x->>'thai_script',
--       ' (',
--       x->>'paiboon',
--       ') = ',
--       x->>'english_gloss'
--     ),
--     E'\n'
--     order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
--   ) as allowed_review_vocabulary_list
--   from jsonb_array_elements(coalesce(lvc.linked_previous_vocabulary, '[]'::jsonb)) x
-- ) arv on true

-- left join lateral (
--   select string_agg(
--     concat(
--       '- ',
--       coalesce(x->>'title', 'Untitled phrase'),
--       ': ',
--       coalesce(x->>'phrase_formula', ''),
--       case
--         when coalesce(x->>'short_explanation', '') <> ''
--         then concat(' — ', x->>'short_explanation')
--         else ''
--       end
--     ),
--     E'\n'
--     order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', '')
--   ) as required_phrases_list
--   from jsonb_array_elements(coalesce(lb.all_phrases, '[]'::jsonb)) x
-- ) rp on true

-- left join lateral (
--   select string_agg(
--     concat(
--       '- ',
--       coalesce(x->>'title', 'Untitled grammar'),
--       case
--         when coalesce(x->>'short_explanation', '') <> ''
--         then concat(': ', x->>'short_explanation')
--         else ''
--       end
--     ),
--     E'\n'
--     order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', '')
--   ) as required_grammar_list
--   from jsonb_array_elements(coalesce(lb.all_grammar, '[]'::jsonb)) x
-- ) rg on true

-- left join lateral (
--   select string_agg(
--     concat(
--       '- ',
--       coalesce(x->>'title', x->>'pattern_key', 'pattern')
--     ),
--     E'\n'
--     order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', x->>'pattern_key', '')
--   ) as required_patterns_list_or_none
--   from jsonb_array_elements(coalesce(lb.all_patterns, '[]'::jsonb)) x
-- ) rpat on true

-- left join lateral (
--   select string_agg(
--     concat('- ', value),
--     E'\n'
--     order by ord
--   ) as speaker_a_default_tone
--   from unnest(coalesce(lc.character_a_default_tone, array[]::text[])) with ordinality as t(value, ord)
-- ) sa on true

-- left join lateral (
--   select string_agg(
--     concat('- ', value),
--     E'\n'
--     order by ord
--   ) as speaker_a_default_usage
--   from unnest(coalesce(lc.character_a_default_usage, array[]::text[])) with ordinality as t(value, ord)
-- ) sau on true

-- left join lateral (
--   select string_agg(
--     concat('- ', value),
--     E'\n'
--     order by ord
--   ) as speaker_b_default_tone
--   from unnest(coalesce(lc.character_b_default_tone, array[]::text[])) with ordinality as t(value, ord)
-- ) sb on true

-- left join lateral (
--   select string_agg(
--     concat('- ', value),
--     E'\n'
--     order by ord
--   ) as speaker_b_default_usage
--   from unnest(coalesce(lc.character_b_default_usage, array[]::text[])) with ordinality as t(value, ord)
-- ) sbu on true

-- left join lateral (
--   select string_agg(
--     concat('- ', value),
--     E'\n'
--     order by ord
--   ) as allowed_progression
--   from unnest(coalesce(lc.allowed_progression, array[]::text[])) with ordinality as t(value, ord)
-- ) ap on true

-- left join lateral (
--   select string_agg(
--     concat(
--       '- ',
--       coalesce(x->>'rule_key', 'rule'),
--       ': ',
--       coalesce(x->>'rule_text', '')
--     ),
--     E'\n'
--     order by ord
--   ) as relationship_rules_list
--   from jsonb_array_elements(coalesce(lc.relationship_rules, '[]'::jsonb)) with ordinality as t(x, ord)
-- ) rr on true

-- left join lateral (
--   select string_agg(
--     concat('- ', value),
--     E'\n'
--     order by ord
--   ) as dialogue_constraints_list
--   from jsonb_array_elements_text(
--     jsonb_build_array(
--       'short lines only',
--       'one communicative move per line',
--       'beginner-safe Thai only',
--       'use polite particles consistently',
--       'no flirting or intimacy',
--       'no important new grammar outside lesson scope'
--     ) || coalesce(ds.extra_constraints, '[]'::jsonb)
--   ) with ordinality as t(value, ord)
-- ) dc on true

-- left join lateral (
--   select string_agg(
--     concat(
--       '- ',
--       x->>'thai_script',
--       ' (',
--       x->>'paiboon',
--       ') = ',
--       x->>'english_gloss'
--     ),
--     E'\n'
--     order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
--   ) as must_use_new_list
--   from jsonb_array_elements(coalesce(lvc.new_vocabulary, '[]'::jsonb)) x
-- ) mun on true

-- left join lateral (
--   select string_agg(
--     concat(
--       '- ',
--       x->>'thai_script',
--       ' (',
--       x->>'paiboon',
--       ') = ',
--       x->>'english_gloss'
--     ),
--     E'\n'
--     order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
--   ) as may_reuse_previous_list
--   from jsonb_array_elements(coalesce(lvc.linked_previous_vocabulary, '[]'::jsonb)) x
-- ) mrp on true

-- where lb.lesson_key = 'a1-dialog-01';

select
  lb.lesson_id,
  lb.lesson_key,
  lb.lesson_title,
  lb.subtitle,
  lb.cefr_level,
  lb.lesson_type,
  lb.sequence_number,
  lb.section_key,
  lb.is_published,

  ds.learning_focus,
  ds.scene_summary,
  ds.scene_type,
  ds.suggested_location,
  ds.allowed_register,
  ds.estimated_line_count,

  lc.relationship_pair_id,
  lc.start_state,
  lc.current_stage,
  lc.function_summary,

  lc.character_a_id,
  lc.character_a_key as speaker_a_key,
  lc.character_a_name as speaker_a_name,
  lc.character_a_name_thai as speaker_a_name_thai,
  lc.character_a_role_summary as speaker_a_role_summary,
  lc.character_a_age_impression as speaker_a_age_impression,

  lc.character_b_id,
  lc.character_b_key as speaker_b_key,
  lc.character_b_name as speaker_b_name,
  lc.character_b_name_thai as speaker_b_name_thai,
  lc.character_b_role_summary as speaker_b_role_summary,
  lc.character_b_age_impression as speaker_b_age_impression,

  coalesce(rv.required_vocabulary_list, '- none') as required_vocabulary_list,
  coalesce(arv.allowed_review_vocabulary_list, '- none') as allowed_review_vocabulary_list,
  coalesce(rp.required_phrases_list, '- none') as required_phrases_list,
  coalesce(rg.required_grammar_list, '- none') as required_grammar_list,
  coalesce(rpat.required_patterns_list, '- none') as required_patterns_list,

  coalesce(sa.speaker_a_default_tone, '- none') as speaker_a_default_tone,
  coalesce(sau.speaker_a_default_usage, '- none') as speaker_a_default_usage,
  coalesce(sb.speaker_b_default_tone, '- none') as speaker_b_default_tone,
  coalesce(sbu.speaker_b_default_usage, '- none') as speaker_b_default_usage,

  coalesce(ap.allowed_progression, '- none') as allowed_progression,
  coalesce(rr.relationship_rules_list, '- none') as relationship_rules_list,
  coalesce(dc.dialogue_constraints_list, '- none') as dialogue_constraints_list,

  coalesce(mun.must_use_new_list, '- none') as must_use_new_list,
  coalesce(mrp.may_reuse_previous_list, '- none') as may_reuse_previous_list,

  'Only use vocabulary from Required vocabulary and Previously introduced vocabulary allowed for reuse. Do not introduce additional vocabulary unless it is extremely basic and unavoidable for natural Thai.'
    as must_avoid_rule

from public.lesson_blueprint_view lb
join public.lesson_vocabulary_control_view lvc
  on lvc.lesson_id = lb.lesson_id
join public.dialog_blueprint_specs ds
  on ds.lesson_id = lb.lesson_id
join public.lesson_continuity_options_view lc
  on lc.relationship_pair_id = ds.relationship_pair_id

left join lateral (
  select string_agg(
    concat('- ', x->>'thai_script', ' (', x->>'paiboon', ') = ', x->>'english_gloss'),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
  ) as required_vocabulary_list
  from jsonb_array_elements(coalesce(lb.all_vocabulary, '[]'::jsonb)) x
) rv on true

left join lateral (
  select string_agg(
    concat('- ', x->>'thai_script', ' (', x->>'paiboon', ') = ', x->>'english_gloss'),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
  ) as allowed_review_vocabulary_list
  from jsonb_array_elements(coalesce(lvc.linked_previous_vocabulary, '[]'::jsonb)) x
) arv on true

left join lateral (
  select string_agg(
    concat(
      '- ',
      coalesce(x->>'title', 'Untitled phrase'),
      ': ',
      coalesce(x->>'phrase_formula', ''),
      case
        when coalesce(x->>'short_explanation', '') <> ''
        then concat(' — ', x->>'short_explanation')
        else ''
      end
    ),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', '')
  ) as required_phrases_list
  from jsonb_array_elements(coalesce(lb.all_phrases, '[]'::jsonb)) x
) rp on true

left join lateral (
  select string_agg(
    concat(
      '- ',
      coalesce(x->>'title', 'Untitled grammar'),
      case
        when coalesce(x->>'short_explanation', '') <> ''
        then concat(': ', x->>'short_explanation')
        else ''
      end
    ),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', '')
  ) as required_grammar_list
  from jsonb_array_elements(coalesce(lb.all_grammar, '[]'::jsonb)) x
) rg on true

left join lateral (
  select string_agg(
    concat('- ', coalesce(x->>'title', x->>'pattern_key', 'pattern')),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', x->>'pattern_key', '')
  ) as required_patterns_list
  from jsonb_array_elements(coalesce(lb.all_patterns, '[]'::jsonb)) x
) rpat on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as speaker_a_default_tone
  from unnest(coalesce(lc.character_a_default_tone, array[]::text[])) with ordinality as t(value, ord)
) sa on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as speaker_a_default_usage
  from unnest(coalesce(lc.character_a_default_usage, array[]::text[])) with ordinality as t(value, ord)
) sau on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as speaker_b_default_tone
  from unnest(coalesce(lc.character_b_default_tone, array[]::text[])) with ordinality as t(value, ord)
) sb on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as speaker_b_default_usage
  from unnest(coalesce(lc.character_b_default_usage, array[]::text[])) with ordinality as t(value, ord)
) sbu on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as allowed_progression
  from unnest(coalesce(lc.allowed_progression, array[]::text[])) with ordinality as t(value, ord)
) ap on true

left join lateral (
  select string_agg(
    concat('- ', coalesce(x->>'rule_key', 'rule'), ': ', coalesce(x->>'rule_text', '')),
    E'\n'
    order by ord
  ) as relationship_rules_list
  from jsonb_array_elements(coalesce(lc.relationship_rules, '[]'::jsonb)) with ordinality as t(x, ord)
) rr on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as dialogue_constraints_list
  from jsonb_array_elements_text(
    jsonb_build_array(
      'short lines only',
      'one communicative move per line',
      'beginner-safe Thai only',
      'use polite particles consistently',
      'no flirting or intimacy',
      'no important new grammar outside lesson scope'
    ) || coalesce(ds.extra_constraints, '[]'::jsonb)
  ) with ordinality as t(value, ord)
) dc on true

left join lateral (
  select string_agg(
    concat('- ', x->>'thai_script', ' (', x->>'paiboon', ') = ', x->>'english_gloss'),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
  ) as must_use_new_list
  from jsonb_array_elements(coalesce(lvc.new_vocabulary, '[]'::jsonb)) x
) mun on true

left join lateral (
  select string_agg(
    concat('- ', x->>'thai_script', ' (', x->>'paiboon', ') = ', x->>'english_gloss'),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
  ) as may_reuse_previous_list
  from jsonb_array_elements(coalesce(lvc.linked_previous_vocabulary, '[]'::jsonb)) x
) mrp on true

where lb.lesson_key = 'a1-dialog-01';