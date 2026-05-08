// import { getLevelById } from "@/features/level/lib/getLevelById";
// import { notFound } from "next/navigation";
// import LevelBadge from "@/components/ui/level-badge/LevelBadge";
// import Link from "next/link";
// import { levelSectionData, isLevelSectionKey } from "@/features/level/data";

// type PageProps = { params: Promise<{ level: string; section: string }> };

// export default async function LevelSectionPage({ params }: PageProps) {
//   const { level, section } = await params;
//   const levelData = getLevelById(level);

//   if (!levelData) {
//     notFound();
//   }

//   const sectionsForLevel =
//     levelSectionData[level as keyof typeof levelSectionData];

//   if (!sectionsForLevel || !isLevelSectionKey(section)) {
//     notFound();
//   }

//   return (
//     <>
//       <LevelBadge levelId={levelData.id} size="lg" />
//       <h1>{levelData.title}</h1>
//       <p>{levelData.description}</p>

//       <nav aria-label="Level sections">
//         <ul>
//           <li>
//             <Link href={`/learn/${level}/dialogs`}>Dialogs</Link>
//           </li>
//           <li>
//             <Link href={`/learn/${level}/themes`}>Themes</Link>
//           </li>
//           <li>
//             <Link href={`/learn/${level}/stories`}>Stories</Link>
//           </li>
//           <li>
//             <Link href={`/learn/${level}/practice`}>Practice</Link>
//           </li>
//         </ul>
//       </nav>

//       <div>
//         {/* TODO routes nog aanpassen, ik ga niet verder nesten */}
//         {section === "dialogs" && (
//           <ul>
//             {sectionsForLevel.dialogs.map((item) => (
//               <li key={item.id}>
//                 {item.type === "dialog" ? (
//                   <Link href={`/learn/${level}/dialogs/${item.slug}`}>
//                     <p>{item.number}</p>
//                     <h2>{item.title}</h2>
//                     <p>{item.subtitle}</p>
//                     <span>{item.label}</span>
//                   </Link>
//                 ) : (
//                   <Link href={`/learn/${level}/practice/${item.slug}`}>
//                     <h2>{item.title}</h2>
//                     <p>{item.rangeLabel}</p>
//                     <p>{item.exerciseCount} exercises</p>
//                   </Link>
//                 )}
//               </li>
//             ))}
//           </ul>
//         )}

//         {section === "themes" && (
//           <ul>
//             {sectionsForLevel.themes.map((theme) => (
//               <li key={theme.id}>
//                 <Link href={`/learn/${level}/themes/${theme.slug}`}>
//                   <h2>{theme.title}</h2>
//                   <p>{theme.description}</p>
//                   <span>{theme.label}</span>
//                 </Link>
//               </li>
//             ))}
//           </ul>
//         )}
//       </div>
//     </>
//   );
// }
import Link from "next/link";
import { notFound } from "next/navigation";
import LevelBadge from "@/components/ui/level-badge/LevelBadge";
import { getLevelById } from "@/features/level/lib/getLevelById";
import { isLevelSectionKey, levelSectionData } from "@/features/level/data";
import styles from "./LevelSectionPage.module.css";

type PageProps = {
  params: Promise<{ level: string; section: string }>;
};

const sectionLabels = {
  dialogs: "Dialogs",
  themes: "Themes",
  stories: "Stories",
  practice: "Practice",
} as const;

export default async function LevelSectionPage({ params }: PageProps) {
  const { level, section } = await params;
  const levelData = getLevelById(level);

  if (!levelData) {
    notFound();
  }

  const sectionsForLevel =
    levelSectionData[level as keyof typeof levelSectionData];

  if (!sectionsForLevel || !isLevelSectionKey(section)) {
    notFound();
  }

  return (
    <section className={styles.page} aria-labelledby="level-title">
      <div className={styles.hero}>
        <nav className={styles.breadcrumbs} aria-label="Breadcrumb">
          <ol className={styles.breadcrumbList}>
            <li className={styles.breadcrumbItem}>
              <Link href="/levels" className={styles.breadcrumbLink}>
                Levels
              </Link>
            </li>
            <li className={styles.breadcrumbItem}>
              <Link
                href={`/learn/${level}/dialogs`}
                className={styles.breadcrumbLink}
              >
                {levelData.id}
              </Link>
            </li>
            <li className={styles.breadcrumbItem}>
              <span aria-current="page" className={styles.breadcrumbCurrent}>
                {sectionLabels[section]}
              </span>
            </li>
          </ol>
        </nav>

        <div className={styles.header}>
          <LevelBadge levelId={levelData.id} size="lg" />
          <div className={styles.headerText}>
            <h1 id="level-title" className={styles.title}>
              {levelData.title}
            </h1>
            <p className={styles.description}>{levelData.description}</p>
          </div>
        </div>
      </div>

      <nav className={styles.sectionNav} aria-label="Level sections">
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
      </nav>
      {/* TODO routes nog aanpassen, ik ga niet verder nesten */}
      <div className={styles.content}>
        {section === "dialogs" && (
          <ul className={styles.grid} role="list">
            {sectionsForLevel.dialogs.map((item) => (
              <li key={item.id}>
                {item.type === "dialog" ? (
                  <Link
                    href={`/learn/${level}/dialogs/${item.slug}`}
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
                    href={`/learn/${level}/practice/${item.slug}`}
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
                  href={`/learn/${level}/themes/${theme.slug}`}
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
