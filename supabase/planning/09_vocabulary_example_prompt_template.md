# Vocabulary Example Prompt Template

Gebruik dit bestand om de canonieke voorbeelden bij de Vocabulary Cards
van één les te laten voorstellen. Het dekt Stap 3 tot en met Stap 5 van
`docs/thai_a1_vocabulary_workflow_guide.md`: het voorbeelddrieluik, de
Paiboon-conventies en de Engelse vertaling.

De output is **één JSON-document**, precies volgens het invoercontract
uit Stap 11, zodat het zonder tussenstap door
`scripts/generate-vocabulary-example-seed.mjs` kan.

**Eén template, geen planner en schrijver.** Bij de Language Notes
bestaan `07` en `08` naast elkaar omdat de verdeling concepten → notes
een oordeel is dat goedkeuring vraagt vóór er geschreven wordt. Hier valt
er niets te verdelen: elk doelwoord krijgt precies één voorbeeld
(vastgelegde beslissing 2) en de werklijst volgt rechtstreeks uit
`vocabulary_example_brief_view`. De twee goedkeuringsmomenten van de gids
verdwijnen daarmee niet — ze liggen vóór het invullen. Stap 1 (welke
woorden hebben een voorbeeld nodig) en Stap 2 (het woordbudget) keur je
goed op de output van de view, met de hand, voordat je hieronder één
placeholder vult. Een plannerprompt zou die twee alleen door een model
laten herformuleren.

**Dit template noemt de les nergens in het promptgedeelte.** Geen
`{{lesson_key}}`, geen lesnummer, geen "in this lesson". Dat is het
verschil met `08` en het is opzettelijk. Een canoniek voorbeeld is
lesneutraal (zie "De twee eigenaarschappen" in de gids), het
invoercontract kent geen `lesson_key`, en de brief-view laat de dialoog
er bewust uit. Wat het model niet weet te bestaan, kan het niet als anker
gebruiken. De les bestaat alleen in de bestandsnamen hieronder, als
archiveringslabel voor de batch.

**Dit template is bewust zelfstandig leesbaar.** Ook wanneer je in
dezelfde chat al iets anders voor deze les hebt gedaan, plak je de
woordenlijst met Paiboon volledig opnieuw. Reden: de dominante faalmodus
in dit project is Paiboon-reconstructie — op 2026-07-13 moesten 167
vocabulairerijen en 19 dialoogblokken van RTGS naar Paiboon gecorrigeerd
worden. Wat niet letterlijk in de directe context staat, wordt
gereconstrueerd.

## Instructions

- Draai de brief-view voor deze les en vul de placeholders hieronder in.
  De mapping-checklist onderaan geeft per placeholder de bijbehorende
  query.
- **Filter de werklijst op `needs_example = true`** vóór je hem plakt.
  Een woord dat zijn voorbeeld al heeft, mag het model niet zien: dan
  leest het `existing_examples` als "hier mag iets bij", en dat is een
  tweede voorbeeld op hetzelfde woord — een fout, geen aanvulling.
- Sla de ingevulde prompt op als
  `supabase/prompts/vocabulary-examples/a1_dialog_XX_examples_prompt.md`.
- Sla de modeloutput op als
  `supabase/generation/vocabulary-examples/a1_dialog_XX_examples.json`.
  Die naam ligt vast: de generator leidt hem af uit `--lesson`.
- Vervang **elke** placeholder vóór je genereert.

**Taalregel voor alle prompttemplates:** Nederlands boven en onder de
prompt, Engels erbinnen. De invulinstructies en de mapping-checklist zijn
voor jou en blijven Nederlands; alles tussen `## Role` en het einde van
`## Output Rules` gaat naar het model en is Engels. Zie "Taal van de
prompttemplates" in `docs/thai_a1_dialog_workflow_guide.md`.

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

{{target_words}}

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

{{example_vocabulary_budget}}

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
one male. Choosing which voice reads which sentence is **not your job** —
a later step works that out from the finished sentence. Your job is to
make sure the sentence is internally consistent, so that whichever voice
it gets is the right one.

