import { Languages } from "lucide-react";
import styles from "./LessonVocabularySection.module.css";
import type { VocabularyItem } from "@/features/lesson/types";
import VocabularyCard from "../vocabulary-card/VocabularyCard";
import SectionHeading from "../section-heading/SectionHeading";

/**
 * LessonVocabularySection
 *
 * Server Component. Rendert de Vocabulary Cards van een les.
 *
 * Lege-staat-regel: een sectie zonder items wordt
 * VOLLEDIG weggelaten, inclusief kop — geen "No vocabulary yet".
 */
type LessonVocabularySectionProps = {
  items: VocabularyItem[];
};

export default function LessonVocabularySection({
  items,
}: LessonVocabularySectionProps) {
  if (items.length === 0) return null;

  return (
    <section className={styles.section} aria-labelledby="vocabulary-heading">
      <SectionHeading icon={<Languages size={20} />} id="vocabulary-heading">
        Vocabulary
      </SectionHeading>
      <div className={styles.cards}>
        {items.map((item) => (
          <VocabularyCard key={item.id} item={item} />
        ))}
      </div>
    </section>
  );
}
