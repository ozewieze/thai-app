-- ============================================================
-- Migratie: Single Introduction Rule staat een re-seed van dezelfde les toe
-- ============================================================
-- Probleem: de vier state machine triggers blokkeerden bij TG_OP = 'INSERT'
-- onvoorwaardelijk zodra de status van het concept al 'introduced' was.
-- Daardoor kon een seedbestand van de leslinks nooit een tweede keer
-- draaien -- ook niet met een `on conflict ... do update`-clausule, want
-- een BEFORE INSERT-trigger vuurt VOORDAT Postgres het conflict detecteert.
-- TG_OP is op dat moment 'INSERT', de UPDATE-tak wordt niet bereikt, en de
-- `on conflict` komt nooit aan bod. Vastgesteld op 2026-08-02 bij het
-- opnieuw draaien van lesson_links_a1-dialog-03.seed.sql.
--
-- Waarom dat een echt probleem is: het corrigeren van een waarde in een
-- seedbestand (bijvoorbeeld requires_explanation, zie Stap 1 van de
-- Language Note-workflowgids) kon dan alleen via een db reset -- die ook de
-- storage-buckets wist en alle dialoogaudio opnieuw door de TTS-API duwt --
-- of via een handgeschreven UPDATE naast het seedbestand. Dat laatste zet
-- dezelfde waarheid op twee plekken en drift vroeg of laat uit elkaar.
--
-- Oorzaak dieper: de regel zoals geïmplementeerd zei "één insert-statement,
-- ooit", terwijl de curriculumregel zegt "één les introduceert een concept".
-- Dat zijn niet dezelfde regel, en het verschil merk je pas bij een re-seed.
--
-- Oplossing: haal naast `status` ook `first_lesson_id` op, en blokkeer bij
-- INSERT alleen wanneer die naar een ANDERE les wijst dan de les die nu
-- ingevoegd wordt. Les 05 die een woord van les 02 als target claimt faalt
-- dus nog steeds luid; les 03 die zichzelf opnieuw seedt gaat door.
--
-- Wat NIET verandert:
--   - De UPDATE-tak: die blokkeert nog steeds wanneer de FK zelf wisselt.
--   - De promotie naar 'introduced' met coalesce(first_lesson_id, ...),
--     die was al idempotent.
--   - De terugdraai-triggers uit 20260717120000 (AFTER DELETE).
--   - De rolcheck op status 'new' in de vocabulaire-variant.
--   - Een tweede rij voor hetzelfde concept binnen één les blijft
--     onmogelijk; dat wordt door de unique constraints afgedwongen, niet
--     door deze trigger.
--
-- De triggers zelf worden niet opnieuw aangemaakt: ze verwijzen naar de
-- functie op naam, en `create or replace function` volstaat.
--
-- De functies hieronder zijn letterlijk overgenomen uit
-- 20260612100000_extend_vocabulary_trigger_for_update.sql en
-- 20260719120000_extend_grammar_phrase_pattern_triggers_for_update.sql,
-- met uitsluitend de hierboven beschreven wijziging.
-- ============================================================

create or replace function public.fn_lesson_vocabulary_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status          text;
  v_first_lesson_id bigint;
  v_still_used      boolean;
