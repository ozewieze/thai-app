begin;

-- =========================================================
-- Herstel: security_invoker = true op alle planning-views
--
-- Waarom: views gemaakt door een superuser (postgres) draaien
-- standaard als SECURITY DEFINER, wat betekent dat RLS-policies
-- op de onderliggende tabellen worden OMZEILD. Iedereen die
-- deze views bevraagt ziet dan alle data, ook ongepubliceerde.
--
-- Met security_invoker = true draait de view als de AANROEPER,
-- niet als de eigenaar. RLS werkt daardoor weer correct.
--
-- Vereist: PostgreSQL 15+ (dit project gebruikt 17).
-- =========================================================


-- ---------------------------------------------------------
-- 1. lesson_blueprint_view
--    Bron: 20260527110551_improve_lesson_blueprint_view.sql
-- ---------------------------------------------------------

drop view if exists public.lesson_blueprint_view;

create or replace view public.lesson_blueprint_view
  with (security_invoker = true)
as
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


-- ---------------------------------------------------------
-- 2. lesson_vocabulary_control_view
--    Bron: 20260527191657_improve_lesson_vocabulary_control_view.sql
-- ---------------------------------------------------------

drop view if exists public.lesson_vocabulary_control_view;

create or replace view public.lesson_vocabulary_control_view
  with (security_invoker = true)
as
select
  l.id as lesson_id,
  l.lesson_key,
  l.sequence_number,

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
        'lesson_role', lv.role,
        'display_order', lv.display_order,
        'requires_explanation', lv.requires_explanation,
        'lesson_notes', lv.notes,
        'status', vs.status,
        'first_lesson_id', vs.first_lesson_id
      )
      order by lv.display_order nulls first, lv.id
    )
    from public.lesson_vocabulary lv
    join public.vocabulary_master vm
      on vm.id = lv.vocabulary_id
    join public.vocabulary_status vs
      on vs.vocabulary_id = vm.id
    where lv.lesson_id = l.id
      and vs.first_lesson_id = l.id
  ), '[]'::jsonb) as new_vocabulary,

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
        'lesson_role', lv.role,
        'display_order', lv.display_order,
        'requires_explanation', lv.requires_explanation,
        'lesson_notes', lv.notes,
        'status', vs.status,
        'first_lesson_id', vs.first_lesson_id
      )
      order by vs.first_lesson_id, lv.display_order nulls first, lv.id
    )
    from public.lesson_vocabulary lv
    join public.vocabulary_master vm
      on vm.id = lv.vocabulary_id
    join public.vocabulary_status vs
      on vs.vocabulary_id = vm.id
    where lv.lesson_id = l.id
      and vs.first_lesson_id is not null
      and vs.first_lesson_id < l.id
  ), '[]'::jsonb) as linked_previous_vocabulary

from public.lessons l;


-- ---------------------------------------------------------
-- 3. lesson_continuity_options_view
--    Bron: 20260528090448_alter_lesson_continuity_options_view.sql
-- ---------------------------------------------------------

drop view if exists public.lesson_continuity_options_view;

create or replace view public.lesson_continuity_options_view
  with (security_invoker = true)
as
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


-- ---------------------------------------------------------
-- 4. lesson_available_vocabulary_view
--    Bron: 20260608100000_fix_lesson_available_vocabulary_view_sequence_number.sql
-- ---------------------------------------------------------

drop view if exists public.lesson_available_vocabulary_view;

create or replace view public.lesson_available_vocabulary_view
  with (security_invoker = true)
as
select
  l.id             as lesson_id,
  l.lesson_key,
  l.sequence_number,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'vocabulary_id',         vm.id,
        'source_key',            vm.source_key,
        'thai_script',           vm.thai_script,
        'paiboon',               vm.paiboon,
        'english_gloss',         vm.english_gloss,
        'part_of_speech',        vm.part_of_speech,
        'register',              vm.register,
        'status',                vs.status,
        'first_lesson_id',       vs.first_lesson_id,
        'intro_sequence_number', intro.sequence_number
      )
      order by intro.sequence_number, vm.id
    )
    from public.vocabulary_status vs
    join public.vocabulary_master vm    on vm.id    = vs.vocabulary_id
    join public.lessons           intro on intro.id = vs.first_lesson_id
    where vs.first_lesson_id is not null
      and intro.sequence_number < l.sequence_number
  ), '[]'::jsonb) as previously_introduced_vocabulary

from public.lessons l;


commit;
