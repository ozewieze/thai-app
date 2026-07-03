# Illustratie-workflowgids

Deze gids beschrijft de herhaalbare workflow om illustraties te produceren voor een dialoog, in dezelfde geest als `docs/thai_a1_dialog_workflow_guide.md`: de database blijft bron van waarheid voor alles wat er al in staat, planning wordt telkens herbouwd, en alleen goedgekeurde eindresultaten (`dialog_slides.image_url`) worden definitief opgeslagen.

Deze workflow start pas **nadat** een dialoog volledig is goedgekeurd en opgeslagen in `dialogs`/`dialog_blocks` (stap 10 van de dialoogworkflowgids).

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
   afbeelding downloaden + hernoemen
              │
              ▼
  upload naar Supabase Storage bucket "illustrations"
              │
              ▼
     dialog_slides.image_url bijwerken (DB)
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

Correspondentie met de database: elke goedgekeurde slide wordt (of is al) een rij in `dialog_slides` met het juiste `slide_index`, `first_block_index`, `last_block_index`.

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

## Stap 7 — Upload naar Supabase Storage

Bucket: **`illustrations`** (zie `05_storage_strategy.md` voor waarom dit een eigen bucket is, gescheiden van `audio`).

Padstructuur (analoog aan de audio-bucket):

```
illustrations/dialogs/{cefr_level}/{dialog-slug}/slides/slide-{nn}.png
```

Bijvoorbeeld: `illustrations/dialogs/a1/greetings-and-introductions/slides/slide-01.png`

Nu: handmatige upload via Supabase Studio of de Storage API. Later: `scripts/upload-slides.mjs` (nog te bouwen, analoog aan `scripts/merge-audio.mjs`) automatiseert dit en werkt meteen `dialog_slides.image_url` bij.

## Stap 8 — Werk `dialog_slides.image_url` bij

```sql
update public.dialog_slides
set image_url = '[storage-url]',
    updated_at = now()
where dialog_id = (select id from public.dialogs where lesson_id = (
  select id from public.lessons where lesson_key = 'a1-dialog-XX'
))
and slide_index = [nn];
```

Als de rij in `dialog_slides` nog niet bestaat (nieuwe dialoog, nog geen slides gedefinieerd), insert dan eerst de rij met `slide_index`, `first_block_index`, `last_block_index` — dat gebeurt normaal al bij het opzetten van de dialoog-afspeellogica, onafhankelijk van illustraties.

## Stap 9 — Commit

Commit samen:

- `scene-bibles/a1_dialog_XX_scene_bible.md`
- `slide-specs/a1_dialog_XX_slide_specs.md`
- `prompts/a1_dialog_XX/slide_nn_prompt.md` (alle slides)
- de SQL-update van `dialog_slides.image_url` (of het seedbestand indien van toepassing)

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
7. Upload naar de `illustrations`-bucket.
8. Werk `dialog_slides.image_url` bij.
9. Commit alle bestanden.
