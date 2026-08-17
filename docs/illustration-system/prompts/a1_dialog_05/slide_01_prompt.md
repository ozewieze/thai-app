# Illustration Prompt — a1_dialog_05 / Slide 1

## Samenstelling (ter controle, niet meesturen naar de generator)

- Master Style Prompt: `01_master_style_system.md`
- Cast-entries: `02_locked_cast_sheet.md` → `mali`, `narin`
- Scene Bible: `scene-bibles/a1_dialog_05_scene_bible.md`
- Slide Specification: `slide-specs/a1_dialog_05_slide_specs.md` → Slide 1

## Verplicht mee te sturen referentieafbeeldingen (niet optioneel)

1. `public/hero-image.png` — stijl-/paletreferentie
2. Face lock-referenties van Mali en Narin (front + 3/4 + profiel). Mali proeft/reageert op de cake terwijl Narin haar aankijkt — driekwart is hier de belangrijkste hoek, stuur alle drie mee.
3. Goedgekeurde full-body cast-referentie-afbeeldingen van Mali en Narin — aanvullende referentie (dezelfde afbeeldingen als gebruikt voor de hero image)
4. n.v.t. — dit is de eerste slide van deze dialoog, geen vorige slide binnen `a1_dialog_05` om als continuïteitsreferentie te gebruiken. (Optioneel, niet verplicht: de laatste goedgekeurde slide van `a1_dialog_04` kan meegestuurd worden als extra locatie-/sfeercontinuïteit, zelfde tafeltje.)

**Let op:** deze slide legt de vaste achtergrond (camerahoek, framing, meubels, lichtinval) vast waar Slide 2 en Slide 3 van deze dialoog pixelconsistent op moeten aansluiten (zie Background Lock Rule in `01_master_style_system.md`, meegenomen in de prompts van Slide 2 en 3). **In tegenstelling tot Dialog 3/4 staat de tafel hier niet leeg**: de bestelling is al geserveerd (zie Scene hieronder) en moet in alle drie slides van deze dialoog identiek blijven staan.

## Finale prompt

