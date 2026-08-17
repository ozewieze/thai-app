"use client";

import { useState } from "react";
import FullDialogPlayer from "../full-dialog-player/FullDialogPlayer";
import type { DialogSlide } from "@/features/lesson/types";
import styles from "./DialogFullSection.module.css";

type DialogFullSectionProps = {
  audioUrl: string | null;
  // Exacte totale duur (ms) van de full-dialog audio, uit dialogs.audio_duration_ms
  // (gezet door scripts/merge-audio.mjs). Null voor dialogen die nog niet
  // (opnieuw) samengevoegd zijn sinds deze kolom bestaat — FullDialogPlayer
  // valt dan terug op de browser-eigen loadedmetadata/durationchange-events.
  audioDurationMs: number | null;
  slides: DialogSlide[];
  // className voor de imageCard wordt meegegeven vanuit LessonPageView
  // zodat de styling gecentraliseerd blijft in LessonPageView.module.css.
  imageCardClassName?: string;
};

/**
 * DialogFullSection
 *
 * Client component dat de slideshow-afbeelding en de FullDialogPlayer
 * combineert in één gedeelde state.
 *
 * Waarom een aparte component?
 * LessonPageView is een server component. Server components kunnen geen
 * callback-functies doorgeven aan client components. Omdat zowel de
 * imageCard (slide-display) als de FullDialogPlayer (audio + sync) de
 * activeSlideIndex moeten delen, moeten ze in dezelfde client component
 * leven.
 *
 * Dataflow:
 *   FullDialogPlayer roept onSlideChange aan wanneer de actieve slide wisselt.
 *   DialogFullSection beheert activeSlideIndex als state.
 *   De imageCard toont slides[activeSlideIndex].imageUrl zodra die beschikbaar is.
 *
 * Fallback-gedrag (zie ook FullDialogPlayer.tsx):
 *   - Vóór het spelen: activeSlideIndex start al op 0 (niet -1), zodat de
 *     eerste slide-afbeelding meteen zichtbaar is (in plaats van de
 *     placeholder totdat de audio voor het eerst een onTimeUpdate geeft).
 *   - Tijdens korte stiltegaten tussen twee blokken en na "ended": de
 *     FullDialogPlayer stuurt in die gevallen bewust GEEN -1 meer door, dus
 *     de laatst actieve slide blijft hier gewoon staan in plaats van terug
 *     te vallen op de placeholder.
 *
 * Overgang tussen slide-afbeeldingen: de afbeelding zelf wisselt nog
 *   steeds instant (ongewijzigde logica hierboven). Er is eerder
 *   geprobeerd om een crossfade/dissolve toe te voegen (zowel met
 *   gelijktijdig overlappende lagen als sequentieel fade-out-dan-fade-in).
 *   Elke variant introduceerde een eigen soort korte, opvallende flits of
 *   "flikkering" — ofwel door browser-rendertiming (witte flits bij het
 *   promoten van een GPU-compositielaag), ofwel door het blenden van twee
 *   verschillende personage-poses ("ghosting"), ofwel door het korte kale
 *   moment tussen een fade-out en fade-in. Bij dialoogslides die elkaar
 *   relatief snel opvolgen was er simpelweg te weinig tijd om zo'n moment
 *   onopvallend te maken.
 *
 *   Nieuw experiment (zie DialogFullSection.module.css): bovenop de
 *   instante wissel is een puur visuele laag toegevoegd, losstaand van de
 *   activeSlideIndex/imageUrl-logica:
 *     Een zeer subtiele, trage scale(1.00 -> 1.02) ("Ken Burns") die de
 *     volledige zichtbare duur van een slide-afbeelding loopt.
 *   (De eerder toegevoegde korte donkere overlay-flash op het wisselmoment
 *   is weer verwijderd — voegde in de praktijk niets toe.)
 *   De animatie wordt getriggerd via een verse DOM-mount
 *   (key={activeSlideIndex}) met CSS @keyframes, niet via een
 *   transition + class-toggle op een hergebruikt element — dat patroon
 *   bleek in de eerdere experimenten onbetrouwbaar.
 *
 *   Animatieduur = zichtduur van de slide: de CSS-module zet een vaste
 *   fallback-duur (12s), maar hieronder wordt per slide de werkelijke
 *   duur (endMs - startMs) berekend uit de block-timestamps en via
 *   inline style="animationDuration" overschreven. Dat overschrijft
 *   alleen de duration-subwaarde van de `animation`-shorthand in de
 *   CSS-module; de rest (curve, keyframes, fill-mode) blijft ongemoeid.
 *   Fallback op 12s zolang startMs/endMs nog null zijn (vóór
 *   merge-audio.mjs). Ondergrens van 2s zodat erg korte slides niet
 *   hortend/abrupt zoomen.
 *
 *   Statisch vóór de eerste keer play: de allereerste slide mount al
 *   (activeSlideIndex start op 0), dus zonder ingreep begon de zoom al
 *   te lopen tijdens het laden van de pagina, nog vóór er op play werd
 *   gedrukt.
 *
 *   Eerdere poging (teruggedraaid): animation-play-state dynamisch
 *   toggelen via inline style op het bestaande element (gebaseerd op een
 *   live isPlaying-boolean) leek veilig omdat het geen class-toggle was,
 *   maar bleek in de praktijk toch dezelfde witte-flits-bug te
 *   reproduceren als de eerdere mislukte experimenten (vermoedelijk
 *   opnieuw GPU-layer-promotion-timing, nu getriggerd door het dynamisch
 *   wijzigen van een animatie-gerelateerde stijlwaarde op elke
 *   slidewissel i.p.v. een statische waarde).
 *
 *   Huidige aanpak: hasStartedPlaying is true zodra er ook maar één keer
 *   op play is gedrukt (en blijft daarna altijd true, ook bij later
 *   pauzeren — pauzeren bevriest de zoom dus NIET meer, alleen de
 *   allereerste periode vóór play is statisch). Zolang hasStartedPlaying
 *   false is, krijgt de img `animationName: "none"` (geen animatie-
 *   machinerie actief, dus geen enkel layer-promotion-risico). Zodra
 *   hasStartedPlaying voor het eerst true wordt, verandert de key
 *   (activeSlideIndex + hasStartedPlaying-vlag samen), wat een verse
 *   DOM-mount forceert — exact hetzelfde betrouwbare patroon als bij
 *   een normale slidewissel, nooit een toggle op een bestaand element.
 *
 *   Resterende, losstaande oorzaak van een (incidentele) witte flits:
 *   elke slide-afbeelding is een ander bestand, dus de browser moet 'm bij
 *   de EERSTE weergave nog decoderen en schalen naar de weergavegrootte
 *   (object-fit: cover). Die gedecodeerde/geschaalde bitmap wordt gecachet
 *   per (afbeelding, weergavegrootte), maar bij een instante key-mount-
 *   wissel gebeurt die decode+schaal-operatie precies op het moment van de
 *   wissel zelf als de afbeelding nog niet eerder op die grootte is
 *   getoond — dat kan een kort wit "gat" geven. Dit staat los van
 *   animaties/GPU-layers; het is puur een browser-rendertimingkwestie die
 *   voor een eerste-keer-kijker in principe bij elke slidewissel kan
 *   optreden (niet alleen bij het handmatig wijzigen van de venstergrootte
 *   in devtools, dat was enkel een makkelijke manier om het te reproduceren).
 *   Oplossing hieronder: ALLE resterende slides van de dialoog worden
 *   vooraf gerenderd (zie .preloadImage in de CSS-module) zodra de
 *   huidige slide actief is, zodat de decode+schaal-operatie al voltooid
 *   is tegen de tijd dat elke slide daadwerkelijk zichtbaar moet worden.
 *   ("Zet ze alvast ergens klaar zodra de pagina laadt" is in de browser
 *   niet letterlijk mogelijk als een tijdelijke map — client-side JS mag
 *   niet naar het bestandssysteem schrijven — maar functioneel is dit
 *   hetzelfde idee: de afbeeldingen worden meteen opgehaald/gedecodeerd en
 *   blijven in het geheugen van de browser staan totdat ze nodig zijn.)
 *
 *   Zichtbaarheid van de preload-laag via z-index i.p.v. opacity: 0 (zie
 *   CSS-module voor de volledige uitleg): .preloadImage staat op volle
 *   opacity maar visueel afgedekt door .slideImage (hogere z-index)
 *   erbovenop. Een volledig ondoorzichtig maar afgedekt element wordt door
 *   de browser gegarandeerd normaal/volledig gerenderd — betrouwbaarder
 *   dan opacity: 0, waarbij niet zeker is of elke browser-implementatie
 *   het element altijd volledig rasterizeert. Bij een slidewissel
 *   verdwijnt de bovenste laag en komt de al klaarstaande laag eronder
 *   instant tevoorschijn.
 *
 *   Alleen de eerstvolgende PRIORITY_LOOKAHEAD slides krijgen
 *   fetchPriority="high" (native HTML-attribuut, hogere netwerk-
 *   prioriteit); de rest krijgt loading="eager" (meteen ophalen, normale
 *   prioriteit). Reden: alles tegelijk als hoge prioriteit markeren zou
 *   bij lange dialogen veel gelijktijdige hoge-prioriteit requests geven
 *   die juist de eerstvolgende (belangrijkste) afbeeldingen kunnen
 *   vertragen door bandbreedte-concurrentie.
 *
 *   Kanttekening: de voorsprong voor "de slide na de volgende" is de
 *   cumulatieve zichtduur van de tussenliggende slide(s) — bij erg korte
 *   dialoogregels en een koud netwerk kan dat nog steeds te weinig tijd
 *   zijn, dus een incidentele flits blijft theoretisch mogelijk.
 *
 *   Belangrijke kanttekening: de gedecodeerde/geschaalde bitmap-cache van
 *   de browser overleeft geen page reload — enkel de ruwe HTTP-bytes
 *   kunnen over sessies heen warm blijven. Elke nieuwe paginalading is dus
 *   sowieso een "koude decode" voor elke slide-afbeelding, ongeacht of de
 *   browsercache is geleegd.
 *
 *   next/image-experiment (teruggedraaid): er is geprobeerd om over te
 *   stappen op next/image voor kleinere, per-breakpoint al toepasselijk
 *   geschaalde bestanden (kortere decodetijd). Dat liep vast op een
 *   hardnekkige "url parameter is not allowed"-fout via de
 *   /_next/image-optimizer bij een lokale Supabase-instantie
 *   (http://127.0.0.1:<poort>) onder Turbopack — ook nadat protocol/
 *   hostname/poort in next.config.ts aantoonbaar correct waren
 *   geconfigureerd (bevestigd via een tijdelijk diagnostisch log) en de
 *   .next-cache volledig was geleegd. Niet verder uitgezocht omdat de
 *   kosten van het najagen van deze specifieke Next.js/Turbopack-
 *   eigenaardigheid niet opwogen tegen het (nog onbewezen) voordeel.
 *   Teruggevallen op gewone <img>-elementen (huidige staat).
 */
