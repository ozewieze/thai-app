"use client";

import { useState, useRef } from "react";
import { Play, Pause } from "lucide-react";
import styles from "./FullDialogPlayer.module.css";

type FullDialogPlayerProps = {
  audioUrl: string | null;
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

export default function FullDialogPlayer({ audioUrl }: FullDialogPlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(NaN);
  const audioRef = useRef<HTMLAudioElement>(null); //HTMLAudioElement is gewoon het Javascript obçject dat de browser maakt voor <audio> tags, bvb <audio src="song.mp3"></audio> . useRef houdt een referentie bij naar dat DOM-element, zodat we er later mee kunnen interageren (bv. play/pause).

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
  function handleTimeUpdate() {
    const audio = audioRef.current;
    if (!audio) return;
    setCurrentTime(audio.currentTime);
  }

  function handleEnded() {
    setIsPlaying(false);
    setCurrentTime(0);
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
