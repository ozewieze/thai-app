select
  rp.id,
  a.display_name as character_a,
  b.display_name as character_b,
  rp.start_state,
  rp.current_stage,
  rp.function_summary
from public.relationship_pairs rp
join public.character_profiles a on a.id = rp.character_a_id
join public.character_profiles b on b.id = rp.character_b_id
order by a.character_key, b.character_key;