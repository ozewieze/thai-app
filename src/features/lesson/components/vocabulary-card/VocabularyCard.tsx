import styles from "./VocabularyCard.module.css";
import type { VocabularyItem } from "@/features/lesson/types";
import ExampleList from "../example-list/ExampleList";

/**
 * VocabularyCard
 *
 * Presentational Server Component. Toont één woord: het lemma
 * (thai/paiboon/engels), optionele meta (woordsoort, register,
 * usage-note) en de canonieke voorbeelden.
 *
 * Leesvoorkeur: alleen de paiboon (transliteratie) draagt
 * `data-study-layer="transliteration"` en volgt zo de "Show
 * transliteration"-toggle. Thai-script en Engelse gloss blijven altijd
 * zichtbaar.
 *
 * De lemma-audioknop volgt in stap 2.7.
 */
type VocabularyCardProps = {
  item: VocabularyItem;
};

export default function VocabularyCard({ item }: VocabularyCardProps) {
  const { master, examples } = item;
  const metaParts = [master.partOfSpeech, master.register].filter(Boolean);// optioneel, dus filteren we lege strings weg

  return (
    <article className={styles.card}>
      <header className={styles.lemma}>
        <p className={styles.lemmaLine}>
          <span className={styles.thai} lang="th">
            {master.thaiScript}
          </span>
          {master.paiboon && (
            <span
              className={styles.paiboon}
              data-study-layer="transliteration"
            >
              {master.paiboon}
            </span>
          )}
        </p>
        <p className={styles.gloss}>{master.englishGloss}</p>
        {metaParts.length > 0 && (
          <p className={styles.meta}>{metaParts.join(" · ")}</p>
        )}
      </header>

      {master.usageNote && <p className={styles.usageNote}>{master.usageNote}</p>}

      <ExampleList examples={examples} />
    </article>
  );
}
