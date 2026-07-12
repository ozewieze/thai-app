# Thai A1 dialoogworkflow-gids

Deze gids beschrijft een herhaalbare workflow voor het aanmaken van Thai A1-lesdialogen, met een strikte scheiding tussen curriculumdata, planningsdata en AI-generatie-output. De workflow houdt de database als bron van waarheid, gebruikt views en builder-queries als afgeleide planningslagen, en slaat definitief goedgekeurde dialooginhoud apart op van tijdelijk generatiewerk.

## Doel van de workflow

Het doel is één dialoog per les aanmaken op basis van bestaande curriculum- en continuïteitsdata, zonder een lesblueprint te veranderen in een aparte persistente bron van waarheid. De vuistregel is eenvoudig: curriculum en continuïteit leven in tabellen, planning wordt telkens opnieuw opgebouwd vanuit queries, en alleen definitieve dialoogoutput wordt weggeschreven naar `dialogs`.

## De drie lagen

### 1. Curriculumdatabase

Deze tabellen blijven de inhoudelijke bron van waarheid:

- `lessons`
- `vocabulary_master`
- `vocabulary_status`
- `phrase_master`
- `phrase_status`
- `grammar_master`
- `grammar_status`
- `pattern_master`
- `pattern_status`
- `lesson_vocabulary`
- `lesson_phrase`
- `lesson_grammar`
- `lesson_pattern`

Deze tabellen blijven de continuïteitsbron van waarheid:

- `character_profiles`
- `relationship_pairs`
- `relationship_pair_rules`

### 2. Inhoudsplanning

Dit is de afgeleide werklaag:

- `dialog_blueprint_specs` (lesspecifieke scène- en ontwerpdata)
- lesblueprint-queryresultaat
- continuïteitscontext-queryresultaat
- platte blueprint-CSV-export
- prompttemplate
- lesspecifieke prompt

Niets in deze laag is een nieuwe bron van waarheid. Planning wordt telkens opnieuw opgebouwd vanuit tabellen of views.

### 3. AI-generatie

Dit is de outputlaag:

- `dialogs`
- `revisions`
- generatiedrafts en reviewnotities in bestanden

Gebruik `dialogs` voor de definitief goedgekeurde lesdialoog. Gebruik `revisions` alleen voor revisie-output of revisiessamenvattingen, niet als versiebeheer voor meerdere dialoogdrafts. Een reviewbestand in `generation/dialogs/` is optioneel — maak het alleen aan als er iets te documenteren valt over de QA of de keuzes tijdens generatie.

## Mapstructuur

```text
supabase/
  planning/
    01_debug_lesson_blueprint.sql        ← inspectie, geen workflow-stap
    02_debug_continuity_options.sql      ← inspectie, geen workflow-stap
    03_build_dialog_lesson_blueprint.sql ← de enige builder-query
    04_lesson_dialog_prompt_template.md
    blueprints/
      a1_dialog_01_blueprint.csv
      a1_dialog_02_blueprint.csv

  prompts/
    a1_dialog_01_prompt.md
    a1_dialog_02_prompt.md

  generation/
    dialogs/
      a1_dialog_01_output.md
      a1_dialog_02_output.md
      a1_dialog_01_review.md  ← optioneel, alleen aanmaken als er iets te documenteren valt

  seed-data/
    app/
      core.seed.sql
      specs/
        a1_dialog_01_blueprint_specs.seed.sql
        a1_dialog_02_blueprint_specs.seed.sql
    master/
      vocabulary_master.seed.sql
      grammar_master.seed.sql
      pattern_master.seed.sql
      phrase_master.seed.sql
    links/
      lesson_links_a1-dialog-01.seed.sql
      lesson_links_a1-dialog-02.seed.sql
    dialogs/
      a1_dialog_01.seed.sql
      a1_dialog_02.seed.sql
```

### Wat hoort waar

| Map           | Gebruik                                                    |
| ------------- | ---------------------------------------------------------- |
| `planning/`   | Builder-SQL, debug-queries, CSV-blueprints, prompttemplate |
| `prompts/`    | Ingevulde, lesspecifieke prompts                           |
| `generation/` | Modeloutputs, reviewnotities, tijdelijke drafts            |
| `seed-data/`  | SQL die echte database-inhoud insert of updatet            |

