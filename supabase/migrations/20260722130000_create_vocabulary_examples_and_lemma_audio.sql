begin;

-- =========================================================
-- Vocabulary Cards: lemma-audio + canonieke voorbeelden
--
--   -  conform de bestaande dialogtabellen; geen
--     apart storage-path-veld, geen audio_assets-tabel.
--   - functionele narrator keys
--     ('narrator_female' default, 'narrator_male' bij
--     genderspecifieke taal). voice_key blijft vrije tekst,
--     net als dialog_blocks.speaker_key: VOICE_MAP is
--     scriptconfiguratie, geen databasereferentiedata.
--   - voorbeeldaudio wordt altijd apart gegenereerd,
--     nooit hergebruikt uit dialoogaudio (redactionele regel,
--     geen constraint).
--   - "Minstens 1 voorbeeld per target-woord" is een
--     publicatieregel voor het latere publicatierapport,
--     onafhankelijk van requires_explanation — bewust GEEN
--     constraint of trigger.
--
-- Additief en veilig voor bestaande data: alleen nullable
-- kolommen op vocabulary_master en een nieuwe, lege tabel.
-- lesson_vocabulary en vocabulary_status blijven ongewijzigd.
-- =========================================================

-- =========================================================
-- 1. vocabulary_master: lemma-audio
--
-- text als type, conform elke bestaande audio_url/voice_key-
-- kolom (dialogs, dialog_blocks, language_note_examples).
-- Nullable: ontbrekende audio is een normale authoring-
-- toestand; volledigheid checkt het latere
-- publicatierapport. Indien gezet: niet leeg en geen
-- whitespace, zelfde btrim-conventie als elders.
-- Geen aparte audiotabel: lemma-audio is 1-op-1 met het
-- woord.
-- =========================================================

alter table public.vocabulary_master
  add column audio_url text,
  add column voice_key text;

alter table public.vocabulary_master
  add constraint vocabulary_master_audio_url_not_blank
    check (audio_url is null or btrim(audio_url) <> ''),
  add constraint vocabulary_master_voice_key_not_blank
    check (voice_key is null or btrim(voice_key) <> '');

-- =========================================================
-- 2. vocabulary_examples
--
-- Canonieke, herbruikbare voorbeelden bij één vocabulaire-
-- item. Master-eigendom: geen
-- lesson-kolommen, geen fusie met
-- language_note_examples — zelfde veldnamen als
-- daar is bewust (één patroon voor audio-scripts en
-- weergave), zelfde tabel is bewust niet (ander eigenaar-
-- schap en andere levenscyclus).
-- =========================================================

create table public.vocabulary_examples (
  id             bigint generated always as identity primary key,
  vocabulary_id  bigint  not null,
  display_order  integer not null,
  thai_script    text    not null,
  paiboon        text    not null,
  translation_en text    not null,
  audio_url      text,
  voice_key      text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  -- CASCADE: een canoniek voorbeeld heeft geen bestaansrecht
  -- zonder zijn woord. Verwijderen van een woord verwijdert
  -- zijn voorbeelden mee — zelfde redenering als
  -- language_notes onder lessons.
  constraint vocabulary_examples_vocabulary_fk
    foreign key (vocabulary_id)
    references public.vocabulary_master (id)
    on delete cascade,

  -- deferrable: herordenen van voorbeelden kan in één
  -- transactie via
  --   set constraints vocabulary_examples_vocab_order_unique deferred;
  -- conform de Language Notes-migratie. Dekt tevens de
  -- FK-kolom vocabulary_id als index (kolom staat vooraan),
  -- dus geen aparte index nodig.
  constraint vocabulary_examples_vocab_order_unique
    unique (vocabulary_id, display_order) deferrable initially immediate,

  constraint vocabulary_examples_display_order_check
    check (display_order >= 1),

  constraint vocabulary_examples_thai_not_blank
    check (btrim(thai_script) <> ''),

  constraint vocabulary_examples_paiboon_not_blank
    check (btrim(paiboon) <> ''),

  constraint vocabulary_examples_translation_not_blank
    check (btrim(translation_en) <> ''),

  -- nullable tijdens authoring; niet leeg indien
  -- gezet, zelfde conventie als language_note_examples
  constraint vocabulary_examples_audio_url_not_blank
    check (audio_url is null or btrim(audio_url) <> ''),

  constraint vocabulary_examples_voice_key_not_blank
    check (voice_key is null or btrim(voice_key) <> '')
);

-- hergebruik van de generieke housekeeping-trigger uit de
-- Language Notes-migratie (20260721120000): één functie voor
-- alle content-tabellen, zodat updated_at overal hetzelfde
-- gedrag heeft
create trigger trg_vocabulary_examples_set_updated_at
  before update on public.vocabulary_examples
  for each row execute function public.fn_set_updated_at();

-- =========================================================
-- 3. RLS
--
-- Zelfde zichtbaarheidsfilosofie als vocabulary_master zelf
-- en als de Language Notes-tabellen: leesbaar zodra het
-- woord in minstens één gepubliceerde les voorkomt. Geen
-- eigen is_published op masterdata — publicatie
-- van de les is de enige poort.
-- =========================================================

alter table public.vocabulary_examples enable row level security;

create policy "Vocabulary examples of published lessons are readable by everyone"
on public.vocabulary_examples
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.lesson_vocabulary lv
    join public.lessons l on l.id = lv.lesson_id
    where lv.vocabulary_id = vocabulary_examples.vocabulary_id
      and l.is_published = true
  )
);

-- =========================================================
-- 4. Grants 
--
-- anon/authenticated: alleen SELECT — er bestaan geen
-- write-policies, en RLS is de tweede (niet de enige)
-- verdedigingslaag. Geen sequence-grants: alleen een
-- INSERTende rol heeft sequence-USAGE nodig, en geen van
-- beide rollen mag inserten.
--
-- service_role: bewust nog niets — rechten volgen per
-- concrete scriptbehoefte in een eigen migratie (conventie
-- van de grant_service_role_*-reeks). Dat moment komt bij
-- de audio-scriptaanpassing voor lemma- en voorbeeldaudio.
-- Authoring/seeding gebeurt als postgres en heeft geen
-- grants nodig.
--
-- vocabulary_master heeft zijn SELECT-grants al
-- (grant_api_access, grant_service_role_select_master_tables);
-- de twee nieuwe kolommen vallen daar automatisch onder.
-- =========================================================

grant select on table public.vocabulary_examples to anon, authenticated;

commit;
