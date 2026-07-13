-- Curriculum sequencer context
-- ============================================================
-- Doel: alle data verzamelen die nodig is om AI te laten voorstellen
-- wat de VOLGENDE dialoogles zou moeten worden — vóór er een
-- `lessons`-rij of `dialog_blueprint_specs`-rij bestaat.
--
-- Dit is bewust geen builder-query zoals 03: dit bestand draait
-- vóór Stap 2 van de workflow-gids, dus er is nog geen doelles om
-- naartoe te joinen. In plaats daarvan leest dit bestand rechtstreeks
-- uit de status-tabellen (vocabulary_status, grammar_status,
-- phrase_status, pattern_status) en de mastertabellen.
--
-- Gebruik: voer elke sectie apart uit in Supabase Studio (net als
-- 01_debug_lesson_blueprint.sql en 02_debug_continuity_options.sql),
-- en plak de resultaten in 05_curriculum_sequencer_prompt_template.md.
--
-- Waarom niet gewoon lesson_available_vocabulary_view hergebruiken?
-- Die view berekent "alles geïntroduceerd VOOR les X" — maar les X
-- (de volgende les) bestaat hier nog niet. Sectie 2 hieronder gebruikt
-- daarom dezelfde onderliggende logica (status-tabellen + join op
-- de introductieles se sequence_number) maar zonder bovengrens:
-- "alles wat tot nu toe al ooit is geïntroduceerd".
-- ============================================================


-- ============================================================
-- SECTIE 1 — Curriculumvoortgang
-- ============================================================
-- Volgend beschikbaar sequence_number + hoeveel kandidaten er nog
-- ongebruikt in elke masterlijst zitten. Handig als snel overzicht
-- vóór je de rest doorneemt.
--
-- Let op: sequence_number is niet globaal uniek, maar uniek per
-- (cefr_level, section_key) — zie constraint
-- lessons_level_section_sequence_unique (migratie
-- 20260511185559_alter_lessons_for_phase_2.sql). De berekening
-- hieronder is daarom gescoped op 'A1' / 'dialogs'. Plan je een les
-- in een ander niveau of sectie, pas dan deze where-clausule aan.

select
  (select coalesce(max(sequence_number), 0) + 1
     from public.lessons
     where cefr_level = 'A1' and section_key = 'dialogs') as next_sequence_number,
  (select count(*) from public.vocabulary_status where status = 'new') as vocabulary_unused_count,
  (select count(*) from public.vocabulary_master)                     as vocabulary_total_count,
  (select count(*) from public.grammar_status where status = 'new')   as grammar_unused_count,
  (select count(*) from public.grammar_master)                       as grammar_total_count,
  (select count(*) from public.phrase_status where status = 'new')    as phrase_unused_count,
  (select count(*) from public.phrase_master)                        as phrase_total_count,
  (select count(*) from public.pattern_status where status = 'new')   as pattern_unused_count,
  (select count(*) from public.pattern_master)                       as pattern_total_count;


-- ============================================================
-- SECTIE 2 — Alles wat tot nu toe al geïntroduceerd is
-- ============================================================
-- Eén leesbare lijst per categorie, over ALLE bestaande lessen heen
-- (niet gebonden aan één specifieke doelles, in tegenstelling tot
-- de allowed_*_list-kolommen in 03_build_dialog_lesson_blueprint.sql).

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


-- ============================================================
-- SECTIE 3 — Ongebruikte kandidatenpool: vocabulaire
-- ============================================================
-- Woorden met status = 'new', gegroepeerd per thema en woordsoort.
-- De buitenste string_agg verzamelt alle groepen tot één cel, zodat
-- je het resultaat in één keer kan kopiëren en direct kan plakken
-- op {{vocabulary_candidate_pool}} in de sequencer-prompt-template
-- — zonder elk van de N groep-rijen apart te moeten overnemen.

with pool as (
  select
    vm.default_theme,
    vm.part_of_speech,
    string_agg(
      concat(vm.thai_script, ' (', vm.paiboon, ') = ', vm.english_gloss),
      E'\n' order by vm.thai_script
    ) as candidates
  from public.vocabulary_master vm
  join public.vocabulary_status vs on vs.vocabulary_id = vm.id
  where vs.status = 'new'
  group by vm.default_theme, vm.part_of_speech
)
select string_agg(
  concat(
    '**', coalesce(default_theme, '(geen thema)'), ' — ',
    coalesce(part_of_speech, '(geen woordsoort)'), '**', E'\n', candidates
  ),
  E'\n\n' order by default_theme nulls last, part_of_speech nulls last
) as vocabulary_candidate_pool
from pool;


-- ============================================================
-- SECTIE 3b — Ongebruikte kandidatenpool: grammatica
-- ============================================================

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


-- ============================================================
-- SECTIE 3c — Ongebruikte kandidatenpool: phrases
-- ============================================================

with pool as (
  select
    pm.phrase_type,
    string_agg(
      concat(pm.title, ': ', coalesce(pm.phrase_formula, '')),
      E'\n' order by pm.title
    ) as candidates
  from public.phrase_master pm
  join public.phrase_status ps on ps.phrase_id = pm.id
  where ps.status = 'new'
  group by pm.phrase_type
)
select string_agg(
  concat('**', coalesce(phrase_type, '(geen type)'), '**', E'\n', candidates),
  E'\n\n' order by phrase_type nulls last
) as phrase_candidate_pool
from pool;


