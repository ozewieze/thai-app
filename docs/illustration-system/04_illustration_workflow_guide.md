# Illustratie-workflowgids

Deze gids beschrijft de herhaalbare workflow om illustraties te produceren voor een dialoog, in dezelfde geest als `docs/thai_a1_dialog_workflow_guide.md`: de database blijft bron van waarheid voor alles wat er al in staat, planning wordt telkens herbouwd, en alleen goedgekeurde eindresultaten (`dialog_slides.image_url`) worden definitief opgeslagen.

Deze workflow start pas **nadat** een dialoog volledig is goedgekeurd en opgeslagen in `dialogs`/`dialog_blocks` (stap 10 van de dialoogworkflowgids).

**Waarom volstaat een korte prompt als "genereer de slides voor dialoog X"?** Dit bestand wordt permanent geladen via `CLAUDE.md` (`@docs/illustration-system/04_illustration_workflow_guide.md`). Alle overige input die nodig is (dialoogtekst, cast sheet, face-locks, scene bibles) staat al in de database of in bestanden onder `docs/illustration-system/`.

## De vier stappen

```
dialog_blueprint_specs + dialogs + dialog_blocks + character_profiles  (DB, bestaand)
              │
              ▼
       Scene Bible (.md)              — automatisch concept, jij keurt sfeer/palet goed
              │
              ▼
   Slide Specifications (.md)         — automatisch concept, jij keurt segmentatie en moment goed
              │
              ▼
    Illustration Prompt (.md)         — mechanisch samengesteld, jij doet finale QA
              │
              ▼
        ChatGPT (of andere image-generator)      ← extern, buiten dit project
              │
              ▼
   afbeelding downloaden + hernoemen naar slide-{nn}.png,
   zetten in illustration-staging/{lesson_key}/ (Stap 6b)
              │
              ▼
   scripts/upload-slides.mjs (Stap 7-8, geautomatiseerd):
   upload naar Supabase Storage bucket "illustrations"
   + dialog_slides.image_url bijwerken
```

## Stap 0 — Eenmalige setup: Face Lock referenties (per personage, vóór de eerste dialoog met dat personage)

Vóór een personage voor het eerst in een dialoogillustratie verschijnt, moet er een **face lock**-referentie bestaan: drie close-up headshots (front + 3/4 + profiel) die als primaire gezichtsanker dienen. Zonder deze referentie leunt de generator te veel op tekstuele Thai Identity Rules alleen, wat in de praktijk onvoldoende bleek (zie `01_master_style_system.md` → Thai Facial Identity — Strict Requirements). De profielhoek is toegevoegd nadat bleek dat scènes met personages in bijna-profiel (zoals een dialoog waarin twee mensen elkaar aankijken) zonder die referentie duidelijk van de vergrendelde identiteit afweken.

1. Gebruik `templates/face-lock-reference-prompt.template.md` om de drie headshots te genereren.
2. Sla ze op als `cast-references/[character_key]/face-lock.png`.

Dit is een eenmalige actie per personage, geen herhaalstap per dialoog — eenmaal aangemaakt, wordt de face lock-referentie bij elke volgende slide van dat personage hergebruikt (zie Stap 5).

## Stap 1 — Bevestig dat de dialoog klaar is

Controleer dat er een rij bestaat in `dialogs` met bijbehorende `dialog_blocks` voor de `lesson_key`. Zonder afgeronde dialoogtekst kan er geen Scene Bible of Slide Specification zinvol worden ingevuld.

## Stap 2 — Stel de Scene Bible op

Gebruik `templates/scene-bible.template.md`. Vul de DB-velden in vanuit `dialog_blueprint_specs` (`suggested_location`, `allowed_register`) en `dialogs.scene_summary`. Vul de nieuwe illustratie-specifieke velden (tijd, weer, sfeer, palet) creatief in, passend bij de scene_summary.

Sla op als `scene-bibles/a1_dialog_XX_scene_bible.md`.

