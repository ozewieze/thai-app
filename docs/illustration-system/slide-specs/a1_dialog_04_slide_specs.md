# Slide Specifications — a1_dialog_04

Bron: `dialog_blocks` van de dialoog gekoppeld aan `lesson_key = 'a1-dialog-04'` (7 blokken, `block_index` 0–6, uit `seed-data/dialogs/a1_dialog_04.seed.sql`). Er bestaan nog geen rijen in `dialog_slides` voor deze dialoog — deze specificatie is de basis om ze aan te maken (insert, geen update).

## Segmentatie-overzicht

| Slide | Blokken (`block_index`) | Gespreksmoment |
|---|---|---|
| 1 | 0–1 | Narin biedt een snack aan; Mali stemt toe |
| 2 | 2–3 | Narin vraagt welke snack; Mali kiest cake |
| 3 | 4–6 | Mali kaatst de vraag terug (ook cake?); Narin wijst af en kiest ijs (afsluiting) |

**Segmentatie-motivatie:** 3 slides voor een dialoog van 7 blokken, elke knip valt op een natuurlijke wisseling van gespreksfunctie (aanbod → acceptatie, vraag → specifiek antwoord, tegenvraag → contrasterend antwoord), conform de heuristiek in `04_illustration_workflow_guide.md`. Blokken 5–6 horen bij slide 3 omdat het één doorlopende beurt van Narin is ("ik neem geen cake, ik neem ijs" — één contrasterende gedachte, geen twee losse momenten). Alle drie slides delen dezelfde Scene Bible (café, zelfde tafel als Dialog 3) — geen visuele reden voor de knippen, alleen conversatiemomenten.

**Continuïteitsnotitie:** dit is de rechtstreekse voortzetting van Dialog 3 (drankjes bestellen) — er is op dit punt nog niets fysiek geserveerd of aanwezig op tafel. Geen menu, geen zichtbare cake of ijs in geen van de drie slides; alle gebaren zijn puur interpersoonlijk (houding, handen, blik), nooit gericht op een object. De lichaamstaal is bewust anders gekozen dan in `a1_dialog_03_slide_specs.md` (geen head-tilt/either-or-gebaar, geen mirroring-leun, geen simpele nod) om visuele herhaling tussen de twee dialogen te vermijden.

---

## Slide 1

### Herkomst
- `dialog_slides.slide_index`: `0`
- Blokken: `0`–`1`
- Tekst:
  - นริน: เอาขนมไหมครับ — "Narin: Would you like a snack?"
  - มะลิ: เอาค่ะ — "Mali: Yes, I will."

### Moment in Dialogue

```
Dialogue Stage
Opening offer, transitioning from drinks to snacks.

Narrative Moment
Nothing has been ordered or served yet — this is purely a spoken offer.
Narin asks Mali if she'd like a snack; she accepts warmly.

Interaction
Narin sits back a little and raises his eyebrows in a light, inviting
way, palms resting open on the table rather than pointing at anything;
Mali responds with a quick, pleased smile and a small settling shift
in her seat.

Body Language
Both still seated as before; Narin's posture opens up slightly
(shoulders relaxed, hands open) rather than leaning in.

Facial Expressions
Narin warm and inviting; Mali brightening, pleasantly surprised by
the offer.

Conversation Energy
Warm, easy continuation — a natural, unforced transition to snacks.

Educational Focus
The learner sees the offer pattern เอา...ไหม ("would you like...")
paired immediately with the simple acceptance เอา ("yes, I will").
```

---

## Slide 2

### Herkomst
- `dialog_slides.slide_index`: `1`
- Blokken: `2`–`3`
- Tekst:
  - นริน: เอาขนมอะไรครับ — "Narin: What snack would you like?"
  - มะลิ: เอาเค้กค่ะ — "Mali: I'll have cake."

### Moment in Dialogue

```
Dialogue Stage
Follow-up clarifying question about which snack.

Narrative Moment
Still nothing on the table — Narin asks which snack Mali wants; she
names cake without hesitation. The choice exists only in the
conversation, not yet in front of them.

Interaction
Narin's expression turns curious, one hand lightly spread in a
"go ahead, tell me" gesture; Mali answers with a small spontaneous
brightness — perhaps her hands coming together briefly at the thought
of cake, rather than pointing at anything.

Body Language
Same seated positions as Slide 1, moments later; Mali sits slightly
more forward with anticipation rather than mirroring Narin's earlier
posture.

Facial Expressions
Narin curious and attentive; Mali delighted and certain.

Conversation Energy
Light and decisive — the natural specificity beat of ordering.

Educational Focus
The learner sees the pattern เอาขนมอะไร ("what snack would you like")
answered with the concrete noun เค้ก ("cake").
```

---

## Slide 3

### Herkomst
- `dialog_slides.slide_index`: `2`
- Blokken: `4`–`6`
- Tekst:
  - มะลิ: เอาเค้กด้วยไหมคะ — "Mali: Will you have cake too?"
  - นริน: ไม่เอาเค้กครับ — "Narin: I won't have cake."
  - นริน: เอาไอศกรีมครับ — "Narin: I'll have ice cream."

### Moment in Dialogue

```
Dialogue Stage
Role-reversal question and contrastive closing answer.

Narrative Moment
Mali turns the question back, asking if Narin will also have cake;
he declines and names his own choice, ice cream — again, purely
conversational, nothing physically in front of them yet.

Interaction
Mali tilts her chin up slightly with playful curiosity, hands
resting loosely on the table (not gesturing toward Narin); Narin
gives a small good-humored headshake with a half-smile, then taps
his own chest lightly as he states his alternative choice — a
"for me" gesture rather than pointing at food.

Body Language
Mali sits back a touch, at ease and teasing; Narin relaxed, amused,
unbothered by disagreeing with her choice.

Facial Expressions
Mali playful and curious; Narin good-humored — the decline reads as
personal taste, not discomfort.

Conversation Energy
Warm closing contrast — a mirrored question answered with a friendly
difference, closing the snack exchange.

Educational Focus
The learner sees the negation pattern ไม่เอา ("I won't have") directly
followed by the alternative choice เอาไอศกรีม ("I'll have ice cream").
```
