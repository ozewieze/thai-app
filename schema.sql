


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."fn_initialize_grammar_status"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  insert into public.grammar_status (grammar_id, status)
  values (new.id, 'new');
  return new;
end;
$$;


ALTER FUNCTION "public"."fn_initialize_grammar_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_initialize_pattern_status"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  insert into public.pattern_status (pattern_id, status)
  values (new.id, 'new');
  return new;
end;
$$;


ALTER FUNCTION "public"."fn_initialize_pattern_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_initialize_phrase_status"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  insert into public.phrase_status (phrase_id, status)
  values (new.id, 'new');
  return new;
end;
$$;


ALTER FUNCTION "public"."fn_initialize_phrase_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_initialize_vocabulary_status"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  insert into public.vocabulary_status (vocabulary_id, status)
  values (new.id, 'new');

  return new;
end;
$$;


ALTER FUNCTION "public"."fn_initialize_vocabulary_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_lesson_grammar_state_machine"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_status text;
begin
  select status into v_status
  from public.grammar_status
  where grammar_id = new.grammar_id;

  if v_status is null then
    raise exception
      'Grammar concept (id: %) heeft geen rij in grammar_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      new.grammar_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  if new.role = 'target' and v_status = 'introduced' then
    raise exception
      'Grammar concept (id: %) is al geïntroduceerd als target (status: introduced). '
      'De Single Introduction Rule verbiedt een tweede target-introductie.',
      new.grammar_id;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if new.role = 'target' then
    update public.grammar_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, new.lesson_id),
      updated_at      = now()
    where grammar_id = new.grammar_id;
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."fn_lesson_grammar_state_machine"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_lesson_pattern_state_machine"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_status text;
begin
  select status into v_status
  from public.pattern_status
  where pattern_id = new.pattern_id;

  if v_status is null then
    raise exception
      'Pattern (id: %) heeft geen rij in pattern_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      new.pattern_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  if new.role = 'target' and v_status = 'introduced' then
    raise exception
      'Pattern (id: %) is al geïntroduceerd als target (status: introduced). '
      'De Single Introduction Rule verbiedt een tweede target-introductie.',
      new.pattern_id;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if new.role = 'target' then
    update public.pattern_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, new.lesson_id),
      updated_at      = now()
    where pattern_id = new.pattern_id;
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."fn_lesson_pattern_state_machine"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_lesson_phrase_state_machine"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_status text;
begin
  select status into v_status
  from public.phrase_status
  where phrase_id = new.phrase_id;

  if v_status is null then
    raise exception
      'Phrase (id: %) heeft geen rij in phrase_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      new.phrase_id;
  end if;

  -- Single Introduction Rule: blokkeer tweede target-introductie.
  if new.role = 'target' and v_status = 'introduced' then
    raise exception
      'Phrase (id: %) is al geïntroduceerd als target (status: introduced). '
      'De Single Introduction Rule verbiedt een tweede target-introductie.',
      new.phrase_id;
  end if;

  -- Bij role = 'target': promoveer naar introduced.
  if new.role = 'target' then
    update public.phrase_status
    set
      status          = 'introduced',
      first_lesson_id = coalesce(first_lesson_id, new.lesson_id),
      updated_at      = now()
    where phrase_id = new.phrase_id;
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."fn_lesson_phrase_state_machine"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_lesson_vocabulary_state_machine"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_status     text;
  v_still_used boolean;
begin

  -- ── UPDATE: vocabulary_id is gewisseld ─────────────────────────────────────
  if TG_OP = 'UPDATE' and OLD.vocabulary_id is distinct from NEW.vocabulary_id then

    -- Controleer of het oude woord nog ergens anders in lesson_vocabulary voorkomt.
    select exists (
      select 1
      from public.lesson_vocabulary
      where vocabulary_id = OLD.vocabulary_id
        and id <> OLD.id        -- sluit de rij die nu geüpdatet wordt uit
    ) into v_still_used;

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

  select status into v_status
  from public.vocabulary_status
  where vocabulary_id = NEW.vocabulary_id;

  if v_status is null then
    raise exception
      'Woord (id: %) heeft geen rij in vocabulary_status. '
      'Controleer of de backfill-migratie correct is uitgevoerd.',
      NEW.vocabulary_id;
  end if;

  -- Blokkeer dubbele target-introductie (Single Introduction Rule).
  -- Bij UPDATE: alleen blokkeren als het een ánder woord is dan het oude
  -- (anders zou je een bestaande target-rij nooit kunnen aanpassen).
  if NEW.role = 'target' and v_status = 'introduced' then
    if TG_OP = 'INSERT' or OLD.vocabulary_id is distinct from NEW.vocabulary_id then
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


ALTER FUNCTION "public"."fn_lesson_vocabulary_state_machine"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."character_profiles" (
    "id" bigint NOT NULL,
    "character_key" "text" NOT NULL,
    "display_name" "text" NOT NULL,
    "role_summary" "text" NOT NULL,
    "age_impression" "text",
    "default_tone" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "default_usage" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "display_name_thai" "text"
);


ALTER TABLE "public"."character_profiles" OWNER TO "postgres";


ALTER TABLE "public"."character_profiles" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."character_profiles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."dialog_blocks" (
    "id" bigint NOT NULL,
    "dialog_id" bigint NOT NULL,
    "block_index" integer NOT NULL,
    "thai_text" "text" NOT NULL,
    "transliteration" "text",
    "translation_en" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "audio_url" "text",
    "speaker_key" "text",
    "full_start_ms" integer,
    "full_end_ms" integer,
    CONSTRAINT "dialog_blocks_block_index_check" CHECK (("block_index" >= 0))
);


ALTER TABLE "public"."dialog_blocks" OWNER TO "postgres";


ALTER TABLE "public"."dialog_blocks" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."dialog_blocks_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."dialog_blueprint_specs" (
    "id" bigint NOT NULL,
    "lesson_id" bigint NOT NULL,
    "relationship_pair_id" bigint NOT NULL,
    "learning_focus" "text" NOT NULL,
    "scene_summary" "text" NOT NULL,
    "scene_type" "text",
    "suggested_location" "text",
    "allowed_register" "text",
    "estimated_line_count" "text",
    "extra_constraints" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "dialog_blueprint_specs_extra_constraints_check" CHECK (("jsonb_typeof"("extra_constraints") = 'array'::"text"))
);


ALTER TABLE "public"."dialog_blueprint_specs" OWNER TO "postgres";


ALTER TABLE "public"."dialog_blueprint_specs" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."dialog_blueprint_specs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."dialog_slides" (
    "id" bigint NOT NULL,
    "dialog_id" bigint NOT NULL,
    "slide_index" integer NOT NULL,
    "first_block_index" integer NOT NULL,
    "last_block_index" integer NOT NULL,
    "image_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "dialog_slides_block_order_check" CHECK (("last_block_index" >= "first_block_index")),
    CONSTRAINT "dialog_slides_first_block_index_check" CHECK (("first_block_index" >= 0)),
    CONSTRAINT "dialog_slides_slide_index_check" CHECK (("slide_index" >= 0))
);


ALTER TABLE "public"."dialog_slides" OWNER TO "postgres";


