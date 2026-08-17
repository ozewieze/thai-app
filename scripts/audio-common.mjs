// ============================================================
// audio-common.mjs
//
// Gedeelde onderdelen van de drie audioscripts voor lemma's en
// voorbeelden:
//
//   generate-lemma-audio.mjs
//   generate-vocab-example-audio.mjs
//   generate-note-example-audio.mjs
//
// Wat hier staat is bewust saai: omgevingsvariabelen nakijken,
// TTS aanroepen, uploaden, pagineren, en een samenvatting
// printen. De regels die ertoe doen -- welke stem bij welke
// tekst hoort -- staan in voice-config.mjs.
//
// LET OP: dit dupliceert callTTS en uploadToStorage uit
// scripts/generate-audio.mjs. Dat is een keuze, geen omissie.
// Dat script werkt en verwerkt de dialogen; het openbreken om
// er twee functies uit te trekken is risico nemen op een
// pijplijn die toch verdwijnt zodra stemacteurs het overnemen.
// De drie regels duplicatie sneuvelen dan samen met de rest.
// ============================================================

import { createClient } from "@supabase/supabase-js";
import { AUDIO_CONFIG } from "./voice-config.mjs";

// Wachten tussen TTS-aanroepen om rate limits te vermijden.
// Zelfde waarde als generate-audio.mjs.
export const DELAY_MS = 300;

// Boven dit aantal rijen weigert een script te draaien zonder
// een expliciete --yes. Geen interactieve vraag: deze scripts
// hangen achter `npm run db:reset:full` en een prompt zou daar
// blijven wachten op iemand die er niet is. Weigeren is luid en
// blokkeert niets.
export const CONFIRMATION_THRESHOLD = 100;

export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// ── Omgeving ────────────────────────────────────────────────

/**
 * Leest en controleert de drie benodigde omgevingsvariabelen.
 * Stopt met exitcode 1 als er een ontbreekt -- zelfde meldingen
 * als generate-audio.mjs, zodat de foutervaring gelijk blijft.
 */
export function readEnvironment() {
  const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const GOOGLE_TTS_API_KEY = process.env.GOOGLE_TTS_API_KEY;

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

  return {
    SUPABASE_URL,
    supabase: createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY),
    ttsApiUrl: `https://texttospeech.googleapis.com/v1/text:synthesize?key=${GOOGLE_TTS_API_KEY}`,
  };
}

// ── Vlaggen ─────────────────────────────────────────────────

export function hasFlag(name) {
  return process.argv.includes(name);
}

/**
 * Waarde van een vlag die één keer voorkomt: --limit 25
 * Geeft null terug als de vlag ontbreekt.
 */
export function flagValue(name) {
  const index = process.argv.indexOf(name);
  return index !== -1 ? (process.argv[index + 1] ?? null) : null;
}

/**
 * Waarden van een vlag die meerdere keren mag voorkomen:
 *   --source-key hello --source-key coffee
 */
export function flagValues(name) {
  const values = [];
  for (let i = 0; i < process.argv.length; i++) {
    if (process.argv[i] === name && process.argv[i + 1]) {
      values.push(process.argv[i + 1]);
    }
  }
  return values;
}

/**
 * Leest --limit en valideert hem. Een onleesbare waarde is een
 * harde fout: stil doorgaan met "geen limiet" zou het
 * tegenovergestelde doen van wat er getypt is.
 */
export function readLimit() {
  const raw = flagValue("--limit");
  if (raw === null) return null;

  const value = Number(raw);
  if (!Number.isInteger(value) || value < 1) {
    console.error(`FOUT: --limit verwacht een geheel getal groter dan 0, kreeg '${raw}'`);
    process.exit(1);
  }
  return value;
}

// ── Ophalen met paginering ──────────────────────────────────

