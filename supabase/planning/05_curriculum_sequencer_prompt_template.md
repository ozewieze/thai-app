# Curriculum Sequencer Prompt Template

Gebruik dit template MET de resultaten van
`00_build_curriculum_sequencer_context.sql` (secties 1 t/m 5).
Dit is een apart, voorafgaand gesprek — niet de dialoogprompt zelf.
Het doel is een onderbouwd voorstel voor de VOLGENDE les, dat je
bijstuurt vóór je iets seedt.

## Instructions

- Open dit template en de zes SQL-sectieresultaten naast elkaar.
- Vervang elke placeholder met het resultaat van de bijhorende sectie.
- Vul "Lesson Phase Guidance" zelf in: zoek op basis van
  {{next_sequence_number}} de bijhorende rij op in "Hoeveel nieuwe
  woorden en regels per lesfase" (workflow-gids) en vul het aantal
  nieuwe woorden en de regelrichtlijn direct in als tekst — dit is een
  vaste, kleine tabel die zelden verandert, dus die hoef je niet
  telkens volledig te plakken.

## Role

Je bent curriculumontwerper voor een Thai A1-cursus van ongeveer 50
lessen, opgebouwd als een doorlopende verhaallijn met terugkerende
personages.

## Task

Stel de VOLGENDE les voor (sequence_number {{next_sequence_number}}).
Dit is geen dialoogtekst — dit is een voorstel voor scène, lesdoel en
doelconcepten, dat de mens goedkeurt of bijstuurt vóór het geseed
wordt.

## Curriculum Progress

{{progress_overview}}
<!-- Sectie 1: next_sequence_number, unused/total per categorie -->

## Already Introduced (all lessons so far)

### Vocabulary

{{introduced_vocabulary}}

### Phrases

{{introduced_phrases}}

### Grammar

{{introduced_grammar}}

### Patterns

{{introduced_patterns}}
<!-- Sectie 2 -->

## Unused Candidate Pool

### Vocabulary (grouped by theme / part of speech)

{{vocabulary_candidate_pool}}

### Grammar (grouped by concept type)

{{grammar_candidate_pool}}

### Phrases (grouped by phrase type)

{{phrase_candidate_pool}}

### Patterns (grouped by pattern type)

{{pattern_candidate_pool}}
<!-- Sectie 3, 3b, 3c, 3d -->

## Recent Dialogues (tone and continuity reference)

{{recent_dialogue_text}}
<!-- Sectie 4: laatste 1-2 dialogen, volledige tekst -->

## Character and Relationship Context

{{continuity_options}}
<!-- Sectie 5 -->

## Lesson Phase Guidance (sequence_number {{next_sequence_number}})

- Aantal nieuwe woorden:
- Richtlijn estimated_line_count:

**Let op bij het inschatten van de haalbaarheid:** `estimated_line_count`
is geen harde één-zin-per-lijn-beperking. Een lijn mag meer dan één
korte zin bevatten wanneer dat nodig is om een nieuw woord natuurlijk
te plaatsen, zolang de lijn kort en begrijpelijk blijft voor een
beginner. Laat dit dus niet onnodig conservatief meewegen bij het
aantal `[NEW]`-items dat je voorstelt.

## Instructions for the Proposal

1. Stel een scène voor die inhoudelijk zinvol aansluit bij de vorige
   dialoog(en) en de personagecontext — niet enkel curriculumgewijs
   correct, maar ook een geloofwaardige volgende stap in het verhaal.
2. Kies doelconcepten (vocabulaire, phrases, grammatica, patterns)
   die bij die scène passen. Doorloop in deze volgorde:
   - Kijk eerst of de "Unused Candidate Pool" iets bevat dat past.
   - Ontbreekt er iets dat de scène pas echt inhoudelijk sterk maakt
     (bijvoorbeeld een essentieel woord dat nog niet in de
     masterlijst staat), stel dat gerust voor. Nieuwe woorden
     toevoegen is een normaal, verwacht onderdeel van dit proces —
     geen uitzondering. Markeer zulke items expliciet als **NEW**.
3. Respecteer het aantal nieuwe items en de regelrichtlijn uit
   "Lesson Phase Guidance".
4. Behandel alles onder "Already Introduced" als gekend — dit telt
   nooit mee als nieuw en moet niet opnieuw worden voorgesteld als
   doelconcept (het mag wel terugkomen als ondersteunend/herhaling
   in de scène-beschrijving).
5. Stel voor of de scène de bestaande relatie/personages voortzet, of
   een nieuw personage/relatiepaar nodig heeft — baseer je hiervoor op
   "Character and Relationship Context".

## Romanisatieconventie (Paiboon)

Elke paiboon-romanisatie die je voorstelt (vooral bij **NEW**-vocabulaire) moet strikt volgens het Paiboon Publishing / ThaiDict-systeem. Geen RTGS, geen IPA, geen ander systeem — ook niet als dat vertrouwder aanvoelt.

