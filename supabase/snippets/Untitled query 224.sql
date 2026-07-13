with rules_flat as (
  select
    lco.relationship_pair_id,
    string_agg(
      concat('  - ', r ->> 'rule_key', ': ', r ->> 'rule_text'),
      E'\n' order by r ->> 'rule_key'
    ) as rules_text
  from public.lesson_continuity_options_view lco
  cross join lateral jsonb_array_elements(lco.relationship_rules) as r
  group by lco.relationship_pair_id
),
pairs as (
  select
    lco.relationship_pair_id,
    lco.character_a_name,
    lco.character_a_name_thai,
    lco.character_a_role_summary,
    lco.character_a_age_impression,
    lco.character_a_default_tone,
    lco.character_a_default_usage,
    lco.character_b_name,
    lco.character_b_name_thai,
    lco.character_b_role_summary,
    lco.character_b_age_impression,
    lco.character_b_default_tone,
    lco.character_b_default_usage,
    lco.current_stage,
    lco.start_state,
    lco.function_summary,
    lco.allowed_progression,
    coalesce(rf.rules_text, '  - (geen regels)') as rules_text
  from public.lesson_continuity_options_view lco
  left join rules_flat rf on rf.relationship_pair_id = lco.relationship_pair_id
)
select string_agg(
  concat(
    '**Pair ', relationship_pair_id, ': ', character_a_name, ' (', character_a_name_thai, ') & ',
    character_b_name, ' (', character_b_name_thai, ')**', E'\n',
    '- ', character_a_name, ': ', character_a_role_summary, ' — ', character_a_age_impression,
    ', tone: ', character_a_default_tone, ', usage: ', character_a_default_usage, E'\n',
    '- ', character_b_name, ': ', character_b_role_summary, ' — ', character_b_age_impression,
    ', tone: ', character_b_default_tone, ', usage: ', character_b_default_usage, E'\n',
    '- Current stage: ', current_stage, ' (start: ', start_state, ')', E'\n',
    '- Function: ', function_summary, E'\n',
    '- Allowed progression: ', allowed_progression, E'\n',
    '- Relationship rules:', E'\n', rules_text
  ),
  E'\n\n' order by relationship_pair_id
) as continuity_options
from pairs;

