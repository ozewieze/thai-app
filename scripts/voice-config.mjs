// ============================================================
// voice-config.mjs
//
// Twee dingen: welke Google Cloud TTS-stem hoort bij welke
// sleutel, en welke sleutel hoort bij welk stuk tekst.
//
// Stemmen:
//   Neural2  — huidige generatie, betrouwbaar voor Thai
//   Chirp3   — nieuwste generatie, natuurlijker, ondersteunt
//              custom voice training (fase 2: voice actors)
//
// Om te wisselen naar Chirp3: vervang de `name` waarde door
// bijv. 'th-TH-Chirp3-HD-Aoede' en test via de Google Cloud
// Text-to-Speech console (https://cloud.google.com/text-to-speech).
//
// SSML: standaard uitgeschakeld. Zet `ssml: true` in een
// toekomstig script voor oefeningen die trager of met pauzes
// worden uitgesproken. De API call gebruikt dan `ssmlText`
// in plaats van `text`.
// ============================================================

import { fileURLToPath } from "node:url";
import { resolve } from "node:path";

// ── Stemmen ─────────────────────────────────────────────────
//
// Twee soorten sleutels in één map:
//
//   mali / narin            personagestemmen, gebruikt door
//                           scripts/generate-audio.mjs via
//                           dialog_blocks.speaker_key
//   narrator_female / _male instructiestemmen, gebruikt door de
//                           drie audioscripts voor lemma's en
//                           voorbeelden via voice_key
//
// De narrators gebruiken bewust dezelfde stemmen als Mali en
// Narin. Een eigen narratorstem kiezen is werk met een
// houdbaarheidsdatum: de hele TTS-pijplijn verdwijnt zodra
// stemacteurs het overnemen. Redactioneel blijft het
// onderscheid wél bestaan — een Vocabulary Card hoort een
// instructiestem te gebruiken, geen personagestem — en dat
// onderscheid leeft hier in de sleutel, niet in het geluid.
//
// voice_key is vrije tekst in de database, net als
// dialog_blocks.speaker_key. Deze map is scriptconfiguratie,
// geen referentiedata.

export const VOICE_MAP = {
  mali: {
    languageCode: "th-TH",
    name: "th-TH-Neural2-C", // vrouwelijk
  },
  narin: {
    languageCode: "th-TH",
    name: "th-TH-Chirp3-HD-Fenrir", // mannelijk (Chirp3 — Neural2 heeft geen Thaise mannenstem)
  },
  narrator_female: {
    languageCode: "th-TH",
    name: "th-TH-Neural2-C",
  },
  narrator_male: {
    languageCode: "th-TH",
    name: "th-TH-Chirp3-HD-Fenrir",
  },
};

// Audioformaat voor Supabase Storage.
// MP3 is het breedst ondersteund in browsers en iOS Safari.
export const AUDIO_CONFIG = {
  audioEncoding: "MP3",
};

// ── Meldingsniveaus ─────────────────────────────────────────
//
// Drie niveaus, en ze horen uit elkaar gehouden te worden. Een
// lijst waarin alles even hard schreeuwt, leert de lezer alles
// negeren.
//
//   FOUT          script stopt, data repareren
//   WAARSCHUWING  één keer bekijken, meestal geldig
//   INFO          geen actie, alleen zichtbaarheid
//   OK            niets te melden
//
// FOUT wordt teruggegeven en niet geworpen. De aanroeper hoort
// eerst álle rijen af te leiden en pas daarna te genereren, zodat
// je in één keer elke gebroken rij ziet in plaats van de eerste
// — en zodat een harde fout valt vóór de eerste TTS-aanroep, niet
// halverwege een batch die al deels opgenomen is.

export const LEVEL = {
  OK: "OK",
  INFO: "INFO",
  WARNING: "WAARSCHUWING",
  ERROR: "FOUT",
};

export const DEFAULT_NARRATOR = "narrator_female";

