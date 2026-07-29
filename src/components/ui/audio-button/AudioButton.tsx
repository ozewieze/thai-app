"use client";

import { useRef, useState } from "react";
import { Volume2, Pause } from "lucide-react";
import styles from "./AudioButton.module.css";

/**
 * AudioButton
 *
 * Herbruikbare client-audioknop (lemma's, voorbeelden, later oefeningen).
 * Ingebed in server-gerenderde kaarten: de kaart blijft server, alleen
 * deze knop is client. Elke knop heeft zijn eigen verborgen <audio> met
 * preload="none" (geen netwerk tot de gebruiker afspeelt).
 *
 * `audioUrl === null` -> knop disabled met een titel; veel audio is nog
 * niet gegenereerd (dat is een normale authoring-toestand).
 */
type AudioButtonProps = {
  audioUrl: string | null;
  /** Korte omschrijving (bv. het woord/zin) voor een duidelijk aria-label. */
  label?: string;
};

export default function AudioButton({ audioUrl, label }: AudioButtonProps) {
  const audioRef = useRef<HTMLAudioElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const hasAudio = audioUrl !== null;

  function toggle() {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
      setIsPlaying(false);
    } else {
      // play() geeft een Promise; fouten (bv. ongeldige URL) opvangen zodat
      // de app niet crasht.
      audio.play().catch(() => setIsPlaying(false));
      setIsPlaying(true);
    }
  }

  const actionLabel = isPlaying ? "Pause" : "Play";

  return (
    <>
      <button
        type="button"
        className={`${styles.button} ${isPlaying ? styles.playing : ""}`}
        onClick={toggle}
        disabled={!hasAudio}
        aria-label={label ? `${actionLabel} audio: ${label}` : `${actionLabel} audio`}
        title={hasAudio ? undefined : "No audio available yet"}
      >
        {isPlaying ? <Pause size={16} /> : <Volume2 size={16} />}
      </button>
      {hasAudio && (
        <audio
          ref={audioRef}
          src={audioUrl}
          preload="none"
          onEnded={() => setIsPlaying(false)}
        />
      )}
    </>
  );
}
