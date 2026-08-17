// ============================================================
// generate-note-example-audio.mjs
//
// Genereert audio voor de voorbeeldzinnen in een Language Note.
// Vult language_note_examples.audio_url en .voice_key.
//
// Pipeline per voorbeeld:
//   1. Haal language_note_examples op waar audio_url null is
//   2. Leid de narrator af uit de zin via
//      deriveNarratorFromSentence() -- slotpartikel, met het
//      voornaamwoord als terugval
//   3. Roep Google Cloud TTS aan
//   4. Upload de MP3 naar 'audio' onder notes/
//   5. Schrijf audio_url + voice_key terug
//
// Uitvoeren:
//   node --env-file=.env.local scripts/generate-note-example-audio.mjs
//
// Dry-run -- toont per zin welke stem gekozen wordt en waarom:
//   node --env-file=.env.local scripts/generate-note-example-audio.mjs --dry-run
//
// De voorbeelden van één les:
//   node --env-file=.env.local scripts/generate-note-example-audio.mjs --lesson a1-dialog-04
//
// Waarom hier wél een --lesson-vlag en bij de kaartvoorbeelden
// niet: een note hangt via language_notes.lesson_id aan een les.
// Die binding staat in de data, niet alleen in een bestandsnaam.
//
// Idempotent: voorbeelden met een bestaande audio_url worden
// overgeslagen. Corrigeer je de tekst in de JSON en draai je het
// seedbestand opnieuw, dan zet de upsert audio_url en voice_key
// op null zodra thai_script wijzigt.
//
// Instructiestem, nooit de stem van Mali of Narin: een voorbeeld
// in een note is uitleg, geen scène. Een personagestem zou
// suggereren dat de zin uit de dialoog komt en bindt de note aan
// een personage dat er inhoudelijk niets mee te maken heeft.
// ============================================================

import {
  CONFIRMATION_THRESHOLD,
  DELAY_MS,
  callTTS,
  fetchAllRows,
  flagValue,
  hasFlag,
  printSummary,
  publicUrlFor,
  readEnvironment,
  readLimit,
  reportDerivation,
  sleep,
  uploadToStorage,
  writeAudioBack,
} from "./audio-common.mjs";
import { VOICE_MAP, deriveNarratorFromSentence } from "./voice-config.mjs";

// ── Configuratie ────────────────────────────────────────────

const DRY_RUN = hasFlag("--dry-run");
const YES = hasFlag("--yes");
const LESSON_KEY = flagValue("--lesson");
const LIMIT = readLimit();

const { SUPABASE_URL, supabase, ttsApiUrl } = readEnvironment();

/**
 * Pad binnen de 'audio'-bucket.
 *
 * note_key 'a1-dialog-01-note-1', block_key 'b3', example_key 'e1'
 *   -> 'notes/a1-dialog-01-note-1/b3/e1.mp3'
 *
 * De drie natuurlijke sleutels uit
 * 20260803120000_add_language_note_natural_keys.sql, in dezelfde
 * volgorde als de tabellen. Stabiel over een db reset heen, anders
 * dan de identity-id's.
 *
 * De les zit hier in het pad, maar niet omdat we lesson_key
 * erbij plakken: note_key luidt 'a1-dialog-01-note-1' en draagt
 * hem al. De lesgroepering in de opslag is dus een gevolg van de
 * sleutel en niet van een aanname over de mapstructuur. Alle drie
 * de sleutels voldoen aan ^[a-z0-9]+(-[a-z0-9]+)*$ per
 * check-constraint, dus er valt niets te escapen.
 */
function buildStoragePath(noteKey, blockKey, exampleKey) {
  return `notes/${noteKey}/${blockKey}/${exampleKey}.mp3`;
}

// ── Ophalen ─────────────────────────────────────────────────

