-- ============================================================
-- View: language_note_brief_view
-- ============================================================
-- Doel: per les één stabiele briefing opleveren voor het schrijven
-- van Language Notes (zie docs/thai_a1_language_note_workflow_guide.md,
-- Stap 1 t/m 6). Deze view is de input van de AI-prompt die notes
-- genereert, analoog aan wat lesson_blueprint_view voor de
-- dialoogworkflow doet.
--
-- Deze view ontsluit bewust weinig nieuws: lesson_blueprint_view geeft
-- de lesconcepten al inclusief requires_explanation, en
-- lesson_available_vocabulary_view geeft previously_introduced_vocabulary
-- al. De winst is één contract in plaats van drie queries die met de
-- hand samengevoegd worden. Drie dingen zijn wél nieuw en zijn de
-- eigenlijke reden dat deze view bestaat:
--
--   1. De link-rij-id (lesson_vocabulary.id, lesson_grammar.id, ...)
--      gaat mee. language_note_concepts verwijst naar de link-rij, niet
--      naar de master-rij, via een samengestelde FK op
--      (lesson_*_id, lesson_id). Zonder die id is de output van de
--      schrijfprompt niet om te zetten naar een insert (Stap 6).
--   2. Het woordbudget voor voorbeeldzinnen is gededupliceerd
--      samengevoegd uit twee bronnen: de lesset van deze les en alles
--      wat in een eerdere les geïntroduceerd is.
--   3. Elk budgetwoord draagt zijn paiboon-vorm. ChatGPT heeft geen
--      databasetoegang; wat niet in de prompt staat wordt
--      gereconstrueerd, en dan komt de RTGS-fout terug (kh/th/ph in
--      plaats van k/t/p, gecorrigeerd op 2026-07-13 over 167
--      vocabulairerijen en 19 dialoogblokken). Zie Stap 5 van de gids.
--
-- Sleutels gaan altijd mee naast de leesbare velden. source_key is
-- uniek in vocabulary_master, thai_script niet: เดือน bestaat twee keer
-- (month en calendar_month), identiek op script, paiboon, gloss en
-- woordsoort. Alleen de sleutel houdt die uit elkaar. De leesbare
-- velden zijn context voor het model, de sleutel is de identificatie.
--
-- security_invoker = true, zoals alle views in dit project: de view
-- draait met de rechten van de aanroeper, zodat de RLS-policies op de
-- onderliggende tabellen blijven gelden. Zonder deze optie zou een
-- anon-lezer via de view ongepubliceerde lessen kunnen zien.
-- ============================================================

drop view if exists public.language_note_brief_view;

create or replace view public.language_note_brief_view
  with (security_invoker = true)