begin

  -- ── UPDATE: vocabulary_id is gewisseld ─────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.vocabulary_id is distinct from NEW.vocabulary_id then

    -- Controleer of het oude woord nog ergens anders in lesson_vocabulary voorkomt.
    select exists (--exists geeft true/false terug
      select 1
      from public.lesson_vocabulary
      where vocabulary_id = OLD.vocabulary_id
        and id <> OLD.id        -- sluit de rij die nu geüpdatet wordt uit
    ) into v_still_used;--bewaar de uitkomst in de variabele

    -- Als het nergens anders voorkomt: status terugdraaien naar 'new'.
    if not v_still_used then
      update public.vocabulary_status
      set
        status          = 'new',
        first_lesson_id = null,
        updated_at      = now()
      where vocabulary_id = OLD.vocabulary_id;
    end if;

  end if;

  -- ── INSERT + UPDATE: validatie en statusupdate voor het nieuwe woord ────────

  select status, first_lesson_id into v_status, v_first_lesson_id
  from public.vocabulary_status
  where vocabulary_id = NEW.vocabulary_id;

  if v_status is null then
    raise exception
      'Woord (id: %) heeft geen rij in vocabulary_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.vocabulary_id;
  end if;

  -- Blokkeer dubbele target-introductie (Single Introduction Rule).
  -- Bij INSERT: alleen blokkeren wanneer een ANDERE les het concept al
  -- introduceerde. Seedt dezelfde les zichzelf opnieuw, dan is dat geen
  -- tweede introductie maar dezelfde. De regel gaat over lessen, niet over
  -- het aantal keer dat een insert draait -- en zonder deze uitzondering
  -- kan een seedbestand met on conflict nooit een tweede keer draaien,
  -- omdat de BEFORE INSERT-trigger vuurt voordat Postgres het conflict
  -- detecteert.
  -- Bij UPDATE: alleen blokkeren als het een ander concept is dan het oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if (TG_OP = 'INSERT' and v_first_lesson_id is distinct from NEW.lesson_id)
       or (TG_OP = 'UPDATE' and OLD.vocabulary_id is distinct from NEW.vocabulary_id) then
      raise exception
        'Woord (id: %) is al geïntroduceerd als target (status: introduced). '
        'De Single Introduction Rule verbiedt een tweede target-introductie.',
        NEW.vocabulary_id;
    end if;
  end if;

  -- Blokkeer ongeldige rollen voor woorden die nog niet geïntroduceerd zijn.
  if v_status = 'new' and NEW.role in ('supporting', 'review', 'bonus') then
    raise exception
      'Woord (id: %) heeft status "new" en mag daarom niet als "%" in een les verschijnen. '
      'Introduceer het woord eerst als target.',
      NEW.vocabulary_id, NEW.role;
  end if;

  -- Promoveer naar introduced bij role = 'target'.
  if NEW.role = 'target' then
    update public.vocabulary_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, NEW.lesson_id),
      updated_at      = now()
    where vocabulary_id = NEW.vocabulary_id;
  end if;

  return NEW;
end;
$$;

create or replace function public.fn_lesson_grammar_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status          text;
  v_first_lesson_id bigint;
  v_still_used      boolean;
begin

  -- ── UPDATE: grammar_id is gewisseld ─────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.grammar_id is distinct from NEW.grammar_id then

    select exists (
      select 1
      from public.lesson_grammar
      where grammar_id = OLD.grammar_id
        and id <> OLD.id
    ) into v_still_used;

    if not v_still_used then
      update public.grammar_status
      set
        status          = 'new',
        first_lesson_id = null,
        updated_at      = now()
      where grammar_id = OLD.grammar_id;
    end if;

  end if;

  -- ── INSERT + UPDATE: validatie en statusupdate voor het nieuwe concept ──

  select status, first_lesson_id into v_status, v_first_lesson_id
  from public.grammar_status
  where grammar_id = NEW.grammar_id;

  if v_status is null then
    raise exception
      'Grammar concept (id: %) heeft geen rij in grammar_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.grammar_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  -- Bij INSERT: alleen blokkeren wanneer een ANDERE les het concept al
  -- introduceerde. Seedt dezelfde les zichzelf opnieuw, dan is dat geen
  -- tweede introductie maar dezelfde. De regel gaat over lessen, niet over
  -- het aantal keer dat een insert draait -- en zonder deze uitzondering
  -- kan een seedbestand met on conflict nooit een tweede keer draaien,
  -- omdat de BEFORE INSERT-trigger vuurt voordat Postgres het conflict
  -- detecteert.
  -- Bij UPDATE: alleen blokkeren als het een ander concept is dan het oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if (TG_OP = 'INSERT' and v_first_lesson_id is distinct from NEW.lesson_id)
       or (TG_OP = 'UPDATE' and OLD.grammar_id is distinct from NEW.grammar_id) then
      raise exception
        'Grammar concept (id: %) is al geïntroduceerd als target (status: introduced). '
        'De Single Introduction Rule verbiedt een tweede target-introductie.',
        NEW.grammar_id;
    end if;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if NEW.role = 'target' then
    update public.grammar_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, NEW.lesson_id),
      updated_at      = now()
    where grammar_id = NEW.grammar_id;
  end if;

  return NEW;
end;
$$;

create or replace function public.fn_lesson_phrase_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status          text;
  v_first_lesson_id bigint;
  v_still_used      boolean;
