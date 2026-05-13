import Link from "next/link";
import LevelBadge from "@/components/ui/level-badge/LevelBadge";
import styles from "./SectionPageView.module.css";
import Breadcrumbs from "@/components/ui/breadcrumbs/Breadcrumbs";
import SectionNav from "../section-nav/SectionNav";
import type { Level } from "@/features/curriculum/types";
import type { LevelSectionKey } from "@/features/level/data";
// import type { SectionsForLevel } from "@/features/section/types";
import type { SectionLessonCardItem } from "@/features/curriculum/types";

export type SectionPageViewProps = {
  level: string;
  section: LevelSectionKey;
  levelData: Level;
  sectionItems: SectionLessonCardItem[];
  sectionLabels: Record<LevelSectionKey, string>;
};

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
              {sectionItems.map((item) => (
                <li key={item.lessonKey}>
                  {item.lessonType === "dialog" ? (
                    <Link
                      href={`/lessons/${item.slug}`}
                      className={styles.lessonCard}
                    >
                      <div className={styles.lessonCardTop}>
                        <span className={styles.lessonNumber}>
                          {item.sequenceNumber}
                        </span>

                        <div className={styles.lessonStatus}>
                          {item.accessTier === "premium" ? (
                            <span className={styles.premiumBadge}>Premium</span>
                          ) : item.accessTier === "free" ? (
                            <span className={styles.freeBadge}>Free</span>
                          ) : null}
                        </div>
                      </div>

                      <div className={styles.lessonBody}>
                        <h2 className={styles.lessonTitle}>{item.title}</h2>
                        {item.subtitle ? (
                          <p className={styles.lessonSubtitle}>
                            {item.subtitle}
                          </p>
                        ) : null}
                      </div>

                      <span className={styles.lessonTag}>Dialog</span>
                    </Link>
                  ) : (
                    <Link
                      href={`/lessons/${item.slug}`}
                      className={styles.revisionCard}
                    >
                      <div className={styles.revisionTop}>
                        <span className={styles.revisionEyebrow}>Revision</span>

                        <div className={styles.lessonStatus}>
                          {item.accessTier === "premium" ? (
                            <span className={styles.premiumBadge}>Premium</span>
                          ) : item.accessTier === "free" ? (
                            <span className={styles.freeBadge}>Free</span>
                          ) : null}
                        </div>
                      </div>

                      <div className={styles.revisionBody}>
                        <h2 className={styles.revisionTitle}>{item.title}</h2>
                        {item.subtitle ? (
                          <p className={styles.revisionText}>{item.subtitle}</p>
                        ) : (
                          <p className={styles.revisionText}>
                            Review key vocabulary and patterns from previous
                            lessons.
                          </p>
                        )}
                      </div>

                      <span className={styles.revisionMeta}>Checkpoint</span>
                    </Link>
                  )}
                </li>
              ))}
            </ul>
          ) : (
            <div className={styles.emptyState}>
              <h2 className={styles.emptyTitle}>Dialogs</h2>
              <p className={styles.emptyText}>No lessons available yet.</p>
            </div>
          ))}

        {section === "themes" && (
          <div className={styles.emptyState}>
            <h2 className={styles.emptyTitle}>Themes</h2>
            <p className={styles.emptyText}>Themes are coming soon.</p>
          </div>
        )}

        {section === "stories" && (
          <div className={styles.emptyState}>
            <h2 className={styles.emptyTitle}>Stories</h2>
            <p className={styles.emptyText}>Stories are coming soon.</p>
          </div>
        )}

        {section === "practice" && (
          <div className={styles.emptyState}>
            <h2 className={styles.emptyTitle}>Practice</h2>
            <p className={styles.emptyText}>Practice is coming soon.</p>
          </div>
        )}
      </div>
    </section>
  );
}
