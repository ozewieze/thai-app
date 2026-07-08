// ============================================================
// merge-audio.mjs
//
// Voegt per-blok MP3-bestanden samen tot één full-dialog audio
// per dialoog en slaat de timestamps per blok op in de database.
//
// Pipeline per dialoog:
//   1. Haal alle dialog_blocks op (gesorteerd op block_index)
//   2. Controleer of alle blokken een audio_url hebben
//   3. Download elke blok-MP3 naar een tijdelijke map
//   4. Bereken de duur van elk blok via ffprobe
//   5. Bereken start/end timestamps (cumulatief + stiltes ertussen)
//   6. Genereer een stilte-MP3 van SILENCE_GAP_MS milliseconden
//   7. Schrijf een concat-lijst en voer ffmpeg uit → full-dialog.mp3
//   8. Upload naar Supabase Storage
//   9. Update dialogs.audio_url
//  10. Update dialog_blocks.full_start_ms en full_end_ms per blok
//  11. Verwijder tijdelijke bestanden
//
// Uitvoeren (alle dialogen zonder audio_url):
//   node --env-file=.env.local scripts/merge-audio.mjs
//
// Uitvoeren (één specifieke dialoog):
//   node --env-file=.env.local scripts/merge-audio.mjs --dialog a1-dialog-01
//
// Opnieuw samenvoegen (ook al heeft de dialoog een audio_url):
//   node --env-file=.env.local scripts/merge-audio.mjs --dialog a1-dialog-01 --force
//
// Dry-run (geen uploads, geen DB-wijzigingen):
//   node --env-file=.env.local scripts/merge-audio.mjs --dry-run
//
// Vereiste: ffmpeg en ffprobe moeten beschikbaar zijn in je PATH.
//   Windows : winget install Gyan.FFmpeg  (herstart terminal daarna)
//   Mac     : brew install ffmpeg
// ============================================================

import { createClient } from "@supabase/supabase-js";
import { execSync } from "child_process"; //hiermee kan Node externe commando's uitvoeren (ffmpeg, ffprobe, etc.)
import { writeFileSync, mkdirSync, rmSync, readFileSync } from "fs"; //fs is de Node File System module
import { join } from "path"; //join() maakt een OS-specifiek pad van losse segmenten, bv. join("a", "b", "c") → "a/b/c" op Mac/Linux, "a\b\c" op Windows
import { tmpdir } from "os"; //tmpdir() geeft het pad naar de tijdelijke map van het OS (C:\Users\<user>\AppData\Local\Temp op Windows, /tmp op Mac/Linux)

// ── Configuratie ────────────────────────────────────────────

const DRY_RUN = process.argv.includes("--dry-run");
const FORCE = process.argv.includes("--force");
const dialogArg = (() => {
  const i = process.argv.indexOf("--dialog");
  return i !== -1 ? (process.argv[i + 1] ?? null) : null;
})();

// Stilte tussen twee blokken in milliseconden.
// 500ms is genoeg om blokgrenzen te horen bij het testen
// van synchronisatie, maar niet zo lang dat de dialoog traag klinkt.
const SILENCE_GAP_MS = 500;

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

// ── Validatie ───────────────────────────────────────────────

if (!SUPABASE_URL) {
  console.error("FOUT: NEXT_PUBLIC_SUPABASE_URL ontbreekt in .env.local");
  process.exit(1);
}
if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error("FOUT: SUPABASE_SERVICE_ROLE_KEY ontbreekt in .env.local");
  process.exit(1);
}
if (FORCE && !dialogArg) {
  console.error("FOUT: --force vereist ook --dialog.");
  console.error("  Gebruik: --dialog a1-dialog-01 --force");
  process.exit(1);
}

// Controleer of ffmpeg en ffprobe beschikbaar zijn in PATH. Zijn ze geïnstalleerd via winget of brew, dan is dat meestal al het geval.
for (const tool of ["ffmpeg", "ffprobe"]) {
  try {
    execSync(`${tool} -version`, { stdio: "ignore" });
  } catch {
    console.error(`FOUT: '${tool}' niet gevonden in PATH.`);
    console.error(
      "  Windows: winget install Gyan.FFmpeg  (herstart terminal daarna)",
    );
    console.error("  Mac    : brew install ffmpeg");
    process.exit(1);
  }
}

// ── Supabase client (service role: schrijftoegang) ──────────

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// ── Helpers ─────────────────────────────────────────────────

/**
 * Bouw het Storage-pad voor de full-dialog audio.
 * 'a1-dialog-01' → 'dialogs/a1/dialog-01/full-dialog.mp3'
 *
 * Zelfde logica als buildStoragePath() in generate-audio.mjs,
 * maar dan voor het samengevoegde bestand (geen blokindex).
 */
