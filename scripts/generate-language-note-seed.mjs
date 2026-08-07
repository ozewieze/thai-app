// Zet een goedgekeurd Language Note-bestand (JSON) om naar een idempotent
// seedbestand (SQL). Het script doet uitsluitend mechanisch werk: sleutels
// opzoeken via subquery's, volgorde afleiden, tekst escapen. Het beoordeelt
// geen inhoud en verandert geen letter Thais of Paiboon.
//
// Gebruik:
//   node scripts/generate-language-note-seed.mjs --lesson a1-dialog-03
//   node scripts/generate-language-note-seed.mjs --in <pad.json> --out <pad.sql>
//
// Met --lesson gelden de conventiepaden:
//   in  = supabase/generation/language-notes/<lesson_key>_notes.json
//   out = supabase/seed-data/language-notes/<lesson_key>_notes.seed.sql
//
// Ontwerpbeslissingen die de validatie hieronder verklaren:
//
// 1. display_order staat NIET in de JSON. De volgorde van de array is de
//    volgorde op het scherm. Dat haalt een hele klasse overschrijffouten weg:
//    je kunt geen nummering hebben die niet klopt met de leesvolgorde.
//
// 2. De sleutels staan er WEL in, en zijn verplicht. Ze zijn de identiteit van
//    een rij en mogen nooit meebewegen met de volgorde. Verplaats je een blok,
//    dan verplaats je het object en houd je zijn block_key. Zou het script de
//    sleutels zelf uit de positie afleiden, dan zou herordenen de identiteit
//    veranderen en zou de upsert een nieuwe rij invoegen in plaats van de
//    bestaande te verplaatsen -- precies wat de sleutels moeten voorkomen.
//
// 3. Concepten worden geïdentificeerd met de MASTERsleutel (source_key,
//    concept_key, phrase_key, pattern_key), nooit met een koppelrij-id.
//    Koppelrij-ids zijn identity-waarden die na een `db reset` kunnen
//    verschuiven; een id in een seedbestand is een tijdbom.
//    language_note_brief_view geeft die id wel mee, maar als controlemiddel.
//
// 4. Onbekende velden zijn een fout, geen ruis om te negeren. Een prompt die
//    afdrijft levert extra of hernoemde velden op, en dat wil je horen op het
//    moment dat het gebeurt.
//
// 5. `[uncertain]` ergens in de JSON is een harde fout. De schrijverprompt
//    markeert daarmee een Paiboon-vorm die niet uit de meegeleverde lijst kwam.
//    Zo'n markering hoort door een mens beslecht te worden; belandt ze in de
//    database, dan ziet niemand haar ooit nog.

import { readFile, writeFile, mkdir } from "node:fs/promises";
import path from "node:path";

const BLOCK_TYPES = [
  "paragraph",
  "subheading",
  "formula",
  "example_group",
  "usage_tip",
];

// Bloktypes die tekst dragen en géén kop mogen hebben. Dit spiegelt
// language_note_blocks_content_shape_check uit 20260721120000. Let op de
// contra-intuïtie: de tekst van een subheading hoort in `content`, niet in
// `heading` -- dat laatste veld is uitsluitend voor example_group.
const TEXT_BLOCK_TYPES = ["paragraph", "subheading", "formula", "usage_tip"];

const CONCEPT_ARMS = {
  vocabulary: {
    column: "lesson_vocabulary_id",
    linkTable: "lesson_vocabulary",
    linkColumn: "vocabulary_id",
    masterTable: "vocabulary_master",
    masterKey: "source_key",
  },
  grammar: {
    column: "lesson_grammar_id",
    linkTable: "lesson_grammar",
    linkColumn: "grammar_id",
    masterTable: "grammar_master",
    masterKey: "concept_key",
  },
  phrase: {
    column: "lesson_phrase_id",
    linkTable: "lesson_phrase",
    linkColumn: "phrase_id",
    masterTable: "phrase_master",
    masterKey: "phrase_key",
  },
  pattern: {
    column: "lesson_pattern_id",
    linkTable: "lesson_pattern",
    linkColumn: "pattern_id",
    masterTable: "pattern_master",
    masterKey: "pattern_key",
  },
};