**You choose the division; you do not choose per sentence what feels
natural.** Give every example a `speaker_gender` — `female` or `male` —
and spread the two across the target words of this run. Then write each
sentence entirely within its own column. The `speaker_gender` is not a
field you return: ครับ or ค่ะ in the sentence already says which one it
is.

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
followed by ` [uncertain]`, for example `gaa-fɛɛ rɔ́ɔn [uncertain]`. Do
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

### The sentences in one run must differ in more than their nouns

Read your own set before you return it. If most of the sentences share a
single frame with only the object swapped — `[pronoun] + [verb] +
[noun] + [particle]`, five times over, all translated "I'll have X" —
then the cards teach the learner one thing five times instead of five
things once.

This is the failure this section exists to prevent, and it is not
hypothetical: in one lesson four of six cards came back as exactly that
frame. Nothing else was wrong with them. The Paiboon was right, the
bundles were right, every word was inside the budget — which is why no
mechanical check caught it and why you have to look.

Two distinctions matter.

**Frame overlap is arithmetic, not a fault.** In an early lesson the
budget may hold three verbs and five nouns. Sentences will resemble each
other, and forcing variety that the budget cannot carry is worse than
the resemblance. **Point overlap is the fault:** two cards built around
the same verb with a different object, teaching the same thing twice.

**The budget always wins.** Never reach outside "Available Vocabulary"
to make a sentence look different, and never bolt on a pronoun or a
particle for variety — those rules are absolute and this one is not.
Within the budget, the usual room is: a question instead of a statement
(using a question word the learner already has), a describing sentence
with no first person at all, a less obvious noun or verb from the
budget, or a different position for the target word in the sentence. If
the budget genuinely offers no room, keep the sentences and say nothing
— a correct repetitive set beats an invented word.

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
| `voice_key` | Output of the same later step. The audio script derives the voice from the sentence itself and then records which one read it; nothing reads this field to pick a voice. A value here would be a report about a recording that does not exist yet. |
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
14. The transliteration of the target word inside the sentence is
    character for character the form given for that word in "Available
    Vocabulary" — not a variant of it.
15. Every translation is natural English and agrees with the
    `english_gloss` of its word.
16. **Read the whole set side by side.** No two cards make the same
    point with only the object swapped, and the set as a whole is not
    one frame repeated. If the budget left no room for more variety,
    that is acceptable — but check that it really did not.
17. `example_key` is `e1` everywhere; every `source_key` was copied
    literally and matches `^[a-z0-9]+(_[a-z0-9]+)*$`.
18. No `display_order`, no `lesson_key`, no `audio_url`, no `voice_key`,
    no other unlisted field.

## Output Rules

