-- ============================================================
-- Migratie: natuurlijke sleutels op de Language Note-tabellen
-- ============================================================
-- Probleem. De seeds van Language Notes moeten idempotent zijn, net als
-- de leslink-seeds sinds 2026-08-02: het bestand opnieuw draaien is de
-- manier om een correctie door te voeren. Dat vraagt
-- `insert ... on conflict ... do update`, en dus een sleutel om op te
-- botsen. Die was er niet.
--
-- Wat er wel was, en waarom het niet volstaat:
--
--   - De primary key `id`. Een identity-waarde die een seedbestand niet
--     kent en niet mag kennen: na een `db reset` kan dezelfde note een
--     ander nummer krijgen. Een id in een seedbestand bakken is precies
--     de fout die zich pas maanden later laat zien.
--
--   - `language_notes_lesson_order_unique (lesson_id, display_order)`,
--     en de gelijkaardige constraints op blocks en examples. Twee
--     bezwaren, elk op zich voldoende.
--
--     Technisch: deze constraints zijn `deferrable initially immediate`
--     aangemaakt, en Postgres weigert een deferrable unique constraint
--     als `on conflict`-arbiter. Gemeten op 2026-08-03 met
--     supabase/qa/verify_language_note_upsert_keys.sql; de melding luidt
--     letterlijk "ON CONFLICT does not support deferrable unique
--     constraints/exclusion constraints as arbiters", zowel via een
--     kolomlijst als via de constraintnaam. `pg_index.indimmediate`
--     staat op false voor deze drie indexen; die vlag wordt gezet als
--     `not deferrable`, dus INITIALLY IMMEDIATE helpt niet -- dat
--     verplaatst alleen het startpunt binnen de transactie.
--
--     Valkuil bij het narekenen: dit is een UITVOERINGSfout, geen
--     planfout. `explain (costs off) insert ... on conflict (lesson_id,
--     display_order) ...` slaagt gewoon en drukt zelfs
--     "Conflict Arbiter Indexes: language_notes_lesson_order_unique"
--     af. Wie deze migratie met EXPLAIN probeert te controleren,
--     concludeert dus precies het tegenovergestelde. Het QA-script
--     voert daarom echt uit, binnen een transactie die terugdraait.
--
--     Tweede valkuil, zichtbaar na deze migratie: een probe-insert die
--     `note_key` weglaat, faalt op NOT NULL vóórdat de arbiter-controle
--     aan bod komt. Dat leest als bewijs terwijl het iets anders meet.
--     Het QA-script classificeert de foutmelding daarom expliciet.
--
--     Inhoudelijk, en dat weegt zwaarder: `display_order` is precies het
--     veld dat je wilt kunnen wijzigen. Een upsert die daarop botst,
--     zou bij het verplaatsen van blok 3 naar positie 1 geen bestaande
--     rij bijwerken maar een nieuwe invoegen, en het oude blok 3 als wees
--     achterlaten -- inclusief zijn examples en hun audio. De seed zou
--     dan stil verkeerde data produceren in plaats van te falen. Dat is
--     dezelfde klasse fout als de `limit 1` die de dialoogworkflowgids
--     sinds 2026-07-31 verbiedt.
--
-- Oplossing. Een aparte sleutel per rij, door de auteur bepaald, die
-- NIET meebeweegt met de volgorde. Daarmee valt identiteit uit elkaar
-- met volgorde: de sleutel zegt wélke rij dit is, `display_order` zegt
-- waar hij staat. Blok `b3` dat naar positie 1 verhuist, blijft `b3`.
--
-- Overwogen en verworpen: de bestaande *_order_unique constraints
-- niet-deferrable maken. Dat maakt ze bruikbaar als arbiter, maar
-- offert het herordenen binnen een transactie op (waarvoor ze bewust
-- deferrable zijn aangemaakt) en lost het inhoudelijke bezwaar
-- hierboven niet op. De twee mechanismen naast elkaar laten bestaan
-- kost één kolom per tabel en houdt beide eigenschappen.
--
-- Reikwijdte. Alleen additief: drie kolommen, drie unique constraints,
-- drie vormchecks. Geen bestaande constraint, index, trigger of policy
-- wordt aangeraakt. De frontend selecteert expliciete kolomlijsten
-- (src/features/lesson/server/queries.ts), dus er breekt niets.
--
-- Over NOT NULL zonder default: de vier tabellen zijn leeg (sectie 4
-- van het QA-script). Staat er tóch een rij, dan faalt deze migratie
-- met "column ... contains null values" en dat is de bedoeling -- dan
-- hoort er eerst een backfill te komen die weet welke sleutel bij welke
-- bestaande rij past. Die vraag mag een migratie niet zelf verzinnen.
-- ============================================================

