import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
//Het Node-script zet de CSV om naar een SQL-bestand met INSERT-regels.
const INPUT_CSV = path.join(
  "supabase",
  "seed-data",
  "master",
  "csv",
  "vocabulary_master.csv",
);
const OUTPUT_SQL = path.join(
  "supabase",
  "seed-data",
  "master",
  "vocabulary_master.seed.sql",
);

const COLUMNS = [
  "source_key",
  "cefr_level",
  "thai_script",
  "paiboon",
  "english_gloss",
  "part_of_speech",
  "register",
  "default_theme",
  "is_multifunctional",
  "usage_note",
  "source_note",
];

function parseCsvLine(line) {
  const result = [];
  let current = "";
  let inQuotes = false;

  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];

    if (ch === '"') {
      if (inQuotes && line[i + 1] === '"') {
        current += '"';
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (ch === "," && !inQuotes) {
      result.push(current);
      current = "";
      continue;
    }

    current += ch;
  }

  result.push(current);
  return result;//parseCsvLine is dus een functie die een CSV-regel omzet in een array van waarden. Het houdt rekening met aanhalingstekens en dubbele aanhalingstekens binnen de waarden.
}

function toSqlText(value) {
  if (value == null || value === "") return "NULL";
  return `'${value.replaceAll("'", "''")}'`;
}

function toSqlBoolean(value, rowNumber) {
  const normalized = (value ?? "").trim().toLowerCase();

  if (normalized === "true") return "true";
  if (normalized === "false" || normalized === "") return "false";

  throw new Error(
    `Invalid boolean in is_multifunctional at CSV row ${rowNumber}: ${value}`,
  );
}

async function main() {
  const raw = await readFile(INPUT_CSV, "utf8");//raw is een string die de inhoud van het CSV-bestand bevat. Het bestand wordt gelezen met UTF-8 codering.
  const lines = raw
    .replace(/^\uFEFF/, "")//
    .split(/\r?\n/)//regex die de string splitst op nieuwe regels, ongeacht of het Windows (\r\n) of Unix (\n) stijl is.
    .filter(Boolean);//lines is een array van strings, waarbij elke string een regel uit het CSV-bestand vertegenwoordigt. De eerste regel is de header met kolomnamen, en de volgende regels bevatten de gegevens. Lege regels worden verwijderd.

  if (lines.length < 2) {
    throw new Error(
      "CSV appears empty. Expected header + at least one data row.",
    );
  }

  const header = parseCsvLine(lines[0]);
  if (header.join(",") !== COLUMNS.join(",")) {
    throw new Error(
      `Unexpected CSV header.\nExpected: ${COLUMNS.join(",")}\nActual:   ${header.join(",")}`,
    );
  }

  const valuesSql = [];

  for (let i = 1; i < lines.length; i += 1) {
    const rowNumber = i + 1;
    const row = parseCsvLine(lines[i]);

    if (row.length !== COLUMNS.length) {
      throw new Error(
        `CSV row ${rowNumber} has ${row.length} columns, expected ${COLUMNS.length}.`,
      );
    }

    const [
      source_key,
      cefr_level,
      thai_script,
      paiboon,
      english_gloss,
      part_of_speech,
      register,
      default_theme,
      is_multifunctional,
      usage_note,
      source_note,
    ] = row;

    const tuple = [
      toSqlText(source_key),
      toSqlText(cefr_level),
      toSqlText(thai_script),
      toSqlText(paiboon),
      toSqlText(english_gloss),
      toSqlText(part_of_speech),
      toSqlText(register),
      toSqlText(default_theme),
      toSqlBoolean(is_multifunctional, rowNumber),
      toSqlText(usage_note),
      toSqlText(source_note),
    ];

    valuesSql.push(`(${tuple.join(", ")})`);
  }

  const out = [
    `-- Auto-generated from ${INPUT_CSV}. Do not edit manually.`,
    "insert into public.vocabulary_master (source_key, cefr_level, thai_script, paiboon, english_gloss, part_of_speech, register, default_theme, is_multifunctional, usage_note, source_note) values",
    `${valuesSql.join(",\n")};`,
    "",
  ].join("\n");

  await writeFile(OUTPUT_SQL, out, "utf8");
  console.log(`Generated ${OUTPUT_SQL} with ${valuesSql.length} rows.`);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
