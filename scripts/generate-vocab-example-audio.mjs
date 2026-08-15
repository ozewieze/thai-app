// ============================================================
// generate-vocab-example-audio.mjs
//
// Genereert audio voor de canonieke voorbeeldzinnen op een
// Vocabulary Card. Vult vocabulary_examples.audio_url en
// .voice_key.
//
// Pipeline per voorbeeld:
//   1. Haal vocabulary_examples op waar audio_url null is
//   2. Leid de narrator af uit de zin via
//      deriveNarratorFromSentence() -- slotpartikel, met het
//      voornaamwoord als terugval
//   3. Roep Google Cloud TTS aan
//   4. Upload de MP3 naar 'audio' onder vocab/examples/
//   5. Schrijf audio_url + voice_key terug
//
// Uitvoeren:
//   node --env-file=.env.local scripts/generate-vocab-example-audio.mjs
//
// Dry-run -- toont per zin welke stem gekozen wordt en waarom,
// zonder uploads of DB-wijzigingen. Dit is de stap waarop een
// verkeerde afleiding zichtbaar wordt vóór er audio bestaat:
//   node --env-file=.env.local scripts/generate-vocab-example-audio.mjs --dry-run
//
// De voorbeelden van één woord:
//   node --env-file=.env.local scripts/generate-vocab-example-audio.mjs --source-key coffee
//
// Geen --lesson-vlag, en dat is geen omissie. Een canoniek
// voorbeeld is lesneutraal: het hoort bij het wóórd, niet bij de
// les waarin dat woord toevallig geïntroduceerd werd. De les zit
// alleen in de bestandsnaam van het invoerdocument, en nergens in
// de data. Een --lesson-vlag hier zou een binding suggereren die
// niet bestaat. Voor Language Note-voorbeelden ligt dat anders --
// zie generate-note-example-audio.mjs.
//
// Idempotent: voorbeelden met een bestaande audio_url worden
// overgeslagen. Corrigeer je de tekst in de JSON en draai je het
// seedbestand opnieuw, dan zet de upsert audio_url en voice_key
// op null zodra thai_script wijzigt -- de volgende run pakt het
// voorbeeld dan vanzelf opnieuw op.
//
// Nooit hergebruikt uit dialoogaudio, ook niet wanneer de zin
// toevallig identiek is (ADR-021). Dialoogaudio is een
// personagestem in een scène; een kaart hoort de neutrale
// instructiestem te gebruiken.
// ============================================================

import {
  CONFIRMATION_THRESHOLD,
  DELAY_MS,
  callTTS,
  fetchAllRows,
  flagValues,
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
const SOURCE_KEYS = flagValues("--source-key");
const LIMIT = readLimit();

const { SUPABASE_URL, supabase, ttsApiUrl } = readEnvironment();

/**
 * Pad binnen de 'audio'-bucket.
 *
 * source_key 'coffee', example_key 'e1'
 *   -> 'vocab/examples/coffee/e1.mp3'
 *
 * De identiteit van een rij is het paar (source_key, example_key)
 * -- zie 20260808120000_add_vocabulary_example_natural_key.sql --
 * en dat paar vormt hier het pad. Geen lesson_key, om dezelfde
 * reden als hierboven. Geen identity-id, want dat wordt bij een
 * db reset opnieuw uitgedeeld en zou hetzelfde voorbeeld na een
 * herbouw op een ander pad zetten.
 */
function buildStoragePath(sourceKey, exampleKey) {
  return `vocab/examples/${sourceKey}/${exampleKey}.mp3`;
}

// ── Ophalen ─────────────────────────────────────────────────

async function fetchCandidates() {
  // Twee losse queries in plaats van een embedded !inner-join.
  // De join is simpel genoeg om te embedden, maar het zusterscript
  // voor Language Notes moet over een samengestelde foreign key
  // (block_id, block_type) -- en daar is embedden precies het soort
  // ding dat werkt tot het niet werkt. Beide scripts lezen nu
  // hetzelfde.
  const examples = await fetchAllRows(() =>
    supabase
      .from("vocabulary_examples")
      .select("id, vocabulary_id, example_key, thai_script")
      .is("audio_url", null)
      .order("id"),
  );

  if (examples.length === 0) return [];

  const words = await fetchAllRows(() =>
    supabase.from("vocabulary_master").select("id, source_key").order("id"),
  );
  const sourceKeyById = new Map(words.map((row) => [row.id, row.source_key]));

  let rows = examples.map((row) => ({
    ...row,
    source_key: sourceKeyById.get(row.vocabulary_id) ?? null,
  }));

  // Een voorbeeld zonder woord kan niet bestaan -- de foreign key
  // is NOT NULL met on delete cascade. Zie je dit toch, dan is de
  // aanname onder het opslagpad weg en niet de data een beetje
  // raar; daarom hard falen in plaats van overslaan.
  const orphans = rows.filter((row) => row.source_key === null);
  if (orphans.length > 0) {
    console.error(`FOUT: ${orphans.length} voorbeeld(en) zonder bijbehorend woord in vocabulary_master.`);
    for (const row of orphans) {
      console.error(`  id ${row.id} (vocabulary_id ${row.vocabulary_id})`);
    }
    process.exit(1);
  }

  if (SOURCE_KEYS.length > 0) {
    const requested = new Set(SOURCE_KEYS);
    rows = rows.filter((row) => requested.has(row.source_key));

    const foundKeys = new Set(rows.map((row) => row.source_key));
    const missing = SOURCE_KEYS.filter((key) => !foundKeys.has(key));

    if (missing.length > 0) {
      for (const key of missing) {
        console.error(
          `FOUT: geen voorbeeld zonder audio gevonden voor source_key '${key}'. ` +
            "Bestaat het woord, en heeft het al audio?",
        );
      }
      process.exit(1);
    }
  }

  return rows;
}

// ── Hoofdlogica ─────────────────────────────────────────────

async function generateVocabExampleAudio() {
  if (DRY_RUN) {
    console.log("DRY-RUN — geen uploads, geen DB-wijzigingen\n");
  }

  const rows = await fetchCandidates();

  if (rows.length === 0) {
    console.log("Geen voorbeelden te doen.");
    return;
  }

  // Fase 1: eerst alle rijen afleiden, dan pas genereren.
  // Zo valt een gebroken bundel vóór de eerste TTS-aanroep in
  // plaats van halverwege een batch die al deels is opgenomen --
  // en zie je in één keer élke gebroken rij, niet alleen de eerste.
  const planned = rows.map((row) => ({
    row,
    outcome: deriveNarratorFromSentence(row.thai_script),
    label: `[${row.source_key}/${row.example_key}]`,
    text: row.thai_script,
    storagePath: buildStoragePath(row.source_key, row.example_key),
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
        "vocabulary_examples",
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

generateVocabExampleAudio().catch((err) => {
  console.error(`FOUT: ${err.message}`);
  process.exit(1);
});