## Debug-queries vs. builder-query

`01_debug_lesson_blueprint.sql` en `02_debug_continuity_options.sql` zijn **geen workflow-stappen**. Ze zijn handig als diagnose wanneer `03` geen rijen teruggeeft:

- `01` — checkt of `lesson_blueprint_view` data heeft voor de les
- `02` — checkt of er een actief relationship pair beschikbaar is

De enige query die je per les gebruikt is `03_build_dialog_lesson_blueprint.sql`.

## Vocabulaire selecteren vóór seeden

Een veelgemaakte fout is te vroeg committen aan een vaste woordenlijst. Als je woorden seedt en de AI stelt een beter alternatief voor tijdens generatie, moet je achteraf `lesson_vocabulary` aanpassen.

Betere aanpak: gebruik een **shortlist van 10–12 kandidaatwoorden** die passen bij het lesonderwerp en A1-niveau. Stel de selectievraag apart, los van de dialoogprompt:

> "Welke [doelaantal] van deze kandidaatwoorden vormen samen de sterkste lesset voor dit doel en deze scène?"

Vul `[doelaantal]` in met het bereik uit de tabel in "Hoeveel nieuwe woorden en regels per lesfase" hieronder, afhankelijk van waar de les zich in het curriculum bevindt.

Keur de aanbeveling goed en seed dan pas naar `lesson_vocabulary`. Zo blijft de database de curriculumbron van waarheid terwijl je betere input geeft aan de selectie.

## Hoeveel nieuwe woorden en regels per lesfase

De oorspronkelijke regel "maximaal 5 nieuwe woorden, dialoog zo kort mogelijk" werkt goed voor de allereerste lessen, maar schaalt niet naar een volledig A1-traject van rond de 50 lessen: latere dialogen mogen en moeten meer woorden bevatten en meer op een natuurlijk gesprek lijken. Gebruik onderstaande richtlijn per lesfase (op basis van `sequence_number` van de les) in plaats van één vast getal voor het hele traject:

| Lesfase (`sequence_number`) | Nieuwe woorden per les | Richtlijn `estimated_line_count` |
| --------------------------- | ---------------------- | -------------------------------- |
| 1–10                        | 4–5                    | 4–6 lines                        |
| 11–30                       | 6–8                    | 6–8 lines                        |
| 31+                         | 8–10                   | 8–10 lines                       |

Praktisch:

- Bepaal de lesfase via `sequence_number` van de les in `lessons`.
- Kies de shortlist-omvang en het doelaantal in Stap 2 volgens deze tabel.
- Vul `estimated_line_count` in `dialog_blueprint_specs` (Stap 4) in met de bijhorende richtlijn, bijvoorbeeld `'6-8 lines'`.
- Dit is een richtlijn, geen harde databasebeperking: bij een scène die iets meer of minder nodig heeft, mag je afwijken. De tabel is een startpunt voor de shortlist-vraag en voor `estimated_line_count`, niet een constraint in het schema.

## Stapsgewijze workflow per les

### Stap 1 — Controleer of de lesdata bestaat

Bevestig dat de les bestaat in `lessons`. Als de les er niet is, stop hier.

```sql
select id, lesson_key, title, subtitle, cefr_level, lesson_type, sequence_number, section_key
from public.lessons
where lesson_key = 'a1-dialog-02';
```

### Stap 2 — Selecteer vocabulaire (shortlist-aanpak)

Stel een shortlist op van 10–12 kandidaatwoorden uit `vocabulary_master` die passen bij het lesonderwerp. Vraag de AI om er een aantal uit te kiezen volgens de lesfase-tabel in "Hoeveel nieuwe woorden en regels per lesfase" (4–5 voor les 1–10, 6–8 voor les 11–30, 8–10 vanaf les 31). Keur goed voordat je iets seed.

### Stap 3 — Seed de leslinks

Maak `seed-data/links/lesson_links_a1-dialog-XX.seed.sql` aan met inserts voor:

- `lesson_vocabulary` (doelwoorden)
- `lesson_grammar` (doelgrammatica)
- `lesson_pattern` (indien van toepassing)
- `lesson_phrase` (indien van toepassing)

Voer de seed uit met het commando:

psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -f supabase/seed-data/links/lesson_links_a1-dialog-02.seed.sql

