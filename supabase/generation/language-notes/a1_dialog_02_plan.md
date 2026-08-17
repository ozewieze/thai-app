## Note plan for a1-dialog-02

Goedgekeurde versie, 2026-08-11. Vier correcties op de plannerouput staan
onderaan toegelicht onder "Redactionele beslissingen". Deze versie gaat als
`{{approved_note_plan}}` naar `08_language_note_writer_prompt_template.md`.

### Note 1 — Saying where you are going and what you are going to do

- note_key: a1-dialog-02-note-1
- Why these concepts together: ไป is the word the whole dialogue turns on,
  and it does two jobs at once here — going to a place and going to do
  something. Both appear in the dialogue, so both are named; only the
  second can be practised with the words the learner has.
- Concepts covered:
  - grammar / movement_pai — Movement with ไป
- Block skeleton:
  1. paragraph — Anchor to ไปที่ไหนครับ / "Where are you going?" and
     ไปดื่มกาแฟค่ะ / "I am going to drink coffee." Introduce ไป as
     covering both: where someone is going, and what they are going to
     do. Say plainly that the second is the one being practised below.
  2. formula — ไป + [verb phrase] = going to do something.
  3. example_group — Going to do something, 2 fresh examples;
     speaker_gender: female, male.

### Note 2 — Asking yes/no questions with ไหม

- note_key: a1-dialog-02-note-2
- Why these concepts together: ไหม is a self-contained and highly
  productive question pattern that deserves its own compact note.
- Concepts covered:
  - pattern / statement_mai — Question with mai
- Block skeleton:
  1. paragraph — Anchor to ดื่มกาแฟด้วยกันไหมครับ / "Would you like to
     drink coffee together?". Explain that Thai does not reorder the
     sentence: the statement stays as it is and ไหม is added at the end.
  2. formula — [statement] + ไหม = yes/no question.
  3. example_group — Statements turned into questions, 2 fresh examples;
     speaker_gender: female, male.

### Note 3 — Saying something can be done with ได้

- note_key: a1-dialog-02-note-3
- Why these concepts together: ได้ appears in the dialogue only in its
  short standalone form, so the note has to supply the full construction
  itself and connect the two.
- Concepts covered:
  - pattern / verb_dai — Can do
- Block skeleton:
  1. paragraph — Anchor to ได้ค่ะ / "Yes, I'd like to." Explain that Mali
     is saying that it can be done, and that the full form puts ได้ after
     everything you can do. Present the standalone ได้ as the short
     answer form, not as a separate word.
  2. formula — [verb phrase] + ได้ = ability or possibility.
  3. example_group — ได้ after a complete verb phrase, 2 fresh examples;
     speaker_gender: male, female.
  4. usage_tip — ได้ goes at the very end, after the object, with the
     object between the verb and ได้. Describe the wrong order in
     English; do not write it out in Thai script.

### Note 4 — Thai often leaves out the subject

- note_key: a1-dialog-02-note-4
- Why these concepts together: This is a property of Thai sentences in
  general, not of any one word in this lesson, so it stands on its own
  and comes last — by then the learner has read several subjectless
  sentences without noticing.
- Concepts covered:
  - grammar / subject_omission_when_clear — Subject omission when clear
- Block skeleton:
  1. paragraph — Anchor to ไปดื่มกาแฟค่ะ / "I am going to drink coffee."
     Point out that there is no word for "I" in the Thai sentence, and
     that Thai leaves the subject out whenever the context already makes
     it obvious.
  2. example_group — Sentences whose subject is understood rather than
     stated, 2 fresh examples; speaker_gender: female, male.

## Coverage check

- grammar / movement_pai — Note 1
- grammar / subject_omission_when_clear — Note 4
- pattern / statement_mai — Note 2
- pattern / verb_dai — Note 3

## Redactionele beslissingen

**1. De plannerouput bundelde ไป en subjectweglating in één note van vijf
blokken.** Die is gesplitst. Formeel omdat vijf blokken het plafond is en
de gids zegt dat een note die daartegenaan loopt vrijwel zeker twee
onderwerpen behandelt — en anders dan bij les 1 was er hier geen dwingende
reden om samen te blijven: allebei de concepten hadden in dat plan al een
eigen paragraaf én een eigen voorbeeldgroep.

