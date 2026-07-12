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
    00_build_curriculum_sequencer_context.sql ← Stap 1 (standaard): input voor "wat wordt de volgende les"
    01_debug_lesson_blueprint.sql        ← inspectie, geen workflow-stap
    02_debug_continuity_options.sql      ← inspectie, geen workflow-stap
    03_build_dialog_lesson_blueprint.sql ← de enige builder-query
    04_lesson_dialog_prompt_template.md
    05_curriculum_sequencer_prompt_template.md ← hoort bij Stap 1
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
- Kies de shortlist-omvang en het doelaantal in Stap 3 volgens deze tabel.
- Vul `estimated_line_count` in `dialog_blueprint_specs` (Stap 5) in met de bijhorende richtlijn, bijvoorbeeld `'6-8 lines'`.
- Dit is een richtlijn, geen harde databasebeperking: bij een scène die iets meer of minder nodig heeft, mag je afwijken. De tabel is een startpunt voor de shortlist-vraag en voor `estimated_line_count`, niet een constraint in het schema.

## Nieuw woord/concept toevoegen aan de masterlijst

De masterlijsten (`vocabulary_master`, `grammar_master`, `phrase_master`, `pattern_master`) zijn een vooraf gecureerde kandidatenpool, maar in de praktijk — al vanaf de eerste dialogen — zal je toch af en toe een woord of concept nodig hebben dat er nog niet in staat, omdat de scène anders niet inhoudelijk zinvol wordt. Dat is een **normaal, verwacht onderdeel** van het proces, geen uitzondering. Gebruik deze korte, snelle route in plaats van iets te forceren binnen de bestaande pool:

1. **Controleer eerst of het niet al onder een andere naam bestaat**, om duplicaten te vermijden:

   ```sql
   select * from public.vocabulary_master
   where thai_script = '...' or english_gloss ilike '%...%';

   select * from public.grammar_master where title ilike '%...%';
   select * from public.phrase_master  where title ilike '%...%';
   select * from public.pattern_master where title ilike '%...%';
   ```

2. **Voeg toe met een directe insert** (snel genoeg voor tijdens actieve ontwikkeling):

   ```sql
   insert into public.vocabulary_master
     (source_key, cefr_level, thai_script, paiboon, english_gloss, part_of_speech, register, default_theme)
   values
     ('...', 'A1', '...', '...', '...', '...', '...', '...');
   ```

   De bijhorende initialisatietrigger (`trg_initialize_vocabulary_status` en de grammar-/phrase-/pattern-varianten) maakt automatisch de status-rij aan met `status = 'new'`. Je hoeft dus niets extra te doen om het woord bruikbaar te maken — het verschijnt meteen in de ongebruikte kandidatenpool (zie Stap 1 hieronder).

3. **Werk periodiek de brondata bij** in `supabase/seed-data/master/csv/*.csv`, zodat `npm run seed:vocab` / `seed:grammar` / `seed:pattern` consistent blijft bij een `db reset`. Dit is opruimwerk dat je kan groeperen (bijvoorbeeld na elke 5–10 dialogen) — het hoeft niet bij elk nieuw woord meteen te gebeuren.

## Stapsgewijze workflow per les

### Stap 1 — Laat AI de volgende les voorstellen (curriculumsequencer)

Dit is het standaardproces: je verzint scène, titel en woordenlijst niet meer zelf vooraf, maar laat AI een voorstel doen op basis van alles wat al gekend is en wat er nog beschikbaar is. Enkel wanneer er bewust al een vooraf geplande `lessons`-rij bestaat die je ongewijzigd wil gebruiken, mag je deze stap overslaan en rechtstreeks naar Stap 2 gaan.

> De 12 lessen die oorspronkelijk in `core.seed.sql` zijn geseed (`a1-dialog-01` t/m `a1-revision-premium-01`) waren een voorlopige skeletplanning uit een vroeg stadium van het project, vóór dit sequencer-proces bestond. Vanaf nu geldt Stap 1 als het vaste proces: ook voor die bestaande rijen mag je Stap 1 gebruiken om ze te herzien en te overschrijven zodra je eraan toe bent, in plaats van de oorspronkelijke placeholder-titel klakkeloos over te nemen.

