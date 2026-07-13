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

## Output Format

Gebruik exact deze structuur:

```
## Lesson Proposal

- Proposed sequence_number: {{next_sequence_number}}
- Lesson title:
- Subtitle:
- Learning focus:
- Scene summary:
- Scene type:
- Suggested location:
- Allowed register:
- Estimated line count: (volgens lesfase-tabel)
- Relationship pair: (bestaand pair_id, of "nieuw voorstel: ...")

## Proposed Vocabulary

- thai_script (paiboon) = gloss — reden waarom dit past
- **NEW** thai_script (paiboon) = gloss — part_of_speech, register, default_theme — reden

## Proposed Phrases

- titel: formule — reden
- **NEW** titel: formule — reden

## Proposed Grammar

- titel: korte uitleg — reden
- **NEW** titel: korte uitleg — reden

## Proposed Patterns

- titel: formule — reden
- **NEW** titel: formule — reden

## Open Questions

(eventuele twijfels of alternatieven die de mens moet beslissen)
```

## Output Rules

- Markeer een item alleen expliciet met **NEW** als het nergens
  voorkomt onder "Already Introduced" of "Unused Candidate Pool"
  hierboven — die twee samen zijn de volledige masterlijst, dus meer
  hoeft niet gecontroleerd te worden. Komt het item wél in een van
  beide voor, laat het dan onvermeld (impliciet bestaand).
- Voor **NEW**-items: geef exact de velden uit het voorbeeldformaat
  hierboven onder "Output Format" (bijvoorbeeld part_of_speech,
  register, default_theme voor vocabulary) — genoeg om het item
  zonder verdere navraag te kunnen invoegen.
- Stel niet meer nieuwe items voor dan de lesfase-richtlijn toelaat.
- Herhaal geen item dat al onder "Already Introduced" staat als
  doelconcept.
- Wees beknopt in de redenen (één regel per item volstaat).
- Doe geen aannames over personages of scènes die niet steunen op de
  meegegeven context.
- Volg de Romanisatieconventie hierboven exact voor elke paiboon-waarde; val niet terug op RTGS of IPA.
