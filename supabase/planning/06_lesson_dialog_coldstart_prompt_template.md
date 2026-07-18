# Lesson Dialogue Prompt Template (cold-start / new-chat variant)

Gebruik dit bestand in Stap 7 wanneer je **niet** in dezelfde chat zit
als waar je Stap 1 (de curriculumsequencer,
`05_curriculum_sequencer_prompt_template.md`) hebt gedraaid — bijvoorbeeld
een nieuwe dag, een andere sessie, of gewoon omdat je geen aannames wil
doen over wat het model nog "onthoudt". Dit bestand bevat de volledige
builder-query-output en maakt geen enkele aanname over voorkennis.

**Werk je wél nog in datzelfde gesprek als Stap 1?** Gebruik dan
`04_lesson_dialog_prompt_template.md` in plaats van dit bestand — dat is
de lichtgewicht standaardvariant die enkel bevat wat het model nog niet
heeft.

## Instructions

- Open the lesson blueprint CSV and this template side by side.
- Replace every placeholder with the value from the matching CSV column.
- For multi-line list fields, paste the complete cell content unchanged.
- Replace every placeholder before generation.

## Role

You are generating Thai A1 curriculum dialogue content.

## Task

Create the dialogue for lesson {{lesson_key}}.

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
- Aim for the estimated line count given in Dialogue Design — do not compress the dialogue below that target just to minimize word count. When multiple valid dialogues are possible within that target, prefer the version that stays inside required and previously-introduced vocabulary over one that adds extra unlisted words.
- Once a grammar point has been introduced in an earlier lesson, prefer applying it consistently in subsequent dialogues unless there is a clear pedagogical reason to deviate. Treat a boilerplate constraint carried over from an earlier lesson's spec as suspect if it contradicts a grammar point already taught — flag it instead of silently following it.
- Prefer natural variation in subject reference. Use explicit pronouns, omitted subjects, คุณ, or personal names according to what best fits the social context and the lesson objectives, rather than enforcing one style consistently.

## Lesson Goal

This is an {{cefr_level}} dialogue lesson.  
Lesson title: {{lesson_title}}  
Lesson subtitle: {{subtitle}}  
Learning focus: {{learning_focus}}  
Scene summary: {{scene_summary}}

## Curriculum Core

Use only the lesson content below as the teaching core.

### Required Vocabulary

{{required_vocabulary_list}}

### Previously Introduced Vocabulary Allowed for Reuse

{{allowed_vocabulary_list}}

### Required Phrases

{{required_phrases_list}}

### Previously Introduced Phrases Allowed for Reuse

{{allowed_phrases_list}}

### Required Grammar

{{required_grammar_list}}

### Previously Introduced Grammar Allowed for Reuse

{{allowed_grammar_list}}

### Patterns

{{required_patterns_list}}

### Previously Introduced Patterns Allowed for Reuse

{{allowed_patterns_list}}

### Vocabulary Restriction

Only use vocabulary from:

- Required vocabulary
- Previously introduced vocabulary allowed for reuse

Do not introduce additional vocabulary unless it is extremely basic and unavoidable for natural Thai.

### Concept Restriction

Treat any item listed under "Previously introduced ... allowed for reuse" (vocabulary, phrases, grammar, or patterns) as already known to the learner — it is not new and does not count as new content. Only introduce a phrase, grammar point, or pattern that is not in a required or previously-introduced list if it is extremely basic and unavoidable for natural Thai.

## Continuity Context

### Speaker A

- Name: {{speaker_a_name}}
- Thai script name: {{speaker_a_name_thai}}
- Character key: {{speaker_a_key}}
- Role summary: {{speaker_a_role_summary}}
- Age impression: {{speaker_a_age_impression}}
- Default tone:
  {{speaker_a_default_tone}}
- Default usage:
  {{speaker_a_default_usage}}

### Speaker B

- Name: {{speaker_b_name}}
- Thai script name: {{speaker_b_name_thai}}
- Character key: {{speaker_b_key}}
- Role summary: {{speaker_b_role_summary}}
- Age impression: {{speaker_b_age_impression}}
- Default tone:
  {{speaker_b_default_tone}}
- Default usage:
  {{speaker_b_default_usage}}

## Relationship Context

- Start state: {{start_state}}
- Current stage: {{current_stage}}
- Function summary: {{function_summary}}

### Allowed Progression

{{allowed_progression}}

### Relationship Rules

{{relationship_rules_list}}

## Dialogue Design

- Scene type: {{scene_type}}
- Suggested location: {{suggested_location}}
- Allowed register: {{allowed_register}}
- Estimated line count: {{estimated_line_count}}

### Constraints

{{dialogue_constraints_list}}

## Quality Rules

- Stay within CEFR {{cefr_level}}.
- Keep the dialogue within the estimated line count for this lesson ({{estimated_line_count}}) and beginner-safe.
- Use short, clear lines.
- Use one communicative move per line — a line does not have to be exactly one sentence. It may contain more than one short sentence when needed to fit a required word or phrase naturally, as long as it stays concise and beginner-readable. Multi-sentence lines become more natural and more expected as lessons progress past the early A1 phase.
- Keep the Thai natural but simple.
- Respect speaker characterization and relationship rules.
- Do not introduce important new grammar outside lesson scope.
- Do not introduce romance, intimacy, or inappropriate familiarity unless explicitly allowed.
- Do not add scene details that are not supported by the lesson blueprint.

