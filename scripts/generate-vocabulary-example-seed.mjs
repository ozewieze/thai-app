// Zet een goedgekeurd bestand met canonieke voorbeelden (JSON) om naar een
// idempotent seedbestand (SQL). Het script doet uitsluitend mechanisch werk:
// het woord opzoeken via zijn source_key, volgorde afleiden, tekst escapen.
// Het beoordeelt geen inhoud en verandert geen letter Thais of Paiboon.
//
// Gebruik:
//   node scripts/generate-vocabulary-example-seed.mjs --lesson a1-dialog-03
//   node scripts/generate-vocabulary-example-seed.mjs --in <pad.json> --out <pad.sql>
//
// Met --lesson gelden de conventiepaden:
//   in  = supabase/generation/vocabulary-examples/<lesson_key>_examples.json
//   out = supabase/seed-data/vocabulary-examples/<lesson_key>_examples.seed.sql
//
// Let op: --lesson is UITSLUITEND padsuiker. De les komt niet in het document
// voor en niet in het gegenereerde SQL. Zie ontwerpbeslissing 2 hieronder.
//
// ---------------------------------------------------------------
// Ontwerpbeslissingen die de validatie hieronder verklaren
// ---------------------------------------------------------------
//
// 1. display_order staat NIET in de JSON. De volgorde van de array is de
//    volgorde op het scherm. Dat haalt een hele klasse overschrijffouten weg:
//    je kunt geen nummering hebben die niet klopt met de leesvolgorde.
//
// 2. lesson_key staat er ook niet in, anders dan bij de Language Notes. Het
//    script heeft hem nergens voor nodig: de enige opzoeking is
//    source_key -> vocabulary_master.id. En inhoudelijk zou het veld schadelijk
//    zijn: een canoniek voorbeeld is LESNEUTRAAL (zie "De twee eigenaarschappen"
//    in de gids) en verschijnt ook in les 24, waar de scène van les 3 nooit
//    heeft plaatsgevonden. Een lesveld in de brondata nodigt uit tot precies de
//    fout die de gids verbiedt. De les zit alleen in de bestandsnaam, als
//    archiveringslabel voor de batch.
//
// 3. De sleutels staan er WEL in, en zijn verplicht. De identiteit van een rij
//    is het paar (source_key, example_key). Ze mag nooit meebewegen met de
//    volgorde: zou het script de sleutel uit de positie afleiden, dan zou
//    herordenen de identiteit veranderen en zou de upsert een nieuwe rij
//    invoegen in plaats van de bestaande bij te werken -- inclusief een wees met
//    zijn audio.
//
// 4. Onbekende velden zijn een fout, geen ruis om te negeren. Een prompt die
//    afdrijft levert extra of hernoemde velden op, en dat wil je horen op het
//    moment dat het gebeurt.
//
// 5. `[uncertain]` ergens in de JSON is een harde fout. De schrijverprompt
//    markeert daarmee een Paiboon-vorm die niet uit de meegeleverde lijst kwam.
//    Zo'n markering hoort door mij als developer beslecht te worden; belandt 
//    ze in de database, dan ziet niemand haar ooit nog.
//
// 6. Meer dan één voorbeeld per woord is een harde fout. Vastgelegde beslissing
//    2 van de gids zegt: precies één canoniek voorbeeld per doelwoord -- een
//    ondergrens én een bovengrens. De ondergrens (heeft élk doelwoord van de les
//    er een?) kan dit script principieel niet kennen: er staat geen les in het
//    document. De bovengrens kan het wél zien, en wat het script kan zien hoort
//    het te zien. Bewust hier en niet in het schema: een redactionele beslissing
//    hoort herzienbaar te blijven, en dat kost hier één regel code in plaats van
//    een migratie. Zie de kop van 20260808120000_add_vocabulary_example_natural_key.sql.
//
// ---------------------------------------------------------------
// Wat dit script NIET bewaakt -- lees dit voor je erop vertrouwt
// ---------------------------------------------------------------
//
//   - DEKKING. Het bestand mag 2 van de 5 doelwoorden bevatten. Het script weet
//     niet welke les je schrijft en kan het niet weten. Stap 10, punt 1.
//   - EEN TWEEDE VOORBEELD VIA EEN ANDER BESTAND. Regel 6 kijkt binnen één
//     document. Geeft bestand A 'e1' en bestand B 'e2' aan hetzelfde woord, dan
//     staan er straks twee rijen. Daarom toont vocabulary_example_brief_view de
//     bestaande voorbeelden mét hun tekst.
//   - EEN NIET-BESTAANDE source_key. Het script heeft geen databasetoegang. Dit
//     faalt niet bij het genereren maar wél luid bij het seeden: zie de
//     values-vorm in buildExampleInsert.
//   - REDACTIONELE KWALITEIT: progressieregel/woordbudget, lesneutraliteit,
//     juistheid van de Paiboon (alleen [uncertain] wordt gezien), of de
//     vertaling verenigbaar is met de gloss, de bundel stem/partikel/eerste
//     persoon, en of het doelwoord centraal staat in zijn eigen voorbeeld.
//     Dat is de checklist van Stap 8.

