# Thai A1 dialogue workflow guide

This guide describes a repeatable workflow for building Thai A1 lesson dialogues with a strict separation between curriculum data, planning data, and AI generation output. The workflow keeps the database as the source of truth, uses views and builder queries as derived planning layers, and stores final approved dialogue content separately from temporary generation work. PostgreSQL views are intended to expose reusable query results, `CREATE OR REPLACE VIEW` is the standard way to update a view definition, and `jsonb_build_object()` is appropriate when a compact JSON planning object is needed for QA or machine-readable inspection.

## Workflow goal

The goal is to create one dialogue per lesson from existing curriculum and continuity data without turning a lesson blueprint into a separate persistent source of truth. The working rule is simple: curriculum and continuity live in tables, planning is rebuilt from queries, and only finalized dialogue output is written to `dialogs`.

The workflow now supports a practical intermediate planning format: a flat blueprint export stored as CSV. CSV is used as a human-friendly bridge between SQL output and the lesson-specific prompt file, while the prompt itself remains a Markdown document that is easier to read and edit in a split-screen workflow.

## The three layers

### 1. Curriculum database

These tables remain the content source of truth:

- `lessons`
- `vocabulary_master`
- `vocabulary_status`
- `phrase_master`
- `phrase_status`
- `grammar_master`
- `grammar_status`
- `pattern_master`
- `pattern_status`
- `lesson_vocabulary`
- `lesson_phrase`
- `lesson_grammar`
- `lesson_pattern`

These tables remain the continuity source of truth:

- `character_profiles`
- `relationship_pairs`
- `relationship_pair_rules`

### 2. Content planning

This is the derived working layer:

- lesson blueprint query output
- continuity context query output
- flat blueprint CSV export
- prompt template
- lesson-specific prompt
- QA checks

Nothing in this layer is a new source of truth. Planning is rebuilt from tables or views each time, which matches the purpose of SQL views as reusable query abstractions rather than authoritative content stores.

### 3. AI generation

This is the output layer:

- `dialogs`
- `revisions`
- generation drafts and review notes in files

Use `dialogs` for the final approved lesson dialogue. Use `revisions` only for revision output or revision summaries, not as version control for multiple draft dialogues.

## Folder structure

```text
supabase/
  planning/
    01_get_lesson_blueprint.sql
    02_get_continuity_context.sql
    03_build_dialog_lesson_blueprint.sql
    04_lesson_dialog_prompt_template.md
    blueprints/
      lesson_01_dialog_blueprint.csv
      lesson_02_dialog_blueprint.csv
    prompts/
      lesson_01_dialog_prompt.md
      lesson_02_dialog_prompt.md

  generation/
    dialogs/
      lesson_01/
        lesson_01_dialog_output.md
        lesson_01_dialog_review.md
      lesson_02/
        lesson_02_dialog_output.md
        lesson_02_dialog_review.md

  seed-data/
    app/
      core.seed.sql
    master/
      vocabulary_master.seed.sql
      grammar_master.seed.sql
      pattern_master.seed.sql
      phrase_master.seed.sql
    links/
      lesson_links.seed.sql
    dialogs/
      a1_dialog_01.seed.sql
      a1_dialog_02.seed.sql
```

### What goes where

| Folder        | Use                                                                    |
| ------------- | ---------------------------------------------------------------------- |
| `planning/`   | Queries, views, builder SQL, CSV blueprints, templates, lesson prompts |
| `generation/` | Model outputs, review notes, temporary drafts                          |
| `seed-data/`  | SQL that inserts or updates actual database content                    |

## Planning model

A flat builder query that returns one row with named columns is the default practical planning format for manual prompt filling, it exports cleanly to CSV and supports multi-line cells for vocabulary, grammar, phrases, rules, and constraints.

That means there are two valid planning outputs:

- a JSON blueprint, useful for structure inspection, QA, or machine-readable planning objects built with `jsonb_build_object()`
- a flat builder result, useful for CSV export and manual prompt filling in VS Code split screen

For the current workflow, the flat builder plus CSV export is the default working method.

