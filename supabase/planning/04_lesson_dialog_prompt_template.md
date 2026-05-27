# Lesson dialogue prompt template

Gebruik dit template nadat je het JSON-resultaat uit de blueprint-assembler hebt opgehaald.
Vervang alle placeholders met concrete waarden uit het lesson_blueprint JSON-object.

---

You are generating Thai A1 curriculum dialogue content.

TASK
Create the dialogue for lesson {{lesson_key}}.

LESSON GOAL
This is a {{cefr_level}} dialogue lesson.
Lesson title: {{lesson_title}}
Lesson subtitle: {{subtitle}}

The communicative goal is:
{{communicative_goal}}

CURRICULUM CONSTRAINTS
Use only the lesson content below as the teaching core.

Required vocabulary:
{{required_vocabulary_list}}

Previously introduced vocabulary allowed for reuse:
{{allowed_review_vocabulary_list}}

Required phrases:
{{required_phrases_list}}

Required grammar:
{{required_grammar_list}}

Patterns:
{{required_patterns_list_or_none}}

CONTINUITY CONTEXT
Speaker A:

- Name: {{speaker_a_name}}
- Character key: {{speaker_a_key}}
- Role summary: {{speaker_a_role_summary}}
- Age impression: {{speaker_a_age_impression}}
- Default tone: {{speaker_a_default_tone}}
- Default usage: {{speaker_a_default_usage}}

Speaker B:

- Name: {{speaker_b_name}}
- Character key: {{speaker_b_key}}
- Role summary: {{speaker_b_role_summary}}
- Age impression: {{speaker_b_age_impression}}
- Default tone: {{speaker_b_default_tone}}
- Default usage: {{speaker_b_default_usage}}

Relationship context:

- start_state: {{start_state}}
- current_stage: {{current_stage}}
- function_summary: {{function_summary}}
- allowed_progression: {{allowed_progression}}

Relationship rules:
{{relationship_rules_list}}

DIALOGUE DESIGN

- Scene type: {{scene_type}}
- Suggested location: {{suggested_location}}
- Allowed register: {{allowed_register}}
- Estimated line count: {{estimated_line_count}}

Constraints:
{{dialogue_constraints_list}}

VOCABULARY CONTROL
New vocabulary for this lesson:
{{must_use_new_list}}

Previously introduced vocabulary allowed for reuse:
{{may_reuse_previous_list}}

Vocabulary restriction:
{{must_avoid_rule}}

QUALITY RULES

- CEFR {{cefr_level}} only.
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
5. English translation