import { readFile, writeFile, mkdir } from "node:fs/promises";
import path from "node:path";

// Twee sleutelvormen, en ze zijn met opzet verschillend.
// source_key volgt vocabulary_master: kleine letters, cijfers, UNDERSCORES
// ('thank_you', 'i_male', 'he_she_they'). Alle 513 masterrijen passen hierop.
// example_key volgt de projectconventie voor nieuwe sleutels: KOPPELTEKENS,
// gelijk aan de vormcheck in de migratie.
// De check op source_key vangt de meest waarschijnlijke drift af: een model dat
// 'thank-you' schrijft. Dat zou anders pas bij het seeden opvallen.
const SOURCE_KEY_PATTERN = /^[a-z0-9]+(_[a-z0-9]+)*$/;
const EXAMPLE_KEY_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const UNCERTAIN_MARKER = "[uncertain]";

const EXAMPLE_FIELDS = [
  "source_key",
  "example_key",
  "thai_script",
  "paiboon",
  "translation_en",
];

// Velden die bewust ontbreken. Ze zouden ook door de generieke
// onbekend-veld-controle gevangen worden, maar dan met een melding die alleen
// zegt DAT het veld niet mag. Hier staat waarom, want dat is de vraag die de
// lezer op dat moment heeft.
const REJECTED_FIELDS = {
  display_order:
    "de volgorde van de array IS de volgorde op het scherm. Het veld staat er " +
    "niet in juist zodat niemand denkt dat het iets doet.",
  lesson_key:
    "een canoniek voorbeeld is lesneutraal en hoort bij het woord, niet bij een " +
    "les. De les zit alleen in de bestandsnaam.",
  audio_url:
    "audio wordt door de audiostap gevuld, niet door de redactionele brondata. " +
    "Een vastgelegde verwijzing naar een bestand dat na een herbouw niet meer " +
    "bestaat, laat het audioproces het item overslaan (zie Stap 11).",
  voice_key:
    "de stemkeuze wordt door de audiostap gezet. Zie Stap 9 van de gids.",
};

class ContractError extends Error {} // Een fout die de gebruiker kan verhelpen door de input te corrigeren. 

function fail(where, message) {
  throw new ContractError(`${where}: ${message}`);
}

function requireExactKeys(object, allowed, where) {
  for (const [field, reason] of Object.entries(REJECTED_FIELDS)) {
    if (field in object) {
      fail(where, `"${field}" hoort hier niet: ${reason}`);
    }
  }
  const unknown = Object.keys(object).filter((k) => !allowed.includes(k));
  if (unknown.length > 0) {
    fail(
      where,
      `onbekend veld ${unknown.map((k) => `"${k}"`).join(", ")}. ` +
        `Toegestaan: ${allowed.join(", ")}. ` +
        `Een onverwacht veld betekent meestal dat de prompt is afgedreven.`,
    );
  }
}

function requireText(object, field, where) {
  const value = object[field];
  if (typeof value !== "string" || value.trim() === "") {
    fail(where, `"${field}" is verplicht en mag niet leeg zijn.`);
  }
  return value;
}

function requireKey(object, field, pattern, where, hint) {
  const value = requireText(object, field, where);
  if (!pattern.test(value)) {
    fail(where, `"${field}" = "${value}" past niet op ${pattern}. ${hint}`);
  }
  return value;
}

// Recursief door de boom lopen, want de markering kan overal zitten -- ook in
// een vertaling, waar ze even schadelijk is als in de Paiboon. De "trail" houdt
// bij waar we zitten, zodat de melding de plek kan noemen.
function assertNoUncertainMarkers(node, trail = "$") {
  if (typeof node === "string") {
    if (node.toLowerCase().includes(UNCERTAIN_MARKER)) {
      fail(
        trail,
        `bevat ${UNCERTAIN_MARKER}. De schrijverprompt markeert daarmee een ` +
          `vorm die niet uit de meegeleverde lijst kwam. Zoek de juiste vorm ` +
          `op in vocabulary_master en haal de markering weg voor je seedt.`,
      );
    }
    return;
  }
  if (Array.isArray(node)) {
    node.forEach((item, i) => assertNoUncertainMarkers(item, `${trail}[${i}]`));
    return;
  }
  if (node && typeof node === "object") {
    for (const [k, v] of Object.entries(node)) {
      assertNoUncertainMarkers(v, `${trail}.${k}`);
    }
  }
}