ALTER TABLE "public"."dialog_slides" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."dialog_slides_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."dialogs" (
    "id" bigint NOT NULL,
    "lesson_id" bigint NOT NULL,
    "title" "text",
    "register" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "scene_summary" "text",
    "learning_focus" "text",
    "subtitle" "text",
    "audio_url" "text",
    "audio_duration_ms" integer,
    CONSTRAINT "dialogs_register_check" CHECK ((("register" IS NULL) OR ("register" = ANY (ARRAY['neutral'::"text", 'formal'::"text", 'informal'::"text", 'polite'::"text", 'colloquial'::"text"]))))
);


ALTER TABLE "public"."dialogs" OWNER TO "postgres";


ALTER TABLE "public"."dialogs" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."dialogues_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."grammar_master" (
    "id" bigint NOT NULL,
    "concept_key" "text" NOT NULL,
    "cefr_level" "text" NOT NULL,
    "title" "text" NOT NULL,
    "short_explanation" "text",
    "concept_type" "text",
    "register" "text",
    "source_note" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "grammar_master_cefr_level_check" CHECK (("cefr_level" = ANY (ARRAY['A1'::"text", 'A2'::"text", 'B1'::"text", 'B2'::"text", 'C1'::"text", 'C2'::"text"]))),
    CONSTRAINT "grammar_master_concept_type_check" CHECK ((("concept_type" IS NULL) OR ("concept_type" = ANY (ARRAY['sentence_pattern'::"text", 'modifier_pattern'::"text", 'question_pattern'::"text", 'pronoun_system'::"text", 'negation'::"text", 'verb_pattern'::"text", 'location_pattern'::"text", 'tense_aspect'::"text", 'functional_expression'::"text", 'politeness'::"text", 'particle'::"text", 'classifier_pattern'::"text", 'quantity'::"text", 'comparison'::"text", 'time_expression'::"text"])))),
    CONSTRAINT "grammar_master_register_check" CHECK ((("register" IS NULL) OR ("register" = ANY (ARRAY['neutral'::"text", 'formal'::"text", 'informal'::"text", 'polite'::"text", 'colloquial'::"text"]))))
);


ALTER TABLE "public"."grammar_master" OWNER TO "postgres";


ALTER TABLE "public"."grammar_master" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."grammar_master_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."grammar_status" (
    "id" bigint NOT NULL,
    "grammar_id" bigint NOT NULL,
    "status" "text" DEFAULT 'new'::"text" NOT NULL,
    "first_lesson_id" bigint,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "grammar_status_first_context_required_check" CHECK (((("status" = 'new'::"text") AND ("first_lesson_id" IS NULL)) OR (("status" = 'introduced'::"text") AND ("first_lesson_id" IS NOT NULL)))),
    CONSTRAINT "grammar_status_status_check" CHECK (("status" = ANY (ARRAY['new'::"text", 'introduced'::"text"])))
);


ALTER TABLE "public"."grammar_status" OWNER TO "postgres";


ALTER TABLE "public"."grammar_status" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."grammar_status_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."lessons" (
    "id" bigint NOT NULL,
    "lesson_key" "text" NOT NULL,
    "cefr_level" "text" NOT NULL,
    "lesson_type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "sequence_number" integer NOT NULL,
    "is_published" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "slug" "text",
    "section_key" "text",
    "subtitle" "text",
    "access_tier" "text",
    CONSTRAINT "lessons_access_tier_check" CHECK (("access_tier" = ANY (ARRAY['free'::"text", 'premium'::"text"]))),
    CONSTRAINT "lessons_cefr_level_check" CHECK (("cefr_level" = ANY (ARRAY['A1'::"text", 'A2'::"text", 'B1'::"text", 'B2'::"text", 'C1'::"text", 'C2'::"text"]))),
    CONSTRAINT "lessons_lesson_type_check" CHECK (("lesson_type" = ANY (ARRAY['dialog'::"text", 'revision'::"text", 'theme'::"text", 'story'::"text"]))),
    CONSTRAINT "lessons_section_key_check" CHECK (("section_key" = ANY (ARRAY['dialogs'::"text", 'themes'::"text", 'stories'::"text", 'focus'::"text"])))
);


ALTER TABLE "public"."lessons" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."lesson_available_grammar_view" WITH ("security_invoker"='true') AS
 SELECT "id" AS "lesson_id",
    "lesson_key",
    "sequence_number",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('grammar_id', "gm"."id", 'concept_key', "gm"."concept_key", 'title', "gm"."title", 'short_explanation', "gm"."short_explanation", 'concept_type', "gm"."concept_type", 'register', "gm"."register", 'status', "gs"."status", 'first_lesson_id', "gs"."first_lesson_id", 'intro_sequence_number', "intro"."sequence_number") ORDER BY "intro"."sequence_number", "gm"."id") AS "jsonb_agg"
           FROM (("public"."grammar_status" "gs"
             JOIN "public"."grammar_master" "gm" ON (("gm"."id" = "gs"."grammar_id")))
             JOIN "public"."lessons" "intro" ON (("intro"."id" = "gs"."first_lesson_id")))
          WHERE (("gs"."first_lesson_id" IS NOT NULL) AND ("intro"."sequence_number" < "l"."sequence_number"))), '[]'::"jsonb") AS "previously_introduced_grammar"
   FROM "public"."lessons" "l";


ALTER VIEW "public"."lesson_available_grammar_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pattern_master" (
    "id" bigint NOT NULL,
    "pattern_key" "text" NOT NULL,
    "cefr_level" "text" NOT NULL,
    "title" "text" NOT NULL,
    "pattern_formula" "text",
    "short_explanation" "text",
    "pattern_type" "text",
    "register" "text",
    "fixedness_level" "text",
    "is_productive" boolean DEFAULT false NOT NULL,
    "source_note" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "pattern_master_cefr_level_check" CHECK (("cefr_level" = ANY (ARRAY['A1'::"text", 'A2'::"text", 'B1'::"text", 'B2'::"text", 'C1'::"text", 'C2'::"text"]))),
    CONSTRAINT "pattern_master_fixedness_level_check" CHECK ((("fixedness_level" IS NULL) OR ("fixedness_level" = ANY (ARRAY['fixed'::"text", 'semi_fixed'::"text", 'productive'::"text"])))),
    CONSTRAINT "pattern_master_pattern_type_check" CHECK ((("pattern_type" IS NULL) OR ("pattern_type" = ANY (ARRAY['sentence_frame'::"text", 'negation_frame'::"text", 'ability_frame'::"text", 'request_frame'::"text", 'preference_frame'::"text", 'permission_frame'::"text", 'question_frame'::"text", 'location_frame'::"text", 'time_frame'::"text", 'quantity_frame'::"text", 'classifier_frame'::"text", 'result_frame'::"text", 'comparison_frame'::"text", 'politeness_frame'::"text", 'response_frame'::"text"])))),
    CONSTRAINT "pattern_master_register_check" CHECK ((("register" IS NULL) OR ("register" = ANY (ARRAY['neutral'::"text", 'formal'::"text", 'informal'::"text", 'polite'::"text", 'colloquial'::"text"]))))
);