// ── De stemafleiding voor voorbeeldzinnen ───────────────────
//
// Thai schrijft geen woordgrenzen. Daarom wordt hier nooit op
// substring gematcht, maar altijd verankerd aan begin of einde.
// Deze regel is drie keer herzien voordat hij deugde, en de
// gesneuvelde versies staan hier omdat de volgende lezer anders
// opnieuw naar de eerste grijpt:
//
//   1. "bevat ผม of ครับ"  — sneuvelde op twee woorden uit de
//      masterlijst zelf: คะแนน (ka-naaen, score) bevat คะ, en
//      หวีผม (wǐi-pǒm, comb hair) bevat ผม. De correcte zinnen
//      ฉันหวีผมค่ะ en ผมได้คะแนนดีครับ werden allebei als
//      bundelfout gemeld.
//   2. verankerd aan begin én einde, symmetrisch — sneuvelde op
//      ผม als homograaf: het is "ik" én "haar". ผมฉันสีดำค่ะ
//      ("mijn haar is zwart") is volstrekt correct Thai en werd
//      geweigerd. Een controle die geldige zinnen afkeurt is
//      erger dan geen controle.
//   3. asymmetrisch, hieronder. ฉัน is in de masterlijst alleen
//      "ik" en geen enkel woord begint ermee, dus die helft is
//      betrouwbaar genoeg voor een harde fout. ผม is dat niet en
//      krijgt een waarschuwing.
//
// Les daaruit: behandel stringregels over Thais schrift als
// heuristiek met een uitgang, niet als invariant — en test het
// sóórt regel, niet alleen de rijen die er nu staan.
//
// Verankering gemeten op 2026-08-14 over alle 514 rijen van
// vocabulary_master: geen enkel woord eindigt op een partikel.
// Twee woorden beginnen met een voornaamwoord, namelijk de
// voornaamwoorden zelf (source_key 'i' = ฉัน en 'i_male' = ผม);
// die raken de zinsafleiding niet, want een lemma komt hier
// nooit langs — daarvoor is narratorForLemma(). Hertel dit
// wanneer de masterlijst groeit; geloof het getal niet.

const MALE_ENDINGS = ["ครับผม", "ครับ"];
const FEMALE_ENDINGS = ["ค่ะ", "คะ"];
const MALE_PRONOUN = "ผม";
const FEMALE_PRONOUN = "ฉัน";

// ครับผม staat gelijkwaardig naast ครับ en niet als uitzondering
// eronder. Het is een gewone beleefde variant, en zonder deze
// regel valt hij door de partikelcontrole heen naar de
// voornaamwoordterugval — die op het begin ankert, dus dan zou
// een zin op ครับผม de standaard vrouwenstem krijgen.

