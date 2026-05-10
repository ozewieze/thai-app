import Link from "next/link";
import LevelBadge from "@/components/ui/level-badge/LevelBadge";
import { levelSectionData } from "@/features/level/data";
import styles from "./SectionPageView.module.css";
import Breadcrumbs from "@/components/ui/breadcrumbs/Breadcrumbs";
import SectionNav from "../section-nav/SectionNav";

type LevelData = {
  id: string;
  title: string;
  description: string;
};

type SectionsForLevel =
  (typeof levelSectionData)[keyof typeof levelSectionData];

type SectionPageViewProps = {
  level: string;
  section: "dialogs" | "themes" | "stories" | "practice";
  levelData: LevelData;
  sectionsForLevel: SectionsForLevel;
  sectionLabels: Record<string, string>;
};

export default function SectionPageView({
  level,
  section,
  levelData,
  sectionsForLevel,
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
      {/* <nav className={styles.sectionNav} aria-label="Level sections">
        <div className={styles.sectionNavScroller}>
          <ul className={styles.sectionNavList}>
            {Object.entries(sectionLabels).map(([key, label]) => {
              const href = `/learn/${level}/${key}`;
              const isActive = section === key;

              return (
                <li key={key} className={styles.sectionNavItem}>
                  <Link
                    href={href}
                    className={
                      isActive ? styles.sectionLinkActive : styles.sectionLink
                    }
                    aria-current={isActive ? "page" : undefined}
                  >
                    {label}
                  </Link>
                </li>
              );
            })}
          </ul>
        </div>
      </nav> */}
      <SectionNav
        level={level}
        section={section}
        sectionLabels={sectionLabels}
      />

      <div className={styles.content}>
        {section === "dialogs" && (
          <ul className={styles.grid} role="list">
            {sectionsForLevel.dialogs.map((item) => (
              <li key={item.id}>
                {item.type === "dialog" ? (
                  <Link
                    href={`/lessons/${item.slug}`}
                    className={styles.lessonCard}
                  >
                    <div className={styles.lessonCardTop}>
                      <span className={styles.lessonNumber}>{item.number}</span>

                      <div className={styles.lessonStatus}>
                        {item.access === "premium" ? (
                          <span className={styles.premiumBadge}>Premium</span>
                        ) : item.access === "free" ? (
                          <span className={styles.freeBadge}>Free</span>
                        ) : null}
                      </div>
                    </div>

                    <div className={styles.lessonBody}>
                      <h2 className={styles.lessonTitle}>{item.title}</h2>
                      <p className={styles.lessonSubtitle}>{item.subtitle}</p>
                    </div>

                    <span className={styles.lessonTag}>{item.label}</span>
                  </Link>
                ) : (
                  <Link
                    href={`/lessons/${item.slug}`}
                    className={styles.revisionCard}
                  >
                    <div className={styles.revisionTop}>
                      <span className={styles.revisionEyebrow}>Revision</span>
                    </div>

                    <div className={styles.revisionBody}>
                      <h2 className={styles.revisionTitle}>
                        {item.rangeLabel}
                      </h2>
                      <p className={styles.revisionText}>
                        Review key vocabulary and patterns from the previous
                        lessons.
                      </p>
                    </div>

                    <span className={styles.revisionMeta}>
                      {item.exerciseCount} exercises
                    </span>
                  </Link>
                )}
              </li>
            ))}
          </ul>
        )}

        {section === "themes" && (
          <ul className={styles.grid} role="list">
            {sectionsForLevel.themes.map((theme) => (
              <li key={theme.id}>
                <Link
                  href={`/lessons/${theme.slug}`}
                  className={styles.themeCard}
                >
                  <div className={styles.themeCardTop}>
                    {theme.access === "premium" ? (
                      <span className={styles.premiumBadge}>Premium</span>
                    ) : theme.access === "free" ? (
                      <span className={styles.freeBadge}>Free</span>
                    ) : null}
                  </div>

                  <div className={styles.themeBody}>
                    <h2 className={styles.themeTitle}>{theme.title}</h2>
                    <p className={styles.themeText}>{theme.description}</p>
                  </div>

                  <span className={styles.themeTag}>{theme.label}</span>
                </Link>
              </li>
            ))}
          </ul>
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
