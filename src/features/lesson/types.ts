// ============================================================
// Dialog types
// ============================================================

/**
 * DialogData
 *
 * De ruwe dialog-data zoals die uit de database komt.
 * Eén lesson heeft maximaal één dialog (UNIQUE constraint in de DB).
 *
 * Velden zoals `thaiText`, `transliteration` en `translationEn` bevatten
 * de volledige tekst voor de gehele dialoog — nog niet opgesplitst in blokken.
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
 * Één blok (één regel / uitwisseling) van de dialoog.
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

// ============================================================
// Lesson types
// ============================================================

/**
 * LessonWithDialog
 *
 * De volledige lesson-data zoals die op de lesson-pagina wordt gebruikt.
 * Bevat alle basisvelden van de lesson + de bijbehorende dialog (als die bestaat).
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
