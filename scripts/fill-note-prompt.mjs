// ============================================================
// fill-note-prompt.mjs
//
// Vult een prompttemplate uit supabase/planning/ met de gegevens van
// één les en schrijft het resultaat naar supabase/prompts/.
//
// Drie stages, drie templates:
//   planner        07_language_note_planner_prompt_template.md
//   writer         08_language_note_writer_prompt_template.md
//   vocab-examples 09_vocabulary_example_prompt_template.md
//
// Uitvoeren:
//   node --env-file=.env.local scripts/fill-note-prompt.mjs --lesson a1-dialog-05 --stage planner
//   node --env-file=.env.local scripts/fill-note-prompt.mjs --lesson a1-dialog-05 --stage writer
//   node --env-file=.env.local scripts/fill-note-prompt.mjs --lesson a1-dialog-05 --stage vocab-examples
//
// Dry-run (toont wat er zou gebeuren, schrijft niets):
//   ... --stage planner --dry-run
//
// Overige vlaggen:
//   --plan <pad>       ander pad naar het goedgekeurde plan (alleen writer);
//                      standaard supabase/generation/language-notes/<les>_plan.md
//   --from-json <pad>  lees de view-rij uit een bestand in plaats van uit
//                      Supabase. Voor reproduceerbaar herhalen zonder
//                      database, en om dit script te testen.
//
// Waarom dit script bestaat. Het invullen is deterministisch -- brief-view
// uitlezen, lijsten renderen, substitueren -- maar het ging met de hand
// twee keer mis op dezelfde manier. Bij a1-dialog-01 stonden de twee
// guideline-waarden als lege bullets in de verstuurde prompt, en
// {{lesson_key}} en {{sequence_number}} waren op twee plaatsen blijven
// staan. Het model plande daarop drie notes van zes blokken terwijl er
// twee van vijf golden. Dit script faalt in beide gevallen luid.
//
// Wat het NIET doet: oordelen. Het plan en de JSON blijven mensenwerk met
// een reviewronde; daar zitten de fouten die dit script niet kan zien.
// ============================================================

import { createClient } from "@supabase/supabase-js";
import { readFile, writeFile, mkdir } from "node:fs/promises";
import path from "node:path";

// ── Stage-configuratie ──────────────────────────────────────

const STAGES = {
  planner: {
    template: "supabase/planning/07_language_note_planner_prompt_template.md",
    output: (l) => `supabase/prompts/language-notes/${l}_planner_prompt.md`,
    view: "language_note_brief_view",
  },
  writer: {
    template: "supabase/planning/08_language_note_writer_prompt_template.md",
    output: (l) => `supabase/prompts/language-notes/${l}_writer_prompt.md`,
    view: "language_note_brief_view",
  },
  "vocab-examples": {
    template: "supabase/planning/09_vocabulary_example_prompt_template.md",
    output: (l) => `supabase/prompts/vocabulary-examples/${l}_examples_prompt.md`,
    view: "vocabulary_example_brief_view",
  },
};

// Het promptgedeelte van een template loopt van "## Role" tot aan de
// mapping-checklist. Alles daarbuiten is invulinstructie voor de auteur en
// hoort niet in de verstuurde prompt. Zie de taalregel bovenaan elk
// template: Nederlands buiten, Engels erbinnen.
//
// De ankers zijn regel-gebonden, en dat is niet cosmetisch. Template 07
// noemt "## Role" ook midden in een Nederlandse zin ("alles tussen
// `## Role` en het einde van `## Output Rules`"). Een gewone indexOf
// vindt die eerst en snijdt twaalf regels invulinstructie mee de prompt
// in. Gemeten op 2026-08-11 bij de eerste testrun.
const PROMPT_START = /^## Role$/m;
const PROMPT_END = /^# Brief-view -> prompt mapping checklist$/m;

// Blokplafond per lesfase, uit "Hoeveel notes per les, en hoe lang?" in
// docs/thai_a1_language_note_workflow_guide.md. Het aantal notes staat
// niet in deze tabel: dat is 2-4 in elke fase en staat als vaste tekst in
// het template.
function maxBlocksPerNote(sequenceNumber) {
  if (sequenceNumber <= 10) return 5;
  if (sequenceNumber <= 30) return 6;
  return 7;
}

