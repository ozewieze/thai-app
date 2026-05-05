import styles from "./AllLevelsPage.module.css";
import LevelsGrid from "@/components/ui/levels-grid/LevelsGrid";
import levels from "@/features/curriculum/levels";

export default function AllLevelsPage() {
  return (
    <main className={styles.page}>
      <div className={styles.header}>
        <h1 className={styles.title}>All Levels</h1>
        <p className={styles.description}>
          Choose your level and start learning. Follow the CEFR framework from
          A1 Beginner to C2 Fluent.
        </p>
      </div>

      <LevelsGrid levels={levels} ctaLabelMode="level" />
    </main>
  );
}