function buildFullDialogPath(lessonKey) {
  const dashIndex = lessonKey.indexOf("-");
  const level = lessonKey.slice(0, dashIndex); // 'a1'
  const dialogPart = lessonKey.slice(dashIndex + 1); // 'dialog-01'
  return `dialogs/${level}/${dialogPart}/full-dialog.mp3`;
}

/**
 * Haal de duur van een lokaal MP3-bestand op via ffprobe.
 * Geeft de duur terug in milliseconden (afgerond op gehele ms).
 *
 * ffprobe retourneert de duur als decimale secondenstring, bv. "3.456000".
 * We proberen eerst streams[0].duration, dan format.duration als fallback
 * (sommige MP3-encoders slaan de duur alleen op in de container-header).
 */
function getAudioDurationMs(filePath) {
  const output = execSync(
    `ffprobe -v quiet -print_format json -show_format -show_streams "${filePath}"`,
    { encoding: "utf8" }, //geeft de uitvoer van ffprobe terug als een string in plaats van een Buffer bvb '{"streams":[{"index":0,"codec_name":"mp3","codec_type":"audio","duration":"3.456000"}],"format":{"filename":"C:\\Users\\<user>\\AppData\\Local\\Temp\\thai-merge-a1-dialog-01-1699999999999\\block-00.mp3","duration":"3.456000"}}'
  );
  const data = JSON.parse(output); //dit geeft een object met streams en format terug, bv. { streams: [...], format: {...} }

  const streamDuration = data.streams?.[0]?.duration;
  const formatDuration = data.format?.duration;
  const raw = streamDuration ?? formatDuration;

  if (!raw) {
    throw new Error(`ffprobe kon de duur niet bepalen van: ${filePath}`);
  }

  const ms = Math.round(parseFloat(raw) * 1000);
  if (isNaN(ms) || ms <= 0) {
    throw new Error(`Ongeldige duur (${raw}) voor: ${filePath}`);
  }

  return ms;
}

/**
 * Download een bestand van een publieke URL naar een lokaal pad.
 */
