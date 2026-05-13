import type { LessonRow, SectionLessonCardItem } from "../types";
// ik heb deze mapper nodig omdat ik in de database snake_case gebruik en in de frontend camelCase.
export function mapLessonRowToSectionItem(
  row: LessonRow,
): SectionLessonCardItem {
  return {
    lessonKey: row.lesson_key,
    slug: row.slug,
    lessonType: row.lesson_type,
    title: row.title,
    subtitle: row.subtitle,
    sequenceNumber: row.sequence_number,
    accessTier: row.access_tier,
  };
}
