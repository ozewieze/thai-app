import { Volume2, Pause } from "lucide-react";
import styles from "./DialogBlock.module.css";
import type { DialogBlock as DialogBlockType } from "@/features/lesson/types";

export type Visibility = {
  thai: boolean;
  transliteration: boolean;
  english: boolean;
};

type DialogBlockProps = {
  block: DialogBlockType;
  visible: Visibility;
  isPlaying: boolean;
  onAudioToggle: () => void;
};

export default function DialogBlock({ block, visible, isPlaying, onAudioToggle }: DialogBlockProps) {
  const hasAudio = block.audioUrl !== null;

  return (
    <div className={styles.card}>
      <div className={styles.header}>
        {/* Knop is disabled als er geen audioUrl is voor dit blok.
            aria-label geeft schermlezers een beschrijvende tekst. */}
        <button
          className={`${styles.audioBtn} ${isPlaying ? styles.audioBtnActive : ""} ${!hasAudio ? styles.audioBtnDisabled : ""}`}
          onClick={onAudioToggle}
          disabled={!hasAudio}
          aria-label={isPlaying ? "Pause audio" : "Play audio"}
          title={hasAudio ? undefined : "No audio available yet"}
        >
          {isPlaying ? <Pause size={15} /> : <Volume2 size={15} />}
        </button>
        <span>Block {block.index + 1}</span>
      </div>

      {visible.thai && (
        <p className={styles.thaiText}>{block.thaiLine}</p>
      )}
      {visible.transliteration && block.transliterationLine && (
        <p className={styles.transliteration}>{block.transliterationLine}</p>
      )}
      {visible.english && block.translationLine && (
        <p className={styles.translation}>{block.translationLine}</p>
      )}
    </div>
  );
}
