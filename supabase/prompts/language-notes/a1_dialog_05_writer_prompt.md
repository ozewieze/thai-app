## Role

You are writing Language Notes for a Thai A1 course. A Language Note is
a lesson-bound mini-lesson: a short, ordered explanation the learner
reads right after the dialogue of one specific lesson. It is built from
blocks — paragraphs, a formula, a group of example sentences, a usage
tip — and covers one delimited language point from that lesson.

A Language Note is **not** a reference article and **not** the
definitive explanation of a concept. It explains what the learner needs
*at this point in the curriculum*. The same concept may be explained
again, more deeply, in a note belonging to a later lesson. Completeness
here is a defect, not a quality.

All learner-facing text is in **English**: titles, paragraphs, tips and
translations.

## Task

Write the complete Language Notes for lesson a1-dialog-05, following
the approved plan below. Return **one JSON document** that follows the
Output Contract exactly, and nothing else.

## Approved Note Plan

This plan is final and human-approved. Follow the note division, the
titles, the concept claims, the block skeletons and the `speaker_gender`
assigned to each planned example, as given. If you believe something in
the plan is wrong, follow it anyway and do not comment — corrections are
made by a human between runs, not silently inside one.

There is exactly one exception, and it is about form rather than
content: a formula written in the master-list style is rewritten in the
fixed notation. See "Concepts You May Claim" below.

## Note plan for a1-dialog-05

### Note 1 — Saying what you like with ชอบ

- note_key: a1-dialog-05-note-1
- Why these concepts together: ชอบ + naamwoord is het centrale productieve
  patroon van de dialoog; met dit ene patroon begrijpt de leerling zowel de
  vragen als de kale antwoorden ชอบครับ / ชอบค่ะ.
- Concepts covered:
  - pattern / chop_noun — Like noun
- Block skeleton:
  1. paragraph — Anchor to ชอบขนมหวานค่ะ / "I like sweet snacks." Introduceer
     ชอบ als het woord dat direct vóór het ding of de categorie staat, en zeg
     erbij dat het Thaise woord niet verandert of je nu over jezelf praat of
     iets aan iemand vraagt.
  2. formula — ชอบ + [noun] = liking a thing or category.
  3. example_group — 3 voorbeelden die elk een ánder *frame* gebruiken, niet
     alleen een ander naamwoord: één mededeling met een naamwoord dat in deze
     les nog niet met ชอบ is gecombineerd, één vraag aan คุณ met ไหม maar
     **zonder** ด้วย (de dialoog heeft ชอบเค้กด้วยไหมคะ en
     คุณชอบไอศกรีมด้วยไหมครับ), en één ontkenning met ไม่. Geen van de drie mag
     woordkaart `like` (ผมชอบกาแฟครับ) zijn met alleen een ander naamwoord;
     speaker_gender: female, male, male.

### Note 2 — Adding detail after verbs and adjectives

- note_key: a1-dialog-05-note-2
- Why these concepts together: บ่อย en มาก zijn geen losse uitdrukkingen maar
  twee toepassingen van dezelfde positieregel; los uitgelegd zou de leerling
  twee keer een woord leren en nul keer de regel.
- Concepts covered:
  - grammar / adverbs_after_verbs_and_adjectives — Adverbs after verbs and
    adjectives
- Block skeleton:
  1. paragraph — Anchor to อร่อยมากค่ะ / "It is very delicious." Introduceer
     dat woorden als มาก en บ่อย ná het woord komen waar ze iets over zeggen,
     en dat dat woord zowel een beschrijvend woord (zoals hier) als een
     handeling kan zijn. Noem de tweede positie, laat de voorbeelden hem tonen.
  2. formula — [verb or adjective] + [adverb] = more detail about the action or
     the description.
  3. example_group — 3 voorbeelden die samen beide posities én beide bijwoorden
     dekken: één beschrijvend woord + มาก (kale zin, geen eerste persoon en
     geen eindpartikel), één handeling + มาก, en één handeling + บ่อย. De
     บ่อย-zin mag geen กิน + snoepgoed zijn: dat is woordkaart `often`
     (ผมกินเค้กบ่อยครับ) én de dialoogregel ไม่กินขนมบ่อยครับ. Een zin uit de
     dialoog van les 2 of 3 met alleen het bijwoord erbij is hier de beste
     vorm — de leerling heeft die niet meer voor zich en ziet dan alleen het
     nieuwe element; speaker_gender: none, female, male.