## Step-by-step workflow per lesson

### Step 1 — Check that lesson base data exists

Confirm that the lesson exists in `lessons`, and that lesson links exist in `lesson_vocabulary`, `lesson_phrase`, `lesson_grammar`, and optionally `lesson_pattern`. A planning workflow is only reliable when the lesson-linked data is complete.

Example identity query for lesson 2:

```sql
select
  id,
  lesson_key,
  title,
  subtitle,
  cefr_level,
  lesson_type,
  sequence_number,
  section_key
from public.lessons
where sequence_number = 2
order by id
limit 1;
```

### Step 2 — Pull lesson content from curriculum tables (via lesson_blueprint_view and related lesson-link views)

Use the lesson-link tables as the instructional source:

- `lesson_vocabulary` + `vocabulary_master` + `vocabulary_status`
- `lesson_phrase` + `phrase_master` + `phrase_status`
- `lesson_grammar` + `grammar_master` + `grammar_status`
- optionally `lesson_pattern` + `pattern_master` + `pattern_status`

This layer remains relational source data, not prompt-ready text.

### Step 3 — Pull continuity context

Use only:

- `character_profiles`
- `relationship_pairs`
- `relationship_pair_rules`

Useful fields in `character_profiles` include:

- `character_key`
- `display_name`
- `display_name_thai`
- `role_summary`
- `age_impression`
- `default_tone`
- `default_usage`

`default_tone` alone is too thin as a continuity signal; role summary, age impression, and usage context help keep generated dialogue voice and interaction more consistent.[cite:12]

### Step 4 — Maintain `lesson_continuity_options_view`

Use a view to expose active relationship pairs and speaker data in one reusable place. PostgreSQL views are designed to behave like named queries, and `CREATE OR REPLACE VIEW` is the standard way to change the defining query while keeping the same view name.[cite:12][cite:9][cite:6]

Example pattern:

```sql
create or replace view public.lesson_continuity_options_view as
select
  rp.id as relationship_pair_id,
  rp.start_state,
  rp.current_stage,
  rp.function_summary,
  rp.allowed_progression,
  ...
from public.relationship_pairs rp
...
```

### Step 5 — Build the lesson blueprint

The builder query assembles lesson and continuity data into a planning result. A JSON blueprint is still valid when you want a compact nested object, because `jsonb_build_object()` creates JSONB from alternating key/value pairs.

However, the current recommended builder for daily work is a **flat builder query** that returns one row with named columns such as:

- lesson identity fields
- dialogue design fields
- speaker fields
- `required_vocabulary_list`
- `required_phrases_list`
- `required_grammar_list`
- `required_patterns_list`
- `relationship_rules_list`
- `dialogue_constraints_list`
- `must_use_new_list`
- `may_reuse_previous_list`
- `must_avoid_rule`

This flat output is easier to export as CSV and easier to use as a prompt-filling sheet.

### Step 6 — Export the flat builder to CSV

Export the one-row builder result as a CSV file into `planning/blueprints/`, for example:

- `planning/blueprints/lesson_02_dialog_blueprint.csv`

This CSV acts as an intermediate working layer between SQL output and the prompt. Multiline fields such as vocabulary, phrases, grammar, rules, or constraints should remain quoted CSV fields so that each block stays in one cell.[cite:239]

### Step 7 — Use the prompt template

Use `04_lesson_dialog_prompt_template.md` as the reusable template. The template is aligned to the flat CSV builder rather than a nested `prompt_render`.

Working rule:

- open the CSV blueprint on one side
- open the template on the other side
- create `planning/prompts/lesson_XX_dialog_prompt.md`
- replace every placeholder with the matching CSV column value
- paste multiline cells exactly as they appear, without CSV-only wrapping quotes

### Step 8 — Current prompt template structure

The prompt template should be organized around these sections:

- Task
- Lesson goal
- Curriculum core
- Continuity context
- Dialogue design
- Quality rules
- Output format
- CSV-to-prompt mapping checklist

The mapping should point directly from placeholders to flat CSV column names.

### Step 9 — Naming conventions in the builder

