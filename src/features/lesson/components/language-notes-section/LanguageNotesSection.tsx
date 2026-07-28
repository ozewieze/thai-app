import { BookOpen } from "lucide-react";
import styles from "./LanguageNotesSection.module.css";
import type { LanguageNote } from "@/features/lesson/types";
import SectionHeading from "../section-heading/SectionHeading";
import ConceptNavigation from "../concept-navigation/ConceptNavigation";
import LanguageNoteCard from "../language-note-card/LanguageNoteCard";

/**
 * LanguageNotesSection
 *
 * Server Component. Rendert de Language Notes van een les: sectiekop,
 * optionele conceptnavigatie (bij >= 2 notes) en de note-kaarten.
 *
 * Lege-staat-regel: geen notes -> sectie volledig weglaten, inclusief
 * kop.
 */
type LanguageNotesSectionProps = {
  notes: LanguageNote[];
};

export default function LanguageNotesSection({
  notes,
}: LanguageNotesSectionProps) {
  if (notes.length === 0) return null;

  return (
    <section className={styles.section} aria-labelledby="language-notes-heading">
      <SectionHeading icon={<BookOpen size={20} />} id="language-notes-heading">
        Language Notes
      </SectionHeading>
      <ConceptNavigation notes={notes} />
      <div className={styles.cards}>
        {notes.map((note) => (
          <LanguageNoteCard key={note.id} note={note} />
        ))}
      </div>
    </section>
  );
}
