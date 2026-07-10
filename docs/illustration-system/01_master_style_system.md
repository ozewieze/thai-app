# Master Style System

Dit hoofdstuk bevat de onveranderlijke visuele filosofie van ThaiNook-illustraties. Deze regels gelden voor élke illustratie — hero images, lesillustraties, en elke slide in elke dialoogslideshow — zonder uitzondering en zonder versimpeling.

## Core Illustration Philosophy

Create illustrations for a premium adult Thai language-learning platform. The illustrations should support language acquisition, conversational context, and cultural immersion. Prioritize clarity of human interaction over visual spectacle.

The visual tone should feel:

- adult
- calm
- welcoming
- refined
- culturally authentic
- educational

Avoid:

- cartoon exaggeration
- visual clutter
- excessive drama
- tourist-style Thailand imagery
- child-oriented educational aesthetics

## Master Style Prompt

Gebruik deze prompt als basislaag in élke Illustration Prompt (zie `templates/illustration-prompt.template.md`):

```
Use the attached character illustration(s) as the primary reference(s) for identity,
facial structure, hairstyle, body proportions, outfit logic, footwear logic, muted
color balance, and recurring cast consistency.

Keep all recurring characters consistent across scenes as if they belong to one
unified illustrated cast.

Keep the exact same illustration style, maturity level, visual finish, shading
approach, proportions, and overall premium adult language-learning aesthetic as
the reference images.

Match the level of refinement exactly, especially in:
- facial treatment
- clothing structure
- silhouette clarity
- adult professional tone

Do not make the result:
- more cartoonish
- more playful
- more exaggerated
- more simplified
than the reference illustrations.
```

## Thai Identity Rules

All characters must clearly remain Thai in facial identity and overall appearance. Keep consistent:

- facial structure
- eye shape logic
- nose structure
- mouth shape
- skin tone logic
- cultural identity

Avoid:

- westernized facial treatment
- globally generic stock illustration faces
- culturally ambiguous facial treatment
- internationally neutralized character design

Characters should remain recognizably Thai rather than broadly Asian.

### Thai Facial Identity — Strict Requirements

**Toegevoegd na een mislukte testgeneratie** (zie `prompts/a1_dialog_01/`): de regels hierboven bleken in de praktijk niet sterk genoeg — de generator produceerde gezichten die te westers/generiek-Aziatisch aandeden. Deze subsectie is de aangescherpte, expliciete versie en moet **altijd samen met** de regels hierboven worden meegestuurd, nooit als vervanging.

```
All characters MUST clearly remain Thai in facial structure, eye shape, nose
shape, mouth shape, skin tone, and overall appearance.

Use consistent Thai facial features: soft facial features, almond-shaped eyes,
a natural (not high, not narrow) nose bridge, full but soft lips, and a warm,
light golden-olive skin tone.

AVOID western, Korean, Japanese, or generically "internationally neutral"
faces.

AVOID large round eyes, a narrow/high nose bridge, pale skin, double-eyelid
western-style eyes, or other non-Thai facial features.

Preserve the exact facial structure shown in the reference images.

If in doubt, choose the clearer Thai interpretation — never an internationally
generic face.
```

### Negative Prompt (Thai Identity)

Dit blok wordt **verbatim** meegestuurd in élke Illustration Prompt, als expliciete negative prompt naast de positieve instructies hierboven:

```
not western, not european, not korean, not japanese, not chinese, not
generically asian

no high nose bridge, no narrow nose, no pale skin, no large round eyes, no
western-style double eyelids

no 3D/photorealistic rendering, no cartoon style

no beauty-ideal/influencer-style face
```

## Identity Protection Rules

Character identity takes priority over scene embellishment. If there is any conflict between:

- maintaining identity
- adding scene detail

**altijd identiteit behouden.**

Do not allow:

- background complexity
- lighting
- camera choices
- pose changes

to weaken character recognition.

## Reference Image Usage Rules

Deze regels bestonden nog niet in het oorspronkelijke document, maar wel in een eerder prototype van de master prompt (gebruikt voor de hero image) en zijn hier toegevoegd omdat ze essentieel worden zodra meerdere referentiebeelden tegelijk worden meegestuurd (stijl + identiteit + continuïteit, zie `04_illustration_workflow_guide.md` stap 5).

```
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
image — they are not a template or default setting for other scenes. Every
scene's environment, location, and objects come exclusively from that
scene's own Scene Bible. If the Scene Bible describes a different setting
(for example a coffee shop, a market, an office, or a street), render that
setting fully and specifically — do not default back to the hero image's
living room or reuse any of its furniture or architecture. Only the
rendering philosophy (color grading, lighting softness, contrast,
saturation, as described above) carries over from the hero image; its
content never does.

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
```

