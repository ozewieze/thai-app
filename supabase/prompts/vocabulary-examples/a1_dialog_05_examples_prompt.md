## Role

You are writing the canonical example sentences for the vocabulary cards
of a Thai A1 course.

A vocabulary card presents one word: the Thai script, the transliteration,
the English meaning, and **one** example sentence showing how that word
works in a real sentence. Your job is that sentence.

Three things about a canonical example decide almost everything below.

**It belongs to the word, not to a lesson.** The same sentence is shown
in every lesson where the word appears — the lesson that introduces it,
and any later lesson that reuses it, possibly twenty lessons apart. It is
written once and stays.

**It stands completely alone.** There is no scene, no character, no
surrounding text and nothing before or after it. The test: would this
sentence still be understandable if it were the only thing on the screen?

**There is only one.** No second sentence will follow to fill in what the
first one missed. Write the sentence you would choose if you were allowed
only one — because that is exactly the situation.

All learner-facing text is in **English**.

## Task

Write exactly one canonical example for each word listed under "Target
Words" below — no more and no fewer. Return **one JSON document** that
follows the Output Contract exactly, and nothing else.

## Target Words

Each of these words needs one example. The `source_key` is the
identification; the readable fields are context for you.

Always return the `source_key` literally. Never use `thai_script` to
identify a word — เดือน exists twice in the master vocabulary list and
cannot be told apart by script or translation.

The example must show the meaning given in `english_gloss`, and only that
meaning. A word may well have other functions; they are not yours to
show. Two functions squeezed into one sentence makes both unrecognisable.

**Divide the two speaker genders across these words.** Not an exact half —
with three or five words that is impossible — but never a run in which
every example is the same one. See "Voice, Particles and Pronouns" for
what that governs and for the one kind of sentence that stays out of the
count.

- ชอบ (chɔ̂ɔp) = like  [key: like]  ·  verb  ·  Also commonly expresses preference.
- กิน (gin) = eat  [key: eat]  ·  verb  ·  Also often used for drink in everyday speech.
- อร่อย (à-rɔ̀i) = delicious  [key: delicious]  ·  adjective
- หวาน (wǎan) = sweet  [key: sweet]  ·  adjective
- บ่อย (bɔ̀i) = often  [key: often]  ·  adverb

## Available Vocabulary

**This list is the complete set of words you may use in example
sentences.** It contains everything the learner knows by the time he can
first see these cards. He knows these words and no others.

Never smuggle in another word because it makes a nicer example. The
learner cannot tell what he is supposed to know and what not; every
unknown word feels like a gap in his knowledge. Proper names, numbers and
loanwords count as words — they look free because they seem
internationally recognisable, but the learner has to read them in Thai
script, and that is precisely what he cannot yet do.

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
- ด้วยกัน (dûai-gan) = together  [key: together]
- ที่ไหน (tîi-nǎi) = where  [key: where]
- เย็น (yen) = cool  [key: cool]
- ร้อน (rɔ́ɔn) = hot  [key: hot]
- หรือ (rʉ̌ʉ) = or  [key: or]
- ชา (chaa) = tea  [key: tea]
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

**The target word is never an exception.** It is always in the list
above: the list holds everything known by the lesson that introduces the
word, and that includes the words of that lesson itself.

**One narrow exception: the polite particles.** ครับ, ค่ะ and คะ are not
in the list. They are not vocabulary in this course — they are a grammar
point, and grammar lives in a different master list that this briefing
does not draw from. They are allowed, and they are required wherever a
Thai speaker would really use one. Their forms are fixed and given under
"Voice, Particles and Pronouns" below, which is their only source. The
exception covers those three words and nothing else.

### Given names

A sentence about someone's name needs one: ฉันชื่อ … cannot be completed
without it, and neither can an answer to "what is your name". These are
the names you may write, with their transliteration:

- มาย (maai) — female
- ฝน (fǒn) — female
- ฟ้า (fáa) — female
- นัท (nát) — male
- ก้อง (gɔ̂ng) — male
- นนท์ (non) — male

That list is the only source for both the script and the transliteration.
**Any other name is forbidden**, including one you believe you know — and
if you find yourself needing a name that is not listed, write
` [uncertain]` rather than inventing one.

Use a name **only where the sentence genuinely needs one**: introducing
yourself, or answering a question about a name. Never as decoration, and
never to fill a subject that natural Thai would leave empty. A name is
reading material in Thai script, so every one you write costs the learner
something; it has to buy something back.

## Voice, Particles and Pronouns

Examples are read aloud by two fixed instruction voices, one female and
one male. Which of the two reads a given example follows from the
sentence itself: a sentence with ผม or ครับ is read by the male voice, any
other by the female one.

**You choose the division; you do not choose per sentence what feels
natural.** Give every example a `speaker_gender` — `female` or `male` —
and spread the two across the target words of this run. Then write each
sentence entirely within its own column.

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
list stops you from picking the wrong one. The `speaker_gender` on the
word does.

