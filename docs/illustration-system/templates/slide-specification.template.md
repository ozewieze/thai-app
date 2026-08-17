# Slide Specifications — [dialog_key, bv. a1_dialog_XX]

> Invulinstructie: één sectie per slide. Het aantal slides hangt af van de
> inhoud van de dialoog (zie segmentatieheuristiek in
> `04_illustration_workflow_guide.md`) — geen vast aantal.
> Velden gemarkeerd **(DB)** komen uit `dialog_slides` / `dialog_blocks`.
> Velden gemarkeerd **(nieuw)** zijn de illustratiebrief en bestaan nog niet
> als kolom in de database.

## Segmentatie-overzicht

| Slide | Blokken (DB: `dialog_blocks.block_index`)  | Gespreksmoment         |
| ----- | ------------------------------------------ | ---------------------- |
| 1     | `[first_block_index]`–`[last_block_index]` | `[korte omschrijving]` |
| 2     | `[first_block_index]`–`[last_block_index]` | `[korte omschrijving]` |
| ...   |                                            |                        |

**(DB)**: `slide_index`, `first_block_index`, `last_block_index` corresponderen 1-op-1 met rijen in `dialog_slides`.

---

## Slide [nn]

### Herkomst

- `dialog_slides.slide_index`: `[nn]` **(DB)**
- Blokken: `[first_block_index]`–`[last_block_index]` **(DB)**
- Thaise tekst van deze blokken: `[plak hier de exacte thai_text/translation_en regels]` **(DB: `dialog_blocks`)**

### Moment in Dialogue

```
Dialogue Stage
[Insert stage]

Narrative Moment
[Describe what is happening right now]

Interaction
[Describe the interaction]

Body Language
[Describe body language]

Facial Expressions
[Describe expressions]

Conversation Energy
[Describe emotional progression]

Educational Focus
What should the learner immediately understand from this image?
[Insert answer]
```

_(alle velden in dit blok zijn **(nieuw)** — de illustratiebrief; kandidaat voor een toekomstige `dialog_slides.illustration_brief jsonb`-kolom, zie `05_storage_strategy.md`)_

---

_Herhaal de "Slide [nn]"-sectie voor elke slide van deze dialoog._