**Waarom dit belangrijk is:** zonder deze clausule kan een image-generator per ongeluk de pose of scenecompositie van een bijgevoegde referentie (bv. de hero image) overnemen in plaats van alleen de stijl. Nu er standaard meerdere referentiebeelden per generatie worden meegestuurd (zie hieronder), moet voor de generator duidelijk zijn welke referentie welk doel dient. De face-lock referentie is toegevoegd omdat een close-up headshot de gezichtsstructuur veel sterker verankert dan een full-body scenebeeld, waar het gezicht maar een klein deel van de compositie inneemt.

**Les uit de praktijk (na kleurcorrectie van Dialog 1):** nadat de kleur-/lichtregels waren aangescherpt, bleef de generator toch de specifieke omgeving van de hero image (woonkamer, vensterboog, wandrek) hergebruiken voor andere scènes, ook wanneer de Scene Bible een andere locatie voorschreef (bv. een koffieshop voor Dialog 3). De oorspronkelijke zin "not... a composition reference" stond te kort en te laat in de prompt om voldoende gewicht te krijgen tegenover de veel uitgebreidere kleur-/lichtinstructies ervoor. Vandaar de expliciete, herhaalde regel hierboven: de omgeving komt altíjd uit de Scene Bible van de betreffende dialoog, nooit uit de hero image.

## Background Lock Rule (Multi-Slide Dialogues)

**Toegevoegd na een waarneming bij Dialog 3:** ook met de vorige slide als continuïteitsreferentie meegestuurd, tekende de generator de achtergrond bij elke volgende slide net iets anders — een lichte verschuiving in compositie/objectplaatsing en een lichte verandering in lichtinval, net zichtbaar genoeg bij naast-elkaar vergelijking. De bestaande continuïteitsformulering ("same location, lighting, furniture, and camera framing") bleek te zacht: de generator interpreteerde dit als "vergelijkbaar", niet als "pixelidentiek". Dit blok is de aangescherpte versie en moet **verbatim** worden meegestuurd in élke Illustration Prompt vanaf Slide 2 van een dialoog (d.w.z. zodra een vorige slide van dezelfde dialoog als continuïteitsreferentie wordt bijgevoegd) — nooit als vervanging van de Reference Image Usage Rules hierboven, maar als aanvulling erop.

```
This illustration is one slide in a multi-slide dialogue sequence. The
attached previous slide of the same dialogue is the background lock
reference: the background environment must remain pixel-consistent with
it — identical camera angle, identical framing, identical furniture
placement and scale, identical light source direction and intensity,
identical color grading and shadow pattern. Do not subtly redraw, shift,
resize, recompose, or relight the environment between slides. Treat the
background as a fixed, unchanging set, as if the same photograph of the
room or location were reused and only the characters were repositioned
and re-posed within it.

The only elements allowed to change between slides are: character pose,
gesture, gaze direction, facial expression, body orientation, and
conversational distance. Every other element in the frame — walls,
furniture, windows, light source, shadows, and color grading — must
match the previous slide exactly, not approximately.
```

Bijbehorende aanvulling op de Negative Prompt, verbatim mee te sturen naast de bestaande Negative Prompt (Thai Identity) zodra deze regel van toepassing is:

```
no background drift, no environment redraw between slides, no relighting
between slides, no camera or framing shift between slides
```

Voor Slide 1 van een dialoog (nog geen vorige slide om naar te verwijzen) is dit blok niet van toepassing — die slide legt zelf de vaste achtergrond vast waar alle volgende slides van dezelfde dialoog exact op moeten aansluiten.

## Adult Tone Rules

Maintain a clearly adult tone in:

- posture
- styling
- facial treatment
- outfit logic

Avoid:

- childlike simplification
- teen-coded styling
- exaggerated cuteness
- youthful caricature

unless explicitly requested.

## Full Body Rules

Show characters as full-body figures from head to toe unless otherwise specified. Ensure:

- full feet visible
- shoes visible
- no accidental cropping

Shoes should be treated as a meaningful part of character design.

## Background Style Rules

Scene background style:

> Clean, calm, modern environment illustration for an adult Thai language-learning platform.

The background should be:

- softly detailed
- slightly simplified
- never visually busy

Use:

- warm off-whites
- muted warm neutrals
- soft blue-grays
- sand tones
- restrained saturation

Include only enough environmental detail to establish context.

## Waarom dit een apart, vast document is

Deze regels veranderen zelden of nooit — ze zijn de "grondwet" van de visuele stijl. Ze worden letterlijk (niet samengevat) in elke Illustration Prompt meegenomen. Zie `04_illustration_workflow_guide.md` voor hoe dit document mechanisch wordt samengevoegd met de Cast Sheet, de Scene Bible en de Slide Specification tot één finale prompt.