De state machine-triggers updaten `vocabulary_status` en `grammar_status` automatisch.

### Stap 4 — Maak `dialog_blueprint_specs` aan

Dit is een **verplichte stap** vóór de builder-query. Zonder een record in `dialog_blueprint_specs` voor de les geeft `03` geen rijen terug.

Maak `seed-data/app/specs/a1_dialog_XX_blueprint_specs.seed.sql` aan en voer uit:

```sql
insert into public.dialog_blueprint_specs (
  lesson_id,
  relationship_pair_id,
  learning_focus,
  scene_summary,
  scene_type,
  suggested_location,
  allowed_register,
  estimated_line_count,
  extra_constraints
)
values (
  (select id from public.lessons where lesson_key = 'a1-dialog-XX'),
  1,
  '...',
  '...',
  '...',
  '...',
  'polite',
  '6-8 lines',
  '[...]'::jsonb
);
```

### Stap 5 — Voer de builder-query uit

Open `03_build_dialog_lesson_blueprint.sql`, verander de WHERE naar de juiste `lesson_key` en voer uit in Supabase Studio. Je zou één rij moeten zien.

De kolommen staan in exact dezelfde volgorde als de secties in `04_lesson_dialog_prompt_template.md`. Je kan van links naar rechts door het resultaat werken terwijl je de prompt invult.

### Stap 6 — Exporteer als CSV (optioneel)

Exporteer het one-row-resultaat als CSV naar `planning/blueprints/a1_dialog_XX_blueprint.csv`.

**Let op multiline-velden.** Velden zoals `required_vocabulary_list`, `allowed_vocabulary_list` en `speaker_a_default_tone` bevatten newlines. De meeste teksteditors (VS Code, Notepad) tonen die fout als extra rijen, waardoor kolomposities verschuiven. Gebruik voor multiline-velden de **cel-klik in Studio** om de volledige inhoud te kopiëren. Scalarvelden (lesson_key, scene_type, allowed_register, etc.) werken wel betrouwbaar uit de CSV.

### Stap 7 — Vul de prompt in

Maak `supabase/prompts/a1_dialog_XX_prompt.md` aan op basis van `04_lesson_dialog_prompt_template.md`. Vervang elke placeholder met de waarde uit het Studio-resultaat of de CSV.

Werkwijze:

- Scalarvelden: plak direct vanuit de CSV-cel
- Multiline-velden: klik de cel aan in Studio en kopieer de volledige inhoud
- Plak geen CSV-aanhalingstekens die niet bij de inhoud horen

### Stap 8 — Genereer de dialoog

Gebruik de ingevulde lesspecifieke prompt. Sla de ruwe output op in `generation/dialogs/a1_dialog_XX_output.md`.

De output bestaat uit vijf metadata-secties (Title, Subtitle, Learning focus, Scene summary, Register) gevolgd door genummerde blokken. Elk blok bevat precies één Thai-regel, één Transliteration-regel en één English-regel.

### Stap 9 — QA vóór opslaan

Controleer minstens:

- Past de scène bij het lesdoel?
- Zijn alle verplichte doelelementen aanwezig?
- Is er geen belangrijke nieuwe grammatica buiten de lesscope?
- Zijn `ครับ`, `ค่ะ` en `คะ` correct gebruikt?
- Past de toon bij de karakterprofielen?
- Past de interactie bij de relatieregels?
- Is de dialoog beginnersveilig en kort genoeg?
- Is de transliteratie consistent?
- Is de Engelse vertaling trouw aan het Thais?

### Stap 10 — Sla de definitieve dialoog op in `dialogs` en `dialog_blocks`

Maak `seed-data/dialogs/a1_dialog_XX.seed.sql` aan. Het bestand bestaat uit twee delen in één transactie.

**Deel 1** insert de dialoog-metadata. **Deel 2** haalt het zojuist geïnserte `dialog_id` op via een CTE en insert alle blokken via `cross join (values ...)`.