// ── Argumenten ──────────────────────────────────────────────

function parseArgs(argv) {
  const args = { dryRun: false };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === "--dry-run") args.dryRun = true;
    else if (a === "--lesson") args.lesson = argv[++i];
    else if (a === "--stage") args.stage = argv[++i];
    else if (a === "--plan") args.plan = argv[++i];
    else if (a === "--from-json") args.fromJson = argv[++i];
    else {
      console.error(`FOUT: onbekend argument "${a}".`);
      process.exit(1);
    }
  }
  return args;
}

const args = parseArgs(process.argv);

if (!args.lesson || !args.stage) {
  console.error(
    "Contractfout -- geef --lesson <lesson_key> en --stage <planner|writer|vocab-examples>.",
  );
  process.exit(1);
}

const stage = STAGES[args.stage];
if (!stage) {
  console.error(
    `FOUT: onbekende stage "${args.stage}". Kies uit: ${Object.keys(STAGES).join(", ")}.`,
  );
  process.exit(1);
}

// --from-json leest de view-rij uit een bestand in plaats van uit
// Supabase. Bedoeld om een vulling reproduceerbaar te herhalen zonder
// database, en om dit script te kunnen testen. Voor het echte werk laat je
// hem weg.
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!args.fromJson) {
  if (!SUPABASE_URL) {
    console.error("FOUT: NEXT_PUBLIC_SUPABASE_URL ontbreekt in .env.local");
    process.exit(1);
  }
  if (!SUPABASE_SERVICE_ROLE_KEY) {
    console.error("FOUT: SUPABASE_SERVICE_ROLE_KEY ontbreekt in .env.local");
    process.exit(1);
  }
}

const supabase = args.fromJson
  ? null
  : createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// ── Renderen van de conceptlijsten ──────────────────────────
//
// Elk masterobject heeft zijn eigen sleutelnaam en zijn eigen velden. De
// vorm hieronder is dezelfde als in de mapping-checklists van 07 en 08,
// zodat een prompt die met dit script gevuld is niet te onderscheiden is
// van een die met de hand gevuld werd.
//
// register wordt bewust weggelaten: dat veld draagt hier de betekenis
// *formaliteit*, terwijl de prompts speaker_gender gebruiken voor iets
// heel anders. Beide in een prompt zetten laat die twee botsen.

function byDisplayOrder(a, b) {
  const x = a.display_order ?? Number.MAX_SAFE_INTEGER;
  const y = b.display_order ?? Number.MAX_SAFE_INTEGER;
  return x - y;
}

function renderVocabulary(items) {
  return items
    .slice()
    .sort(byDisplayOrder)
    .map(
      (c) =>
        `- ${c.thai_script} (${c.paiboon}) = ${c.english_gloss}  [key: ${c.source_key}]`,
    )
    .join("\n");
}

function renderGrammar(items) {
  return items
    .slice()
    .sort(byDisplayOrder)
    .map((c) => `- ${c.title}: ${c.short_explanation}  [key: ${c.concept_key}]`)
    .join("\n");
}

function renderPhrases(items) {
  return items
    .slice()
    .sort(byDisplayOrder)
    .map(
      (c) =>
        `- ${c.title}: ${c.phrase_formula} — ${c.short_explanation}  [key: ${c.phrase_key}]`,
    )
    .join("\n");
}

function renderPatterns(items) {
  return items
    .slice()
    .sort(byDisplayOrder)
    .map(
      (c) =>
        `- ${c.title}: ${c.pattern_formula} — ${c.short_explanation}  [key: ${c.pattern_key}]`,
    )
    .join("\n");
}

// Een lege conceptlijst wordt "(geen)" en niet een weggelaten kop. Een
// ontbrekende kop leest als een vergissing, "(geen)" als een feit.
function orNone(rendered) {
  return rendered.trim() === "" ? "(geen)" : rendered;
}

