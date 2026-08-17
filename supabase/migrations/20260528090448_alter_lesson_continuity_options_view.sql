drop view if exists public.lesson_continuity_options_view;

create or replace view public.lesson_continuity_options_view as
select
  rp.id as relationship_pair_id,
  rp.start_state,
  rp.current_stage,
  rp.function_summary,
  rp.allowed_progression,

  a.id as character_a_id,
  a.character_key as character_a_key,
  a.display_name as character_a_name,
  a.display_name_thai as character_a_name_thai,
  a.role_summary as character_a_role_summary,
  a.age_impression as character_a_age_impression,
  a.default_tone as character_a_default_tone,
  a.default_usage as character_a_default_usage,

  b.id as character_b_id,
  b.character_key as character_b_key,
  b.display_name as character_b_name,
  b.display_name_thai as character_b_name_thai,
  b.role_summary as character_b_role_summary,
  b.age_impression as character_b_age_impression,
  b.default_tone as character_b_default_tone,
  b.default_usage as character_b_default_usage,

  coalesce(
    jsonb_agg(
      jsonb_build_object(
        'rule_key', rpr.rule_key,
        'rule_text', rpr.rule_text
      )
      order by rpr.id
    ) filter (where rpr.id is not null),
    '[]'::jsonb
  ) as relationship_rules

from public.relationship_pairs rp
join public.character_profiles a on a.id = rp.character_a_id
join public.character_profiles b on b.id = rp.character_b_id
left join public.relationship_pair_rules rpr
  on rpr.relationship_pair_id = rp.id
where rp.is_active = true
group by
  rp.id,
  rp.start_state,
  rp.current_stage,
  rp.function_summary,
  rp.allowed_progression,
  a.id,
  a.character_key,
  a.display_name,
  a.display_name_thai,
  a.role_summary,
  a.age_impression,
  a.default_tone,
  a.default_usage,
  b.id,
  b.character_key,
  b.display_name,
  b.display_name_thai,
  b.role_summary,
  b.age_impression,
  b.default_tone,
  b.default_usage;