begin

  -- ── UPDATE: phrase_id is gewisseld ──────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.phrase_id is distinct from NEW.phrase_id then

    select exists (
      select 1
      from public.lesson_phrase
      where phrase_id = OLD.phrase_id
        and id <> OLD.id
    ) into v_still_used;

    if not v_still_used then
      update public.phrase_status
      set
        status          = 'new',
        first_lesson_id = null,
        updated_at      = now()
      where phrase_id = OLD.phrase_id;
    end if;

  end if;

  -- ── INSERT + UPDATE: validatie en statusupdate voor de nieuwe phrase ────

  select status, first_lesson_id into v_status, v_first_lesson_id
  from public.phrase_status
  where phrase_id = NEW.phrase_id;

  if v_status is null then
    raise exception
      'Phrase (id: %) heeft geen rij in phrase_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.phrase_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  -- Bij INSERT: alleen blokkeren wanneer een ANDERE les het concept al
  -- introduceerde. Seedt dezelfde les zichzelf opnieuw, dan is dat geen
  -- tweede introductie maar dezelfde. De regel gaat over lessen, niet over
  -- het aantal keer dat een insert draait -- en zonder deze uitzondering
  -- kan een seedbestand met on conflict nooit een tweede keer draaien,
  -- omdat de BEFORE INSERT-trigger vuurt voordat Postgres het conflict
  -- detecteert.
  -- Bij UPDATE: alleen blokkeren als het een ander concept is dan het oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if (TG_OP = 'INSERT' and v_first_lesson_id is distinct from NEW.lesson_id)
       or (TG_OP = 'UPDATE' and OLD.phrase_id is distinct from NEW.phrase_id) then
      raise exception
        'Phrase (id: %) is al geïntroduceerd als target (status: introduced). '
        'De Single Introduction Rule verbiedt een tweede target-introductie.',
        NEW.phrase_id;
    end if;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if NEW.role = 'target' then
    update public.phrase_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, NEW.lesson_id),
      updated_at      = now()
    where phrase_id = NEW.phrase_id;
  end if;

  return NEW;
end;
$$;

create or replace function public.fn_lesson_pattern_state_machine()
returns trigger
language plpgsql
as $$
declare
  v_status          text;
  v_first_lesson_id bigint;
  v_still_used      boolean;
begin

  -- ── UPDATE: pattern_id is gewisseld ─────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.pattern_id is distinct from NEW.pattern_id then

    select exists (
      select 1
      from public.lesson_pattern
      where pattern_id = OLD.pattern_id
        and id <> OLD.id
    ) into v_still_used;

    if not v_still_used then
      update public.pattern_status
      set
        status          = 'new',
        first_lesson_id = null,
        updated_at      = now()
      where pattern_id = OLD.pattern_id;
    end if;

  end if;

  -- ── INSERT + UPDATE: validatie en statusupdate voor het nieuwe pattern ──

  select status, first_lesson_id into v_status, v_first_lesson_id
  from public.pattern_status
  where pattern_id = NEW.pattern_id;

  if v_status is null then
    raise exception
      'Pattern (id: %) heeft geen rij in pattern_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.pattern_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  -- Bij INSERT: alleen blokkeren wanneer een ANDERE les het concept al
  -- introduceerde. Seedt dezelfde les zichzelf opnieuw, dan is dat geen
  -- tweede introductie maar dezelfde. De regel gaat over lessen, niet over
  -- het aantal keer dat een insert draait -- en zonder deze uitzondering
  -- kan een seedbestand met on conflict nooit een tweede keer draaien,
  -- omdat de BEFORE INSERT-trigger vuurt voordat Postgres het conflict
  -- detecteert.
  -- Bij UPDATE: alleen blokkeren als het een ander concept is dan het oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if (TG_OP = 'INSERT' and v_first_lesson_id is distinct from NEW.lesson_id)
       or (TG_OP = 'UPDATE' and OLD.pattern_id is distinct from NEW.pattern_id) then
      raise exception
        'Pattern (id: %) is al geïntroduceerd als target (status: introduced). '
        'De Single Introduction Rule verbiedt een tweede target-introductie.',
        NEW.pattern_id;
    end if;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if NEW.role = 'target' then
    update public.pattern_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, NEW.lesson_id),
      updated_at      = now()
    where pattern_id = NEW.pattern_id;
  end if;

  return NEW;
end;
$$;
