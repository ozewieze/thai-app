"use client";

import { useState, useRef } from "react";
import { Play, Pause } from "lucide-react";
import styles from "./FullDialogPlayer.module.css";
import type { DialogSlide } from "@/features/lesson/types";

type FullDialogPlayerProps = {
  audioUrl: string | null;
  // Exacte totale duur (ms) uit dialogs.audio_duration_ms (zie
  // scripts/merge-audio.mjs). Voorkomt dat de browser deze zelf uit het
  // (samengevoegde) MP3-bestand moet destilleren, wat onbetrouwbaar bleek.
  // Null voor dialogen die nog niet met de bijgewerkte scriptversie
  // samengevoegd zijn — dan valt de player terug op de browser-events.
  audioDurationMs?: number | null;
  // Slides zijn optioneel: de player werkt ook zonder synchronisatie.
  // Worden gevuld zodra dialog_slides rijen en block-timestamps beschikbaar zijn.
  slides?: DialogSlide[];
  // Callback die vuurt wanneer de actieve slide wisselt tijdens afspelen.
  // Wordt beheerd door de parent (DialogFullSection), niet door de player zelf.
  onSlideChange?: (slideIndex: number) => void;
  // Callback die vuurt wanneer play/pause-status verandert (incl. "ended").
  // DialogFullSection gebruikt dit om de Ken Burns-zoom te pauzeren zolang
  // er niet wordt afgespeeld (bv. vóór de eerste keer op play drukken).
  onPlayStateChange?: (isPlaying: boolean) => void;
};

