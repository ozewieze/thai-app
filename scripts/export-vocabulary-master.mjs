import { createClient } from "@supabase/supabase-js";
import { writeFile } from "node:fs/promises";
import path from "node:path";

const OUTPUT_CSV = path.join(
  "supabase",
  "seed-data",
  "master",
  "csv",
  "vocabulary_master.csv",
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

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL) {
  console.error("FOUT: NEXT_PUBLIC_SUPABASE_URL ontbreekt in .env.local");
  process.exit(1);
}
if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error("FOUT: SUPABASE_SERVICE_ROLE_KEY ontbreekt in .env.local");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

function toCsvField(value) {
  if (value == null) return "";
  const str = String(value);
  if (/[",\n]/.test(str)) {
    return `"${str.replaceAll('"', '""')}"`;
  }
  return str;
}

async function main() {
  const { data, error } = await supabase
    .from("vocabulary_master")
    .select(COLUMNS.join(","))
    .order("id", { ascending: true });//data is an array of objects, each object representing a row from the vocabulary_master table, with keys corresponding to the columns specified in COLUMNS.

  if (error) {
    throw new Error(`Supabase query failed: ${error.message}`);
  }

  const lines = [COLUMNS.join(",")];

  for (const row of data) {
    lines.push(COLUMNS.map((col) => toCsvField(row[col])).join(","));
  }// voor elke rij wordt in de lines array een array gepusht met de waarden van de kolommen, gescheiden door komma's. De eerste regel van de CSV bevat de kolomnamen, en elke volgende regel bevat de waarden van een rij uit de database.

  await writeFile(OUTPUT_CSV, `${lines.join("\n")}\n`, "utf8");
  console.log(`Exported ${OUTPUT_CSV} with ${data.length} rows.`);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
