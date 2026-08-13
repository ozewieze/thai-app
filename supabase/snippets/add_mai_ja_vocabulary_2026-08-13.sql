-- ============================================================
-- ไหม en จะ bruikbaar maken in voorbeeldzinnen
-- 2026-08-13
--
-- Aanleiding: het example_vocabulary_budget van de brief-views volgt de
-- link-rijen in lesson_vocabulary, niet de masterlijst. ไหม en จะ zijn
-- alleen als pattern aangeleerd (statement_mai in les 2, ja_verb in les
-- 3) en nooit als woord geïntroduceerd. Gevolg: vanaf les 4 kan geen
-- enkel notevoorbeeld nog een ja/nee-vraag stellen of over de toekomst
-- praten, terwijl de leerling beide vormen kent. Vastgesteld bij
-- a1-dialog-04.
--
-- Dit bestand doet alleen de masterlijst. De link-rijen die het budget
-- daadwerkelijk vullen staan in
-- seed-data/links/lesson_links_a1-dialog-02.seed.sql en -03.seed.sql.
--
-- Volgorde van draaien:
--   1. dit bestand
--   2. npm run sync:vocab   (exporteert live DB -> CSV -> .seed.sql)
--   3. de twee link-seedbestanden
--
-- Stap 2 niet overslaan: de CSV in de repo is een export, geen bron.
-- ============================================================

begin;

-- ------------------------------------------------------------
-- 1. question_particle -> question_particle_mai
-- ------------------------------------------------------------
-- Waarom hernoemen: หรือ zit al als 'or' in de lijst en เหรอ, ล่ะ en
-- ใช่ไหม komen nog. Eén generieke sleutel 'question_particle' claimt de
-- naam voor de hele familie en blokkeert die. De sleutel hangt vandaag
-- nergens aan vast -- geen link-rij, geen woordkaart, geen note-claim --
-- dus dit is het laatste moment waarop hernoemen gratis is.
--
-- Waarom de gloss meegaat: english_gloss is wat het schrijvende model in
-- de "Available Vocabulary"-lijst van de writerprompt leest. "question
-- particle" zegt niet welk soort vraag; "yes/no question particle" wel.
--
-- มั้ย (de spreektaalvariant) blijft er bewust uit: één rij, één vorm.

update public.vocabulary_master set
  source_key    = 'question_particle_mai',
  english_gloss = 'yes/no question particle'
where source_key = 'question_particle';

-- ------------------------------------------------------------
-- 2. จะ toevoegen
-- ------------------------------------------------------------
-- paiboon 'jà' is letterlijk overgenomen uit de transliteratie van
-- dialoog 3 ("jà dʉ̀ʉm à-rai khráp", "khun jà dʉ̀ʉm à-rai khá"), niet
-- gereconstrueerd en niet uit een woordenboek. Afleiden is precies hoe
-- de RTGS-vormen er eerder in geslopen zijn.
--
-- source_key 'will' sluit aan bij de gloss-achtige sleutels van de
-- andere grammaticale woorden: 'no' (ไม่), 'can' (ได้), 'or' (หรือ),
-- 'also' (ด้วย).
--
-- part_of_speech 'verb': จะ is een hulpwerkwoord (aux). Dat sluit ook
-- aan bij ได้, dat als verb in de lijst staat.
--
-- default_theme 'essentials': dezelfde plek als ไม่, ได้, หรือ en ด้วย.
--
-- is_multifunctional false: op A1 heeft จะ één functie.
--
-- source_note 'manual_dialogue_seed_v1': dezelfde markering als
-- ยินดี en รู้จัก, de andere twee woorden die met de hand zijn
-- toegevoegd omdat een dialoog ze nodig had.

insert into public.vocabulary_master (
  source_key,
  cefr_level,
  thai_script,
  paiboon,
  english_gloss,
  part_of_speech,
  register,
  default_theme,
  is_multifunctional,
  usage_note,
  source_note
)
values (
  'will',
  'A1',
  'จะ',
  'jà',
  'will / going to',
  'verb',
  'formal',
  'essentials',
  false,
  'Placed before the verb to show intention or a future action.',
  'manual_dialogue_seed_v1'
)
on conflict (source_key) do update set
  thai_script        = excluded.thai_script,
  paiboon            = excluded.paiboon,
  english_gloss      = excluded.english_gloss,
  part_of_speech     = excluded.part_of_speech,
  register           = excluded.register,
  default_theme      = excluded.default_theme,
  is_multifunctional = excluded.is_multifunctional,
  usage_note         = excluded.usage_note,
  source_note        = excluded.source_note;

commit;

-- ------------------------------------------------------------
-- 3. Controle
-- ------------------------------------------------------------
-- Verwacht: twee rijen, question_particle_mai met paiboon mǎi en will
-- met paiboon jà. Beide met een status new (nog geen link-rij).
--
-- Draai met -A -P pager=off, anders lopen de Thaise rijen op het
-- Windows-console over elkaar heen.

select
  vm.source_key,
  vm.thai_script,
  vm.paiboon,
  vm.english_gloss,
  vm.part_of_speech,
  vs.status,
  vs.first_lesson_id
from public.vocabulary_master vm
left join public.vocabulary_status vs on vs.vocabulary_id = vm.id
where vm.source_key in ('question_particle_mai', 'will')
order by vm.source_key;

-- Verwacht: 0 rijen. De oude sleutel mag nergens meer bestaan.

select count(*) as oude_sleutel_nog_aanwezig
from public.vocabulary_master
where source_key = 'question_particle';
