import styles from "./LevelsSection.module.css";
import LevelsGrid from "@/features/levels/components/levels-grid/LevelsGrid";
import levels from "@/features/curriculum/levels";

export default function LevelsSection() {
  return (
    <section className={styles.section} aria-labelledby="levels-title">
      <div className={styles.header}>
        <h2 id="levels-title" className={styles.title}>
          Progress from A1 to C2
        </h2>
        <p className={styles.description}>
          Follow the internationally recognized CEFR framework, designed for
          structured language progression.
        </p>
      </div>

      <LevelsGrid levels={levels} />
    </section>
  );
}
