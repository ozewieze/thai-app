begin;

-- =========================================================
-- Lemma-audio verloopt zodra de tekst verandert.
--
-- Het gat dat deze migratie dicht. De twee seedgenerators
-- (generate-vocabulary-example-seed.mjs en
-- generate-language-note-seed.mjs) zetten audio_url op null
-- zodra thai_script wijzigt:
--
--   audio_url = case
--                 when <tabel>.thai_script is distinct from excluded.thai_script
--                 then null
--                 else <tabel>.audio_url
--               end
--
-- Voor vocabulary_master bestaat dat nergens. Die tabel is
-- DB-first: een correctie gaat rechtstreeks de database in en
-- er komt geen upsert aan te pas die zoiets zou kunnen doen.
-- vocabulary_master.seed.sql is een kale insert zonder
-- `on conflict` -- hij draait alleen tegen een verse database.
--
-- Waarom dat erger is dan het klinkt. Het audioscript is
-- idempotent via `audio_url is null`. Blijft er na een
-- tekstcorrectie een URL staan, dan concludeert het script
-- "er is al audio" en slaat de rij over. De kaart toont dan
-- het nieuwe woord en speelt de oude opname af. Niemand ziet
-- een foutmelding; de leerling traint zijn oor op een
-- uitspraak die niet bij het woord hoort dat hij ziet staan.
-- Dat is dezelfde faalmodus die de twee generators al
-- afvangen, en Stap 11 van de vocabulairegids beschrijft haar
-- woordelijk.
--
-- Waarom een trigger en geen vlag op het script. Een vlag
-- werkt alleen als degene die de tekst corrigeert zich
-- herinnert dat er audio bestond. De database is de enige
-- laag die de bewerking ziet op het moment dat ze gebeurt.
--
-- Waarom alleen thai_script. Audio wordt uit het Thaise
-- schrift gegenereerd en uit niets anders. Een correctie aan
-- paiboon, english_gloss of usage_note verandert de gesproken
-- vorm niet en hoort een geldige opname niet weg te gooien --
-- dat zou de herbouwkosten verhogen zonder iets te
-- beschermen.
--
-- Waarom voice_key mee op null. voice_key is een verslag van
-- welke stem een opname insprak, geen instructie vooraf. Zonder
-- opname is er niets te verslaan, en een achtergebleven
-- voice_key zou een uitspraak over een bestand zijn dat niet
-- meer bestaat. De twee kolommen horen samen gevuld en samen
-- leeg te zijn.
--
-- Wat er niet gebeurt: het bestand in de 'audio'-bucket blijft
-- staan. Dat is goedkoop en veilig -- het opslagpad komt uit
-- source_key, dus de volgende run overschrijft precies dat
-- bestand (upsert). Een verweesd bestand is bovendien
-- onbereikbaar zodra audio_url null is.
-- =========================================================

create or replace function public.fn_reset_vocabulary_master_audio()
returns trigger
language plpgsql
as $$
begin
  new.audio_url := null;
  new.voice_key := null;
  return new;
end;
$$;

-- De WHEN-clausule doet het echte werk: de functie draait
-- alleen bij een gewijzigd thai_script, niet bij elke update.
-- `is distinct from` en niet `<>`, zodat een wijziging van of
-- naar null ook telt -- al verbiedt de NOT NULL op thai_script
-- dat vandaag. De constraint kan veranderen; deze regel hoeft
-- dan niet mee.
--
-- Geen aanraking van updated_at. vocabulary_master heeft die
-- kolom wel, maar geen set_updated_at-trigger (anders dan
-- vocabulary_examples en de Language Note-tabellen). Dat hier
-- half repareren zou het gedrag inconsistent maken tussen
-- updates die thai_script raken en updates die dat niet doen.
--
-- Enige BEFORE UPDATE-trigger op deze tabel, dus geen
-- volgordekwestie. trg_initialize_vocabulary_status
-- (20260607100001) is AFTER INSERT en staat hier los van.

create trigger trg_vocabulary_master_reset_audio
  before update on public.vocabulary_master
  for each row
  when (old.thai_script is distinct from new.thai_script)
  execute function public.fn_reset_vocabulary_master_audio();

commit;
