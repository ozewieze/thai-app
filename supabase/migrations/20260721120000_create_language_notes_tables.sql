begin;

-- =========================================================
-- Language Notes: lesson-bound editorial mini-lessons
--
-- Ontwerp goedgekeurd in architectuurreview (2026-07-21):
--   - language_notes          : een note, gebonden aan een lesson
--   - language_note_blocks    : geordende content-blokken binnen een note
--   - language_note_examples  : relationele voorbeelden onder een
--                               example_group-blok
--   - language_note_concepts  : exclusive arc naar lesson-associatierijen,
--                               met same-lesson-garantie via samengestelde
--                               foreign keys (geen triggers)
-- =========================================================

-- =========================================================
-- 1. Voorbereiding: samengestelde FK-doelen op bestaande
--    link-tabellen. Logisch redundant met de PK (id is al
--    uniek), maar PostgreSQL eist een exact passende unique
--    constraint als doel van een samengestelde FK.
--    Geen datawijziging.
-- =========================================================

alter table public.lesson_vocabulary
  add constraint lesson_vocabulary_id_lesson_unique unique (id, lesson_id);

alter table public.lesson_grammar
  add constraint lesson_grammar_id_lesson_unique unique (id, lesson_id);

alter table public.lesson_phrase
  add constraint lesson_phrase_id_lesson_unique unique (id, lesson_id);

alter table public.lesson_pattern
  add constraint lesson_pattern_id_lesson_unique unique (id, lesson_id);

-- =========================================================
-- 2. Generieke updated_at-trigger (housekeeping, geen
--    business-logica). Wordt in deze migratie alleen aan de
--    nieuwe Language Note-tabellen gekoppeld.
-- =========================================================

create or replace function public.fn_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- =========================================================
-- 3. language_notes
-- =========================================================

create table public.language_notes (
  id            bigint generated always as identity primary key,
  lesson_id     bigint  not null,
  title         text    not null,
  display_order integer not null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  constraint language_notes_lesson_fk
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade,

  -- deferrable: herordenen kan in een transactie via
  --   set constraints language_notes_lesson_order_unique deferred;
  constraint language_notes_lesson_order_unique
    unique (lesson_id, display_order) deferrable initially immediate,

  -- FK-doel voor language_note_concepts (same-lesson-garantie);
  -- moet non-deferrable zijn, vandaar apart van de order-unique
  constraint language_notes_id_lesson_unique
    unique (id, lesson_id),

  constraint language_notes_display_order_check
    check (display_order >= 1),

  constraint language_notes_title_not_blank
    check (btrim(title) <> '')
);

create trigger trg_language_notes_set_updated_at
  before update on public.language_notes
  for each row execute function public.fn_set_updated_at();

-- =========================================================
-- 4. language_note_blocks
-- =========================================================

create table public.language_note_blocks (
  id               bigint generated always as identity primary key,
  language_note_id bigint  not null,
  display_order    integer not null,
  block_type       text    not null,
  heading          text,
  content          text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),

  constraint language_note_blocks_note_fk
    foreign key (language_note_id)
    references public.language_notes (id)
    on delete cascade,

  constraint language_note_blocks_note_order_unique
    unique (language_note_id, display_order) deferrable initially immediate,

  constraint language_note_blocks_display_order_check
    check (display_order >= 1),

  constraint language_note_blocks_block_type_check
    check (
      block_type in
        ('paragraph', 'subheading', 'formula', 'example_group', 'usage_tip')
    ),

  -- vorm per bloktype: tekst-blokken vereisen content en verbieden
  -- heading; example_group heeft optionele heading en optionele
  -- intro-tekst (content)
  constraint language_note_blocks_content_shape_check
    check (
      (block_type in ('paragraph', 'subheading', 'formula', 'usage_tip')
        and content is not null and btrim(content) <> ''
        and heading is null)
      or
      (block_type = 'example_group'
        and (heading is null or btrim(heading) <> '')
        and (content is null or btrim(content) <> ''))
    ),

  -- FK-doel voor language_note_examples: dwingt zonder trigger af
  -- dat examples uitsluitend aan example_group-blokken hangen
  constraint language_note_blocks_id_type_unique
    unique (id, block_type)
);

