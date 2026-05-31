# Lesson dialogue prompt template

Use this template with the lesson blueprint CSV.
Open the CSV blueprint on one side and this template on the other.
Replace every placeholder with the value from the matching CSV column.
For multi-line list fields, paste the full cell content as-is.

---

You are generating Thai A1 curriculum dialogue content.

## Task

Create the dialogue for lesson {{lesson_key}}.

## Lesson goal

This is a {{cefr_level}} dialogue lesson.
Lesson title: {{lesson_title}}
Lesson subtitle: {{subtitle}}
Learning focus: {{learning_focus}}
Scene summary: {{scene_summary}}

## Curriculum core

Use only the lesson content below as the teaching core.

Required vocabulary:
{{required_vocabulary_list}}

Required phrases:
{{required_phrases_list}}

Required grammar:
{{required_grammar_list}}

Patterns:
{{required_patterns_list_or_none}}

Previously introduced vocabulary allowed for reuse:
{{may_reuse_previous_list}}

Vocabulary restriction:
{{must_avoid_rule}}

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