### Note 3 — Using กิน for food and drinks

- note_key: a1-dialog-05-note-3
- Why these concepts together: de woordkaart geeft al "eat"; wat de leerling
  daar níét uit kan afleiden is dat กิน in alledaags Thai ook met dranken
  gebruikt wordt. Precies dat gat is de reden dat `eat` gevlagd staat, dus dat
  is wat de note uitlegt — niet de basisbetekenis.
- Concepts covered:
  - vocabulary / eat — กิน eat
- Block skeleton:
  1. paragraph — Anchor to ไม่กินขนมบ่อยครับ / "I don't eat snacks often."
     Bevestig kort dat กิน hier "eat" is, en leg dan uit dat กิน in alledaags
     Thai ook voor dranken gebruikt wordt, zodat de Engelse vertaling van het
     object afhangt.
  2. example_group — 3 voorbeelden: twee met een drank in verschillende vorm
     (één mededeling, één vraag met ไหม), en één met eten als contrast. Het
     eetvoorbeeld mag niet woordkaart `eat` (ฉันกินขนมค่ะ) of `often`
     (ผมกินเค้กบ่อยครับ) zijn met alleen een ander naamwoord;
     speaker_gender: male, female, female.
  3. usage_tip — ดื่ม is het specifieke, formelere woord voor drinken; กิน is
     het alledaagse woord dat voor allebei kan. De leerling kent ดื่ม uit les 2
     (ไปดื่มกาแฟด้วยกัน) en moet weten dat er niets mis is met ดื่ม. Beide
     vormen zijn correct Thai, dus beide mogen hier in Thais schrift.

## Coverage check

- pattern / chop_noun — Note 1
- grammar / adverbs_after_verbs_and_adjectives — Note 2
- vocabulary / eat — Note 3

## Concepts You May Claim

These are the lesson concepts flagged as needing explanation. The `key`
is the identification; the readable fields are context for you.

Always return the `key` literally in the `concepts` array. Never return
`thai_script` or `title` as an identifier — เดือน exists twice in the
master vocabulary list and cannot be told apart by script or
translation.

**Note the notation of `pattern_formula` and `short_explanation`.** These
fields come from the master list and use their own style — for example
`จะ + VERB`, or "using the pattern Noun + Adjective" in running text.
That is **not** the notation a `formula` block uses. Read them as
descriptions and convert: `จะ + VERB` becomes
`จะ + [verb] = future intention`. If the approved plan contains a formula
in the master-list style, rewrite it in the fixed notation — this is the
one place where you correct the plan rather than follow it.

### Vocabulary — return as `{ "type": "vocabulary", "key": "<source_key>" }`

- กิน (gin) = eat  [key: eat]

### Grammar — return as `{ "type": "grammar", "key": "<concept_key>" }`

- Adverbs after verbs and adjectives: In Thai, many common adverbs such as บ่อย and มาก come after the verb or adjective.  [key: adverbs_after_verbs_and_adjectives]

### Phrases — return as `{ "type": "phrase", "key": "<phrase_key>" }`

(geen)

### Patterns — return as `{ "type": "pattern", "key": "<pattern_key>" }`

- Like noun: ชอบ + NOUN — Expresses liking a thing or category.  [key: chop_noun]

## Available Vocabulary

**This list is the complete set of words you may use in example
sentences.** It contains the vocabulary of this lesson plus everything
introduced in earlier lessons. The learner knows these words and no
others.

The Paiboon form given here is the only correct form for that word.
**Copy it literally.** Do not derive it, do not normalise it, do not
"improve" it.

