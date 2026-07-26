import { createClient } from "@/lib/supabase/server";
import type {
  LessonRow,
  DialogRow,
  LessonWithDialog,
  LessonNav,
  LessonVocabularyItemRow,
  LanguageNoteRow,
  LessonInstructionalContent,
} from "../types";
import {
  mapLessonRowToLessonWithDialog,
  mapLessonInstructionalContent,
} from "./mappers";

export async function getLessonBySlug(
  slug: string,
): Promise<LessonWithDialog | null> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("lessons")
    .select(
      `
      id,
      lesson_key,
      slug,
      title,
      subtitle,
      cefr_level,
      lesson_type,
      section_key,
      access_tier,
      dialogs (
        id,
        title,
        subtitle,
        register,
        scene_summary,
        learning_focus,
        audio_url,
        audio_duration_ms,
        dialog_blocks (
          id,
          block_index,
          thai_text,
          transliteration,
          translation_en,
          audio_url,
          full_start_ms,
          full_end_ms
        ),
        dialog_slides (
          id,
          slide_index,
          first_block_index,
          last_block_index,
          image_url
        )
      )
    `,
    )
    .eq("slug", slug)
    .eq("is_published", true)
    .single();

  if (error) {
    return null;
  }

  // Supabase herkent de UNIQUE constraint op dialogs.lesson_id
  // en geeft de dialog terug als een enkel object, niet als array.
  // De Supabase TypeScript-types weten dit niet en typen het als array[].
  // Via `unknown` vertellen we TypeScript: Laat het oude afgeleide type even los.
  const dialogRow = (data.dialogs as unknown as DialogRow | null) ?? null;

  return mapLessonRowToLessonWithDialog(data as LessonRow, dialogRow);
}

export async function getLessonNav(
  lessonId: number,
  sectionKey: string | null,
): Promise<LessonNav> {
  if (!sectionKey) return { prevSlug: null, nextSlug: null };

  const supabase = await createClient();

  const [prevResult, nextResult] = await Promise.all([
    supabase
      .from("lessons")
      .select("slug")
      .eq("is_published", true)
      .eq("section_key", sectionKey) //de section_key wordt gebruikt om de vorige les te vinden binnen dezelfde sectie
      .lt("id", lessonId) //lt betekent "less than" en wordt gebruikt om de vorige les te vinden op basis van de ID
      .order("id", { ascending: false })
      .limit(1)
      .maybeSingle(), // gebruikt in plaats van single omdat maybeSingle null kan teruggeven als er geen vorige les is, in plaats van een fout te gooien.
    supabase
      .from("lessons")
      .select("slug")
      .eq("is_published", true)
      .eq("section_key", sectionKey)
      .gt("id", lessonId)
      .order("id", { ascending: true })
      .limit(1)
      .maybeSingle(),
  ]);

  return {
    prevSlug: prevResult.data?.slug ?? null,
    nextSlug: nextResult.data?.slug ?? null,
  };
}

/**
 * LessonInstructionalContentRows
 *
 * De ruwe (snake_case) rijen voor het instructiedeel van een les,
 * vóór het mappen naar camelCase. Interne tussenvorm tussen de query
 * (deze functie) en de mapper (mapLessonInstructionalContent, stap 2.3).
 */
export type LessonInstructionalContentRows = {
  vocab: LessonVocabularyItemRow[];
  notes: LanguageNoteRow[];
};