as
select
  l.id as lesson_id,
  l.lesson_key,
  l.title    as lesson_title,
  l.subtitle as lesson_subtitle,
  l.cefr_level,
  l.lesson_type,
  l.section_key,
  l.sequence_number,
  l.is_published,

  -- ---------------------------------------------------------
  -- 1. Concepten met requires_explanation = true
  --
  -- Vier aparte arrays in plaats van één lijst met een
  -- soort-discriminator: de mastervelden verschillen per soort, en
  -- één array zou objecten opleveren die voor de helft leeg zijn.
  -- Deze vorm volgt lesson_blueprint_view.
  --
  -- Geen filter op role: vandaag is elke geseede link-rij 'target',
  -- maar de vlag is de opdrachtenlijst, niet de rol (zie Stap 3 van
  -- de dialoogworkflowgids). Een gevlagd concept met een andere rol
  -- hoort net zo goed uitgelegd te worden.
  -- ---------------------------------------------------------

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'lesson_vocabulary_id', lv.id,
        'vocabulary_id',        vm.id,
        'source_key',           vm.source_key,
        'thai_script',          vm.thai_script,
        'paiboon',              vm.paiboon,
        'english_gloss',        vm.english_gloss,
        'part_of_speech',       vm.part_of_speech,
        'register',             vm.register,
        'usage_note',           vm.usage_note,
        'is_multifunctional',   vm.is_multifunctional,
        'lesson_role',          lv.role,
        'display_order',        lv.display_order,
        'lesson_notes',         lv.notes
      )
      order by lv.display_order nulls first, lv.id
    )
    from public.lesson_vocabulary lv
    join public.vocabulary_master vm on vm.id = lv.vocabulary_id
    where lv.lesson_id = l.id
      and lv.requires_explanation
  ), '[]'::jsonb) as vocabulary_to_explain,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'lesson_grammar_id',  lg.id,
        'grammar_id',         gm.id,
        'concept_key',        gm.concept_key,
        'title',              gm.title,
        'short_explanation',  gm.short_explanation,
        'concept_type',       gm.concept_type,
        'register',           gm.register,
        'lesson_role',        lg.role,
        'display_order',      lg.display_order,
        'lesson_notes',       lg.notes
      )
      order by lg.display_order nulls first, lg.id
    )
    from public.lesson_grammar lg
    join public.grammar_master gm on gm.id = lg.grammar_id
    where lg.lesson_id = l.id
      and lg.requires_explanation
  ), '[]'::jsonb) as grammar_to_explain,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'lesson_phrase_id',   lp.id,
        'phrase_id',          pm.id,
        'phrase_key',         pm.phrase_key,
        'title',              pm.title,
        'phrase_formula',     pm.phrase_formula,
        'short_explanation',  pm.short_explanation,
        'phrase_type',        pm.phrase_type,
        'register',           pm.register,
        'fixedness_level',    pm.fixedness_level,
        'is_productive',      pm.is_productive,
        'lesson_role',        lp.role,
        'display_order',      lp.display_order,
        'lesson_notes',       lp.notes
      )
      order by lp.display_order nulls first, lp.id
    )
    from public.lesson_phrase lp
    join public.phrase_master pm on pm.id = lp.phrase_id
    where lp.lesson_id = l.id
      and lp.requires_explanation
  ), '[]'::jsonb) as phrases_to_explain,

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'lesson_pattern_id',  lpat.id,
        'pattern_id',         patm.id,
        'pattern_key',        patm.pattern_key,
        'title',              patm.title,
        'pattern_formula',    patm.pattern_formula,
        'short_explanation',  patm.short_explanation,
        'pattern_type',       patm.pattern_type,
        'register',           patm.register,
        'fixedness_level',    patm.fixedness_level,
        'is_productive',      patm.is_productive,
        'lesson_role',        lpat.role,
        'display_order',      lpat.display_order,
        'lesson_notes',       lpat.notes
      )
      order by lpat.display_order nulls first, lpat.id
    )
    from public.lesson_pattern lpat
    join public.pattern_master patm on patm.id = lpat.pattern_id
    where lpat.lesson_id = l.id
      and lpat.requires_explanation
  ), '[]'::jsonb) as patterns_to_explain,

  -- ---------------------------------------------------------
  -- 2. Woordbudget voor voorbeeldzinnen
  --
  -- Twee bronnen in één lijst:
  --   - de volledige lesset van deze les (elke rij in
  --     lesson_vocabulary, ongeacht role). Stap 4 van de LN-gids:
  --     voorbeelden gebruiken uitsluitend vocabulaire uit deze les of
  --     eerdere lessen. Rollen als 'review' of 'supporting' horen er
  --     dus bij — ook die woorden kent de leerling.
  --   - alles wat in een les met een lager sequence_number
  --     geïntroduceerd is (dezelfde filter als
  --     lesson_available_vocabulary_view).
  --
  -- Dedupe: een woord kan in beide bronnen zitten (een woord dat aan
  -- deze les gelinkt is én al eerder geïntroduceerd). De query gaat
  -- daarom uit van vocabulary_master met left joins, zodat er per
  -- woord hoogstens één rij ontstaat. lesson_vocabulary heeft
  -- unique (lesson_id, vocabulary_id), dus de left join naar lv kan
  -- niet vermenigvuldigen.
  --
  -- availability zegt waar het woord vandaan komt; in_lesson_set zegt
  -- of het aan deze les gekoppeld is. Die twee zijn niet hetzelfde:
  -- een woord met role 'review' is gekoppeld én eerder geïntroduceerd.
  -- intro_sequence_number komt altijd uit vocabulary_status en is dus
  -- ook voor zulke woorden de waarheid.
  -- ---------------------------------------------------------

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
        'usage_note',            vm.usage_note,
        'availability',          case
                                   when intro.sequence_number = l.sequence_number
                                     then 'this_lesson'
                                   else 'previous'
                                 end,
        'in_lesson_set',         (lv.id is not null),
        'lesson_role',           lv.role,
        'intro_sequence_number', intro.sequence_number
      )
      order by intro.sequence_number nulls last,
               lv.display_order nulls first,
               vm.id
    )
    from public.vocabulary_master vm
    left join public.vocabulary_status vs
           on vs.vocabulary_id = vm.id
    left join public.lessons intro
           on intro.id = vs.first_lesson_id
    left join public.lesson_vocabulary lv
           on lv.vocabulary_id = vm.id
          and lv.lesson_id = l.id
    where lv.id is not null
       or (intro.sequence_number is not null
           and intro.sequence_number < l.sequence_number)
  ), '[]'::jsonb) as example_vocabulary_budget,

  -- ---------------------------------------------------------
  -- 3. De dialoog van deze les als context
  --
  -- dialogs heeft unique (lesson_id), dus hoogstens één dialoog per
  -- les: één object, geen array. Null wanneer de dialoog nog niet
  -- geseed is -- de LN-workflow hoort dan sowieso nog niet te starten
  -- (de gids: pas beginnen nadat de dialoog goedgekeurd en opgeslagen
  -- is).
  --
  -- audio_url en de timings blijven eruit: de prompt heeft de tekst
  -- nodig, niet de media.
  -- ---------------------------------------------------------

  (
    select jsonb_build_object(
      'dialog_id',      d.id,
      'title',          d.title,
      'subtitle',       d.subtitle,
      'register',       d.register,
      'scene_summary',  d.scene_summary,
      'learning_focus', d.learning_focus,
      'blocks', coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'block_index',     db.block_index,
            'speaker_key',     db.speaker_key,
            'thai_text',       db.thai_text,
            'transliteration', db.transliteration,
            'translation_en',  db.translation_en
          )
          order by db.block_index
        )
        from public.dialog_blocks db
        where db.dialog_id = d.id
      ), '[]'::jsonb)
    )
    from public.dialogs d
    where d.lesson_id = l.id
  ) as dialog

from public.lessons l;


-- ============================================================
-- Grants
-- ============================================================
-- Least-privilege, volgens de conventie van
-- 20260617120000_grant_api_access.sql: alleen select, en alleen voor
-- de rollen die het nodig hebben.
--
-- anon/authenticated krijgen select voor consistentie met de andere
-- views. Dat lekt niets: security_invoker = true betekent dat de
-- RLS-policies op lessons, lesson_*, *_master, vocabulary_status,
-- dialogs en dialog_blocks gewoon gelden -- die geven anon alleen
-- toegang tot gepubliceerde lessen.
--
-- Bewust geen grant voor service_role. Er is vandaag geen script dat
-- deze view leest; de briefing wordt via psql als postgres opgehaald.
-- Zodra er wel een script komt, hoort dat een eigen migratie te zijn
-- met een eigen motivering, zoals
-- 20260716120100_grant_service_role_select_status_link_tables.sql.
-- ============================================================

grant select on table public.language_note_brief_view to anon, authenticated;