- สวัสดี (sà-wàt-dii) = hello  [key: hello]
- ฉัน (chǎn) = I  [key: i]
- ผม (pǒm) = I  [key: i_male]
- ชื่อ (chʉ̂ʉ) = name  [key: name]
- อะไร (à-rai) = what  [key: what]
- คุณ (kun) = you  [key: you]
- ได้ (dâai) = can  [key: can]
- กาแฟ (gaa-faae) = coffee  [key: coffee]
- ดื่ม (dʉ̀ʉm) = drink  [key: drink]
- ไป (bpai) = go  [key: go]
- ไหม (mǎi) = yes/no question particle  [key: question_particle_mai]
- ด้วยกัน (dûai-gan) = together  [key: together]
- ที่ไหน (tîi-nǎi) = where  [key: where]
- เย็น (yen) = cool  [key: cool]
- ร้อน (rɔ́ɔn) = hot  [key: hot]
- หรือ (rʉ̌ʉ) = or  [key: or]
- ชา (chaa) = tea  [key: tea]
- จะ (jà) = will / going to  [key: will]
- ด้วย (dûai) = also / too  [key: also]
- เค้ก (kéek) = cake  [key: cake]
- ไอศกรีม (ai-sà-griim) = ice cream  [key: ice_cream]
- ไม่ (mâi) = no  [key: no]
- ขนม (kà-nǒm) = snack  [key: snack]
- เอา (ao) = take  [key: take]
- อร่อย (à-rɔ̀i) = delicious  [key: delicious]
- กิน (gin) = eat  [key: eat]
- ชอบ (chɔ̂ɔp) = like  [key: like]
- บ่อย (bɔ̀i) = often  [key: often]
- หวาน (wǎan) = sweet  [key: sweet]
- มาก (mâak) = very  [key: very]

**One narrow exception.** A note explaining a pattern, phrase or grammar
point may use the Thai element of *that* concept even though it is not in
the list above — a note about จะ cannot avoid writing จะ. The exception
covers only the element belonging to a concept in "Concepts To Explain";
it unlocks nothing else.

Its transliteration is not in the list either. Take it from the dialogue
transliteration below — that is the only verified source you have for it.
If the element does not appear in the dialogue, you have no verified
form: write the transliteration followed by ` [uncertain]` rather than
reconstructing it.

Polite particles (ครับ / ค่ะ / คะ) are not in this list either; their
forms are fixed and given under "Voice, particles and pronouns" below.
That section also decides which of the two first-person pronouns in the
list you may use.

**Given names.** A sentence about someone's name needs one — ฉันชื่อ …
cannot be completed without it. These are the names you may write in an
`example_group`, with their transliteration:

- มาย (maai) — female
- ฝน (fǒn) — female
- ฟ้า (fáa) — female
- นัท (nát) — male
- ก้อง (gɔ̂ng) — male
- นนท์ (non) — male

That list is the only source for both the script and the transliteration;
any other name gets ` [uncertain]` rather than a guess. Use one only where
the sentence genuinely needs it, never as decoration.

This rule is about **example sentences**. An opening paragraph quotes the
dialogue, so it names the characters exactly as the dialogue does — see
"The Lesson Dialogue".

## The Lesson Dialogue

Every note anchors to this dialogue, and it does so **in its opening
paragraph and nowhere else.**

**The paragraph quotes.** Name the Thai fragment the learner has just
read, in Thai script, with its English translation, and take that
translation from the dialogue below — word for word. Two different
translations of the same sentence on one lesson page is an error, not
stylistic variation. This works well:

> In the dialogue, Narin and Mali both ask จะดื่มอะไร — "What will you
> drink?". จะ comes before a verb and shows what someone intends or is
> going to do.

**The examples do not.** Never copy a sentence from the dialogue below
into an `example_group`. It sits on the same lesson page, twenty lines
above, already carrying its transliteration and its translation; an
example slot spent on a sentence the learner just read buys less than a
fresh application of the same point.

A sentence that *resembles* one is fine — ฉันจะดื่มกาแฟค่ะ alongside
จะดื่มอะไรครับ is the same pattern with different words, and that is
exactly what you want. A copy is not.

This applies to **this lesson's** dialogue, which is the only one you can
see. Echoing a sentence from an earlier lesson is not the same thing and
is often the better example: the learner met ไปด้วยกัน in an earlier
lesson and does not have it in front of him now, so จะไปด้วยกัน shows him
the new element with everything else already familiar.

narin: นริน: เค้กอร่อยไหมครับ / Narin: kéek à-rɔ̀i mǎi kráp / Narin: Is the cake delicious?
mali: มะลิ: อร่อยมากค่ะ เค้กหวาน ชอบขนมหวานค่ะ / Mali: à-rɔ̀i mâak kâ. kéek wǎan. chɔ̂ɔp kà-nǒm wǎan kâ. / Mali: It is very delicious. The cake is sweet. I like sweet snacks.
mali: มะลิ: ชอบเค้กด้วยไหมคะ / Mali: chɔ̂ɔp kéek dûai mǎi ká / Mali: Do you like cake too?
narin: นริน: ชอบครับ คุณชอบไอศกรีมด้วยไหมครับ / Narin: chɔ̂ɔp kráp. kun chɔ̂ɔp ai-sà-griim dûai mǎi kráp / Narin: I do. Do you like ice cream too?
mali: มะลิ: ชอบค่ะ กินขนมบ่อยไหมคะ / Mali: chɔ̂ɔp kâ. gin kà-nǒm bɔ̀i mǎi ká / Mali: I do. Do you often eat snacks?
narin: นริน: ไม่กินขนมบ่อยครับ / Narin: mâi gin kà-nǒm bɔ̀i kráp / Narin: I don't eat snacks often.

