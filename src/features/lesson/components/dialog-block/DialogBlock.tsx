"use client";

import { useState } from "react";
import { Eye, EyeOff } from "lucide-react";
import styles from "./DialogBlock.module.css";
import type { DialogBlock as DialogBlockType } from "@/features/lesson/types";

type Visibility = {
  thai: boolean;
  transliteration: boolean;
  english: boolean;
};

type DialogBlockProps = {
  block: DialogBlockType;
  totalBlocks: number;
};

const LAYERS: { key: keyof Visibility; label: string }[] = [
  { key: "thai", label: "Thai" },
  { key: "transliteration", label: "Transliteration" },
  { key: "english", label: "English" },
];

export default function DialogBlock({ block, totalBlocks }: DialogBlockProps) {
  const [visible, setVisible] = useState<Visibility>({
    thai: true,
    transliteration: true,
    english: true,
  });

  function toggle(layer: keyof Visibility) {
    setVisible((prev) => ({ ...prev, [layer]: !prev[layer] }));
  }

  return (
    <div>
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

      <div className={styles.card}>
        <div className={styles.header}>
          <span>Block {block.index + 1}</span>
          <span>of {totalBlocks}</span>
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
    </div>
  );
}
