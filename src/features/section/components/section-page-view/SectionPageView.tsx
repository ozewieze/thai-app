import LevelBadge from "@/components/ui/level-badge/LevelBadge";
import styles from "./SectionPageView.module.css";
import Breadcrumbs from "@/components/ui/breadcrumbs/Breadcrumbs";
import SectionNav from "../section-nav/SectionNav";
import type { Level } from "@/features/curriculum/types";
import type { LevelSectionKey } from "@/features/level/data";
import type { SectionLessonCardItem } from "@/features/curriculum/types";
import DialogsSectionView from "../dialogs-section-view/DialogsSectionView";
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
        {section === "dialogs" ? (
          <DialogsSectionView
            items={sectionItems}
            viewer={viewer}
            emptyTitle={sectionLabels[section]}
            emptyText="No lessons available yet."
          />
        ) : null}
      </div>
    </section>
  );
}
