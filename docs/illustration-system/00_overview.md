# ThaiNook Illustration System — Overzicht

Dit is de documentatiehoofdmap voor het volledige illustratieproductiesysteem van ThaiNook. Het systeem is ontworpen als een vierde laag bovenop de bestaande drie-lagen dialoogworkflow (zie `docs/thai_a1_dialog_workflow_guide.md`):

```
1. Curriculum-DB      → lessons, character_profiles, relationship_pairs
2. Content-planning   → dialog_blueprint_specs
3. AI-generatie       → dialogs, dialog_blocks, dialog_slides
4. Illustratielaag    → Scene Bible → Slide Specifications → Illustration Prompts   ← dit systeem
```

De illustratielaag hergebruikt bestaande databasegegevens als brondata en produceert uiteindelijk maar één ding dat teruggeschreven wordt naar de database: `dialog_slides.image_url`.

## Hoe lees je deze documentatie

Lees de bestanden in deze volgorde als je nieuw bent in het systeem:

1. **`01_master_style_system.md`** — de onveranderlijke visuele filosofie en de Master Style Prompt. Dit geldt voor élke illustratie, zonder uitzondering.
2. **`02_locked_cast_sheet.md`** — de vaste cast (Narin, Mali, Ploy, Dao, Lin, Suda, Kiet, Arun) en de regels die hun identiteit consistent houden over honderden illustraties heen.
3. **`03_scene_and_continuity_rules.md`** — hoe een scène en een slideshow-sequentie in elkaar zitten, en wat wel/niet mag veranderen tussen slides.
4. **`04_illustration_workflow_guide.md`** — de praktische, stap-voor-stap productiepipeline: van dialoog naar Scene Bible naar Slide Specifications naar Illustration Prompt naar geüploade afbeelding.
5. **`05_storage_strategy.md`** — waarom welk gegeven waar leeft (database, Markdown, of later JSON), met motivatie.

## Mapstructuur

```
docs/illustration-system/
  00_overview.md                     ← dit bestand
  01_master_style_system.md
  02_locked_cast_sheet.md
  03_scene_and_continuity_rules.md
  04_illustration_workflow_guide.md
  05_storage_strategy.md
  templates/
    scene-bible.template.md
    slide-specification.template.md
    illustration-prompt.template.md
    new-character.template.md
    new-scene.template.md
  scene-bibles/
    a1_dialog_01_scene_bible.md
    a1_dialog_02_scene_bible.md       ← toe te voegen naarmate dialogen verschijnen
    ...
  slide-specs/
    a1_dialog_01_slide_specs.md
    ...
  prompts/
    a1_dialog_01/
      slide_01_prompt.md
      slide_02_prompt.md
      slide_03_prompt.md
    ...

  cast-references/
    [character_key]/
      face-lock.png                    ← verplicht vóór eerste dialoog met dit personage (zie 04, Stap 0)
      full-body.png
    ...

illustration-staging/
    a1_dialog_01/
      slide_01.png                     ← goedgekeurde afbeelding, lokale kopie vóór upload (zie 04, Stap 6b)
      slide_02.png
      slide_03.png
    ...
```

## Naamgevingsconventie

Alle illustratiebestanden gebruiken de `a1_dialog_XX`-vorm (onderstrepingstekens, zero-padded nummer), rechtstreeks afgeleid van de stabiele `lesson_key` in de database (`a1-dialog-01` → `a1_dialog_01`). Deze vorm is dezelfde als die inmiddels overal elders in het project wordt gebruikt voor lesspecifieke bestanden (`supabase/prompts/`, `supabase/generation/dialogs/`, `supabase/planning/blueprints/`, `supabase/seed-data/`), omdat `lesson_key` de stabiele identifier is en een sequence-onafhankelijke naam oplevert.

Voor toekomstige CEFR-niveaus (A2–C2) geldt dezelfde conventie met het bijbehorende niveauprefix, bijvoorbeeld `a2_dialog_01_scene_bible.md`.

In de templates (`templates/*.template.md`) wordt deze `a1_dialog_XX`-vorm aangeduid als `dialog_key`. Dit is geen databasekolom maar een documentatieterm: de underscore-vorm die je afleidt van de echte bron `lessons.lesson_key` (hyphenated, bv. `a1-dialog-01`). Gebruik `dialog_key` in bestandsnamen en template-headers, en `lesson_key` wanneer je expliciet naar de databasewaarde verwijst.

## Bronnen van waarheid

Dit systeem dupliceert geen data die al in de database bestaat. Zie `05_storage_strategy.md` voor de volledige motivatie, maar de vuistregel is:

- Bestaat het veld al in `dialog_blueprint_specs` of `dialog_slides`? → de database is de bron van waarheid, dit systeem leest ervan.
- Bestaat het veld nog niet (illustratie-specifieke details zoals lichaamstaal, weer, sfeer)? → Markdown is nu de bron van waarheid, met een gedocumenteerd pad naar een toekomstige JSONB-kolom.

## Relatie tot de dialoogworkflow

Dit systeem start pas ná stap 10 van `thai_a1_dialog_workflow_guide.md` (de dialoog is goedgekeurd en opgeslagen in `dialogs`/`dialog_blocks`). Een illustratie wordt nooit ontworpen op basis van een nog-niet-goedgekeurde dialoogdraft.