1. Voer `00_build_curriculum_sequencer_context.sql` uit in Supabase Studio — dit zijn 7 losse secties (voortgang, reeds-geïntroduceerde concepten, ongebruikte kandidatenpool per categorie, laatste dialogen, continuïteitscontext).
2. Vul `05_curriculum_sequencer_prompt_template.md` in met die resultaten.
3. Laat AI een voorstel doen: titel, subtitel, scène, lesdoel, en doelconcepten (gelabeld als `[EXISTING]` of `[NEW]`).
4. **Keur het voorstel goed of stuur het bij** — dit is een voorstel, geen bron van waarheid. Let vooral op:
   - Klopt de scène inhoudelijk en past ze bij de vorige dialoog(en)?
   - Is het aantal nieuwe items in lijn met de lesfase-richtlijn?
   - Voor elk `[NEW]`-item: wil je dit echt toevoegen, of bestaat er al een alternatief in de pool?
5. Voor elk goedgekeurd `[NEW]`-item: volg "Nieuw woord/concept toevoegen aan de masterlijst" hierboven.
6. **Maak of werk de `lessons`-rij aan** met de goedgekeurde titel, subtitel en sequence_number uit het voorstel:

   ```sql
   insert into public.lessons (
     lesson_key, slug, cefr_level, section_key, lesson_type,
     title, subtitle, sequence_number, access_tier, is_published
   )
   values (
     'a1-dialog-XX',
     'slug-op-basis-van-titel',
     'A1',
     'dialogs',
     'dialog',
     '...',                    -- goedgekeurde titel uit het voorstel
     '...',                    -- goedgekeurde subtitel uit het voorstel
     4,                        -- goedgekeurde sequence_number uit het voorstel
     'free',
     true
   )
   on conflict (lesson_key) do update set
     title           = excluded.title,
     subtitle        = excluded.subtitle,
     sequence_number = excluded.sequence_number,
     updated_at      = now();
   ```

   `on conflict (lesson_key) do update` maakt dit ook veilig om een bestaande, voorlopige placeholder-rij te overschrijven met een beter onderbouwd voorstel — zonder eerst iets te moeten verwijderen.

Pas na deze stap ga je verder met Stap 2.

### Stap 2 — Controleer of de lesdata bestaat

Bevestig dat de `lessons`-rij klopt — aangemaakt of bijgewerkt via Stap 1, of (bij uitzondering) al eerder bewust vastgelegd. Is het resultaat leeg en heb je Stap 1 niet gebruikt? Ga dan eerst terug naar Stap 1.

```sql
select id, lesson_key, title, subtitle, cefr_level, lesson_type, sequence_number, section_key
from public.lessons
where lesson_key = 'a1-dialog-02';
```

### Stap 3 — Selecteer vocabulaire (shortlist-aanpak)

Stel een shortlist op van 10–12 kandidaatwoorden uit `vocabulary_master` die passen bij het lesonderwerp. Vraag de AI om er een aantal uit te kiezen volgens de lesfase-tabel in "Hoeveel nieuwe woorden en regels per lesfase" (4–5 voor les 1–10, 6–8 voor les 11–30, 8–10 vanaf les 31). Keur goed voordat je iets seed.

### Stap 4 — Seed de leslinks

Maak `seed-data/links/lesson_links_a1-dialog-XX.seed.sql` aan met inserts voor:

- `lesson_vocabulary` (doelwoorden)
- `lesson_grammar` (doelgrammatica)
- `lesson_pattern` (indien van toepassing)
- `lesson_phrase` (indien van toepassing)

Voer de seed uit met het commando:

psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -f supabase/seed-data/links/lesson_links_a1-dialog-02.seed.sql

De state machine-triggers updaten `vocabulary_status` en `grammar_status` automatisch.

### Stap 5 — Maak `dialog_blueprint_specs` aan

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