Inhoudelijk weegt zwaarder dat subjectweglating niets met ไป te maken
heeft. Élke regel van deze dialoog laat het onderwerp weg, ook ได้ค่ะ en
ดื่มกาแฟด้วยกันไหมครับ. Onder een ไป-titel gehangen lijkt het een
eigenschap van ไป, en de leerling die later terugzoekt met "waarom staat
er nooit 'ik' in het Thais" vindt hem daar niet.

**2. De open question over de plaatsbetekenis van ไป berustte op een
misverstand.** De plannerouput schrijft dat de dialoog vooral "going to do
something" toont, maar de eerste regel is `ไปที่ไหนครับ` — dat ís de
plaatsbetekenis, en hij staat er letterlijk. Uitstellen zou betekenen dat
je een dialoogregel onverklaard laat.

Toch krijgt de plaatsbetekenis geen eigen formule en geen eigen
voorbeeldgroep, en de reden is het woordbudget: er staat geen enkele
plaatsnaam in. Het enige plaatswoord is ที่ไหน, en dat is een vraagwoord.
Een groep over ไป + plaats zou uit varianten van de dialoogregel bestaan.
De paragraaf noemt de betekenis dus wel en veroordeelt hem tot uitleg; de
formule en de voorbeelden gaan over de betekenis die de leerling wél kan
oefenen. Zodra er plaatsnamen in het curriculum zitten, is dat de les om
het uit te breiden.

**3. De usage_tip bij ได้ is vervangen.** De plannerouput waarschuwde dat
"this note specifically teaches ได้ after a verb phrase" — dat is de cursus
die over zichzelf praat, en het herhaalde bovendien wat blok 1 al zei. De
tip draagt nu de echte valkuil: de positie ná de hele werkwoordgroep. Dat
is exact de fout die `pattern_master` tot 2026-08-11 zelf maakte met
`ได้ + VERB`.

**4. Na de schrijfronde: `e2` van Note 1 vervangen.** Het model leverde
`ฉันไปดื่มกาแฟค่ะ` en `ผมไปดื่มกาแฟครับ` — dezelfde zin met dezelfde
Engelse vertaling, alleen een andere genderbundel. Dat is één voorbeeld,
twee keer, en precies wat de schrijverprompt verbiedt met "never plan an
example that exists only to display a speaker_gender".

Note 4 had dezelfde fout en die is bij de eerste review gemist: `ชื่อฝนค่ะ`
en `ชื่อก้องครับ` waren ook één constructie met alleen een andere naam en
bundel. `e2` is `ดื่มกาแฟครับ` geworden, zodat de groep het weglaten toont
bij een naamzin én bij een handelingszin. `ชื่อฝนค่ะ` blijft staan omdat
les 1 diezelfde zin mét `ฉัน` heeft aangeleerd — de leerling heeft de
volledige vorm nog voor ogen.

Het botste bovendien met Note 4. Die verankert aan `ไปดื่มกาแฟค่ะ` en legt
uit dat er geen woord voor "ik" in staat, terwijl Note 1 er twee keer een
voornaamwoord aan toevoegde. `ไปดื่มกาแฟด้วยกันครับ` lost allebei op: de
groep toont ไป nu vóór twee verschillende werkwoordgroepen, en Note 1
draagt nog één voorbeeld met voornaamwoord — waardoor Note 4 een
aanvulling wordt in plaats van een tegenspraak.

**5. De ได้-tip toont de foute vorm niet.** De eerste versie eindigde op
"ดื่มกาแฟได้, not ดื่มได้กาแฟ". Die is vervangen door een beschrijving van
de juiste volgorde. Een `usage_tip` is platte tekst zonder doorhaling of
markering, dus de foute vorm staat er even leesbaar bij als de juiste,
voor een leerling die het schrift nog ontcijfert. Zie de regel bij
`usage_tip` in de workflowgids; die is hier op vastgelegd.

**6. Voorbeeldgroepen van twee in plaats van drie.** Het bruikbare budget
voor deze constructies is ongeveer negen woorden — ไป, ที่ไหน, ดื่ม, กาแฟ,
ด้วยกัน, ได้, คุณ, ฉัน, ผม; de rest van les 1 (ชื่อ, อะไร, สวัสดี)
combineert er nauwelijks mee. Twaalf werkelijk verschillende zinnen
daaruit halen zonder dialoogkopieën lukt niet; je krijgt varianten die
alleen in het partikel verschillen. Acht voorbeelden is haalbaar, en de
gids kent geen streefaantal — alleen een bereik van twee tot vier.
