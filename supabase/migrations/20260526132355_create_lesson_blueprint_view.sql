-- V0003_remove_old_lesson_blueprint_view.sql
DROP VIEW IF EXISTS public.lesson_blueprint_view;

CREATE OR REPLACE VIEW lesson_blueprint_view AS
SELECT
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
  (
    SELECT jsonb_agg(
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
      ORDER BY lv.display_order nulls first, lv.id
    )
    FROM public.lesson_vocabulary lv
    JOIN public.vocabulary_master vm ON vm.id = lv.vocabulary_id
    WHERE lv.lesson_id = l.id
  ) as all_vocabulary,
  
  -- Phrases  
  (
    SELECT jsonb_agg(
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
      ORDER BY lp.display_order nulls first, lp.id
    )
    FROM public.lesson_phrase lp
    JOIN public.phrase_master pm ON pm.id = lp.phrase_id
    WHERE lp.lesson_id = l.id
  ) as all_phrases,
  
  -- Grammar (zonder 'role')
  (
    SELECT jsonb_agg(
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
      ORDER BY lg.display_order nulls first, lg.id
    )
    FROM public.lesson_grammar lg
    JOIN public.grammar_master gm ON gm.id = lg.grammar_id
    WHERE lg.lesson_id = l.id
  ) as all_grammar

FROM public.lessons l;