create trigger trg_language_note_blocks_set_updated_at
  before update on public.language_note_blocks
  for each row execute function public.fn_set_updated_at();

-- =========================================================
-- 5. language_note_examples
-- =========================================================

create table public.language_note_examples (
  id             bigint generated always as identity primary key,
  block_id       bigint  not null,
  block_type     text    not null default 'example_group',
  display_order  integer not null,
  thai_script    text    not null,
  paiboon        text    not null,
  translation_en text    not null,
  audio_url      text,
  voice_key      text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  -- samengestelde FK: (block_id, 'example_group') moet bestaan, dus
  -- het blok is gegarandeerd een example_group. Bijeffect: het
  -- bloktype wijzigen terwijl er examples hangen wordt geblokkeerd.
  constraint language_note_examples_block_fk
    foreign key (block_id, block_type)
    references public.language_note_blocks (id, block_type)
    on delete cascade,

  constraint language_note_examples_block_type_check
    check (block_type = 'example_group'),

  constraint language_note_examples_block_order_unique
    unique (block_id, display_order) deferrable initially immediate,

  constraint language_note_examples_display_order_check
    check (display_order >= 1),

  constraint language_note_examples_thai_not_blank
    check (btrim(thai_script) <> ''),

  constraint language_note_examples_paiboon_not_blank
    check (btrim(paiboon) <> ''),

  constraint language_note_examples_translation_not_blank
    check (btrim(translation_en) <> ''),

  -- audio_url en voice_key zijn nullable tijdens authoring;
  -- volledigheid wordt later door het publicatierapport gecheckt
  constraint language_note_examples_audio_url_not_blank
    check (audio_url is null or btrim(audio_url) <> ''),

  constraint language_note_examples_voice_key_not_blank
    check (voice_key is null or btrim(voice_key) <> '')
);

create trigger trg_language_note_examples_set_updated_at
  before update on public.language_note_examples
  for each row execute function public.fn_set_updated_at();

-- =========================================================
-- 6. language_note_concepts (exclusive arc)
-- =========================================================

create table public.language_note_concepts (
  id                   bigint generated always as identity primary key,
  language_note_id     bigint not null,
  lesson_id            bigint not null,
  lesson_vocabulary_id bigint,
  lesson_grammar_id    bigint,
  lesson_phrase_id     bigint,
  lesson_pattern_id    bigint,
  created_at           timestamptz not null default now(),

  -- precies één arm gevuld
  constraint language_note_concepts_exactly_one_check
    check (
      num_nonnulls(
        lesson_vocabulary_id,
        lesson_grammar_id,
        lesson_phrase_id,
        lesson_pattern_id
      ) = 1
    ),

  -- lesson_id wordt gedeeld door ALLE samengestelde FK's hieronder:
  -- daardoor is de les van de note per constructie gelijk aan de les
  -- van de geclaimde associatierij (geen trigger nodig).
  constraint language_note_concepts_note_fk
    foreign key (language_note_id, lesson_id)
    references public.language_notes (id, lesson_id)
    on delete cascade,

  -- MATCH SIMPLE (default): bij een NULL-arm wordt de FK
  -- overgeslagen, dus alleen de gevulde arm wordt gecontroleerd.
  -- CASCADE: verdwijnt de lesson-associatie, dan verdwijnt alleen
  -- de claim; de note zelf blijft bestaan.
  constraint language_note_concepts_lesson_vocabulary_fk
    foreign key (lesson_vocabulary_id, lesson_id)
    references public.lesson_vocabulary (id, lesson_id)
    on delete cascade,

  constraint language_note_concepts_lesson_grammar_fk
    foreign key (lesson_grammar_id, lesson_id)
    references public.lesson_grammar (id, lesson_id)
    on delete cascade,

  constraint language_note_concepts_lesson_phrase_fk
    foreign key (lesson_phrase_id, lesson_id)
    references public.lesson_phrase (id, lesson_id)
    on delete cascade,

  constraint language_note_concepts_lesson_pattern_fk
    foreign key (lesson_pattern_id, lesson_id)
    references public.lesson_pattern (id, lesson_id)
    on delete cascade
);