**Eenmalige personages horen niet in `character_profiles`.** Een kelner, marktkramer of ander figuur dat maar in één scène opduikt en geen invloed heeft op een relatie, hoeft niet als personage aangemaakt te worden. Beschrijf de eenmalige rol gewoon in `scene_summary` of als extra regel in `extra_constraints` (bv. `'a waiter briefly takes the order and says something like "here you go..."'`). `dialog_blocks.speaker_key` is vrije tekst zonder foreign key naar `character_profiles`, dus zo'n figuur kan gewoon een sprekerlabel krijgen (bv. "Waiter") zonder ooit in de database te bestaan.

### Stap 6 — Voer de builder-query uit

Open `03_build_dialog_lesson_blueprint.sql`, verander de WHERE naar de juiste `lesson_key` en voer uit in Supabase Studio. Je zou één rij moeten zien.

De kolommen staan in exact dezelfde volgorde als de secties in `04_lesson_dialog_prompt_template.md`. Je kan van links naar rechts door het resultaat werken terwijl je de prompt invult.

### Stap 7 — Exporteer als CSV (optioneel)

Exporteer het one-row-resultaat als CSV naar `planning/blueprints/a1_dialog_XX_blueprint.csv`.

**Let op multiline-velden.** Velden zoals `required_vocabulary_list`, `allowed_vocabulary_list` en `speaker_a_default_tone` bevatten newlines. De meeste teksteditors (VS Code, Notepad) tonen die fout als extra rijen, waardoor kolomposities verschuiven. Gebruik voor multiline-velden de **cel-klik in Studio** om de volledige inhoud te kopiëren. Scalarvelden (lesson_key, scene_type, allowed_register, etc.) werken wel betrouwbaar uit de CSV.

### Stap 8 — Vul de prompt in

Maak `supabase/prompts/a1_dialog_XX_prompt.md` aan op basis van `04_lesson_dialog_prompt_template.md`. Vervang elke placeholder met de waarde uit het Studio-resultaat of de CSV.

Werkwijze:

- Scalarvelden: plak direct vanuit de CSV-cel
- Multiline-velden: klik de cel aan in Studio en kopieer de volledige inhoud
- Plak geen CSV-aanhalingstekens die niet bij de inhoud horen

### Stap 9 — Genereer de dialoog

Gebruik de ingevulde lesspecifieke prompt. Sla de ruwe output op in `generation/dialogs/a1_dialog_XX_output.md`.

De output bestaat uit vijf metadata-secties (Title, Subtitle, Learning focus, Scene summary, Register) gevolgd door genummerde blokken. Elk blok bevat precies één Thai-regel, één Transliteration-regel en één English-regel.

### Stap 10 — QA vóór opslaan

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

### Stap 11 — Sla de definitieve dialoog op in `dialogs` en `dialog_blocks`

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

### Stap 12 — Voer lokaal uit

Voor kleine wijzigingen of een nieuwe dialoog: voer de seed-SQL handmatig uit in de SQL-editor. Gebruik `supabase db reset` alleen voor een volledige reproducibiliteitstest.

### Stap 13 — Commit

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

1. Laat AI de volgende les voorstellen via de curriculumsequencer (Stap 1): titel, subtitel, scène en doelconcepten. Keur goed, voeg goedgekeurde `[NEW]`-items toe aan de masterlijst, en maak/werk de `lessons`-rij bij.
2. Bevestig dat de les bestaat in `lessons`.
3. Stel een shortlist van 10–12 kandidaatwoorden op en kies het aantal volgens de lesfase-tabel (4–5 voor les 1–10, 6–8 voor les 11–30, 8–10 vanaf les 31).
4. Seed `lesson_vocabulary`, `lesson_grammar`, `lesson_pattern`, `lesson_phrase`.
5. Maak `dialog_blueprint_specs` aan en seed.
6. Voer `03_build_dialog_lesson_blueprint.sql` uit — verwacht één rij.
7. Exporteer als CSV naar `planning/blueprints/`.
8. Vul `supabase/prompts/a1_dialog_XX_prompt.md` in (scalars vanuit CSV, multiline vanuit Studio-cel).
9. Genereer de dialoog en sla op in `generation/dialogs/`.
10. Voer QA uit.
11. Maak `seed-data/dialogs/a1_dialog_XX.seed.sql` aan (dialoog-metadata + blokken) en voer uit.
12. Commit alle bestanden.