// Zet seconden om naar "m:ss" formaat (bv. 63 -> "1:03").
// isNaN-check vangt het geval op waarbij de browser de duration
// nog niet kent (gebeurt vóór onLoadedMetadata).
function formatTime(seconds: number): string {
  if (isNaN(seconds) || seconds < 0) return "0:00";
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}:${s.toString().padStart(2, "0")}`;
}

// Is deze duration-waarde bruikbaar om te tonen/te rekenen?
// Sommige samengevoegde MP3-bestanden (zie merge-audio.mjs, dat blokken
// aan elkaar plakt via ffmpeg -c copy zonder herenkoderen) hebben geen
// betrouwbare duur in hun header. De browser geeft dan bij loadedmetadata
// soms NaN of Infinity terug, en corrigeert dat pas later via een apart
// durationchange-event. Infinity is dus net zo "nog niet bekend" als NaN.
function isKnownDuration(value: number): boolean {
  return !isNaN(value) && isFinite(value) && value > 0;
}

export default function FullDialogPlayer({
  audioUrl,
  audioDurationMs = null,
  slides = [],
  onSlideChange,
  onPlayStateChange,
}: FullDialogPlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  // Initieel al gevuld vanuit audioDurationMs (database) als die er is —
  // dan staan balk en duur er meteen, zonder te wachten op onbetrouwbare
  // browser-events. Anders NaN, zoals voorheen (browser-events vullen 'm aan).
  const [duration, setDuration] = useState<number>(() =>
    audioDurationMs && audioDurationMs > 0 ? audioDurationMs / 1000 : NaN,
  );
  const audioRef = useRef<HTMLAudioElement>(null);

  // Ref om dubbele callback-aanroepen te vermijden: onTimeUpdate vuurt ~4x/sec,
  // maar we roepen onSlideChange alleen aan als de slide daadwerkelijk wisselt.
  const prevActiveSlideRef = useRef<number>(-1); //useRef is een manier om een mutable value te bewaren die niet opnieuw renderen veroorzaakt. Hier gebruiken we het om de vorige actieve slide-index bij te houden, zodat we onSlideChange alleen aanroepen als de index verandert.

  const hasAudio = audioUrl !== null;
  // Voortgang als percentage (0-100), veilig afgevangen bij NaN/Infinity/0.
  const progress =
    hasAudio && isKnownDuration(duration) ? (currentTime / duration) * 100 : 0;

  function handleToggle() {
    const audio = audioRef.current;
    if (!audio) return;
    if (isPlaying) {
      audio.pause();
    } else {
      audio.play().catch(() => setIsPlaying(false));
    }
  }

  // onPlay en onPause: de browser kan ook zelf pauzeren (bv. bij netwerk-
  // problemen), dus we luisteren naar de events op het element zelf
  // in plaats van alleen de knop bij te houden.
  function handlePlay() {
    setIsPlaying(true);
    onPlayStateChange?.(true);
  }

  function handlePause() {
    setIsPlaying(false);
    onPlayStateChange?.(false);
  }

  // onLoadedMetadata vuurt zodra de browser de duur (voorlopig) kent.
  // onDurationChange vuurt telkens als die duur daarna nog verandert —
  // dat is precies wat er gebeurt bij de samengevoegde MP3's zonder
  // betrouwbare header: loadedmetadata geeft eerst NaN/Infinity, en de
  // echte waarde komt pas later via durationchange. Beide events roepen
  // dezelfde updateDuration aan.
  //
  // We overschrijven de state alleen als de browser een BRUIKBARE waarde
  // teruggeeft. Zonder die guard zou een tussentijdse NaN/Infinity-melding
  // een al betrouwbare, uit audioDurationMs geïnitialiseerde duur kunnen
  // overschrijven met een slechtere waarde.
  function updateDuration() {
    const audio = audioRef.current;
    if (!audio) return;
    if (isKnownDuration(audio.duration)) {
      setDuration(audio.duration);
    }
  }

  // onTimeUpdate vuurt ~4x per seconde tijdens afspelen.
  // We updaten currentTime en berekenen de actieve slide op basis van timestamps.
  function handleTimeUpdate() {
    const audio = audioRef.current;
    if (!audio) return;
    setCurrentTime(audio.currentTime);

    // Bereken de actieve slide op basis van currentTime (in ms).
    // Alleen als er slides met timestamps beschikbaar zijn.
    if (slides.length > 0) {
      const currentMs = audio.currentTime * 1000;
      const newIndex = slides.findIndex(
        (s) =>
          s.startMs !== null &&
          s.endMs !== null &&
          currentMs >= s.startMs &&
          currentMs < s.endMs,
      );
      // newIndex is -1 tijdens het stiltegat tussen twee blokken (zie
      // SILENCE_GAP_MS in scripts/merge-audio.mjs) of vóór de allereerste
      // slide. We negeren dat resultaat bewust: de vorige actieve slide
      // blijft staan in plaats van dat DialogFullSection terugvalt op de
      // placeholder. Alleen een echte, geldige slide-index (>= 0) wordt
      // doorgegeven.
      if (newIndex !== -1 && newIndex !== prevActiveSlideRef.current) {
        prevActiveSlideRef.current = newIndex;
        onSlideChange?.(newIndex);
      }
    }
  }

  function handleEnded() {
    setIsPlaying(false);
    onPlayStateChange?.(false);
    setCurrentTime(0);
    // Bewust GEEN reset van de slide-index naar -1: de laatst getoonde
    // slide blijft zichtbaar in plaats van terug te vallen op de placeholder.
  }

  return (
    <div className={styles.card}>
      {hasAudio && (
        <audio
          ref={audioRef} //vanaf nu wordt audioRef.current een referentie naar het <audio> DOM-element, zodat we er later mee kunnen interageren (bv. play/pause).
          src={audioUrl}
          onPlay={handlePlay}
          onPause={handlePause}
          onLoadedMetadata={updateDuration}
          onDurationChange={updateDuration}
          onTimeUpdate={handleTimeUpdate}
          onEnded={handleEnded}
          preload="metadata" //preload="metadata" betekent dat de browser alleen de metadata van het audio-bestand (zoals duur) moet laden, maar niet het hele bestand. Dit is efficiënter als je alleen de duur nodig hebt voordat de gebruiker op play drukt.
        />
      )}

      <button
        className={`${styles.playBtn} ${!hasAudio ? styles.playBtnDisabled : ""}`}
        onClick={handleToggle}
        disabled={!hasAudio}
        aria-label={isPlaying ? "Pause full dialogue" : "Play full dialogue"}
      >
        {isPlaying ? (
          <Pause size={16} fill="currentColor" />
        ) : (
          <Play size={16} fill="currentColor" />
        )}
      </button>

      <div className={styles.meta}>
        <span className={styles.label}>Full Dialogue</span>
        <div className={styles.track}>
          <div className={styles.trackFill} style={{ width: `${progress}%` }} />
        </div>
      </div>

      <span className={styles.time}>
        {formatTime(currentTime)} /{" "}
        {isKnownDuration(duration) ? formatTime(duration) : "--:--"}
      </span>
    </div>
  );
}
