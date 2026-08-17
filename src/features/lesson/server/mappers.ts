import type {
  LessonRow,
  DialogRow,
  DialogData,
  LessonWithDialog,
  LessonVocabularyItemRow,
  LanguageNoteRow,
  LanguageNoteBlockRow,
  LanguageNoteExampleRow,
  VocabularyExampleRow,
  ExampleLine,
  VocabularyItem,
  LanguageNote,
  LanguageNoteBlock,
  LessonInstructionalContent,
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

// ============================================================
// Instructiecontent: Vocabulary Cards + Language Notes
// ============================================================

/**
 * mapExampleRow
 *
 * Zet één voorbeeldrij om naar een ExampleLine. Bewust gedeeld tussen
 * vocabulary_examples en language_note_examples: beide hebben exact
 * dezelfde vorm (drieluik + audio), dus één weergave-type en één mapper.
 * De transliteratie is de `paiboon`-kolom.
 */
function mapExampleRow(
  row: VocabularyExampleRow | LanguageNoteExampleRow,
): ExampleLine {
  return {
    id: row.id,
    order: row.display_order,
    thaiLine: row.thai_script,
    transliterationLine: row.paiboon,
    translationLine: row.translation_en,
    audioUrl: row.audio_url,
  };
}

/** Sorteert voorbeelden oplopend op display_order en mapt ze. */
function mapExamples(
  rows: (VocabularyExampleRow | LanguageNoteExampleRow)[],
): ExampleLine[] {
  return [...rows]
    .sort((a, b) => a.display_order - b.display_order)
    .map(mapExampleRow);
}

/**
 * mapVocabularyItemRow
 *
 * `master` = canonieke data uit vocabulary_master, `lesson` = de
 * lesspecifieke presentatie uit lesson_vocabulary. `id`/`sourceKey`
 * komen van het woord zelf (stabiel over lessen heen, bruikbaar als
 * React-key en voor audiokoppeling).
 */
function mapVocabularyItemRow(row: LessonVocabularyItemRow): VocabularyItem {
  const m = row.vocabulary_master;
  return {
    id: m.id,
    sourceKey: m.source_key,
    master: {
      thaiScript: m.thai_script,
      paiboon: m.paiboon,
      englishGloss: m.english_gloss,
      partOfSpeech: m.part_of_speech,
      register: m.register,
      usageNote: m.usage_note,
      audioUrl: m.audio_url,
    },
    lesson: {
      role: row.role,
      order: row.display_order,
      requiresExplanation: row.requires_explanation,
      notes: row.notes,
    },
    examples: mapExamples(m.vocabulary_examples),
  };
}

/**
 * mapLanguageNoteBlockRow
 *
 * Zet een ruw blok om naar de discriminated union LanguageNoteBlock.
 * De switch dwingt af dat alle vijf bloktypes behandeld worden; de
 * `never`-tak in default vangt een onverwacht bloktype (bv. een nieuw
 * type dat wel in de DB staat maar nog niet in de union) hard af in
 * plaats van stil verkeerd te renderen.
 *
 * Voor de tekstblokken is `content` per DB-constraint gevuld, maar het
 * type is `string | null`; `?? ""` maakt dat expliciet typeveilig.
 * Bij example_group wordt `content` de optionele intro-tekst.
 */
function mapLanguageNoteBlockRow(
  row: LanguageNoteBlockRow,
): LanguageNoteBlock {
  switch (row.block_type) {
    case "paragraph":
    case "subheading":
    case "formula":
    case "usage_tip":
      return { blockType: row.block_type, content: row.content ?? "" };
    case "example_group":
      return {
        blockType: "example_group",
        heading: row.heading,
        intro: row.content,
        examples: mapExamples(row.language_note_examples),
      };
    default: {
      const exhaustiveCheck: never = row.block_type;
      throw new Error(`Onbekend block_type: ${exhaustiveCheck}`);
    }
  }
}

/**
 * mapLanguageNoteRow
 *
 * Sorteert de blokken oplopend op display_order en mapt ze. De notes
 * zelf zijn al door de query gesorteerd (display_order is NOT NULL).
 */
function mapLanguageNoteRow(row: LanguageNoteRow): LanguageNote {
  return {
    id: row.id,
    order: row.display_order,
    title: row.title,
    blocks: [...row.language_note_blocks]
      .sort((a, b) => a.display_order - b.display_order)
      .map(mapLanguageNoteBlockRow),
  };
}

/**
 * mapLessonInstructionalContent
 *
 * Voegt de twee ruwe querytakken (vocab + notes) samen tot het
 * frontend-type LessonInstructionalContent. De top-level volgorde
 * komt uit de query (vocab: display_order nullsFirst:false; notes:
 * display_order); alle geneste sortering gebeurt hier.
 */
export function mapLessonInstructionalContent(rows: {
  vocab: LessonVocabularyItemRow[];
  notes: LanguageNoteRow[];
}): LessonInstructionalContent { 
  // console.log( 'vocabularyItems:', rows.vocab.map(mapVocabularyItemRow),  'languageNotes:', rows.notes.map(mapLanguageNoteRow))
  return {
    vocabularyItems: rows.vocab.map(mapVocabularyItemRow),
    languageNotes: rows.notes.map(mapLanguageNoteRow),
  };
}
