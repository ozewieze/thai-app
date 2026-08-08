-- ============================================================
-- View: vocabulary_example_brief_view
-- ============================================================
-- Doel: per les één stabiele briefing opleveren voor het schrijven
-- van canonieke voorbeelden bij Vocabulary Cards (zie
-- docs/thai_a1_vocabulary_workflow_guide.md, Stap 1 en 2). Deze view
-- is de input van de AI-prompt die voorbeelden genereert, analoog aan
-- wat language_note_brief_view voor de Language Notes doet.
--
-- De view beantwoordt Stap 1 en Stap 2 in één query:
--
--   1. De werklijst  -> target_words
--      De doelwoorden van deze les (role = 'target'), met de
--      mastervelden die de schrijver nodig heeft, plus de canonieke
--      voorbeelden die het woord AL heeft. Dat laatste is geen
--      formaliteit: voorbeelden horen bij het wóórd en niet bij de
--      les, dus een woord kan ze al gekregen hebben zonder dat iemand
--      het zich herinnert. En vastgelegde beslissing 2 maakt een
--      tweede voorbeeld een fout, geen aanvulling -- daarom gaat niet
--      alleen een teller mee maar de voorbeeldtekst zelf. Een teller
--      laat de schrijver kiezen; de tekst erbij maakt zichtbaar dat er
--      niets te doen valt.
--
--   2. Het woordbudget -> example_vocabulary_budgets
--      De woorden die in die voorbeelden gebruikt mogen worden, elk
--      met zijn paiboon-vorm.
--
-- ------------------------------------------------------------
-- Het wezenlijke verschil met language_note_brief_view
-- ------------------------------------------------------------
-- Daar is het budget LESGEBONDEN: alles wat vóór déze les
-- geïntroduceerd is, plus de lesset van déze les. Hier is het
-- gebonden aan de INTRODUCTIELES VAN HET DOELWOORD.
--
-- Waarom: een canoniek voorbeeld is lesneutraal en moet geldig zijn in
-- élke les waarin het woord verschijnt. De introductieles is de
-- vroegste daarvan, en het aantal bekende woorden groeit alleen maar --
-- dus wie tegen de introductieles valideert, weet dat het voorbeeld in
-- alle latere lessen ook klopt. Eén controle, permanent geldig. Zie
-- "De first_lesson_id-progressieregel" in de gids.
--
-- Vandaag vallen beide varianten samen, en dat is geen toeval maar een
-- gevolg van fn_lesson_vocabulary_state_machine: bij role = 'target'
-- wordt first_lesson_id op déze les gezet (status 'new'), of hij stond
-- al op déze les, of de Single Introduction Rule gooit een exception.
-- Sinds 20260608100001_simplify_status_values.sql bestaat 'theme_exposed'
-- niet meer, dus er is geen derde pad. Divergentie kan alleen ontstaan
-- buiten de trigger om: een handmatige update op vocabulary_status, een
-- herordening van het curriculum, of de terugdraai-trigger uit
-- 20260717120000 die first_lesson_id op null zet terwijl er nog
-- leslinks staan.
--
-- Dat is juist de reden om het anker nú goed te leggen: het kost
-- vandaag geen enkele regel extra output, en het is de enige vorm die
-- blijft kloppen als het curriculum ooit schuift. De lesgebonden
-- variant zou bij divergentie een te ruim budget geven, en dan schrijf
-- je voorbeelden die in de introductieles onbegrijpelijk zijn -- stil,
-- want er gaat niets stuk.
--
-- ------------------------------------------------------------
-- Waarom het budget per INTRODUCTIELES is gegroepeerd
-- ------------------------------------------------------------
-- Twee doelwoorden met dezelfde introductieles hebben per definitie
-- een identiek budget. Het budget per wóórd meegeven zou die lijst dus
-- louter dupliceren: bij een les met 5 doelwoorden 5x, bij een latere
-- les met 8 doelwoorden en 400 budgetwoorden 3200 entries in plaats
-- van 400. Groeperen per introductieles is even correct en kost nul
-- extra omvang zolang alle doelwoorden hun introductieles delen -- dus
-- vandaag altijd. Pas bij echte divergentie verschijnt er een tweede
-- budgetblok, en dan is die omvang precies de informatie die je nodig
-- hebt.
--
-- Elk werklijstitem draagt intro_lesson_id en intro_sequence_number,
-- zodat de generator zijn budgetblok zonder redeneren kan opzoeken.
-- Wat hier bewust NIET gebeurt: één ruim budget meegeven en het model
-- zelf laten filteren op intro_sequence_number. Dat verplaatst de
-- progressieregel naar ChatGPT, en dat is precies de plek waar hij
-- niet hoort.
--
-- ------------------------------------------------------------
-- Het budgetpredicaat
-- ------------------------------------------------------------
-- language_note_brief_view voegt twee bronnen samen (de lesset van
-- deze les + alles wat eerder geïntroduceerd is) en moet daarom via
-- left joins dedupliceren. Hier volstaat één predicaat:
--
--   intro.sequence_number <= sequence_number(introductieles doelwoord)
--
-- Dat dekt clausule 1 én 2 van de progressieregel (eerder
-- geïntroduceerd, plus de lesset van de introductieles zelf), kan per
-- definitie niet dubbel tellen, en sluit woorden zonder first_lesson_id
-- automatisch uit. Dat laatste is de veilige richting: de gids zegt
-- "twijfel is een nee". vocabulary_status heeft unique (vocabulary_id),
-- dus de join kan niet vermenigvuldigen.
--
-- Geen role-filter op het budget: ook een 'review'- of
-- 'supporting'-woord kent de leerling. Conform language_note_brief_view.
--
-- ------------------------------------------------------------
-- Wat er bewust NIET in zit: de dialoog
-- ------------------------------------------------------------
-- language_note_brief_view geeft de dialoog mee omdat notes juist aan
-- de dialoog verankerd moeten worden. Hier is het omgekeerd:
-- lesneutraliteit is de kernregel van de vocabulairegids, en "een
-- dialoogzin kopiëren" staat er met zoveel woorden in de lijst
-- veelvoorkomende fouten. Beide regels zijn correct binnen hun eigen
-- eigenaarschap; wie ze door elkaar haalt, schrijft woordkaarten die in
-- latere lessen onbegrijpelijk zijn. Een briefing die de scène toont,
-- nodigt uit tot precies die fout -- dus staat de scène er niet in.
-- De lesmetadata blijft wel staan, zodat er op gefilterd kan worden.
--
-- ------------------------------------------------------------
-- Sleutels
-- ------------------------------------------------------------
-- Sleutels gaan altijd mee naast de leesbare velden. source_key is
-- uniek in vocabulary_master, thai_script niet: เดือน bestaat twee keer
-- (month en calendar_month), identiek op script, paiboon, gloss en
-- woordsoort. Alleen de sleutel houdt die uit elkaar. De leesbare
-- velden zijn context voor het model, de sleutel is de identificatie.
--
-- Elk budgetwoord draagt zijn paiboon-vorm. ChatGPT heeft geen
-- databasetoegang; wat niet in de prompt staat wordt gereconstrueerd,
-- en dan komt de RTGS-fout terug (kh/th/ph in plaats van k/t/p,
-- gecorrigeerd op 2026-07-13 over 167 vocabulairerijen). Zie Stap 4
-- van de gids.
--
-- security_invoker = true, zoals alle views in dit project: de view
-- draait met de rechten van de aanroeper, zodat de RLS-policies op de
-- onderliggende tabellen blijven gelden. Zonder deze optie zou een
-- anon-lezer via de view ongepubliceerde lessen kunnen zien.
-- ============================================================

