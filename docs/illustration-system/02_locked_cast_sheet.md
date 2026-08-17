# Locked Cast Sheet

Deze cast is **vergrendeld**: elk personage moet er in elke illustratie, in elke dialoog, herkenbaar hetzelfde uitzien. De narratieve/pedagogische identiteit van deze personages staat al in de database (`character_profiles`, `relationship_pairs`, `relationship_pair_rules`) — dit document bevat de **visuele** identiteit, die (nog) niet in de database zit. Zie `05_storage_strategy.md` voor de motivatie.

## Kruisverwijzing naar de database

| `character_key` | Naam (Thai) | Rol in database (`role_summary`)                                                        |
| --------------- | ----------- | --------------------------------------------------------------------------------------- |
| `narin`         | นริน        | Central anchor character; calm, socially capable, dependable, connector between groups. |
| `mali`          | มะลิ        | Adult woman with a polished, professional-adjacent presence; organized and polite.      |
| `ploy`          | พลอย        | Relaxed younger urban adult; casual and modern.                                         |
| `dao`           | ดาว         | Warm and friendly adult woman; gentle and supportive.                                   |
| `lin`           | ลิน         | Youngest adult figure; study-oriented, modest, careful.                                 |
| `suda`          | สุดา        | Middle-aged grounding figure; practical, caring, neighborhood/home anchor.              |
| `kiet`          | เกียรติ     | Friendly practical man; colleague or peer type.                                         |
| `arun`          | อรุณ        | Older established man; calm authority presence.                                         |

Gebruik altijd de `character_key` als referentie wanneer je een personage in een Scene Bible of Slide Specification noemt, zodat een illustratie-request altijd terug te herleiden is naar de exacte databaserij.

## Narin

Adult Thai man. Main recurring character. Calm, approachable, believable. Friendly and socially confident.

Must remain consistent in:

- facial identity
- hairstyle
- age impression
- outfit logic

## Mali

Neat adult Thai woman. Refined smart-casual appearance. Calm and polished. Soft neutral palette. Elegant flats or minimal loafers.

## Ploy

Younger adult Thai woman. Casual urban styling. Modern and approachable.

## Dao

Adult Thai woman. Slightly more feminine presentation. Warm and approachable.

## Lin

Youngest adult woman in cast. Early twenties. Study-oriented. Modest and practical.

## Suda

Middle-aged Thai woman. Late 40s to early 50s. Warm and reliable. Grounded adult presence.

## Kiet

Thai man around 35. Friendly colleague type. Approachable and practical.

## Arun

Thai man around 44. Calm authority figure. More established than Kiet. Subtle gray at temples.

## Core Visual Rules

All recurring characters must:

- remain clearly Thai
- remain within one illustration style
- maintain identity consistency

Differentiate characters through:

- age impression
- hairstyle
- outfit structure
- footwear
- silhouette
- social energy

**Never redesign characters accidentally.**

## Full-body Cast Referenties

Naast de face lock-referenties (hieronder) bestaat er per personage ook een **full-body cast-referentie**: een enkele figuur, rechtstreeks van voren, volledig zichtbaar van hoofd tot voeten, op een neutrale effen achtergrond. Dit is de referentie die gebruikt is om de bestaande hero image te genereren, en die ook standaard wordt meegestuurd als reference type #3 in elke Illustration Prompt (zie `04_illustration_workflow_guide.md` stap 5).

### Prompt

Gebruik `templates/full-body-cast-reference-prompt.template.md` — het generieke "Master Prompt voor elke figuur"-sjabloon, uitsluitend bedoeld voor **nieuwe** personages. Bestaande personages zijn vaak via meerdere iteraties/correcties tot stand gekomen (zie Stap 6a-achtige correctietaal in `04_illustration_workflow_guide.md`); de uiteindelijke prompt per personage is daardoor niet representatief genoeg om te bewaren en wordt bewust **niet** opgeslagen. Alleen het eindresultaat (de afbeelding) telt als bron van waarheid voor identiteit.

### Opslagconventie

```
docs/illustration-system/cast-references/{character_key}/full-body.png
```

Geen los promptbestand per personage — zie motivatie hierboven.

## Face Lock Referenties

**Waarom nodig:** een eerste testgeneratie (Dialog 1, Slide 1) leverde gezichten op die niet duidelijk genoeg Thai waren, ondanks de Thai Identity Rules in `01_master_style_system.md`. Een full-body scenebeeld (zoals `hero-image.png`) verankert een gezicht onvoldoende sterk, omdat het gezicht daar maar een klein deel van de compositie is. Oplossing: per personage een eigen close-up **face lock**-referentie, die bij élke generatie waarin dat personage voorkomt wordt meegestuurd naast de stijl- en scenereferenties.

### Wat een face lock-referentie is

Per personage drie close-up headshots, in dezelfde illustratiestijl als de rest van de cast (niet fotorealistisch):

1. **Front-facing** — recht van voren, neutrale uitdrukking, goede/egale belichting.
2. **Driekwart-hoek (3/4)** — hoofd licht gedraaid, zodat neusbrug en kaaklijn duidelijk zichtbaar zijn, neutrale uitdrukking.
3. **Profiel** — hoofd volledig zijwaarts gedraaid, neutrale uitdrukking, consequent dezelfde kijkrichting voor alle personages (zie template).

**Waarom een profielhoek:** bij het testen van Dialog 1 Slide 1 week het gezicht duidelijk af van de front/3-4 referenties zodra de personages in bijna-profiel stonden (twee mensen die elkaar aankijken) — een hoek die in dialoogscènes structureel terugkomt, geen randgeval. Zie `01_master_style_system.md` → Reference Image Usage Rules voor hoe je de dichtstbijzijnde hoek kiest bij het samenstellen van een Illustration Prompt.

Gebruik `templates/face-lock-reference-prompt.template.md` om deze drie afbeeldingen te genereren. Sla ze op als:

```
docs/illustration-system/cast-references/{character_key}/face-lock.png

```

Elke Illustration Prompt voor een dialoog met dat personage moet de relevante face lock-referentie(s) verplicht meesturen (zie `04_illustration_workflow_guide.md`).

### Waarom dit apart van de Full-body Cast Referenties hierboven

De full-body referenties tonen het personage van hoofd tot voeten op een neutrale achtergrond. Ze blijven waardevol als stijl-/silhouet-/outfitreferentie, maar zijn niet close-up genoeg om als primaire gezichtsanker te dienen — het gezicht neemt maar een klein deel van de compositie in. Face lock-referenties vervangen de full-body referenties niet — ze worden **samen** meegestuurd: full-body voor stijl, silhouet en outfit, face lock voor de exacte gezichtsstructuur (zie Reference Image Usage Rules in `01_master_style_system.md`).

## Wanneer een nieuw personage nodig is

Gebruik `templates/new-character.template.md`. Voeg het personage ook toe aan `character_profiles` in de database (narratieve identiteit) vóórdat je het in een dialoog laat optreden — de visuele cast sheet en de database-cast moeten altijd in sync blijven. Zie stap "Nieuw personage toevoegen" in `04_illustration_workflow_guide.md`.