**Jouw goedkeuring nodig voor:** sfeer, tijd van de dag, palet — dit zijn keuzes die niet uit de database zijn af te leiden.

## Stap 3 — Segmenteer de dialoog in slides

Dit is de stap waar jij Claude vraagt: "genereer de slides voor dialoog X". Claude werkt dan als volgt:

1. Claude leest **alle** `dialog_blocks` van de dialoog in samenhang (niet blok per blok los), inclusief Thaise tekst en Engelse vertaling.
2. Claude groepeert opeenvolgende blokken tot slides op basis van **natuurlijke gespreksmomenten** — een slide-wissel is altijd gemotiveerd door een verandering in wie spreekt, welke emotie, of welk gebaar, nooit door een visuele reden (zie `03_scene_and_continuity_rules.md`).
3. Vuistregels:
   - **Minimaal 3 slides** voor een dialoog van 6 of meer regels.
   - **Maximaal ~2 gespreksuitwisselingen per slide**, om te vermijden dat één illustratie te veel gelijktijdige actie of emotie moet tonen ("visually busy" — expliciet verboden in de Background Style Rules).
   - Een groet-en-introductie, een vraag-en-antwoord, en een afsluiting zijn typische natuurlijke slide-grenzen.
4. Claude levert het segmentatievoorstel + ingevulde "Moment in Dialogue"-velden per slide aan jou, via `templates/slide-specification.template.md`.
5. **Jij keurt de segmentatie en de moment-beschrijvingen goed** vóór Claude prompts genereert — een verkeerde knip kost een overbodige illustratie.

Sla op als `slide-specs/a1_dialog_XX_slide_specs.md`.

Correspondentie met de database: elke goedgekeurde slide moet een rij worden in `dialog_slides` met het juiste `slide_index` (0-based, net als `block_index`), `first_block_index`, `last_block_index`. Dit gebeurt **niet automatisch** — maak een eigen seed-bestand `seed-data/dialogs/a1_dialog_XX_slides.seed.sql` aan (los van `a1_dialog_XX.seed.sql`, want die is al aangemaakt/gecommit tijdens de basis-dialoogworkflow, ruim vóór deze segmentatie bekend is — zie `docs/thai_a1_dialog_workflow_guide.md` Stap 10), in dezelfde idempotente stijl (`on conflict ... do update`) als de bestaande inserts voor `dialogs` en `dialog_blocks`. `image_url` blijft hierbij `null` — dat vult `scripts/upload-slides.mjs` later in (Stap 7–8).

Gebruik dit sjabloon als basis — vervang `a1_dialog_XX`, de omschrijvingen in de commentaarregels, en vul de `values`-lijst met exact de rijen uit de segmentatietabel van `slide-specs/a1_dialog_XX_slide_specs.md` (één rij per slide, `slide_index` 0-based):

```sql
begin;

-- =========================================================
-- a1_dialog_XX — dialog_slides
--
-- Hoort bij de illustratieworkflow, niet bij de basis-
-- dialoogworkflow: deze segmentatie wordt pas bepaald in
-- Stap 3 van docs/illustration-system/04_illustration_workflow_guide.md,
-- ruim na goedkeuring van de dialoog zelf (dialogs/dialog_blocks,
-- zie docs/thai_a1_dialog_workflow_guide.md Stap 10). Daarom een
-- eigen bestand in plaats van een derde blok in
-- a1_dialog_XX.seed.sql.
--
-- Segmentatie-bron: docs/illustration-system/slide-specs/a1_dialog_XX_slide_specs.md
-- slide_index is 0-based, net als block_index in dialog_blocks.
-- image_url blijft null -- die vult scripts/upload-slides.mjs later
-- in, na handmatige generatie en goedkeuring van de illustraties.
-- =========================================================

with dialog as (
  select id
  from public.dialogs
  where lesson_id = (select id from public.lessons where lesson_key = 'a1-dialog-XX')
)
insert into public.dialog_slides (dialog_id, slide_index, first_block_index, last_block_index)
select
  dialog.id,
  slide.slide_index,
  slide.first_block_index,
  slide.last_block_index
from dialog
cross join (values
  (0, 0, 1), -- Slide 1: ... (blokken 0-1)
  (1, 2, 3)  -- Slide 2: ... (blokken 2-3)
  -- voeg hier één rij per slide toe
) as slide(slide_index, first_block_index, last_block_index)
on conflict (dialog_id, slide_index) do update set
  first_block_index = excluded.first_block_index,
  last_block_index  = excluded.last_block_index,
  updated_at         = now();

commit;
```
Voer de seed uit met het commando:

psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -f supabase/seed-data/dialogs/a1_dialog_XX_slides.seed.sql

## Stap 4 — Genereer de Illustration Prompt(s)

Voor elke goedgekeurde slide stelt Claude mechanisch de finale prompt samen uit:

1. Master Style Prompt + Thai Identity Rules (`01_master_style_system.md`) — verbatim, ongewijzigd
2. De relevante Locked Cast-entries (`02_locked_cast_sheet.md`) — alleen de personages die in deze slide voorkomen
3. De Scene Bible van deze dialoog (stap 2)
4. Het Moment in Dialogue van deze specifieke slide (stap 3)

Sla op als `prompts/a1_dialog_XX/slide_nn_prompt.md`, volgens `templates/illustration-prompt.template.md`.

Dit is de laatste automatische stap — er wordt hier niets nieuws bedacht, alleen samengevoegd.

## Stap 5 — Genereer de afbeelding (extern, handmatig)

Kopieer de finale prompt naar ChatGPT (of een andere image-generator naar keuze).

**Voeg altijd referentieafbeeldingen toe — dit is niet optioneel.** Tekstuele paletbeschrijvingen alleen garanderen geen exacte kleur-/toonmatch, en tekstuele Thai Identity Rules alleen bleken in de praktijk onvoldoende voor een betrouwbaar Thai gezicht. Een image-generator verankert zich veel sterker op een meegestuurde afbeelding dan op tekst. Voeg standaard toe:

1. `public/hero-image.png` — als stijl-/paletreferentie (kleurtemperatuur, licht, rendering). Dit is dezelfde referentie die al gebruikt is om de bestaande hero image te genereren.
2. De **face lock**-referenties (front + 3/4 + profiel) van elk personage dat in deze slide voorkomt (zie Stap 0) — als primaire gezichtsanker. Verplicht; zonder face lock-referentie is het risico op een niet-Thais gezicht hoog. **Kies de hoek die het dichtst bij de pose in het Moment in Dialogue ligt** (front voor frontale poses, 3/4 voor driekwartposes, profiel voor personages die elkaar aankijken/bijna-profiel) — stuur bij twijfel meerdere hoeken mee, maar laat de dichtstbijzijnde nooit weg. Dit is precies wat in de eerste test van Dialog 1 misging: beide personages stonden bijna in profiel, terwijl alleen front + 3/4 waren meegestuurd.
3. De goedgekeurde full-body/cast-referentie-afbeeldingen van elk personage dat in deze slide voorkomt — dezelfde afbeeldingen die al voor de hero image zijn gebruikt — als aanvullende referentie voor hairstyle, outfit en silhouet.
4. Zodra beschikbaar: de vorige goedgekeurde slide(s) van dezelfde dialoog — als continuïteitsreferentie (zelfde scène, net iets eerder in het gesprek).

Zie `01_master_style_system.md` → Reference Image Usage Rules voor hoe deze vier soorten referenties uit elkaar gehouden worden (stijl vs. gezicht vs. identiteit vs. continuïteit), zodat de generator ze niet door elkaar haalt en geen pose/compositie overneemt die niet bedoeld was.

**Stuur ook altijd het Negative Prompt-blok mee** (`01_master_style_system.md` → Negative Prompt (Thai Identity)) — dit hoort al standaard in elke samengestelde Illustration Prompt, maar controleer dat het niet per ongeluk is weggeknipt bij het kopiëren naar de generator.

