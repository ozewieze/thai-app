# Slide Specifications — a1_dialog_03

Bron: `dialog_blocks` van de dialoog gekoppeld aan `lesson_key = 'a1-dialog-03'` (6 blokken, `block_index` 0–5, uit `seed-data/dialogs/a1_dialog_03.seed.sql`). Er bestaan nog geen rijen in `dialog_slides` voor deze dialoog — deze specificatie is de basis om ze aan te maken (insert, geen update).

## Segmentatie-overzicht

| Slide | Blokken (`block_index`) | Gespreksmoment |
|---|---|---|
| 1 | 0–1 | Narin vraagt wat Mali wil drinken; zij antwoordt koffie |
| 2 | 2–3 | Narin vraagt of het warme of ijskoffie moet zijn; zij specificeert ijskoffie |
| 3 | 4–5 | Mali kaatst de vraag terug; Narin antwoordt thee (afsluiting) |

**Segmentatie-motivatie:** 3 slides voor een dialoog van 6 blokken, elke slide precies 2 blokken (één gespreksuitwisseling per slide), elke knip valt op een natuurlijke wisseling van gespreksmoment (openingsvraag/antwoord → verduidelijkingsvraag/antwoord → rolomkering/afsluiting), conform de heuristiek in `04_illustration_workflow_guide.md`. Alle drie slides delen dezelfde Scene Bible (café, zittend aan tafel) — geen visuele reden voor de knippen, alleen conversatiemomenten.

---

## Slide 1

### Herkomst
- `dialog_slides.slide_index`: `0`
- Blokken: `0`–`1`
- Tekst:
  - นริน: จะดื่มอะไรครับ — "Narin: What will you drink?"
  - มะลิ: กาแฟค่ะ — "Mali: Coffee."

### Moment in Dialogue

```
Dialogue Stage
Opening order question, just after sitting down together.

Narrative Moment
Now seated together at the café table, Narin asks Mali what she would
like to drink; she answers simply that she would like coffee.

Interaction
Narin turns toward Mali with a light, attentive question, perhaps a
small gesture toward her or the table; Mali answers easily, with a
small relaxed nod.

Body Language
Both seated upright and relaxed at the small café table, comfortable
conversational distance; Narin slightly turned toward Mali in an
attentive, hosting posture.

Facial Expressions
Narin friendly and mildly inquiring; Mali calm and pleasant.

Conversation Energy
Easy, polite opening — the natural first exchange right after sitting
down together.

Educational Focus
The learner sees the question pattern จะดื่มอะไร ("what will you drink")
immediately followed by the simple one-word answer กาแฟ ("coffee").
```

---

## Slide 2

### Herkomst
- `dialog_slides.slide_index`: `1`
- Blokken: `2`–`3`
- Tekst:
  - นริน: กาแฟร้อนหรือกาแฟเย็นครับ — "Narin: Hot coffee or iced coffee?"
  - มะลิ: กาแฟเย็นค่ะ — "Mali: Iced coffee."

### Moment in Dialogue

```
Dialogue Stage
Follow-up clarifying question about coffee type.

Narrative Moment
Narin follows up by asking whether Mali wants her coffee hot or iced;
she specifies iced coffee.

Interaction
Narin tilts his head slightly, perhaps a small either/or hand gesture
suggesting two options; Mali answers promptly and decisively, with a
small confirming gesture of her own.

Body Language
Same seated postures as Slide 1, continuing moments later; Narin
leaning in slightly with genuine attentiveness, Mali relaxed and clear
as she states her preference.

Facial Expressions
Narin curious and helpful; Mali certain, with a small pleasant smile.

Conversation Energy
Light continuation, the natural back-and-forth of ordering — still
calm and polite.

Educational Focus
The learner sees the either/or question pattern ร้อนหรือเย็น ("hot or
iced") paired immediately with the specific answer กาแฟเย็น ("iced
coffee").
```

---

## Slide 3

### Herkomst
- `dialog_slides.slide_index`: `2`
- Blokken: `4`–`5`
- Tekst:
  - มะลิ: คุณจะดื่มอะไรคะ — "Mali: What will you drink?"
  - นริน: ชาครับ — "Narin: Tea."

### Moment in Dialogue

```
Dialogue Stage
Role-reversal question and closing answer.

Narrative Moment
Mali turns the same question back to Narin, asking what he will
drink; he answers simply that he wants tea.

Interaction
Mali turns her attention to Narin with a small warm gesture, mirroring
the question he asked her earlier; Narin answers simply and easily.

Body Language
Mali now leaning slightly toward Narin, echoing his earlier attentive
posture; Narin relaxed and open as he gives his simple answer.

Facial Expressions
Mali curious and warm; Narin calm, content, with an easy smile.

Conversation Energy
Warm closing symmetry — the same question returned and answered
simply, completing the small ordering ritual with mutual ease.

Educational Focus
The learner sees the mirrored question pattern คุณจะดื่มอะไร ("what will
you drink", now addressed to "you") answered with a simple one-word
noun ชา ("tea"), reinforcing the pattern already introduced in Slide 1.
```
