// ============================================================
// generate-audio.mjs
//
// Genereert per-blok audio voor alle dialog_blocks zonder audio_url.
//
// Pipeline per blok:
//   1. Haal dialog_blocks op (zonder audio_url) via Supabase
//   2. Strip het character-prefix uit thai_text ("มะลิ: " → "สวัสดีค่ะ")
//   3. Roep Google Cloud TTS aan met de stem uit voice-config.mjs
//   4. Upload de MP3 naar Supabase Storage
//   5. Update dialog_blocks.audio_url
//
// Uitvoeren:
//   node --env-file=.env.local scripts/generate-audio.mjs
//
// Dry-run (geen uploads, geen DB-wijzigingen):
//   node --env-file=.env.local scripts/generate-audio.mjs --dry-run
//
// Idempotent: blokken met een bestaande audio_url worden overgeslagen.
// ============================================================

import { createClient } from "@supabase/supabase-js";
import { VOICE_MAP, AUDIO_CONFIG } from "./voice-config.mjs";

// ── Configuratie ────────────────────────────────────────────

const DRY_RUN = process.argv.includes("--dry-run");
const DELAY_MS = 300; // wacht tussen TTS-aanroepen om rate limits te vermijden

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const GOOGLE_TTS_API_KEY = process.env.GOOGLE_TTS_API_KEY;
const TTS_API_URL = `https://texttospeech.googleapis.com/v1/text:synthesize?key=${GOOGLE_TTS_API_KEY}`;

// ── Validatie ───────────────────────────────────────────────

if (!SUPABASE_URL) {
  console.error("FOUT: NEXT_PUBLIC_SUPABASE_URL ontbreekt in .env.local");
  process.exit(1);
}
if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error("FOUT: SUPABASE_SERVICE_ROLE_KEY ontbreekt in .env.local");
  process.exit(1);
}
if (!GOOGLE_TTS_API_KEY) {
  console.error("FOUT: GOOGLE_TTS_API_KEY ontbreekt in .env.local");
  process.exit(1);
}

// ── Supabase client (service role: schrijftoegang) ──────────

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// ── Helpers ─────────────────────────────────────────────────

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Strip het character-prefix uit thai_text.
 * "มะลิ: สวัสดีค่ะ" → "สวัสดีค่ะ"
 * Geen prefix gevonden → tekst ongewijzigd teruggeven.
 */
function extractSpokenText(thaiText) {
  const colonIndex = thaiText.indexOf(": ");
  if (colonIndex === -1) return thaiText;
  return thaiText.slice(colonIndex + 2);
}

/**
 * Bouw het pad binnen de 'audio' bucket op basis van lesson_key en block_index.
 * lesson_key 'a1-dialog-01', block_index 0
 *   → 'dialogs/a1/dialog-01/blocks/block-00.mp3'
 */
function buildStoragePath(lessonKey, blockIndex) {
  const dashIndex = lessonKey.indexOf("-");
  const level = lessonKey.slice(0, dashIndex); // 'a1'
  const dialogPart = lessonKey.slice(dashIndex + 1); // 'dialog-01'
  const blockNum = String(blockIndex).padStart(2, "0");
  return `dialogs/${level}/${dialogPart}/blocks/block-${blockNum}.mp3`;
}

/**
 * Roep Google Cloud TTS aan en geef een MP3-buffer terug.
 */
async function callTTS(spokenText, voice) {
  const response = await fetch(TTS_API_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      input: { text: spokenText },
      voice,
      audioConfig: AUDIO_CONFIG,
    }),
  });

  const data = await response.json();

  if (data.error) {
    throw new Error(`TTS API fout: ${data.error.message}`);
  }

  return Buffer.from(data.audioContent, "base64");
}

/**
 * Upload MP3-buffer naar Supabase Storage.
 * Geeft de publieke URL terug.
 */
async function uploadToStorage(storagePath, mp3Buffer) {
  const { error } = await supabase.storage
    .from("audio")
    .upload(storagePath, mp3Buffer, {
      contentType: "audio/mpeg",
      upsert: true, // overschrijf als het bestand al bestaat
    });

  if (error) {
    throw new Error(`Storage upload fout: ${error.message}`);
  }

  return `${SUPABASE_URL}/storage/v1/object/public/audio/${storagePath}`;
}

/**
 * Sla de publieke URL op in dialog_blocks.audio_url.
 */
async function updateAudioUrl(blockId, audioUrl) {
  const { error } = await supabase
    .from("dialog_blocks")
    .update({ audio_url: audioUrl })
    .eq("id", blockId);

  if (error) {
    throw new Error(`DB update fout: ${error.message}`);
  }
}

// ── Hoofdlogica ─────────────────────────────────────────────

async function generateAudio() {
  if (DRY_RUN) {
    console.log("DRY-RUN — geen uploads, geen DB-wijzigingen\n");
  }

  // Haal alle blokken op zonder audio_url, inclusief lesson_key via de join.
  // Supabase volgt de FK-keten: dialog_blocks → dialogs → lessons
  const { data: blocks, error } = await supabase
    .from("dialog_blocks")
    .select(
      `
      id,
      block_index,
      speaker_key,
      thai_text,
      dialogs!inner (
        lessons!inner (
          lesson_key
        )
      )
    `,
    )
    .is("audio_url", null)
    .order("id");

  if (error) {
    console.error("FOUT: Kon dialog_blocks niet ophalen:", error.message);
    process.exit(1);
  }

  if (blocks.length === 0) {
    console.log("Alle blokken hebben al een audio_url. Niets te doen.");
    return;
  }

  console.log(`${blocks.length} blok(ken) gevonden zonder audio_url.\n`);

  let geslaagd = 0;
  let overgeslagen = 0;
  let mislukt = 0;

  for (const block of blocks) {
    const lessonKey = block.dialogs.lessons.lesson_key;
    const label = `[${lessonKey} / block-${String(block.block_index).padStart(2, "0")}]`;

    // Controleer of speaker_key bekend is in de voice-config
    const voice = VOICE_MAP[block.speaker_key];
    if (!voice) {
      console.warn(`WAARSCHUWING: ${label} onbekende speaker_key '${block.speaker_key}' — overgeslagen`);
      overgeslagen++;
      continue;
    }

    const spokenText = extractSpokenText(block.thai_text);
    const storagePath = buildStoragePath(lessonKey, block.block_index);
    const publicUrl = `${SUPABASE_URL}/storage/v1/object/public/audio/${storagePath}`;

    if (DRY_RUN) {
      console.log(label);
      console.log(`  speaker : ${block.speaker_key} -> ${voice.name}`);
      console.log(`  tekst   : ${spokenText}`);
      console.log(`  pad     : ${storagePath}\n`);
      geslaagd++;
      continue;
    }

    try {
      process.stdout.write(`${label} genereren...`);

      const mp3Buffer = await callTTS(spokenText, voice);
      await uploadToStorage(storagePath, mp3Buffer);
      await updateAudioUrl(block.id, publicUrl);

      console.log(" OK");
      geslaagd++;
    } catch (err) {
      console.log(" MISLUKT");
      console.error(`  ${err.message}`);
      mislukt++;
    }

    await sleep(DELAY_MS);
  }

  // Samenvatting
  console.log("\n------------------------------");
  console.log(`Geslaagd    : ${geslaagd}`);
  if (overgeslagen > 0) console.log(`Overgeslagen: ${overgeslagen}`);
  if (mislukt > 0) console.log(`Mislukt     : ${mislukt}`);
  console.log("------------------------------");
}

generateAudio();
