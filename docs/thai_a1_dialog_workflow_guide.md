# Thai A1 dialogue workflow guide

Deze handleiding beschrijft een eenvoudige, herhaalbare workflow om voor een Thai A1 curriculum-app dialogen op te bouwen, te genereren, te controleren en op te slaan. De workflow houdt drie lagen strikt gescheiden: curriculum database, content planning en AI generation. Seedbestanden in Supabase kunnen expliciet geconfigureerd worden via `sql_paths` en worden automatisch geladen bij `db reset`; losse seed-SQL kan ook handmatig worden uitgevoerd tijdens lokale ontwikkeling.[cite:430][cite:433]

## Doel van de workflow

De workflow is bedoeld om per les een dialoog te maken op basis van bestaande curriculumdata en bestaande continuity-data, zonder dat de lesson blueprint zelf een aparte bron van waarheid wordt. PostgreSQL views zijn hiervoor geschikt als afgeleide querylaag, en JSON-opbouw met `jsonb_build_object()` is geschikt om een compact planning-object samen te stellen voor prompts en QA.[cite:255][cite:317]

De drie lagen zijn:

- **Curriculum database**: vaste brondata en lesson links.
- **Content planning**: afgeleide blueprint en continuity-context.
- **AI generation**: prompt, dialoogoutput, opslag en latere revisie.

## Basisprincipe

Gebruik altijd de database als bron van waarheid voor lesinhoud en continuity. Bouw de blueprint per les opnieuw op uit bestaande data in plaats van die blueprint als aparte persistente waarheid op te slaan. Dat houdt je model logisch, reproduceerbaar en beter onderhoudbaar.[cite:470][cite:255]

## Overzicht van de drie lagen

### 1. Curriculum database

Dit zijn je inhoudelijke brontabellen:

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

Dit zijn je continuity-bronnen:

- `character_profiles`
- `relationship_pairs`
- `relationship_pair_rules`

### 2. Content planning

Dit is de afgeleide werklaag:

- lesson blueprint
- continuity-context
- prompt template
- lesson-specifieke prompt
- QA-checks

Hier zitten geen nieuwe waarheden in. Alles in deze laag moet opnieuw afleidbaar zijn uit curriculum- en continuity-data.[cite:255][cite:317]

### 3. AI generation

Dit is de outputlaag:

- `dialogs`
- `revisions`

Gebruik `dialogs` voor de finale, goedgekeurde dialoog per les. Gebruik `revisions` alleen voor revision-output of samenvattingen, niet als versiebeheer voor dialoogvarianten.

## Aanbevolen mapstructuur

Een duidelijke mapstructuur helpt om werkbestanden en definitieve seedbestanden uit elkaar te houden. Reusable prompt templates en gestandaardiseerde workflows werken beter als tussenstappen, templates en definitieve database-writes in aparte mappen blijven.[cite:467][cite:472]

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

### Wat hoort waar?

| Map | Gebruik |
|---|---|
| `planning/` | Queries, views, blueprint-opbouw, continuity-opbouw, templates |
| `generation/` | Prompt-output, model-output, reviewnotities, tijdelijke drafts |
| `seed-data/` | SQL die effectief data in tabellen schrijft of updatet |

## Stap-voor-stap workflow per les

## Stap 1 — Controleer of de basisdata bestaat

Controleer eerst of de les bestaat in `lessons`, en of de lesson links gevuld zijn in `lesson_vocabulary`, `lesson_phrase`, `lesson_grammar` en eventueel `lesson_pattern`. Een seed- of planningworkflow is pas betrouwbaar als de onderliggende lesson-linked data compleet is.[cite:430][cite:470]

