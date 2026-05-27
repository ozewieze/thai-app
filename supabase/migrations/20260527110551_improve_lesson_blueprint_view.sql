drop view if exists public.lesson_blueprint_view;

create or replace view public.lesson_blueprint_view as
select
  l.id as lesson_id,
  l.lesson_key,
  l.title as lesson_title,
  l.subtitle,
  l.cefr_level,
  l.lesson_type,
  l.sequence_number,
  l.section_key,
  l.is_published,

  -- Vocabulary
  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'vocabulary_id', vm.id,
        'source_key', vm.source_key,
        'thai_script', vm.thai_script,
        'paiboon', vm.paiboon,
        'english_gloss', vm.english_gloss,
        'part_of_speech', vm.part_of_speech,
        'register', vm.register,
        'usage_note', vm.usage_note,
        'lesson_role', lv.role,
        'display_order', lv.display_order,
        'requires_explanation', lv.requires_explanation,
        'lesson_notes', lv.notes
      )
      order by lv.display_order nulls first, lv.id
    )
    from public.lesson_vocabulary lv
    join public.vocabulary_master vm on vm.id = lv.vocabulary_id
    where lv.lesson_id = l.id
  ), '[]'::jsonb) as all_vocabulary,

  -- Phrases
  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'phrase_id', pm.id,
        'phrase_key', pm.phrase_key,
        'title', pm.title,
        'phrase_formula', pm.phrase_formula,
        'short_explanation', pm.short_explanation,
        'phrase_type', pm.phrase_type,
        'register', pm.register,
        'fixedness_level', pm.fixedness_level,
        'is_productive', pm.is_productive,
        'lesson_role', lp.role,
        'display_order', lp.display_order,
        'requires_explanation', lp.requires_explanation,
        'lesson_notes', lp.notes
      )
      order by lp.display_order nulls first, lp.id
    )
    from public.lesson_phrase lp
    join public.phrase_master pm on pm.id = lp.phrase_id
    where lp.lesson_id = l.id
  ), '[]'::jsonb) as all_phrases,

  -- Grammar
  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'grammar_id', gm.id,
        'concept_key', gm.concept_key,
        'title', gm.title,
        'short_explanation', gm.short_explanation,
        'concept_type', gm.concept_type,
        'register', gm.register,
        'display_order', lg.display_order,
        'requires_explanation', lg.requires_explanation,
        'lesson_notes', lg.notes
      )
      order by lg.display_order nulls first, lg.id
    )
    from public.lesson_grammar lg
    join public.grammar_master gm on gm.id = lg.grammar_id
    where lg.lesson_id = l.id
  ), '[]'::jsonb) as all_grammar,

  -- Patterns
  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'pattern_id', pm.id,
        'pattern_key', pm.pattern_key,
        'title', pm.title,
        'pattern_formula', pm.pattern_formula,
        'short_explanation', pm.short_explanation,
        'pattern_type', pm.pattern_type,
        'register', pm.register,
        'fixedness_level', pm.fixedness_level,
        'is_productive', pm.is_productive,
        'display_order', lp.display_order,
        'requires_explanation', lp.requires_explanation,
        'lesson_notes', lp.notes
      )
      order by lp.display_order nulls first, lp.id
    )
    from public.lesson_pattern lp
    join public.pattern_master pm on pm.id = lp.pattern_id
    where lp.lesson_id = l.id
  ), '[]'::jsonb) as all_patterns

from public.lessons l;