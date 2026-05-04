import styles from "./LearningStructureSection.module.css";
import { BookOpenText, LayoutList, NotebookPen } from "lucide-react";
import SectionEyebrow from "@/components/ui/SectionEyebrow/SectionEyebrow";
import { Sparkles } from "lucide-react";

export default function LearningStructureSection() {
  return (
    <section
      className={styles.section}
      aria-labelledby="learning-structure-title"
    >
      <div className={styles.header}>
        <SectionEyebrow
          icon={
            <Sparkles size={14} strokeWidth={1.8} color="var(--color-brand)" />
          }
          size="sm"
        >
          Structured Learning Approach
        </SectionEyebrow>
        <h2 id="learning-structure-title" className={styles.title}>
          Built for steady progress
        </h2>
        <p className={styles.description}>
          Dialogs form the core of each level. Focus and Themes deepen specific
          vocabulary, while Stories, News, and Practice help you meet and use
          familiar language in new ways.
        </p>
      </div>

      <div className={styles.grid}>
        <article className={styles.card}>
          <div className={styles.icon} aria-hidden="true">
            <BookOpenText size={18} strokeWidth={1.8} />
          </div>
          <h3 className={styles.cardTitle}>Dialogs</h3>
          <p className={styles.cardText}>
            The main curriculum, built step by step with revision checkpoints
            after every five lessons.
          </p>
        </article>

        <article className={styles.card}>
          <div className={styles.icon} aria-hidden="true">
            <LayoutList size={18} strokeWidth={1.8} />
          </div>
          <h3 className={styles.cardTitle}>Focus &amp; Themes</h3>
          <p className={styles.cardText}>
            Targeted vocabulary and grammar blocks for topics like time, home,
            transport, people, and more.
          </p>
        </article>

        <article className={styles.card}>
          <div className={styles.icon} aria-hidden="true">
            <NotebookPen size={18} strokeWidth={1.8} />
          </div>
          <h3 className={styles.cardTitle}>Stories, News &amp; Practice</h3>
          <p className={styles.cardText}>
            Extra context and varied exercises that help you recognize and use
            what you have already learned.
          </p>
        </article>
      </div>
    </section>
  );
}