function renderDialog(dialog) {
  const blocks = dialog?.blocks ?? [];
  return blocks
    .slice()
    .sort((a, b) => a.block_index - b.block_index)
    .map(
      (b) =>
        `${b.speaker_key}: ${b.thai_text} / ${b.transliteration} / ${b.translation_en}`,
    )
    .join("\n");
}

function renderBudget(words) {
  return words
    .slice()
    .sort((a, b) => {
      const x = a.intro_sequence_number ?? Number.MAX_SAFE_INTEGER;
      const y = b.intro_sequence_number ?? Number.MAX_SAFE_INTEGER;
      if (x !== y) return x - y;
      return String(a.source_key).localeCompare(String(b.source_key));
    })
    .map(
      (w) =>
        `- ${w.thai_script} (${w.paiboon}) = ${w.english_gloss}  [key: ${w.source_key}]`,
    )
    .join("\n");
}

function renderTargetWords(words) {
  return words
    .slice()
    .sort(byDisplayOrder)
    .map((w) => {
      const parts = [
        `- ${w.thai_script} (${w.paiboon}) = ${w.english_gloss}  [key: ${w.source_key}]`,
        w.part_of_speech,
      ];
      if (w.usage_note) parts.push(w.usage_note);
      return parts.join("  ·  ");
    })
    .join("\n");
}

// ── De les ophalen ──────────────────────────────────────────

async function fetchRow() {
  if (args.fromJson) {
    const raw = JSON.parse(await readFile(args.fromJson, "utf8"));
    if (raw.lesson_key !== args.lesson) {
      console.error(
        `FOUT: ${args.fromJson} bevat lesson_key "${raw.lesson_key}" ` +
          `maar --lesson zegt "${args.lesson}".`,
      );
      process.exit(1);
    }
    return raw;
  }

  const { data, error } = await supabase
    .from(stage.view)
    .select("*")
    .eq("lesson_key", args.lesson)
    .maybeSingle();

  if (error) {
    console.error(`FOUT bij het lezen van ${stage.view}: ${error.message}`);
    process.exit(1);
  }
  if (!data) {
    console.error(
      `FOUT: les "${args.lesson}" staat niet in ${stage.view}. ` +
        `Is de dialoog al geseed?`,
    );
    process.exit(1);
  }
  return data;
}

// ── Waarden per stage ───────────────────────────────────────

async function valuesForNoteStage(row) {
  const values = {
    lesson_key: row.lesson_key,
    sequence_number: String(row.sequence_number),
    vocabulary_to_explain: orNone(renderVocabulary(row.vocabulary_to_explain ?? [])),
    grammar_to_explain: orNone(renderGrammar(row.grammar_to_explain ?? [])),
    phrases_to_explain: orNone(renderPhrases(row.phrases_to_explain ?? [])),
    patterns_to_explain: orNone(renderPatterns(row.patterns_to_explain ?? [])),
    dialog_text: renderDialog(row.dialog),
  };

  if (args.stage === "planner") {
    values.max_blocks_per_note = String(maxBlocksPerNote(row.sequence_number));
  }

  if (args.stage === "writer") {
    values.example_vocabulary_budget = renderBudget(
      row.example_vocabulary_budget ?? [],
    );
    values.approved_note_plan = await readApprovedPlan();
  }

  return values;
}

// Het goedgekeurde plan is de versie mét jouw correcties, niet de ruwe
// modeloutput. Alleen het promptgedeelte gaat mee: de Nederlandse
// motivering onder "Redactionele beslissingen" is voor jou en heeft in een
// Engelse prompt niets te zoeken.
async function readApprovedPlan() {
  const planPath =
    args.plan ??
    `supabase/generation/language-notes/${args.lesson.replaceAll("-", "_")}_plan.md`;

  let raw;
  try {
    raw = await readFile(planPath, "utf8");
  } catch {
    console.error(
      `FOUT: goedgekeurd plan niet gevonden op ${planPath}.\n` +
        `      Draai eerst de planner-stage, keur het plan goed, en sla het\n` +
        `      daar op. Of geef een ander pad met --plan.`,
    );
    process.exit(1);
  }

  const start = raw.indexOf("### Note 1");
  if (start === -1) {
    console.error(
      `FOUT: ${planPath} bevat geen "### Note 1". Is dit wel een notenplan?`,
    );
    process.exit(1);
  }
  const cut = raw.indexOf("## Redactionele beslissingen");
  const body = (cut === -1 ? raw.slice(start) : raw.slice(start, cut)).trim();

  return `## Note plan for ${args.lesson}\n\n${body}`;
}

