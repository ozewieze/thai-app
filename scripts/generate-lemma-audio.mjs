// ============================================================
// generate-lemma-audio.mjs
//
// Genereert lemma-audio: het woord alleen, in citeervorm, voor
// de audioknop links van het Thaise schrift op een Vocabulary
// Card. Vult vocabulary_master.audio_url en .voice_key.
//
// Pipeline per lemma:
//   1. Haal vocabulary_master op waar audio_url null is
//   2. Bepaal de narrator via narratorForLemma() -- de
//      overrulelijst op source_key, geen tekstafleiding
//   3. Roep Google Cloud TTS aan
//   4. Upload de MP3 naar 'audio' onder vocab/lemmas/
//   5. Schrijf audio_url + voice_key terug
//
// Uitvoeren (standaard: alleen lemma's die aan minstens één les
// gekoppeld zijn):
//   node --env-file=.env.local scripts/generate-lemma-audio.mjs
//
// Dry-run -- toont per lemma welke stem gekozen wordt, zonder
// uploads of DB-wijzigingen:
//   node --env-file=.env.local scripts/generate-lemma-audio.mjs --dry-run
//
// De hele masterlijst, ook woorden die in geen enkele les
// voorkomen (vereist --yes, zie hieronder):
//   node --env-file=.env.local scripts/generate-lemma-audio.mjs --all --yes
//
// Eén of meer specifieke woorden, ongeacht leskoppeling:
//   node --env-file=.env.local scripts/generate-lemma-audio.mjs --source-key coffee --source-key snack
//
// Idempotent: lemma's met een bestaande audio_url worden
// overgeslagen. Corrigeer je de thai_script van een woord in de
// database, dan zet de trigger uit migratie 20260814120100
// audio_url en voice_key weer op null, en pakt de volgende run
// het woord vanzelf opnieuw op.
//
// Waarom de leskoppeling de standaard is. Een lemma dat aan geen
// enkele les hangt, komt op geen enkele Vocabulary Card terecht
// en wordt dus nooit afgespeeld. Gemeten op 2026-08-14: 30 van de
// 514 lemma's zijn gekoppeld. Audio maken voor de andere 484 is
// betalen voor bestanden die niemand hoort, in een TTS-pijplijn
// die door stemacteurs vervangen gaat worden. Groeit het
// curriculum, dan groeit de standaardselectie vanzelf mee -- je
// koppelt een woord aan een les en de volgende run pakt het op.
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
import { VOICE_MAP, narratorForLemma } from "./voice-config.mjs";

// ── Configuratie ────────────────────────────────────────────

const DRY_RUN = hasFlag("--dry-run");
const ALL = hasFlag("--all");
const YES = hasFlag("--yes");
const SOURCE_KEYS = flagValues("--source-key");
const LIMIT = readLimit();

const { SUPABASE_URL, supabase, ttsApiUrl } = readEnvironment();

if (ALL && SOURCE_KEYS.length > 0) {
  console.error("FOUT: --all en --source-key sluiten elkaar uit.");
  console.error("  --all neemt de hele masterlijst, --source-key een handmatige selectie.");
  process.exit(1);
}

/**
 * Pad binnen de 'audio'-bucket.
 *
 * source_key 'i_male' -> 'vocab/lemmas/i_male.mp3'
 *
 * Lesneutraal, en dat is de bedoeling: een lemma hoort bij een
 * woord, niet bij een les. Zou de les in het pad zitten, dan zou
 * de opslaglaag een binding suggereren die de data niet heeft.
 * De sleutel is bovendien stabiel over een db reset heen, anders
 * dan het identity-id -- hetzelfde woord landt na een herbouw
 * dus op hetzelfde pad.
 *
 * Alle 514 source_keys voldoen aan [a-z0-9_]+ (gecontroleerd
 * 2026-08-14), dus er valt niets te escapen. Hercontroleer dat
 * wanneer er een sleutel met een ander teken bij komt.
 */
function buildStoragePath(sourceKey) {
  return `vocab/lemmas/${sourceKey}.mp3`;
}

// ── Ophalen ─────────────────────────────────────────────────

