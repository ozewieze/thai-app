with pool as (
  select
    gm.concept_type,
    string_agg(
      concat(gm.title, case when coalesce(gm.short_explanation, '') <> ''
        then concat(': ', gm.short_explanation) else '' end),
      E'\n' order by gm.title
    ) as candidates
  from public.grammar_master gm
  join public.grammar_status gs on gs.grammar_id = gm.id
  where gs.status = 'new'
  group by gm.concept_type
)
select string_agg(
  concat('**', coalesce(concept_type, '(geen type)'), '**', E'\n', candidates),
  E'\n\n' order by concept_type nulls last
) as grammar_candidate_pool
from pool;