function valuesForVocabStage(row) {
  const targets = (row.target_words ?? []).filter((w) => w.needs_example);

  if (targets.length === 0) {
    console.error(
      `FOUT: geen enkel doelwoord van ${args.lesson} heeft needs_example = true.\n` +
        `      Er valt niets te genereren.`,
    );
    process.exit(1);
  }

  const budgets = row.example_vocabulary_budgets ?? [];
  if (budgets.length !== 1) {
    console.error(
      `FOUT: ${budgets.length} budgetblokken voor ${args.lesson}, verwacht 1.\n` +
        `      Zie "Het woordbudget" in template 09.`,
    );
    process.exit(1);
  }

  const words = budgets[0].words ?? [];
  const declared = Number(budgets[0].word_count);
  if (Number.isFinite(declared) && declared !== words.length) {
    console.error(
      `FOUT: het budgetblok meldt ${declared} woorden maar bevat er ${words.length}.`,
    );
    process.exit(1);
  }

  return {
    lesson_key: row.lesson_key,
    target_words: renderTargetWords(targets),
    example_vocabulary_budget: renderBudget(words),
  };
}

// ── Substitueren en controleren ─────────────────────────────

async function main() {
  const row = await fetchRow();

  const values =
    args.stage === "vocab-examples"
      ? valuesForVocabStage(row)
      : await valuesForNoteStage(row);

  const templateRaw = await readFile(stage.template, "utf8");
  const startMatch = templateRaw.match(PROMPT_START);
  const endMatch = templateRaw.match(PROMPT_END);
  if (!startMatch || !endMatch || endMatch.index < startMatch.index) {
    console.error(
      `FOUT: ${stage.template} mist een regel "## Role" of een regel\n` +
        `      "# Brief-view -> prompt mapping checklist".\n` +
        `      Zonder die twee ankers weet dit script niet welk deel de\n` +
        `      prompt is en welk deel invulinstructie.`,
    );
    process.exit(1);
  }

  let body = `${templateRaw.slice(startMatch.index, endMatch.index).trimEnd()}\n`;

  for (const [key, value] of Object.entries(values)) {
    body = body.replaceAll(`{{${key}}}`, value);
  }

  // De controle waar dit script voor bestaat. Een placeholder die
  // blijft staan, is een leeg veld dat er niet uitziet als een veld --
  // en dat is voor geen enkele controle vindbaar, ook niet voor die van
  // jezelf.
  const leftovers = [...new Set(body.match(/\{\{[a-z_]+\}\}/g) ?? [])];
  if (leftovers.length > 0) {
    console.error(
      `FOUT: niet ingevulde placeholders in ${stage.template}:\n` +
        leftovers.map((p) => `        ${p}`).join("\n") +
        `\n      Het template vraagt een waarde die dit script niet levert.\n` +
        `      Vul hem aan in fill-note-prompt.mjs of verwijder hem uit het\n` +
        `      template -- verstuur de prompt niet half.`,
    );
    process.exit(1);
  }

  const outPath = stage.output(args.lesson.replaceAll("-", "_"));

  if (args.dryRun) {
    console.log(`[dry-run] zou schrijven naar ${outPath}`);
    console.log(`[dry-run] ${body.split("\n").length} regels, geen placeholders over`);
    for (const [key, value] of Object.entries(values)) {
      const preview = value.split("\n")[0].slice(0, 60);
      const lines = value.split("\n").length;
      console.log(`[dry-run]   ${key}: ${lines} regel(s) — ${preview}`);
    }
    return;
  }

  await mkdir(path.dirname(outPath), { recursive: true });
  await writeFile(outPath, body, "utf8");

  console.log(`${outPath}: ${body.split("\n").length} regels, alle placeholders ingevuld.`);
}

main().catch((err) => {
  console.error(`FOUT: ${err.message}`);
  process.exit(1);
});
