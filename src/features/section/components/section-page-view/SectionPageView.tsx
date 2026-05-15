import Link from "next/link";
import LevelBadge from "@/components/ui/level-badge/LevelBadge";
import styles from "./SectionPageView.module.css";
import Breadcrumbs from "@/components/ui/breadcrumbs/Breadcrumbs";
import SectionNav from "../section-nav/SectionNav";
import type { Level } from "@/features/curriculum/types";
import type { LevelSectionKey } from "@/features/level/data";
import type { SectionLessonCardItem } from "@/features/curriculum/types";
import LessonCompletionButton from "../lesson-completion-button/LessonCompletionButton";
import PremiumBadge from "@/features/level/section/premium-badge/PremiumBadge";
import { isLessonLocked } from "@/features/section/lib/isLessonLocked";
export type SectionPageViewProps = {
  level: string;
  section: LevelSectionKey;
  levelData: Level;
  sectionItems: SectionLessonCardItem[];
  sectionLabels: Record<LevelSectionKey, string>;
};
// TODO - connect lesson completion button to real user data
const viewer = { plan: "free" as const };

export default function SectionPageView({
  level,
  section,
  levelData,
  sectionItems,
  sectionLabels,
}: SectionPageViewProps) {
  return (
    <section className={styles.page} aria-labelledby="level-title">
      <div className={styles.hero}>
        <Breadcrumbs
          items={[
            { label: "levels", href: "/levels" },
            { label: levelData.id, href: `/learn/${level}/dialogs` },
            { label: sectionLabels[section] },
          ]}
        />

        <div className={styles.header}>
          <LevelBadge levelId={levelData.id} responsive />
          <div className={styles.headerText}>
            <h1 id="level-title" className={styles.title}>
              {levelData.title}
            </h1>
            <p className={styles.description}>{levelData.description}</p>
          </div>
        </div>
      </div>

      <SectionNav
        level={level}
        section={section}
        sectionLabels={sectionLabels}
      />

      <div className={styles.content}>
        {section === "dialogs" &&
          (sectionItems.length > 0 ? (
            <ul className={styles.grid} role="list">
              {sectionItems.map((item) => {
                const isLocked = isLessonLocked(item, viewer);
                return (
                  <li key={item.lessonKey} className={styles.gridItem}>
                    {item.lessonType === "dialog" ? (
                      <article className={styles.lessonCard}>
                        <div className={styles.lessonCardTop}>
                          <span className={styles.lessonNumber}>
                            {item.sequenceNumber}
                          </span>
                          {isLocked ? (
                            <PremiumBadge />
                          ) : (
                            <LessonCompletionButton
                              lessonTitle={item.title}
                              comingSoon
                            />
                          )}
                        </div>

                        <div className={styles.lessonBody}>
                          <h2 className={styles.lessonTitle}>
                            <Link
                              href={`/lessons/${item.slug}`}
                              className={styles.cardMainLink}
                            >
                              {item.title}
                            </Link>
                          </h2>

                          {item.subtitle ? (
                            <p className={styles.lessonSubtitle}>
                              {item.subtitle}
                            </p>
                          ) : null}
                        </div>
                      </article>
                    ) : (
                      <article className={styles.revisionCard}>
                        {isLocked ? (
                          <PremiumBadge />
                        ) : (
                          <LessonCompletionButton
                            lessonTitle={item.title}
                            comingSoon
                          />
                        )}
                        {/* <LessonCompletionButton
                          lessonTitle={item.title}
                          comingSoon
                        /> */}

                        {/* <div className={styles.revisionTop}>
                          <span className={styles.lessonNumber}>
                            {item.sequenceNumber}
                          </span>

                          <div className={styles.lessonStatus}>
                            {item.accessTier === "premium" ? (
                              <span className={styles.premiumBadge}>
                                Premium
                              </span>
                            ) : (
                              ""
                            )}
                          </div>
                        </div> */}

                        <div className={styles.revisionBody}>
                          <h2 className={styles.revisionTitle}>
                            <Link
                              href={`/lessons/${item.slug}`}
                              className={styles.cardMainLink}
                            >
                              {item.title}
                            </Link>
                          </h2>

                          {item.subtitle ? (
                            <p className={styles.revisionText}>
                              {item.subtitle}
                            </p>
                          ) : (
                            <p className={styles.revisionText}>
                              Review key vocabulary and patterns from previous
                              lessons.
                            </p>
                          )}
                        </div>
                      </article>
                    )}
                  </li>
                );
              })}
            </ul>
          ) : (
            <div className={styles.emptyState}>
              <h2 className={styles.emptyTitle}>Dialogs</h2>
              <p className={styles.emptyText}>No lessons available yet.</p>
            </div>
          ))}
      </div>
    </section>
  );
}