## Dialogue Validation

Before producing the dialogue, verify that:

- Every required phrase appears at least once.
- Every required grammar point appears at least once.
- Every required vocabulary item appears at least once, unless it is already contained inside a required phrase.
- The lesson goal is fully achieved.
- No prohibited vocabulary has been introduced unnecessarily.
- The dialogue follows the character roles and relationship rules.
- The dialogue is beginner-safe and matches the target line count in Dialogue Design — not just under it, but reasonably close to it.
- Required phrases are not repeated unnecessarily.

## Romanization Convention (Paiboon)

All Paiboon transliteration in this dialogue must strictly follow the Paiboon Publishing / ThaiDict romanization system. Do not use RTGS, IPA, or any other romanization convention, even if it looks more familiar.

- Unaspirated stops: ก = g, ต = dt, ป = bp
- Aspirated stops: ข, ค = k · ท, ถ = t · พ, ผ, ภ = p — never write "kh", "th", or "ph"
- ง = ng, จ = j, ช = ch
- Syllable-final ย is written "i" (not "y"); syllable-final ว is written "o" or "u" depending on the vowel pattern (not "w")
- For words with the อัว/อวย vowel pattern (e.g. สวย, ครัว, ช่วย, ป่วย), whether it is spelled with a single or double "u" cannot be derived from the script alone and varies per word. Match whatever spelling that exact word already has in the Required/Allowed Vocabulary lists above. If the word does not appear there, mark that transliteration as uncertain rather than guessing.

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

- Title must exactly match the lesson title.
- Subtitle must exactly match the lesson subtitle.
- Learning focus must exactly match the lesson learning focus.
- Scene summary must exactly match the lesson scene summary.
- Register must exactly match the register specified in Dialogue Design.
- Each block contains exactly one Thai line, one Transliteration line, and one English line.
- Every line within a block must carry a speaker label using the character name.
- Blocks must be numbered sequentially starting from 1.
- Keep the dialogue within the estimated line count for this lesson while satisfying all lesson requirements — do not artificially shorten it below that target.
- Do not explain your reasoning.
- Do not add notes, commentary, metadata, or extra sections.
- Follow the Romanization Convention above exactly for every Transliteration line; do not fall back to RTGS or IPA.

# CSV -> prompt mapping checklist

## lesson / goal

{{lesson_key}} <- lesson_key
{{cefr_level}} <- cefr_level
{{lesson_title}} <- lesson_title
{{subtitle}} <- subtitle
{{learning_focus}} <- learning_focus
{{scene_summary}} <- scene_summary

## curriculum core

{{required_vocabulary_list}} <- required_vocabulary_list
{{allowed_vocabulary_list}} <- allowed_vocabulary_list
{{required_phrases_list}} <- required_phrases_list
{{allowed_phrases_list}} <- allowed_phrases_list
{{required_grammar_list}} <- required_grammar_list
{{allowed_grammar_list}} <- allowed_grammar_list
{{required_patterns_list}} <- required_patterns_list
{{allowed_patterns_list}} <- allowed_patterns_list
{{must_avoid_rule}} <- must_avoid_rule

## continuity / speaker A

{{speaker_a_name}} <- speaker_a_name
{{speaker_a_name_thai}} <- speaker_a_name_thai
{{speaker_a_key}} <- speaker_a_key
{{speaker_a_role_summary}} <- speaker_a_role_summary
{{speaker_a_age_impression}} <- speaker_a_age_impression
{{speaker_a_default_tone}} <- speaker_a_default_tone
{{speaker_a_default_usage}} <- speaker_a_default_usage

## continuity / speaker B

{{speaker_b_name}} <- speaker_b_name
{{speaker_b_name_thai}} <- speaker_b_name_thai
{{speaker_b_key}} <- speaker_b_key
{{speaker_b_role_summary}} <- speaker_b_role_summary
{{speaker_b_age_impression}} <- speaker_b_age_impression
{{speaker_b_default_tone}} <- speaker_b_default_tone
{{speaker_b_default_usage}} <- speaker_b_default_usage

## relationship context

{{start_state}} <- start_state
{{current_stage}} <- current_stage
{{function_summary}} <- function_summary
{{allowed_progression}} <- allowed_progression
{{relationship_rules_list}} <- relationship_rules_list

## dialogue design

{{scene_type}} <- scene_type
{{suggested_location}} <- suggested_location
{{allowed_register}} <- allowed_register
{{estimated_line_count}} <- estimated_line_count
{{dialogue_constraints_list}} <- dialogue_constraints_list

## notes for manual filling

- Paste scalar values directly from the CSV cell.
- Paste multi-line list cells exactly as they appear.
- Do not paste quotes that belong only to CSV formatting.
- Replace every placeholder before generation.
