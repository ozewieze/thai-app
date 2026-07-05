// ============================================================
// upload-slides.mjs
//
// Pikt lokaal gedownloade illustratie-afbeeldingen op (na
// handmatige generatie via ChatGPT), valideert ze, uploadt ze
// naar de Supabase Storage-bucket 'illustrations' en werkt
// dialog_slides.image_url bij.
//
// Automatiseert Stap 7-8 van
// docs/illustration-system/04_illustration_workflow_guide.md.
// De generatie zelf (Stap 5, ChatGPT of een andere generator)
// blijft volledig handmatig -- dit script roept geen enkele
// image-generation API aan.
//
// Verwachte staging-structuur (per dialoog):
//   illustration-staging/{lesson_key}/slide-{nn}.png
//
// Jij hernoemt het gedownloade bestand zelf naar slide-{nn}.png
// (zero-padded, overeenkomend met dialog_slides.slide_index)
// vóórdat je het in de staging-map zet. Dit is de ENIGE manier
// waarop het script weet welke afbeelding bij welke slide hoort
// -- er wordt nooit gegokt op bestandsvolgorde of downloaddatum,
// want geen van beide is een betrouwbare bron voor de bedoelde
// slide-index.
//
// Uitvoeren (alle dialogen met openstaande slides):
//   node --env-file=.env.local scripts/upload-slides.mjs
//
// Uitvoeren (één specifieke dialoog):
//   node --env-file=.env.local scripts/upload-slides.mjs --dialog a1-dialog-01
//
// Andere staging-map voor die ene dialoog:
//   node --env-file=.env.local scripts/upload-slides.mjs --dialog a1-dialog-01 --input-dir ~/Downloads/dialog-01-slides
//
// Ook slides met een bestaande image_url opnieuw verwerken (bv. om
// een afgekeurde illustratie te vervangen -- vereist --dialog):
//   node --env-file=.env.local scripts/upload-slides.mjs --dialog a1-dialog-01 --force
//
// Dry-run (geen uploads, geen DB-wijzigingen, toont alleen welk
// bestand aan welke slide gekoppeld zou worden):
//   node --env-file=.env.local scripts/upload-slides.mjs --dry-run
//
// Ruimt nooit zelf lokale bestanden op in de staging-map -- dat is
// een bewuste keuze (zie 04_illustration_workflow_guide.md, Stap 6b),
// niet een oversight. Jij bepaalt zelf wanneer je opruimt.
// ============================================================

import { createClient } from "@supabase/supabase-js";
import { readFileSync, readdirSync, statSync, existsSync } from "fs";
import { join } from "path";

// ── Configuratie ────────────────────────────────────────────

const DRY_RUN = process.argv.includes("--dry-run");
const FORCE = process.argv.includes("--force");
const dialogArg = (() => {
  const i = process.argv.indexOf("--dialog");
  return i !== -1 ? (process.argv[i + 1] ?? null) : null;
})();
const inputDirArg = (() => {
  const i = process.argv.indexOf("--input-dir");
  return i !== -1 ? (process.argv[i + 1] ?? null) : null;
})();

// Standaard staging-root; per dialoog wordt hieronder een submap
// verwacht met de lesson_key als naam, bv. illustration-staging/a1-dialog-01/
const DEFAULT_STAGING_ROOT = "illustration-staging";

// Zelfde limiet als de bucket-migratie
// (supabase/migrations/20260702120000_create_illustrations_storage_bucket.sql).
const MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024; // 10 MB

const MIME_TYPES = {
  png: "image/png",
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  webp: "image/webp",
};

// Verplicht patroon: 'slide-{nn}.{ext}', exact 2 cijfers, geen andere vorm
// wordt herkend.
const SLIDE_FILENAME_PATTERN = /^slide-(\d{2})\.(png|jpe?g|webp)$/i;

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

// ── Validatie ───────────────────────────────────────────────

