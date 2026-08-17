# Prompt voor nieuwe taak: witte/schok-flits bij slidewissel opnieuw onderzoeken

Plak dit bestand (of de inhoud) als openingsbericht in een nieuwe taak/sessie.

## Context

`DialogFullSection.tsx` (+ `DialogFullSection.module.css`) toont de
slideshow-afbeelding boven de full-dialog audioplayer op de lesson-pagina.
Bij elke slidewissel (audio-tijdstip bereikt `startMs` van de volgende
slide) wisselt de getoonde afbeelding. Dit moet **instant en zonder
visueel artefact** gebeuren.

Relevante bestanden:
- `src/features/lesson/components/dialog-full-section/DialogFullSection.tsx`
- `src/features/lesson/components/dialog-full-section/DialogFullSection.module.css`
- `scripts/upload-slides.mjs` (uploadt lokale bestanden uit
  `illustration-staging/` naar Supabase Storage bucket `illustrations` en
  zet `dialog_slides.image_url`)
- `docs/illustration-system/templates/illustration-prompt.template.md`
  (bron van de illustraties — genereert 1536x1024 / 3:2 PNG's via ChatGPT)

## Probleemgeschiedenis (samengevat, chronologisch)

1. **Crossfade/dissolve** (overlappende lagen of fade-out→fade-in): gaf
   telkens een eigen artefact — witte flits door GPU-layer-promotion-timing,
   "ghosting" door het blenden van twee personage-poses, of een kaal moment
   tussen fade-out en fade-in. Bij snel opeenvolgende dialoogregels was er
   te weinig tijd om dit onopvallend te maken. **Verworpen.**
2. **Ken Burns-animatie toegevoegd** (losstaand probleem, wel behouden):
   subtiele `scale(1.00 → 1.02)` over de volledige zichtduur van een slide,
   getriggerd via een verse DOM-mount (`key`-prop) met CSS `@keyframes` —
   nooit via een `transition` + class-toggle op een hergebruikt element,
   want dat patroon bleek in dit project herhaaldelijk onbetrouwbaar (geen
   animatie-start-timing garantie).
3. **Statisch vóór de eerste play**: `hasStartedPlaying`-state zorgt dat de
   zoom pas ingaat na de eerste keer play (niet al tijdens page load).
   Belangrijk geleerde les: `animation-play-state` dynamisch toggelen via
   inline style op een bestaand element reproduceerde dezelfde witte-flits-
   bug als de crossfade-experimenten (waarschijnlijk opnieuw
   layer-promotion-timing). Opgelost via dezelfde key-mount-aanpak i.p.v.
   een toggle.
4. **Root cause van de resterende flits geïdentificeerd**: elke
   slide-afbeelding is een apart bestand; de browser moet 'm bij de EERSTE
   weergave nog decoderen en schalen naar de weergavegrootte
   (`object-fit: cover`). Die decode+schaal-operatie gebeurt bij een
   instante key-mount-wissel precies op het wisselmoment zelf als de
   afbeelding nog niet eerder op die grootte getoond is — dat gaf het witte
   "gat". Dit is **puur een browser-rendertimingkwestie**, los van de
   animatie/GPU-layers, en treft in principe elke eerste-keer-kijker bij
   elke slidewissel (niet alleen bij handmatig venster-resizen in devtools
   — dat was slechts een makkelijke manier om het te reproduceren).
   Belangrijke kanttekening: de gedecodeerde/geschaalde bitmap-cache
   overleeft geen page reload (enkel de ruwe HTTP-bytes kunnen warm
   blijven) — elke nieuwe paginalading is dus sowieso een "koude decode"
   voor elke slide-afbeelding.
5. **`next/image`-experiment**: geprobeerd voor kleinere, per-breakpoint
   al geschaalde bestanden (kortere decodetijd). Liep vast op een
   hardnekkige "url parameter is not allowed"-fout via de
   `/_next/image`-optimizer bij een lokale Supabase-instantie
   (`http://127.0.0.1:<poort>`) onder Turbopack — ook na aantoonbaar
   correcte `next.config.ts`-configuratie (protocol/hostname/poort) en een
   volledige `.next`-cache-clear. Niet verder uitgezocht; **teruggedraaid**
   naar gewone `<img>`-elementen.
6. **Z-index-occlusion-oplossing (huidige architectuur, tot voor kort
   succesvol)**: alle resterende slides van de dialoog worden vooraf
   gerenderd als volledig ondoorzichtige, maar visueel afgedekte
   `<img>`-elementen:
   - `.slideImage` (actieve slide): `position: absolute; inset: 0; z-index: 2;`
   - `.preloadImage` (alle overige/komende slides): zelfde
     `position: absolute; inset: 0;`, maar `z-index: 1`, **geen**
     `opacity: 0`.
   - Rationale: een volledig ondoorzichtig maar afgedekt element geeft de
     browser geen enkele aanwijzing dat het "onbelangrijk" is, dus wordt
     het gegarandeerd normaal/volledig gerasterizeerd — betrouwbaarder dan
     `opacity: 0`, waarbij niet zeker is of elke browser-implementatie het
     element altijd volledig rasterizeert.
   - Bij een slidewissel verdwijnt de bovenste laag en komt de al
     klaarstaande laag eronder instant tevoorschijn.
   - Prioriteit: alleen de eerstvolgende `PRIORITY_LOOKAHEAD` (= 2) slides
     krijgen `fetchPriority="high"`; de rest krijgt `loading="eager"` met
     normale prioriteit (voorkomt dat bandbreedte-concurrentie bij lange
     dialogen juist de eerstvolgende afbeeldingen vertraagt).
   - Randgeval last→first slide (herstart van de dialoog) apart afgevangen:
     `slides.slice(activeSlideIndex + 1)` geeft een lege array op de
     laatste slide, dus slide 0 wordt daar expliciet aan `preloadSlides`
     toegevoegd.
   - **Resultaat destijds**: gebruiker bevestigde dat dit de flits voor
     vrijwel alle overgangen oploste ("het is gelukt... resultaat nu voor
     de volgende slides perfect"), op een incidentele flits tussen twee
     specifieke slides na (vermoedelijk trage lading).

## Nieuw probleem (aanleiding voor deze taak)

Na het overschrijven van de illustraties in de database (nieuwe
PNG-bestanden, ongeveer **2.4 MB per stuk**) is de flits **terug**, en nu
in een andere vorm dan voorheen: een korte "schok" waarbij **gedeeltelijk
de vorige slide en gedeeltelijk de volgende slide tegelijk zichtbaar zijn**,
in plaats van een wit gat.

Vermoeden van de gebruiker: bestandsgrootte (~2.4 MB) is mogelijk te groot,
waardoor download+decode niet meer binnen de beschikbare voorlaadtijd past.

## Te onderzoeken richtingen

1. **Bestandsgrootte/dimensies vergelijken**: hoe groot/wat voor dimensies
   hadden de vorige (werkende) illustraties versus de nieuwe 2.4 MB-bestanden?
   Zijn de nieuwe bestanden ongecomprimeerd/onnodig groot (bv. geen
   PNG-optimalisatie, hogere resolutie dan de 1536x1024 uit het
   prompt-template, of een ander kleurprofiel/bitdepth)?
2. **Voorlaadtijd vs. bestandsgrootte**: de voorsprong die een slide krijgt
   om te preloaden is de cumulatieve zichtduur van de slide(s) ervoor
   (zie `PRIORITY_LOOKAHEAD` en de preload-logica in
   `DialogFullSection.tsx`). Bij ~2.4 MB per afbeelding en een matige
   verbinding kan download+decode die voorsprong nu overschrijden — dit was
   in de code al als theoretisch restrisico gedocumenteerd
   ("bij erg korte dialoogregels en een koud netwerk kan dat nog steeds te
   weinig tijd zijn"), maar lijkt nu structureel op te treden i.p.v.
   incidenteel.
3. **"Schok" i.p.v. wit gat — betekent dit iets anders dan voorheen?** Een
   gedeeltelijk zichtbare oude + nieuwe slide tegelijk wijst mogelijk op een
   ander soort renderprobleem dan de eerdere "koude decode geeft wit gat"
   (bv. progressive/interlaced PNG-decodering die decode-voortgang
   tussentijds toont, of een layout-shift doordat de nieuwe afbeelding een
   andere intrinsieke resolutie/aspect-ratio heeft dan verwacht). Dit
   verdient eerst reproductie + Network-tab/Performance-tab-onderzoek
   voordat er een fix wordt geprobeerd.
4. **Mogelijke oplossingsrichtingen** (nog niet geïmplementeerd,
   ter overweging):
   - Illustraties comprimeren/resizen vóór upload (bv. naar de effectieve
     weergavebreedte van `.imageCard`, i.p.v. het volledige 1536x1024
     bronbestand) — via `upload-slides.mjs` of een tussenstap met bv.
     `sharp`.
   - Overstappen naar WebP/AVIF voor een veel kleinere bestandsgrootte bij
     gelijke visuele kwaliteit.
   - Supabase Storage's ingebouwde image-transformation-API gebruiken om
     on-the-fly te resizen/comprimeren zonder de bronbestanden te wijzigen
     (analoog aan wat `next/image` probeerde te doen, maar dan zonder de
     eerder vastgelopen Next.js/Turbopack-integratie).
   - Programmatisch wachten op decode-gereedheid (`img.decode()` Promise
     of `onLoad`) i.p.v. blind vertrouwen op de browser-heuristiek achter
     de z-index-occlusietruc, met een fallback-gedrag als een slide bij
     het bereiken van `startMs` nog niet klaar is.
   - `PRIORITY_LOOKAHEAD` verhogen en/of preloaden loskoppelen van
     "resterende slides" naar een vaste N-slides-vooruit-strategie met
     expliciete `Image()`-objecten in JS (i.p.v. verborgen DOM-elementen)
     zodat laadstatus programmatisch te volgen is.
5. **Reproductie vóór fix**: eerst bevestigen of de flits consistent
   optreedt bij elke overgang sinds de nieuwe illustraties, of alsnog
   incidenteel is (netwerkafhankelijk) — bepaalt of dit een
   capaciteitsprobleem (te traag voor de huidige aanpak) of een nieuw
   apart bug-patroon is.

## Belangrijke randvoorwaarde

Elke nieuwe oplossing moet **niet** terugvallen op een `transition` +
class-toggle op een hergebruikt element voor het animatiegedeelte (Ken
Burns) — dat patroon is in dit project meermaals empirisch onbetrouwbaar
gebleken (zie punt 1 en 3 hierboven). Animatiestart moet via een verse
DOM-mount (`key`-prop) blijven lopen.