Voor les 1 begin je met het ophalen van de lesidentiteit:

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
where sequence_number = 1
order by id
limit 1;
```

## Stap 2 — Haal lesson content op uit de curriculumtabellen

Gebruik de lesson-link tabellen als inhoudelijke bron. Dat betekent:

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

## Stap 3 — Haal continuity-context op

Gebruik hiervoor uitsluitend:

- `character_profiles`
- `relationship_pairs`
- `relationship_pair_rules`

Zorg dat `character_profiles` deze nuttige velden bevat:

- `character_key`
- `display_name`
- `display_name_thai`
- `role_summary`
- `age_impression`
- `default_tone`
- `default_usage`

Alleen `default_tone` is te beperkt als continuity-signaal; rol, leeftijdsindruk en gebruikscontext geven extra karakterconsistentie bij dialooggeneratie.[cite:370][cite:373]

## Stap 4 — Update of maak `lesson_continuity_options_view`

Gebruik een view om actieve relationship pairs en hun speakerdata op één plek beschikbaar te maken. PostgreSQL views zijn bedoeld als herbruikbare afgeleide querylaag bovenop tabellen.[cite:255]

Voorbeeld:

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

## Stap 5 — Bouw de lesson blueprint opnieuw op

Gebruik daarna een assembler-query, bijvoorbeeld `03_build_dialog_lesson_blueprint.sql`, om alle lesson- en continuity-data samen te brengen in één JSON-object. `jsonb_build_object()` is hiervoor geschikt omdat het gestructureerde sleutel-waardeobjecten uit SQL-data kan opbouwen.[cite:317][cite:318]

Belangrijk: de blueprint is een **planning-object**, geen aparte bron van waarheid.

Minimale blueprint-onderdelen:

- `lesson_identity`
- `content_scope`
- `continuity_context`
- `vocabulary_control`
- `dialogue_design`

Voorbeeld van het continuity-deel in de assembler:

```sql
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
)
```

## Stap 6 — Gebruik een vaste prompt-template

Gebruik een herbruikbaar prompt-templatebestand, bijvoorbeeld `04_lesson_dialog_prompt_template.md`, met placeholders die gevuld worden vanuit het blueprint JSON. Reusable prompt templates en expliciete placeholders maken generatie consistenter en minder foutgevoelig.[cite:467][cite:475]

Voorbeeld van continuity-placeholderblokken:

```md
Speaker A:
- Name: {{speaker_a_name}}
- Thai script name: {{speaker_a_name_thai}}
- Character key: {{speaker_a_key}}
- Role summary: {{speaker_a_role_summary}}
- Age impression: {{speaker_a_age_impression}}
- Default tone: {{speaker_a_default_tone}}
- Default usage: {{speaker_a_default_usage}}

Speaker B:
- Name: {{speaker_b_name}}
- Thai script name: {{speaker_b_name_thai}}
- Character key: {{speaker_b_key}}
- Role summary: {{speaker_b_role_summary}}
- Age impression: {{speaker_b_age_impression}}
- Default tone: {{speaker_b_default_tone}}
- Default usage: {{speaker_b_default_usage}}
```

## Stap 7 — Houd een mapping checklist bij

Maak onder of naast je template een mapping checklist die exact zegt welk JSON-veld naar welke placeholder gaat. Dat maakt je workflow later veel overzichtelijker.[cite:467][cite:472]

Voorbeeld:

```md
## continuity_context.speaker_a
{{speaker_a_name}} <- continuity_context.speaker_a.display_name
{{speaker_a_name_thai}} <- continuity_context.speaker_a.display_name_thai
{{speaker_a_key}} <- continuity_context.speaker_a.character_key
{{speaker_a_role_summary}} <- continuity_context.speaker_a.role_summary
{{speaker_a_age_impression}} <- continuity_context.speaker_a.age_impression
{{speaker_a_default_tone}} <- continuity_context.speaker_a.default_tone[]
{{speaker_a_default_usage}} <- continuity_context.speaker_a.default_usage[]
```

## Stap 8 — Vul de les-specifieke prompt in

Maak per les een promptbestand in `planning/prompts/`, bijvoorbeeld `lesson_01_dialog_prompt.md`. Vul daar het template met de concrete blueprintdata van die les.[cite:467][cite:475]

Voor les 1 leidde dat tot een compacte first-meeting prompt met:

- greeting
- self-introduction
- asking the other person’s name
- polite particles
- beginner-safe Thai
- no flirting or intimacy

## Stap 9 — Genereer de dialoog

Gebruik de prompt om één of meer kandidaatdialogen te genereren. Bewaar werkversies bij voorkeur eerst in `generation/`, niet direct in de database.

Voor les 1 werd de finale compacte versie:

```text
มะลิ: สวัสดีค่ะ
นริน: สวัสดีครับ
มะลิ: ฉันชื่อมะลิค่ะ
มะลิ: คุณชื่ออะไรคะ
นริน: ผมชื่อนรินครับ
นริน: ยินดีที่ได้รู้จักครับ
มะลิ: ยินดีที่ได้รู้จักค่ะ
```

## Stap 10 — QA voor je opslaat

Controleer elke dialoog minstens op deze punten:

- past de scène bij de lesson goal?
- zijn alle verplichte target items aanwezig?
- is er geen belangrijke nieuwe grammar buiten de les?
- kloppen `ครับ / ค่ะ / คะ`?
- past de toon bij de character profiles?
- past de relatie bij `relationship_pair_rules`?
- is de dialoog beginner-proof en niet te lang?
- is transliteratie consistent?
- is de Engelse vertaling trouw aan het Thai?

## Stap 11 — Sla de finale dialoog op in `dialogs`

Gebruik een eigen seedbestand per dialoog onder `seed-data/dialogs/`, bijvoorbeeld `a1_dialog_01.seed.sql`. Finale databasewrites horen in `seed-data/`, niet in `planning/` of `generation/`.[cite:430][cite:470]

Voorbeeld:

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

## Stap 12 — Voeg dialog seeds toe aan `config.toml`

Als je wilt dat dialog-seeds automatisch meelopen bij `db reset`, moet de dialogmap opgenomen zijn in `[db.seed].sql_paths`. Seedpaden worden expliciet en in volgorde geladen tijdens een reset.[cite:430][cite:433]

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
  "./seed-data/dialogs/*.sql"
]
```

