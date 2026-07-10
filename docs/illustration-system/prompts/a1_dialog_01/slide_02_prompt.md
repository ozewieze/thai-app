# Illustration Prompt — a1_dialog_01 / Slide 2

## Samenstelling (ter controle, niet meesturen naar de generator)

- Master Style Prompt: `01_master_style_system.md`
- Cast-entries: `02_locked_cast_sheet.md` → `mali`, `narin`
- Scene Bible: `scene-bibles/a1_dialog_01_scene_bible.md`
- Slide Specification: `slide-specs/a1_dialog_01_slide_specs.md` → Slide 2

## Verplicht mee te sturen referentieafbeeldingen (niet optioneel)

1. `public/hero-image.png` — stijl-/paletreferentie
2. Face lock-referenties van Mali en Narin. Zelfde camerahoek als Slide 1, dus profiel blijft de belangrijkste van de drie hoeken.
3. Goedgekeurde full-body cast-referentie-afbeeldingen van Mali en Narin — aanvullende referentie (dezelfde afbeeldingen als gebruikt voor de hero image)
4. De goedgekeurde afbeelding van Slide 1 — continuïteitsreferentie (zelfde scène, licht en sfeer)

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
composition, or clothing details unless explicitly requested. The attached hero
image is the master style reference: match not only illustration style and
color palette but also lighting treatment, contrast level, shadow softness,
saturation, and atmospheric rendering — restrained contrast, soft shadow
transitions, muted premium color palette, gentle tonal compression, subtle
atmospheric softness. Avoid dramatic lighting, harsh shadow edges, strong cast
shadows, overly vivid colors, or high-contrast rendering. It is a style/palette
reference only, not a pose or composition reference — its living room, window,
shelving, furniture, and decorative objects must never be reused; this
dialogue's environment comes only from the Scene description below and from
the attached Slide 1 image (for continuity within this dialogue), never from
the hero image. The attached Mali and Narin face lock
references (front, 3/4, and profile) are the primary source for exact facial
structure — prioritize the profile reference, since this scene keeps the same
near-profile camera angle as Slide 1. The full-body Mali and Narin reference
images are identity references for hairstyle, proportions, and outfit logic
only. The attached Slide 1 image is a
continuity reference for scene, lighting, and mood only — poses and
expressions in this slide must follow the Moment described below, not the
poses shown in Slide 1.

Characters in this scene:
- Mali: neat adult Thai woman, refined smart-casual appearance, calm and
  polished, soft neutral palette, elegant flats or minimal loafers.
- Narin: adult Thai man, main recurring character, calm, approachable,
  believable, friendly and socially confident.
Keep both characters' identity, hairstyle, and outfit logic locked — do not
redesign them.

Scene (this dialogue's own setting, continued from Slide 1 — never the hero
image's living room): the same quiet everyday indoor setting as the previous
slide (a simple, modern living room or a calm corner of a café), daytime with soft
natural light, minimal furniture, softly detailed. A richer selection of
Thai decorative touches is welcome — for example patterned cushions or
textile details, warm teak or rattan wood tones, a small tabletop fountain,
framed Thai-style artwork or botanical prints, or decorative Thai ceramics
— as long as it reads as a considered, contemporary interior rather than a
cluttered souvenir shop. Avoid literal shop signage, tourist-market
clichés, religious imagery (e.g. Buddha statues, spirit houses, or
altars), or visual clutter that would date or over-localize the scene.
Clean and uncluttered overall. Same color palette: warm off-whites, muted
warm neutrals, soft sand tones, restrained saturation. Do
not change camera angle, environment, mood, or lighting from the previous
slide — treat this moment as occurring only seconds after slide 1.

Moment: Mali states her own name and then asks Narin for his name. Mali
gestures gently toward herself while introducing her name, then tilts her
head slightly in question toward Narin. Mali is relaxed and attentive;
Narin is listening with polite, engaged attention. Mali's expression is
friendly and slightly curious; Narin's is attentive and open. Conversation
energy continues calm, becoming slightly more personal than the opening
greeting.

Composition: medium-wide, horizontal format, full-body figures from head to
toe, feet and shoes clearly visible, optimized for a wide slideshow card on
a language-learning lesson page. Avoid extreme close-ups or movie-poster
compositions.
```

## Na generatie

1. Visuele QA (identiteit, stijl, continuïteit met Slide 1 — zie `04_illustration_workflow_guide.md` stap 6).
2. Afbeelding downloaden en hernoemen: `greetings-and-introductions-slide-02.png`
3. Uploaden naar Supabase Storage bucket `illustrations`, pad `illustrations/dialogs/a1/greetings-and-introductions/slides/slide-02.png`.
4. `dialog_slides.image_url` bijwerken voor `slide_index = 1`.