ALTER TABLE "public"."pattern_master" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pattern_status" (
    "id" bigint NOT NULL,
    "pattern_id" bigint NOT NULL,
    "status" "text" DEFAULT 'new'::"text" NOT NULL,
    "first_lesson_id" bigint,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "pattern_status_first_context_required_check" CHECK (((("status" = 'new'::"text") AND ("first_lesson_id" IS NULL)) OR (("status" = 'introduced'::"text") AND ("first_lesson_id" IS NOT NULL)))),
    CONSTRAINT "pattern_status_status_check" CHECK (("status" = ANY (ARRAY['new'::"text", 'introduced'::"text"])))
);


ALTER TABLE "public"."pattern_status" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."lesson_available_pattern_view" WITH ("security_invoker"='true') AS
 SELECT "id" AS "lesson_id",
    "lesson_key",
    "sequence_number",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('pattern_id', "pm"."id", 'pattern_key', "pm"."pattern_key", 'title', "pm"."title", 'pattern_formula', "pm"."pattern_formula", 'short_explanation', "pm"."short_explanation", 'pattern_type', "pm"."pattern_type", 'register', "pm"."register", 'fixedness_level', "pm"."fixedness_level", 'is_productive', "pm"."is_productive", 'status', "pas"."status", 'first_lesson_id', "pas"."first_lesson_id", 'intro_sequence_number', "intro"."sequence_number") ORDER BY "intro"."sequence_number", "pm"."id") AS "jsonb_agg"
           FROM (("public"."pattern_status" "pas"
             JOIN "public"."pattern_master" "pm" ON (("pm"."id" = "pas"."pattern_id")))
             JOIN "public"."lessons" "intro" ON (("intro"."id" = "pas"."first_lesson_id")))
          WHERE (("pas"."first_lesson_id" IS NOT NULL) AND ("intro"."sequence_number" < "l"."sequence_number"))), '[]'::"jsonb") AS "previously_introduced_patterns"
   FROM "public"."lessons" "l";


ALTER VIEW "public"."lesson_available_pattern_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."phrase_master" (
    "id" bigint NOT NULL,
    "phrase_key" "text" NOT NULL,
    "cefr_level" "text" NOT NULL,
    "title" "text" NOT NULL,
    "phrase_formula" "text",
    "short_explanation" "text",
    "phrase_type" "text",
    "register" "text",
    "fixedness_level" "text",
    "is_productive" boolean DEFAULT false NOT NULL,
    "source_note" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "phrase_master_cefr_level_check" CHECK (("cefr_level" = ANY (ARRAY['A1'::"text", 'A2'::"text", 'B1'::"text", 'B2'::"text", 'C1'::"text", 'C2'::"text"]))),
    CONSTRAINT "phrase_master_fixedness_level_check" CHECK ((("fixedness_level" IS NULL) OR ("fixedness_level" = ANY (ARRAY['fixed'::"text", 'semi_fixed'::"text", 'productive'::"text"])))),
    CONSTRAINT "phrase_master_phrase_type_check" CHECK ((("phrase_type" IS NULL) OR ("phrase_type" = ANY (ARRAY['sentence_frame'::"text", 'collocation'::"text", 'formulaic_expression'::"text", 'functional_pattern'::"text", 'discourse_pattern'::"text", 'question_answer_exchange'::"text", 'other'::"text"])))),
    CONSTRAINT "phrase_master_register_check" CHECK ((("register" IS NULL) OR ("register" = ANY (ARRAY['neutral'::"text", 'formal'::"text", 'informal'::"text", 'polite'::"text", 'colloquial'::"text"]))))
);


ALTER TABLE "public"."phrase_master" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."phrase_status" (
    "id" bigint NOT NULL,
    "phrase_id" bigint NOT NULL,
    "status" "text" DEFAULT 'new'::"text" NOT NULL,
    "first_lesson_id" bigint,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "phrase_status_first_context_required_check" CHECK (((("status" = 'new'::"text") AND ("first_lesson_id" IS NULL)) OR (("status" = 'introduced'::"text") AND ("first_lesson_id" IS NOT NULL)))),
    CONSTRAINT "phrase_status_status_check" CHECK (("status" = ANY (ARRAY['new'::"text", 'introduced'::"text"])))
);


ALTER TABLE "public"."phrase_status" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."lesson_available_phrase_view" WITH ("security_invoker"='true') AS
 SELECT "id" AS "lesson_id",
    "lesson_key",
    "sequence_number",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('phrase_id', "pm"."id", 'phrase_key', "pm"."phrase_key", 'title', "pm"."title", 'phrase_formula', "pm"."phrase_formula", 'short_explanation', "pm"."short_explanation", 'phrase_type', "pm"."phrase_type", 'register', "pm"."register", 'fixedness_level', "pm"."fixedness_level", 'is_productive', "pm"."is_productive", 'status', "ps"."status", 'first_lesson_id', "ps"."first_lesson_id", 'intro_sequence_number', "intro"."sequence_number") ORDER BY "intro"."sequence_number", "pm"."id") AS "jsonb_agg"
           FROM (("public"."phrase_status" "ps"
             JOIN "public"."phrase_master" "pm" ON (("pm"."id" = "ps"."phrase_id")))
             JOIN "public"."lessons" "intro" ON (("intro"."id" = "ps"."first_lesson_id")))
          WHERE (("ps"."first_lesson_id" IS NOT NULL) AND ("intro"."sequence_number" < "l"."sequence_number"))), '[]'::"jsonb") AS "previously_introduced_phrases"
   FROM "public"."lessons" "l";


ALTER VIEW "public"."lesson_available_phrase_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vocabulary_master" (
    "id" bigint NOT NULL,
    "source_key" "text" NOT NULL,
    "cefr_level" "text" NOT NULL,
    "thai_script" "text" NOT NULL,
    "paiboon" "text",
    "english_gloss" "text" NOT NULL,
    "part_of_speech" "text",
    "register" "text",
    "default_theme" "text",
    "is_multifunctional" boolean DEFAULT false NOT NULL,
    "usage_note" "text",
    "source_note" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "vocabulary_master_cefr_level_check" CHECK (("cefr_level" = ANY (ARRAY['A1'::"text", 'A2'::"text", 'B1'::"text", 'B2'::"text", 'C1'::"text", 'C2'::"text"]))),
    CONSTRAINT "vocabulary_master_part_of_speech_check" CHECK ((("part_of_speech" IS NULL) OR ("part_of_speech" = ANY (ARRAY['noun'::"text", 'verb'::"text", 'adjective'::"text", 'adverb'::"text", 'pronoun'::"text", 'preposition'::"text", 'conjunction'::"text", 'particle'::"text", 'classifier'::"text", 'question_word'::"text", 'expression'::"text", 'numeral'::"text", 'number'::"text", 'other'::"text"])))),
    CONSTRAINT "vocabulary_master_register_check" CHECK ((("register" IS NULL) OR ("register" = ANY (ARRAY['neutral'::"text", 'formal'::"text", 'informal'::"text", 'polite'::"text", 'colloquial'::"text"]))))
);