-- ============================================================
-- SECTIE 3d — Ongebruikte kandidatenpool: patterns
-- ============================================================

with pool as (
  select
    pam.pattern_type,
    string_agg(
      concat(pam.title, ': ', coalesce(pam.pattern_formula, '')),
      E'\n' order by pam.title
    ) as candidates
  from public.pattern_master pam
  join public.pattern_status pas on pas.pattern_id = pam.id
  where pas.status = 'new'
  group by pam.pattern_type
)
select string_agg(
  concat('**', coalesce(pattern_type, '(geen type)'), '**', E'\n', candidates),
  E'\n\n' order by pattern_type nulls last
) as pattern_candidate_pool
from pool;


-- ============================================================
-- SECTIE 4 — Laatste dialogen (volledige tekst, voor toon/continuïteit)
-- ============================================================
-- Pas de limit aan als je meer dan de laatste 2 dialogen wil zien.
--
-- Zelfde reden voor de where-clausule als in Sectie 1: sequence_number
-- is uniek per (cefr_level, section_key), niet globaal. "De vorige
-- dialoog" moet de vorige les IN DIT TRAJECT zijn, anders kan een les
-- uit een ander niveau/sectie hier tussenkomen zodra die ooit bestaat.

-- De binnenste query gebruikt DESC + LIMIT om de MEEST RECENTE 2
-- dialogen te selecteren. De buitenste query sorteert die selectie
-- daarna weer ASC, zodat de uiteindelijke leesvolgorde chronologisch
-- is (oudste eerst, nieuwste laatst) — prettiger leesbaar voor de AI
-- die de volgende les voorstelt, als doorlopend verhaal.
select * from (
  select
    l.sequence_number,
    l.lesson_key,
    d.title,
    d.scene_summary,
    string_agg(
      concat(
        coalesce(db.speaker_key, '?'), ': ',
        db.thai_text, ' (', coalesce(db.transliteration, ''), ') — ',
        coalesce(db.translation_en, '')
      ),
      E'\n' order by db.block_index
    ) as dialog_text
  from public.dialogs d
  join public.lessons l on l.id = d.lesson_id
  join public.dialog_blocks db on db.dialog_id = d.id
  where l.cefr_level = 'A1' and l.section_key = 'dialogs'
  group by l.sequence_number, l.lesson_key, d.title, d.scene_summary
  order by l.sequence_number desc
  limit 2
) recent
order by sequence_number asc;


-- ============================================================
-- SECTIE 5 — Actieve relatie-/personagecontext
-- ============================================================
-- Zelfde bron als 02_debug_continuity_options.sql, maar hier
-- samengevat tot leesbare tekst per relatiepaar (i.p.v. de ruwe
-- view-rijen met interne ids en een jsonb-kolom) en tot één cel
-- geaggregeerd, zodat je het resultaat weer in één keer kan
-- kopiëren naar {{continuity_options}}.

with rules_flat as (
  select
    lco.relationship_pair_id,
    string_agg(
      concat('  - ', r ->> 'rule_key', ': ', r ->> 'rule_text'),
      E'\n' order by r ->> 'rule_key'
    ) as rules_text
  from public.lesson_continuity_options_view lco
  cross join lateral jsonb_array_elements(lco.relationship_rules) as r
  group by lco.relationship_pair_id
),
pairs as (
  select
    lco.relationship_pair_id,
    lco.character_a_name,
    lco.character_a_name_thai,
    lco.character_a_role_summary,
    lco.character_a_age_impression,
    lco.character_a_default_tone,
    lco.character_a_default_usage,
    lco.character_b_name,
    lco.character_b_name_thai,
    lco.character_b_role_summary,
    lco.character_b_age_impression,
    lco.character_b_default_tone,
    lco.character_b_default_usage,
    lco.current_stage,
    lco.start_state,
    lco.function_summary,
    lco.allowed_progression,
    coalesce(rf.rules_text, '  - (geen regels)') as rules_text
  from public.lesson_continuity_options_view lco
  left join rules_flat rf on rf.relationship_pair_id = lco.relationship_pair_id
)
select string_agg(
  concat(
    '**Pair ', relationship_pair_id, ': ', character_a_name, ' (', character_a_name_thai, ') & ',
    character_b_name, ' (', character_b_name_thai, ')**', E'\n',
    '- ', character_a_name, ': ', character_a_role_summary, ' — ', character_a_age_impression,
    ', tone: ', character_a_default_tone, ', usage: ', character_a_default_usage, E'\n',
    '- ', character_b_name, ': ', character_b_role_summary, ' — ', character_b_age_impression,
    ', tone: ', character_b_default_tone, ', usage: ', character_b_default_usage, E'\n',
    '- Current stage: ', current_stage, ' (start: ', start_state, ')', E'\n',
    '- Function: ', function_summary, E'\n',
    '- Allowed progression: ', allowed_progression, E'\n',
    '- Relationship rules:', E'\n', rules_text
  ),
  E'\n\n' order by relationship_pair_id
) as continuity_options
from pairs;
