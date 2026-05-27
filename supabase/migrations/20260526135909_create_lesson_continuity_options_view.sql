drop view if exists public.lesson_continuity_options_view;

create or replace view public.lesson_continuity_options_view as
select
  rp.id as relationship_pair_id,
  rp.start_state,
  rp.current_stage,
  rp.function_summary,
  rp.allowed_progression,
  rp.is_active,

  a.id as character_a_id,
  a.character_key as character_a_key,
  a.display_name as character_a_name,
  a.role_summary as character_a_role_summary,
  a.age_impression as character_a_age_impression,
  a.default_tone as character_a_default_tone,
  a.default_usage as character_a_default_usage,

  b.id as character_b_id,
  b.character_key as character_b_key,
  b.display_name as character_b_name,
  b.role_summary as character_b_role_summary,
  b.age_impression as character_b_age_impression,
  b.default_tone as character_b_default_tone,
  b.default_usage as character_b_default_usage,

  (
    select jsonb_agg(
      jsonb_build_object(
        'rule_key', rpr.rule_key,
        'rule_text', rpr.rule_text
      )
      order by rpr.rule_key, rpr.id
    )
    from public.relationship_pair_rules rpr
    where rpr.relationship_pair_id = rp.id
  ) as relationship_rules

from public.relationship_pairs rp
join public.character_profiles a on a.id = rp.character_a_id
join public.character_profiles b on b.id = rp.character_b_id
where rp.is_active = true;