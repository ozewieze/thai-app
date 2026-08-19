import { createClient } from "@/lib/supabase/server";
import { mapLessonRowToSectionItem } from "./mappers";
import type { LessonRow, SectionLessonCardItem } from "../types";
export async function getLessonsForSection(
  level: string,
  section: string,
): Promise<SectionLessonCardItem[]> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("lessons")
    .select(
      "lesson_key, slug, lesson_type, title, subtitle, sequence_number, access_tier",
    )
    .eq("cefr_level", level.toUpperCase())
    .eq("section_key", section)
    .eq("is_published", true)
    .order("sequence_number", { ascending: true });

  if (error) {
    throw new Error(error.message);
  }

  const rows = (data ?? []) as LessonRow[];
  // ik heb deze mapper nodig omdat ik in de database snake_case gebruik en in de frontend camelCase. 
  return rows.map(mapLessonRowToSectionItem);
}