**A `speaker_gender` is a constraint, not an instruction to use a
pronoun.** Many natural Thai sentences have no first person and no final
particle at all — a plain description needs neither. Such a sentence
carries no gendered element, so it belongs to neither column and **does
not count towards the division**. Never bolt a pronoun or a particle onto
a sentence that does not want one in order to make it count.

**A particle goes where a Thai would really say one, and nowhere else.**
When addressing someone, answering, or asking: yes. For a plain
observation with no one being spoken to: no. Ending every example in ค่ะ
makes the sentences polite but also monotonous, and it hides the bare
sentence structure the learner is meant to see. Applied consistently, the
presence of a particle carries information instead of being decoration.

Do not translate the particle as a separate word in the English line. Its
politeness lives in the tone of the English sentence, or stays
untranslated. "yes, polite-particle" teaches the learner something false.

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

**Look up, never reconstruct.** You have exactly two sources, in this
order:

1. **"Available Vocabulary"** — for every word in the sentence.
2. **The table under "Voice, Particles and Pronouns"** — for ครับ, ค่ะ
   and คะ only.

There is no third source. Build the sentence transliteration by joining
the given forms.

**If a form is in neither source, mark it.** Write the transliteration
followed by ` [uncertain]`, for example `gaa-faae rɔ́ɔn [uncertain]`. Do
not guess. A human resolves the marking before seeding; the generator
refuses any document that still contains it, so an uncertain form cannot
silently reach the database.

Reaching for `[uncertain]` almost always means you are about to use a
word you are not allowed to use. Check "Available Vocabulary" first.

## Editorial Rules

### The sentence

- **The target word is the point of the sentence, not a passenger.** The
  example exists to show *this* word. A sentence in which the target word
  plays a supporting role next to something more interesting teaches the
  learner the wrong thing.
- **Short and natural.** A complete but short sentence, the way a Thai
  person would actually say it. Not an artificial telegram sentence, and
  not ten words to show one.
- **Self-contained.** It must make sense with nothing around it.
- **Only words from "Available Vocabulary"**, plus the three polite
  particles.

### What a canonical example must never contain

This section is the opposite of the corresponding rule for Language
Notes, where examples are deliberately anchored to the lesson dialogue.
Both are correct within their own ownership. Here the sentence outlives
the lesson, so:

- **No personal names except the ones under "Given names", and only
  where the sentence needs one.** Any other name ties a permanent card to
  a scene it has nothing to do with, and puts Thai script in front of the
  learner that was never taught. Where no name is needed, use a pronoun
  or leave the subject out as natural Thai often does.
- **No reference to a scene, a situation or a conversation.** There is no
  scene. Nothing "just happened".
- **No reference to the course itself** — no "as you saw", no "the polite
  form you learned earlier", no "in this lesson". The card does not know
  where the learner is.
- **No sentence that reads as one turn of a dialogue.** A question is
  fine; a question that clearly expects the answer to appear next is not.

### The translation

- **Natural English, faithful to the Thai.** Say what the sentence means
  in ordinary English. No word-for-word glossing in the translation line.
- **Compatible with `english_gloss`.** If the card says the word means
  "like" and the translation turns it into "would like", one of the two
  is wrong. This is the most common silent inconsistency on a vocabulary
  card, precisely because both halves look fine on their own.
- **One sentence, no explanation.** Structure is explained in Language
  Notes, not in a translation.

## Output Contract

Return one JSON object. These are the only permitted fields at every
level — **any other field is a hard error** and the generator refuses the
document. An unexpected field is the first sign that a prompt has
drifted, which is why it fails loudly rather than being ignored.

### Document

| Field | Required | Value |
| --- | --- | --- |
| `examples` | yes | non-empty array, one entry per target word |

There is no other field at document level.

### Example

| Field | Required | Value |
| --- | --- | --- |
| `source_key` | yes | copied literally from "Target Words" |
| `example_key` | yes | `e1` |
| `thai_script` | yes | the Thai sentence |
| `paiboon` | yes | transliteration, forms copied from the sources |
| `translation_en` | yes | natural English |

### Keys

Both key fields are **required**, and together they are the identity of a
row. Note that they use **different** shapes, and that is not cosmetic —
the generator checks both, so a wrong shape fails immediately instead of
three lessons later.

- **`source_key`** follows the master vocabulary list: lower-case
  letters, digits and **underscores** (`thank_you`, `i_male`). Never
  hyphens. Copy it; do not invent one.
- **`example_key`** uses lower-case letters, digits and **hyphens**. It
  is unique within the word, not globally. Every word gets exactly one
  example, so the value is always `e1`.

### One example per word

Exactly one entry per target word. Two entries with the same
`source_key` is a hard error and the generator refuses the document.

If a word seems to need a second sentence — usually because it has a
second function — that second function does not belong on the card at
all. It is handled elsewhere, by a human, and not by you.

### Fields that must not appear

