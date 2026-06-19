import { createClient } from "@/lib/supabase/server";
import type { LessonWithDialog } from "../types";
import type { LessonRow, DialogRow } from "./mappers";
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
        thai_text,
        transliteration,
        translation_en,
        register,
        scene_summary,
        learning_focus
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
