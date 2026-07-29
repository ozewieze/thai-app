import styles from "./ExampleList.module.css";
import type { ExampleLine } from "@/features/lesson/types";
import AudioButton from "@/components/ui/audio-button/AudioButton";

/**
 * ExampleList
 *
 * Server Component. Rendert een lijst voorbeeldzinnen als drieluik
 * (thai / transliteratie / engels). Gedeeld door VocabularyCard en
 * de example_group-blokken van Language Notes: beide bronnen
 * mappen naar hetzelfde ExampleLine-type.
 */
type ExampleListProps = {
  examples: ExampleLine[];
};

export default function ExampleList({ examples }: ExampleListProps) {
  if (examples.length === 0) return null;

  return (
    <ul className={styles.list}>
      {examples.map((example) => (
        <li key={example.id} className={styles.item}>
          <AudioButton audioUrl={example.audioUrl} label={example.thaiLine} />
          <div className={styles.lines}>
            <p className={styles.thai} lang="th">
              {example.thaiLine}
            </p>
            <p className={styles.translit} data-study-layer="transliteration">
              {example.transliterationLine}
            </p>
            <p className={styles.english}>{example.translationLine}</p>
          </div>
        </li>
      ))}
    </ul>
  );
}