Use human-readable instructional labels in the final prompt text, even if the CSV column names remain technical. For example, the vocabulary restriction text should refer to **Required vocabulary** and **Previously introduced vocabulary allowed for reuse**, instead of internal names like `must_use_new` and `may_reuse_previous`.

Recommended wording for `must_avoid_rule`:

```text
Only use vocabulary from Required vocabulary and Previously introduced vocabulary allowed for reuse. Do not introduce additional vocabulary unless it is extremely basic and unavoidable for natural Thai.
```

Also use consistent neutral list names in the builder output:

- `required_phrases_list`
- `required_grammar_list`
- `required_patterns_list`

Avoid names like `required_patterns_list_or_none`, because phrases, grammar, and patterns can all be empty depending on lesson design.

### Step 10 — Generate the dialogue

Use the filled lesson-specific prompt to generate one or more dialogue candidates. Save draft outputs first in `generation/`, not directly in the database.

### Step 11 — QA before saving

Check every dialogue for at least these points:

- Does the scene match the lesson goal?
- Are all required target items present?
- Is there no important new grammar outside lesson scope?
- Are `ครับ`, `ค่ะ`, and `คะ` correct?
- Does the tone fit the character profiles?
- Does the interaction fit the relationship rules?
- Is the dialogue beginner-safe and short enough?
- Is transliteration consistent?
- Is the English translation faithful to the Thai?

### Step 12 — Save the final dialogue in `dialogs`

Create one seed file per approved dialogue under `seed-data/dialogs/`, for example `a1_dialog_02.seed.sql`. Final database writes belong in `seed-data/`, not in `planning/` or `generation/`.[cite:12]

Example pattern:

```sql
insert into public.dialogs (
  lesson_id,
  title,
  thai_text,
  transliteration,
  translation_en,
  register
) values (
  2,
  'Dialog 2 — ...',
  '...thai text...',
  '...transliteration...',
  '...translation...',
  'polite'
)
on conflict (lesson_id)
do update set
  title = excluded.title,
  thai_text = excluded.thai_text,
  transliteration = excluded.transliteration,
  translation_en = excluded.translation_en,
  register = excluded.register,
  updated_at = now();
```

### Step 13 — Add dialog seeds to `config.toml`

If dialogue seeds should run automatically on `db reset`, include the dialog path in `[db.seed].sql_paths`. Explicit seed paths and glob patterns are loaded in order during reset.

Recommended configuration:

```toml
[db.seed]
enabled = true
sql_paths = [
  "./seed-data/app/core.seed.sql",
  "./seed-data/master/vocabulary_master.seed.sql",
  "./seed-data/master/grammar_master.seed.sql",
  "./seed-data/master/pattern_master.seed.sql",
  "./seed-data/master/phrase_master.seed.sql",
  "./seed-data/links/lesson_links.seed.sql",
  "./seed-data/dialogs/*.sql"
]
```

### Step 14 — Run locally without reset

For small, controlled changes during development, run seed SQL manually in the SQL editor or with `psql` instead of resetting the whole database each time. Use `db reset` only when testing full reproducibility.

Practical rule:

- one small data fix or one new dialogue: run manually
- full reproducibility test: `supabase db reset`

## Prompt template reference

Below is the current recommended reusable prompt template.

```md
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
{{required_patterns_list}}

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
{{required_patterns_list}} <- required_patterns_list
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
```

## Practical checklist per new lesson

Use this short routine for every new dialogue:

1. Confirm the lesson and lesson links exist.
2. Pull vocabulary, phrases, grammar, and patterns.
3. Choose a suitable relationship pair.
4. Check character profiles and relationship rules.
5. Run the flat builder query.
6. Export the single-row result as CSV into `planning/blueprints/`.
7. Open the CSV and prompt template side by side.
8. Fill `planning/prompts/lesson_XX_dialog_prompt.md`.
9. Generate the dialogue.
10. Run QA.
11. Create a seed file in `seed-data/dialogs/`.
12. Run it locally.
13. Commit planning files, generation notes, and the seed file.
