# Thai A1 dialogue workflow guide

Deze handleiding beschrijft een eenvoudige, herhaalbare workflow om voor een Thai A1 curriculum-app dialogen op te bouwen, te plannen, te genereren, te controleren en op te slaan.

De workflow houdt drie lagen gescheiden:

1. curriculum database
2. content planning
3. AI generation

De workflow gebruikt de database als bron van waarheid voor curriculum- en continuity-data, maar laat ook een beperkte les-specifieke specs-laag toe voor dialoogontwerp. Die specs-laag is geen duplicaat van curriculuminhoud, maar een kleine authoringlaag voor keuzes zoals learning focus, scène en extra constraints. Architectuurdocumentatie blijft alleen bruikbaar als ze aansluit op de actuele implementatie. [cite:1037][cite:1044]

## Doel van de workflow

De workflow is bedoeld om per les een dialoog te maken op basis van:

- bestaande curriculumdata;
- bestaande continuity-data;
- beperkte les-specifieke dialoogspecs.

De uiteindelijke dialoog wordt gegenereerd vanuit een samengesteld `lesson_blueprint` JSON-object. PostgreSQL views en `jsonb_build_object()` zijn geschikt om zo’n compact planning-object op te bouwen uit relationele data. [cite:1048]

## De drie lagen

### 1. Curriculum database

Vaste inhoudelijke en relationele brondata:

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
- `character_profiles`
- `relationship_pairs`
- `relationship_pair_rules`

### 2. Content planning

Afgeleide en authoringlaag:

- lesson blueprint assembler
- continuity-context view
- `dialog_blueprint_specs`
- prompt template
- lesson-specifieke prompt
- QA-checks

### 3. AI generation

Outputlaag:

- `dialogs`
- `revisions`

Gebruik `dialogs` voor de finale goedgekeurde dialoog per les. Gebruik `revisions` alleen voor revision-output of samenvattende afgeleiden, niet als versiebeheer voor meerdere kandidaatdialogen.

## Basisprincipe

Gebruik de database als bron van waarheid voor lesinhoud, vocabulary scope, continuity en relationship rules. Bouw de blueprint per les opnieuw op uit bestaande data en een kleine specs-tabel. De blueprint zelf is een planning-object, geen zelfstandige primaire waarheid. De expliciete keuzes in `dialog_blueprint_specs` zijn wel persistente authoring-inputs voor de blueprint-opbouw. Documenteer zulke beslissingen expliciet zodra het model verandert, zodat workflow en implementatie niet uit elkaar lopen. [cite:1041][cite:1044]

## Aanbevolen mapstructuur

```text
supabase/
  planning/
    01_get_lesson_blueprint.sql
    02_get_continuity_context.sql
    03_build_dialog_lesson_blueprint.sql
    04_lesson_dialog_prompt_template.md

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

  seed-data/
    app/
      core.seed.sql
      specs/
        a1_dialog_01_blueprint_specs.seed.sql
        a1_dialog_02_blueprint_specs.seed.sql
    master/
      vocabulary_master.seed.sql
      grammar_master.seed.sql
      pattern_master.seed.sql
      phrase_master.seed.sql
    links/
      lesson_links.seed.sql
    planning/
      dialog_blueprint_specs.seed.sql
    dialogs/
      a1_dialog_01.seed.sql
      a1_dialog_02.seed.sql
```

## Wat hoort waar?

### `planning/`

- queries
- views
- blueprint-opbouw
- continuity-opbouw
- templates

### `prompts/`

- per-les ingevulde promptbestanden

### `generation/`

- prompt-output
- model-output
- reviewnotities
- tijdelijke drafts

### `seed-data/`

- SQL die effectief data schrijft of update in tabellen

## Stap-voor-stap workflow per les

### Stap 1 — Controleer of de basisdata bestaat

Controleer eerst of de les bestaat in `lessons`, en of de lesson links gevuld zijn in:

- `lesson_vocabulary`
- `lesson_phrase`
- `lesson_grammar`
- eventueel `lesson_pattern`

Een plannings- of seedworkflow is pas betrouwbaar als de onderliggende lesson-linked data compleet is.

Voorbeeld:

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
where lesson_key = 'a1-dialog-01';
```

### Stap 2 — Haal lesson content op uit de curriculumtabellen

Gebruik de lesson-link tabellen als inhoudelijke bron.

Dat betekent:

- `lesson_vocabulary` + `vocabulary_master` + `vocabulary_status`
- `lesson_phrase` + `phrase_master` + `phrase_status`
- `lesson_grammar` + `grammar_master` + `grammar_status`
- optioneel `lesson_pattern` + `pattern_master` + `pattern_status`

Voorbeeld voor vocabulary:

```sql
select
  lv.lesson_id,
  lv.display_order,
  lv.role as lesson_role,
  lv.requires_explanation,
  lv.notes as lesson_notes,
  vm.id as vocabulary_id,
  vm.source_key,
  vm.thai_script,
  vm.paiboon,
  vm.english_gloss,
  vm.part_of_speech,
  vm.register,
  vm.usage_note,
  vs.status,
  vs.first_exposure_type,
  vs.first_lesson_id,
  vs.last_seen_lesson_id
