# Language Note Planner Prompt Template

Gebruik dit bestand vóór er ook maar één note geschreven wordt. Het dekt
Stap 1 tot en met Stap 3 van
`docs/thai_a1_language_note_workflow_guide.md`: welke concepten vormen
samen één note, hoe heet die note, en uit welke blokken bestaat ze.

De output is een **voorstel dat jij goedkeurt of bijschuift** — geen
note-tekst. Dat is bewust: de gids legt na Stap 1 en na Stap 3 een
goedkeuringsmoment, omdat een verkeerde conceptverdeling of een
verkeerde blokvolgorde ná het uitschrijven vijf keer zoveel werk kost om
te herstellen.

Pas ná goedkeuring gaat het goedgekeurde plan als invoer naar
`08_language_note_writer_prompt_template.md`.

**Voorwaarde:** de dialoog van deze les is goedgekeurd en geseed (Stap 10
van de dialoogworkflowgids). Zolang de dialoog nog kan veranderen, kan
een note naar zinnen verwijzen die straks niet meer bestaan.

## Instructions

- Draai de brief-view voor deze les en vul de placeholders hieronder in.
  De mapping-checklist onderaan geeft per placeholder de bijbehorende
  query.
- Vul "Richtlijn voor deze lesfase" zelf in: zoek `sequence_number` op in
  de tabel "Hoeveel notes per les, en hoe lang?" in de workflowgids. Dat
  is een kleine, stabiele tabel; die hoef je niet telkens volledig te
  plakken. Neem bij "Notes per les" het bereik over, maar bij "Maximum
  blokken per note" **alleen de bovengrens** — een bereik leest als een
  te halen aantal en levert opgevulde notes op.
- Sla de ingevulde prompt op als
  `supabase/prompts/language-notes/a1_dialog_XX_planner_prompt.md`.
- Sla de modeloutput op als
  `supabase/generation/language-notes/a1_dialog_XX_plan.md`.
- Vervang **elke** placeholder vóór je genereert.

**Taalregel voor alle prompttemplates:** Nederlands boven en onder de
prompt, Engels erbinnen. De invulinstructies en de mapping-checklist zijn
voor jou en blijven Nederlands; alles tussen `## Role` en het einde van
`## Output Rules` gaat naar het model en is Engels.

Waarom: elke prompt levert waarden op die uiteindelijk in het Engels in
de database belanden — notetitels hier, dialoogtekst bij `04`,
`learning_focus` bij `05`. Een Nederlandse prompt die om een Engelse
waarde vraagt, is een zwakkere instructie dan een Engelse die dat doet.
Dit template stond tot 2026-08-06 volledig in het Nederlands.

De output van dit template is daardoor ook Engels. Dat is meegenomen: het
plan gaat ongewijzigd de schrijverprompt in, en die is Engels.

## Role

You are the editor of Language Notes for a Thai A1 course of about 50
lessons. A Language Note is a lesson-bound mini-lesson: a short, ordered
explanation the learner reads right after the dialogue of one specific
lesson, built from blocks: `paragraph`, `subheading`, `formula`,
`example_group` and `usage_tip`.

A Language Note is explicitly **not** a reference article and **not**
the definitive explanation of a concept. It explains what the learner
needs *at this point in the curriculum*. The same concept may be
explained again, more deeply, in a note belonging to a later lesson.
Completeness here is a defect, not a quality.

## Task

Propose how the concepts of lesson {{lesson_key}} that need explaining
should be divided over notes. For each note, give a title, a
justification, the concepts it covers, and the block skeleton.

Write **no** note text and **no** example sentences. Describe in one
line what goes into each block.

## Concepts To Explain

These are the lesson concepts flagged `requires_explanation = true`.
Together they are the assignment list: every concept below must be
covered by at least one note of this lesson.

The `key` on each concept is the identification. The readable fields
(Thai script, title, explanation) are context for you, but they identify
nothing — เดือน exists twice in the master list and cannot be told apart
by script or translation. So always carry the `key` over literally.