**Praktische tips (uit ervaring met Dialog 1):**

- Werk voor alle slides van dezelfde dialoog in **dezelfde ChatGPT-chatsessie** — dat houdt de gezichtsinterpretatie consistenter dan telkens een nieuwe sessie starten.
- Herhaal de kernzin van de Thai Identity Rules ("these are adult Thai people, not Korean or western") ook los, direct vóór je op genereren klikt, zelfs al staat het al in de prompt — expliciete herhaling helpt.

Dit gebeurt volledig buiten dit project — hetzelfde principe als bij dialooggeneratie, waar de AI-output ook extern wordt gegenereerd en pas na goedkeuring wordt opgeslagen.

## Stap 6 — Visuele QA

Controleer minstens:

- Blijft de identiteit van elk personage herkenbaar t.o.v. de Locked Cast Sheet?
- **Is het gezicht van elk personage duidelijk Thai** — geen westerse, Koreaanse, Japanse of generiek-Aziatische trekken? Toets tegen `01_master_style_system.md` → Thai Facial Identity — Strict Requirements.
- Blijft de scène consistent met vorige slides van dezelfde dialoog (locatie, licht, sfeer)?
- Voldoet de compositie aan de Dialogue Composition Rules (medium-wide, horizontaal, geen close-up)?
- Is de achtergrond rustig genoeg (Background Style Rules)?
- Komt het educational focus van deze slide visueel over?

## Stap 6a — Correctieprotocol bij een niet-Thais gezicht

Als de gezichten bij QA nog niet duidelijk Thai genoeg zijn, ga niet zomaar opnieuw genereren met dezelfde prompt — geef gerichte correctietaal mee in dezelfde chatsessie, bijvoorbeeld:

```
Maak de gezichten duidelijker Thai. Zachtere oogvorm, bredere neus met lagere
neusbrug, warme olijf- tot goudtint huid, voller gezicht. NIET westers of
Koreaans.
```

Herhaal dit zo nodig iteratief — benoem telkens specifiek welk gezichtskenmerk nog niet klopt, in plaats van de hele prompt opnieuw te versturen. Zodra een generatie wél slaagt, overweeg de geslaagde afbeelding zelf als toekomstige face lock-referentie te gebruiken (i.p.v. de oorspronkelijke face lock-referentie), zodat de correctie "vastklikt" voor volgende slides.

## Stap 6b — Download, hernoem en zet in de staging-map

Zodra een slide de QA (Stap 6/6a) doorstaat, staat de afbeelding nog alleen extern (bv. als download in je browser). Er is **geen aparte projectmap** nodig om deze afbeeldingen blijvend te bewaren — ze worden niet gecommit naar git, want Supabase Storage is de enige bron van waarheid voor `dialog_slides.image_url` (zie `05_storage_strategy.md`, zelfde "wegwerpbaar"-principe als bij de Illustration Prompt-tekst). Er is wél een vaste, tijdelijke **staging-map** nodig, zodat `scripts/upload-slides.mjs` (Stap 7) weet waar het moet zoeken.