from public.lesson_vocabulary lv
join public.vocabulary_master vm on vm.id = lv.vocabulary_id
left join public.vocabulary_status vs on vs.vocabulary_id = vm.id
where lv.lesson_id = :lesson_id
order by lv.display_order nulls last, lv.id;
```

### Stap 3 — Haal continuity-context op

Gebruik hiervoor uitsluitend:

- `character_profiles`
- `relationship_pairs`
- `relationship_pair_rules`

Zorg dat `character_profiles` minstens nuttige generatievelden bevat:

- `character_key`
- `display_name`
- `display_name_thai`
- `role_summary`
- `age_impression`
- `default_tone`
- `default_usage`

`default_tone` alleen is te beperkt als continuity-signaal; rol, leeftijdsindruk en gebruikscontext maken karakterconsistentie sterker.

### Stap 4 — Maak of update `lesson_continuity_options_view`

Gebruik een view om actieve relationship pairs en hun speakerdata op één plek beschikbaar te maken.

```sql
create or replace view public.lesson_continuity_options_view as
select
  rp.id as relationship_pair_id,
  rp.start_state,
  rp.current_stage,
  rp.function_summary,
  rp.allowed_progression,

  a.id as character_a_id,
  a.character_key as character_a_key,
  a.display_name as character_a_name,
  a.display_name_thai as character_a_name_thai,
  a.role_summary as character_a_role_summary,
  a.age_impression as character_a_age_impression,
  a.default_tone as character_a_default_tone,
  a.default_usage as character_a_default_usage,

  b.id as character_b_id,
  b.character_key as character_b_key,
  b.display_name as character_b_name,
  b.display_name_thai as character_b_name_thai,
  b.role_summary as character_b_role_summary,
  b.age_impression as character_b_age_impression,
  b.default_tone as character_b_default_tone,
  b.default_usage as character_b_default_usage,

  coalesce(
    jsonb_agg(
      jsonb_build_object(
        'rule_key', rpr.rule_key,
        'rule_text', rpr.rule_text
      )
      order by rpr.id
    ) filter (where rpr.id is not null),
    '[]'::jsonb
  ) as relationship_rules
from public.relationship_pairs rp
join public.character_profiles a on a.id = rp.character_a_id
join public.character_profiles b on b.id = rp.character_b_id
left join public.relationship_pair_rules rpr on rpr.relationship_pair_id = rp.id
where rp.is_active = true
group by
  rp.id,
  rp.start_state,
  rp.current_stage,
  rp.function_summary,
  rp.allowed_progression,
  a.id,
  a.character_key,
  a.display_name,
  a.display_name_thai,
  a.role_summary,
  a.age_impression,
  a.default_tone,
  a.default_usage,
  b.id,
  b.character_key,
  b.display_name,
  b.display_name_thai,
  b.role_summary,
  b.age_impression,
  b.default_tone,
  b.default_usage;