if (!SUPABASE_URL) {
  console.error("FOUT: NEXT_PUBLIC_SUPABASE_URL ontbreekt in .env.local");
  process.exit(1);
}
if (!SUPABASE_SERVICE_ROLE_KEY) {
  console.error("FOUT: SUPABASE_SERVICE_ROLE_KEY ontbreekt in .env.local");
  process.exit(1);
}
if (FORCE && !dialogArg) {
  console.error("FOUT: --force vereist ook --dialog.");
  console.error("  Gebruik: --dialog a1-dialog-01 --force");
  process.exit(1);
}
if (inputDirArg && !dialogArg) {
  console.error("FOUT: --input-dir vereist ook --dialog.");
  console.error(
    "  Zonder --dialog verwerkt het script meerdere dialogen tegelijk, elk met",
  );
  console.error(
    "  hun eigen standaard staging-map -- één losse --input-dir zou dan",
  );
  console.error("  dubbelzinnig zijn.");
  process.exit(1);
}

// ── Supabase client (service role: schrijftoegang) ──────────

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// ── Helpers ─────────────────────────────────────────────────

/**
 * Bouw het Storage-pad binnen de 'illustrations' bucket.
 * 'a1-dialog-01', slideIndex 0 (de eerste slide, 0-based -- zelfde
 * conventie als block_index), ext 'png'
 *   → 'dialogs/a1/dialog-01/slides/slide-00.png'
 *
 * Zelfde split-logica (op de eerste '-') als buildStoragePath()
 * in generate-audio.mjs.
 */
function buildStoragePath(lessonKey, slideIndex, ext) {
  const dashIndex = lessonKey.indexOf("-");
  const level = lessonKey.slice(0, dashIndex); // 'a1'
  const dialogPart = lessonKey.slice(dashIndex + 1); // 'dialog-01'
  const slideNum = String(slideIndex).padStart(2, "0");
  return `dialogs/${level}/${dialogPart}/slides/slide-${slideNum}.${ext}`;
}

/**
 * Leid het slide-nummer en de extensie af uit een bestandsnaam.
 * Verwacht exact 'slide-{nn}.png' (of .jpg/.jpeg/.webp), ongeacht
 * hoofd-/kleine letters. Geeft null terug als de naam niet matcht --
 * zo'n bestand wordt genegeerd, nooit gegokt.
 */
function parseSlideFilename(fileName) {
  const match = fileName.match(SLIDE_FILENAME_PATTERN); //er zijn drie groepen: 0: hele match, 1: slide index, 2: extensie
  if (!match) return null;
  return {
    slideIndex: parseInt(match[1], 10), //geeft terug: 0, 1, 2, ... (integer)
    ext: match[2].toLowerCase(),
  };
}

/**
 * Scan een staging-map en splits de inhoud in bestanden die aan het
 * slide-{nn}-patroon voldoen en bestanden die genegeerd worden.
 */
function scanStagingDir(dir) {
  const entries = readdirSync(dir, { withFileTypes: true }).filter((e) =>
    e.isFile(),
  ); // geeft terug: Array van Dirent-objecten (Directory Entry objects uit Node.js) voor alle bestanden in de map bvb  Dirent { name: "slide-00.png", isFile() => true }, Dirent { name: "slide-01.png", isFile() => true }]

  const matched = [];
  const genegeerd = [];

  for (const entry of entries) {
    const parsed = parseSlideFilename(entry.name); //geeft terug: {slideIndex: 0, ext: 'png'} of null
    if (parsed) {
      matched.push({ fileName: entry.name, ...parsed }); //geeft dus terug: {fileName: 'slide-00.png', slideIndex: 0, ext: 'png'}
    } else {
      genegeerd.push(entry.name); //bvb 'test.png'
    }
  }

  return { matched, genegeerd };
}

/**
 * Controleer bestandsgrootte tegen de bucket-limiet (10 MB).
 * Gooit een fout i.p.v. false terug te geven, zodat de aanroeper
 * de fout direct in de catch kan loggen met een consistente stijl.
 */
function validateFileSize(filePath) {
  const { size } = statSync(filePath);
  if (size > MAX_FILE_SIZE_BYTES) {
    throw new Error(
      `bestand is ${(size / 1024 / 1024).toFixed(1)} MB, limiet is 10 MB`,
    );
  }
}

/**
 * Upload een lokaal bestand naar de 'illustrations' bucket.
 * Geeft de publieke URL terug.
 */