const KEY_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const UNCERTAIN_MARKER = "[uncertain]";

class ContractError extends Error {}// Een fout die de gebruiker van het script kan voorkomen door de input te corrigeren.

function fail(where, message) {
  throw new ContractError(`${where}: ${message}`);
}

function requireExactKeys(object, allowed, where) {
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

function requireKey(object, field, where) {
  const value = requireText(object, field, where);
  if (!KEY_PATTERN.test(value)) {
    fail(
      where,
      `"${field}" = "${value}" past niet op ${KEY_PATTERN}. ` +
        `Sleutels zijn kleine letters, cijfers en koppeltekens.`,
    );
  }
  return value;
}

function optionalText(object, field, where) {
  if (!(field in object) || object[field] === null) return null;
  const value = object[field];
  if (typeof value !== "string" || value.trim() === "") {
    fail(
      where,
      `"${field}" mag weggelaten of null zijn, maar niet leeg. ` +
        `Een lege string en "geen waarde" zijn niet hetzelfde.`,
    );
  }
  return value;
}

// recursief door de boom lopen, want de markering kan overal zitten, ook in velden die dit script verder niet gebruikt. Een markering die in een titel of een vertaling belandt is even schadelijk als een in de Paiboon.
// een recursieve functie is een elegante manier om door een JSON-structuur te lopen, ongeacht hoe diep genest. We houden een "trail" bij om te kunnen melden waar de markering zit.
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

function assertUnique(values, where, what) {
  const seen = new Set();//een set mag geen dubbele waarden bevatten, dus die gebruiken we om te controleren of er dubbele sleutels zijn
  for (const value of values) {
    if (seen.has(value)) {
      fail(where, `${what} "${value}" komt twee keer voor.`);
    }
    seen.add(value);
  }
}

// ---------------------------------------------------------------
// Validatie van het volledige document
// ---------------------------------------------------------------

function validate(doc) {
  if (!doc || typeof doc !== "object" || Array.isArray(doc)) {
    fail("$", "het document moet een object zijn.");
  }
  requireExactKeys(doc, ["lesson_key", "notes"], "$");
  const lessonKey = requireKey(doc, "lesson_key", "$");

  if (!Array.isArray(doc.notes) || doc.notes.length === 0) {
    fail("$.notes", "moet een niet-lege array zijn.");
  }
  assertUnique(
    doc.notes.map((n) => n?.note_key),
    "$.notes",
    "note_key",
  );

  doc.notes.forEach((note, ni) => {
    const nWhere = `$.notes[${ni}]`;
    if (!note || typeof note !== "object" || Array.isArray(note)) {
      fail(nWhere, "moet een object zijn.");
    }
    requireExactKeys(note, ["note_key", "title", "blocks", "concepts"], nWhere);
    requireKey(note, "note_key", nWhere);
    requireText(note, "title", nWhere);

    if (!Array.isArray(note.blocks) || note.blocks.length === 0) {
      fail(
        `${nWhere}.blocks`,
        "moet een niet-lege array zijn. Een note zonder blokken is leeg en " +
          "wordt door de publicatievalidatie afgekeurd (Stap 9).",
      );
    }
    assertUnique(
      note.blocks.map((b) => b?.block_key),
      `${nWhere}.blocks`,
      "block_key",
    );

    note.blocks.forEach((block, bi) => {
      const bWhere = `${nWhere}.blocks[${bi}]`;
      if (!block || typeof block !== "object" || Array.isArray(block)) {
        fail(bWhere, "moet een object zijn.");
      }
      requireKey(block, "block_key", bWhere);

      const blockType = requireText(block, "block_type", bWhere);
      if (!BLOCK_TYPES.includes(blockType)) {
        fail(
          bWhere,
          `block_type "${blockType}" bestaat niet. Toegestaan: ${BLOCK_TYPES.join(", ")}.`,
        );
      }

      if (TEXT_BLOCK_TYPES.includes(blockType)) {
        requireExactKeys(block, ["block_key", "block_type", "content"], bWhere);
        requireText(block, "content", bWhere);
      } else {
        requireExactKeys(
          block,
          ["block_key", "block_type", "heading", "content", "examples"],
          bWhere,
        );
        optionalText(block, "heading", bWhere);
        optionalText(block, "content", bWhere);

        if (!Array.isArray(block.examples) || block.examples.length === 0) {
          fail(
            `${bWhere}.examples`,
            "een example_group zonder voorbeelden is leeg. Het schema staat " +
              "dat toe tijdens het schrijven, maar een goedgekeurde note " +
              "hoort er geen te bevatten (Stap 9, punt 4).",
          );
        }
        assertUnique(
          block.examples.map((e) => e?.example_key),
          `${bWhere}.examples`,
          "example_key",
        );

        block.examples.forEach((example, ei) => {
          const eWhere = `${bWhere}.examples[${ei}]`;
          if (!example || typeof example !== "object" || Array.isArray(example)) {
            fail(eWhere, "moet een object zijn.");
          }
          requireExactKeys(
            example,
            ["example_key", "thai_script", "paiboon", "translation_en"],
            eWhere,
          );
          requireKey(example, "example_key", eWhere);
          requireText(example, "thai_script", eWhere);
          requireText(example, "paiboon", eWhere);
          requireText(example, "translation_en", eWhere);
        });
      }
    });

    if (!Array.isArray(note.concepts)) {
      fail(
        `${nWhere}.concepts`,
        "moet een array zijn (mag leeg zijn, maar dan behandelt de note " +
          "niets en telt ze niet mee in de publicatievalidatie).",
      );
    }
    assertUnique(
      note.concepts.map((c) => `${c?.type}:${c?.key}`),
      `${nWhere}.concepts`,
      "concept",
    );
    note.concepts.forEach((concept, ci) => {
      const cWhere = `${nWhere}.concepts[${ci}]`;
      if (!concept || typeof concept !== "object" || Array.isArray(concept)) {
        fail(cWhere, "moet een object zijn.");
      }
      requireExactKeys(concept, ["type", "key"], cWhere);
      const type = requireText(concept, "type", cWhere);
      if (!(type in CONCEPT_ARMS)) {
        fail(
          cWhere,
          `type "${type}" bestaat niet. Toegestaan: ${Object.keys(CONCEPT_ARMS).join(", ")}.`,
        );
      }
      requireText(concept, "key", cWhere);
    });
  });

  return lessonKey;
}

// ---------------------------------------------------------------
// SQL-opbouw
// ---------------------------------------------------------------

function toSqlText(value) {
  if (value == null) return "null";
  return `'${value.replaceAll("'", "''")}'`;
}

function lessonSubquery(lessonKey) {
  return `(select id from public.lessons where lesson_key = ${toSqlText(lessonKey)})`;
}

function buildNotesInsert(doc) {
  const rows = doc.notes.map(
    (note, index) =>
      `  (\n` +
      `    ${lessonSubquery(doc.lesson_key)},\n` +
      `    ${toSqlText(note.note_key)},\n` +
      `    ${toSqlText(note.title)},\n` +
      `    ${index + 1}\n` +
      `  )`,
  );

  return [
    "insert into public.language_notes (lesson_id, note_key, title, display_order)",
    "values",
    rows.join(",\n"),
    "on conflict (note_key) do update set",
    "  lesson_id     = excluded.lesson_id,",
    "  title         = excluded.title,",
    "  display_order = excluded.display_order;",
  ].join("\n");
}

function buildBlocksInsert(note) {
  const rows = note.blocks.map((block, index) => {
    const isText = TEXT_BLOCK_TYPES.includes(block.block_type);
    const heading = isText ? null : (block.heading ?? null);
    const content = isText ? block.content : (block.content ?? null);
    // De ::text-casts op de eerste rij zijn nodig: een kolom die in élke rij
    // null is, houdt anders type `unknown` en dan weigert de insert.
    //anders gezegd: null heeft geen duideljk datatype, en de database kan niet afleiden wat het moet zijn. De eerste rij geeft het type aan, de rest mag null zijn.
    const cast = index === 0 ? "::text" : "";
    return (
      `  (${toSqlText(block.block_key)}, ${index + 1}, ` +
      `${toSqlText(block.block_type)}, ` +
      `${toSqlText(heading)}${heading === null ? cast : ""}, ` +
      `${toSqlText(content)}${content === null ? cast : ""})`
    );
  });

  return [
    "with note as (",// een CTE om de note_id op te halen, zodat we die niet in elke rij hoeven te herhalen
    `  select id from public.language_notes where note_key = ${toSqlText(note.note_key)}`,
    ")",
    "insert into public.language_note_blocks",
    "  (language_note_id, block_key, display_order, block_type, heading, content)",
    "select note.id, b.block_key, b.display_order, b.block_type, b.heading, b.content",
    "from note",
    "cross join (values",
    rows.join(",\n"),
    ") as b(block_key, display_order, block_type, heading, content)",
    "on conflict (language_note_id, block_key) do update set",
    "  display_order = excluded.display_order,",
    "  block_type    = excluded.block_type,",
    "  heading       = excluded.heading,",
    "  content       = excluded.content;",
  ].join("\n");
}

function buildExamplesInsert(note) {
  const rows = [];
  for (const block of note.blocks) {
    if (block.block_type !== "example_group") continue;
    block.examples.forEach((example, index) => {
      rows.push(
        `  (${toSqlText(block.block_key)}, ${toSqlText(example.example_key)}, ${index + 1}, ` +
          `${toSqlText(example.thai_script)}, ${toSqlText(example.paiboon)}, ` +
          `${toSqlText(example.translation_en)})`,
      );
    });
  }
  if (rows.length === 0) return null;

  return [
    "with blocks as (",
    "  select blk.id, blk.block_key",
    "  from public.language_note_blocks blk",
    "  join public.language_notes n on n.id = blk.language_note_id",
    `  where n.note_key = ${toSqlText(note.note_key)}`,
    ")",
    "insert into public.language_note_examples",
    "  (block_id, example_key, display_order, thai_script, paiboon, translation_en)",
    "select blocks.id, e.example_key, e.display_order, e.thai_script, e.paiboon, e.translation_en",
    "from (values",
    rows.join(",\n"),
    ") as e(block_key, example_key, display_order, thai_script, paiboon, translation_en)",
    "join blocks on blocks.block_key = e.block_key",
    "on conflict (block_id, example_key) do update set",
    "  display_order  = excluded.display_order,",
    "  thai_script    = excluded.thai_script,",
    "  paiboon        = excluded.paiboon,",
    "  translation_en = excluded.translation_en;",
  ].join("\n");
}

function buildConceptInsert(lessonKey, note, concept) {
  const arm = CONCEPT_ARMS[concept.type];
  const lesson = lessonSubquery(lessonKey);

  return [
    `-- ${concept.type}: ${concept.key}`,
    "insert into public.language_note_concepts",
    `  (language_note_id, lesson_id, ${arm.column})`,//bvb lesson_vocabulary_id
    "values (",
    `  (select id from public.language_notes where note_key = ${toSqlText(note.note_key)}),`,
    `  ${lesson},`,
    "  (select link.id",
    `     from public.${arm.linkTable} link`,//bvb lesson_vocabulary
    `    where link.lesson_id = ${lesson}`,
    `      and link.${arm.linkColumn} = (select id from public.${arm.masterTable} where ${arm.masterKey} = ${toSqlText(concept.key)}))`,
    ")",
    `on conflict (${arm.column}, language_note_id)`,
    `  where ${arm.column} is not null`,
    "do nothing;",
  ].join("\n");
}

function buildSql(doc, inputPath) {
  const parts = [];

  parts.push(
    [
      `-- Automatisch gegenereerd uit ${inputPath.replaceAll("\\", "/")}.`,
      "-- Niet met de hand bewerken: draai scripts/generate-language-note-seed.mjs opnieuw.",
      "--",
      "-- Het bestand is idempotent. Opnieuw draaien is de manier om een correctie",
      "-- door te voeren -- voor toevoegen en wijzigen. Verwijderen niet: haal je een",
      "-- note, blok, voorbeeld of claim uit de JSON, dan blijft de rij in de database",
      "-- staan. Dat is een aparte, expliciete handeling.",
      "--",
      "-- Herorden je blokken of notes, draai dit bestand dan binnen een transactie met",
      "--   set constraints all deferred;",
      "-- De tussenstand van een herordening botst anders op de display_order-",
      "-- constraints; precies daarvoor zijn die deferrable aangemaakt.",
      "",
      "begin;",
      "",
    ].join("\n"),
  );

  parts.push("-- 1. De notes van deze les");
  parts.push(buildNotesInsert(doc));

  doc.notes.forEach((note, index) => {
    parts.push(`-- ${index + 2}. Note ${toSqlText(note.note_key)}`);
    parts.push(buildBlocksInsert(note));

    const examples = buildExamplesInsert(note);
    if (examples) parts.push(examples);

    for (const concept of note.concepts) {
      parts.push(buildConceptInsert(doc.lesson_key, note, concept));
    }
  });

  parts.push("commit;");
  return parts.join("\n\n") + "\n";
}

// ---------------------------------------------------------------

function parseArgs(argv) {//bvb ["--lesson", "a1-dialog-03"] of ["--in", "supabase/generation/language-notes/a1_dialog_03_notes.json", "--out", "supabase/seed-data/language-notes/a1_dialog_03_notes.seed.sql"]
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) continue;
    const name = token.slice(2);//slice haalt de eerste 2 karakters weg, dus "--lesson" wordt "lesson" of "--in" wordt "in"
    const value = argv[i + 1];
    if (value === undefined || value.startsWith("--")) {
      throw new ContractError(`Optie --${name} verwacht een waarde.`);
    }
    args[name] = value;
    i += 1;
  }
  return args;//bvb { lesson: "a1-dialog-03" } of { in: "supabase/generation/language-notes/a1_dialog_03_notes.json", out: "supabase/seed-data/language-notes/a1_dialog_03_notes.seed.sql" }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));//bvb vanuit node scripts/generate-language-note-seed.mjs --lesson a1-dialog-03
  // want process.arg is ongeveer ["node", "scripts/generate-language-note-seed.mjs", "--lesson", "a1-dialog-03"]

  let inputPath = args.in;
  let outputPath = args.out;

  if (args.lesson) {
    const stem = args.lesson.replaceAll("-", "_");
    inputPath ??= path.join(
      "supabase",
      "generation",
      "language-notes",
      `${stem}_notes.json`,
    );
    outputPath ??= path.join(
      "supabase",
      "seed-data",
      "language-notes",
      `${stem}_notes.seed.sql`,
    );
  }

  if (!inputPath || !outputPath) {
    throw new ContractError(
      "Geef --lesson <lesson_key>, of --in <pad.json> en --out <pad.sql>.",
    );
  }

  let doc;
  try {
    doc = JSON.parse(await readFile(inputPath, "utf8"));
  } catch (error) {
    throw new ContractError(`${inputPath} kon niet gelezen worden: ${error.message}`);
  }

  assertNoUncertainMarkers(doc);
  const lessonKey = validate(doc);

  if (args.lesson && args.lesson !== lessonKey) {
    throw new ContractError(
      `--lesson is "${args.lesson}" maar het bestand zegt lesson_key "${lessonKey}".`,
    );
  }

  const sql = buildSql(doc, inputPath);

  await mkdir(path.dirname(outputPath), { recursive: true });//recursive:true maakt de hele padstructuur aan als die nog niet bestaat, zodat writeFile niet faalt
  await writeFile(outputPath, sql, "utf8");//schrijf de ganse SQL string naar het outputbestand

  const blocks = doc.notes.reduce((sum, n) => sum + n.blocks.length, 0);
  const examples = doc.notes.reduce(
    (sum, n) =>
      sum +
      n.blocks.reduce((s, b) => s + (b.examples ? b.examples.length : 0), 0),
    0,
  );
  const concepts = doc.notes.reduce((sum, n) => sum + n.concepts.length, 0);

  console.log(
    `${outputPath}: ${doc.notes.length} notes, ${blocks} blokken, ` +
      `${examples} voorbeelden, ${concepts} conceptclaims.`,
  );
}

main().catch((error) => {
  if (error instanceof ContractError) {
    console.error(`Contractfout -- ${error.message}`);
  } else {
    console.error(error);
  }
  process.exit(1);//exit met een foutcode zodat een CI-pipeline of script kan detecteren dat er iets misging bvb 0 = success, 1 = error
});
