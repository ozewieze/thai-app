# Lesson Dialogue Prompt Template (same-chat continuation)

Gebruik dit bestand in Stap 7 wanneer je in dezelfde chat zit als waar
je Stap 1 (de curriculumsequencer,
`05_curriculum_sequencer_prompt_template.md`) hebt gedraaid. Het model
heeft in dat gesprek al gezien: lesdoel, scène, sprekers,
relatiecontext, scene_type/locatie/register/regelaantal, en zijn eigen
voorstel voor doelwoorden/phrases/grammatica/patterns. Dit bestand
herhaalt die data niet.

**Werk je in een nieuwe chat zonder die voorgeschiedenis?** Gebruik dan
`06_lesson_dialog_coldstart_prompt_template.md` in plaats van dit
bestand — dat bevat de volledige builder-query-output, zonder enige
aanname over voorkennis.

## Instructions

- Vul enkel de placeholders hieronder in met de finale, goedgekeurde
  waarden uit de Stap 5 builder-query-output
  (`03_build_dialog_lesson_blueprint.sql`).
- Deze lijsten zijn de finale, goedgekeurde versie — ze kunnen op
  details afwijken van het model's eigen voorstel uit Stap 1. Behandel
  ze als leidend, niet het eigen voorstel.
- Herhaal geen data die het model al kreeg in Stap 1 (Lesson Goal,
  Speaker A/B, Relationship Context, scene_type/locatie/register/
  regelaantal) — dat is overbodig en geeft risico op tegenstrijdige
  versies.

## Role

You already proposed this lesson's scene, target concepts, and
vocabulary selection earlier in this conversation, during the
curriculum sequencer step. You are now generating the actual Thai A1
dialogue text for that lesson.

## Task

Generate the dialogue for lesson {{lesson_key}}, using the final,
human-approved requirements below. These may differ slightly from your
own earlier proposal — treat the lists below as authoritative.

## Curriculum Priority Order

Apply these priorities in order:

1. Curriculum accuracy
2. Vocabulary control
3. Pattern visibility
4. Naturalness

## Pedagogical Preference

- The dialogue exists to teach the curriculum content, not to simulate realistic conversation.
- For early A1 lessons, prioritize clarity, pattern visibility, and learnability over conversational realism.
- Prefer pedagogical clarity over conversational naturalness when the two conflict.
- Keep the dialogue tightly aligned with the lesson goal and curriculum scope.
- Aim for the estimated line count already established for this lesson earlier in this conversation — do not compress the dialogue below that target just to minimize word count. When multiple valid dialogues are possible within that target, prefer the version that stays inside required and previously-introduced vocabulary over one that adds extra unlisted words.
- Once a grammar point has been introduced in an earlier lesson, prefer applying it consistently in subsequent dialogues unless there is a clear pedagogical reason to deviate. Treat a boilerplate constraint carried over from an earlier lesson's spec as suspect if it contradicts a grammar point already taught — flag it instead of silently following it.
- Prefer natural variation in subject reference. Use explicit pronouns, omitted subjects, คุณ, or personal names according to what best fits the social context and the lesson objectives, rather than enforcing one style consistently.

## Final Approved Requirements

These are the final, human-approved required lists for this lesson —
use them instead of your own earlier proposal wherever they differ.

### Required Vocabulary

{{required_vocabulary_list}}

### Required Phrases

{{required_phrases_list}}

### Required Grammar

{{required_grammar_list}}

### Required Patterns

{{required_patterns_list}}

### Vocabulary Restriction

Only use vocabulary from:

- Required Vocabulary above
- Vocabulary already established earlier in this conversation as previously introduced / already known (the "Already Introduced" and "Unused Candidate Pool" sections from the curriculum sequencer step)

Do not introduce additional vocabulary unless it is extremely basic and unavoidable for natural Thai.

### Concept Restriction

Treat every phrase, grammar point, or pattern already discussed earlier in this conversation as previously introduced or already known — none of that counts as new content. Only introduce something that is not in the Required lists above and was not already discussed as known if it is extremely basic and unavoidable for natural Thai.

## Additional Dialogue Constraints

These constraints apply on top of the scene, register, and location
already established earlier in this conversation. This list includes
constraints added after the sequencer step (such as one-off character
instructions from `dialog_blueprint_specs.extra_constraints`), so treat
it as authoritative even where it overlaps with earlier discussion.

{{dialogue_constraints_list}}

## Quality Rules