**Note the notation of `pattern_formula` and `short_explanation`.** Those
fields come from the master list and use their own style — for example
`จะ + VERB`, or "using the pattern Noun + Adjective" in running text.
That is **not** the notation a `formula` block uses. Do not copy them:
read them as descriptions and convert them to the fixed notation under
"Block Types". So `จะ + VERB` becomes `จะ + [verb] = future intention`,
and "Noun + Adjective" becomes `[noun] + [adjective] = descriptive
phrase`.

### Vocabulary

{{vocabulary_to_explain}}

### Grammar

{{grammar_to_explain}}

### Phrases

{{phrases_to_explain}}

### Patterns

{{patterns_to_explain}}

## The Lesson Dialogue

Every note anchors to this dialogue **in its opening paragraph and
nowhere else.** That paragraph quotes the Thai fragment the learner has
just read, with the dialogue's own translation.

The example groups do not. Never plan a sentence from the dialogue below
as an example — it sits on the same lesson page, already carrying its
transliteration and translation, so an example slot spent on it buys less
than a fresh application of the same point. An example that *resembles*
one is fine; a copy is not.

This applies to **this lesson's** dialogue, the only one you can see.
Echoing a sentence from an earlier lesson is not the same thing and is
often the better example: the learner does not have it in front of him,
so the echo shows him the new element with everything else already
familiar.

Use the dialogue to decide which fragment each note's paragraph should
quote.

{{dialog_text}}

## Block Types

There are five block types. Use only these names.

| Block type | When it is used |
| --- | --- |
| `paragraph` | required — every note opens with one |
| `example_group` | required as soon as the note explains a pattern or construction |
| `formula` | only for a construction with a fixed shape |
| `usage_tip` | only when there is a real pitfall |
| `subheading` | only for clearly separated sub-topics |

Only `paragraph` is unconditional. A note with zero `formula` blocks and
zero `usage_tip` blocks is complete; never add one to reach a count.

- **`paragraph`** — the workhorse. Every note opens with a `paragraph`
  that introduces the concept in two to four sentences and anchors it to
  the dialogue by quoting a Thai fragment from it. Name that fragment in
  the plan: it is the note's only contact with the dialogue. One idea per
  block; a second idea gets its own block.
- **`subheading`** — only for notes with clearly separated sub-topics
  (for example "Asking" and "Answering"). **Never the first block** (the
  title already does that work), **never the last block** (a heading
  with nothing under it is an empty promise), **never two in a row**. In
  a short note, headings are mostly visual noise.
- **`formula`** — the pattern in schematic form. The notation is fixed
  and has three parts: **English slot names in square brackets**,
  **fixed Thai elements in Thai script**, and an `=` followed by the
  function. So `[statement] + ไหม = yes/no question`, never
  `STATEMENT + ไหม` and never without the `=` part. Only meaningful for
  a construction with a fixed shape; a note explaining what a word means
  has none. One formula per block. A formula without an accompanying
  example group is meaningless to an A1 learner, so always plan one
  alongside it.
- **`example_group`** — two to four examples of the same language point.
  **Required for every note that explains a pattern or construction:**
  explanation without examples is not verifiable for an A1 learner. To
  show a contrast, plan two groups. Give each planned example a
  `speaker_gender` — see "Speaker Gender" below.
- **`usage_tip`** — one concrete tip: a pitfall, a politeness nuance, a
  difference from English. One tip per block, at most one or two tip
  blocks per note. Tips draw their force from scarcity: if the concept
  has no pitfall, the note gets no tip.

## Speaker Gender

Note examples are read by two fixed instruction voices, one female and
one male. **Every planned example gets a `speaker_gender`: `female` or
`male`.** You propose the division here; a human adjusts it when
approving the plan, and the writing phase then follows it without
choosing again.

| | `speaker_gender: female` | `speaker_gender: male` |
| --- | --- | --- |
| First person | ฉัน | ผม |
| Statement particle | ค่ะ | ครับ |
| Question particle | คะ | ครับ |

Two rules govern the assignment.