/**
 * PostgREST levert standaard maximaal 1000 rijen per verzoek en
 * zegt er niets over als je die grens raakt. Bij 514 lemma's zit
 * je daaronder, maar de masterlijst groeit, en een stille
 * afkapping zou hier betekenen dat er woorden zonder audio
 * achterblijven zonder dat iemand het merkt.
 *
 * @param {() => object} buildQuery  geeft telkens een verse query terug
 * @param {number} pageSize
 */
export async function fetchAllRows(buildQuery, pageSize = 500) {
  const rows = [];

  for (let from = 0; ; from += pageSize) {
    const { data, error } = await buildQuery().range(from, from + pageSize - 1);

    if (error) {
      throw new Error(`Ophalen mislukt: ${error.message}`);
    }

    rows.push(...data);
    if (data.length < pageSize) break;
  }

  return rows;
}

// ── TTS en opslag ───────────────────────────────────────────

/**
 * Roept Google Cloud TTS aan en geeft een MP3-buffer terug.
 * De API antwoordt met base64 in `audioContent`, niet met bytes.
 */
export async function callTTS(spokenText, voice, ttsApiUrl) {
  const response = await fetch(ttsApiUrl, {
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
 * Upload een MP3-buffer naar de 'audio'-bucket.
 * upsert: een herhaalde run overschrijft hetzelfde pad, wat klopt
 * omdat het pad uit de natuurlijke sleutel komt en dus bij
 * dezelfde inhoud hoort.
 */
export async function uploadToStorage(supabase, storagePath, mp3Buffer) {
  const { error } = await supabase.storage.from("audio").upload(storagePath, mp3Buffer, {
    contentType: "audio/mpeg",
    upsert: true,
  });

  if (error) {
    throw new Error(`Storage upload fout: ${error.message}`);
  }
}

export function publicUrlFor(supabaseUrl, storagePath) {
  return `${supabaseUrl}/storage/v1/object/public/audio/${storagePath}`;
}

/**
 * Schrijft audio_url en voice_key terug.
 *
 * Dit zijn de enige twee kolommen waarop service_role UPDATE
 * heeft (20260814120000). Krijg je hier 'permission denied for
 * column X', dan probeert het script een kolom te schrijven die
 * niet in die grant staat -- breid de migratie uit, niet de
 * rechten van de rol.
 */
export async function writeAudioBack(supabase, table, id, audioUrl, voiceKey) {
  const { error } = await supabase
    .from(table)
    .update({ audio_url: audioUrl, voice_key: voiceKey })
    .eq("id", id);

  if (error) {
    throw new Error(`DB update fout: ${error.message}`);
  }
}

// ── Meldingen ───────────────────────────────────────────────
//
// Drie niveaus, en ze worden gegroepeerd geprint in plaats van
// door elkaar. Een lijst waarin alles even hard schreeuwt, leert
// de lezer alles negeren; een lijst waarin de fouten bovenaan
// staan en de INFO-regels onderaan, niet.

/**
 * Print de afleidingsuitkomsten gegroepeerd op niveau.
 *
 * @param {Array<{label: string, text: string, outcome: object}>} entries
 * @returns {number} aantal harde fouten
 */
export function reportDerivation(entries) {
  const byLevel = { FOUT: [], WAARSCHUWING: [], INFO: [] };

  for (const entry of entries) {
    if (byLevel[entry.outcome.level]) byLevel[entry.outcome.level].push(entry);
  }

  for (const level of ["FOUT", "WAARSCHUWING", "INFO"]) {
    if (byLevel[level].length === 0) continue;

    console.log(`\n${level} (${byLevel[level].length})`);
    for (const entry of byLevel[level]) {
      console.log(`  ${entry.label}  ${entry.text}`);
      console.log(`    ${entry.outcome.reason}`);
    }
  }

  return byLevel.FOUT.length;
}

export function printSummary({ geslaagd, overgeslagen, mislukt }) {
  console.log("\n------------------------------");
  console.log(`Geslaagd    : ${geslaagd}`);
  if (overgeslagen > 0) console.log(`Overgeslagen: ${overgeslagen}`);
  if (mislukt > 0) console.log(`Mislukt     : ${mislukt}`);
  console.log("------------------------------");
}