- Return the JSON document inside a single ```json code block.
- Return nothing else: no explanation, no commentary, no summary, no
  second version, no markdown rendering of the examples alongside it.
- Do not describe your reasoning or the checks you performed.
- The document must be valid JSON. Escape double quotes inside strings;
  keep Thai script and tone marks as literal characters, never as
  `\u`-escapes.

# Brief-view -> prompt mapping checklist

Beide placeholders komen uit één view: `vocabulary_example_brief_view`.
De tabel hieronder zegt welke kolom bij welke placeholder hoort; de
queries eronder maken er de vorm van die je plakt.

Dump **niet** de hele rij om de prompt te vullen. Dat zijn dertig velden
per woord, inclusief identity-waarden die na een `db reset` verschuiven en
lesgebonden velden die het model naar de les wijzen. Op een
Windows-console komt het Thaise schrift er bovendien onleesbaar uit.
Bekijk de rij in Supabase Studio wanneer je hem wilt inspecteren; gebruik
de queries hieronder wanneer je invult.

| Placeholder | Bron |
| --- | --- |
| `{{target_words}}` | `vocabulary_example_brief_view.target_words`, gefilterd op `needs_example` |
| `{{example_vocabulary_budget}}` | `vocabulary_example_brief_view.example_vocabulary_budgets` |

## De eigennamen

**Hier valt niets in te vullen.** De lijst onder "Given names" in het
promptgedeelte is vast en staat er al; dezelfde zes namen staan letterlijk
in `08`. Deze sectie legt uit waarom dat zo is, en wat je moet doen als je
er later een toevoegt.

**Waarom een lijst en geen tabelkolom.** Een eigennaam hoort niet in
`vocabulary_master`. Mét leslink rendert de kaartquery hem als woordkaart
— die filtert nergens op, elke `lesson_vocabulary`-rij wordt een kaart —
en zonder leslink heeft hij geen `first_lesson_id` en komt hij in geen
enkel budget. Geen van beide werkt, en een eigennaam is ook geen woord dat
uitgelegd wordt.

**Waarom vast en niet per generatierun.** Een canoniek voorbeeld is
permanent en lesneutraal: het verschijnt ook in les 24. Een lijst die per
run verschilt, levert de leerling twee schrijfwijzen van dezelfde naam op
en brengt bij elke run opnieuw de kans op een gereconstrueerde
Paiboon-vorm. Eén roster over alle lessen neemt beide weg.

**Als je een naam toevoegt.** Drie voorwaarden, en de eerste is de
zwaarste:

- **De Paiboon komt uit een betrouwbare bron en niet uit je hoofd.** Er is
  geen masterlijst om hem tegen te controleren, dus dit is de enige plek
  in de hele keten waar een transliteratie ongecontroleerd binnenkomt.
- **Geen personage uit een dialoog.** `มะลิ` en `นริน` vallen daarmee af:
  een canoniek voorbeeld mag niet aan een scène gebonden zijn die de
  leerling in les 24 nooit gezien heeft.
- **Voeg hem op beide plaatsen toe**, in `09` én in `08`, in dezelfde
  vorm. Dat is de prijs van één roster in twee templates; er is geen
  gedeelde bron die het voor je doet.

**Herkomst van de huidige zes.** Met de hand aangeleverd op 2026-08-10,
uit kennis van het Thai. Twee ervan zijn wél te controleren en kloppen:
`ฝน` en `ฟ้า` staan als gewoon woord in `vocabulary_master` (`rain` =
`fǒn`, `sky` = `fáa`) en de vormen in de lijst zijn daaraan gelijk. De
andere vier — `มาย`, `นัท`, `ก้อง`, `นนท์` — komen in geen enkele
masterlijst voor en zijn dus nergens tegen na te lopen. Dat is geen fout
maar wel een open flank: blijkt een vorm later verkeerd, dan moeten alle
voorbeelden die hem gebruiken mee.

`{{lesson_key}}` bestaat hier niet. Dat is geen omissie — zie de vierde
alinea bovenaan dit bestand.

## De werklijst

```sql
select string_agg(
         format('- %s (%s) = %s  [key: %s]  ·  %s%s',
                w->>'thai_script', w->>'paiboon',
                w->>'english_gloss', w->>'source_key',
                w->>'part_of_speech',
                case when w->>'usage_note' is null then ''
                     else '  ·  ' || (w->>'usage_note') end),
         E'\n' order by (w->>'display_order')::int nulls first)
from public.vocabulary_example_brief_view v,
     lateral jsonb_array_elements(v.target_words) w
where v.lesson_key = 'a1-dialog-XX'
  and (w->>'needs_example')::boolean;
