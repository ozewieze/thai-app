import type { DialogData, LessonWithDialog } from "../types";

// ============================================================
// Ruwe database-rij types (snake_case, zoals Supabase ze stuurt)
// ============================================================

/**
 * LessonRow
 *
 * De velden die we uit de `lessons` tabel ophalen.
 * Namen zijn in snake_case, precies zoals de database ze terugstuurt.
 */
export type LessonRow = {
  id: number;
  lesson_key: string;
  slug: string;
  title: string;
  subtitle: string | null;
  cefr_level: string;
  lesson_type: "dialog" | "revision" | "theme" | "story";
  section_key: string | null;
  access_tier: "free" | "premium";
};

/**
 * DialogRow
 *
 * De velden die we uit de `dialogs` tabel ophalen.
 * De database geeft één dialoog per lesson (UNIQUE constraint op lesson_id).
 * Supabase stuurt dit terug als een array — we pakken altijd het eerste element.
 */
export type DialogRow = {
  id: number;
  title: string | null;
  subtitle: string | null;
  thai_text: string;
  transliteration: string | null;
  translation_en: string | null;
  register: "neutral" | "formal" | "informal" | "polite" | "colloquial" | null;
  scene_summary: string | null;
  learning_focus: string | null;
};

// ============================================================
// Mappers: van snake_case naar camelCase
// ============================================================

/**
 * mapDialogRowToDialogData
 *
 * Zet één ruwe DialogRow om naar het DialogData-type dat de frontend gebruikt.
 */
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

/**
 * mapLessonRowToLessonWithDialog
 *
 * Zet een ruwe LessonRow (met optioneel een DialogRow) om naar
 * het LessonWithDialog-type dat de lesson-pagina gebruikt.
 */
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
