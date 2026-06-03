You are generating Thai A1 curriculum dialogue content.

## Task

Create the dialogue for lesson a1-dialog-01.

## Curriculum priority order

1. Curriculum accuracy
2. Vocabulary control
3. Pattern visibility
4. Naturalness

## Pedagogical preference

- The dialogue exists to teach the curriculum content, not to simulate realistic conversation.
- For early A1 lessons, prioritize clarity, pattern visibility, and learnability over conversational realism.
- Prefer pedagogical clarity over conversational naturalness when the two conflict.
- Keep the dialogue tightly aligned with the lesson goal and curriculum scope.
- When multiple valid dialogues are possible, choose the version that introduces the fewest additional Thai words.

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
Only use vocabulary from Required vocabulary and Previously introduced vocabulary allowed for reuse. Do not introduce additional vocabulary unless it is extremely basic and unavoidable for natural Thai.

## Continuity context

Speaker A:

- Name: Mali
- Thai script name: มะลิ
- Character key: mali
- Role summary: Adult woman with a polished, professional-adjacent presence; organized and polite.
- Age impression: Adult
- Default tone:
  - calm
  - polite
  - organized
  - mature

- Default usage:
  - workplace adjacent scenes
  - cafe scenes
  - shopping
  - scheduling
  - introductions

Speaker B:

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
  - bridge_between_character_clusters,

Relationship context:

- Start state: first meeting
- Current stage: early
- Function summary: Opening introductions and polite small talk.
- Allowed progression:
- acquaintance
- comfortable contact
- close bond or subtle romantic potential

Allowed progression

- acquaintance
- comfortable_contact
- close bond or subtle romantic potential

Relationship rules:

- lesson 1 can start here: This pair may begin the curriculum as a first meeting in greetings and introductions.
- keep growth gradual: Do not move this pair too quickly into intimacy; let familiarity develop over multiple lessons.
- no fast romance: Romantic potential must remain subtle and should not appear in early A1 lessons.

## Dialogue design

- Scene type: First meeting
- Suggested location: quiet everyday setting
- Allowed register: formal polite
- Estimated line count: 6 - 8 lines

Constraints:

- short lines only
- one communicative move per line
- beginner-safe Thai only
- use polite particles consistently
- no flirting or intimacy
- no important new grammar outside lesson scope
- Mali uses ฉัน
- Narin uses ผม"

## Quality rules

- Stay within CEFR A1.
- Keep the dialogue short and beginner-safe.
- Use short, clear lines.
- Use one communicative move per line.
- Keep the Thai natural but simple.
- Respect speaker characterization and relationship rules.
- Do not introduce important new grammar outside lesson scope.
- Do not introduce romance, intimacy, or inappropriate familiarity unless explicitly allowed.
- Do not add scene details that are not supported by the lesson blueprint.

## Dialogue validation

Before producing the dialogue, verify that:

- Every required phrase appears at least once.
- Every required grammar point appears at least once.
- Every required vocabulary item appears at least once, unless it is already contained inside a required phrase.
- The lesson goal is fully achieved.
- No prohibited vocabulary has been introduced unnecessarily.
- The dialogue follows the character roles and relationship rules.
- The dialogue is beginner-safe and stays within the target line count.
- Required phrases are not repeated unnecessarily.

## Output format

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

## Output rules

- Title must be the lesson title exactly.
- Subtitle must be the lesson subtitle exactly.
- Learning focus must be the lesson learning focus exactly.
- Scene summary must be the lesson scene summary exactly.
- Register must be the value from Dialogue design exactly.
- Thai dialogue must contain speaker labels using the character names.
- Paiboon transliteration must preserve line order exactly.
- English translation must preserve line order exactly.
- Keep the dialogue as short as possible while still satisfying all lesson requirements.
- Do not explain your reasoning.
- Do not add notes, commentary, or metadata outside the required output.

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
