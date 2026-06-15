-- Dialog lesson blueprint query
-- ============================================================
-- Haalt alle gegevens op die nodig zijn om een AI-dialoog te genereren
-- voor een les van het type 'dialog'.
--
-- Bronnen:
--   required_vocabulary_list  ← lesson_blueprint_view.all_vocabulary
--                               (alle woorden in lesson_vocabulary voor deze les;
--                                voor dialoglessen uitsluitend role='target')
--
--   allowed_vocabulary_list   ← lesson_available_vocabulary_view.previously_introduced_vocabulary
--                               (ALLE woorden die de leerling al kent uit vorige lessen,
--                                gesorteerd op curriculum-positie via sequence_number)
--
-- Vereenvoudigd t.o.v. vorige versie:
--   - lesson_vocabulary_control_view verwijderd (niet nodig voor dialoglessen)
--   - lesson_available_vocabulary_view toegevoegd als bron voor allowed vocabulary
--   - must_use_new_list verwijderd (zelfde inhoud als required_vocabulary_list)
--   - may_reuse_previous_list verwijderd (was dubbel van allowed_review_vocabulary_list)
--   - allowed_review_vocabulary_list hernoemd naar allowed_vocabulary_list
-- ============================================================

select

  -- ── Lesson goal (volgorde = prompt template §Lesson Goal) ──────────────────
  lb.lesson_key,
  lb.cefr_level,
  lb.lesson_title,
  lb.subtitle,
  ds.learning_focus,
  ds.scene_summary,

  -- ── Curriculum core (volgorde = prompt template §Curriculum Core) ──────────
  coalesce(rv.required_vocabulary_list,  '- none') as required_vocabulary_list,
  coalesce(av.allowed_vocabulary_list,   '- none') as allowed_vocabulary_list,
  coalesce(rp.required_phrases_list,     '- none') as required_phrases_list,
  coalesce(rg.required_grammar_list,     '- none') as required_grammar_list,
  coalesce(rpat.required_patterns_list,  '- none') as required_patterns_list,

  -- ── Speaker A (volgorde = prompt template §Speaker A) ──────────────────────
  lc.character_a_name           as speaker_a_name,
  lc.character_a_name_thai      as speaker_a_name_thai,
  lc.character_a_key            as speaker_a_key,
  lc.character_a_role_summary   as speaker_a_role_summary,
  lc.character_a_age_impression as speaker_a_age_impression,
  coalesce(sa.speaker_a_default_tone,    '- none') as speaker_a_default_tone,
  coalesce(sau.speaker_a_default_usage,  '- none') as speaker_a_default_usage,

  -- ── Speaker B (volgorde = prompt template §Speaker B) ──────────────────────
  lc.character_b_name           as speaker_b_name,
  lc.character_b_name_thai      as speaker_b_name_thai,
  lc.character_b_key            as speaker_b_key,
  lc.character_b_role_summary   as speaker_b_role_summary,
  lc.character_b_age_impression as speaker_b_age_impression,
  coalesce(sb.speaker_b_default_tone,    '- none') as speaker_b_default_tone,
  coalesce(sbu.speaker_b_default_usage,  '- none') as speaker_b_default_usage,

  -- ── Relationship context (volgorde = prompt template §Relationship Context) ─
  lc.start_state,
  lc.current_stage,
  lc.function_summary,
  coalesce(ap.allowed_progression,       '- none') as allowed_progression,
  coalesce(rr.relationship_rules_list,   '- none') as relationship_rules_list,

  -- ── Dialogue design (volgorde = prompt template §Dialogue Design) ───────────
  ds.scene_type,
  ds.suggested_location,
  ds.allowed_register,
  ds.estimated_line_count,
  coalesce(dc.dialogue_constraints_list, '- none') as dialogue_constraints_list,

  -- ── Intern / meta (niet nodig voor prompt, handig voor QA) ─────────────────
  lb.lesson_id,
  lb.lesson_type,
  lb.sequence_number,
  lb.section_key,
  lb.is_published,
  lc.relationship_pair_id,
  lc.character_a_id,
  lc.character_b_id

from public.lesson_blueprint_view lb

join public.lesson_available_vocabulary_view lav
  on lav.lesson_id = lb.lesson_id

join public.dialog_blueprint_specs ds
  on ds.lesson_id = lb.lesson_id