ALTER TABLE "public"."vocabulary_master" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vocabulary_status" (
    "id" bigint NOT NULL,
    "vocabulary_id" bigint NOT NULL,
    "status" "text" DEFAULT 'new'::"text" NOT NULL,
    "first_lesson_id" bigint,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "vocabulary_status_first_context_required_check" CHECK (((("status" = 'new'::"text") AND ("first_lesson_id" IS NULL)) OR (("status" = 'introduced'::"text") AND ("first_lesson_id" IS NOT NULL)))),
    CONSTRAINT "vocabulary_status_status_check" CHECK (("status" = ANY (ARRAY['new'::"text", 'introduced'::"text"])))
);


ALTER TABLE "public"."vocabulary_status" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."lesson_available_vocabulary_view" WITH ("security_invoker"='true') AS
 SELECT "id" AS "lesson_id",
    "lesson_key",
    "sequence_number",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('vocabulary_id', "vm"."id", 'source_key', "vm"."source_key", 'thai_script', "vm"."thai_script", 'paiboon', "vm"."paiboon", 'english_gloss', "vm"."english_gloss", 'part_of_speech', "vm"."part_of_speech", 'register', "vm"."register", 'status', "vs"."status", 'first_lesson_id', "vs"."first_lesson_id", 'intro_sequence_number', "intro"."sequence_number") ORDER BY "intro"."sequence_number", "vm"."id") AS "jsonb_agg"
           FROM (("public"."vocabulary_status" "vs"
             JOIN "public"."vocabulary_master" "vm" ON (("vm"."id" = "vs"."vocabulary_id")))
             JOIN "public"."lessons" "intro" ON (("intro"."id" = "vs"."first_lesson_id")))
          WHERE (("vs"."first_lesson_id" IS NOT NULL) AND ("intro"."sequence_number" < "l"."sequence_number"))), '[]'::"jsonb") AS "previously_introduced_vocabulary"
   FROM "public"."lessons" "l";


ALTER VIEW "public"."lesson_available_vocabulary_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lesson_grammar" (
    "id" bigint NOT NULL,
    "lesson_id" bigint NOT NULL,
    "grammar_id" bigint NOT NULL,
    "requires_explanation" boolean DEFAULT false NOT NULL,
    "display_order" integer,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "role" "text" NOT NULL,
    CONSTRAINT "lesson_grammar_display_order_check" CHECK ((("display_order" IS NULL) OR ("display_order" >= 1))),
    CONSTRAINT "lesson_grammar_role_check" CHECK (("role" = ANY (ARRAY['target'::"text", 'supporting'::"text", 'review'::"text", 'bonus'::"text"])))
);


ALTER TABLE "public"."lesson_grammar" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lesson_pattern" (
    "id" bigint NOT NULL,
    "lesson_id" bigint NOT NULL,
    "pattern_id" bigint NOT NULL,
    "requires_explanation" boolean DEFAULT false NOT NULL,
    "display_order" integer,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "role" "text" NOT NULL,
    CONSTRAINT "lesson_pattern_display_order_check" CHECK ((("display_order" IS NULL) OR ("display_order" >= 1))),
    CONSTRAINT "lesson_pattern_role_check" CHECK (("role" = ANY (ARRAY['target'::"text", 'supporting'::"text", 'review'::"text", 'bonus'::"text"])))
);


ALTER TABLE "public"."lesson_pattern" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lesson_phrase" (
    "id" bigint NOT NULL,
    "lesson_id" bigint NOT NULL,
    "phrase_id" bigint NOT NULL,
    "role" "text" NOT NULL,
    "requires_explanation" boolean DEFAULT false NOT NULL,
    "display_order" integer,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "lesson_phrase_display_order_check" CHECK ((("display_order" IS NULL) OR ("display_order" >= 1))),
    CONSTRAINT "lesson_phrase_role_check" CHECK (("role" = ANY (ARRAY['target'::"text", 'supporting'::"text", 'review'::"text", 'bonus'::"text"])))
);


ALTER TABLE "public"."lesson_phrase" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lesson_vocabulary" (
    "id" bigint NOT NULL,
    "lesson_id" bigint NOT NULL,
    "vocabulary_id" bigint NOT NULL,
    "role" "text" NOT NULL,
    "requires_explanation" boolean DEFAULT false NOT NULL,
    "display_order" integer,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "lesson_vocabulary_display_order_check" CHECK ((("display_order" IS NULL) OR ("display_order" >= 1))),
    CONSTRAINT "lesson_vocabulary_role_check" CHECK (("role" = ANY (ARRAY['target'::"text", 'supporting'::"text", 'review'::"text", 'bonus'::"text"])))
);


ALTER TABLE "public"."lesson_vocabulary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."lesson_blueprint_view" WITH ("security_invoker"='true') AS
 SELECT "id" AS "lesson_id",
    "lesson_key",
    "title" AS "lesson_title",
    "subtitle",
    "cefr_level",
    "lesson_type",
    "sequence_number",
    "section_key",
    "is_published",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('vocabulary_id', "vm"."id", 'source_key', "vm"."source_key", 'thai_script', "vm"."thai_script", 'paiboon', "vm"."paiboon", 'english_gloss', "vm"."english_gloss", 'part_of_speech', "vm"."part_of_speech", 'register', "vm"."register", 'usage_note', "vm"."usage_note", 'lesson_role', "lv"."role", 'display_order', "lv"."display_order", 'requires_explanation', "lv"."requires_explanation", 'lesson_notes', "lv"."notes") ORDER BY "lv"."display_order" NULLS FIRST, "lv"."id") AS "jsonb_agg"
           FROM ("public"."lesson_vocabulary" "lv"
             JOIN "public"."vocabulary_master" "vm" ON (("vm"."id" = "lv"."vocabulary_id")))
          WHERE ("lv"."lesson_id" = "l"."id")), '[]'::"jsonb") AS "all_vocabulary",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('phrase_id', "pm"."id", 'phrase_key', "pm"."phrase_key", 'title', "pm"."title", 'phrase_formula', "pm"."phrase_formula", 'short_explanation', "pm"."short_explanation", 'phrase_type', "pm"."phrase_type", 'register', "pm"."register", 'fixedness_level', "pm"."fixedness_level", 'is_productive', "pm"."is_productive", 'lesson_role', "lp"."role", 'display_order', "lp"."display_order", 'requires_explanation', "lp"."requires_explanation", 'lesson_notes', "lp"."notes") ORDER BY "lp"."display_order" NULLS FIRST, "lp"."id") AS "jsonb_agg"
           FROM ("public"."lesson_phrase" "lp"
             JOIN "public"."phrase_master" "pm" ON (("pm"."id" = "lp"."phrase_id")))
          WHERE ("lp"."lesson_id" = "l"."id")), '[]'::"jsonb") AS "all_phrases",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('grammar_id', "gm"."id", 'concept_key', "gm"."concept_key", 'title', "gm"."title", 'short_explanation', "gm"."short_explanation", 'concept_type', "gm"."concept_type", 'register', "gm"."register", 'display_order', "lg"."display_order", 'requires_explanation', "lg"."requires_explanation", 'lesson_notes', "lg"."notes") ORDER BY "lg"."display_order" NULLS FIRST, "lg"."id") AS "jsonb_agg"
           FROM ("public"."lesson_grammar" "lg"
             JOIN "public"."grammar_master" "gm" ON (("gm"."id" = "lg"."grammar_id")))
          WHERE ("lg"."lesson_id" = "l"."id")), '[]'::"jsonb") AS "all_grammar",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('pattern_id', "pm"."id", 'pattern_key', "pm"."pattern_key", 'title', "pm"."title", 'pattern_formula', "pm"."pattern_formula", 'short_explanation', "pm"."short_explanation", 'pattern_type', "pm"."pattern_type", 'register', "pm"."register", 'fixedness_level', "pm"."fixedness_level", 'is_productive', "pm"."is_productive", 'display_order', "lp"."display_order", 'requires_explanation', "lp"."requires_explanation", 'lesson_notes', "lp"."notes") ORDER BY "lp"."display_order" NULLS FIRST, "lp"."id") AS "jsonb_agg"
           FROM ("public"."lesson_pattern" "lp"
             JOIN "public"."pattern_master" "pm" ON (("pm"."id" = "lp"."pattern_id")))
          WHERE ("lp"."lesson_id" = "l"."id")), '[]'::"jsonb") AS "all_patterns"
   FROM "public"."lessons" "l";


