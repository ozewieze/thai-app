import styles from "./DialogBlock.module.css";
import type { DialogBlock as DialogBlockType } from "@/features/lesson/types";

type DialogBlockProps = {
  block: DialogBlockType;
  totalBlocks: number;
};

export default function DialogBlock({ block, totalBlocks }: DialogBlockProps) {
  return (
    <div className={styles.card}>
      <div className={styles.header}>
        <span>Block {block.index + 1}</span>
        <span style={{ color: "var(--color-border-strong)" }}>
          ({totalBlocks} total)
        </span>
      </div>

      <p className={styles.thaiText}>{block.thaiLine}</p>

      {block.transliterationLine && (
        <p className={styles.transliteration}>{block.transliterationLine}</p>
      )}

      {block.translationLine && (
        <p className={styles.translation}>{block.translationLine}</p>
      )}
    </div>
  );
}
