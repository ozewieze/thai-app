import { Volume2 } from "lucide-react";
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
};

export default function DialogBlock({ block, visible }: DialogBlockProps) {
  return (
    <div className={styles.card}>
      <div className={styles.header}>
        <Volume2 size={15} />
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