async function uploadToStorage(storagePath, filePath, contentType) {
  const fileBuffer = readFileSync(filePath);

  const { error } = await supabase.storage
    .from("illustrations")
    .upload(storagePath, fileBuffer, {
      contentType,
      upsert: true, // overschrijf als het bestand al bestaat (bv. bij --force)
    });

  if (error) throw new Error(`Storage upload fout: ${error.message}`);

  return `${SUPABASE_URL}/storage/v1/object/public/illustrations/${storagePath}`; //pad volgens de supabase storage url structuur
}

// ── Hoofdlogica ─────────────────────────────────────────────

//Voor elke dialoog:
//Stap 1: zoek openstaande slides in de database
//Stap 2 zoek lokale bestanden in illustration-staging/{lesson_key}
//Stap 3: accepteer alleen bestanden zoals slide-00.png
//Stap 4: koppel slide-00.png aan dialog_slides.slide_index = 0
//Stap5 upload bestand naar Supabase Storage
//Stap 6: schrijf publieke URL terug naar dialog_slides.image_url

async function uploadSlides() {
  if (DRY_RUN) console.log("DRY-RUN — geen uploads, geen DB-wijzigingen\n");

  // Als --dialog is opgegeven, zoek de bijbehorende lesson_id op.
  let lessonId = null;
  if (dialogArg) {
    const { data: lesson, error: lessonError } = await supabase
      .from("lessons")
      .select("id")
      .eq("lesson_key", dialogArg)
      .single();

    if (lessonError || !lesson) {
      console.error(`FOUT: Les '${dialogArg}' niet gevonden in de database.`);
      process.exit(1);
    }
    lessonId = lesson.id;
  }

  // Haal de doeldialogen op, inclusief hun slides en lesson_key.
  // We filteren "welke slides staan open" hierna in JS (niet in de
  // query zelf) omdat dialog_slides een 1-op-veel-relatie is en
  // Supabase's JS-client geen "heeft minstens één rij met image_url
  // is null"-filter op de hoofdtabel ondersteunt. Bij de huidige
  // schaal (enkele dialogen) is dat geen probleem.
  let query = supabase.from("dialogs").select(`
      id,
      lesson_id,
      lessons ( lesson_key ),
      dialog_slides ( id, slide_index, image_url )
    `);

  if (lessonId) {
    query = query.eq("lesson_id", lessonId);
  }

  const { data: dialogs, error } = await query;

  if (error) {
    console.error("FOUT: Kon dialogen niet ophalen:", error.message);
    process.exit(1);
  }

  if (!dialogs || dialogs.length === 0) {
    if (dialogArg) {
      console.log(`Geen dialoog gevonden voor '${dialogArg}'.`);
    } else {
      console.log("Geen dialogen gevonden.");
    }
    return;
  }

  console.log(`${dialogs.length} dialoog/dialogen te controleren.\n`);

  let geslaagd = 0;
  let overgeslagen = 0;
  let mislukt = 0;

  for (const dialog of dialogs) {
    const lessonKey = dialog.lessons.lesson_key;
    const label = `[${lessonKey}]`;

    //STAP 1: openstaande slides ophalen
    // Openstaande slides: standaard alleen die zonder image_url.
    // Met --force (en dus altijd in combinatie met --dialog, zie
    // validatie hierboven) tellen ook slides mét een bestaande
    // image_url mee, zodat je een afgekeurde illustratie kunt
    // vervangen.
    const openSlides = dialog.dialog_slides.filter(
      (s) => !s.image_url || FORCE,
    ); //geeft terug: [{id: 1, slide_index: 0, image_url: null}, {id: 2, slide_index: 1, image_url: null}, ...]

    if (openSlides.length === 0) {
      console.log(`${label} geen openstaande slides — overgeslagen.`);
      overgeslagen++;
      continue;
    }
    //sTAP 2: Bepaal de staging-map voor deze dialoog.
    const stagingDir =
      inputDirArg && dialogArg
        ? inputDirArg
        : join(DEFAULT_STAGING_ROOT, lessonKey); //geeft terug: 'illustration-staging/a1-dialog-01'

    if (!existsSync(stagingDir)) {
      console.log(
        `${label} staging-map niet gevonden (${stagingDir}) — overgeslagen.`,
      );
      overgeslagen++;
      continue;
    }
    //STAP 3: Scan de staging-map en splits in geldige en genegeerde bestanden.
    const { matched, genegeerd } = scanStagingDir(stagingDir); //geeft terug: {matched: [{fileName: 'slide-00.png', slideIndex: 0, ext: 'png'}, ...], genegeerd: ['test.png', ...]}

    if (genegeerd.length > 0) {
      console.log(
        `${label} genegeerd (voldoen niet aan slide-{nn}.png patroon): ${genegeerd.join(", ")}`,
      );
    }

    if (matched.length === 0) {
      console.log(
        `${label} geen geldige bestanden gevonden in ${stagingDir} — overgeslagen.`,
      );
      overgeslagen++;
      continue;
    }

    const openIndexen = new Set(openSlides.map((s) => s.slide_index)); //geeft terug: Set {0, 1, 2, ...} van de slide_indexen die openstaan

    // STAP 4: Koppel elk geldig lokaal bestand aan de bijbehorende slide-index.

    for (const file of matched) {
      const slideLabel = `${label} slide-${String(file.slideIndex).padStart(2, "0")}`;

      // Alleen uploaden als deze index ook echt openstaat in de
      // database -- dit is de expliciete koppeling tussen lokaal
      // bestand en DB-rij, geen giswerk op bestandsvolgorde.
      if (!openIndexen.has(file.slideIndex)) {
        console.log(
          `${slideLabel} — bestand gevonden (${file.fileName}) maar geen overeenkomende openstaande slide in de database. Overgeslagen.`,
        );
        overgeslagen++;
        continue;
      }

      const slideRow = openSlides.find(
        (s) => s.slide_index === file.slideIndex,
      ); //geeft bvb terug: {id: 1, slide_index: 0, image_url: null}
      const filePath = join(stagingDir, file.fileName);
      const contentType = MIME_TYPES[file.ext];
      const storagePath = buildStoragePath(
        lessonKey,
        file.slideIndex,
        file.ext,
      ); //geeft terug: 'dialogs/a1/dialog-01/slides/slide-00.png'

      try {
        validateFileSize(filePath);
      } catch (err) {
        console.log(`${slideLabel} MISLUKT — ${err.message}`);
        mislukt++;
        continue;
      }

      if (DRY_RUN) {
        console.log(
          `${slideLabel} — ${file.fileName} → illustrations/${storagePath} (dry-run, niet geüpload)`,
        );
        geslaagd++;
        continue;
      }
      //Stap5 upload bestand naar Supabase Storage

      try {
        process.stdout.write(`${slideLabel} uploaden...`);
        const publicUrl = await uploadToStorage(
          storagePath,
          filePath,
          contentType,
        );
        //Stap 6: schrijf publieke URL terug naar dialog_slides.image_url
        const { error: updateError } = await supabase
          .from("dialog_slides")
          .update({
            image_url: publicUrl,
            updated_at: new Date().toISOString(),
          })
          .eq("id", slideRow.id);

        if (updateError) {
          throw new Error(
            `dialog_slides update mislukt: ${updateError.message}`,
          );
        }

        console.log(" OK");
        geslaagd++;
      } catch (err) {
        console.log(" MISLUKT");
        console.error(`  ${err.message}`);
        mislukt++;
      }
    }
  }

  // ── Samenvatting ────────────────────────────────────────────
  console.log("\n------------------------------");
  console.log(`Geslaagd    : ${geslaagd}`);
  if (overgeslagen > 0) console.log(`Overgeslagen: ${overgeslagen}`);
  if (mislukt > 0) console.log(`Mislukt     : ${mislukt}`);
  console.log("------------------------------");

  if (!DRY_RUN && geslaagd > 0) {
    console.log(
      "\nLet op: lokale bestanden in de staging-map zijn NIET verwijderd.",
    );
    console.log(
      "Ruim ze zelf op zodra je klaar bent (zie 04_illustration_workflow_guide.md, Stap 6b).",
    );
  }
}

uploadSlides();