- Stay within CEFR A1.
- Keep the dialogue within the estimated line count already established for this lesson and beginner-safe.
- Use short, clear lines.
- Use one communicative move per line — a line does not have to be exactly one sentence. It may contain more than one short sentence when needed to fit a required word or phrase naturally, as long as it stays concise and beginner-readable. Multi-sentence lines become more natural and more expected as lessons progress past the early A1 phase.
- Keep the Thai natural but simple.
- **Polite particles follow the speaker, and the female forms are not interchangeable.** A female speaker ends a statement with ค่ะ and a question with คะ — it is ชอบเค้กไหม**คะ**, never ไหม**ค่ะ**. A male speaker uses ครับ for both. Keep each speaker's pronoun and particle in the same column: ผม goes with ครับ, ฉัน goes with ค่ะ or คะ, and never one form from each. Each character's gender is fixed by the continuity context already established in this conversation, so this is not a choice — it follows from who is speaking.
- Respect speaker characterization and relationship rules already established earlier in this conversation.
- Do not introduce important new grammar outside lesson scope.
- Do not introduce romance, intimacy, or inappropriate familiarity unless explicitly allowed.
- Do not add scene details that are not supported by the lesson blueprint.

## Dialogue Validation

Before producing the dialogue, verify that:

- Every required phrase above appears at least once.
- Every required grammar point above appears at least once.
- Every required vocabulary item above appears at least once, unless it is already contained inside a required phrase.
- The lesson goal already established earlier in this conversation is fully achieved.
- No prohibited vocabulary has been introduced unnecessarily.
- The dialogue follows the character roles and relationship rules already established earlier in this conversation.
- The dialogue is beginner-safe and matches the target line count already established — not just under it, but reasonably close to it.
- Required phrases are not repeated unnecessarily.
- Every polite particle matches its speaker, and every female question ends in คะ rather than ค่ะ.
- Every tone mark in the transliteration was copied, not invented, and none was dropped.

## Romanization Convention (Paiboon)

All Paiboon transliteration in this dialogue must strictly follow the Paiboon Publishing / ThaiDict romanization system. Do not use RTGS, IPA, or any other romanization convention, even if it looks more familiar.

- Unaspirated stops: ก = g, ต = dt, ป = bp
- Aspirated stops: ข, ค = k · ท, ถ = t · พ, ผ, ภ = p — never write "kh", "th", or "ph"
- ง = ng, จ = j, ช = ch
- Syllable-final ย is written "i" (not "y"); syllable-final ว is written "o" or "u" depending on the vowel pattern (not "w")
- Tone marks exactly as the source records them — none added, none dropped. Mid tone is written without a mark in Paiboon, so "a mark on every syllable" is not the rule; copying faithfully is. A transliteration with the marks stripped out is not "nearly done", it is wrong — and inventing a mark to make a syllable look complete is equally wrong.
- For words with the อัว/อวย vowel pattern (e.g. สวย, ครัว, ช่วย, ป่วย), whether it is spelled with a single or double "u" cannot be derived from the script alone and varies per word. Match whatever spelling that exact word already has in the Required Vocabulary list above or elsewhere in this conversation. If the word does not appear there, mark that transliteration as uncertain rather than guessing.

## Output Format

Use these section headings exactly, in this order:

1. Title
2. Subtitle
3. Learning focus
4. Scene summary
5. Register
6. Blocks

For the Blocks section, output one numbered block per dialogue line, using exactly this format:

Block 1
Thai: [Thai line with speaker label]
Transliteration: [Paiboon transliteration with speaker label]
English: [English translation with speaker label]

Block 2
Thai: ...
Transliteration: ...
English: ...

Return exactly these sections and no additional sections.

## Output Rules

- Title must exactly match the lesson title already established earlier in this conversation.
- Subtitle must exactly match the lesson subtitle already established earlier in this conversation.
- Learning focus must exactly match the lesson learning focus already established earlier in this conversation.
- Scene summary must exactly match the lesson scene summary already established earlier in this conversation.
- Register must exactly match the register already established earlier in this conversation.
- Each block contains exactly one Thai line, one Transliteration line, and one English line.
- Every line within a block must carry a speaker label using the character name.
- Blocks must be numbered sequentially starting from 1.
- Keep the dialogue within the estimated line count already established for this lesson while satisfying all lesson requirements — do not artificially shorten it below that target.
- Do not explain your reasoning.
- Do not add notes, commentary, metadata, or extra sections.
- Follow the Romanization Convention above exactly for every Transliteration line; do not fall back to RTGS or IPA.

# Builder-query -> prompt mapping checklist

Enkel deze kolommen uit `03_build_dialog_lesson_blueprint.sql` zijn
nodig voor dit bestand — de rest van de builder-query-output is al
gedekt door het Stap 1-gesprek en hoeft niet herhaald te worden.

{{lesson_key}} <- lesson_key
{{required_vocabulary_list}} <- required_vocabulary_list
{{required_phrases_list}} <- required_phrases_list
{{required_grammar_list}} <- required_grammar_list
{{required_patterns_list}} <- required_patterns_list
{{dialogue_constraints_list}} <- dialogue_constraints_list

## Notities bij het invullen

- Vul alleen deze zes velden in.
- Plak multiline-cellen exact zoals ze zijn, zonder de regels te
  herschikken.
- Plak geen aanhalingstekens die alleen bij de CSV-opmaak horen.
- Vervang elke placeholder vóór je genereert.