async function fetchCandidates() {
  const withoutAudio = await fetchAllRows(() =>
    supabase
      .from("vocabulary_master")
      .select("id, source_key, thai_script")
      .is("audio_url", null)
      .order("id"),
  );

  if (SOURCE_KEYS.length > 0) {
    const requested = new Set(SOURCE_KEYS);
    const found = withoutAudio.filter((row) => requested.has(row.source_key));

    // Een getypte sleutel die niets oplevert is een harde fout.
    // Stil overslaan zou betekenen dat je denkt audio te hebben
    // gemaakt voor een woord dat je verkeerd hebt gespeld.
    const foundKeys = new Set(found.map((row) => row.source_key));
    const missing = SOURCE_KEYS.filter((key) => !foundKeys.has(key));

    if (missing.length > 0) {
      const existing = await fetchAllRows(() =>//geeft bvb [ { source_key: 'coffee' } ] of []
        supabase.from("vocabulary_master").select("source_key").in("source_key", missing),
      );//bvb [ { source_key: 'coffee' } ]
      const existingKeys = new Set(existing.map((row) => row.source_key));//bvb Set { 'coffee' }

      for (const key of missing) {
        if (existingKeys.has(key)) {//dus hij zit in vocabulary_master, maar heeft al audio_url != null
          console.error(
            `FOUT: '${key}' heeft al audio. Wijzig de thai_script of verwijder audio_url handmatig.`,
          );
        } else {
          console.error(`FOUT: source_key '${key}' bestaat niet in vocabulary_master.`);
        }
      }
      process.exit(1);
    }

    return { rows: found, unlinked: 0 };
  }

  if (ALL) {
    return { rows: withoutAudio, unlinked: 0 };
  }

  // Standaard: alleen lemma's met minstens één leskoppeling.
  // Twee losse queries in plaats van een embedded !inner-join:
  // het resultaat is hetzelfde, maar dit maakt zichtbaar hoeveel
  // woorden om welke reden afvallen -- en dat getal hoort in de
  // uitvoer.
  const links = await fetchAllRows(() =>
    supabase.from("lesson_vocabulary").select("vocabulary_id").order("vocabulary_id"),
  );
  const linkedIds = new Set(links.map((row) => row.vocabulary_id));//bvb Set { 1, 2, 3, 4, 5 }

  const rows = withoutAudio.filter((row) => linkedIds.has(row.id));//bvb [ { id: 1, source_key: 'coffee', thai_script: 'กาแฟ' } ]
  return { rows, unlinked: withoutAudio.length - rows.length };
}

// ── Hoofdlogica ─────────────────────────────────────────────

async function generateLemmaAudio() {
  if (DRY_RUN) {
    console.log("DRY-RUN — geen uploads, geen DB-wijzigingen\n");
  }

  const { rows, unlinked } = await fetchCandidates();

  if (unlinked > 0) {
    console.log(
      `INFO: ${unlinked} lemma('s) zonder audio hangen aan geen enkele les en vallen buiten deze run.`,
    );
    console.log("      Draai met --all --yes om ze toch te verwerken.\n");
  }

  if (rows.length === 0) {
    console.log("Geen lemma's te doen.");
    return;
  }

  // Fase 1: eerst alles afleiden, dan pas genereren.
  // Voor lemma's kan de afleiding niet hard falen -- het is een
  // opzoeking in een lijst, geen tekstanalyse -- maar de vorm is
  // gelijk aan die van de twee voorbeeldscripts, waar het wél kan.
  const planned = rows.map((row) => ({
    row,
    outcome: narratorForLemma(row.source_key),
    label: `[${row.source_key}]`,
    text: row.thai_script,
    storagePath: buildStoragePath(row.source_key),
  }));

  const errorCount = reportDerivation(planned);
  if (errorCount > 0) {
    console.error(`\nGestopt: ${errorCount} rij(en) met een harde fout. Er is niets gegenereerd.`);
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

  console.log(`\n${selection.length} lemma('s) te verwerken.\n`);

  let geslaagd = 0;
  let mislukt = 0;

  for (const item of selection) {
    const voice = VOICE_MAP[item.outcome.narratorKey];
    const publicUrl = publicUrlFor(SUPABASE_URL, item.storagePath);

    if (DRY_RUN) {
      console.log(item.label);
      console.log(`  tekst : ${item.text}`);
      console.log(`  stem  : ${item.outcome.narratorKey} -> ${voice.name}`);
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
        "vocabulary_master",
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

generateLemmaAudio().catch((err) => {
  console.error(`FOUT: ${err.message}`);
  process.exit(1);
});
