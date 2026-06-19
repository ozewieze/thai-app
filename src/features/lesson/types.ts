// ============================================================
// Raw database row types (snake_case, zoals Supabase ze stuurt)
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
 * Supabase geeft dit terug als een enkel object (niet als array) vanwege die constraint.
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
// Frontend types (camelCase, zoals de UI ze gebruikt)
// ============================================================

/**
 * DialogData
 *
 * De dialog-data na de mapper: velden zijn omgezet naar camelCase.
 * Bevat de volledige dialoogtekst, nog niet opgesplitst in blokken.
 */
export type DialogData = {
  id: number;
  title: string | null;
  subtitle: string | null;
  thaiText: string;
  transliteration: string | null;
  translationEn: string | null;
  register: "neutral" | "formal" | "informal" | "polite" | "colloquial" | null;
  sceneSummary: string | null;
  learningFocus: string | null;
};

/**
 * DialogBlock
 *
 * Een enkel blok (een regel of uitwisseling) van de dialoog.
 * Ontstaat door de volledige dialoogtekst op te splitsen op regelafbrekingen.
 *
 * `index` is 0-gebaseerd (het eerste blok heeft index 0).
 */
export type DialogBlock = {
  index: number;
  thaiLine: string;
  transliterationLine: string | null;
  translationLine: string | null;
};

/**
 * LessonWithDialog
 *
 * De volledige lesson-data zoals die op de lesson-pagina wordt gebruikt.
 * Bevat alle basisvelden van de lesson plus de bijbehorende dialog.
 *
 * `dialog` is `null` als er nog geen dialog in de database staat voor deze lesson.
 */
export type LessonWithDialog = {
  id: number;
  lessonKey: string;
  slug: string;
  title: string;
  subtitle: string | null;
  cefrLevel: string;
  lessonType: "dialog" | "revision" | "theme" | "story";
  sectionKey: string | null;
  accessTier: "free" | "premium";
  dialog: DialogData | null;
};