| Field | Why |
| --- | --- |
| `display_order` | The array order **is** the screen order. The generator refuses the field, precisely so nobody assumes it does something. |
| `lesson_key` | A canonical example belongs to the word, not to a lesson. A lesson field in the source data invites a lesson-bound sentence. |
| `audio_url` | Output of a later step, generated from the frozen text. |
| `voice_key` | Empty means "use the fixed default female voice", not "unknown". A value here invites variation where there is nothing to choose. |
| anything else | Unknown fields are a hard error. |

### Complete example

Illustrative — not the content of any real lesson. Every Paiboon form in
it was copied from the project's master vocabulary list, so the shape is
safe to imitate.

```json
{
  "examples": [
    {
      "source_key": "water",
      "example_key": "e1",
      "thai_script": "ฉันดื่มน้ำค่ะ",
      "paiboon": "chǎn dʉ̀ʉm náam kâ",
      "translation_en": "I drink water."
    },
    {
      "source_key": "food",
      "example_key": "e1",
      "thai_script": "อาหารอร่อยไหมคะ",
      "paiboon": "aa-hǎan à-rɔ̀i mǎi ká",
      "translation_en": "Is the food delicious?"
    },
    {
      "source_key": "market",
      "example_key": "e1",
      "thai_script": "ผมไปตลาดครับ",
      "paiboon": "pǒm bpai dtà-làat kráp",
      "translation_en": "I'm going to the market."
    },
    {
      "source_key": "teacher",
      "example_key": "e1",
      "thai_script": "คุณเป็นครูไหมครับ",
      "paiboon": "kun bpen kruu mǎi kráp",
      "translation_en": "Are you a teacher?"
    },
    {
      "source_key": "milk",
      "example_key": "e1",
      "thai_script": "นมหวานมาก",
      "paiboon": "nom wǎan mâak",
      "translation_en": "The milk is very sweet."
    }
  ]
}
```

The five together cover every case. `water` and `food` are
`speaker_gender: female` — a statement in ค่ะ and a question in คะ.
`market` and `teacher` are `speaker_gender: male` — a statement and a
question, both in ครับ, with ผม as the first person where there is one.
`milk` carries no gendered element at all: nobody is being addressed, so
it gets no particle and no pronoun, whichever `speaker_gender` it was
assigned.

Note that `example_key` is `e1` in all five, and that is correct rather
than a slip. The key is unique **within its word**, so five words with
`e1` are five distinct rows — the identity of a row is the pair
(`source_key`, `example_key`). Since every word gets exactly one example,
`e1` is the only value that ever occurs.

In all five the target word is what the sentence is about, no name
appears, nothing refers to a scene, and every sentence is readable on its
own.

## Corrections

When you are asked to change something afterwards, return the **complete
document** again, not a fragment or a diff.

Keep every `source_key` and `example_key` attached to its own object,
including when the order changes. Replacing a sentence means changing the
text and keeping `example_key` as `e1` — that updates the existing row.
A new key would insert a second row and leave the old one orphaned with
its audio attached.

## Self-Check Before Answering

Verify all of these before you produce output:

1. There is exactly one entry for every word in "Target Words", and no
   entry for any other word.
2. No `source_key` appears twice.
3. Every word in every sentence appears in "Available Vocabulary", except
   ครับ, ค่ะ and คะ.
4. Every Paiboon form was copied from "Available Vocabulary" or from the
   particle table. Nothing reconstructed.
5. No `kh`, `th` or `ph` anywhere in the transliteration.
6. Every tone mark stands exactly where its source put it — none added,
   none dropped.
7. No `[uncertain]` remains — if one does, you used a word you should not
   have used.
8. Every sentence stays entirely inside one column, and never takes one
   form from each: ผม goes with ครับ, ฉัน goes with ค่ะ or คะ. Both
   columns are used across the run — not every gendered sentence is the
   same one.
9. Within `speaker_gender: female`, statements end in ค่ะ (`kâ`) and
   questions in คะ (`ká`) — never the other way around.
10. No pronoun and no particle was added to a sentence that does not
    want one, and not every sentence ends in a particle.
11. No personal name other than one from "Given names", and none at all
    in a sentence that does not need one. No reference to a scene, a
    conversation, a lesson or the course.
12. Every sentence is understandable with nothing around it.
13. In every sentence the target word is what the sentence is about.
14. Every translation is natural English and agrees with the
    `english_gloss` of its word.
15. `example_key` is `e1` everywhere; every `source_key` was copied
    literally and matches `^[a-z0-9]+(_[a-z0-9]+)*$`.
16. No `display_order`, no `lesson_key`, no `audio_url`, no `voice_key`,
    no other unlisted field.

## Output Rules

- Return the JSON document inside a single ```json code block.
- Return nothing else: no explanation, no commentary, no summary, no
  second version, no markdown rendering of the examples alongside it.
- Do not describe your reasoning or the checks you performed.
- The document must be valid JSON. Escape double quotes inside strings;
  keep Thai script and tone marks as literal characters, never as
  `\u`-escapes.

