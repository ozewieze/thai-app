import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const INPUT_CSV = path.join("supabase", "seed-data", "grammar_master.csv");
const OUTPUT_SQL = path.join(
  "supabase",
  "seed-data",
  "grammar_master.seed.sql",
);

const COLUMNS = [
  "concept_key",
  "cefr_level",
  "title",
  "short_explanation",
  "concept_type",
  "register",
  "source_note",
];

const ALLOWED_CONCEPT_TYPES = new Set([
  "sentence_pattern",
  "modifier_pattern",
  "question_pattern",
  "pronoun_system",
  "negation",
  "verb_pattern",
  "location_pattern",
  "tense_aspect",
  "functional_expression",
  "politeness",
  "particle",
  "classifier_pattern",
  "quantity",
  "comparison",
  "time_expression",
]);

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

async function main() {
  const raw = await readFile(INPUT_CSV, "utf8");
  const lines = raw
    .replace(/^\uFEFF/, "")
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
      concept_key,
      cefr_level,
      title,
      short_explanation,
      concept_type,
      register,
      source_note,
    ] = row;

    if (concept_type && !ALLOWED_CONCEPT_TYPES.has(concept_type)) {
      throw new Error(
        `Invalid concept_type in CSV row ${rowNumber}: ${concept_type}. Allowed values: ${Array.from(ALLOWED_CONCEPT_TYPES).join(", ")}`,
      );
    }

    const tuple = [
      toSqlText(concept_key),
      toSqlText(cefr_level),
      toSqlText(title),
      toSqlText(short_explanation),
      toSqlText(concept_type),
      toSqlText(register),
      toSqlText(source_note),
    ];

    valuesSql.push(`(${tuple.join(", ")})`);
  }

  const out = [
    `-- Auto-generated from ${INPUT_CSV}. Do not edit manually.`,
    "insert into public.grammar_master (concept_key, cefr_level, title, short_explanation, concept_type, register, source_note) values",
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