/**
 * getLessonInstructionalContentRows
 *
 * Haalt de Vocabulary Cards en Language Notes van één les op met twee
 * onafhankelijke, parallelle PostgREST-query's (Promise.all), net als
 * getLessonNav. Elke query mapt straks naar één type; een fout in de
 * ene tak raakt de andere niet.
 *
 * Waarom twee losse query's en geen grote geneste select: elk resultaat
 * is los leesbaar en los te debuggen, en PostgREST leidt de types per
 * query af. 
 *
 * Sortering:
 *   - vocab op display_order met nullsFirst:false — display_order is
 *     nullable (EXISTING); ongenummerde items horen ONDERAAN, niet
 *     bovenaan zoals de authoring-views (NULLS FIRST) doen.
 *   - notes op display_order (NOT NULL) oplopend.
 *   - De geneste blokken en voorbeelden worden NIET hier gesorteerd
 *     maar in de mapper: PostgREST sorteert diepere niveaus niet
 *     betrouwbaar, en de bestaande dialog-mapper sorteert ook in TS.
 *
 * RLS beperkt de resultaten automatisch tot gepubliceerde lessen; deze
 * functie hoeft daar niets extra voor te doen.
 *
 * De `as unknown as`-cast is nodig zolang er geen gegenereerde
 * database-types zijn (P13), net als in getLessonBySlug hierboven.
 *
 * TE VERIFIËREN OP DE LOKALE DATABASE (kan niet vanuit de sandbox):
 * de geneste embedding `language_note_blocks → language_note_examples`
 * hangt aan de samengestelde FK (block_id, block_type). Werkt de select
 * hieronder niet, gebruik dan de expliciete FK-hint:
 *   language_note_examples!language_note_examples_block_fk ( ... )
 */
export async function getLessonInstructionalContentRows(
  lessonId: number,
): Promise<LessonInstructionalContentRows> {
  const supabase = await createClient();

  const [vocabResult, notesResult] = await Promise.all([
    supabase
      .from("lesson_vocabulary")
      .select(
        `
        id,
        role,
        display_order,
        requires_explanation,
        notes,
        vocabulary_master (
          id,
          source_key,
          thai_script,
          paiboon,
          english_gloss,
          part_of_speech,
          register,
          usage_note,
          audio_url,
          voice_key,
          vocabulary_examples (
            id,
            display_order,
            thai_script,
            paiboon,
            translation_en,
            audio_url,
            voice_key
          )
        )
      `,
      )
      .eq("lesson_id", lessonId)
      .order("display_order", { ascending: true, nullsFirst: false }),

    supabase
      .from("language_notes")
      .select(
        `
        id,
        title,
        display_order,
        language_note_blocks (
          id,
          display_order,
          block_type,
          heading,
          content,
          language_note_examples (
            id,
            display_order,
            thai_script,
            paiboon,
            translation_en,
            audio_url,
            voice_key
          )
        )
      `,
      )
      .eq("lesson_id", lessonId)
      .order("display_order", { ascending: true }),
  ]);

  // Een lege sectie is normaal (niet elke les heeft vocab of notes);
  // dat levert data:[] zonder error. Een échte error (bv. een
  // permissieprobleem) loggen we en behandelen we als "geen content",
  // zodat de kern van de les (de dialoog) blijft renderen. De lege
  // sectie wordt in de UI volledig weggelaten.
  if (vocabResult.error) {
    console.error("getLessonInstructionalContent vocab:", vocabResult.error);
  }
  if (notesResult.error) {
    console.error("getLessonInstructionalContent notes:", notesResult.error);
  }

  const vocab =
    (vocabResult.data as unknown as LessonVocabularyItemRow[] | null) ?? [];
  const notes =
    (notesResult.data as unknown as LanguageNoteRow[] | null) ?? [];

  return { vocab, notes };
}

/**
 * getLessonInstructionalContent
 *
 * Publieke functie voor de lespagina: haalt de ruwe rijen op
 * (getLessonInstructionalContentRows) en mapt ze naar de frontend-vorm
 * (LessonInstructionalContent). Dit is wat page.tsx straks aanroept,
 * naast getLessonBySlug en getLessonNav.
 */
export async function getLessonInstructionalContent(
  lessonId: number,
): Promise<LessonInstructionalContent> {
  const rows = await getLessonInstructionalContentRows(lessonId);
  return mapLessonInstructionalContent(rows);
}