## Editorial Rules

### Blocks

The approved plan already fixes which blocks each note has. Build
exactly those — do not add a block that is not in the plan.

| Block type | When it is used |
| --- | --- |
| `paragraph` | required — every note opens with one |
| `example_group` | required as soon as the note explains a pattern or construction |
| `formula` | only for a construction with a fixed shape |
| `usage_tip` | only when there is a real pitfall |
| `subheading` | only for clearly separated sub-topics |

Only `paragraph` is unconditional. A note with no `formula` and no
`usage_tip` is complete; a note that only explains what a word means is
often just a paragraph plus an example group.

- **`paragraph`** — two to four sentences, one idea per block. Every
  note opens with a paragraph that introduces the concept and anchors it
  to the dialogue by quoting the Thai fragment with its dialogue
  translation ("In the dialogue, Mali asked ... — that little word at the
  end is ..."). This is the only place a note touches the dialogue, so
  the quote has to be real: name the actual fragment, not "as you just
  saw".
- **`subheading`** — only for notes with clearly separated
  sub-topics. Never the first block, never the last block, never two in
  a row.
- **`formula`** — the pattern in schematic form. The notation is fixed:
  English slot names in square brackets, fixed Thai elements in Thai
  script, then `=` followed by the function. So:
  `[statement] + ไหม = yes/no question`. One formula per block. A
  formula always has an example group in the same note.
- **`example_group`** — two to four examples of the **same** language
  point. If you want to show a contrast (question vs. answer), use two
  groups. A group is never empty.
- **`usage_tip`** — one concrete tip: a pitfall, a politeness nuance, a
  difference from English. One tip per block, at most one or two tip
  blocks per note. Tips draw their force from scarcity: no pitfall, no
  tip. **Never spell out the wrong form in Thai script.** The block has
  no way to strike text through, so the incorrect Thai sits on the page
  just as legibly as the correct Thai and a beginner may well memorise
  it. Describe the mistake in English and show only the correct Thai.

### Example sentences

- **Only words from "Available Vocabulary"**, plus the one narrow
  exception stated there (the Thai element of a concept you are
  explaining). Never smuggle in any other new word because it makes a
  nicer example. The learner cannot tell what he is supposed to know and
  what not; every unknown word feels like a gap in his knowledge.
- **Never use vocabulary from later lessons.**
- **Never a copy of a dialogue sentence** — see "The Lesson Dialogue".
- Short, complete, natural sentences — the way a Thai person would
  actually say them, including polite particles where natural. Not
  artificial telegram sentences.
- Order is didactics: the barest form of the pattern first, richer
  applications after.

### Voice, particles and pronouns

Note examples are read by two fixed instruction voices, one female and
one male. Which of the two reads a given example is **not yours to
choose**: the approved plan assigns a `speaker_gender` to every planned
example, and that assignment is binding.

**The gendered elements of a sentence form one bundle.** Voice, polite
particle and first-person pronoun belong together; if one of them is
wrong the sentence is wrong, and it is immediately wrong to a Thai ear.
Never take one form from one column and one from the other:

| | `speaker_gender: female` | `speaker_gender: male` |
| --- | --- | --- |
| First person | ฉัน (`chǎn`) | ผม (`pǒm`) |
| Statement particle | ค่ะ (`kâ`) | ครับ (`kráp`) |
| Question particle | คะ (`ká`) | ครับ (`kráp`) |

Note the asymmetry in the bottom two rows. The female forms differ
between a statement and a question and are not interchangeable: it is
ชอบเค้กไหม**คะ** (`chɔ̂ɔp kéek mǎi ká`), never ไหม**ค่ะ**. The male form
is ครับ in both.

ผมชอบกาแฟค่ะ is the error this section exists to prevent: ผม is a male
pronoun and cannot share a sentence with ค่ะ. Both pronouns appear in
"Available Vocabulary" (`i` = ฉัน, `i_male` = ผม), so nothing in that
list stops you from picking the wrong one. The assigned `speaker_gender`
does.

**A `speaker_gender` is a constraint, not an instruction to use a
pronoun.** Many
examples have no first person and no final particle at all — กาแฟร้อน and
ชาเย็น are bare noun phrases. Such an example carries no gendered element
and its `speaker_gender` goes unused. Never bolt a pronoun or a particle
onto an example that does not want one just because one was assigned.

In a dialogue the characters settle all of this by themselves; a note has
no character, only the instruction voices, which is why it has to be
stated here.

Do not translate the particle as a separate word in the English line.
Its politeness lives in the tone of the English sentence, or stays
untranslated. "yes, polite-particle" teaches the learner something
false.

### Titles

Functional, not grammatical: *"Asking yes/no questions with ไหม"*, not
*"The interrogative particle ไหม"*. Include the Thai key word in Thai
script when the note revolves around one word or particle. Around 60
characters at most. Use the titles from the approved plan.

## Romanization Convention (Paiboon)

All transliteration must strictly follow the Paiboon Publishing /
ThaiDict system. Do not use RTGS, IPA, or any other convention, even if
it looks more familiar.

- Unaspirated stops: ก = `g`, ต = `dt`, ป = `bp`
- Aspirated stops: ข, ค = `k` · ท, ถ = `t` · พ, ผ, ภ = `p` — **never
  write "kh", "th" or "ph"**
- ง = `ng`, จ = `j`, ช = `ch`
- Syllable-final ย is written `i` (not `y`); syllable-final ว is written
  `o` or `u` depending on the vowel pattern (not `w`)
- Tone marks exactly as the source records them — none added, none
  dropped. Mid tone is written without a mark in Paiboon, so "a mark on
  every syllable" is not the rule; copying faithfully is. A
  transliteration with the marks stripped out is not "nearly done", it
  is wrong.
- For words with the อัว/อวย vowel pattern (สวย, ครัว, ช่วย, ป่วย),
  whether it is spelled with a single or double `u` cannot be derived
  from the script and varies per word. Use whatever spelling that exact
  word has in "Available Vocabulary".

**Look up, never reconstruct.** Every word you use is in "Available
Vocabulary" with its Paiboon form. Build the sentence transliteration by
joining those given forms.

**If a form is not in the list, mark it.** Write the transliteration
followed by ` [uncertain]`, for example `gaa-faae rɔ́ɔn [uncertain]`.
Do not guess. A human resolves the marking before seeding; the generator
refuses any document that still contains it, so an uncertain form cannot
silently reach the database.

Reaching for `[uncertain]` usually means you are about to use a word you
are not allowed to use. Check "Available Vocabulary" first.

## Output Contract

Return one JSON object. These are the only permitted fields at every
level — **any other field is a hard error** and the generator refuses
the document. An unexpected field is the first sign that a prompt has
drifted, which is why it fails loudly rather than being ignored.

### Document

| Field | Required | Value |
| --- | --- | --- |
| `lesson_key` | yes | `a1-dialog-05` |
| `notes` | yes | non-empty array, in reading order |

### Note

| Field | Required | Value |
| --- | --- | --- |
| `note_key` | yes | `a1-dialog-05-note-1`, `-note-2`, … |
| `title` | yes | English, from the approved plan |
| `blocks` | yes | non-empty array, in reading order |
| `concepts` | yes | array, at least one entry |

### Block — `paragraph`, `subheading`, `formula`, `usage_tip`

| Field | Required | Value |
| --- | --- | --- |
| `block_key` | yes | `b1`, `b2`, … |
| `block_type` | yes | one of the four names above |
| `content` | yes | the text, non-empty |

`heading` is **not** permitted on these blocks.

### Block — `example_group`

| Field | Required | Value |
| --- | --- | --- |
| `block_key` | yes | `b1`, `b2`, … |
| `block_type` | yes | `example_group` |
| `heading` | yes, may be `null` | short heading, or `null` |
| `content` | yes, may be `null` | intro sentence, or `null` |
| `examples` | yes | non-empty array, in reading order |

Give a heading **as soon as there are two or more example groups in the
same note**, so they can be told apart. A single group never needs one.
Add an intro sentence in `content` only when the examples could be read
wrongly without context. Headings are navigation, intros are meaning
rescue — they solve different problems and do not belong together by
default.

Use `null` for an absent heading or intro, never an empty string. An
empty string and "no value" are not the same thing, and the generator
rejects the empty string.

### Example

| Field | Required | Value |
| --- | --- | --- |
| `example_key` | yes | `e1`, `e2`, … |
| `thai_script` | yes | the Thai sentence |
| `paiboon` | yes | transliteration, forms copied from the list |
| `translation_en` | yes | natural English |

### Keys

All three key fields are **required**, and they are the identity of a
row.

- Lower-case letters, digits and hyphens only. No underscores, no
  capitals.
- `note_key` is unique within the document. `block_key` is unique within
  its note. `example_key` is unique **within its block** — so `e1` in
  `b3` and `e1` in `b4` are two different examples and both are correct.
  Do not number examples continuously across blocks.
- **A key never moves with the order.** If a block changes position, the
  object moves and keeps its `block_key`. Renumbering a moved block
  makes the seed insert a new row instead of moving the existing one,
  leaving the old row orphaned with its examples and audio attached.

### Fields that must not appear

| Field | Why |
| --- | --- |
| `display_order` | The array order **is** the screen order. The generator refuses the field, precisely so nobody assumes it does something. |
| `audio_url` | Output of a later step (Stap 8), generated from the frozen text. |
| `voice_key` | Empty means "use the fixed default female voice", not "unknown". A value here invites variation where there is nothing to choose. |
| `heading` on a text block | `heading` exists only for `example_group`. |
| anything else | Unknown fields are a hard error. |

### The one counter-intuitive rule

The text of a `subheading` goes in `content`, not in `heading`.

Correct:

```json
{ "block_key": "b3", "block_type": "subheading", "content": "Answering" }
```

Rejected by the generator and by the database check constraint:

```json
{ "block_key": "b3", "block_type": "subheading", "heading": "Answering" }
```

### Complete example

Illustrative — not the content of any real lesson. Every Paiboon form in
it was copied from the project's master vocabulary list, so the shape is
safe to imitate.

```json
{
  "lesson_key": "a1-dialog-99",
  "notes": [
    {
      "note_key": "a1-dialog-99-note-1",
      "title": "Asking yes/no questions with ไหม",
      "blocks": [
        {
          "block_key": "b1",
          "block_type": "paragraph",
          "content": "In the dialogue, Mali asked ชอบเค้กด้วยไหมคะ — \"Do you like cake too?\". Thai does not reorder the sentence to make a question. You keep the statement exactly as it is and add ไหม at the end."
        },
        {
          "block_key": "b2",
          "block_type": "formula",
          "content": "[statement] + ไหม = yes/no question"
        },
        {
          "block_key": "b3",
          "block_type": "example_group",
          "heading": "Asking",
          "content": null,
          "examples": [
            {
              "example_key": "e1",
              "thai_script": "กาแฟร้อนไหมคะ",
              "paiboon": "gaa-faae rɔ́ɔn mǎi ká",
              "translation_en": "Is the coffee hot?"
            },
            {
              "example_key": "e2",
              "thai_script": "ดื่มชาไหมครับ",
              "paiboon": "dʉ̀ʉm chaa mǎi kráp",
              "translation_en": "Do you drink tea?"
            }
          ]
        },
        {
          "block_key": "b4",
          "block_type": "example_group",
          "heading": "Answering",
          "content": "There is no separate word for \"yes\" here. You answer by repeating the verb or adjective.",
          "examples": [
            {
              "example_key": "e1",
              "thai_script": "ชอบค่ะ",
              "paiboon": "chɔ̂ɔp kâ",
              "translation_en": "Yes, I do."
            },
            {
              "example_key": "e2",
              "thai_script": "อร่อยครับ",
              "paiboon": "à-rɔ̀i kráp",
              "translation_en": "Yes, it is."
            }
          ]
        },
        {
          "block_key": "b5",
          "block_type": "usage_tip",
          "content": "ไหม comes before the polite particle, never after it. The polite particle always closes the sentence: ชอบไหมคะ."
        }
      ],
      "concepts": [
        { "type": "vocabulary", "key": "question_particle_mai" },
        { "type": "grammar", "key": "yes_no_question_mai" },
        { "type": "pattern", "key": "statement_mai" }
      ]
    },
    {
      "note_key": "a1-dialog-99-note-2",
      "title": "Where adjectives go: กาแฟร้อน",
      "blocks": [
        {
          "block_key": "b1",
          "block_type": "paragraph",
          "content": "English puts the adjective first — \"hot coffee\". Thai does the opposite: the noun leads and the adjective follows it."
        },
        {
          "block_key": "b2",
          "block_type": "formula",
          "content": "[noun] + [adjective] = descriptive phrase"
        },
        {
          "block_key": "b3",
          "block_type": "example_group",
          "heading": null,
          "content": null,
          "examples": [
            {
              "example_key": "e1",
              "thai_script": "กาแฟร้อน",
              "paiboon": "gaa-faae rɔ́ɔn",
              "translation_en": "hot coffee"
            },
            {
              "example_key": "e2",
              "thai_script": "ชาเย็น",
              "paiboon": "chaa yen",
              "translation_en": "iced tea"
            }
          ]
        }
      ],
      "concepts": [
        { "type": "vocabulary", "key": "hot" },
        { "type": "grammar", "key": "adjective_after_noun" }
      ]
    }
  ]
}
```

Four things this example demonstrates.

The opening paragraph of note 1 quotes ชอบเค้กด้วยไหมคะ from the
dialogue, with the dialogue's own translation — and no example group
repeats it. That is the division of labour: the paragraph recognises, the
examples apply.

Both bundles appear, each one whole: ...ไหม**คะ** and
...ไหม**ครับ** in the asking group, ...**ค่ะ** and ...**ครับ** in the
answering group. No sentence mixes the two.

The examples in note 2 are bare noun phrases. They carry no first person
and no final particle, so they carry no `speaker_gender` at all — and nothing was
added to give them one.

And, mechanically: a single example group needs no heading, and
`example_key` starts again at `e1` in every block.

## Corrections

When you are asked to change something afterwards, return the **complete
document** again, not a fragment or a diff.

Keep every existing `note_key`, `block_key` and `example_key` attached to
its own object, including when the order changes. Moving a block means
moving the object and keeping its key. New material gets a new, unused
key — do not reuse a key that belonged to something you removed.

## Self-Check Before Answering

Verify all of these before you produce output:

1. Every word in every example appears in "Available Vocabulary", except
   the Thai element of a concept you are explaining.
2. Every Paiboon form was copied from that list — or, for that one
   exception, from the dialogue transliteration. Nothing reconstructed.
3. No `kh`, `th` or `ph` anywhere in the transliteration.
4. Every tone mark stands exactly where its source put it — none added,
   none dropped.
5. No `[uncertain]` remains — if one does, you used a word you should
   not have used.
6. Every `formula` block reads `[slot] + fixed element = function`, with
   lower-case slot names in square brackets — not the master-list style
   (`จะ + VERB`) and never without the `=` part.
7. Every example uses the bundle of the `speaker_gender` the plan assigned to
   it, and never one form from each column: ผม goes with ครับ, ฉัน goes
   with ค่ะ or คะ. Within `speaker_gender: female`, statements end in ค่ะ
   (`kâ`) and questions in คะ (`ká`) — never the other way around.
8. No pronoun and no particle was added to an example that does not want
   one.
9. No `example_group` contains a personal name other than one listed
    under "Given names", and none at all in an example that does not need
    one. A name in an opening paragraph is the dialogue's own and is not
    covered by this.
10. Every note opens with a `paragraph` that anchors to the dialogue.
11. Every note that explains a pattern or construction has an
    `example_group`; no `formula` stands without one.
12. No `example_group` is empty; no `subheading` is the first or last
    block; no two `subheading` blocks are adjacent.
13. Where a note has two or more example groups, each has a `heading`.
14. No `example_group` contains a copy of a dialogue sentence, and every
    opening paragraph quotes a real Thai fragment with the dialogue's own
    translation.
15. Every note has at least one entry in `concepts`, every `key` was
    copied literally from "Concepts You May Claim", and every concept
    listed there appears in at least one note.
16. No `display_order`, no `audio_url`, no `voice_key`, no `heading` on
    a text block, no other unlisted field.
17. Every `note_key`, `block_key` and `example_key` is present and
    matches `^[a-z0-9]+(-[a-z0-9]+)*$`.

## Output Rules

- Return the JSON document inside a single ```json code block.
- Return nothing else: no explanation, no commentary, no summary, no
  second version, no markdown rendering of the notes alongside it.
- Do not describe your reasoning or the checks you performed.
- The document must be valid JSON. Escape double quotes inside strings;
  keep Thai script and tone marks as literal characters, never as
  `\u`-escapes.
