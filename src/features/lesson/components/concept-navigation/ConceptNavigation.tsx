import styles from "./ConceptNavigation.module.css";
import type { LanguageNote } from "@/features/lesson/types";

/**
 * ConceptNavigation
 *
 * Server Component: gewone anchorlinks naar de Language Notes,
 * géén client-side scroll-logica. Wordt alleen getoond bij twee of meer
 * notes — bij één note voegt een inhoudsopgave niets toe.
 */
type ConceptNavigationProps = {
  notes: LanguageNote[];
};

export default function ConceptNavigation({ notes }: ConceptNavigationProps) {
  if (notes.length < 2) return null;

  return (
    <nav className={styles.nav} aria-label="Language notes in this lesson">
      <ul className={styles.list}>
        {notes.map((note) => (
          <li key={note.id}>
            <a href={`#note-${note.id}`} className={styles.link}>
              {note.title}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}
