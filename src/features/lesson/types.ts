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
 * DialogBlockRow
 *
 * Één rij uit de `dialog_blocks` tabel.
 * Elke rij is één blok (regel/uitwisseling) van de dialoog.
 * `block_index` is 0-gebaseerd en bepaalt de volgorde.
 */
export type DialogBlockRow = {
  id: number;
  dialog_id: number;
  block_index: number;
  thai_text: string;
  transliteration: string | null;
  translation_en: string | null;
};

/**
 * DialogRow
 *
 * De velden die we uit de `dialogs` tabel ophalen.
 * De database geeft één dialoog per lesson (UNIQUE constraint op lesson_id).
 * Supabase geeft dit terug als een enkel object (niet als array) vanwege die constraint.
 * Bevat de geneste `dialog_blocks` als array.
 */
export type DialogRow = {
  id: number;
  title: string | null;
  subtitle: string | null;
  register: "neutral" | "formal" | "informal" | "polite" | "colloquial" | null;
  scene_summary: string | null;
  learning_focus: string | null;
  dialog_blocks: DialogBlockRow[];
};

// ============================================================
// Frontend types (camelCase, zoals de UI ze gebruikt)
// ============================================================

/**
 * DialogBlock
 *
 * Een enkel blok (een regel of uitwisseling) van de dialoog.
 * Komt rechtstreeks uit de `dialog_blocks` tabel via de mapper.
 *
 * `index` is 0-gebaseerd (het eerste blok heeft index 0).
 * `id` is de stabiele database-id, nodig voor audio-URL-koppeling (stap 2).
 */
export type DialogBlock = {
  id: number;
  index: number;
  thaiLine: string;
  transliterationLine: string | null;
  translationLine: string | null;
};

/**
 * DialogData
 *
 * De dialog-data na de mapper: velden zijn omgezet naar camelCase.
 * Bevat de geneste blokken gesorteerd op index.
 */
export type DialogData = {
  id: number;
  title: string | null;
  subtitle: string | null;
  register: "neutral" | "formal" | "informal" | "polite" | "colloquial" | null;
  sceneSummary: string | null;
  learningFocus: string | null;
  blocks: DialogBlock[];
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
