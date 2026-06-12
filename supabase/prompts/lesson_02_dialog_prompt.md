# Lesson Dialogue Prompt Template

Use this template with the lesson blueprint CSV.

## Instructions

- Open the lesson blueprint CSV and this template side by side.
- Replace every placeholder with the value from the matching CSV column.
- For multi-line list fields, paste the complete cell content unchanged.
- Replace every placeholder before generation.

## Role

You are generating Thai A1 curriculum dialogue content.

## Task

Create the dialogue for lesson a1-dialog-02.

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
- When multiple valid dialogues are possible, choose the version that introduces the fewest additional Thai words.

## Lesson Goal

This is an A1 dialogue lesson.  
Lesson title: Dialog 2  
Lesson subtitle: Where are you going?
Learning focus: Ask where someone is going, invite them to do something together, and accept an invitation.  
Scene summary: Continuation of the first, polite introduction between Mali and Narin in an everyday setting. Narin asks where she is going and invites her for coffee.

## Curriculum Core

Use only the lesson content below as the teaching core.

### Required Vocabulary

- ที่ไหน (thîi-nǎi) = where
- ไป (bpai) = go
- ดื่ม (dʉ̀ʉm) = drink
- กาแฟ (gaa-faae) = coffee
- ได้ (dâai) = can
- ด้วยกัน (dûai-gan) = together

### Previously Introduced Vocabulary Allowed for Reuse

- คุณ (khun) = you
- ฉัน (chǎn) = I
- ชื่อ (chʉ̂ʉ) = name
- ผม (phǒm) = I
- สวัสดี (sà-wàt-dii) = hello
- อะไร (à-rai) = what

### Required Phrases

- none

### Required Grammar

- Subject omission when clear: Leave out the subject when context already makes it obvious.

### Patterns

Question with mai

### Vocabulary Restriction

Only use vocabulary from:

- Required vocabulary
- Previously introduced vocabulary allowed for reuse

Do not introduce additional vocabulary unless it is extremely basic and unavoidable for natural Thai.

## Continuity Context

### Speaker A

- Name: Mali
- Thai script name: มะลิ
- Character key: mali
- Role summary: Adult woman with a polished, professional-adjacent presence; organized and polite.
- Age impression: adult
- Default tone:
  - calm
  - polite
  - organized
  - mature
- Default usage:
  - workplace_adjacent_scenes
  - cafe_scenes
  - shopping
  - scheduling
  - introductions

### Speaker B

- Name: Narin
- Thai script name: นริน
- Character key: narin
- Role summary: Central anchor character; calm, socially capable, dependable, connector between groups.
- Age impression: adult
- Default tone:
  - calm
  - approachable
  - socially_confident
  - believable
- Default usage:
  - first_meetings
  - practical_daily_scenes
  - bridge_between_character_clusters

## Relationship Context

- Start state: first_meeting
- Current stage: early
- Function summary: Opening introductions and polite small talk.

### Allowed Progression

- acquaintance
- comfortable_contact
- close_bond_or_subtle_romantic_potential

### Relationship Rules

- lesson_1_can_start_here: This pair may begin the curriculum as a first meeting in greetings and introductions.
- keep_growth_gradual: Do not move this pair too quickly into intimacy; let familiarity develop over multiple lessons.
- no_fast_romance: Romantic potential must remain subtle and should not appear in early A1 lessons.

## Dialogue Design

- Scene type: first meeting
- Suggested location: quiet everyday setting
- Allowed register: formal polite
- Estimated line count: 6-8 lines

### Constraints

- short lines only
- one communicative move per line
- beginner-safe Thai only
- use polite particles consistently
- no flirting or intimacy
- no important new grammar outside lesson scope
- Mali uses ฉัน
- Narin uses ผม

## Quality Rules

- Stay within CEFR {{cefr_level}}.
- Keep the dialogue short and beginner-safe.
- Use short, clear lines.
- Use one communicative move per line.
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
- The dialogue is beginner-safe and stays within the target line count.
- Required phrases are not repeated unnecessarily.

## Output Format

Use these section headings exactly, in this order:

1. Title
2. Subtitle
3. Learning focus
4. Scene summary
5. Register
6. Thai dialogue
7. Paiboon transliteration
8. English translation

Return exactly these sections and no additional sections.

## Output Rules

- Title must exactly match the lesson title.
- Subtitle must exactly match the lesson subtitle.
- Learning focus must exactly match the lesson learning focus.
- Scene summary must exactly match the lesson scene summary.
- Register must exactly match the register specified in Dialogue Design.
- Thai dialogue must contain speaker labels using the character names.
- Paiboon transliteration must preserve line order exactly.
- English translation must preserve line order exactly.
- Keep the dialogue as short as possible while satisfying all lesson requirements.
- Do not explain your reasoning.
- Do not add notes, commentary, metadata, or extra sections.

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
{{required_phrases_list}} <- required_phrases_list
{{required_grammar_list}} <- required_grammar_list
{{required_patterns_list_or_none}} <- required_patterns_list_or_none
{{may_reuse_previous_list}} <- may_reuse_previous_list
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