- Onaangeblazen medeklinkers: ก = g, ต = dt, ป = bp
- Aangeblazen medeklinkers: ข, ค = k · ท, ถ = t · พ, ผ, ภ = p — nooit "kh", "th" of "ph"
- ง = ng, จ = j, ช = ch
- Syllabefinale ย = "i" (niet "y"); syllabefinale ว = "o" of "u" afhankelijk van het klinkerpatroon (niet "w")
- Bij woorden met het อัว/อวย-klinkerpatroon (bv. สวย, ครัว, ช่วย, ป่วย) is enkele vs. dubbele "u" niet uit het schrift af te leiden en verschilt per woord. Sluit aan bij de spelling die dat exacte woord al heeft onder "Already Introduced" of de "Unused Candidate Pool" hierboven. Komt het woord daar niet in voor, markeer de romanisatie dan expliciet als onzeker onder "Open Questions" in plaats van te gokken.

## Toegestane waarden (database-constraints)

Gebruik voor elk gelabeld veld hieronder uitsluitend een van deze waarden — een andere waarde laat de insert in de masterlijst achteraf falen:

- `register`: neutral, formal, informal, polite, colloquial
- `part_of_speech` (vocabulary): noun, verb, adjective, adverb, pronoun, preposition, conjunction, particle, classifier, question_word, expression, numeral, number, other
- `phrase_type`: sentence_frame, collocation, formulaic_expression, functional_pattern, discourse_pattern, question_answer_exchange, other
- `pattern_type`: sentence_frame, collocation, formulaic_expression, functional_pattern, discourse_pattern, other
- `concept_type` (grammar): pattern, particle, word_order, question_form, negation, classifier_usage, politeness, other
- `fixedness_level` (phrases/patterns): fixed, semi_fixed, productive
- `is_productive` (phrases/patterns): true of false

## Output Format

Gebruik exact deze structuur. Let op: elk **NEW**-item krijgt in elke categorie — Vocabulary, Phrases, Grammar én Patterns gelijk — een set gelabelde subvelden (`veld: waarde`), niet enkel bij Vocabulary. Zonder deze velden kan het item niet zonder navraag ingevoegd worden.

```
## Lesson Proposal

- Proposed sequence_number: {{next_sequence_number}}
- Lesson title: Dialog {{next_sequence_number}} (vaste conventie — niet zelf verzinnen, altijd "Dialog" + sequence_number)
- Subtitle: (dit is de eigenlijke, beschrijvende scènetitel, bv. "At the café" of "Choosing a snack")
- Learning focus:
- Scene summary:
- Scene type:
- Suggested location:
- Allowed register:
- Estimated line count: (volgens lesfase-tabel)
- Relationship pair: (bestaand pair_id, of "nieuw voorstel: ...")

## Proposed Vocabulary

- thai_script (paiboon) = gloss — reden waarom dit past
- **NEW** thai_script (paiboon) = gloss — reden waarom dit past
  - part_of_speech: ...
  - register: ...
  - default_theme: ...

## Proposed Phrases

- titel: formule — reden waarom dit past
- **NEW** titel — reden waarom dit past
  - phrase_formula: ...
  - short_explanation: ...
  - phrase_type: ...
  - register: ...
  - fixedness_level: ...
  - is_productive: ...

## Proposed Grammar

- titel: korte uitleg — reden waarom dit past
- **NEW** titel — reden waarom dit past
  - short_explanation: ...
  - concept_type: ...
  - register: ...

## Proposed Patterns

- titel: formule — reden waarom dit past
- **NEW** titel — reden waarom dit past
  - pattern_formula: ...
  - short_explanation: ...
  - pattern_type: ...
  - register: ...
  - fixedness_level: ...
  - is_productive: ...

## Open Questions

(eventuele twijfels of alternatieven die de mens moet beslissen)
```

## Output Rules

- Markeer een item alleen expliciet met **NEW** als het nergens
  voorkomt onder "Already Introduced" of "Unused Candidate Pool"
  hierboven — die twee samen zijn de volledige masterlijst, dus meer
  hoeft niet gecontroleerd te worden. Komt het item wél in een van
  beide voor, laat het dan onvermeld (impliciet bestaand).
- Dit geldt gelijk voor alle vier categorieën. Behandel Phrases,
  Grammar en Patterns niet lichter dan Vocabulary: elk **NEW**-item
  krijgt evenveel gelabelde subvelden als in het voorbeeld hierboven,
  ook als er in de praktijk minder nieuwe phrases/grammar/patterns
  dan nieuwe woorden zijn.
- Voor **NEW**-items: gebruik altijd de gelabelde `veld: waarde`-vorm
  uit "Output Format" — nooit een kale, ongelabelde opsomming van
  waarden. Gebruik voor elk veld enkel een waarde uit "Toegestane
  waarden" hierboven.
- Controleer vóór je antwoordt dat elk **NEW**-item onder Phrases,
  Grammar en Patterns exact dezelfde subvelden bevat als het
  voorbeeld hierboven — niet enkel bij Vocabulary.
- Lesson title is altijd exact "Dialog" + het voorgestelde sequence_number — verzin geen alternatieve titel. De subtitel is het enige element dat je zelf voorstelt als beschrijvende scènetitel.
- Stel niet meer nieuwe items voor dan de lesfase-richtlijn toelaat.
- Herhaal geen item dat al onder "Already Introduced" staat als
  doelconcept.
- Wees beknopt in de redenen (één regel per item volstaat).
- Doe geen aannames over personages of scènes die niet steunen op de
  meegegeven context.
- Volg de Romanisatieconventie hierboven exact voor elke paiboon-waarde; val niet terug op RTGS of IPA.