```

### Stap 5 — Maak of seed `dialog_blueprint_specs`

Gebruik `dialog_blueprint_specs` als kleine authoringlaag per les. Deze tabel bewaart niet de volledige curriculuminhoud, maar alleen de les-specifieke ontwerpkeuzes die niet logisch afleidbaar zijn uit de curriculum- en continuity-tabellen.

Aanbevolen tabel:

```sql
create table public.dialog_blueprint_specs (
  id bigint generated always as identity primary key,
  lesson_id bigint not null unique references public.lessons(id) on delete cascade,
  relationship_pair_id bigint not null references public.relationship_pairs(id),
  learning_focus text not null,
  scene_summary text not null,
  scene_type text,
  suggested_location text,
  allowed_register text,
  estimated_line_count text,
  extra_constraints jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (jsonb_typeof(extra_constraints) = 'array')
);
```

Voorbeeldseed voor les 1:

```sql
insert into public.dialog_blueprint_specs (
  lesson_id,
  relationship_pair_id,
  learning_focus,
  scene_summary,
  scene_type,
  suggested_location,
  allowed_register,
  estimated_line_count,
  extra_constraints
)
values (
  1,
  1,
  'Say hello, ask someone''s name, say your own name, and say nice to meet you.',
  'A first, polite introduction between Mali and Narin in an everyday setting.',
  'first meeting',
  'quiet everyday setting',
  'formal_polite',
  '6-8 lines',
  '[
    "Mali uses ฉัน",
    "Narin uses ผม"
  ]'::jsonb
);
```

### Stap 6 — Bouw de lesson blueprint opnieuw op

Gebruik een assembler-query, bijvoorbeeld `03_build_dialog_lesson_blueprint.sql`, om curriculumdata, continuitydata en dialogue specs samen te brengen in één JSON-object.

Belangrijk:

- de blueprint blijft een planning-object;
- de blueprint wordt opnieuw opgebouwd uit views en tabellen;
- `dialog_blueprint_specs` levert alleen de les-specifieke ontwerpinput.

Minimale blueprint-onderdelen:

- `lesson_identity`
- `content_scope`
- `continuity_context`
- `vocabulary_control`
- `dialogue_design`

```sql
select jsonb_build_object(
  'lesson_identity', jsonb_build_object(
    'lesson_id', lb.lesson_id,
    'lesson_key', lb.lesson_key,
    'lesson_title', lb.lesson_title,
    'subtitle', lb.subtitle,
    'cefr_level', lb.cefr_level,
    'lesson_type', lb.lesson_type,
    'sequence_number', lb.sequence_number,
    'section_key', lb.section_key,
    'is_published', lb.is_published
  ),

  'content_scope', jsonb_build_object(
    'all_vocabulary', lb.all_vocabulary,
    'new_vocabulary', lvc.new_vocabulary,
    'linked_previous_vocabulary', lvc.linked_previous_vocabulary,
    'all_phrases', lb.all_phrases,
    'all_grammar', lb.all_grammar,
    'all_patterns', lb.all_patterns
  ),

  'continuity_context', jsonb_build_object(
    'relationship_pair_id', lc.relationship_pair_id,
    'start_state', lc.start_state,
    'current_stage', lc.current_stage,
    'function_summary', lc.function_summary,
    'allowed_progression', lc.allowed_progression,

    'speaker_a', jsonb_build_object(
      'character_id', lc.character_a_id,
      'character_key', lc.character_a_key,
      'display_name', lc.character_a_name,
      'display_name_thai', lc.character_a_name_thai,
      'role_summary', lc.character_a_role_summary,
      'age_impression', lc.character_a_age_impression,
      'default_tone', lc.character_a_default_tone,
      'default_usage', lc.character_a_default_usage
    ),

    'speaker_b', jsonb_build_object(
      'character_id', lc.character_b_id,
      'character_key', lc.character_b_key,
      'display_name', lc.character_b_name,
      'display_name_thai', lc.character_b_name_thai,
      'role_summary', lc.character_b_role_summary,
      'age_impression', lc.character_b_age_impression,
      'default_tone', lc.character_b_default_tone,
      'default_usage', lc.character_b_default_usage
    ),

    'relationship_rules', lc.relationship_rules
  ),

  'vocabulary_control', jsonb_build_object(
    'must_use_new', lvc.new_vocabulary,
    'may_reuse_previous', lvc.linked_previous_vocabulary,
    'must_avoid_rule',
      'Do not introduce vocabulary outside must_use_new and may_reuse_previous unless extremely basic and unavoidable for natural Thai.'
  ),

  'dialogue_design', jsonb_build_object(
    'learning_focus', ds.learning_focus,
    'scene_summary', ds.scene_summary,
    'scene_type', ds.scene_type,
    'suggested_location', ds.suggested_location,
    'allowed_register', ds.allowed_register,
    'estimated_line_count', ds.estimated_line_count,
    'constraints',
      jsonb_build_array(
        'short lines only',
        'one communicative move per line',
        'beginner-safe Thai only',
        'use polite particles consistently',
        'no flirting or intimacy',
        'no important new grammar outside lesson scope'
      ) || coalesce(ds.extra_constraints, '[]'::jsonb)
  )
) as lesson_blueprint
from public.lesson_blueprint_view lb
join public.lesson_vocabulary_control_view lvc
  on lvc.lesson_id = lb.lesson_id
join public.dialog_blueprint_specs ds
  on ds.lesson_id = lb.lesson_id
join public.lesson_continuity_options_view lc
  on lc.relationship_pair_id = ds.relationship_pair_id
where lb.lesson_key = 'a1-dialog-01';
```

### Stap 7 — Gebruik een vaste prompt-template

Gebruik een herbruikbaar prompt-templatebestand, bijvoorbeeld `04_lesson_dialog_prompt_template.md`, met placeholders die gevuld worden vanuit `lesson_blueprint`.

Gebruik de actuele blueprintvelden. De prompt-template moet dus `learning_focus` en `scene_summary` gebruiken, niet de oude `communicative_goal`.

Voorbeeld:

```text
LESDOEL
Dit is een dialoogles op niveau {{cefr_level}}.
Les titel: {{lesson_title}}
Les ondertitel: {{subtitle}}

