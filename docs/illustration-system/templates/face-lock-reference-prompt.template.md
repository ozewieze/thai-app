# Face Lock Reference Prompt — [character_key]

> Gebruik dit template éénmalig per personage om de drie close-up
> gezichtsreferenties te genereren (zie `02_locked_cast_sheet.md` →
> Face Lock Referenties). Deze afbeeldingen worden daarna bij élke
> volgende generatie van dit personage meegestuurd.
>
> Genereer alle drie hoeken (front + 3/4 + profiel) bij voorkeur in dezelfde
> chat-sessie, direct na elkaar, zodat ze dezelfde gezichtsinterpretatie
> delen.
>
> **Waarom een profielhoek nodig is:** bij het testen van Dialog 1 bleek dat
> een scène met personages in bijna-profiel (twee mensen die elkaar aankijken)
> duidelijk afweek van de front/3-4 face lock-referenties — er was geen
> referentiehoek dicht genoeg bij de gegenereerde hoek. Omdat dialoogscènes
> per definitie vaak profiel-achtige hoeken bevatten (personages die naar
> elkaar toe gekeerd staan), is een profielreferentie geen randgeval maar een
> structurele behoefte voor dit project.

## Voorbereiding

- Personage: `[character_key]` — zie cast-entry in `02_locked_cast_sheet.md`
- Bestaande referentie (indien beschikbaar): eerdere full-body/hero-illustratie van dit personage, als losse stijlreferentie (niet als gezichtsanker — dat is precies wat hier ontbreekt)

## Prompt — Front-facing headshot

```
[Master Style Prompt — verbatim uit 01_master_style_system.md]

[Thai Identity Rules + Thai Facial Identity — Strict Requirements — verbatim
uit 01_master_style_system.md]

[Negative Prompt (Thai Identity) — verbatim uit 01_master_style_system.md]

Character: [cast-entry van character_key, verbatim uit 02_locked_cast_sheet.md]

Generate a close-up front-facing headshot portrait of this character only —
head and shoulders, facing directly forward, neutral expression, even and
clear lighting, plain neutral background (no scene, no environment). Same
illustration style, shading approach, and level of refinement as the rest of
the ThaiNook cast — not photorealistic, not 3D-rendered, not cartoonish.

This image will be used as the primary facial-identity reference for this
character in all future illustrations. Facial structure, eye shape, nose
bridge, mouth shape, jawline, and skin tone shown here must remain exactly
consistent in every future generation of this character.
```

## Prompt — Driekwart (3/4) headshot

```
[zelfde opbouw als hierboven, met als enige wijziging:]

Generate a close-up three-quarter-angle headshot portrait of this character
only — head and shoulders, head turned slightly to reveal the nose bridge
and jawline clearly, neutral expression, even and clear lighting, plain
neutral background (no scene, no environment). Same illustration style as
the front-facing reference generated for this character — attach that image
alongside this prompt so both headshots match exactly.
```

## Prompt — Profielportret

```
[zelfde opbouw als hierboven, met als enige wijziging:]

Generate a close-up full side-profile headshot portrait of this character
only — head and shoulders, head turned fully to the side (profile view,
facing left), neutral expression, even and clear lighting, plain neutral
background (no scene, no environment). Same illustration style as the
front-facing and three-quarter references generated for this character —
attach both images alongside this prompt so all three headshots match
exactly.
```

Kies consequent dezelfde kijkrichting (hier: naar links) voor alle personages, zodat de conventie uniform blijft. Start met één profielhoek; voeg pas een gespiegelde (naar rechts kijkende) versie toe als je in de praktijk vaststelt dat de andere richting apart nodig is.

## Na generatie

1. Visuele QA: is het gezicht duidelijk Thai? Toets tegen `01_master_style_system.md` → Thai Facial Identity — Strict Requirements en de Negative Prompt. Twijfel? Gebruik het correctieprotocol in `04_illustration_workflow_guide.md` (Stap 6a).
2. Komen front-, 3/4- en profielversie overeen (zelfde gezicht, zelfde stijl)?
3. Opslaan als: `docs/illustration-system/cast-references/[character_key]/face-lock.png`
