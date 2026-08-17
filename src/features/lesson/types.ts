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
  // Exacte totale duur (ms) van de samengevoegde full-dialog audio, gezet
  // door scripts/merge-audio.mjs. Null zolang deze dialoog nog niet (met
  // de bijgewerkte scriptversie) samengevoegd is.
  audio_duration_ms: number | null;
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
  // Zie DialogRow.audio_duration_ms — null zolang nog niet (opnieuw)
  // samengevoegd sinds deze kolom bestaat.
  audioDurationMs: number | null;
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

// ============================================================
// Zichtbaarheidscontrols (gedeeld type)
// ============================================================

/**
 * Visibility
 *
 * Welke van de drie leeslagen zichtbaar zijn. Gebruikt door de
 * dialoogspeler (DialogBlock/DialogPlayer) als actief studie-instrument.
 * Woonde vroeger in DialogBlock.tsx; naar types.ts verplaatst tijdens de
 * lespagina-refactor. (De instructiecontent gebruikt een eenvoudiger
 * boolean-voorkeur, zie TransliterationToggle.)
 */
export type Visibility = {
  thai: boolean;
  transliteration: boolean;
  english: boolean;
};

// ============================================================
// Instructiecontent — raw database row types (snake_case)
// ============================================================

/**
 * VocabularyExampleRow
 *
 * Eén rij uit `vocabulary_examples`: een canoniek voorbeeld bij één
 * woord (owner = vocabulary_master). `audio_url`/`voice_key` zijn
 * nullable tijdens authoring; volledigheid checkt het latere
 * publicatierapport, niet een constraint.
 */
export type VocabularyExampleRow = {
  id: number;
  display_order: number;
  thai_script: string;
  paiboon: string;
  translation_en: string;
  audio_url: string | null;
  voice_key: string | null;
};

/**
 * LessonVocabularyItemRow
 *
 * Eén `lesson_vocabulary`-rij met de geneste master-data en
 * canonieke voorbeelden. `display_order` is nullable (EXISTING):
 * ongenummerde items horen onderaan (query gebruikt nullsFirst:false).
 */
export type LessonVocabularyItemRow = {
  id: number;
  role: "target" | "supporting" | "review" | "bonus";
  display_order: number | null;
  requires_explanation: boolean;
  notes: string | null;
  vocabulary_master: {
    id: number;
    source_key: string;
    thai_script: string;
    paiboon: string | null;
    english_gloss: string;
    part_of_speech: string | null;
    register: string | null;
    usage_note: string | null;
    audio_url: string | null;
    voice_key: string | null;
    vocabulary_examples: VocabularyExampleRow[];
  };
};

/**
 * LanguageNoteExampleRow
 *
 * Eén rij uit `language_note_examples`. Hangt uitsluitend onder een
 * `example_group`-blok (afgedwongen door de samengestelde FK
 * (block_id, block_type)).
 */
export type LanguageNoteExampleRow = {
  id: number;
  display_order: number;
  thai_script: string;
  paiboon: string;
  translation_en: string;
  audio_url: string | null;
  voice_key: string | null;
};

/**
 * LanguageNoteBlockRow
 *
 * Eén rij uit `language_note_blocks`. `block_type` bepaalt de vorm:
 * tekstblokken (paragraph/subheading/formula/usage_tip) vullen
 * `content` en laten `heading` leeg; `example_group` heeft optionele
 * `heading` + optionele intro (`content`) en draagt de geneste
 * examples. `language_note_examples` is leeg tenzij example_group.
 */
export type LanguageNoteBlockRow = {
  id: number;
  display_order: number;
  block_type:
    | "paragraph"
    | "subheading"
    | "formula"
    | "example_group"
    | "usage_tip";
  heading: string | null;
  content: string | null;
  language_note_examples: LanguageNoteExampleRow[];
};

/**
 * LanguageNoteRow
 *
 * Eén `language_notes`-rij met geneste, geordende blokken.
 * `display_order` is NOT NULL, dus sortering in de query volstaat
 * voor de notes zelf; blokken en examples worden in de mapper
 * gesorteerd (PostgREST sorteert geneste niveaus niet betrouwbaar).
 */
export type LanguageNoteRow = {
  id: number;
  title: string;
  display_order: number;
  language_note_blocks: LanguageNoteBlockRow[];
};

// ============================================================
// Instructiecontent — frontend types (camelCase)
// ============================================================

/**
 * ExampleLine
 *
 * Eén voorbeeldzin (drieluik thai/paiboon/translation) na de mapper.
 * Zowel vocabulary_examples als language_note_examples mappen hierheen:
 * dezelfde vorm, dezelfde weergavecomponent.
 */
export type ExampleLine = {
  id: number;
  order: number;
  thaiLine: string;
  transliterationLine: string;
  translationLine: string;
  audioUrl: string | null;
};

/**
 * LanguageNoteBlock
 *
 * Discriminated union op `blockType`: de compiler weet per variant
 * welke velden bestaan (bij "example_group" de examples, bij de
 * tekstvarianten alleen `content`). De blokrenderer moet in zijn
 * switch alle vijf gevallen afhandelen.
 */
export type LanguageNoteBlock =
  | { blockType: "paragraph"; content: string }
  | { blockType: "subheading"; content: string }
  | { blockType: "formula"; content: string }
  | { blockType: "usage_tip"; content: string }
  | {
      blockType: "example_group";
      heading: string | null;
      intro: string | null;
      examples: ExampleLine[];
    };

/**
 * LanguageNote
 *
 * Eén redactionele mini-les: een titel plus geordende blokken.
 * De koppeltabel language_note_concepts (associatie met een
 * vocab/grammar/phrase/pattern-item) wordt in fase 1 niet opgehaald.
 */
export type LanguageNote = {
  id: number;
  order: number;
  title: string;
  blocks: LanguageNoteBlock[];
};

/**
 * VocabularyItem
 *
 * `master` = canonieke taaldata uit vocabulary_master (herbruikbaar
 * over lessen heen). `lesson` = lesspecifieke presentatie uit
 * lesson_vocabulary. Die scheiding is bewust.
 */
export type VocabularyItem = {
  id: number;
  sourceKey: string;
  master: {
    thaiScript: string;
    paiboon: string | null;
    englishGloss: string;
    partOfSpeech: string | null;
    register: string | null;
    usageNote: string | null;
    audioUrl: string | null;
  };
  lesson: {
    role: "target" | "supporting" | "review" | "bonus";
    order: number | null;
    requiresExplanation: boolean;
    notes: string | null;
  };
  examples: ExampleLine[];
};

/**
 * LessonInstructionalContent
 *
 * Het volledige instructiedeel van een les. Losgekoppeld van
 * LessonWithDialog zodat beide onafhankelijk opgehaald en (later)
 * gecached kunnen worden.
 */
export type LessonInstructionalContent = {
  vocabularyItems: VocabularyItem[];
  languageNotes: LanguageNote[];
};