drop view if exists public.vocabulary_example_brief_view;

create or replace view public.vocabulary_example_brief_view
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
  -- 1. De werklijst: doelwoorden van deze les
  --
  -- Filter op role = 'target': alleen doelwoorden krijgen in deze les
  -- een voorbeeld. Woorden met 'supporting', 'review' of 'bonus'
  -- hebben hun voorbeeld al gekregen in de les die ze introduceerde,
  -- of krijgen het daar nog (gids, "Hoeveel voorbeelden per woord?").
  --
  -- needs_example is de eigenlijke werklijstvraag, en is bewust een
  -- ja/nee en geen telling: elk doelwoord krijgt precies één voorbeeld
  -- (vastgelegde beslissing 2). Staat existing_example_count op meer
  -- dan 1, dan is dat geen "genoeg" maar een signaal dat er iets is
  -- gebeurd wat niet hoort -- de dekkingsvalidatie van taak 4 vangt
  -- dat.
  --
  -- intro_lesson_* is de sleutel naar het budgetblok hieronder.
  -- is_introduced_here maakt de divergentie zichtbaar in plaats van
  -- hem te verbergen: false betekent dat het budget van dit woord
  -- krapper is dan dat van de les waarin je werkt.
  --
  -- requires_explanation gaat mee als redactionele context, niet als
  -- filter: het zegt dat de les een Language Note over dit woord
  -- plant, en dat is nuttig om te weten bij het kiezen van een
  -- voorbeeldzin -- maar het bepaalt niets over de voorbeeldplicht.
  -- ---------------------------------------------------------

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'lesson_vocabulary_id',   lv.id,
        'vocabulary_id',          vm.id,
        'source_key',             vm.source_key,
        'thai_script',            vm.thai_script,
        'paiboon',                vm.paiboon,
        'english_gloss',          vm.english_gloss,
        'part_of_speech',         vm.part_of_speech,
        'register',               vm.register,
        'usage_note',             vm.usage_note,
        'is_multifunctional',     vm.is_multifunctional,
        'lesson_role',            lv.role,
        'display_order',          lv.display_order,
        'lesson_notes',           lv.notes,
        'requires_explanation',   lv.requires_explanation,
        'intro_lesson_id',        intro.id,
        'intro_lesson_key',       intro.lesson_key,
        'intro_sequence_number',  intro.sequence_number,
        'is_introduced_here',     (intro.id is not distinct from l.id),--true/false
        'existing_example_count', (
          select count(*)
          from public.vocabulary_examples ve
          where ve.vocabulary_id = vm.id
        ),
        'needs_example', not exists (
          select 1
          from public.vocabulary_examples ve
          where ve.vocabulary_id = vm.id
        ),
        'existing_examples', coalesce((
          select jsonb_agg(
            jsonb_build_object(
              'vocabulary_example_id', ve.id,
              'display_order',         ve.display_order,
              'thai_script',           ve.thai_script,
              'paiboon',               ve.paiboon,
              'translation_en',        ve.translation_en,
              'has_audio',             (ve.audio_url is not null),
              'voice_key',             ve.voice_key
            )
            order by ve.display_order
          )
          from public.vocabulary_examples ve
          where ve.vocabulary_id = vm.id
        ), '[]'::jsonb)
      )
      order by lv.display_order nulls first, lv.id
    )
    from public.lesson_vocabulary lv
    join public.vocabulary_master vm
      on vm.id = lv.vocabulary_id
    left join public.vocabulary_status vs
      on vs.vocabulary_id = vm.id
    left join public.lessons intro
      on intro.id = vs.first_lesson_id
    where lv.lesson_id = l.id
      and lv.role = 'target'
  ), '[]'::jsonb) as target_words,

  -- ---------------------------------------------------------
  -- 2. Het woordbudget, gegroepeerd per introductieles
  --
  -- De buitenste query levert één blok per DISTINCTE introductieles
  -- onder de doelwoorden van deze les. Vandaag is dat er altijd
  -- precies één; zie de motivering in de kop.
  --
  -- Doelwoorden zonder introductieles (first_lesson_id is null) leveren
  -- geen blok op. Dat kan volgens de trigger niet, maar als het toch
  -- gebeurt is er ook geen anker en dus geen budget -- de gids: "Een
  -- woord dat nog nergens geïntroduceerd is, krijgt nog geen canonieke
  -- voorbeelden." Het woord staat wél in de werklijst, met
  -- intro_sequence_number null, zodat de schrijver ziet dát het bestaat.
  --
  -- word_count staat erbij zodat de generator en de QA kunnen
  -- controleren dat er niets is weggevallen zonder de array te tellen.
  --
  -- in_intro_lesson_set zegt of het woord aan de introductieles zelf
  -- gekoppeld is (clausule 2 van de progressieregel) tegenover eerder
  -- geïntroduceerd (clausule 1). Voor de schrijver is dat het verschil
  -- tussen "dit leert de leerling nu" en "dit kent hij al".
  -- ---------------------------------------------------------

  coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'intro_lesson_id',       intro.id,
        'intro_lesson_key',      intro.lesson_key,
        'intro_sequence_number', intro.sequence_number,
        'word_count', (
          select count(*)
          from public.vocabulary_master bvm
          join public.vocabulary_status bvs
            on bvs.vocabulary_id = bvm.id
          join public.lessons bintro
            on bintro.id = bvs.first_lesson_id
          where bintro.sequence_number <= intro.sequence_number
        ),
        'words', coalesce((
          select jsonb_agg(
            jsonb_build_object(
              'vocabulary_id',         bvm.id,
              'source_key',            bvm.source_key,
              'thai_script',           bvm.thai_script,
              'paiboon',               bvm.paiboon,
              'english_gloss',         bvm.english_gloss,
              'part_of_speech',        bvm.part_of_speech,
              'register',              bvm.register,
              'usage_note',            bvm.usage_note,
              'intro_lesson_key',      bintro.lesson_key,
              'intro_sequence_number', bintro.sequence_number,
              'availability',          case
                                         when bintro.sequence_number = intro.sequence_number
                                           then 'intro_lesson'
                                         else 'previous'
                                       end,
              'in_intro_lesson_set',   exists (
                select 1
                from public.lesson_vocabulary blv
                where blv.vocabulary_id = bvm.id
                  and blv.lesson_id = intro.id
              )
            )
            order by bintro.sequence_number, bvm.source_key
          )
          from public.vocabulary_master bvm
          join public.vocabulary_status bvs
            on bvs.vocabulary_id = bvm.id
          join public.lessons bintro
            on bintro.id = bvs.first_lesson_id
          where bintro.sequence_number <= intro.sequence_number
        ), '[]'::jsonb)
      )
      order by intro.sequence_number
    )
    from (
      select distinct vs.first_lesson_id
      from public.lesson_vocabulary lv
      join public.vocabulary_status vs
        on vs.vocabulary_id = lv.vocabulary_id
      where lv.lesson_id = l.id
        and lv.role = 'target'
        and vs.first_lesson_id is not null
    ) anchors--is tijdelijke tabelachtige subquery, anchors is de tabelalias
    join public.lessons intro
      on intro.id = anchors.first_lesson_id
  ), '[]'::jsonb) as example_vocabulary_budgets

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
-- RLS-policies op lessons, lesson_vocabulary, vocabulary_master,
-- vocabulary_status en vocabulary_examples gewoon gelden -- die geven
-- anon alleen toegang tot gepubliceerde lessen.
--
-- Bewust geen grant voor service_role. Er is vandaag geen script dat
-- deze view leest; de briefing wordt via psql als postgres opgehaald.
-- Zodra er wel een script komt (de generator uit taak 2, of de
-- promptvulling uit taak 3), hoort dat een eigen migratie te zijn met
-- een eigen motivering, zoals
-- 20260716120100_grant_service_role_select_status_link_tables.sql.
-- ============================================================

grant select on table public.vocabulary_example_brief_view to anon, authenticated;
