import { createClient } from "@/lib/supabase/server";
import type {
  LessonRow,
  DialogRow,
  LessonWithDialog,
  LessonNav,
} from "../types";
import { mapLessonRowToLessonWithDialog } from "./mappers";

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
  // Via `unknown` vertellen we TypeScript dat wij dit beter weten.
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
