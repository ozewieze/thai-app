import type { LessonRow, DialogRow, DialogData, LessonWithDialog } from "../types";

export function mapDialogRowToDialogData(row: DialogRow): DialogData {
  return {
    id: row.id,
    title: row.title,
    subtitle: row.subtitle,
    thaiText: row.thai_text,
    transliteration: row.transliteration,
    translationEn: row.translation_en,
    register: row.register,
    sceneSummary: row.scene_summary,
    learningFocus: row.learning_focus,
  };
}

export function mapLessonRowToLessonWithDialog(
  lessonRow: LessonRow,
  dialogRow: DialogRow | null,
): LessonWithDialog {
  return {
    id: lessonRow.id,
    lessonKey: lessonRow.lesson_key,
    slug: lessonRow.slug,
    title: lessonRow.title,
    subtitle: lessonRow.subtitle,
    cefrLevel: lessonRow.cefr_level,
    lessonType: lessonRow.lesson_type,
    sectionKey: lessonRow.section_key,
    accessTier: lessonRow.access_tier,
    dialog: dialogRow ? mapDialogRowToDialogData(dialogRow) : null,
  };
}