ALTER VIEW "public"."lesson_blueprint_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."relationship_pair_rules" (
    "id" bigint NOT NULL,
    "relationship_pair_id" bigint NOT NULL,
    "rule_key" "text" NOT NULL,
    "rule_text" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."relationship_pair_rules" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."relationship_pairs" (
    "id" bigint NOT NULL,
    "character_a_id" bigint NOT NULL,
    "character_b_id" bigint NOT NULL,
    "start_state" "text" NOT NULL,
    "current_stage" "text" NOT NULL,
    "function_summary" "text" NOT NULL,
    "allowed_progression" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "relationship_pairs_distinct_characters_check" CHECK (("character_a_id" <> "character_b_id"))
);


ALTER TABLE "public"."relationship_pairs" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."lesson_continuity_options_view" WITH ("security_invoker"='true') AS
 SELECT "rp"."id" AS "relationship_pair_id",
    "rp"."start_state",
    "rp"."current_stage",
    "rp"."function_summary",
    "rp"."allowed_progression",
    "a"."id" AS "character_a_id",
    "a"."character_key" AS "character_a_key",
    "a"."display_name" AS "character_a_name",
    "a"."display_name_thai" AS "character_a_name_thai",
    "a"."role_summary" AS "character_a_role_summary",
    "a"."age_impression" AS "character_a_age_impression",
    "a"."default_tone" AS "character_a_default_tone",
    "a"."default_usage" AS "character_a_default_usage",
    "b"."id" AS "character_b_id",
    "b"."character_key" AS "character_b_key",
    "b"."display_name" AS "character_b_name",
    "b"."display_name_thai" AS "character_b_name_thai",
    "b"."role_summary" AS "character_b_role_summary",
    "b"."age_impression" AS "character_b_age_impression",
    "b"."default_tone" AS "character_b_default_tone",
    "b"."default_usage" AS "character_b_default_usage",
    COALESCE("jsonb_agg"("jsonb_build_object"('rule_key', "rpr"."rule_key", 'rule_text', "rpr"."rule_text") ORDER BY "rpr"."id") FILTER (WHERE ("rpr"."id" IS NOT NULL)), '[]'::"jsonb") AS "relationship_rules"
   FROM ((("public"."relationship_pairs" "rp"
     JOIN "public"."character_profiles" "a" ON (("a"."id" = "rp"."character_a_id")))
     JOIN "public"."character_profiles" "b" ON (("b"."id" = "rp"."character_b_id")))
     LEFT JOIN "public"."relationship_pair_rules" "rpr" ON (("rpr"."relationship_pair_id" = "rp"."id")))
  WHERE ("rp"."is_active" = true)
  GROUP BY "rp"."id", "rp"."start_state", "rp"."current_stage", "rp"."function_summary", "rp"."allowed_progression", "a"."id", "a"."character_key", "a"."display_name", "a"."display_name_thai", "a"."role_summary", "a"."age_impression", "a"."default_tone", "a"."default_usage", "b"."id", "b"."character_key", "b"."display_name", "b"."display_name_thai", "b"."role_summary", "b"."age_impression", "b"."default_tone", "b"."default_usage";


ALTER VIEW "public"."lesson_continuity_options_view" OWNER TO "postgres";


ALTER TABLE "public"."lesson_grammar" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."lesson_grammar_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."lesson_pattern" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."lesson_pattern_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."lesson_phrase" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."lesson_phrase_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."lesson_vocabulary_control_view" WITH ("security_invoker"='true') AS
 SELECT "id" AS "lesson_id",
    "lesson_key",
    "sequence_number",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('vocabulary_id', "vm"."id", 'source_key', "vm"."source_key", 'thai_script', "vm"."thai_script", 'paiboon', "vm"."paiboon", 'english_gloss', "vm"."english_gloss", 'part_of_speech', "vm"."part_of_speech", 'register', "vm"."register", 'lesson_role', "lv"."role", 'display_order', "lv"."display_order", 'requires_explanation', "lv"."requires_explanation", 'lesson_notes', "lv"."notes", 'status', "vs"."status", 'first_lesson_id', "vs"."first_lesson_id") ORDER BY "lv"."display_order" NULLS FIRST, "lv"."id") AS "jsonb_agg"
           FROM (("public"."lesson_vocabulary" "lv"
             JOIN "public"."vocabulary_master" "vm" ON (("vm"."id" = "lv"."vocabulary_id")))
             JOIN "public"."vocabulary_status" "vs" ON (("vs"."vocabulary_id" = "vm"."id")))
          WHERE (("lv"."lesson_id" = "l"."id") AND ("vs"."first_lesson_id" = "l"."id"))), '[]'::"jsonb") AS "new_vocabulary",
    COALESCE(( SELECT "jsonb_agg"("jsonb_build_object"('vocabulary_id', "vm"."id", 'source_key', "vm"."source_key", 'thai_script', "vm"."thai_script", 'paiboon', "vm"."paiboon", 'english_gloss', "vm"."english_gloss", 'part_of_speech', "vm"."part_of_speech", 'register', "vm"."register", 'lesson_role', "lv"."role", 'display_order', "lv"."display_order", 'requires_explanation', "lv"."requires_explanation", 'lesson_notes', "lv"."notes", 'status', "vs"."status", 'first_lesson_id', "vs"."first_lesson_id") ORDER BY "vs"."first_lesson_id", "lv"."display_order" NULLS FIRST, "lv"."id") AS "jsonb_agg"
           FROM (("public"."lesson_vocabulary" "lv"
             JOIN "public"."vocabulary_master" "vm" ON (("vm"."id" = "lv"."vocabulary_id")))
             JOIN "public"."vocabulary_status" "vs" ON (("vs"."vocabulary_id" = "vm"."id")))
          WHERE (("lv"."lesson_id" = "l"."id") AND ("vs"."first_lesson_id" IS NOT NULL) AND ("vs"."first_lesson_id" < "l"."id"))), '[]'::"jsonb") AS "linked_previous_vocabulary"
   FROM "public"."lessons" "l";


ALTER VIEW "public"."lesson_vocabulary_control_view" OWNER TO "postgres";