Een globpatroon voor `dialogs/*.sql` is handig als je veel dialogen gaat toevoegen, omdat je dan niet telkens de TOML hoeft aan te passen.[cite:430]

## Stap 13 — Lokaal uitvoeren zonder reset

Tijdens lokale ontwikkeling hoef je niet telkens `supabase db reset` te doen. Voor kleine, gecontroleerde wijzigingen kun je seed-SQL ook gewoon handmatig uitvoeren in de SQL editor of via `psql`. Dat is minder ingrijpend en sneller dan resetten.[cite:438][cite:445]

Praktische regel:

- wijziging aan bestaande data of één nieuwe dialoog: handmatig uitvoeren
- volledige reproduceerbaarheid testen: `db reset`

## Seedbeleid voor `core.seed.sql`

Als je seedbestanden later opnieuw wilt kunnen draaien zonder unique-conflicts, gebruik dan bij voorkeur `insert ... on conflict (...) do update` voor tabellen met unieke sleutels zoals `character_key`. Dat maakt je seeds veiliger herbruikbaar op bestaande data.[cite:433][cite:430]

Voor `character_profiles` is dat handiger dan losse inserts, zeker nadat `display_name_thai` werd toegevoegd.

## Praktische checklist per nieuwe les

Gebruik deze korte routine voor elke nieuwe dialoog:

1. Controleer of de les en lesson links bestaan.
2. Haal vocabulary, phrases, grammar en patterns op.
3. Kies een geschikt relationship pair.
4. Controleer character profiles en relationship rules.
5. Bouw de blueprint opnieuw op.
6. Vul het prompt-template in.
7. Genereer de dialoog.
8. Doe QA.
9. Maak een seedbestand in `seed-data/dialogs/`.
10. Run dat lokaal handmatig.
11. Commit planningbestanden, generation-notes en seedbestand.

## Wat in de README kan

Ja, deze handleiding is geschikt om in een README of projectdocument te zetten. Een README is een goede plek voor een overzicht van workflow, mapstructuur, seedstrategie en stap-voor-stap proces, zodat toekomstige jij of andere bijdragers snel begrijpen hoe de dialoogpipeline werkt.[cite:467][cite:472]

Een praktische aanpak is:

- `README.md` = korte projectuitleg + samenvatting workflow
- `docs/dialog-workflow.md` = deze volledige gedetailleerde handleiding

Dat houdt je hoofd-README compact, terwijl de volledige werkinstructie toch bewaard blijft.