```
Use the attached character illustration(s) as the primary reference(s) for identity,
facial structure, hairstyle, body proportions, outfit logic, footwear logic, muted
color balance, and recurring cast consistency.

Keep all recurring characters consistent across scenes as if they belong to one
unified illustrated cast.

Keep the exact same illustration style, maturity level, visual finish, shading
approach, proportions, and overall premium adult language-learning aesthetic as
the reference images.

Match the level of refinement exactly, especially in facial treatment, clothing
structure, silhouette clarity, and adult professional tone. Do not make the
result more cartoonish, more playful, more exaggerated, or more simplified than
the reference illustrations.

All characters must clearly remain Thai in facial structure, eye shape, nose
shape, mouth shape, skin tone, and overall appearance. Use consistent Thai
facial features: soft facial features, almond-shaped eyes, a natural (not
high, not narrow) nose bridge, full but soft lips, and a warm, light
golden-olive skin tone. Avoid western, Korean, Japanese, or generically
"internationally neutral" faces. Avoid large round eyes, a narrow/high nose
bridge, pale skin, double-eyelid western-style eyes, or other non-Thai facial
features. Preserve the exact facial structure shown in the reference images.
If in doubt, choose the clearer Thai interpretation — never an
internationally generic face.

Negative prompt: not western, not european, not korean, not japanese, not
chinese, not generically asian; no high nose bridge, no narrow nose, no pale
skin, no large round eyes, no western-style double eyelids; no
3D/photorealistic rendering, no cartoon style; no beauty-ideal/influencer-style
face.

Use the attached reference images carefully and selectively. Preserve identity,
style, and design logic where intended, but do not accidentally copy pose, scene
composition, or clothing details unless explicitly requested.

When a reference image is attached for style (e.g. the platform hero image),
match not only the illustration style and color palette, but also the overall
lighting treatment, contrast level, shadow softness, saturation, and
atmospheric rendering. Treat the reference image as the master source for
visual mood and color grading. Adapt the light source naturally to the scene
context (daytime, evening, indoor, or night), while preserving the same
restrained contrast, soft shadow transitions, muted premium color palette,
gentle tonal compression, and subtle atmospheric softness. Avoid dramatic
lighting, harsh shadow edges, strong cast shadows, overly vivid colors, or
high-contrast rendering unless explicitly requested. Treat it strictly as a
style reference — not as a character identity or composition reference for
the new scene.

The hero image's specific environment must never be reused. Its living room,
window, shelving, furniture, and decorative objects belong only to the hero
image — they are not a template or default setting for other scenes. This
scene's environment, location, and objects come exclusively from the Scene
description below. Only the rendering philosophy (color grading, lighting
softness, contrast, saturation, as described above) carries over from the
hero image; its content never does.

When a reference image is attached for a specific character (a locked cast
reference), treat it as the identity source for that character's face,
hairstyle, proportions, and outfit logic — but not for pose or scene
composition, unless the new scene explicitly reuses that pose.

When a close-up "face lock" reference is attached for a specific character
(front-facing, three-quarter, and/or profile headshot), treat it as the
primary, highest-priority source for that character's exact facial structure
— eye shape, nose bridge, mouth shape, jawline, and skin tone — overriding
any looser facial impression from a full-body or scene reference of the same
character.

When the pose in the new scene turns a character's head or body toward a
side or three-quarter angle, prioritize the face lock reference whose angle
is closest to that pose (front for front-facing poses, three-quarter for
three-quarter poses, profile for side/near-profile poses). Do not rely on a
front-facing reference alone to infer a profile view — facial accuracy
degrades significantly across angles the reference does not cover.

Characters in this scene:
- Mali: neat adult Thai woman, refined smart-casual appearance, calm and
  polished, soft neutral palette, elegant flats or minimal loafers.
- Narin: adult Thai man, main recurring character, calm, approachable,
  believable, friendly and socially confident.
Keep both characters' identity, hairstyle, and outfit logic locked — do not
redesign them.

Scene (this dialogue's own setting — do not reuse the hero image's living
room, furniture, or architecture, only its rendering philosophy): a quiet
corner of a coffee shop, seated at the same small café table as Dialog 4,
daytime with soft natural light, minimal furniture (a chair, a small table,
perhaps a plant), softly detailed. A richer selection of Thai decorative
touches is welcome — for example patterned cushions or textile details,
warm teak or rattan wood tones, a small tabletop fountain, framed
Thai-style artwork or botanical prints, or decorative Thai ceramics — as
long as it reads as a considered, contemporary interior rather than a
cluttered souvenir shop. Avoid literal shop signage, tourist-market
clichés, religious imagery (e.g. Buddha statues, spirit houses, or
altars), or visual clutter that would date or over-localize the scene.
Unlike Dialog 3/4, where the table was deliberately empty, the just-served
order is already on the table and stays unchanged across all three slides
of this dialogue: Mali has an iced coffee in a tall glass (coffee, ice
cubes, a swirl of crème fraîche/whipped cream on top, a straw) beside a
slice of cake on a small plate; Narin has a cup/glass of tea and a bowl or
cup of ice cream. No one gestures toward, points at, or touches the other
person's items — each stays with their own. Clean and uncluttered overall.
Color palette: warm off-whites, muted warm neutrals, soft sand tones,
restrained saturation.

Moment: Narin asks if the cake in front of Mali is delicious; she has just
tasted it, confirms, describes it as sweet, and generalizes to her
preference for sweet snacks. Her iced coffee sits beside the cake plate;
Narin's tea and ice cream are already in front of him, not yet the topic
of conversation. Mali holds a small fork by the cake plate or has just
taken a bite; Narin watches her reaction with warm, expectant curiosity,
no gesture toward her plate. Both seated as before at the same café table
as Dialog 4; Mali leans slightly forward, enjoying the taste. Narin
expectant and curious; Mali genuinely delighted. Warm, mildly enthusiastic
— an expansive, positive first reaction.

Composition: medium-wide, horizontal, full-body, feet and shoes visible,
optimized for a wide slideshow card, 3:2 aspect ratio (1536x1024 landscape).
Avoid extreme close-ups or movie-poster compositions.
```

Genereer op **landscape-formaat (1536x1024, 3:2)**.

Als de gezichten na generatie nog niet duidelijk Thai zijn: gebruik het correctieprotocol in `04_illustration_workflow_guide.md` (Stap 6a) in plaats van de prompt opnieuw vanaf nul te versturen.

## Na generatie

1. Visuele QA (identiteit, stijl, continuïteit — zie `04_illustration_workflow_guide.md` stap 6).
2. Afbeelding downloaden en hernoemen: `slide-00.png` (zero-padded, `slide_index = 0`).
3. Zetten in `illustration-staging/a1-dialog-05/slide-00.png`.
4. Uploaden via `scripts/upload-slides.mjs` (Stap 7-8) → pad `illustrations/dialogs/a1/dialog-05/slides/slide-00.png`, werkt `dialog_slides.image_url` bij voor `slide_index = 0`.
