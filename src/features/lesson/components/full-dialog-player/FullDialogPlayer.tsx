"use client";

import { useState, useRef } from "react";
import { Play, Pause } from "lucide-react";
import styles from "./FullDialogPlayer.module.css";
import type { DialogSlide } from "@/features/lesson/types";

type FullDialogPlayerProps = {
  audioUrl: string | null;
  // Slides zijn optioneel: de player werkt ook zonder synchronisatie.
  // Worden gevuld zodra dialog_slides rijen en block-timestamps beschikbaar zijn.
  slides?: DialogSlide[];
  // Callback die vuurt wanneer de actieve slide wisselt tijdens afspelen.
  // Wordt beheerd door de parent (DialogFullSection), niet door de player zelf.
  onSlideChange?: (slideIndex: number) => void;
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

export default function FullDialogPlayer({
  audioUrl,
  slides = [],
  onSlideChange,
}: FullDialogPlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(NaN);
  const audioRef = useRef<HTMLAudioElement>(null);

  // Ref om dubbele callback-aanroepen te vermijden: onTimeUpdate vuurt ~4x/sec,
  // maar we roepen onSlideChange alleen aan als de slide daadwerkelijk wisselt.
  const prevActiveSlideRef = useRef<number>(-1); //useRef is een manier om een mutable value te bewaren die niet opnieuw renderen veroorzaakt. Hier gebruiken we het om de vorige actieve slide-index bij te houden, zodat we onSlideChange alleen aanroepen als de index verandert.

  const hasAudio = audioUrl !== null;
  // Voortgang als percentage (0-100), veilig afgevangen bij NaN/0.
  const progress =
    hasAudio && !isNaN(duration) && duration > 0
      ? (currentTime / duration) * 100
      : 0;

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
  }

  function handlePause() {
    setIsPlaying(false);
  }

  // onLoadedMetadata vuurt zodra de browser de duur kent.
  function handleLoadedMetadata() {
    const audio = audioRef.current;
    if (!audio) return;
    setDuration(audio.duration);
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
      // Update state alleen als de slide daadwerkelijk gewisseld is.
      if (newIndex !== prevActiveSlideRef.current) {
        prevActiveSlideRef.current = newIndex;
        onSlideChange?.(newIndex);
      }
    }
  }

  function handleEnded() {
    setIsPlaying(false);
    setCurrentTime(0);
    prevActiveSlideRef.current = -1;
    onSlideChange?.(-1);
  }

  return (
    <div className={styles.card}>
      {hasAudio && (
        <audio
          ref={audioRef} //vanaf nu wordt audioRef.current een referentie naar het <audio> DOM-element, zodat we er later mee kunnen interageren (bv. play/pause).
          src={audioUrl}
          onPlay={handlePlay}
          onPause={handlePause}
          onLoadedMetadata={handleLoadedMetadata}
          onTimeUpdate={handleTimeUpdate}
          onEnded={handleEnded}
          preload="metadata"
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
        {isNaN(duration) ? "--:--" : formatTime(duration)}
      </span>
    </div>
  );
}
