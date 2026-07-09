# Illustration Prompt — a1_dialog_02 / Slide 3

## Samenstelling (ter controle, niet meesturen naar de generator)

- Master Style Prompt: `01_master_style_system.md`
- Cast-entries: `02_locked_cast_sheet.md` → `mali`, `narin`
- Scene Bible: `scene-bibles/a1_dialog_02_scene_bible.md`
- Slide Specification: `slide-specs/a1_dialog_02_slide_specs.md` → Slide 3

## Verplicht mee te sturen referentieafbeeldingen (niet optioneel)

1. `public/hero-image.png` — stijl-/paletreferentie
2. Face lock-referenties van Mali en Narin (front + 3/4 + profiel). Beiden zijn in dezelfde richting gekeerd om samen te vertrekken — driekwart is hier de belangrijkste hoek, stuur alle drie mee.
3. Goedgekeurde full-body cast-referentie-afbeeldingen van Mali en Narin — aanvullende referentie (dezelfde afbeeldingen als gebruikt voor de hero image)
4. Vorige goedgekeurde slide van deze dialoog: `slide-01.png` — continuïteitsreferentie (zelfde scène, net iets eerder in het gesprek).

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

The previous approved slide of this same dialogue is attached as a
continuity reference: keep the same location, lighting, and atmosphere as
that slide, only slightly later in the same conversation.

Characters in this scene:
- Mali: neat adult Thai woman, refined smart-casual appearance, calm and
  polished, soft neutral palette, elegant flats or minimal loafers.
- Narin: adult Thai man, main recurring character, calm, approachable,
  believable, friendly and socially confident.
Keep both characters' identity, hairstyle, and outfit logic locked — do not
redesign them.

Scene (this dialogue's own setting — do not reuse the hero image's living
room, furniture, or architecture, only its rendering philosophy): a quiet
everyday indoor setting (a simple, modern living room or a calm corner of a
café), daytime with soft natural light, minimal and softly detailed
environment, clean and uncluttered. Color palette: warm off-whites, muted
warm neutrals, soft sand tones, restrained saturation.

Moment: Mali confirms they will go together; Narin gives a simple,
agreeable closing response. Mali gestures toward the direction they will
walk, beginning to turn to go; Narin nods and falls in step beside her.
Both figures oriented in the same direction, relaxed synchronized posture
suggesting they are about to walk off together, comfortable, easy
proximity. Both smiling, content and at ease. Warm resolution — the
exchange closes on easy companionship as they set off together.

Composition: medium-wide, horizontal format, full-body figures from head to
toe, feet and shoes clearly visible, optimized for a wide slideshow card on
a language-learning lesson page. Avoid extreme close-ups or movie-poster
compositions.
```

## Na generatie

1. Visuele QA (identiteit, stijl, continuïteit met slide 2 — zie `04_illustration_workflow_guide.md` stap 6).
2. Afbeelding downloaden en hernoemen: `slide-02.png` (zero-padded, `slide_index = 2`).
3. Zetten in `illustration-staging/a1-dialog-02/slide-02.png`.
4. Uploaden via `scripts/upload-slides.mjs` (Stap 7-8) → pad `illustrations/dialogs/a1/dialog-02/slides/slide-02.png`, werkt `dialog_slides.image_url` bij voor `slide_index = 2`.