-- geen dubbele claim van hetzelfde concept binnen één note;
-- arm-kolom eerst zodat de index ook de omgekeerde vraag dient:
-- "welke notes behandelen deze associatierij?" (publicatierapport)
create unique index language_note_concepts_vocab_note_unique
  on public.language_note_concepts (lesson_vocabulary_id, language_note_id)
  where lesson_vocabulary_id is not null;

create unique index language_note_concepts_grammar_note_unique
  on public.language_note_concepts (lesson_grammar_id, language_note_id)
  where lesson_grammar_id is not null;

create unique index language_note_concepts_phrase_note_unique
  on public.language_note_concepts (lesson_phrase_id, language_note_id)
  where lesson_phrase_id is not null;

create unique index language_note_concepts_pattern_note_unique
  on public.language_note_concepts (lesson_pattern_id, language_note_id)
  where lesson_pattern_id is not null;

-- forward lookup + cascade-performance vanaf language_notes
create index language_note_concepts_note_idx
  on public.language_note_concepts (language_note_id);

-- Overige FK-kolommen zijn al geïndexeerd via de unique constraints:
-- language_notes (lesson_id, display_order),
-- language_note_blocks (language_note_id, display_order),
-- language_note_examples (block_id, display_order).

-- =========================================================
-- 7. RLS
-- =========================================================

alter table public.language_notes         enable row level security;
alter table public.language_note_blocks   enable row level security;
alter table public.language_note_examples enable row level security;
alter table public.language_note_concepts enable row level security;

create policy "Language notes of published lessons are readable by everyone"
on public.language_notes
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lessons l
    where l.id = language_notes.lesson_id
      and l.is_published = true
  )
);

create policy "Blocks of published language notes are readable by everyone"
on public.language_note_blocks
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.language_notes n
    join public.lessons l on l.id = n.lesson_id
    where n.id = language_note_blocks.language_note_id
      and l.is_published = true
  )
);

create policy "Examples of published language notes are readable by everyone"
on public.language_note_examples
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.language_note_blocks b
    join public.language_notes n on n.id = b.language_note_id
    join public.lessons l on l.id = n.lesson_id
    where b.id = language_note_examples.block_id
      and l.is_published = true
  )
);

create policy "Concept links of published language notes are readable by everyone"
on public.language_note_concepts
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.language_notes n
    join public.lessons l on l.id = n.lesson_id
    where n.id = language_note_concepts.language_note_id
      and l.is_published = true
  )
);

-- =========================================================
-- 8. Grants (principle of least privilege, conform de
--    grant_api_access-conventie)
--
-- anon/authenticated lezen alleen (RLS beperkt verder tot
-- published lessons). Geen sequence-grants: sequence-rechten
-- zijn alleen nodig voor rollen die INSERTen, en dat doet
-- geen van beide rollen.
--
-- service_role krijgt bewust nog niets: rechten worden per
-- script-behoefte toegekend (conventie van de bestaande
-- grant_service_role_*-migraties). Dat gebeurt pas bij de
-- audio-scriptaanpassing voor Language Note-examples.
-- Authoring/seeding gebeurt als postgres en heeft geen
-- grants nodig.
-- =========================================================

grant select on table public.language_notes         to anon, authenticated;
grant select on table public.language_note_blocks   to anon, authenticated;
grant select on table public.language_note_examples to anon, authenticated;
grant select on table public.language_note_concepts to anon, authenticated;

commit;
