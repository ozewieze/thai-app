## Note plan for a1-dialog-01

Goedgekeurde versie, 2026-08-11. Dit is niet de ruwe plannerouput: drie
correcties zijn erin verwerkt en staan onderaan toegelicht onder
"Redactionele beslissingen". Deze versie gaat als `{{approved_note_plan}}`
naar `08_language_note_writer_prompt_template.md`.

### Note 1 — Introducing yourself when you meet someone

- note_key: a1-dialog-01-note-1
- Why these concepts together: Giving your name and saying "nice to meet
  you" are two halves of the same first encounter, and the learner uses
  them in the same breath. Neither is large enough to carry a note on its
  own at this point in the course.
- Concepts covered:
  - phrase / self_introduction_name — Introduce yourself by name
  - phrase / yin_di_thi_dai_ru_jak — Nice to meet you
- Block skeleton:
  1. paragraph — Anchor to ฉันชื่อมะลิค่ะ / "My name is Mali." and
     คุณชื่ออะไรคะ / "What is your name?". Introduce asking and giving a
     name as one paired exchange, and note that the pronoun changes with
     the speaker.
  2. formula — [pronoun] + ชื่อ + [name] = giving your own name.
  3. example_group — Giving your own name, 2 fresh examples showing the
     two first-person forms; speaker_gender: female, male.
  4. paragraph — Anchor to ยินดีที่ได้รู้จักครับ / "Nice to meet you."
     Introduce it as a fixed expression that closes a first meeting, used
     unchanged by both speakers apart from the polite particle.
  5. usage_tip — Tell the learner not to try to break the expression into
     words yet. It is the first unanalysable chunk in the course and the
     natural reaction is to decode it, get stuck, and assume something
     was missed.

### Note 2 — Speaking politely with ครับ, ค่ะ and คะ

- note_key: a1-dialog-01-note-2
- Why these concepts together: This note teaches the male/female
  politeness contrast itself, so both speaker bundles have to appear side
  by side rather than being picked up incidentally elsewhere.
- Concepts covered:
  - grammar / polite_particles_khrab_kha — Polite sentence-final
    particles
- Block skeleton:
  1. paragraph — Anchor to สวัสดีค่ะ / "Hello." and สวัสดีครับ /
     "Hello." Explain that Thai marks politeness with a particle at the
     end of the utterance, and that which particle you use depends on who
     is speaking.
  2. formula — [statement] + ค่ะ / ครับ = polite statement.
  3. paragraph — Explain that a female speaker uses ค่ะ in a statement
     but คะ in a question, while a male speaker uses ครับ for both. This
     is core explanation, not a footnote: the learner has just met both
     female forms in the dialogue.
  4. example_group — Statement and question endings, 3 examples with an
     intro naming the contrast: a female statement, the same speaker's
     question, and a male speaker asking that question; speaker_gender:
     female, female, male.
  5. usage_tip — One line pointing at the tone difference between ค่ะ and
     คะ, with both transliterations. Deliberately short: the course-level
     "how to use" section carries the explanation of tones and of reading
     the transliteration, so this only has to make the learner look.

## Coverage check

- grammar / polite_particles_khrab_kha — Note 2
- phrase / self_introduction_name — Note 1
- phrase / yin_di_thi_dai_ru_jak — Note 1

## Redactionele beslissingen

**1. Geen formule voor de vraagvorm.** De plannerouput bevatte
`คุณชื่ออะไร = asking someone's name`. Dat is geen formule: de notatie
eist `[slot] + vast element = functie`, en deze regel heeft geen enkel
slot — het is de zin zelf. Een schema van iets wat geen patroon is,
suggereert een regelmaat die er niet is. De vraagvorm wordt in de
openingsparagraaf van Note 1 uitgelegd en in Note 2 als voorbeeld
getoond; dat volstaat op dit punt in het curriculum.

**2. Drie notes teruggebracht naar twee.** ยินดีที่ได้รู้จัก kreeg in de
plannerouput een eigen note met een voorbeeldgroep. Die groep kan niet
bestaan: de enige twee mogelijke voorbeelden — ยินดีที่ได้รู้จักค่ะ en
ยินดีที่ได้รู้จักครับ — staan allebei letterlijk in de dialoog. Wat
overblijft is één alinea, en die hoort bij de eerste ontmoeting waar Note
1 al over gaat.

**3. Eén toegestane dialoogkopie, alleen in deze les.** Les 1 heeft zes
woorden en de dialoog van zeven regels verbruikt vrijwel elke zinvolle
combinatie ervan; er is geen eerdere les om naar te echoën. De enige
vraagvorm die de leerling kent is `คุณชื่ออะไร`, dus de vrouwelijke
vraag met คะ kan niet anders zijn dan de dialoogregel `คุณชื่ออะไรคะ`.

Blok 5 van Note 2 mag die regel daarom als voorbeeld gebruiken. Zonder
die uitzondering heeft de note geen enkel voorbeeld van คะ, en dan valt
juist het contrast weg waarvoor de note bestaat. De uitzondering geldt
voor dit ene voorbeeld in deze ene les en ontgrendelt verder niets: alle
andere voorbeelden zijn vers.

Wat wél vers moet zijn in datzelfde blok is de statement-tegenhanger —
`ฉันชื่อ[naam]ค่ะ` met een naam uit de vaste lijst, niet Mali.

**4. Note 2 heeft na de eerste schrijfronde één voorbeeldgroep in plaats
van twee.** De oorspronkelijke blokken 3 en 5 leverden allebei
`ฉันชื่อ…ค่ะ` / `ผมชื่อ…ครับ` op — met zes woorden bestaat er geen andere
beleefde mededeling — en dat waren dezelfde zinnen als in Note 1, alleen
met andere namen. Blok 3 is daarom vervallen. De overgebleven groep draagt
het hele contrast in drie voorbeelden, inclusief `คุณชื่ออะไรครับ`, dat
laat zien dat de mannelijke vorm níet verandert. `คุณชื่ออะไรครับ` staat
niet in de dialoog: daar stelt alleen Mali de vraag.

De blokken houden hun oorspronkelijke `block_key`: Note 2 loopt nu
`b1, b2, b4, b5, b6`. Dat gat is bedoeld. Een sleutel verhuist niet mee
met de volgorde, anders voegt de seed een nieuwe rij toe in plaats van de
bestaande te verplaatsen.

**5. Note 1 loopt bewust tot het blokplafond.** Vijf blokken is het
maximum voor lesfase 1–10, en de gids zegt dat een note die daartegenaan
loopt vrijwel zeker twee onderwerpen behandelt en gesplitst moet worden.
Dat klopt hier ook — Note 1 draagt twee phrases. Splitsen is toch niet de
juiste ingreep, om de reden onder punt 2: ยินดีที่ได้รู้จัก kan in deze les
geen eigen voorbeeldgroep krijgen, dus een losse note zou uit één alinea
bestaan en geen enkel voorbeeld dragen. Het alarm is terecht afgegaan en
de afweging is bewust gemaakt; dat is waar een plafond als alarm voor
dient en niet als verbod.
