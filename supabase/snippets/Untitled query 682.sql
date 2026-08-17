select
  rpr.id,
  a.character_key as character_a,
  b.character_key as character_b,
  rpr.rule_key,
  rpr.rule_text
from public.relationship_pair_rules rpr
join public.relationship_pairs rp on rp.id = rpr.relationship_pair_id
join public.character_profiles a on a.id = rp.character_a_id
join public.character_profiles b on b.id = rp.character_b_id
order by a.character_key, b.character_key, rpr.rule_key;