1. Download de goedgekeurde afbeelding uit ChatGPT (of de gekozen generator).
2. Hernoem het bestand naar `slide-{nn}.png`, zero-padded, overeenkomend met `dialog_slides.slide_index` van die slide. **`slide_index` is 0-based**, net als `block_index` in dezelfde tabel-familie — de eerste slide van een dialoog heeft dus `slide_index = 0` en wordt `slide-00.png`, niet `slide-01.png`. Controleer het exacte nummer in de bijbehorende `slide-specs/a1_dialog_XX_slide_specs.md` (sectie "Herkomst" per slide). **Dit nummer is de enige manier waarop het script weet welke afbeelding bij welke slide hoort** — het gokt nooit op bestandsvolgorde of downloaddatum, omdat geen van beide betrouwbaar de bedoelde slide-index weergeeft.
3. Zet het bestand in `illustration-staging/{lesson_key}/` (bv. `illustration-staging/a1-dialog-01/slide-00.png`). Deze map staat in `.gitignore` en wordt dus nooit gecommit.
4. Controleer dat het bestand voldoet aan de bucket-restricties uit de migratie (`supabase/migrations/20260702120000_create_illustrations_storage_bucket.sql`): type `image/png`, `image/jpeg` of `image/webp`, max. 10 MB. Deze 10 MB-limiet geldt in de praktijk nauwelijks meer als risico: het script verkleint en converteert elk bestand eerst naar WebP (zie Stap 7) vóór het uploadt, en controleert daarna zelf de grootte van dát verwerkte bestand — een ruime bron-PNG wordt dus niet meer geweigerd, enkel een resultaat dat ook ná verkleining/compressie nog te groot is.
5. Bewaar tijdens iteratieve correctie (Stap 6a) desgewenst meerdere pogingen naast elkaar met een tijdelijke naam **buiten** de staging-map, maar zet voor upload alleen de uiteindelijk goedgekeurde versie onder de definitieve naam ín de staging-map.
6. Zodra Stap 7 geslaagd is, heeft het lokale bestand geen functie meer buiten Supabase Storage. Het script verwijdert het echter **niet automatisch** (bewuste keuze) — ruim het zelf op wanneer je daar klaar voor bent.

## Stap 7 — Upload naar Supabase Storage (geautomatiseerd)

Bucket: **`illustrations`** (zie `05_storage_strategy.md` voor waarom dit een eigen bucket is, gescheiden van `audio`).

Voer uit:

```
node --env-file=.env.local scripts/upload-slides.mjs
```

Dit verwerkt in één keer alle dialogen met openstaande slides (`dialog_slides.image_url is null`), elk gelezen uit hun eigen `illustration-staging/{lesson_key}/`.

Nuttige varianten:

```
# Alleen deze dialoog
node --env-file=.env.local scripts/upload-slides.mjs --dialog a1-dialog-01

# Andere staging-map dan de standaardlocatie
node --env-file=.env.local scripts/upload-slides.mjs --dialog a1-dialog-01 --input-dir ~/Downloads/dialog-01-slides

# Ook slides met een bestaande image_url opnieuw verwerken
# (bv. een afgekeurde illustratie vervangen)
node --env-file=.env.local scripts/upload-slides.mjs --dialog a1-dialog-01 --force

# Dry-run: toont welk bestand aan welke slide gekoppeld zou worden,
# zonder te uploaden of de database te wijzigen — gebruik dit altijd
# eerst ter controle
node --env-file=.env.local scripts/upload-slides.mjs --dry-run
```

Vóór het uploaden verkleint het script elke afbeelding via `sharp` naar max. 1200×800 (`fit: "cover"`, geen vervorming) en zet het om naar WebP (kwaliteit 85) — de bron-PNG's uit ChatGPT (1536×1024) zijn ruim groter dan de daadwerkelijke weergavegrootte in de UI en onnodig zwaar als lossless PNG. Dit gebeurt volledig in-memory: het lokale bestand in de staging-map blijft ongewijzigd staan (zie Stap 6b) — bewust, want een lokale `supabase db reset` veegt de storage-bucket leeg, en de staging-map is dan de enige plek vanwaar opnieuw geüpload kan worden.

Padstructuur binnen de bucket (analoog aan `buildStoragePath()` in `scripts/generate-audio.mjs`):

```
illustrations/dialogs/{level}/{dialogPart}/slides/slide-{nn}.webp
```

`{level}` en `{dialogPart}` zijn geen vrije titel-slug maar rechtstreeks afgeleid van `lesson_key`, met dezelfde split als in `generate-audio.mjs` (splits op de eerste `-`):

```
lesson_key 'a1-dialog-01' → level = 'a1', dialogPart = 'dialog-01'
```

Bijvoorbeeld (eerste slide, `slide_index = 0`): `illustrations/dialogs/a1/dialog-01/slides/slide-00.webp` — ongeacht of het lokale staging-bestand `.png`, `.jpg` of `.webp` was, de bucket bevat altijd `.webp`.

