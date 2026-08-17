"use client";

import { useState, useRef, useEffect } from "react";
import { Eye, EyeOff, ChevronLeft, ChevronRight } from "lucide-react";
import styles from "./DialogPlayer.module.css";
import DialogBlock from "../dialog-block/DialogBlock";
import type {
  DialogBlock as DialogBlockType,
  Visibility,
} from "@/features/lesson/types";

type DialogPlayerProps = {
  blocks: DialogBlockType[];
};

const LAYERS: { key: keyof Visibility; label: string }[] = [
  { key: "thai", label: "Thai" },
  { key: "transliteration", label: "Transliteration" },
  { key: "english", label: "English" },
];

export default function DialogPlayer({ blocks }: DialogPlayerProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [visible, setVisible] = useState<Visibility>({
    thai: true,
    transliteration: true,
    english: true,
  });
  const [isPlaying, setIsPlaying] = useState(false);

  // useRef houdt een referentie bij naar het <audio> DOM-element.
  // Anders dan useState triggert een ref-wijziging geen re-render --
  // precies wat we willen: audio afspelen is een side effect, geen UI-state.
  const audioRef = useRef<HTMLAudioElement>(null);

  // Stop audio automatisch zodra de gebruiker van blok wisselt.
  // useEffect met [currentIndex] als dependency loopt elke keer dat
  // currentIndex verandert -- dus bij elke blokwisseling.
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;
    audio.pause();
    audio.currentTime = 0;
    setIsPlaying(false);
  }, [currentIndex]);

  const currentBlock = blocks[currentIndex];
  const isFirst = currentIndex === 0;
  const isLast = currentIndex === blocks.length - 1;

  function toggle(layer: keyof Visibility) {
    setVisible((prev) => ({ ...prev, [layer]: !prev[layer] }));
  }

  function handleAudioToggle() {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
      setIsPlaying(false);
    } else {
      // play() geeft een Promise terug. We vangen fouten op (bv. bij
      // een ongeldige URL) zodat de app niet crasht.
      audio.play().catch(() => {
        setIsPlaying(false);
      });
      setIsPlaying(true);
    }
  }

  // Zet isPlaying terug op false zodra het audiobestand volledig is afgespeeld.
  function handleAudioEnded() {
    setIsPlaying(false);
  }

  if (!currentBlock) return null;

  return (
    <div className={styles.wrapper}>
      {/* Toggles: gecenterd op mobile, rechts op desktop */}
      <div className={styles.toggles}>
        {LAYERS.map(({ key, label }) => (
          <button
            key={key}
            className={`${styles.toggleBtn} ${visible[key] ? styles.toggleBtnActive : ""}`}
            onClick={() => toggle(key)}
            aria-pressed={visible[key]}
            aria-label={`${visible[key] ? "Hide" : "Show"} ${label}`}
          >
            {visible[key] ? <Eye size={15} /> : <EyeOff size={15} />}
            {label}
          </button>
        ))}
      </div>

      {/* Verborgen audio element -- wordt bestuurd via audioRef.
          key={currentBlock.id} zorgt ervoor dat React een nieuw element
          aanmaakt bij elk blok, zodat de src correct wordt geladen. */}
      {currentBlock.audioUrl && (
        <audio
          ref={audioRef}
          src={currentBlock.audioUrl}
          key={currentBlock.id}
          onEnded={handleAudioEnded}
          preload="none"
        />
      )}

      {/* Dialog block */}
      <DialogBlock
        block={currentBlock}
        visible={visible}
        isPlaying={isPlaying}
        onAudioToggle={handleAudioToggle}
      />

      {/* Dot indicators */}
      <div className={styles.dots} aria-hidden="true">
        {blocks.map((_, i) => (
          <span
            key={i}
            className={`${styles.dot} ${i === currentIndex ? styles.dotActive : ""}`}
          />
        ))}
      </div>

      {/* Previous / Next */}
      <div className={styles.nav}>
        <button
          className={styles.navBtn}
          onClick={() => setCurrentIndex((i) => i - 1)}
          disabled={isFirst}
          aria-label="Previous block"
        >
          <ChevronLeft size={16} />
          Previous
        </button>

        <span className={styles.navCount}>
          {currentIndex + 1} of {blocks.length}
        </span>

        <button
          className={`${styles.navBtn} ${styles.navNext}`}
          onClick={() => setCurrentIndex((i) => i + 1)}
          disabled={isLast}
          aria-label="Next block"
        >
          Next
          <ChevronRight size={16} />
        </button>
      </div>
    </div>
  );
}