const PRIORITY_LOOKAHEAD = 2;
const FALLBACK_SLIDE_ANIMATION_SECONDS = 12;
const MIN_SLIDE_ANIMATION_SECONDS = 2;

// Berekent de Ken Burns-animatieduur (in seconden) voor een slide op basis
// van de werkelijke zichtduur (endMs - startMs). Valt terug op de vaste
// FALLBACK_SLIDE_ANIMATION_SECONDS zolang de timestamps nog null zijn
// (dialoog nog niet door merge-audio.mjs verwerkt), en clamp naar beneden
// op MIN_SLIDE_ANIMATION_SECONDS zodat erg korte slides niet abrupt zoomen.
function getSlideAnimationDurationSeconds(slide: DialogSlide): number {
  if (slide.startMs === null || slide.endMs === null) {
    return FALLBACK_SLIDE_ANIMATION_SECONDS;
  }
  const visibleSeconds = (slide.endMs - slide.startMs) / 1000;
  if (!isFinite(visibleSeconds) || visibleSeconds <= 0) {
    return FALLBACK_SLIDE_ANIMATION_SECONDS;
  }
  return Math.max(MIN_SLIDE_ANIMATION_SECONDS, visibleSeconds);
}

export default function DialogFullSection({
  audioUrl,
  audioDurationMs,
  slides,
  imageCardClassName,
}: DialogFullSectionProps) {
  // Start op de eerste slide (index 0) als er slides zijn, in plaats van -1.
  const [activeSlideIndex, setActiveSlideIndex] = useState<number>(
    slides.length > 0 ? 0 : -1,
  );

  // Of er ooit al op play is gedrukt (zie FullDialogPlayer.onPlayStateChange).
  // Start op false en wordt daarna permanent true (ook na pauzeren): enkel
  // de periode vóór de allereerste play moet statisch zijn.
  const [hasStartedPlaying, setHasStartedPlaying] = useState(false);

  // Wordt aangeroepen bij elke play/pause/ended-transitie, maar we zetten
  // hasStartedPlaying alleen bij een echte "play" (true) en negeren pauzeren
  // (false) — eenmaal gestart blijft de zoom dus doorlopen na pauzeren.
  function handlePlayStateChange(isPlaying: boolean) {
    if (isPlaying) setHasStartedPlaying(true);
  }

  // De actieve slide op basis van de index die de player doorgeeft.
  // null als er geen slides zijn of de index buiten bereik valt.
  const activeSlide =
    activeSlideIndex >= 0 && activeSlideIndex < slides.length
      ? slides[activeSlideIndex]
      : null;

  // Alle resterende slides (indien aanwezig): worden vooraf gerenderd
  // (visueel afgedekt door de actieve slide, zie .preloadImage) zodat de
  // decode+schaal-operatie al klaar is tegen de tijd dat elke slide
  // daadwerkelijk actief wordt (zie de comments hierboven). Alleen de
  // eerste PRIORITY_LOOKAHEAD daarvan krijgen hoge prioriteit.
  //
  // Op de laatste slide is er normaal "niets meer na" (slice geeft een
  // lege array), maar bij een herstart van de dialoog (laatste -> eerste
  // slide) is slide 0 dan wél de eerstvolgende. Daarom wordt slide 0
  // expliciet meegenomen zolang de laatste slide actief is, zodat ook die
  // overgang geen onvoorbereide, verse afbeelding tegenkomt.
  const isLastSlide = activeSlideIndex === slides.length - 1;
  const preloadSlides =
    activeSlideIndex >= 0
      ? isLastSlide
        ? slides.slice(0, 1)
        : slides.slice(activeSlideIndex + 1)
      : [];

  return (
    <div className={styles.combinedCard}>
      {/* Slide-afbeelding of placeholder */}
      <div className={imageCardClassName}>
        {activeSlide?.imageUrl ? (
          <div className={styles.imageWrapper}>
            {/*
              key bevat zowel activeSlideIndex als hasStartedPlaying, zodat
              zowel een slide-wissel als de overgang "nog niet gespeeld" ->
              "gestart" een vers DOM-element mounten. Dat is nodig zodat de
              @keyframes-animatie betrouwbaar (opnieuw) start (zie de
              comments hierboven) — nooit via een toggle op een bestaand
              element. 
              Dus van <img key="0-idle" /> naar <img key="0-playing" /> bij de allereerste keer play, en van <img key="0-playing" /> naar <img key="1-playing" /> bij de eerste slidewissel.
            */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              key={`${activeSlideIndex}-${hasStartedPlaying ? "playing" : "idle"}`}
              src={activeSlide.imageUrl}
              alt=""
              className={styles.slideImage}
              style={
                hasStartedPlaying
                  ? {
                      animationDuration: `${getSlideAnimationDurationSeconds(activeSlide)}s`,
                    }
                  : { animationName: "none" }
              }
            />

            {/*
              Preload van alle resterende slides: volledig ondoorzichtig
              maar visueel afgedekt door .slideImage erbovenop (z-index,
              zie CSS-module) i.p.v. opacity: 0 — betrouwbaarder om de
              browser te dwingen tot volledige decode/rasterisatie. De
              eerste PRIORITY_LOOKAHEAD krijgen fetchPriority="high"
              (native HTML-attribuut, hogere netwerk-prioriteit), de rest
              krijgt loading="eager" (meteen ophalen, normale prioriteit —
              voorkomt dat een lange dialoog te veel gelijktijdige
              hoge-prioriteit requests geeft die de eerstvolgende, meest
              urgente afbeeldingen zouden vertragen). Geen key-koppeling
              aan hasStartedPlaying nodig — deze elementen hoeven nooit een
              animatie te starten, enkel de browser aan het decoderen/
              schalen te zetten.
            */}
            {preloadSlides.map((slide, index) =>
              slide.imageUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  key={`preload-${slide.slideIndex}`}
                  src={slide.imageUrl}
                  alt=""
                  aria-hidden="true"
                  className={styles.preloadImage}
                  loading="eager"
                  {...(index < PRIORITY_LOOKAHEAD
                    ? { fetchPriority: "high" as const }
                    : {})}
                />
              ) : null,
            )}
          </div>
        ) : (
          "Illustration coming soon"
        )}
      </div>

      {/* Full-dialog audioplayer met slide-synchronisatie */}
      <FullDialogPlayer
        audioUrl={audioUrl}
        audioDurationMs={audioDurationMs}
        slides={slides}
        onSlideChange={setActiveSlideIndex}
        onPlayStateChange={handlePlayStateChange}
      />
    </div>
  );
}