begin;

-- =========================================================
-- 1. language_notes.note_key
--
-- Globaal uniek, niet per les. De naamconventie uit vastgelegde
-- beslissing 6 van de workflowgids draagt de les al in zich
-- ('a1-dialog-03-note-1'), dus globale uniciteit is gratis en levert
-- een arbiter van één kolom op: `on conflict (note_key)`. Dat sluit
-- ook aan bij lesson_key, source_key, concept_key, phrase_key en
-- pattern_key, die in dit project allemaal globaal uniek zijn.
-- =========================================================

alter table public.language_notes
  add column note_key text not null;

alter table public.language_notes
  add constraint language_notes_note_key_unique unique (note_key);

-- Vormcheck, geen naamgevingscheck. Kleine letters, cijfers en
-- koppeltekens: dat vangt spaties, hoofdletters en onzichtbare
-- witruimte af zonder de redactionele conventie in het schema te
-- betonneren. Wélke naam een note krijgt is een beslissing van de gids,
-- en die hoort daar herzienbaar te blijven.
alter table public.language_notes
  add constraint language_notes_note_key_format
  check (note_key ~ '^[a-z0-9]+(-[a-z0-9]+)*$');

-- =========================================================
-- 2. language_note_blocks.block_key
--
-- Uniek binnen de note, niet globaal. De note draagt de context al via
-- de foreign key; 'a1-dialog-03-note-1-b1' zou diezelfde informatie een
-- tweede keer opschrijven en bij het hernoemen van een note op drie
-- plaatsen moeten veranderen. Binnen de note volstaat 'b1'.
-- =========================================================

alter table public.language_note_blocks
  add column block_key text not null;

alter table public.language_note_blocks
  add constraint language_note_blocks_note_key_unique
  unique (language_note_id, block_key);

alter table public.language_note_blocks
  add constraint language_note_blocks_block_key_format
  check (block_key ~ '^[a-z0-9]+(-[a-z0-9]+)*$');

-- =========================================================
-- 3. language_note_examples.example_key
--
-- Zelfde redenering, één niveau dieper: uniek binnen het blok.
-- =========================================================

alter table public.language_note_examples
  add column example_key text not null;

alter table public.language_note_examples
  add constraint language_note_examples_block_key_unique
  unique (block_id, example_key);

alter table public.language_note_examples
  add constraint language_note_examples_example_key_format
  check (example_key ~ '^[a-z0-9]+(-[a-z0-9]+)*$');

-- =========================================================
-- 4. Geen wijziging aan language_note_concepts
--
-- Die tabel heeft al een bruikbare arbiter: de vier partiële unique
-- indexen uit 20260721120000 zijn met `create unique index` aangemaakt
-- en dus niet-deferrable (indimmediate = true). Een partiële index mag
-- arbiter zijn, mits het predicaat in de infer-clausule herhaald wordt:
--
--   on conflict (lesson_vocabulary_id, language_note_id)
--     where lesson_vocabulary_id is not null
--   do nothing
--
-- Laat je dat `where` weg, dan weigert Postgres met "there is no unique
-- or exclusion constraint matching the ON CONFLICT specification".
-- Beide takken zijn gemeten in sectie 6 van het QA-script.
--
-- `do nothing` en niet `do update`: alle kolommen van die tabel zijn óf
-- sleutelkolom óf created_at. Er valt niets bij te werken -- een claim
-- bestaat of bestaat niet.
--
-- Ook geen extra kolom: een claim heeft geen eigen identiteit los van
-- het paar (note, koppelrij). Een concept_key zou een sleutel toevoegen
-- die niets nieuws identificeert.
-- =========================================================

-- =========================================================
-- 5. Geen grants
--
-- De nieuwe kolommen erven de tabelrechten uit 20260721120000: select
-- voor anon en authenticated, verder niets. Seeden gebeurt als postgres.
-- Zodra een script deze tabellen schrijft (de audio-stap voor
-- note-voorbeelden), hoort dat een eigen migratie te zijn met een eigen
-- motivering, zoals 20260716120100_grant_service_role_select_status_link_tables.sql.
-- =========================================================

commit;