ALTER TABLE "public"."lesson_vocabulary" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."lesson_vocabulary_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."lessons" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."lessons_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."pattern_master" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."pattern_master_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."pattern_status" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."pattern_status_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."phrase_master" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."phrase_master_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."phrase_status" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."phrase_status_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."relationship_pair_rules" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."relationship_pair_rules_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."relationship_pairs" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."relationship_pairs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."revisions" (
    "id" bigint NOT NULL,
    "lesson_id" bigint NOT NULL,
    "range_label" "text",
    "summary" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."revisions" OWNER TO "postgres";


ALTER TABLE "public"."revisions" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."revisions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."vocabulary_master" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."vocabulary_master_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."vocabulary_status" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."vocabulary_status_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."character_profiles"
    ADD CONSTRAINT "character_profiles_character_key_unique" UNIQUE ("character_key");



ALTER TABLE ONLY "public"."character_profiles"
    ADD CONSTRAINT "character_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dialog_blocks"
    ADD CONSTRAINT "dialog_blocks_dialog_block_unique" UNIQUE ("dialog_id", "block_index");



ALTER TABLE ONLY "public"."dialog_blocks"
    ADD CONSTRAINT "dialog_blocks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dialog_blueprint_specs"
    ADD CONSTRAINT "dialog_blueprint_specs_lesson_id_key" UNIQUE ("lesson_id");



ALTER TABLE ONLY "public"."dialog_blueprint_specs"
    ADD CONSTRAINT "dialog_blueprint_specs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dialog_slides"
    ADD CONSTRAINT "dialog_slides_dialog_slide_unique" UNIQUE ("dialog_id", "slide_index");



ALTER TABLE ONLY "public"."dialog_slides"
    ADD CONSTRAINT "dialog_slides_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dialogs"
    ADD CONSTRAINT "dialogs_lesson_id_unique" UNIQUE ("lesson_id");



ALTER TABLE ONLY "public"."dialogs"
    ADD CONSTRAINT "dialogues_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."grammar_master"
    ADD CONSTRAINT "grammar_master_concept_key_unique" UNIQUE ("concept_key");



ALTER TABLE ONLY "public"."grammar_master"
    ADD CONSTRAINT "grammar_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."grammar_status"
    ADD CONSTRAINT "grammar_status_grammar_id_unique" UNIQUE ("grammar_id");



ALTER TABLE ONLY "public"."grammar_status"
    ADD CONSTRAINT "grammar_status_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lesson_grammar"
    ADD CONSTRAINT "lesson_grammar_lesson_grammar_unique" UNIQUE ("lesson_id", "grammar_id");



ALTER TABLE ONLY "public"."lesson_grammar"
    ADD CONSTRAINT "lesson_grammar_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lesson_pattern"
    ADD CONSTRAINT "lesson_pattern_lesson_pattern_unique" UNIQUE ("lesson_id", "pattern_id");



ALTER TABLE ONLY "public"."lesson_pattern"
    ADD CONSTRAINT "lesson_pattern_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lesson_phrase"
    ADD CONSTRAINT "lesson_phrase_lesson_phrase_unique" UNIQUE ("lesson_id", "phrase_id");



ALTER TABLE ONLY "public"."lesson_phrase"
    ADD CONSTRAINT "lesson_phrase_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lesson_vocabulary"
    ADD CONSTRAINT "lesson_vocabulary_lesson_vocab_unique" UNIQUE ("lesson_id", "vocabulary_id");



ALTER TABLE ONLY "public"."lesson_vocabulary"
    ADD CONSTRAINT "lesson_vocabulary_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lessons"
    ADD CONSTRAINT "lessons_lesson_key_unique" UNIQUE ("lesson_key");



ALTER TABLE ONLY "public"."lessons"
    ADD CONSTRAINT "lessons_level_section_sequence_unique" UNIQUE ("cefr_level", "section_key", "sequence_number");



ALTER TABLE ONLY "public"."lessons"
    ADD CONSTRAINT "lessons_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lessons"
    ADD CONSTRAINT "lessons_slug_unique" UNIQUE ("slug");



ALTER TABLE ONLY "public"."pattern_master"
    ADD CONSTRAINT "pattern_master_pattern_key_unique" UNIQUE ("pattern_key");



ALTER TABLE ONLY "public"."pattern_master"
    ADD CONSTRAINT "pattern_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pattern_status"
    ADD CONSTRAINT "pattern_status_pattern_id_unique" UNIQUE ("pattern_id");



ALTER TABLE ONLY "public"."pattern_status"
    ADD CONSTRAINT "pattern_status_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."phrase_master"
    ADD CONSTRAINT "phrase_master_phrase_key_unique" UNIQUE ("phrase_key");



ALTER TABLE ONLY "public"."phrase_master"
    ADD CONSTRAINT "phrase_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."phrase_status"
    ADD CONSTRAINT "phrase_status_phrase_id_unique" UNIQUE ("phrase_id");



ALTER TABLE ONLY "public"."phrase_status"
    ADD CONSTRAINT "phrase_status_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."relationship_pair_rules"
    ADD CONSTRAINT "relationship_pair_rules_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."relationship_pairs"
    ADD CONSTRAINT "relationship_pairs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."relationship_pairs"
    ADD CONSTRAINT "relationship_pairs_unique_pair" UNIQUE ("character_a_id", "character_b_id");



ALTER TABLE ONLY "public"."revisions"
    ADD CONSTRAINT "revisions_lesson_id_unique" UNIQUE ("lesson_id");



ALTER TABLE ONLY "public"."revisions"
    ADD CONSTRAINT "revisions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vocabulary_master"
    ADD CONSTRAINT "vocabulary_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vocabulary_master"
    ADD CONSTRAINT "vocabulary_master_source_key_unique" UNIQUE ("source_key");



ALTER TABLE ONLY "public"."vocabulary_status"
    ADD CONSTRAINT "vocabulary_status_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vocabulary_status"
    ADD CONSTRAINT "vocabulary_status_vocabulary_id_unique" UNIQUE ("vocabulary_id");



CREATE UNIQUE INDEX "uq_lesson_vocabulary_single_target" ON "public"."lesson_vocabulary" USING "btree" ("vocabulary_id") WHERE ("role" = 'target'::"text");



CREATE OR REPLACE TRIGGER "trg_initialize_grammar_status" AFTER INSERT ON "public"."grammar_master" FOR EACH ROW EXECUTE FUNCTION "public"."fn_initialize_grammar_status"();



CREATE OR REPLACE TRIGGER "trg_initialize_pattern_status" AFTER INSERT ON "public"."pattern_master" FOR EACH ROW EXECUTE FUNCTION "public"."fn_initialize_pattern_status"();



CREATE OR REPLACE TRIGGER "trg_initialize_phrase_status" AFTER INSERT ON "public"."phrase_master" FOR EACH ROW EXECUTE FUNCTION "public"."fn_initialize_phrase_status"();



CREATE OR REPLACE TRIGGER "trg_initialize_vocabulary_status" AFTER INSERT ON "public"."vocabulary_master" FOR EACH ROW EXECUTE FUNCTION "public"."fn_initialize_vocabulary_status"();



CREATE OR REPLACE TRIGGER "trg_lesson_grammar_state_machine" BEFORE INSERT ON "public"."lesson_grammar" FOR EACH ROW EXECUTE FUNCTION "public"."fn_lesson_grammar_state_machine"();



CREATE OR REPLACE TRIGGER "trg_lesson_pattern_state_machine" BEFORE INSERT ON "public"."lesson_pattern" FOR EACH ROW EXECUTE FUNCTION "public"."fn_lesson_pattern_state_machine"();



CREATE OR REPLACE TRIGGER "trg_lesson_phrase_state_machine" BEFORE INSERT ON "public"."lesson_phrase" FOR EACH ROW EXECUTE FUNCTION "public"."fn_lesson_phrase_state_machine"();



CREATE OR REPLACE TRIGGER "trg_lesson_vocabulary_state_machine" BEFORE INSERT OR UPDATE ON "public"."lesson_vocabulary" FOR EACH ROW EXECUTE FUNCTION "public"."fn_lesson_vocabulary_state_machine"();



ALTER TABLE ONLY "public"."dialog_blocks"
    ADD CONSTRAINT "dialog_blocks_dialog_fk" FOREIGN KEY ("dialog_id") REFERENCES "public"."dialogs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."dialog_blueprint_specs"
    ADD CONSTRAINT "dialog_blueprint_specs_lesson_id_fkey" FOREIGN KEY ("lesson_id") REFERENCES "public"."lessons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."dialog_blueprint_specs"
    ADD CONSTRAINT "dialog_blueprint_specs_relationship_pair_id_fkey" FOREIGN KEY ("relationship_pair_id") REFERENCES "public"."relationship_pairs"("id");



ALTER TABLE ONLY "public"."dialog_slides"
    ADD CONSTRAINT "dialog_slides_dialog_fk" FOREIGN KEY ("dialog_id") REFERENCES "public"."dialogs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."dialogs"
    ADD CONSTRAINT "dialogs_lesson_fk" FOREIGN KEY ("lesson_id") REFERENCES "public"."lessons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."grammar_status"
    ADD CONSTRAINT "grammar_status_first_lesson_fk" FOREIGN KEY ("first_lesson_id") REFERENCES "public"."lessons"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."grammar_status"
    ADD CONSTRAINT "grammar_status_grammar_fk" FOREIGN KEY ("grammar_id") REFERENCES "public"."grammar_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_grammar"
    ADD CONSTRAINT "lesson_grammar_grammar_fk" FOREIGN KEY ("grammar_id") REFERENCES "public"."grammar_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_grammar"
    ADD CONSTRAINT "lesson_grammar_lesson_fk" FOREIGN KEY ("lesson_id") REFERENCES "public"."lessons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_pattern"
    ADD CONSTRAINT "lesson_pattern_lesson_fk" FOREIGN KEY ("lesson_id") REFERENCES "public"."lessons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_pattern"
    ADD CONSTRAINT "lesson_pattern_pattern_fk" FOREIGN KEY ("pattern_id") REFERENCES "public"."pattern_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_phrase"
    ADD CONSTRAINT "lesson_phrase_lesson_fk" FOREIGN KEY ("lesson_id") REFERENCES "public"."lessons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_phrase"
    ADD CONSTRAINT "lesson_phrase_phrase_fk" FOREIGN KEY ("phrase_id") REFERENCES "public"."phrase_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_vocabulary"
    ADD CONSTRAINT "lesson_vocabulary_lesson_fk" FOREIGN KEY ("lesson_id") REFERENCES "public"."lessons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."lesson_vocabulary"
    ADD CONSTRAINT "lesson_vocabulary_vocabulary_fk" FOREIGN KEY ("vocabulary_id") REFERENCES "public"."vocabulary_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pattern_status"
    ADD CONSTRAINT "pattern_status_first_lesson_fk" FOREIGN KEY ("first_lesson_id") REFERENCES "public"."lessons"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."pattern_status"
    ADD CONSTRAINT "pattern_status_pattern_fk" FOREIGN KEY ("pattern_id") REFERENCES "public"."pattern_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."phrase_status"
    ADD CONSTRAINT "phrase_status_first_lesson_fk" FOREIGN KEY ("first_lesson_id") REFERENCES "public"."lessons"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."phrase_status"
    ADD CONSTRAINT "phrase_status_phrase_fk" FOREIGN KEY ("phrase_id") REFERENCES "public"."phrase_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."relationship_pair_rules"
    ADD CONSTRAINT "relationship_pair_rules_relationship_pair_fk" FOREIGN KEY ("relationship_pair_id") REFERENCES "public"."relationship_pairs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."relationship_pairs"
    ADD CONSTRAINT "relationship_pairs_character_a_fk" FOREIGN KEY ("character_a_id") REFERENCES "public"."character_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."relationship_pairs"
    ADD CONSTRAINT "relationship_pairs_character_b_fk" FOREIGN KEY ("character_b_id") REFERENCES "public"."character_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."revisions"
    ADD CONSTRAINT "revisions_lesson_fk" FOREIGN KEY ("lesson_id") REFERENCES "public"."lessons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vocabulary_status"
    ADD CONSTRAINT "vocabulary_status_first_lesson_fk" FOREIGN KEY ("first_lesson_id") REFERENCES "public"."lessons"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."vocabulary_status"
    ADD CONSTRAINT "vocabulary_status_vocabulary_fk" FOREIGN KEY ("vocabulary_id") REFERENCES "public"."vocabulary_master"("id") ON DELETE CASCADE;



CREATE POLICY "Active relationship pairs are readable by everyone" ON "public"."relationship_pairs" FOR SELECT TO "authenticated", "anon" USING (("is_active" = true));



CREATE POLICY "Blocks of published dialogs are readable by everyone" ON "public"."dialog_blocks" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM ("public"."dialogs" "d"
     JOIN "public"."lessons" "l" ON (("l"."id" = "d"."lesson_id")))
  WHERE (("d"."id" = "dialog_blocks"."dialog_id") AND ("l"."is_published" = true)))));



