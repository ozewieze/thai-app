# Illustration Prompt — [dialog_key] / Slide [nn]

> Dit is de uiteindelijke, kant-en-klare prompt die je kopieert naar ChatGPT
> (of een andere image-generator). Dit bestand is **wegwerpbaar**: het is
> generatie-output, geen bron van waarheid (zie `05_storage_strategy.md`).
> De opbouw is mechanisch: Master Style + Cast Sheet + Scene Bible + Moment.
> Er wordt hier niets nieuws bedacht — alles is samengevoegd uit de drie
> voorgaande documenten/bestanden.

## Samenstelling (ter controle, niet meesturen naar de generator)

- Master Style Prompt: `01_master_style_system.md`
- Cast-entries: `02_locked_cast_sheet.md` → personages `[character_key, character_key]`
- Scene Bible: `scene-bibles/[dialog_key]_scene_bible.md`
- Slide Specification: `slide-specs/[dialog_key]_slide_specs.md` → Slide `[nn]`

## Verplicht mee te sturen referentieafbeeldingen (niet optioneel)

Tekst alleen garandeert geen exacte kleur-/toonmatch en bleek in de praktijk ook onvoldoende voor een betrouwbaar Thai gezicht — de generator verankert zich sterker op meegestuurde afbeeldingen dan op tekst. Voeg altijd toe:

1. `public/hero-image.png` — stijl-/paletreferentie (kleurtemperatuur, licht, rendering)
2. **Face lock**-referenties (front + 3/4 + profiel) van `[character_key, character_key]` — zie `02_locked_cast_sheet.md` → Face Lock Referenties — primaire gezichtsanker, verplicht zodra aangemaakt. **Kies minstens de hoek die het dichtst bij de pose in het Moment ligt** (front/3-4/profiel); stuur bij twijfel meerdere hoeken mee.
3. Goedgekeurde full-body/cast-referentie-afbeeldingen van `[character_key, character_key]` — aanvullende referentie voor hairstyle/outfit/silhouet (dezelfde afbeeldingen als gebruikt voor de hero image)
4. Vorige goedgekeurde slide van dezelfde dialoog, indien Slide `[nn]` > 1 — continuïteitsreferentie

Zie `01_master_style_system.md` → Reference Image Usage Rules voor hoe deze vier referentietypes uit elkaar gehouden worden in de generator (stijl vs. gezicht vs. identiteit vs. continuïteit). Genereer alle slides van dezelfde dialoog bij voorkeur in dezelfde chatsessie.

## Finale prompt

```
[Master Style Prompt — verbatim uit 01_master_style_system.md]

[Thai Identity Rules + Thai Facial Identity — Strict Requirements — verbatim]

[Negative Prompt (Thai Identity) — verbatim uit 01_master_style_system.md]

[Reference Image Usage Rules — verbatim uit 01_master_style_system.md; licht
"[Bijgevoegd: hero image als stijlreferentie; face lock-referentie(s)
(front/3-4/profiel — kies de hoek die het dichtst bij de pose in dit Moment
ligt) van character_key(s) als primaire gezichtsanker; full-body
cast-referenties als identiteitsreferentie; vorige slide als
continuïteitsreferentie indien van toepassing]" toe zodat de generator weet
welke bijlage welk doel dient]

[Relevante Locked Cast entries — verbatim, alleen de personages die in deze
slide voorkomen]

Scene (this dialogue's own setting — do not reuse the hero image's living
room, furniture, or architecture, only its rendering philosophy): [Location],
[Time of day], [Weather indien relevant], [Environment]. [Visual Density].
Color palette: [Color Palette].

Moment: [Narrative Moment]. [Interaction]. [Body Language]. [Facial
Expressions]. [Conversation Energy].

Composition: medium-wide, horizontal, full-body, feet and shoes visible,
optimized for a wide slideshow card, 3:2 aspect ratio (1536x1024 landscape).
Avoid extreme close-ups or movie-poster compositions.
```

Genereer op **landscape-formaat (1536x1024, 3:2)** — dit is de generator-instelling,
niet enkel tekst in de prompt. De site toont de afbeelding in een `.imageCard`
met `aspect-ratio: 3/2` (zie `LessonPageView.module.css`), dus deze twee
moeten in sync blijven: wijzigt de CSS-ratio ooit, werk dan ook hier de ratio
en het genoemde pixelformaat bij.

Als de gezichten na generatie nog niet duidelijk Thai zijn: gebruik het correctieprotocol in `04_illustration_workflow_guide.md` (Stap 6a) in plaats van de prompt opnieuw vanaf nul te versturen.

## Na generatie

1. Visuele QA: identiteit, stijl, continuïteit met vorige slide (zie checklist in `04_illustration_workflow_guide.md`).
2. Afbeelding downloaden en hernoemen: `[dialog-slug]-slide-[nn].png`
3. Uploaden naar Supabase Storage bucket `illustrations`.
4. `dialog_slides.image_url` bijwerken voor `slide_index = [nn]`.