**Aim for balance across the lesson.** Not an exact half — with three
examples that is impossible — but no lesson where every example is the
same `speaker_gender`.

**Only examples that carry a gendered element count.** Many examples have
no first person and no final particle: กาแฟร้อน and ชาเย็น are bare noun
phrases. Such an example carries no `speaker_gender`, and it does not count
towards the balance. Never plan an example that exists only to display a
`speaker_gender` — and never plan one that would need a pronoun or a particle
bolted on to show it.

A note that teaches the male/female contrast itself is the one case where
both bundles must appear side by side. Say so in the justification.

Two skeletons, depending on what the note explains. A note about a
language pattern:

```
1. paragraph      — what this is and why you met it in the dialogue
2. formula        — the pattern in schematic form
3. example_group  — 2-4 examples of the pattern
4. usage_tip      — one warning (only if there really is a pitfall)
```

A note explaining what a word means often needs only two blocks:

```
1. paragraph      — what the word means, and where you met it
2. example_group  — 2-3 examples
```

## Guideline For This Lesson Phase (sequence_number {{sequence_number}})

- Notes per lesson:
- Maximum blocks per note:

**There is no target number of blocks.** Take only the blocks the
language point calls for. The maximum is an alarm, not a goal: a note
that runs up against it almost certainly covers two topics and must be
split.

## Instructions For The Proposal

1. **Cluster the concepts.** Related concepts that form one learnable
   whole — for example a question particle and the answer pattern that
   goes with it — belong in one note. Three micro-notes about one
   coherent phenomenon fragment the learner's attention and duplicate
   the examples. Conversely: two concepts with nothing to do with each
   other do not belong in one note just because it is convenient.
2. **Claim only what the note actually explains.** The test per concept:
   *would a learner understand this concept after reading this note?* If
   not, no link. A word appearing incidentally in an example sentence
   does not make it a covered concept. These claims later become the
   basis of the publication validation; false claims make that
   validation worthless.
3. **Choose a functional title** — see the title conventions below.
4. **Design the block skeleton** — see "Block Types" above. Per note,
   pick only the types the language point calls for. Assign a
   `speaker_gender` to every planned example, and check the balance across
   the lesson before you finish — see "Speaker Gender".
5. **Decide the order of the notes.** The learner reads them top to
   bottom. The note about the central lesson goal comes first;
   supporting notes (pronunciation, register, culture) after it. The
   first note decides whether the learner understands the dialogue; the
   rest deepen.
6. **Check the coverage.** Every concept from the list above appears in
   at least one note. One note may cover several concepts, and several
   notes may cover the same concept — both are normal.

## Title Conventions

- **Functional, not grammatical.** Describe what the learner can do with
  it, not what the phenomenon is called: *"Asking yes/no questions with
  ไหม"*, not *"The interrogative particle ไหม"*. An A1 learner does not
  know the technical term and does not need to.
- **Include the Thai key word in Thai script** when the note revolves
  around one word or particle.
- **Cover what the note teaches, not what its examples happen to be
  about.** The dialogue is a note's anchor, not its boundary. A note
  explaining that a describing word follows the noun teaches a rule the
  learner will later apply to cars and people, even though every example
  is about coffee and tea — so *"Describing drinks as hot or cold"*
  promises too little, while *"Talking about what you'll do with จะ"*
  correctly does not say "what you'll drink". A title can be functional
  and still be too narrow.
- **In English.**
- **Short:** around 60 characters at most; titles also appear in
  overviews and navigation.
- **Unique within the lesson.** Two notes with nearly the same title
  almost always mean the concept division is wrong.

## Output Format

Use exactly this structure.

```
## Note plan for {{lesson_key}}

### Note 1 — <title>

- note_key: {{lesson_key}}-note-1
- Why these concepts together: <one or two sentences>
- Concepts covered:
  - vocabulary / <source_key> — <thai script> <gloss>
  - grammar / <concept_key> — <title from the list>
- Block skeleton:
  1. paragraph — <what goes in it, one line>
  2. formula — <which pattern>
  3. example_group — <which language point, how many examples, speaker_gender per example>
  4. usage_tip — <which pitfall>

### Note 2 — <title>

<same structure>

## Coverage check

- <type> / <key> — Note 1
- <type> / <key> — Note 2

## Open questions

<doubts or alternatives a human must decide; leave empty if there are none>
```