// ---------------------------------------------------------------
// Validatie van het volledige document
// ---------------------------------------------------------------

function validate(doc) {
  if (!doc || typeof doc !== "object" || Array.isArray(doc)) {
    fail("$", "het document moet een object zijn.");
  }
  requireExactKeys(doc, ["examples"], "$");

  if (!Array.isArray(doc.examples) || doc.examples.length === 0) {
    fail("$.examples", "moet een niet-lege array zijn.");
  }

  // Per woord bijhouden hoeveel voorbeelden we gezien hebben. Die teller doet
  // twee dingen tegelijk: hij levert de display_order (positie binnen het
  // woord) en hij betrapt de tweede rij op hetzelfde woord.
  const perWord = new Map();
  const rows = [];

  doc.examples.forEach((example, index) => {
    const where = `$.examples[${index}]`;
    if (!example || typeof example !== "object" || Array.isArray(example)) {
      fail(where, "moet een object zijn.");
    }
    requireExactKeys(example, EXAMPLE_FIELDS, where);

    const sourceKey = requireKey(
      example,
      "source_key",
      SOURCE_KEY_PATTERN,
      where,
      "source_key volgt vocabulary_master: kleine letters, cijfers en " +
        "underscores ('thank_you'), nooit koppeltekens.",
    );
    const exampleKey = requireKey(
      example,
      "example_key",
      EXAMPLE_KEY_PATTERN,
      where,
      "example_key gebruikt kleine letters, cijfers en koppeltekens. Hij is " +
        "uniek binnen het woord; vandaag is dat altijd 'e1'.",
    );
    requireText(example, "thai_script", where);
    requireText(example, "paiboon", where);
    requireText(example, "translation_en", where);

    const seen = perWord.get(sourceKey);
    if (seen) {
      fail(
        where,
        `"${sourceKey}" heeft al een voorbeeld in dit bestand ` +
          `(${seen.where}, example_key "${seen.exampleKey}"). ` +
          `Vastgelegde beslissing 2 van de gids: precies één canoniek ` +
          `voorbeeld per doelwoord -- niet "minstens één". Wil je het ` +
          `voorbeeld VERVANGEN, wijzig dan de tekst en houd example_key ` +
          `"${seen.exampleKey}"; de seed werkt de bestaande rij dan bij. ` +
          `Heeft het woord in een latere les een tweede functie, dan hoort ` +
          `die in een Language Note (beslissing 3), niet in een tweede zin.`,
      );
    }
    perWord.set(sourceKey, { where, exampleKey });

    rows.push({
      sourceKey,
      exampleKey,
      displayOrder: 1, // positie binnen het woord; zie de opmerking hieronder
      thaiScript: example.thai_script,
      paiboon: example.paiboon,
      translationEn: example.translation_en,
    });
  });

  // Vandaag is display_order altijd 1, omdat een tweede voorbeeld per woord
// hierboven wordt geweigerd. Als die beleidsregel ooit verandert, is dit
// de plek waar de positie per source_key uit perWord moet worden afgeleid.
  return rows;
}

// ---------------------------------------------------------------
// SQL-opbouw
// ---------------------------------------------------------------

function toSqlText(value) {
  if (value == null) return "null";
  return `'${value.replaceAll("'", "''")}'`;
}

function buildExampleInsert(row) {
  return [
    `-- ${row.sourceKey} / ${row.exampleKey}`,
    "insert into public.vocabulary_examples",
    "  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)",
    "values (",
    `  (select id from public.vocabulary_master where source_key = ${toSqlText(row.sourceKey)}),`,
    `  ${toSqlText(row.exampleKey)},`,
    `  ${row.displayOrder},`,
    `  ${toSqlText(row.thaiScript)},`,
    `  ${toSqlText(row.paiboon)},`,
    `  ${toSqlText(row.translationEn)}`,
    ")",
    "on conflict (vocabulary_id, example_key) do update set",
    "  display_order  = excluded.display_order,",
    "  thai_script    = excluded.thai_script,",
    "  paiboon        = excluded.paiboon,",
    "  translation_en = excluded.translation_en,",
    "  audio_url      = case",
    "                     when vocabulary_examples.thai_script is distinct from excluded.thai_script",
    "                     then null",
    "                     else vocabulary_examples.audio_url",
    "                   end;",
  ].join("\n");
}