join public.lesson_continuity_options_view lc
  on lc.relationship_pair_id = ds.relationship_pair_id

-- Verplichte vocabulaire: de target-woorden voor deze les
left join lateral (
  select string_agg(
    concat('- ', x->>'thai_script', ' (', x->>'paiboon', ') = ', x->>'english_gloss'),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), x->>'thai_script'
  ) as required_vocabulary_list
  from jsonb_array_elements(coalesce(lb.all_vocabulary, '[]'::jsonb)) x
) rv on true

-- Toegelaten vocabulaire: alle eerder geïntroduceerde woorden (curriculum-volgorde)
left join lateral (
  select string_agg(
    concat('- ', x->>'thai_script', ' (', x->>'paiboon', ') = ', x->>'english_gloss'),
    E'\n'
    order by coalesce((x->>'intro_sequence_number')::int, 9999), x->>'thai_script'
  ) as allowed_vocabulary_list
  from jsonb_array_elements(coalesce(lav.previously_introduced_vocabulary, '[]'::jsonb)) x
) av on true

-- Verplichte phrases
left join lateral (
  select string_agg(
    concat(
      '- ',
      coalesce(x->>'title', 'Untitled phrase'),
      ': ',
      coalesce(x->>'phrase_formula', ''),
      case
        when coalesce(x->>'short_explanation', '') <> ''
        then concat(' — ', x->>'short_explanation')
        else ''
      end
    ),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', '')
  ) as required_phrases_list
  from jsonb_array_elements(coalesce(lb.all_phrases, '[]'::jsonb)) x
) rp on true

-- Verplichte grammatica
left join lateral (
  select string_agg(
    concat(
      '- ',
      coalesce(x->>'title', 'Untitled grammar'),
      case
        when coalesce(x->>'short_explanation', '') <> ''
        then concat(': ', x->>'short_explanation')
        else ''
      end
    ),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', '')
  ) as required_grammar_list
  from jsonb_array_elements(coalesce(lb.all_grammar, '[]'::jsonb)) x
) rg on true

-- Verplichte patronen
left join lateral (
  select string_agg(
    concat('- ', coalesce(x->>'title', x->>'pattern_key', 'pattern')),
    E'\n'
    order by coalesce((x->>'display_order')::int, 9999), coalesce(x->>'title', x->>'pattern_key', '')
  ) as required_patterns_list
  from jsonb_array_elements(coalesce(lb.all_patterns, '[]'::jsonb)) x
) rpat on true

-- Karaktereigenschappen
left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as speaker_a_default_tone
  from unnest(coalesce(lc.character_a_default_tone, array[]::text[])) with ordinality as t(value, ord)
) sa on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as speaker_a_default_usage
  from unnest(coalesce(lc.character_a_default_usage, array[]::text[])) with ordinality as t(value, ord)
) sau on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as speaker_b_default_tone
  from unnest(coalesce(lc.character_b_default_tone, array[]::text[])) with ordinality as t(value, ord)
) sb on true

left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as speaker_b_default_usage
  from unnest(coalesce(lc.character_b_default_usage, array[]::text[])) with ordinality as t(value, ord)
) sbu on true

-- Relatie-informatie
left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as allowed_progression
  from unnest(coalesce(lc.allowed_progression, array[]::text[])) with ordinality as t(value, ord)
) ap on true

left join lateral (
  select string_agg(
    concat('- ', coalesce(x->>'rule_key', 'rule'), ': ', coalesce(x->>'rule_text', '')),
    E'\n'
    order by ord
  ) as relationship_rules_list
  from jsonb_array_elements(coalesce(lc.relationship_rules, '[]'::jsonb)) with ordinality as t(x, ord)
) rr on true

-- Dialoogbeperkingen (vaste lijst + extra constraints uit dialog_blueprint_specs)
left join lateral (
  select string_agg(concat('- ', value), E'\n' order by ord) as dialogue_constraints_list
  from jsonb_array_elements_text(
    jsonb_build_array(
      'short lines only',
      'one communicative move per line',
      'beginner-safe Thai only',
      'use polite particles consistently',
      'no flirting or intimacy',
      'no important new grammar outside lesson scope'
    ) || coalesce(ds.extra_constraints, '[]'::jsonb)
  ) with ordinality as t(value, ord)
) dc on true

where lb.lesson_key = 'a1-dialog-03';
