import Link from "next/link";
import styles from "./SectionNav.module.css";

type SectionNavProps = {
  level: string;
  section: "dialogs" | "themes" | "stories" | "practice";
  sectionLabels: Record<string, string>;
};
export default function SectionNav({
  level,
  section,
  sectionLabels,
}: SectionNavProps) {
  return (
    <nav className={styles.sectionNav} aria-label="Level sections">
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
    </nav>
  );
}