// Leestekens aan het einde breken de verankering stil: 'สวัสดีค่ะ?'
// eindigt niet op ค่ะ en zou de standaardstem krijgen. We ankeren
// daarom op de tekst zonder slotleesteken, maar melden het wel —
// stil normaliseren zou een dataprobleem verbergen.
//
// Thai schrijft geen vraagteken en geen punt, dus deze controle
// vuurt nooit op correct Thais. Dat is precies de bedoeling: als
// hij vuurt, is er iets misgegaan in de generatiestap — een model
// dat een Engelse gewoonte meebrengt. Hij bewaakt geen Thaise
// spelling maar de invoerketen erheen.
const TRAILING_PUNCTUATION = /[.!?…"'’”)\]]+$/u;

function outcome(narratorKey, level, reason, notes) {
  return {
    narratorKey,
    level,
    reason: notes.length > 0 ? `${reason} (${notes.join("; ")})` : reason,
  };
}

/**
 * Leid de narrator af uit een voorbeeldzin.
 *
 * Volgorde, en die volgorde is de regel:
 *   eindigt op ครับ / ครับผม   -> narrator_male
 *   eindigt op ค่ะ of คะ        -> narrator_female
 *   geen partikel, begint met ผม  -> narrator_male
 *   geen partikel, begint met ฉัน -> narrator_female
 *   geen van beide                -> narrator_female (standaard)
 *
 * De terugval op het voornaamwoord is nodig omdat een zin als
 * ผมไปได้ zonder partikel anders de vrouwenstem zou krijgen —
 * precies de fout die deze regel moet voorkomen. De homograaf
 * weegt daar licht: ผมสีดำ ("haar is zwart", zonder partikel)
 * krijgt dan een mannenstem, wat willekeurig is maar niet fout,
 * terwijl ผมไปได้ zonder de terugval gewoon verkeerd is.
 *
 * @param {string} thaiScript
 * @returns {{narratorKey: string|null, level: string, reason: string}}
 *   narratorKey is null bij LEVEL.ERROR.
 */
export function deriveNarratorFromSentence(thaiScript) {
  const trimmed = String(thaiScript ?? "").trim();
  const sentence = trimmed.replace(TRAILING_PUNCTUATION, "");
  const notes = [];

  if (sentence === "") {
    return outcome(null, LEVEL.ERROR, "lege zin", notes);
  }
  if (sentence !== trimmed) {
    notes.push("zin eindigt op een leesteken; verankerd zonder dat teken");
  }

  const endsMale = MALE_ENDINGS.some((particle) => sentence.endsWith(particle));
  const endsFemale = FEMALE_ENDINGS.some((particle) => sentence.endsWith(particle));
  const startsMale = sentence.startsWith(MALE_PRONOUN);
  const startsFemale = sentence.startsWith(FEMALE_PRONOUN);

  // Bundelcontrole, asymmetrisch — zie de toelichting hierboven.
  // Dit is het tweede handhavingspunt voor een regel die vandaag
  // alleen door de schrijverprompt gedragen wordt, op een plek
  // waar de fout niet meer te repareren is zonder de opname weg
  // te gooien.
  if (startsFemale && endsMale) {
    return outcome(
      null,
      LEVEL.ERROR,
      "begint met ฉัน en eindigt op een mannelijk partikel — gebroken bundel, corrigeer de tekst",
      notes,
    );
  }
  if (startsMale && endsFemale) {
    notes.push(
      "begint met ผม en eindigt op ค่ะ/คะ — geldig als ผม hier 'haar' betekent, anders een gebroken bundel",
    );
  }

  if (endsMale) {
    return outcome(
      "narrator_male",
      notes.length > 0 ? LEVEL.WARNING : LEVEL.OK,
      "slotpartikel ครับ",
      notes,
    );
  }
  if (endsFemale) {
    return outcome(
      "narrator_female",
      notes.length > 0 ? LEVEL.WARNING : LEVEL.OK,
      "slotpartikel ค่ะ/คะ",
      notes,
    );
  }
  if (startsMale) {
    return outcome(
      "narrator_male",
      notes.length > 0 ? LEVEL.WARNING : LEVEL.OK,
      "geen slotpartikel, begint met ผม",
      notes,
    );
  }
  if (startsFemale) {
    return outcome(
      "narrator_female",
      notes.length > 0 ? LEVEL.WARNING : LEVEL.OK,
      "geen slotpartikel, begint met ฉัน",
      notes,
    );
  }

  // Geen genderelement. Dat is INFO en geen waarschuwing: กาแฟร้อน
  // en ชาเย็น zijn nu eenmaal neutraal en dat blijft altijd zo.
  // Deze regels horen bij elke run te verschijnen zonder dat er
  // iets te doen valt. Omdat de scripts rijen met een gevulde
  // audio_url overslaan, zie je ze na de eerste run alleen nog
  // terug na een lokale db reset.
  return outcome(DEFAULT_NARRATOR, LEVEL.INFO, "geen genderelement, standaardstem", notes);
}

// ── De stemkeuze voor lemma-audio ───────────────────────────
//
// Hier geldt geen afleiding uit de tekst. Een lemma is een
// woord, geen uitspraak, en ผม als los woord is niet van หวีผม
// te onderscheiden door te matchen. De regel is daarom: altijd
// de vrouwelijke narrator, met een expliciete overrulelijst op
// source_key. Dat is auditeerbaar en hangt van geen enkele
// stringvergelijking af.
//
// Groeit deze lijst, dan is dat een redactionele beslissing per
// woord en geen patroon dat je kunt afleiden.

export const LEMMA_NARRATOR_OVERRIDES = {
  i_male: "narrator_male", // ผม — het mannelijke 'ik'
};

/**
 * Bepaal de narrator voor een lemma.
 *
 * @param {string} sourceKey
 * @returns {{narratorKey: string, level: string, reason: string}}
 */
export function narratorForLemma(sourceKey) {
  const key = String(sourceKey ?? "");

  // Object.hasOwn en niet `OVERRIDES[key]`: source_key komt uit de
  // database, en een sleutel als 'constructor' of 'toString' zou
  // anders een waarde van het prototype opleveren.
  if (Object.hasOwn(LEMMA_NARRATOR_OVERRIDES, key)) {
    return {
      narratorKey: LEMMA_NARRATOR_OVERRIDES[key],
      level: LEVEL.INFO,
      reason: `overrulelijst op source_key '${key}'`,
    };
  }

  return {
    narratorKey: DEFAULT_NARRATOR,
    level: LEVEL.OK,
    reason: "standaard voor lemma's",
  };
}

// ── Zelftest ────────────────────────────────────────────────
//
// Draaien met:  node scripts/voice-config.mjs --self-test
//
// Deze tabel test het sóórt regel, niet de rijen die er nu
// toevallig staan. Elke gesneuvelde versie van de regel heeft
// hier zijn eigen tegenvoorbeeld, zodat een herziening die
// terugvalt op substring-matching direct zichtbaar wordt.

const SELF_TEST_SENTENCES = [
  // gewone gevallen
  ["สวัสดีค่ะ", "narrator_female", LEVEL.OK],
  ["สวัสดีครับ", "narrator_male", LEVEL.OK],
  ["คุณชื่ออะไรคะ", "narrator_female", LEVEL.OK],
  ["ดื่มกาแฟด้วยกันไหมครับ", "narrator_male", LEVEL.OK],

  // ครับผม — gelijkwaardige beleefde variant. Zonder de regel zou
  // deze op ผม eindigen, door de partikelcontrole heen vallen en
  // de standaard vrouwenstem krijgen.
  ["ขอบคุณครับผม", "narrator_male", LEVEL.OK],

  // de twee woorden waarop substring-matching sneuvelde
  ["ฉันหวีผมค่ะ", "narrator_female", LEVEL.OK],
  ["ผมได้คะแนนดีครับ", "narrator_male", LEVEL.OK],
  ["คะแนน", "narrator_female", LEVEL.INFO],
  ["หวีผม", "narrator_female", LEVEL.INFO],

  // terugval op het voornaamwoord, zonder partikel
  ["ผมไปได้", "narrator_male", LEVEL.OK],
  ["ฉันไปได้", "narrator_female", LEVEL.OK],
  // willekeurig maar niet fout: ผม betekent hier 'haar'
  ["ผมสีดำ", "narrator_male", LEVEL.OK],

  // asymmetrische bundelcontrole
  ["ผมฉันสีดำค่ะ", "narrator_female", LEVEL.WARNING],
  ["ฉันชื่อนัทครับ", null, LEVEL.ERROR],

  // geen genderelement — hoort INFO te zijn, geen waarschuwing
  ["กาแฟร้อน", "narrator_female", LEVEL.INFO],
  ["ชาเย็น", "narrator_female", LEVEL.INFO],

  // vorm van de invoer
  ["  สวัสดีค่ะ  ", "narrator_female", LEVEL.OK],
  ["สวัสดีค่ะ?", "narrator_female", LEVEL.WARNING],
  ["", null, LEVEL.ERROR],
];

const SELF_TEST_LEMMAS = [
  ["i_male", "narrator_male"],
  ["i", "narrator_female"],
  ["comb_hair", "narrator_female"],
  ["score", "narrator_female"],
  ["constructor", "narrator_female"], // prototype-lek
];

function runSelfTest() {
  let mislukt = 0;

  console.log("Zinnen\n");
  for (const [sentence, expectedNarrator, expectedLevel] of SELF_TEST_SENTENCES) {
    const result = deriveNarratorFromSentence(sentence);
    const ok = result.narratorKey === expectedNarrator && result.level === expectedLevel;
    if (!ok) mislukt++;
    console.log(
      `  ${ok ? "ok  " : "FOUT"} ${JSON.stringify(sentence)} -> ${result.narratorKey} / ${result.level}` +
        (ok ? "" : `  (verwacht ${expectedNarrator} / ${expectedLevel})`),
    );
    console.log(`       ${result.reason}`);
  }

  console.log("\nLemma's\n");
  for (const [sourceKey, expectedNarrator] of SELF_TEST_LEMMAS) {
    const result = narratorForLemma(sourceKey);
    const ok = result.narratorKey === expectedNarrator;
    if (!ok) mislukt++;
    console.log(
      `  ${ok ? "ok  " : "FOUT"} ${sourceKey} -> ${result.narratorKey}` +
        (ok ? "" : `  (verwacht ${expectedNarrator})`),
    );
  }

  const total = SELF_TEST_SENTENCES.length + SELF_TEST_LEMMAS.length;
  console.log("\n------------------------------");
  console.log(`${total - mislukt}/${total} geslaagd`);
  console.log("------------------------------");

  if (mislukt > 0) process.exit(1);
}

// Alleen bij directe uitvoering, niet bij import.
//
// De vlag beslist, niet de padvergelijking. Anders hangt het
// draaien van de zelftest aan een string-vergelijking die op één
// platform anders uitpakt — hoofdletter van de schijfletter, een
// symlink, een spatie in het pad — en het gevolg daarvan is
// stilte, de slechtste uitkomst van allemaal. Dat is precies wat
// er gebeurde: in een file://-URL staat %20 waar het pad een
// spatie heeft ('personal projects'), en in process.argv[1] een
// echte spatie. De padcontrole bepaalt nu alleen nog of de
// gebruiksregel getoond wordt; fileURLToPath draait de
// URL-codering terug.
const thisFile = fileURLToPath(import.meta.url);
const invokedFile = process.argv[1] ? resolve(process.argv[1]) : null;

if (process.argv.includes("--self-test")) {
  runSelfTest();
} else if (invokedFile === thisFile) {
  console.log("Gebruik: node scripts/voice-config.mjs --self-test");
}