Leerfocus:
{{learning_focus}}

Scènesamenvatting:
{{scene_summary}}
```

### Stap 8 — Houd een mapping checklist bij

Maak onder of naast je template een mapping checklist die exact zegt welk JSON-veld naar welke placeholder gaat.

```text
## dialogue_design
{{learning_focus}} <- dialogue_design.learning_focus
{{scene_summary}} <- dialogue_design.scene_summary
{{scene_type}} <- dialogue_design.scene_type
{{suggested_location}} <- dialogue_design.suggested_location
{{allowed_register}} <- dialogue_design.allowed_register
{{estimated_line_count}} <- dialogue_design.estimated_line_count
{{dialogue_constraints_list}} <- dialogue_design.constraints[]
```

### Stap 9 — Vul de les-specifieke prompt in

Maak per les een promptbestand in `prompts/`, bijvoorbeeld `lesson_02_dialog_prompt.md`. Vul daar het template met de concrete blueprintdata van die les.

### Stap 10 — Genereer de dialoog

Gebruik de prompt om één of meer kandidaatdialogen te genereren. Bewaar werkversies eerst in `generation/`, niet direct in de database.

### Stap 11 — QA voor je opslaat

Controleer elke dialoog minstens op deze punten:

- past de scène bij de learning focus?
- zijn alle verplichte target items aanwezig?
- is er geen belangrijke nieuwe grammatica buiten de les?
- kloppen `ครับ` / `ค่ะ` / `คะ`?
- past de toon bij de character profiles?
- past de relatie bij `relationship_pair_rules`?
- is de dialoog beginner-proof en niet te lang?
- is transliteratie consistent?
- is de Engelse vertaling trouw aan het Thai?

### Stap 12 — Sla de finale dialoog op in `dialogs`

Gebruik een eigen seedbestand per dialoog onder `seed-data/dialogs/`, bijvoorbeeld `a1_dialog_02.seed.sql`.

```sql
insert into public.dialogs (
  lesson_id,
  title,
  thai_text,
  transliteration,
  translation_en,
  register
) values (
  1,
  'Dialog 1 — Greetings and introductions',
  'มะลิ: สวัสดีค่ะ
นริน: สวัสดีครับ
มะลิ: ฉันชื่อมะลิค่ะ
มะลิ: คุณชื่ออะไรคะ
นริน: ผมชื่อนรินครับ
นริน: ยินดีที่ได้รู้จักครับ
มะลิ: ยินดีที่ได้รู้จักค่ะ',
  'Mali: sà-wàt-dii khâ
Narin: sà-wàt-dii khráp
Mali: chǎn chʉ̂ʉ Mali khâ
Mali: khun chʉ̂ʉ à-rai khá
Narin: phǒm chʉ̂ʉ Narin khráp
Narin: yin-dii thîi dâai rúu-jàk khráp
Mali: yin-dii thîi dâai rúu-jàk khâ',
  'Mali: Hello.
Narin: Hello.
Mali: My name is Mali.
Mali: What is your name?
Narin: My name is Narin.
Narin: Nice to meet you.
Mali: Nice to meet you.',
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

### Stap 13 — Voeg seedpaths toe aan `config.toml`

Als je wilt dat seeds automatisch meelopen bij `db reset`, moet de relevante seedmap opgenomen zijn in `[db.seed].sql_paths`.

Aanbevolen configuratie:

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
  "./seed-data/planning/dialog_blueprint_specs.seed.sql",
  "./seed-data/dialogs/*.sql"
]
```

### Stap 14 — Lokaal uitvoeren zonder reset

Tijdens lokale ontwikkeling hoef je niet telkens `supabase db reset` te doen. Voor kleine gecontroleerde wijzigingen kun je seed-SQL ook handmatig uitvoeren in de SQL editor of via `psql`.

Praktische regel:

- wijziging aan bestaande specs of één nieuwe dialoog: handmatig uitvoeren
- volledige reproduceerbaarheid testen: `db reset`

## Praktische checklist per nieuwe les

- Controleer of de les en lesson links bestaan.
- Haal vocabulary, phrases, grammar en patterns op.
- Kies een geschikt relationship pair.
- Maak of update `dialog_blueprint_specs`.
- Controleer character profiles en relationship rules.
- Bouw de blueprint opnieuw op.
- Vul het prompt-template in.
- Genereer de dialoog.
- Doe QA.
- Maak een seedbestand in `seed-data/dialogs/`.
- Run dat lokaal handmatig.
- Commit planningbestanden, promptbestanden, generation-notes en seedbestanden.
