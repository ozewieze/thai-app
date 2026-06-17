import { createClient } from "@/lib/supabase/server";
import type { LessonWithDialog } from "../types";
import type { LessonRow, DialogRow } from "./mappers";
import { mapLessonRowToLessonWithDialog } from "./mappers";

/**
 * getLessonBySlug
 *
 * Haalt een lesson op via zijn slug, inclusief de bijbehorende dialog.
 * Geeft null terug als er geen gepubliceerde lesson bestaat met deze slug.
 *
 * De nested select laat Supabase in een query zowel de lesson-velden
 * als de gekoppelde dialog-velden ophalen via de foreign key
 * (dialogs.lesson_id -> lessons.id).
 */
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

  // Supabase stuurt gerelateerde rijen terug als een array,
  // ook al is er door de UNIQUE constraint maar een dialog per lesson.
  // We pakken het eerste element, of null als de array leeg is.
  const rawDialogs = data.dialogs as DialogRow[] | null;
  const dialogRow = Array.isArray(rawDialogs) ? (rawDialogs[0] ?? null) : null;

  return mapLessonRowToLessonWithDialog(data as LessonRow, dialogRow);
}
