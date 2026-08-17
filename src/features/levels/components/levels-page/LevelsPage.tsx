import styles from "./LevelsPage.module.css";
import LevelsGrid from "@/features/levels/components/levels-grid/LevelsGrid";
import levels from "@/features/curriculum/levels";

export default function LevelsPage() {
  return (
    <section className={styles.page} aria-labelledby="levels-title">
      <div className={styles.header}>
        <h1 id="levels-title" className={styles.title}>
          All Levels
        </h1>
        <p className={styles.description}>
          Choose your level and start learning. Follow the CEFR framework from
          A1 Beginner to C2 Fluent.
        </p>
      </div>

      <LevelsGrid levels={levels} ctaLabelMode="level" />
    </section>
  );
}
