import { Lightbulb } from "lucide-react";
import styles from "./LanguageNoteBlock.module.css";
import type { LanguageNoteBlock as Block } from "@/features/lesson/types";
import ExampleList from "../example-list/ExampleList";

/**
 * LanguageNoteBlock
 *
 * Server Component. Rendert één blok van een Language Note op basis van
 * `blockType`. De `switch` handelt alle vijf bloktypes af (de compiler
 * dwingt dat af via de discriminated union).
 *
 * Visibility-architectuur: alleen de voorbeeldregels binnen een
 * example_group (via ExampleList) dragen `data-study-layer`. Subheadings,
 * paragrafen, formules en tips krijgen dat NIET en blijven dus altijd
 * zichtbaar.
 */
type LanguageNoteBlockProps = {
  block: Block;
};

export default function LanguageNoteBlock({ block }: LanguageNoteBlockProps) {
  switch (block.blockType) {
    case "subheading":
      return <h4 className={styles.subheading}>{block.content}</h4>;

    case "paragraph":
      return (
        <div className={styles.paragraph}>
          {block.content.split("\n\n").map((para, i) => (
            <p key={i} className={styles.paragraphText}>
              {para}
            </p>
          ))}
        </div>
      );

    case "formula":
      return <p className={styles.formula}>{block.content}</p>;

    case "usage_tip":
      return (
        <div className={styles.usageTip}>
          <Lightbulb
            size={16}
            className={styles.usageTipIcon}
            aria-hidden="true"
          />
          <p className={styles.usageTipText}>{block.content}</p>
        </div>
      );

    case "example_group":
      return (
        <div className={styles.exampleGroup}>
          {block.heading && (
            <h4 className={styles.exampleHeading}>{block.heading}</h4>
          )}
          {block.intro && <p className={styles.exampleIntro}>{block.intro}</p>}
          <ExampleList examples={block.examples} />
        </div>
      );
  }
}
