import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
// Het Node-script zet de CSV om naar een SQL-bestand met INSERT-regels.
const INPUT_CSV = path.join(
  "supabase",
  "seed-data",
  "master",
  "csv",
  "phrase_master.csv",
);
const OUTPUT_SQL = path.join(
  "supabase",
  "seed-data",
  "master",
  "phrase_master.seed.sql",
);

const COLUMNS = [
  "phrase_key",
  "cefr_level",
  "title",
  "phrase_formula",
  "short_explanation",
  "phrase_type",
  "register",
  "fixedness_level",
  "is_productive",
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
  return result;
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
    `Invalid boolean in is_productive at CSV row ${rowNumber}: ${value}`,
  );
}

async function main() {
  let raw = await readFile(INPUT_CSV, "utf8");
  if (raw.charCodeAt(0) === 0xfeff) raw = raw.slice(1); // strip UTF-8 BOM if present
  const lines = raw
    .split(/\r?\n/)
    .filter(Boolean);

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
      phrase_key,
      cefr_level,
      title,
      phrase_formula,
      short_explanation,
      phrase_type,
      register,
      fixedness_level,
      is_productive,
      source_note,
    ] = row;

    const tuple = [
      toSqlText(phrase_key),
      toSqlText(cefr_level),
      toSqlText(title),
      toSqlText(phrase_formula),
      toSqlText(short_explanation),
      toSqlText(phrase_type),
      toSqlText(register),
      toSqlText(fixedness_level),
      toSqlBoolean(is_productive, rowNumber),
      toSqlText(source_note),
    ];

    valuesSql.push(`(${tuple.join(", ")})`);
  }

  const out = [
    `-- Auto-generated from ${INPUT_CSV}. Do not edit manually.`,
    "insert into public.phrase_master (phrase_key, cefr_level, title, phrase_formula, short_explanation, phrase_type, register, fixedness_level, is_productive, source_note) values",
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
