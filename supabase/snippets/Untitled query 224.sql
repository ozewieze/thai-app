select
  coalesce(v.vocabulary_list, '- none')  as introduced_vocabulary,
  coalesce(p.phrase_list,     '- none')  as introduced_phrases,
  coalesce(g.grammar_list,    '- none')  as introduced_grammar,
  coalesce(pa.pattern_list,   '- none')  as introduced_patterns

from (select 1) as dummy

left join lateral (
  select string_agg(
    concat('- ', vm.thai_script, ' (', vm.paiboon, ') = ', vm.english_gloss),
    E'\n' order by intro.sequence_number, vm.id
  ) as vocabulary_list
  from public.vocabulary_status vs
  join public.vocabulary_master vm on vm.id = vs.vocabulary_id
  join public.lessons intro on intro.id = vs.first_lesson_id
  where vs.first_lesson_id is not null
) v on true

left join lateral (
  select string_agg(
    concat('- ', pm.title, ': ', coalesce(pm.phrase_formula, '')),
    E'\n' order by intro.sequence_number, pm.id
  ) as phrase_list
  from public.phrase_status ps
  join public.phrase_master pm on pm.id = ps.phrase_id
  join public.lessons intro on intro.id = ps.first_lesson_id
  where ps.first_lesson_id is not null
) p on true

left join lateral (
  select string_agg(
    concat(
      '- ', gm.title,
      case when coalesce(gm.short_explanation, '') <> ''
        then concat(': ', gm.short_explanation) else '' end
    ),
    E'\n' order by intro.sequence_number, gm.id
  ) as grammar_list
  from public.grammar_status gs
  join public.grammar_master gm on gm.id = gs.grammar_id
  join public.lessons intro on intro.id = gs.first_lesson_id
  where gs.first_lesson_id is not null
) g on true

left join lateral (
  select string_agg(
    concat('- ', coalesce(pam.title, pam.pattern_key)),
    E'\n' order by intro.sequence_number, pam.id
  ) as pattern_list
  from public.pattern_status pas
  join public.pattern_master pam on pam.id = pas.pattern_id
  join public.lessons intro on intro.id = pas.first_lesson_id
  where pas.first_lesson_id is not null
) pa on true;