```sql
begin;

-- 1. dialoog-metadata
insert into public.dialogs (
  lesson_id,
  title,
  subtitle,
  learning_focus,
  scene_summary,
  register
) values (
  (select id from public.lessons where lesson_key = 'a1-dialog-XX'),
  '...',
  '...',
  '...',
  '...',
  'polite'
)
on conflict (lesson_id) do update set
  title          = excluded.title,
  subtitle       = excluded.subtitle,
  learning_focus = excluded.learning_focus,
  scene_summary  = excluded.scene_summary,
  register       = excluded.register,
  updated_at     = now();

-- 2. dialoogblokken
with dialog as (
  select id
  from public.dialogs
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-XX')
)
insert into public.dialog_blocks (dialog_id, block_index, thai_text, transliteration, translation_en)
select
  dialog.id,
  block.block_index,
  block.thai_text,
  block.transliteration,
  block.translation_en
from dialog
cross join (values
  (0, 'Thai regel 1',  'Translit 1',  'English 1'),
  (1, 'Thai regel 2',  'Translit 2',  'English 2')
  -- voeg hier één rij per blok toe
) as block(block_index, thai_text, transliteration, translation_en)
on conflict (dialog_id, block_index) do update set
  thai_text       = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en  = excluded.translation_en,
  updated_at      = now();

commit;
```

`block_index` is 0-gebaseerd. De volgorde van de rijen in `values` bepaalt de volgorde in de player. Enkelvoudige aanhalingstekens in de tekst escapeer je als `''` (twee enkele quotes).

Als er later een illustratielaag voor deze dialoog bijkomt, verschijnt er nog een apart bestand `seed-data/dialogs/a1_dialog_XX_slides.seed.sql` (voor `dialog_slides`) — dat hoort bij `docs/illustration-system/04_illustration_workflow_guide.md` en niet bij deze stap, omdat de slide-segmentatie pas ná goedkeuring van de dialoog wordt bepaald.

### Stap 11 — Voer lokaal uit

Voor kleine wijzigingen of een nieuwe dialoog: voer de seed-SQL handmatig uit in de SQL-editor. Gebruik `supabase db reset` alleen voor een volledige reproducibiliteitstest.

### Stap 12 — Commit

Commit de plannings-, generatie- en seed-bestanden samen:

- `planning/blueprints/a1_dialog_XX_blueprint.csv`
- `supabase/prompts/a1_dialog_XX_prompt.md`
- `generation/dialogs/a1_dialog_XX_output.md`
- `seed-data/app/specs/a1_dialog_XX_blueprint_specs.seed.sql`
- `seed-data/links/lesson_links_a1-dialog-XX.seed.sql`
- `seed-data/dialogs/a1_dialog_XX.seed.sql`

## `config.toml` seed-configuratie

Als dialoog-seeds automatisch moeten draaien bij `db reset`:

```toml
[db.seed]
enabled = true
sql_paths = [
  "./seed-data/app/core.seed.sql",
  "./seed-data/master/vocabulary_master.seed.sql",
  "./seed-data/master/grammar_master.seed.sql",
  "./seed-data/master/pattern_master.seed.sql",
  "./seed-data/master/phrase_master.seed.sql",
  "./seed-data/links/lesson_links_a1-dialog-01.seed.sql",
  "./seed-data/links/lesson_links_a1-dialog-02.seed.sql",
  "./seed-data/app/specs/*.seed.sql",
  "./seed-data/dialogs/*.sql"
]
```

## Praktische checklist per nieuwe les

1. Bevestig dat de les bestaat in `lessons`.
2. Stel een shortlist van 10–12 kandidaatwoorden op en kies het aantal volgens de lesfase-tabel (4–5 voor les 1–10, 6–8 voor les 11–30, 8–10 vanaf les 31).
3. Seed `lesson_vocabulary`, `lesson_grammar`, `lesson_pattern`, `lesson_phrase`.
4. Maak `dialog_blueprint_specs` aan en seed.
5. Voer `03_build_dialog_lesson_blueprint.sql` uit — verwacht één rij.
6. Exporteer als CSV naar `planning/blueprints/`.
7. Vul `supabase/prompts/a1_dialog_XX_prompt.md` in (scalars vanuit CSV, multiline vanuit Studio-cel).
8. Genereer de dialoog en sla op in `generation/dialogs/`.
9. Voer QA uit.
10. Maak `seed-data/dialogs/a1_dialog_XX.seed.sql` aan (dialoog-metadata + blokken) en voer uit.
11. Commit alle bestanden.
