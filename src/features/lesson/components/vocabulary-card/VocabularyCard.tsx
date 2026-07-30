import { StickyNote } from "lucide-react";
import styles from "./VocabularyCard.module.css";
import type { VocabularyItem } from "@/features/lesson/types";
import ExampleList from "../example-list/ExampleList";
import AudioButton from "@/components/ui/audio-button/AudioButton";

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
 * De lemma-audioknop (AudioButton) staat links van het woord; `audioUrl`
 * kan null zijn (nog geen audio) -> knop disabled.
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
        <AudioButton audioUrl={master.audioUrl} label={master.thaiScript} />
        <div className={styles.lemmaText}>
          <p className={styles.lemmaLine}>
            <span className={styles.thai} lang="th">
              {master.thaiScript}
            </span>
            {metaParts.length > 0 && (
              <span className={styles.meta}>{metaParts.join(" · ")}</span>
            )}
          </p>
          {master.paiboon && (
            <p className={styles.paiboon} data-study-layer="transliteration">
              {master.paiboon}
            </p>
          )}
          <p className={styles.gloss}>{master.englishGloss}</p>
        </div>
      </header>

      {master.usageNote && (
        <p className={styles.usageNote}>
          <StickyNote
            size={14}
            className={styles.usageNoteIcon}
            aria-hidden="true"
          />
          {master.usageNote}
        </p>
      )}

      <ExampleList examples={examples} />
    </article>
  );
}