CREATE POLICY "Character profiles are readable by everyone" ON "public"."character_profiles" FOR SELECT TO "authenticated", "anon" USING (true);



CREATE POLICY "Dialogs of published lessons are readable by everyone" ON "public"."dialogs" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "public"."lessons" "l"
  WHERE (("l"."id" = "dialogs"."lesson_id") AND ("l"."is_published" = true)))));



CREATE POLICY "Grammar used in published lessons is readable by everyone" ON "public"."grammar_master" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM ("public"."lesson_grammar" "lg"
     JOIN "public"."lessons" "l" ON (("l"."id" = "lg"."lesson_id")))
  WHERE (("lg"."grammar_id" = "grammar_master"."id") AND ("l"."is_published" = true)))));



CREATE POLICY "Lesson grammar of published lessons are readable by everyone" ON "public"."lesson_grammar" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "public"."lessons" "l"
  WHERE (("l"."id" = "lesson_grammar"."lesson_id") AND ("l"."is_published" = true)))));



CREATE POLICY "Lesson pattern of published lessons are readable by everyone" ON "public"."lesson_pattern" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "public"."lessons" "l"
  WHERE (("l"."id" = "lesson_pattern"."lesson_id") AND ("l"."is_published" = true)))));



CREATE POLICY "Lesson phrases of published lessons are readable by everyone" ON "public"."lesson_phrase" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "public"."lessons" "l"
  WHERE (("l"."id" = "lesson_phrase"."lesson_id") AND ("l"."is_published" = true)))));



