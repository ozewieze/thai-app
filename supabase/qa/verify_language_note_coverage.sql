-- ============================================================
-- Verificatie: is alles wat uitleg vereist ook uitgelegd?
-- ============================================================
-- Draaien met:
--   psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -A -P pager=off -f supabase/qa/verify_language_note_coverage.sql
--
-- (Eén regel. `\` is bash-syntax en werkt niet in PowerShell; zie
-- "psql op Windows" in docs/thai_a1_dialog_workflow_guide.md.)
--
-- Dit script is **alleen-lezen**. Anders dan
-- verify_language_note_seed_format.sql schrijft het niets, dus er is
-- geen transactie en geen rollback nodig. Je kunt het op elk moment
-- draaien, ook op een database waar je verder mee bezig bent.
--
-- ------------------------------------------------------------
-- Wat dit beantwoordt, en waarom het bestaat
-- ------------------------------------------------------------
-- Stap 9 van docs/thai_a1_language_note_workflow_guide.md somt op wat
-- er vóór publicatie moet kloppen. Punt 1 daarvan --  elk lesconcept
-- met requires_explanation = true is gekoppeld aan minstens één note
-- van diezelfde les -- is alleen te beantwoorden via
-- language_note_concepts. `requires_explanation` zegt "dit heeft uitleg
-- nodig"; de koppeltabel zegt "en hier staat die uitleg". Zonder een
-- query die de twee tegen elkaar legt, zijn het twee lijsten waar
-- niemand iets mee kan.
--
-- Tot dit script bestond was language_note_concepts schrijf-alleen
-- data: de generator vulde de tabel, en de enige lezers waren twee
-- QA-scripts die het invoegmechanisme testen, niet de inhoud. Dat is de
-- vervelendste soort data -- ze wordt verzameld, ze wordt niet gelezen,
-- en fouten stapelen zich stil op.
--
-- ------------------------------------------------------------
-- Wat dit NIET kan zien
-- ------------------------------------------------------------
-- Een **valse claim**. Of een note een concept werkelijk uitlegt of het
-- alleen terloops noemt, is een redactioneel oordeel; dit script telt
-- alleen of de claim bestaat. Een note die drie concepten claimt en er
-- één uitlegt, komt hier als volledig gedekt uit. De toets uit Stap 6
-- ("zou een leerling na het lezen van deze note dit concept
-- begrijpen?") blijft mensenwerk, en dit script maakt die controle niet
-- overbodig -- het maakt haar alleen vindbaar.
--
-- Een les waarvan de Language Note-workflow nog niet gestart is, komt
-- in sectie 1 apart te staan in plaats van als een berg gaten in
-- sectie 2. Dat is geen defect maar werk dat nog moet gebeuren.
-- ============================================================


-- ------------------------------------------------------------
-- Gemeenschappelijke basis
-- ------------------------------------------------------------
-- De vier soorten lesconcepten wonen in vier tabellen met vier
-- verschillende mastersleutels, en language_note_concepts heeft
-- daarvoor vier armen waarvan er per rij precies één gevuld is
-- (language_note_concepts_exactly_one_check). Beide kanten worden
-- hieronder platgeslagen tot (lesson_id, soort, link_id), zodat de
-- vergelijking één join is in plaats van vier.
--
-- Er wordt op link_id vergeleken en niet op de mastersleutel: de
-- koppeltabel wijst naar de koppelrij van deze les, niet naar de
-- masterrij. Zie de waarschuwing in Stap 1 van de gids.

-- De drops maken het script herbruikbaar binnen één psql-sessie. Draai je
-- het met `-f`, dan verdwijnen de temp views vanzelf bij het afsluiten;
-- draai je het twee keer met `\i` in een open sessie, dan faalt de tweede
-- run zonder deze regels op "relation already exists".
drop view if exists ln_gevlagd;
drop view if exists ln_geclaimd;

create temporary view ln_gevlagd as
  select lv.lesson_id, 'vocabulary'::text as soort, vm.source_key   as sleutel, lv.id as link_id
    from public.lesson_vocabulary lv
    join public.vocabulary_master vm on vm.id = lv.vocabulary_id
   where lv.requires_explanation
  union all
  select lg.lesson_id, 'grammar', gm.concept_key, lg.id
    from public.lesson_grammar lg
    join public.grammar_master gm on gm.id = lg.grammar_id
   where lg.requires_explanation
  union all
  select lp.lesson_id, 'phrase', pm.phrase_key, lp.id
    from public.lesson_phrase lp
    join public.phrase_master pm on pm.id = lp.phrase_id
   where lp.requires_explanation
  union all
  select lpat.lesson_id, 'pattern', patm.pattern_key, lpat.id
    from public.lesson_pattern lpat
    join public.pattern_master patm on patm.id = lpat.pattern_id
   where lpat.requires_explanation;

create temporary view ln_geclaimd as
  select lesson_id, 'vocabulary'::text as soort, lesson_vocabulary_id as link_id, language_note_id
    from public.language_note_concepts where lesson_vocabulary_id is not null
  union all
  select lesson_id, 'grammar', lesson_grammar_id, language_note_id
    from public.language_note_concepts where lesson_grammar_id is not null
  union all
  select lesson_id, 'phrase', lesson_phrase_id, language_note_id
    from public.language_note_concepts where lesson_phrase_id is not null
  union all
  select lesson_id, 'pattern', lesson_pattern_id, language_note_id
    from public.language_note_concepts where lesson_pattern_id is not null;


\echo ''
\echo '=== 1. Samenvatting per les ==='
\echo '    status "geen notes" = workflow nog niet gestart, geen defect.'
\echo '    gaten > 0 blokkeert publicatie (Stap 9, punt 1).'
\echo ''

select
  l.lesson_key,
  count(distinct g.link_id)                                    as gevlagd,
  count(distinct g.link_id) filter (
    where exists (select 1 from ln_geclaimd c
                   where c.lesson_id = g.lesson_id
                     and c.soort     = g.soort
                     and c.link_id   = g.link_id))             as gedekt,
  count(distinct g.link_id) filter (
    where not exists (select 1 from ln_geclaimd c
                       where c.lesson_id = g.lesson_id
                         and c.soort     = g.soort
                         and c.link_id   = g.link_id))         as gaten,
  (select count(*) from public.language_notes n
    where n.lesson_id = l.id)                                  as notes,
  case
    when (select count(*) from public.language_notes n where n.lesson_id = l.id) = 0
      then 'geen notes'
    when count(distinct g.link_id) filter (
      where not exists (select 1 from ln_geclaimd c
                         where c.lesson_id = g.lesson_id
                           and c.soort     = g.soort
                           and c.link_id   = g.link_id)) > 0
      then 'GATEN'
    else 'volledig'
  end                                                          as status
from public.lessons l
left join ln_gevlagd g on g.lesson_id = l.id
group by l.id, l.lesson_key, l.sequence_number
having count(g.link_id) > 0 or (select count(*) from public.language_notes n where n.lesson_id = l.id) > 0
order by l.sequence_number;


\echo ''
\echo '=== 2. Gaten: gevlagd concept zonder note ==='
\echo '    Alleen lessen waarvan de workflow gestart is (>= 1 note).'
\echo '    Verwacht: geen rijen.'
\echo ''

select l.lesson_key, g.soort, g.sleutel
from ln_gevlagd g
join public.lessons l on l.id = g.lesson_id
where exists (select 1 from public.language_notes n where n.lesson_id = g.lesson_id)
  and not exists (
    select 1 from ln_geclaimd c
     where c.lesson_id = g.lesson_id
       and c.soort     = g.soort
       and c.link_id   = g.link_id)
order by l.sequence_number, g.soort, g.sleutel;


\echo ''
\echo '=== 3. Weesnotes: note zonder enige conceptclaim ==='
\echo '    De generator laat "concepts": [] door, dus dit is de enige'
\echo '    plek waar zo een note opvalt. Verwacht: geen rijen.'
\echo ''

select l.lesson_key, n.note_key, n.title
from public.language_notes n
join public.lessons l on l.id = n.lesson_id
where not exists (
  select 1 from public.language_note_concepts c where c.language_note_id = n.id)
order by l.sequence_number, n.display_order;


\echo ''
\echo '=== 4. Claims die niet uitgelegd kunnen zijn ==='
\echo '    Lege note (Stap 9, punt 3) of lege voorbeeldgroep (punt 4).'
\echo '    Verwacht: geen rijen.'
\echo ''

select l.lesson_key, n.note_key, 'note zonder blokken'::text as probleem, null::text as block_key
from public.language_notes n
join public.lessons l on l.id = n.lesson_id
where not exists (select 1 from public.language_note_blocks b where b.language_note_id = n.id)
union all
select l.lesson_key, n.note_key, 'example_group zonder voorbeelden', b.block_key
from public.language_note_blocks b
join public.language_notes n on n.id = b.language_note_id
join public.lessons l on l.id = n.lesson_id
where b.block_type = 'example_group'
  and not exists (select 1 from public.language_note_examples e where e.block_id = b.id)
order by 1, 2, 4;


\echo ''
\echo '=== 5. Audio (Stap 9, punt 5) ==='
\echo '    Informatief. Het audioscript voor Language Notes bestaat nog'
\echo '    niet (Stap 8), dus zonder_audio hoort nu gelijk te zijn aan'
\echo '    totaal. Wordt vanzelf zinvol zodra dat script er is.'
\echo ''

select
  count(*)                                as totaal,
  count(*) filter (where audio_url is null) as zonder_audio
from public.language_note_examples;


\echo ''
\echo '=== Einde. Er is niets geschreven. ==='