async function fetchCandidates() {
  // Drie losse queries in plaats van een embedded !inner-join.
  // language_note_examples hangt aan language_note_blocks via een
  // samengestelde foreign key (block_id, block_type) -- de truc
  // die afdwingt dat voorbeelden alleen onder een example_group
  // kunnen hangen. Embedden over een samengestelde sleutel is
  // precies het soort ding dat werkt tot het niet werkt, en dan
  // met een foutmelding die nergens naar wijst. De drie tabellen
  // zijn klein; dit is goedkoop en leest onmiddellijk.
  const examples = await fetchAllRows(() =>
    supabase
      .from("language_note_examples")
      .select("id, block_id, example_key, thai_script")
      .is("audio_url", null)
      .order("id"),
  );

  if (examples.length === 0) return [];

  const blocks = await fetchAllRows(() =>
    supabase
      .from("language_note_blocks")
      .select("id, block_key, language_note_id")
      .order("id"),
  );
  const blockById = new Map(blocks.map((row) => [row.id, row]));

  const notes = await fetchAllRows(() =>
    supabase.from("language_notes").select("id, note_key, lesson_id").order("id"),
  );
  const noteById = new Map(notes.map((row) => [row.id, row]));

  let rows = examples.map((row) => {
    const block = blockById.get(row.block_id) ?? null;
    const note = block ? (noteById.get(block.language_note_id) ?? null) : null;
    return {
      ...row,
      block_key: block?.block_key ?? null,
      note_key: note?.note_key ?? null,
      lesson_id: note?.lesson_id ?? null,
    };
  });

  // Een voorbeeld zonder blok of zonder note kan niet bestaan --
  // beide foreign keys zijn NOT NULL met on delete cascade. Zie je
  // dit toch, dan klopt de aanname onder het opslagpad niet meer.
  const orphans = rows.filter((row) => row.note_key === null || row.block_key === null);
  if (orphans.length > 0) {
    console.error(`FOUT: ${orphans.length} voorbeeld(en) zonder vindbaar blok of note.`);
    for (const row of orphans) {
      console.error(`  id ${row.id} (block_id ${row.block_id})`);
    }
    process.exit(1);
  }

  if (LESSON_KEY !== null) {
    const lessons = await fetchAllRows(() =>
      supabase.from("lessons").select("id, lesson_key").eq("lesson_key", LESSON_KEY),
    );

    if (lessons.length === 0) {
      console.error(`FOUT: les '${LESSON_KEY}' bestaat niet.`);
      process.exit(1);
    }

    const lessonId = lessons[0].id;
    rows = rows.filter((row) => row.lesson_id === lessonId);

    if (rows.length === 0) {
      console.log(`Geen voorbeelden zonder audio in les '${LESSON_KEY}'.`);
    }
  }

  return rows;
}

// ── Hoofdlogica ─────────────────────────────────────────────

async function generateNoteExampleAudio() {
  if (DRY_RUN) {
    console.log("DRY-RUN — geen uploads, geen DB-wijzigingen\n");
  }

  const rows = await fetchCandidates();

  if (rows.length === 0) {
    console.log("Geen voorbeelden te doen.");
    return;
  }

  // Fase 1: eerst alle rijen afleiden, dan pas genereren.
  // Zie generate-vocab-example-audio.mjs voor het waarom.
  const planned = rows.map((row) => ({
    row,
    outcome: deriveNarratorFromSentence(row.thai_script),
    label: `[${row.note_key}/${row.block_key}/${row.example_key}]`,
    text: row.thai_script,
    storagePath: buildStoragePath(row.note_key, row.block_key, row.example_key),
  }));

  const errorCount = reportDerivation(planned);
  if (errorCount > 0) {
    console.error(
      `\nGestopt: ${errorCount} zin(nen) met een gebroken partikel/voornaamwoord-bundel.`,
    );
    console.error("  Corrigeer de tekst in de JSON en draai het seedbestand opnieuw.");
    console.error("  Er is niets gegenereerd.");
    process.exit(1);
  }

  const selection = LIMIT === null ? planned : planned.slice(0, LIMIT);

  if (LIMIT !== null && planned.length > LIMIT) {
    console.log(
      `\nINFO: --limit ${LIMIT} — ${planned.length - LIMIT} rij(en) blijven staan voor een volgende run.`,
    );
  }

  if (!DRY_RUN && selection.length > CONFIRMATION_THRESHOLD && !YES) {
    console.error(
      `\nFOUT: deze run zou ${selection.length} TTS-aanroepen doen (drempel ${CONFIRMATION_THRESHOLD}).`,
    );
    console.error("  Bevestig met --yes, of beperk met --limit N.");
    process.exit(1);
  }

  console.log(`\n${selection.length} voorbeeld(en) te verwerken.\n`);

  let geslaagd = 0;
  let mislukt = 0;

  for (const item of selection) {
    const voice = VOICE_MAP[item.outcome.narratorKey];
    const publicUrl = publicUrlFor(SUPABASE_URL, item.storagePath);

    if (DRY_RUN) {
      console.log(item.label);
      console.log(`  zin   : ${item.text}`);
      console.log(`  stem  : ${item.outcome.narratorKey} -> ${voice.name}`);
      console.log(`  reden : ${item.outcome.reason}`);
      console.log(`  pad   : ${item.storagePath}\n`);
      geslaagd++;
      continue;
    }

    try {
      process.stdout.write(`${item.label} genereren...`);

      const mp3Buffer = await callTTS(item.text, voice, ttsApiUrl);
      await uploadToStorage(supabase, item.storagePath, mp3Buffer);
      await writeAudioBack(
        supabase,
        "language_note_examples",
        item.row.id,
        publicUrl,
        item.outcome.narratorKey,
      );

      console.log(" OK");
      geslaagd++;
    } catch (err) {
      console.log(" MISLUKT");
      console.error(`  ${err.message}`);
      mislukt++;
    }

    await sleep(DELAY_MS);
  }

  printSummary({ geslaagd, overgeslagen: 0, mislukt });
}

generateNoteExampleAudio().catch((err) => {
  console.error(`FOUT: ${err.message}`);
  process.exit(1);
});