async function downloadFile(url, destPath) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Download mislukt (HTTP ${response.status}): ${url}`);
  }
  const buffer = Buffer.from(await response.arrayBuffer()); //Zet de gedownloade bytes in geheugen.
  writeFileSync(destPath, buffer); // Schrijf die bytes naar een bestand op schijf
}

/**
 * Genereer een stilte-MP3 van SILENCE_GAP_MS milliseconden.
 *
 * Instellingen:
 *   r=24000       — sample rate 24 kHz (Google TTS default voor MP3)
 *   cl=mono       — mono (idem)
 *   ab 128k       — bitrate 128 kbps (idem)
 *
 * Door dezelfde parameters te gebruiken als de blok-MP3s kan
 * ffmpeg de bestanden samenvoegen zonder re-encoding (-c copy).
 */
function generateSilence(destPath) {
  const durationSec = SILENCE_GAP_MS / 1000;
  execSync(
    `ffmpeg -y -f lavfi -i anullsrc=r=24000:cl=mono -t ${durationSec} -acodec libmp3lame -ab 128k "${destPath}"`,
    { stdio: "ignore" },
  );
}

/**
 * Voeg de bestanden in de concat-lijst samen via ffmpeg.
 *
 * -f concat        — gebruik de concat-demuxer (voor een lijst van bestanden)
 * -safe 0          — sta absolute paden toe in de lijst
 * -i <lijst>       — het tekstbestand met de bestandspaden
 * -c copy          — geen re-encoding: audio wordt bit-voor-bit gekopieerd
 *
 * -c copy werkt correct zolang alle inputbestanden dezelfde codec-
 * parameters hebben (sample rate, kanalen, bitrate). Dat is gegarandeerd
 * omdat alle blokken uit dezelfde Google TTS API komen met dezelfde config,
 * en het stilte-bestand hierboven met dezelfde parameters is aangemaakt.
 */
function runFfmpegConcat(concatListPath, outputPath) {
  execSync(
    `ffmpeg -y -f concat -safe 0 -i "${concatListPath}" -c copy "${outputPath}"`,
    { stdio: "ignore" },
  );
}

/**
 * Upload een lokaal bestand naar de 'audio' bucket in Supabase Storage.
 * Geeft de publieke URL terug.
 */
async function uploadToStorage(storagePath, filePath) {
  const fileBuffer = readFileSync(filePath);

  const { error } = await supabase.storage
    .from("audio")
    .upload(storagePath, fileBuffer, {
      contentType: "audio/mpeg",
      upsert: true, // overschrijf als het bestand al bestaat
    });

  if (error) throw new Error(`Storage upload fout: ${error.message}`);

  return `${SUPABASE_URL}/storage/v1/object/public/audio/${storagePath}`;
}

/**
 * Formatteer milliseconden als "m:ss.mmm" voor de timestamp-log.
 * Voorbeeld: 63456 → "1:03.456"
 */
function formatMs(ms) {
  const totalSec = Math.floor(ms / 1000);
  const m = Math.floor(totalSec / 60);
  const s = totalSec % 60;
  const msRest = ms % 1000;
  return `${m}:${String(s).padStart(2, "0")}.${String(msRest).padStart(3, "0")}`;
}

// ── Hoofdlogica ─────────────────────────────────────────────

async function mergeDialogAudio() {
  if (DRY_RUN) console.log("DRY-RUN — geen uploads, geen DB-wijzigingen\n");

  // Als --dialog is opgegeven, zoek de bijbehorende lesson_id op.
  // We filteren via lesson_id (niet via een join-filter) omdat dat
  // betrouwbaarder is in de Supabase JS client.
  let lessonId = null;
  if (dialogArg) {
    const { data: lesson, error: lessonError } = await supabase
      .from("lessons")
      .select("id")
      .eq("lesson_key", dialogArg)
      .single();

    if (lessonError || !lesson) {
      console.error(`FOUT: Les '${dialogArg}' niet gevonden in de database.`);
      process.exit(1);
    }
    lessonId = lesson.id;
  }

  // Haal de doeldialogen op, inclusief blokken en lesson_key.
  let query = supabase.from("dialogs").select(`
      id,
      audio_url,
      lessons ( lesson_key ),
      dialog_blocks (
        id,
        block_index,
        audio_url
      )
    `);

  if (lessonId) {
    query = query.eq("lesson_id", lessonId);
  } else if (!FORCE) {
    // Standaard: alleen dialogen zonder audio_url verwerken.
    query = query.is("audio_url", null);
  }

  const { data: dialogs, error } = await query;

  if (error) {
    console.error("FOUT: Kon dialogen niet ophalen:", error.message);
    process.exit(1);
  }

  if (!dialogs || dialogs.length === 0) {
    if (dialogArg) {
      console.log(`Geen dialoog gevonden voor '${dialogArg}'.`);
    } else {
      console.log("Alle dialogen hebben al een audio_url.");
      console.log(
        "Gebruik --dialog <key> --force om een specifieke dialoog opnieuw samen te voegen.",
      );
    }
    return;
  }

  console.log(`${dialogs.length} dialoog/dialogen te verwerken.\n`);

  let geslaagd = 0;
  let overgeslagen = 0;
  let mislukt = 0;

  for (const dialog of dialogs) {
    const lessonKey = dialog.lessons.lesson_key;
    const label = `[${lessonKey}]`;

    // Sorteer blokken op block_index (de DB-query garandeert dit niet altijd).
    const blocks = [...dialog.dialog_blocks].sort(
      (a, b) => a.block_index - b.block_index,
    );

    // Sla de dialoog over als niet alle blokken een audio_url hebben.
    // Genereer eerst de per-blok audio via generate-audio.mjs.
    const ontbrekendeBlokken = blocks.filter((b) => !b.audio_url);
    if (ontbrekendeBlokken.length > 0) {
      const indices = ontbrekendeBlokken.map((b) => b.block_index).join(", ");
      console.warn(
        `WAARSCHUWING: ${label} blokken zonder audio_url: [${indices}]`,
      );
      console.warn(`  Voer eerst generate-audio.mjs uit voor deze dialoog.`);
      overgeslagen++;
      continue; //slaat dus de dialoog over als niet alle blokken een audio_url hebben, en gaat naar de volgende dialoog in de loop
    }

    if (DRY_RUN) {
      console.log(`${label} ${blocks.length} blok(ken) — dry-run OK`);
      geslaagd++;
      continue;
    }

    // Maak een tijdelijke map aan voor de bestanden van deze dialoog.
    // rmSync in het finally-blok ruimt alles op, ook bij fouten.
    const tempDir = join(tmpdir(), `thai-merge-${lessonKey}-${Date.now()}`);
    mkdirSync(tempDir, { recursive: true });

    try {
      // ── Stap 1: download blok-MP3s ─────────────────────────
      process.stdout.write(`${label} downloaden (${blocks.length} blokken)...`);

      const blockPaths = [];
      for (const block of blocks) {
        const fileName = `block-${String(block.block_index).padStart(2, "0")}.mp3`; //bvb block-00.mp3, block-01.mp3, etc.
        const dest = join(tempDir, fileName); //dit bouwt een pad naar de tijdelijke map bvb C:\Users\<user>\AppData\Local\Temp\thai-merge-a1-dialog-01-1699999999999\block-00.mp3
        await downloadFile(block.audio_url, dest); //creëert het binare mp3-bestand in de tijdelijke map
        blockPaths.push(dest); //inhoud array bvb [C:\Users\<user>\AppData\Local\Temp\thai-merge-a1-dialog-01-1699999999999\block-00.mp3, C:\Users\<user>\AppData\Local\Temp\thai-merge-a1-dialog-01-1699999999999\block-01.mp3, ...]
      }
      console.log(" OK"); //dus je hebt een array van alle gedownloade blok-MP3-bestanden in de tijdelijke map, klaar om samengevoegd te worden

      // ── Stap 2: bereken timestamps via ffprobe ──────────────
      process.stdout.write(`${label} timestamps berekenen...`);

      const timestamps = []; // [{ blockId, startMs, endMs }]
      let cursor = 0;

      for (let i = 0; i < blocks.length; i++) {
        const durationMs = getAudioDurationMs(blockPaths[i]);
        timestamps.push({
          blockId: blocks[i].id,
          startMs: cursor,
          endMs: cursor + durationMs,
        });
        // Voeg de stilte toe na elk blok, behalve na het laatste.
        cursor += durationMs;
        if (i < blocks.length - 1) cursor += SILENCE_GAP_MS;
      }
      console.log(" OK");

      // ── Stap 3: genereer stilte en stel concat-lijst op ────
      process.stdout.write(`${label} samenvoegen...`);

      const silencePath = join(tempDir, "silence.mp3");
      const concatPath = join(tempDir, "concat.txt"); //tekstbestand met de volgorde dat ffmpeg kan gebruiken als concat-lijst
      const fullDialogPath = join(tempDir, "full-dialog.mp3");

      generateSilence(silencePath);

      // ffmpeg concat-demuxer verwacht forward slashes, ook op Windows.
      const toFfmpegPath = (p) => p.replace(/\\/g, "/");

      const concatLines = [];
      for (let i = 0; i < blockPaths.length; i++) {
        concatLines.push(`file '${toFfmpegPath(blockPaths[i])}'`);
        if (i < blockPaths.length - 1) {
          concatLines.push(`file '${toFfmpegPath(silencePath)}'`);
        }
      }
      writeFileSync(concatPath, concatLines.join("\n"), "utf8");

      runFfmpegConcat(concatPath, fullDialogPath); //geeft terug een mp3-bestand in de tijdelijke map dat alle blokken + stiltes samenvoegt en kopieert naar fullDialogPath
      console.log(" OK");

      // ── Stap 4: upload naar Storage ─────────────────────────
      process.stdout.write(`${label} uploaden...`);
      const storagePath = buildFullDialogPath(lessonKey);
      const publicUrl = await uploadToStorage(storagePath, fullDialogPath);
      console.log(" OK");

      // ── Stap 5: update database ─────────────────────────────
      process.stdout.write(`${label} database bijwerken...`);

      const { error: dialogError } = await supabase
        .from("dialogs")
        .update({ audio_url: publicUrl, audio_duration_ms: cursor })
        .eq("id", dialog.id);

      if (dialogError)
        throw new Error(
          `dialogs.audio_url/audio_duration_ms update mislukt: ${dialogError.message}`,
        );

      for (const { blockId, startMs, endMs } of timestamps) {
        const { error: blockError } = await supabase
          .from("dialog_blocks")
          .update({ full_start_ms: startMs, full_end_ms: endMs })
          .eq("id", blockId);

        if (blockError)
          throw new Error(
            `dialog_blocks timestamps update mislukt: ${blockError.message}`,
          );
      }

      console.log(" OK");

      // ── Log de timestamp-tijdlijn als snelle visuele controle ─
      console.log(`  Tijdlijn (totaal: ${formatMs(cursor)}):`);
      for (let i = 0; i < blocks.length; i++) {
        const { startMs, endMs } = timestamps[i];
        const idx = String(blocks[i].block_index).padStart(2, "0");
        console.log(
          `    blok-${idx}: ${formatMs(startMs)} → ${formatMs(endMs)}`,
        );
      }

      geslaagd++;
    } catch (err) {
      console.log(" MISLUKT");
      console.error(`  ${err.message}`);
      mislukt++;
    } finally {
      // Ruim de tijdelijke map altijd op, ook bij fouten.
      rmSync(tempDir, { recursive: true, force: true });
    }
  }

  // ── Samenvatting ────────────────────────────────────────────
  console.log("\n------------------------------");
  console.log(`Geslaagd    : ${geslaagd}`);
  if (overgeslagen > 0) console.log(`Overgeslagen: ${overgeslagen}`);
  if (mislukt > 0) console.log(`Mislukt     : ${mislukt}`);
  console.log("------------------------------");
}

mergeDialogAudio();