Het script roept zelf geen enkele generatie-API aan — het verwerkt alleen wat al lokaal staat, ná Stap 5/6.

## Stap 8 — `dialog_slides.image_url` wordt bijgewerkt (automatisch)

`scripts/upload-slides.mjs` werkt na een geslaagde upload meteen `dialog_slides.image_url` en `updated_at` bij voor de betreffende rij — je hoeft hiervoor geen losse SQL meer uit te voeren.

Als de rij in `dialog_slides` nog niet bestaat (nieuwe dialoog, nog geen slides gedefinieerd), moet die eerst worden aangemaakt met `slide_index`, `first_block_index`, `last_block_index` — dat gebeurt normaal al bij het opzetten van de dialoog-afspeellogica, onafhankelijk van illustraties, en valt buiten dit script.

Ter referentie, dit is het equivalent van wat het script uitvoert:

```sql
update public.dialog_slides
set image_url = '[storage-url]',
    updated_at = now()
where dialog_id = (select id from public.dialogs where lesson_id = (
  select id from public.lessons where lesson_key = 'a1-dialog-XX'
))
and slide_index = [nn];
```

## Stap 9 — Commit

Commit samen:

- `scene-bibles/a1_dialog_XX_scene_bible.md`
- `slide-specs/a1_dialog_XX_slide_specs.md`
- `prompts/a1_dialog_XX/slide_nn_prompt.md` (alle slides)

Er is geen losse SQL-update meer om te committen — die schrijft `scripts/upload-slides.mjs` rechtstreeks naar de database.

De afbeeldingen zelf (`slide-nn.png`) en de staging-map (`illustration-staging/`) worden **niet** gecommit — die staan alleen lokaal tussen Stap 6b en Stap 7/8, en zijn overbodig zodra `dialog_slides.image_url` naar Supabase Storage wijst (zie Stap 6b).

## Nieuw personage toevoegen

Gebruik `templates/new-character.template.md`. Voeg het personage **eerst** toe aan `character_profiles` (database), genereer daarna een referentie-illustratie, en voeg het personage pas na goedkeuring toe aan `02_locked_cast_sheet.md`.

## Nieuwe losstaande scène (hero/lesillustratie, geen dialoogslideshow)

Gebruik `templates/new-scene.template.md`. Dezelfde Master Style Prompt en Locked Cast Sheet zijn van toepassing; er is geen Scene Bible/Slide Specification nodig omdat er geen doorlopende conversatie is.

## Praktische checklist per nieuwe dialoog

0. Controleer dat elk personage in de dialoog al een face lock-referentie heeft (`02_locked_cast_sheet.md`); zo niet, maak die eerst aan (Stap 0).
1. Bevestig dat de dialoog is goedgekeurd en opgeslagen (`dialogs`/`dialog_blocks`).
2. Stel de Scene Bible op en laat goedkeuren.
3. Vraag de segmentatie + Moment in Dialogue per slide aan en laat goedkeuren.
4. Genereer de Illustration Prompt(s).
5. Genereer de afbeelding(en) via ChatGPT — met hero image, face lock-referenties, cast-referenties en vorige slide als bijlage, in dezelfde chatsessie.
6. Voer visuele QA uit, inclusief expliciete Thai-gezichtscontrole; corrigeer indien nodig via Stap 6a.
7. Download de goedgekeurde afbeelding(en), hernoem naar `slide-{nn}.png` en zet ze in `illustration-staging/{lesson_key}/` (Stap 6b).
8. Voer `node --env-file=.env.local scripts/upload-slides.mjs --dialog {lesson_key} --dry-run` uit ter controle, en daarna zonder `--dry-run` om daadwerkelijk te uploaden naar de `illustrations`-bucket en `dialog_slides.image_url` bij te werken (Stap 7–8).
9. Commit de planning- en generatiebestanden (geen afbeeldingen, geen staging-map — zie Stap 9).
