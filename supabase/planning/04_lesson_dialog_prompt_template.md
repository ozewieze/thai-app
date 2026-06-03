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
- When multiple valid dialogues are possible, choose the version that introduces the fewest additional Thai words.

## Lesson Goal

This is a {{cefr_level}} dialogue lesson.  
Lesson title: {{lesson_title}}  
Lesson subtitle: {{subtitle}}  
Learning focus: {{learning_focus}}  
Scene summary: {{scene_summary}}

## Curriculum Core

Use only the lesson content below as the teaching core.

### Required Vocabulary

{{required_vocabulary_list}}

### Required Phrases

{{required_phrases_list}}

### Required Grammar

{{required_grammar_list}}

### Patterns

{{required_patterns_list}}

### Previously Introduced Vocabulary Allowed for Reuse

{{may_reuse_previous_list}}

### Vocabulary Restriction

Only use vocabulary from:

- Required vocabulary
- Previously introduced vocabulary allowed for reuse

Do not introduce additional vocabulary unless it is extremely basic and unavoidable for natural Thai.

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