```

Het filter op `needs_example` staat in de query en niet in je hoofd. Wil
je zien wat je daarmee weglaat — en dus of dat terecht is — draai dan
dezelfde query met `not (w->>'needs_example')::boolean` en lees de
`existing_examples` van die woorden. Levert de eerste query niets op, dan
heeft elk doelwoord van deze les zijn voorbeeld al en is er hier niets te
doen.

**Plak niet de ruwe view-JSON.** Het is verleidelijk — `jsonb_pretty` geeft
een compleet object per woord — maar dat object draagt `vocabulary_id`,
`lesson_vocabulary_id` en `intro_lesson_id`, identity-waarden die na een
`db reset` verschuiven en die het contract nergens vraagt. Het draagt ook
`lesson_role`, `lesson_notes`, `requires_explanation` en
`existing_examples`, en dat is lesgebonden context die het model naar de
les wijst — precies wat dit template overal vermijdt. Bij
`existing_examples` is het scherper dan hinderlijk: een gevulde array
leest als "hier mag iets bij", en dat is een tweede voorbeeld op hetzelfde
woord.

Wil je toch liever JSON plakken, gebruik dan deze projectie in plaats van
de hele rij:

```sql
select jsonb_pretty(jsonb_agg(jsonb_build_object(
         'source_key',     w->>'source_key',
         'thai_script',    w->>'thai_script',
         'paiboon',        w->>'paiboon',
         'english_gloss',  w->>'english_gloss',
         'part_of_speech', w->>'part_of_speech',
         'usage_note',     w->>'usage_note')
       order by (w->>'display_order')::int nulls first))
from public.vocabulary_example_brief_view v,
     lateral jsonb_array_elements(v.target_words) w
where v.lesson_key = 'a1-dialog-XX'
  and (w->>'needs_example')::boolean;
```

Zes velden, en geen daarvan wijst naar een les.

## Het woordbudget

```sql
select string_agg(
         format('- %s (%s) = %s  [key: %s]',
                w->>'thai_script', w->>'paiboon',
                w->>'english_gloss', w->>'source_key'),
         E'\n' order by (w->>'intro_sequence_number')::int nulls last,
                        w->>'source_key')
from public.vocabulary_example_brief_view v,
     lateral jsonb_array_elements(v.example_vocabulary_budgets) b,
     lateral jsonb_array_elements(b->'words') w
where v.lesson_key = 'a1-dialog-XX';
```

Controleer vooraf dat er precies één budgetblok is, en dat de lijst
compleet is overgekomen:

```sql
select jsonb_array_length(example_vocabulary_budgets) as budget_blocks,
       example_vocabulary_budgets->0->>'intro_lesson_key' as intro_lesson,
       (example_vocabulary_budgets->0->>'word_count')::int as word_count
