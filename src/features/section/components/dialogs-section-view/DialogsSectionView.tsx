import Link from "next/link";
import styles from "./DialogsSectionView.module.css";
import type { SectionLessonCardItem } from "@/features/curriculum/types";
import LessonCompletionButton from "../lesson-completion-button/LessonCompletionButton";
import PremiumBadge from "@/features/level/section/premium-badge/PremiumBadge";
import { isLessonLocked } from "@/features/section/lib/isLessonLocked";

type Viewer = { plan: "free" | "premium" } | null;

type DialogsSectionViewProps = {
  items: SectionLessonCardItem[];
  viewer: Viewer;
  emptyTitle: string;
  emptyText: string;
};

export default function DialogsSectionView({
  items,
  viewer,
  emptyTitle,
  emptyText,
}: DialogsSectionViewProps) {
  if (items.length === 0) {
    return (
      <div className={styles.emptyState}>
        <h2 className={styles.emptyTitle}>{emptyTitle}</h2>
        <p className={styles.emptyText}>{emptyText}</p>
      </div>
    );
  }

  return (
    <ul className={styles.grid} role="list">
      {items.map((item) => {
        const isLocked = isLessonLocked(item, viewer);
        const isRevision = item.lessonType === "revision";

        return (
          <li key={item.lessonKey} className={styles.gridItem}>
            <article
              className={isRevision ? styles.revisionCard : styles.lessonCard}
            >
              <div
                className={
                  isRevision ? styles.revisionTop : styles.lessonCardTop
                }
              >
                <span className={styles.lessonNumber}>
                  {item.sequenceNumber}
                </span>
                {isLocked ? (
                  <PremiumBadge />
                ) : (
                  <LessonCompletionButton lessonTitle={item.title} comingSoon />
                )}
              </div>

              <div
                className={isRevision ? styles.revisionBody : styles.lessonBody}
              >
             <h2 className={isRevision ? styles.revisionTitle : styles.lessonTitle}>
  {isLocked ? (
    <span className={styles.cardMainLink}>{item.title}</span>
  ) : (
    <Link href={`/lessons/${item.slug}`} className={styles.cardMainLink}>
      {item.title}
    </Link>
  )}
</h2>

                {item.subtitle ? (
                  <p
                    className={
                      isRevision ? styles.revisionText : styles.lessonSubtitle
                    }
                  >
                    {item.subtitle}
                  </p>
                ) : isRevision ? (
                  <p className={styles.revisionText}>
                    Review key vocabulary and patterns from previous lessons.
                  </p>
                ) : null}
              </div>
            </article>
          </li>
        );
      })}
    </ul>
  );
}
