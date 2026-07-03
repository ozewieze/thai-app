# Full-body Cast Reference Prompt — [character_key]

> Dit is het "Master Prompt voor elke figuur"-sjabloon, letterlijk zoals
> aangeleverd, nu vastgelegd als herbruikbaar template. Uitsluitend bedoeld
> voor het aanmaken van een **nieuw** personage — een enkele figuur, volledig
> zichtbaar, op een neutrale effen achtergrond. Deze afbeelding dient later
> als reference type #3 in elke Illustration Prompt (zie
> `04_illustration_workflow_guide.md` stap 5), náást de face lock-referentie
> (close-up, zie `face-lock-reference-prompt.template.md`).
>
> **Alleen de uiteindelijke afbeelding wordt bewaard, niet de ingevulde
> prompt.** In de praktijk vergt een personage vaak meerdere iteraties/
> correcties voordat het resultaat klopt — een enkel "de prompt"-bestand zou
> dat proces niet correct weergeven. Zie `02_locked_cast_sheet.md` → Full-body
> Cast Referenties voor de motivatie.

## Prompt

```
Use the attached character illustration(s) as the primary reference(s) for
identity, facial structure, hairstyle, body proportions, outfit logic,
footwear logic, muted color balance, and recurring cast consistency.

Keep all recurring characters consistent across scenes as if they belong to
one unified illustrated cast.

Keep the exact same illustration style, maturity level, visual finish,
shading approach, proportions, and overall premium adult language-learning
aesthetic as the reference images. Match the level of refinement exactly,
especially in the facial treatment, clothing structure, silhouette clarity,
and adult professional tone. Do not make the result more cartoonish, more
playful, more exaggerated, or more simplified than the references.

All characters must clearly remain Thai in facial identity and overall
appearance. Keep consistent Thai facial structure, hairstyle logic, skin
tone logic, and cultural identity matching their reference illustrations.
Avoid westernized facial treatment, globally generic stock-illustration
features, or ambiguous internationalized character design. The faces should
remain stylized and refined, but recognizably Thai rather than globally
neutral.

Maintain a clearly adult tone in posture, styling, facial treatment, and
outfit logic. Avoid childlike simplification, teen-coded fashion logic,
exaggerated cuteness, or overly youthful proportions unless explicitly
specified for that character.

Show the character as a full-body figure from head to toe unless otherwise
specified. Make sure the full feet and entire shoes are clearly visible and
not cropped off. Shoes must be treated as an intentional part of the
character design and should match the character's age, role, outfit logic,
and personality.

Use the attached references carefully and selectively. Preserve identity,
style, and design logic where intended, but do not accidentally copy pose,
scene composition, or clothing details unless explicitly requested. When a
reference is used only for style, treat it strictly as a style reference and
not as a character identity reference.

Ensure the character remains visually distinct from other recurring
characters in the same series through a clear combination of age impression,
hairstyle logic, outfit structure, footwear choice, silhouette, and overall
social or professional energy.

[Insert character-specific description here — gebruik de cast-entry van
character_key, verbatim uit 02_locked_cast_sheet.md]

[Insert scene-specific description here — voor een full-body cast-referentie:
plain neutral off-white studio background, no props, no environment, standing
pose, front-facing, arms relaxed, neutral/friendly expression]

Scene background style: clean, calm, modern environment illustration for an
adult Thai language learning platform. The background should be softly
detailed, slightly simplified, and never visually busy. Use a warm
off-white atmosphere, muted warm tones, soft blue-gray and sand support
colors, and limited saturation. Include only a few clear environmental
elements that establish the setting without distracting from the characters.
```

> **Let op — nog niet aangevuld met de latere Thai Facial Identity —
> Strict Requirements en het Negative Prompt-blok** (toegevoegd in
> `01_master_style_system.md` na de mislukte dialoogslide-test). Voor een
> nieuwe full-body referentie is het aan te raden die twee blokken hier ook
> aan toe te voegen, ook al werkten de bestaande Narin/Mali-referenties
> zonder die aanscherping goed genoeg.

## Na generatie

1. Personage-specifieke beschrijving en scene-specifieke beschrijving invullen, prompt uitvoeren (evt. meerdere correctierondes, zie Stap 6a-stijl correctietaal in `04_illustration_workflow_guide.md`).
2. Alleen het eindresultaat opslaan als `docs/illustration-system/cast-references/[character_key]/full-body.png` — de ingevulde/gecorrigeerde prompt zelf wordt niet bewaard.
3. Statusoverzicht in `02_locked_cast_sheet.md` bijwerken.
