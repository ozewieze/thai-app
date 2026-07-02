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
 *
 * `full_start_ms` / `full_end_ms`: positie van dit blok in de
 * samengevoegde full-dialog audio (dialogs.audio_url).
 * Zijn null zolang merge-audio.mjs nog niet gedraaid heeft.
 */
export type DialogBlockRow = {
  id: number;
  dialog_id: number;
  block_index: number;
  thai_text: string;
  transliteration: string | null;
  translation_en: string | null;
  audio_url: string | null;
  full_start_ms: number | null;
  full_end_ms: number | null;
};

/**
 * DialogSlideRow
 *
 * Één rij uit de `dialog_slides` tabel.
 * Een slide beslaat een bereik van blokken: first_block_index t/m last_block_index.
 * De tijdstippen worden afgeleid uit de bijbehorende dialog_blocks.
 */
export type DialogSlideRow = {
  id: number;
  slide_index: number;
  first_block_index: number;
  last_block_index: number;
  image_url: string | null;
};

/**
 * DialogRow
 *
 * De velden die we uit de `dialogs` tabel ophalen.
 * De database geeft één dialoog per lesson (UNIQUE constraint op lesson_id).
 * Supabase geeft dit terug als een enkel object (niet als array) vanwege die constraint.
 * Bevat de geneste `dialog_blocks` en `dialog_slides` als arrays.
 */
export type DialogRow = {
  id: number;
  title: string | null;
  subtitle: string | null;
  register: "neutral" | "formal" | "informal" | "polite" | "colloquial" | null;
  scene_summary: string | null;
  learning_focus: string | null;
  audio_url: string | null;
  dialog_blocks: DialogBlockRow[];
  dialog_slides: DialogSlideRow[];
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
 * `id` is de stabiele database-id, nodig voor audio-URL-koppeling.
 *
 * `fullStartMs` / `fullEndMs`: positie van dit blok in de full-dialog audio.
 * Null zolang merge-audio.mjs nog niet gedraaid heeft voor deze dialoog.
 */
export type DialogBlock = {
  id: number;
  index: number;
  thaiLine: string;
  transliterationLine: string | null;
  translationLine: string | null;
  audioUrl: string | null;
  fullStartMs: number | null;
  fullEndMs: number | null;
};

/**
 * DialogSlide
 *
 * Een visuele slide die één of meerdere aaneengesloten blokken beslaat.
 * `startMs` en `endMs` worden in de mapper afgeleid uit de block-timestamps:
 *   startMs = blocks[firstBlockIndex].fullStartMs
 *   endMs   = blocks[lastBlockIndex].fullEndMs
 * Beide zijn null als de block-timestamps nog niet beschikbaar zijn.
 */
export type DialogSlide = {
  id: number;
  slideIndex: number;
  firstBlockIndex: number;
  lastBlockIndex: number;
  imageUrl: string | null;
  startMs: number | null;
  endMs: number | null;
};

/**
 * DialogData
 *
 * De dialog-data na de mapper: velden zijn omgezet naar camelCase.
 * Bevat de geneste blokken gesorteerd op index en de slides gesorteerd op slideIndex.
 */
export type DialogData = {
  id: number;
  title: string | null;
  subtitle: string | null;
  register: "neutral" | "formal" | "informal" | "polite" | "colloquial" | null;
  sceneSummary: string | null;
  learningFocus: string | null;
  audioUrl: string | null;
  blocks: DialogBlock[];
  slides: DialogSlide[];
};

/**
 * LessonNav
 *
 * Slugs van de vorige en volgende les binnen dezelfde sectie.
 * Gebruikt voor de prev/next navigatie op de lesson-pagina.
 * Waarden zijn `null` als er geen vorige of volgende les bestaat.
 */
export type LessonNav = {
  prevSlug: string | null;
  nextSlug: string | null;
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
