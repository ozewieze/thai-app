import type {
  LessonRow,
  DialogRow,
  DialogData,
  LessonWithDialog,
} from "../types";

export function mapDialogRowToDialogData(row: DialogRow): DialogData {
  // Sorteer blokken op block_index en map naar camelCase.
  const blocks = row.dialog_blocks
    .sort((a, b) => a.block_index - b.block_index)
    .map((block) => ({
      id: block.id,
      index: block.block_index,
      thaiLine: block.thai_text,
      transliterationLine: block.transliteration,
      translationLine: block.translation_en,
      audioUrl: block.audio_url,
      fullStartMs: block.full_start_ms,
      fullEndMs: block.full_end_ms,
    }));

  // Bouw een lookup map van block_index → timestamps.
  // Gebruikt om slide-tijdstippen af te leiden zonder extra queries.
  const blockTimingByIndex = new Map(
    blocks.map((b) => [
      b.index,
      { startMs: b.fullStartMs, endMs: b.fullEndMs },
    ]),
  );

  // Sorteer slides op slide_index en bereken start/end timestamps
  // uit de bijbehorende blokken (first_block_index en last_block_index).
  const slides = (row.dialog_slides ?? [])
    .sort((a, b) => a.slide_index - b.slide_index)
    .map((slide) => ({
      id: slide.id,
      slideIndex: slide.slide_index,
      firstBlockIndex: slide.first_block_index,
      lastBlockIndex: slide.last_block_index,
      imageUrl: slide.image_url,
      startMs: blockTimingByIndex.get(slide.first_block_index)?.startMs ?? null,
      endMs: blockTimingByIndex.get(slide.last_block_index)?.endMs ?? null,
    }));

  return {
    id: row.id,
    title: row.title,
    subtitle: row.subtitle,
    register: row.register,
    sceneSummary: row.scene_summary,
    learningFocus: row.learning_focus,
    audioUrl: row.audio_url,
    audioDurationMs: row.audio_duration_ms,
    blocks,
    slides,
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
