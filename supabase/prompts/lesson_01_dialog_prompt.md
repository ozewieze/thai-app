<!-- You are generating Thai A1 curriculum dialogue content.

TASK
Create the dialogue for lesson a1-dialog-01.

LESSON GOAL
This is an A1 dialogue lesson.
Lesson title: Dialog 1
Lesson subtitle: Greetings and introductions

The communicative goal is:
Say hello, ask someone's name, say your own name, and say nice to meet you.

CURRICULUM CONSTRAINTS
Use only the lesson content below as the teaching core.

Required vocabulary:

- สวัสดี (sà-wàt-dii) = hello
- คุณ (khun) = you
- ชื่อ (chʉ̂ʉ) = name
- อะไร (à-rai) = what
- ฉัน (chǎn) = I, female speaker
- ผม (phǒm) = I, male speaker

Previously introduced vocabulary allowed for reuse:

- none

Required phrases:

- คุณชื่ออะไร / ผมชื่อ... / ฉันชื่อ...
- ยินดีที่ได้รู้จัก

Required grammar:

- polite sentence-final particles: ครับ / ค่ะ

Patterns:

- none

CONTINUITY CONTEXT

Speaker A:

- Name: Mali
- Thai script name: มะลิ
- Character key: mali
- Role summary: Adult woman with a polished, professional-adjacent presence; organized and polite.
- Age impression: adult
- Default tone: calm, polite, organized, mature
- Default usage: workplace_adjacent_scenes, cafe_scenes, shopping, scheduling, introductions

Speaker B:

- Name: Narin
- Thai script name: นริน
- Character key: narin
- Role summary: Central anchor character; calm, socially capable, dependable, connector between groups.
- Age impression: adult
- Default tone: calm, approachable, socially_confident, believable
- Default usage: first_meetings, practical_daily_scenes, bridge_between_character_clusters

Relationship context:

- start_state: first_meeting
- current_stage: early
- function_summary: Opening introductions and polite small talk.
- allowed_progression: acquaintance, comfortable_contact, close_bond_or_subtle_romantic_potential

Relationship rules:

- Do not move this pair too quickly into intimacy; let familiarity develop over multiple lessons.
- This pair may begin the curriculum as a first meeting in greetings and introductions.
- Romantic potential must remain subtle and should not appear in early A1 lessons.

DIALOGUE DESIGN

- Scene type: first meeting
- Suggested location: quiet everyday setting
- Allowed register: formal_polite
- Estimated line count: 6-8 lines

Constraints:

- short lines only
- one communicative move per line
- beginner-safe Thai only
- Mali uses ฉัน
- Narin uses ผม
- use polite particles consistently
- no flirting or intimacy
- no important new grammar outside lesson scope

VOCABULARY CONTROL
New vocabulary for this lesson:

- สวัสดี (sà-wàt-dii) = hello
- คุณ (khun) = you
- ชื่อ (chʉ̂ʉ) = name
- อะไร (à-rai) = what
- ฉัน (chǎn) = I, female speaker
- ผม (phǒm) = I, male speaker

Previously introduced vocabulary allowed for reuse:

- none

Vocabulary restriction:
Do not introduce vocabulary outside must_use_new and may_reuse_previous unless extremely basic and unavoidable for natural Thai.

QUALITY RULES

- CEFR A1 only.
- Short, clear lines.
- One communicative move per line.
- Natural but simple Thai.
- No slang unless explicitly allowed.
- No flirting or intimacy in early lessons.
- Do not introduce important new grammar outside lesson scope.
- Respect all speaker and relationship guardrails.
- Keep the scene easy to understand for a beginner.

OUTPUT FORMAT
Return exactly:

1. Title
2. Register
3. Thai dialogue
4. Paiboon transliteration
5. English translation -->

# Lesson dialogue prompt template

Use this template with the lesson blueprint CSV.
Open the CSV blueprint on one side and this template on the other.
Replace every placeholder with the value from the matching CSV column.
For multi-line list fields, paste the full cell content as-is.

---

You are generating Thai A1 curriculum dialogue content.

## Task

Create the dialogue for lesson a1-dialog-01.

## Lesson goal

This is a A1 dialogue lesson.
Lesson title: Dialog 1
Lesson subtitle: Greetings and introductions
Learning focus: Say hello, ask someone's name, say your own name, and say nice to meet you.
Scene summary: A first, polite introduction between Mali and Narin in an everyday setting.

## Curriculum core

Use only the lesson content below as the teaching core.

Required vocabulary:

- สวัสดี (sà-wàt-dii) = hello
- คุณ (khun) = you
- ชื่อ (chʉ̂ʉ) = name
- อะไร (à-rai) = what
- ฉัน (chǎn) = I
- ผม (phǒm) = I

Required phrases:
Introduce yourself by name: คุณชื่ออะไร / ผมชื่อ... / ฉันชื่อ... — Asks someone’s name and gives your own name in a simple first-meeting exchange.

- Nice to meet you: ยินดีที่ได้รู้จัก — A polite formula used when meeting someone for the first time.

Required grammar:

- Polite sentence-final particles: Use ครับ and ค่ะ to make speech polite and socially appropriate.

Patterns:
none

Previously introduced vocabulary allowed for reuse:
none

Vocabulary restriction:
Do not introduce vocabulary outside must_use_new and may_reuse_previous unless extremely basic and unavoidable for natural Thai

## Continuity context

Speaker A:

- Name: {{speaker_a_name}}
- Thai script name: {{speaker_a_name_thai}}
- Character key: {{speaker_a_key}}
- Role summary: {{speaker_a_role_summary}}
- Age impression: {{speaker_a_age_impression}}
- Default tone:
  {{speaker_a_default_tone}}
- Default usage:
  {{speaker_a_default_usage}}

Speaker B:

- Name: {{speaker_b_name}}
- Thai script name: {{speaker_b_name_thai}}
- Character key: {{speaker_b_key}}
- Role summary: {{speaker_b_role_summary}}
- Age impression: {{speaker_b_age_impression}}
- Default tone:
  {{speaker_b_default_tone}}
- Default usage:
  {{speaker_b_default_usage}}

Relationship context:

- Start state: {{start_state}}
- Current stage: {{current_stage}}
- Function summary: {{function_summary}}
- Allowed progression:
  {{allowed_progression}}

Relationship rules:
{{relationship_rules_list}}

## Dialogue design

- Scene type: {{scene_type}}
- Suggested location: {{suggested_location}}
- Allowed register: {{allowed_register}}
- Estimated line count: {{estimated_line_count}}

Constraints:
{{dialogue_constraints_list}}

## Quality rules

- Stay within CEFR {{cefr_level}}.
- Keep the dialogue short and beginner-safe.
- Use short, clear lines.
- Use one communicative move per line.
- Keep the Thai natural but simple.
- Respect speaker characterization and relationship rules.
- Do not introduce important new grammar outside lesson scope.
- Do not introduce romance, intimacy, or inappropriate familiarity in early lessons unless explicitly allowed.

## Output format

Return exactly in this order:

1. Title
2. Register
3. Thai dialogue
4. Paiboon transliteration
5. English translation

---

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