## Output Rules

- **Carry every `key` over literally from the list above.** Never use
  `thai_script` or `title` to identify a concept.
- **`type` is one of:** `vocabulary`, `grammar`, `phrase`, `pattern`.
  Note the singular in `phrase` and `pattern`.
- **`note_key` follows the fixed convention:** `{{lesson_key}}-note-1`,
  `{{lesson_key}}-note-2`, numbered in reading order. Lower-case
  letters, digits and hyphens; no underscores.
- **Every concept from "Concepts To Explain" appears in the coverage
  check.** If you find a concept that in your judgement needs no note,
  put it under "Open questions" with your reasoning instead of leaving
  it out — the flag is the source of truth and is corrected by a human,
  not by you.
- **Write no note text.** No written-out paragraphs, no written-out
  example sentences, no translations. One line per block.
- **No transliteration in this proposal.** Name Thai words in Thai
  script if you must, but write no Paiboon — you do not have the
  recorded forms here, and a reconstructed form that lands in the
  proposal gets copied unquestioned in the writing phase.
- **Assign a `speaker_gender` to every planned example**, `female` or
  `male`. See "Speaker Gender" below. This is part of the plan, not of the writing
  phase.
- **No `subheading` as the first or last block**, and never two in a
  row.
- **No `formula` without an `example_group`** in the same note.
- **Write every formula in the fixed notation** `[slot] + fixed element
  = function`. Never copy the `pattern_formula` from the master list
  unchanged — it uses a different style.
- **Respect the maximum number of blocks from "Guideline For This
  Lesson Phase".** If you go over it, split and explain why in the
  justification.
- **Never add a block to reach a count.** A note of two blocks is a good
  note if the language point asks for no more.
- Be concise: one line per block, one or two sentences per
  justification.
- Make no assumptions about concepts, characters or scenes that do not
  follow from the context given.

# Brief-view -> prompt mapping checklist

Alle placeholders komen uit één view: `language_note_brief_view`. De
tabel hieronder zegt welke kolom bij welke placeholder hoort; de queries
eronder maken er de vorm van die je plakt.

Draai **niet** `select *` om de prompt te vullen. Dat levert de hele rij
met alle velden, inclusief de koppelrij-id's die na een `db reset`
verschuiven, en op een Windows-console komt het Thaise schrift er
onleesbaar uit. Bekijk de rij in Supabase Studio wanneer je hem wilt
inspecteren; gebruik de queries hieronder wanneer je invult.

| Placeholder | Kolom |
| --- | --- |
| `{{lesson_key}}` | `lesson_key` |
| `{{sequence_number}}` | `sequence_number` |
| `{{vocabulary_to_explain}}` | `vocabulary_to_explain` |
| `{{grammar_to_explain}}` | `grammar_to_explain` |
| `{{phrases_to_explain}}` | `phrases_to_explain` |
| `{{patterns_to_explain}}` | `patterns_to_explain` |
| `{{dialog_text}}` | `dialog` |

De vier conceptkolommen zijn `jsonb`-arrays. Plak ze als leesbare lijst
in plaats van als ruwe JSON — dat scheelt het model werk en jou
leesbaarheid. Voor vocabulaire:

```sql
select string_agg(
         format('- %s (%s) = %s  [key: %s]',
                c->>'thai_script', c->>'paiboon',
                c->>'english_gloss', c->>'source_key'),
         E'\n' order by (c->>'display_order')::int nulls first)
from public.language_note_brief_view v,
     lateral jsonb_array_elements(v.vocabulary_to_explain) c
where v.lesson_key = 'a1-dialog-XX';
```

Voor grammatica, phrases en patterns dezelfde vorm, met de eigen
sleutelnaam en velden:

```sql
-- grammar: concept_key · title · short_explanation
-- phrases: phrase_key  · title · phrase_formula  · short_explanation
-- patterns: pattern_key · title · pattern_formula · short_explanation
select string_agg(
         format('- %s: %s — %s  [key: %s]',
                c->>'title', c->>'phrase_formula',
                c->>'short_explanation', c->>'phrase_key'),
         E'\n' order by (c->>'display_order')::int nulls first)
from public.language_note_brief_view v,
     lateral jsonb_array_elements(v.phrases_to_explain) c
where v.lesson_key = 'a1-dialog-XX';
```

En voor de dialoogtekst:

```sql
select string_agg(
         format('%s: %s / %s / %s',
                b->>'speaker_key', b->>'thai_text',
                b->>'transliteration', b->>'translation_en'),
         E'\n' order by (b->>'block_index')::int)
from public.language_note_brief_view v,
     lateral jsonb_array_elements(v.dialog->'blocks') b
where v.lesson_key = 'a1-dialog-XX';
```

### Liever JSON dan een lijst?

Plak dan niet de ruwe view-kolom. Die draagt `lesson_vocabulary_id`,
`lesson_grammar_id`, `grammar_id`, `pattern_id` en `display_order` —
identity-waarden die na een `db reset` verschuiven, en die er precies
uitzien als de identifier die het model juist *niet* mag gebruiken. Het
ging tot nu toe goed omdat het model de `key` koos, niet omdat de prompt
hem daartoe dwong.

Gebruik in plaats daarvan een projectie. Voor vocabulaire:

```sql
select jsonb_pretty(jsonb_agg(jsonb_build_object(
         'source_key',    c->>'source_key',
         'thai_script',   c->>'thai_script',
         'paiboon',       c->>'paiboon',
         'english_gloss', c->>'english_gloss',
         'usage_note',    c->>'usage_note')
       order by (c->>'display_order')::int nulls first))
from public.language_note_brief_view v,
     lateral jsonb_array_elements(v.vocabulary_to_explain) c
where v.lesson_key = 'a1-dialog-XX';
```

Voor grammatica, phrases en patterns dezelfde vorm met hun eigen
sleutelnaam plus `title`, `short_explanation` en — alleen bij phrases en
patterns — `phrase_formula` respectievelijk `pattern_formula`. Dat laatste
veld hoort er wél in: het template vraagt het model expliciet die notatie
te lezen en om te zetten.

Laat `register` weg. Elk masterobject draagt hem met de betekenis
*formaliteit*, en deze prompt gebruikt de term nergens meer — sinds
2026-08-09 heet de mannelijk/vrouwelijk-keuze `speaker_gender`, juist om
die botsing te vermijden. Hem alsnog meeplakken zet beide betekenissen in
één prompt.

## Notes for manual filling

- Is een van de vier conceptlijsten leeg, schrijf dan letterlijk
  `(geen)` onder die kop. Laat de kop staan — een weggelaten kop leest
  als een vergissing, `(geen)` als een feit.
- Neem de `lesson_vocabulary_id`, `lesson_grammar_id`,
  `lesson_phrase_id` en `lesson_pattern_id` uit de view **niet** mee in
  de prompt. Dat zijn identity-waarden die na een `db reset` kunnen
  verschuiven; ze dienen om achteraf te controleren dat de seed dezelfde
  rij vond, niet om ergens ingevuld te worden.
- **De verdeling van `speaker_gender` doet het model; jij corrigeert
  hem.** Binnen één les kan het voorstel prima zelf spreiden, en je ziet
  bij het nalezen meteen wat het gekozen heeft. Wat het model níet kan
  zien is de rest van het curriculum — het krijgt één les. Kijk dus bij
  het goedkeuren over de les heen: het evenwicht geldt over het hele
  traject, en één les met drie voorbeelden laat zich niet netjes
  halveren.
- Wijkt je oordeel bij het reviewen af van de `requires_explanation`-vlag,
  pas dan het leslink-seedbestand aan en draai het opnieuw — niet alleen
  de database. Een correctie die alleen in de database staat, verdwijnt
  bij de eerstvolgende reset.
