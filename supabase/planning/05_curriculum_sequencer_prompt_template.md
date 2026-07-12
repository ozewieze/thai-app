# Curriculum Sequencer Prompt Template

Gebruik dit template MET de resultaten van
`00_build_curriculum_sequencer_context.sql` (secties 1 t/m 5).
Dit is een apart, voorafgaand gesprek — niet de dialoogprompt zelf.
Het doel is een onderbouwd voorstel voor de VOLGENDE les, dat je
bijstuurt vóór je iets seedt.

## Instructions

- Open dit template en de zes SQL-sectieresultaten naast elkaar.
- Vervang elke placeholder met het resultaat van de bijhorende sectie.
- Vul {{lesson_phase_table}} in met de tabel uit "Hoeveel nieuwe
  woorden en regels per lesfase" in de workflow-gids.

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

## Lesson Phase Guidance

{{lesson_phase_table}}

Bepaal de lesfase op basis van {{next_sequence_number}} en gebruik het
bijhorende bereik voor nieuwe woorden en regelaantal.

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

- [EXISTING] thai_script (paiboon) = gloss — reden waarom dit past
- [NEW] thai_script (paiboon) = gloss — part_of_speech, register, default_theme — reden

## Proposed Phrases

- [EXISTING|NEW] titel: formule — reden

## Proposed Grammar

- [EXISTING|NEW] titel: korte uitleg — reden

## Proposed Patterns

- [EXISTING|NEW] titel: formule — reden

## Open Questions

(eventuele twijfels of alternatieven die de mens moet beslissen)
```

## Output Rules

- Elk voorgesteld item krijgt exact één label: `[EXISTING]` (al in de
  masterlijst, status 'new') of `[NEW]` (nog niet in de masterlijst).
- Voor `[NEW]`-items: geef genoeg detail om het meteen te kunnen
  invoegen in de masterlijst (zie "Nieuw woord/concept toevoegen aan
  de masterlijst" in de workflow-gids).
- Stel niet meer nieuwe items voor dan de lesfase-richtlijn toelaat.
- Herhaal geen item dat al onder "Already Introduced" staat als
  doelconcept.
- Wees beknopt in de redenen (één regel per item volstaat).
- Doe geen aannames over personages of scènes die niet steunen op de
  meegegeven context.
