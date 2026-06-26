import type {
  LessonRow,
  DialogRow,
  DialogData,
  LessonWithDialog,
} from "../types";

export function mapDialogRowToDialogData(row: DialogRow): DialogData {
  return {
    id: row.id,
    title: row.title,
    subtitle: row.subtitle,
    register: row.register,
    sceneSummary: row.scene_summary,
    learningFocus: row.learning_focus,
    audioUrl: row.audio_url,
    blocks: row.dialog_blocks
      .sort((a, b) => a.block_index - b.block_index)
      .map((block) => ({
        id: block.id,
        index: block.block_index,
        thaiLine: block.thai_text,
        transliterationLine: block.transliteration,
        translationLine: block.translation_en,
        audioUrl: block.audio_url,
      })),
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
