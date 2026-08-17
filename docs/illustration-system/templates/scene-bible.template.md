# Scene Bible — [dialog_key, bv. a1_dialog_XX]

> Invulinstructie: dit template levert precies één Scene Bible per dialoog op.
> Velden gemarkeerd **(DB)** komen rechtstreeks uit `dialog_blueprint_specs` of
> `dialogs` — kopieer die waarde, verzin niets nieuws. Velden gemarkeerd
> **(nieuw)** bestaan nog niet in de database en zijn een illustratie-specifieke
> creatieve invulling — deze heb jij goed te keuren.

## Herkomst

- Lesson key: `[a1-dialog-XX]` **(DB: `lessons.lesson_key`)**
- Titel/subtitel: `[Dialog X]` / `[short text]` **(DB: `dialogs.title`/`dialogs.subtitle`)**
- Personages in deze dialoog: `[character_key, character_key]` \*_(DB: afgeleid van `dialog_blocks.speaker_key` / `dialogs`)_

## Scene Bible

```
Location
[Insert location]                       (DB: dialog_blueprint_specs.suggested_location)

Time of day
[Insert time]                            (nieuw)

Weather
[Insert weather]                         (nieuw)

Environment
[Insert environmental details]           (nieuw, mag dialog_blueprint_specs.scene_type verfijnen)

Mood
[Insert mood]                            (nieuw, mag dialogs.scene_summary verfijnen)

Visual Density
Clean and uncluttered unless specified otherwise.

Color Palette
[Insert palette if relevant]             (nieuw)
```

## Register & continuïteit

- Register: `[formal_polite / informal / ...]` **(DB: `dialog_blueprint_specs.allowed_register`)**
- Relevante `relationship_pair_rules` om in gedachten te houden bij houding/afstand tussen personages: `[opsomming]` **(DB)**

## Continuïteitsnotitie

Deze Scene Bible geldt voor **alle** slides van deze dialoog. Zie `03_scene_and_continuity_rules.md` — locatie, belichting, weer en sfeer veranderen nooit tussen slides van dezelfde dialoog.