from public.vocabulary_example_brief_view
where lesson_key = 'a1-dialog-XX';
```

`budget_blocks` hoort **1** te zijn, en `word_count` hoort gelijk te zijn
aan het aantal regels dat de vorige query oplevert.

## Notities bij het invullen

- **Het model verdeelt de twee stemmen; jij controleert het evenwicht
  over de lessen heen.** Binnen één run kan het model zelf spreiden, en
  dat hoef je niet vooraf toe te wijzen: je ziet bij het nalezen meteen
  welke zin welke is, want ครับ of ค่ะ staat er gewoon in. Wat het model
  níet kan zien is de rest van het curriculum — het krijgt één les.
  Controleer daarom periodiek de verdeling over alles wat er al staat:

  ```sql
  select count(*) filter (where thai_script like '%ครับ%' or thai_script like '%ผม%') as male,
         count(*) filter (where thai_script like '%ค่ะ%' or thai_script like '%คะ%') as female,
         count(*) as totaal
  from public.vocabulary_examples;
  ```

  Het verschil tussen `male + female` en `totaal` zijn de zinnen zonder
  gegenderd element. Die horen er te zijn — zie vastgelegde beslissing 5 —
  en tellen niet mee in het evenwicht.
- **De vijf woorden in het voorbeelddocument mogen geen doelwoord zijn.**
  `water`, `food`, `market`, `teacher` en `milk` zijn met opzet gekozen:
  ze zijn in geen enkele bestaande les een doelwoord. Zou de illustratie
  een woord tonen waarvoor het model in diezelfde run een zin moet
  schrijven, dan geeft het die zin gewoon terug — en dan meet je hoe goed
  het kan kopiëren in plaats van of de prompt werkt. Dit is geen
  hypothetisch geval: de eerste versie van dit template gebruikte `tea`
  en `hot`, precies twee van de vier doelwoorden van les 3. Controleer dit
  opnieuw wanneer er lessen bijkomen, en verwissel de illustratie zodra
  een van deze vijf een doelwoord wordt.
- **Kort de woordenlijst niet in.** Hij groeit per les en dat is de
  bedoeling: elk woord dat je weglaat, is een woord dat het model niet
  mag gebruiken of gaat reconstrueren.
- **Neem de `*_id`-velden uit de view niet mee.** `lesson_vocabulary_id`,
  `vocabulary_id` en `intro_lesson_id` zijn identity-waarden die na een
  `db reset` kunnen verschuiven; het contract vraagt mastersleutels.
- **Neem `requires_explanation`, `existing_examples` en de lesmetadata
  niet mee.** Dat is redactionele context voor jou. In de prompt zouden
  ze het model naar de les wijzen, en dat is precies wat dit template
  vermijdt.
- **Meer dan één budgetblok is een alarm, geen werkwijze.** Elk doelwoord
  van een les wordt in die les geïntroduceerd — de state machine zet
  `first_lesson_id` op deze les of gooit een exception, en een woord dat
  later een tweede betekenis krijgt komt sinds 2026-08-07 als een eigen
  rij met een eigen `source_key` in de masterlijst. Twee blokken betekent
  dus dat er iets buiten de trigger om is gebeurd: een handmatige update
  op `vocabulary_status`, of de terugdraai-trigger uit `20260717120000`
  die `first_lesson_id` leeghaalde terwijl de leslinks bleven staan.
  Repareer de data; bouw er geen route omheen.
- **Een doelwoord met `intro_sequence_number` op null hoort niet in deze
  batch.** Zonder introductieles is er geen anker en dus geen budget. De
  gids: een woord dat nog nergens geïntroduceerd is, krijgt nog geen
  canonieke voorbeelden. Laat het weg en zoek uit waarom zijn status leeg
  is.
- **Verwerken van de output.** Vier commando's, maar niet vier stappen —
  twee ervan zijn instellingen van je PowerShell-venster en twee zijn het
  eigenlijke werk.

  Eenmalig, zodra je een PowerShell-venster opent. Ze gelden tot je dat
  venster sluit:

  ```powershell
  chcp 65001
  $env:PGCLIENTENCODING = "UTF8"
  ```

  Daarna per les:

  ```powershell
  node scripts/generate-vocabulary-example-seed.mjs --lesson a1-dialog-XX
  psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -f supabase/seed-data/vocabulary-examples/a1_dialog_XX_examples.seed.sql
  ```

  `node` leest je goedgekeurde JSON en schrijft er het seedbestand van;
  `psql -f` voert dat bestand uit tegen je lokale database.

  Twee dingen die **stil** misgaan, en daarom geen van beide optioneel
  zijn. Zonder `chcp 65001` en `PGCLIENTENCODING` kan Thais schrift
  onderweg beschadigen — je krijgt geen foutmelding, alleen verkeerde
  tekens in de database. En zet nooit een `\` aan het eind van een regel
  om hem voort te zetten: dat is bash-syntax, PowerShell doet er niets
  mee, psql krijgt zijn `-f` niet binnen en opent een interactieve sessie.
  Ook dat ziet er niet uit als een fout. Zie "psql op Windows" in
  `docs/thai_a1_dialog_workflow_guide.md`.

- **Faalt de generator met een contractfout, corrigeer dan de JSON of
  laat het model opnieuw genereren — bewerk het gegenereerde SQL-bestand
  nooit met de hand.** De meldingen noemen het pad in het document, dus
  `$.examples[2]: "source_key" = "thank-you" past niet op ...` wijst je
  naar het derde voorbeeld.

- **Wat de generator níet bewaakt:** dekking (het bestand mag twee van de
  vijf doelwoorden bevatten), een tweede voorbeeld dat via een ánder
  bestand binnenkomt, een niet-bestaande `source_key` (dat faalt pas bij
  het seeden, maar dan wel luid), en alle redactionele kwaliteit — het
  woordbudget, lesneutraliteit, of de Paiboon klopt, of de vertaling bij
  de gloss past, de bundel stem/partikel/eerste persoon, en of het
  doelwoord centraal staat. Dat is de checklist van Stap 8 van de gids,
  en die loop jij af.
