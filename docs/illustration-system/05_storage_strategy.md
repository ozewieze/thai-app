# Opslagstrategie

Dit document legt vast **waarom** elk gegeven in het illustratiesysteem waar leeft: database, Markdown, of (later) JSON. Kernprincipe: *als het al in de database staat, blijft de database de bron van waarheid; als het nog niet bestaat, begint het als Markdown met een expliciet pad naar een toekomstige kolom.*

## Overzicht

| Gegeven | Opslag nu | Motivatie |
|---|---|---|
| Master Style, Locked Cast, Rules | Markdown (`01`, `02`, `03`) | Beleid/proza, geen record-per-record data. Verandert zelden, moet leesbaar en versiebeheerd zijn. |
| Scene Bible — locatie, scene-type, register | **Database** (`dialog_blueprint_specs`) | Bestaat al als bron van waarheid. Niet dupliceren — voorkomt dat twee bronnen uit sync raken. |
| Scene Bible — tijd, weer, palet, mood | Markdown (`scene-bibles/*.md`) | Bestaat nog niet als kolom. Klein volume bij 3 dialogen; een migratie nu is voorbarig. |
| Slide Specifications — index, blokbereik, image_url | **Database** (`dialog_slides`) | Bestaat al en is al bron van waarheid voor de slideshow-speler in de app. |
| Slide Specifications — illustratiebrief (moment, lichaamstaal, expressie) | Markdown (`slide-specs/*.md`) | Bestaat nog niet als kolom. Zie migratiepad hieronder. |
| Illustration Prompts (eindresultaat) | Markdown (`prompts/**/*.md`), wegwerpbaar | Eenmalige generatie-instructie, geen query- of join-behoefte. Zelfde patroon als `supabase/generation/dialogs/*.md`. |

## Waarom niet alles meteen in de database?

Drie dialogen rechtvaardigen geen schema-uitbreiding. Een migratie toevoegen voor een handvol rijen is voortijdige optimalisatie en een groter risico (schema-wijziging) voor weinig winst. De Markdown-aanpak kost bij deze schaal niets aan onderhoudbaarheid.

## Wanneer wél naar de database migreren

Zodra het aantal dialogen groeit (tientallen tot honderden, zoals de A1–C2-curriculumuitbreiding beoogt), wordt het voordeel van query-gebaseerde generatie groter dan het gemak van losse bestanden. Concreet migratiepad, **niet nu uitgevoerd, apart te bespreken**:

1. **`dialog_blueprint_specs.illustration_context jsonb`** — analoog aan de al bestaande `extra_constraints jsonb`-kolom op dezelfde tabel. Bevat `time_of_day`, `weather`, `environment_detail`, `mood`, `color_palette`.
2. **`dialog_slides.illustration_brief jsonb`** — bevat `dialogue_stage`, `narrative_moment`, `interaction`, `body_language`, `facial_expressions`, `conversation_energy`, `educational_focus`.
3. Een view (analoog aan `03_build_dialog_lesson_blueprint.sql`) die `dialogs` + `dialog_blocks` + `dialog_slides` + `dialog_blueprint_specs` + `character_profiles` + `relationship_pairs` samenvoegt tot exact de data die een Illustration Prompt nodig heeft.

Omdat de Markdown-templates in `templates/` bewust dezelfde veldnamen gebruiken als deze toekomstige JSON-structuur, is de migratie op dat moment een mechanische kopieerslag, geen herontwerp.

## Storage bucket voor afbeeldingen: `illustrations`

De bestaande `audio`-bucket (zie `supabase/migrations/20260626140000_create_audio_storage_bucket.sql`) staat alleen audio-mimetypes toe (`audio/mpeg`, `audio/mp4`, `audio/ogg`, `audio/wav`) — een afbeelding zou hier geweigerd worden bij upload, ondanks dat het commentaar bij de `dialog_slides`-migratie abusievelijk verwijst naar de `audio`-bucket voor `image_url`.

Besluit: een **nieuwe, aparte bucket `illustrations`** (zie `supabase/migrations/*_create_illustrations_storage_bucket.sql`), om twee redenen:

1. Audio en beeld hebben een eigen levenscyclus — audio wordt automatisch samengevoegd (`merge-audio.mjs`), beeld wordt per slide extern gegenereerd en handmatig gecureerd. Vermenging in één bucket maakt toekomstig beheer (bv. cache-regels, CDN-instellingen, opschoning) onnodig complex.
2. Expliciete `allowed_mime_types` per bucket (zoals het bestaande patroon al doet voor audio) voorkomt per ongeluk verkeerde bestandstypes.

## Wat blijft nooit in de database

De uiteindelijke Illustration Prompt-tekst wordt niet gestructureerd opgeslagen als database-rij. Dit is bewust: het is gegenereerde, samengestelde tekst zonder eigen betekenis los van het moment van generatie — vergelijkbaar met `supabase/generation/dialogs/a1_dialog_XX_output.md`, dat ook buiten de database blijft. Optioneel, laagprioriteit: een `dialog_slides.generated_prompt text`-kolom voor reproduceerbaarheid kan later worden toegevoegd, maar is geen vereiste.
