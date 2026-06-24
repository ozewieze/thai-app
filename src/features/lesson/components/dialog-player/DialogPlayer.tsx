"use client";

import { useState } from "react";
import { Eye, EyeOff, ChevronLeft, ChevronRight } from "lucide-react";
import styles from "./DialogPlayer.module.css";
import DialogBlock, { type Visibility } from "../dialog-block/DialogBlock";
import type { DialogBlock as DialogBlockType } from "@/features/lesson/types";

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

  const currentBlock = blocks[currentIndex];
  const isFirst = currentIndex === 0;
  const isLast = currentIndex === blocks.length - 1;

  function toggle(layer: keyof Visibility) {
    setVisible((prev) => ({ ...prev, [layer]: !prev[layer] }));
  }

  function goToPrev() {
    if (!isFirst) setCurrentIndex((i) => i - 1);
  }

  function goToNext() {
    if (!isLast) setCurrentIndex((i) => i + 1);
  }

  if (!currentBlock) return null;

  return (
    <div className={styles.wrapper}>
      {/* Visibility toggles */}
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

      {/* Dialog block */}
      <DialogBlock
        block={currentBlock}
        totalBlocks={blocks.length}
        visible={visible}
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
          onClick={goToPrev}
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
          onClick={goToNext}
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