function buildSql(rows, inputPath) {
  const parts = [];

  parts.push(
    [
      `-- Automatisch gegenereerd uit ${inputPath.replaceAll("\\", "/")}.`,
      "-- Niet met de hand bewerken: draai scripts/generate-vocabulary-example-seed.mjs opnieuw.",
      "--",
      "-- Het bestand is idempotent. Opnieuw draaien is de manier om een correctie",
      "-- door te voeren -- voor toevoegen en wijzigen. Verwijderen niet: haal je een",
      "-- voorbeeld uit de JSON, dan blijft de rij in de database staan. Dat is een",
      "-- aparte, expliciete handeling.",
      "--",
      "-- Waarom de `values ((select ...))`-vorm en niet `select ... join`: vindt de",
      "-- subquery de source_key niet, dan levert deze vorm null op en botst hij op",
      "-- NOT NULL. Het bestand faalt dan luid. De join-vorm zou nul rijen invoegen",
      "-- en zwijgen -- en dan mist er stil een voorbeeld waarvan de",
      "-- publicatievalidatie later denkt dat het bestaat.",
      "--",
      "-- Waarom audio_url op null gaat bij gewijzigde thai_script: audio die bij een",
      "-- oudere zin hoort is erger dan geen audio. Het audioscript slaat een item met",
      "-- een gevulde audio_url over ('er is al audio'), en de leerling hoort dan de",
      "-- oude zin zonder dat iemand een foutmelding ziet. voice_key blijft wel staan:",
      "-- dat is een redactionele keuze en geen verwijzing die kan verouderen.",
      "--",
      "-- Geen `updated_at = now()`: trg_vocabulary_examples_set_updated_at zet dat",
      "-- veld zelf.",
      "",
      "begin;",
      "",
    ].join("\n"),
  );

  for (const row of rows) parts.push(buildExampleInsert(row));

  parts.push("commit;");
  return parts.join("\n\n") + "\n";
}

// ---------------------------------------------------------------

function parseArgs(argv) { //argv is de array van commandline argumenten
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) continue;
    const name = token.slice(2);
    const value = argv[i + 1];
    if (value === undefined || value.startsWith("--")) {
      throw new ContractError(`Optie --${name} verwacht een waarde.`);
    }
    args[name] = value;
    i += 1;
  }
  return args;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));//bvb {name:a1-dialog-03} of {in:pad.json, out:pad.sql}

  let inputPath = args.in;
  let outputPath = args.out;

  if (args.lesson) {
    const stem = args.lesson.replaceAll("-", "_");
    inputPath ??= path.join(
      "supabase",
      "generation",
      "vocabulary-examples",
      `${stem}_examples.json`,
    );
    outputPath ??= path.join(
      "supabase",
      "seed-data",
      "vocabulary-examples",
      `${stem}_examples.seed.sql`,
    );
  }

  if (!inputPath || !outputPath) {
    throw new ContractError(
      "Geef --lesson <lesson_key>, of --in <pad.json> en --out <pad.sql>.",
    );
  }

  let doc;
  try {
    doc = JSON.parse(await readFile(inputPath, "utf8"));// maakt van het JSON-bestand een JS-object bvb examples = {examples:[{source_key:..., example_key:..., ...}, ...]}
  } catch (error) {
    throw new ContractError(`${inputPath} kon niet gelezen worden: ${error.message}`);
  }

  assertNoUncertainMarkers(doc);
  const rows = validate(doc);

  // Anders dan bij de Language Notes is er geen kruiscontrole tussen --lesson en
  // de inhoud van het bestand. Die kan er niet zijn: het document draagt geen
  // les, en dat is opzet (ontwerpbeslissing 2). --lesson bepaalt alleen waar de
  // bestanden staan.

  const sql = buildSql(rows, inputPath);

  await mkdir(path.dirname(outputPath), { recursive: true });//recursive: true maakt de map aan als die nog niet bestaat
  await writeFile(outputPath, sql, "utf8");

  console.log(
    `${outputPath}: ${rows.length} voorbeelden voor ${rows.length} woorden.`,
  );
}

main().catch((error) => {
  if (error instanceof ContractError) {
    console.error(`Contractfout -- ${error.message}`);
  } else {
    console.error(error);
  }
  process.exit(1);
});
