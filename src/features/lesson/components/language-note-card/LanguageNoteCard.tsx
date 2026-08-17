import { Fragment } from "react";
import styles from "./LanguageNoteCard.module.css";
import type { LanguageNote } from "@/features/lesson/types";
import LanguageNoteBlock from "../language-note-block/LanguageNoteBlock";

/**
 * LanguageNoteCard
 *
 * Server Component. Rendert één Language Note: een titel plus de
 * geordende blokken. Het `id` (`note-<id>`) dient als anchor-doel voor
 * ConceptNavigation.
 *
 * Sectiescheiding conform mijn Figma: vóór een `subheading` of
 * `example_group` (behalve als het het eerste blok is) komt een dunne
 * divider, zodat "intro / uitleg / voorbeelden" visueel losse secties
 * worden zonder lijnen tussen losse paragrafen.
 */
type LanguageNoteCardProps = {
  note: LanguageNote;
};

export default function LanguageNoteCard({ note }: LanguageNoteCardProps) {
  return (
    <article id={`note-${note.id}`} className={styles.card}>
      <h3 className={styles.title}>{note.title}</h3>
      <div className={styles.body}>
        {note.blocks.map((block, index) => {
          const startsNewSection =
            index > 0 &&
            (block.blockType === "subheading" ||
              block.blockType === "example_group");

          return (
            <Fragment key={index}>
              {startsNewSection && <hr className={styles.divider} />}
              <LanguageNoteBlock block={block} />
            </Fragment>
          );
        })}
      </div>
    </article>
  );
}