CREATE POLICY "Lesson vocabulary of published lessons are readable by everyone" ON "public"."lesson_vocabulary" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "public"."lessons" "l"
  WHERE (("l"."id" = "lesson_vocabulary"."lesson_id") AND ("l"."is_published" = true)))));



CREATE POLICY "Patterns used in published lessons are readable by everyone" ON "public"."pattern_master" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM ("public"."lesson_pattern" "lp"
     JOIN "public"."lessons" "l" ON (("l"."id" = "lp"."lesson_id")))
  WHERE (("lp"."pattern_id" = "pattern_master"."id") AND ("l"."is_published" = true)))));



CREATE POLICY "Phrases used in published lessons are readable by everyone" ON "public"."phrase_master" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM ("public"."lesson_phrase" "lp"
     JOIN "public"."lessons" "l" ON (("l"."id" = "lp"."lesson_id")))
  WHERE (("lp"."phrase_id" = "phrase_master"."id") AND ("l"."is_published" = true)))));



CREATE POLICY "Published lessons are readable by everyone" ON "public"."lessons" FOR SELECT TO "authenticated", "anon" USING (("is_published" = true));



CREATE POLICY "Revisions of published lessons are readable by everyone" ON "public"."revisions" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "public"."lessons" "l"
  WHERE (("l"."id" = "revisions"."lesson_id") AND ("l"."is_published" = true)))));



CREATE POLICY "Rules of active relationship pairs are readable by everyone" ON "public"."relationship_pair_rules" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM "public"."relationship_pairs" "rp"
  WHERE (("rp"."id" = "relationship_pair_rules"."relationship_pair_id") AND ("rp"."is_active" = true)))));



CREATE POLICY "Slides of published dialogs are readable by everyone" ON "public"."dialog_slides" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM ("public"."dialogs" "d"
     JOIN "public"."lessons" "l" ON (("l"."id" = "d"."lesson_id")))
  WHERE (("d"."id" = "dialog_slides"."dialog_id") AND ("l"."is_published" = true)))));



CREATE POLICY "Vocabulary used in published lessons is readable by everyone" ON "public"."vocabulary_master" FOR SELECT TO "authenticated", "anon" USING ((EXISTS ( SELECT 1
   FROM ("public"."lesson_vocabulary" "lv"
     JOIN "public"."lessons" "l" ON (("l"."id" = "lv"."lesson_id")))
  WHERE (("lv"."vocabulary_id" = "vocabulary_master"."id") AND ("l"."is_published" = true)))));



ALTER TABLE "public"."character_profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."dialog_blocks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."dialog_blueprint_specs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."dialog_slides" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."dialogs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."grammar_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."grammar_status" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lesson_grammar" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lesson_pattern" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lesson_phrase" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lesson_vocabulary" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."lessons" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pattern_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pattern_status" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."phrase_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."phrase_status" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."relationship_pair_rules" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."relationship_pairs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."revisions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vocabulary_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vocabulary_status" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."character_profiles" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."character_profiles" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."character_profiles" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."character_profiles_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."character_profiles_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."character_profiles_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."dialog_blocks" TO "anon";
GRANT ALL ON TABLE "public"."dialog_blocks" TO "authenticated";
GRANT ALL ON TABLE "public"."dialog_blocks" TO "service_role";



GRANT ALL ON SEQUENCE "public"."dialog_blocks_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."dialog_blocks_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."dialog_blocks_id_seq" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."dialog_blueprint_specs" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."dialog_blueprint_specs" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."dialog_blueprint_specs" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."dialog_blueprint_specs_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."dialog_blueprint_specs_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."dialog_blueprint_specs_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."dialog_slides" TO "anon";
GRANT ALL ON TABLE "public"."dialog_slides" TO "authenticated";
GRANT ALL ON TABLE "public"."dialog_slides" TO "service_role";



GRANT ALL ON SEQUENCE "public"."dialog_slides_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."dialog_slides_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."dialog_slides_id_seq" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."dialogs" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."dialogs" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "public"."dialogs" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."dialogues_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."dialogues_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."dialogues_id_seq" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."grammar_master" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."grammar_master" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."grammar_master" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."grammar_master_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."grammar_master_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."grammar_master_id_seq" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."grammar_status" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."grammar_status" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."grammar_status" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."grammar_status_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."grammar_status_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."grammar_status_id_seq" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lessons" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lessons" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lessons" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_grammar_view" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_grammar_view" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_grammar_view" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."pattern_master" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."pattern_master" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."pattern_master" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."pattern_status" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."pattern_status" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."pattern_status" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_pattern_view" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_pattern_view" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_pattern_view" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."phrase_master" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."phrase_master" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."phrase_master" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."phrase_status" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."phrase_status" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."phrase_status" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_phrase_view" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_phrase_view" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_phrase_view" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."vocabulary_master" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."vocabulary_master" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."vocabulary_master" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."vocabulary_status" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."vocabulary_status" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."vocabulary_status" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_vocabulary_view" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_vocabulary_view" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_available_vocabulary_view" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_grammar" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_grammar" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_grammar" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_pattern" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_pattern" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_pattern" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_phrase" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_phrase" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_phrase" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_vocabulary" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_vocabulary" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_vocabulary" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_blueprint_view" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_blueprint_view" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_blueprint_view" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."relationship_pair_rules" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."relationship_pair_rules" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."relationship_pair_rules" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."relationship_pairs" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."relationship_pairs" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."relationship_pairs" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_continuity_options_view" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_continuity_options_view" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_continuity_options_view" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."lesson_grammar_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."lesson_grammar_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."lesson_grammar_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."lesson_pattern_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."lesson_pattern_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."lesson_pattern_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."lesson_phrase_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."lesson_phrase_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."lesson_phrase_id_seq" TO "service_role";



GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_vocabulary_control_view" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_vocabulary_control_view" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."lesson_vocabulary_control_view" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."lesson_vocabulary_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."lesson_vocabulary_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."lesson_vocabulary_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."lessons_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."lessons_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."lessons_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."pattern_master_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."pattern_master_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."pattern_master_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."pattern_status_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."pattern_status_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."pattern_status_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."phrase_master_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."phrase_master_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."phrase_master_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."phrase_status_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."phrase_status_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."phrase_status_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."relationship_pair_rules_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."relationship_pair_rules_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."relationship_pair_rules_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."relationship_pairs_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."relationship_pairs_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."relationship_pairs_id_seq" TO "service_role";



GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."revisions" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."revisions" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."revisions" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."revisions_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."revisions_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."revisions_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."vocabulary_master_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."vocabulary_master_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."vocabulary_master_id_seq" TO "service_role";



GRANT UPDATE ON SEQUENCE "public"."vocabulary_status_id_seq" TO "anon";
GRANT UPDATE ON SEQUENCE "public"."vocabulary_status_id_seq" TO "authenticated";
GRANT UPDATE ON SEQUENCE "public"."vocabulary_status_id_seq" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT UPDATE ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT UPDATE ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT UPDATE ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "service_role";







