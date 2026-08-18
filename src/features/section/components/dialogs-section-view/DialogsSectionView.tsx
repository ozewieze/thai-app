import Link from "next/link";
import styles from "./DialogsSectionView.module.css";
import type { SectionLessonCardItem } from "@/features/curriculum/types";
import LessonCompletionButton from "../lesson-completion-button/LessonCompletionButton";
import PremiumBadge from "@/features/level/section/premium-badge/PremiumBadge";
import { isLessonLocked } from "@/features/section/lib/isLessonLocked";

type Viewer = { plan: "free" | "premium" } | null;

type DialogsSectionViewProps = {
  items: SectionLessonCardItem[];
  viewer: Viewer;
  emptyTitle: string;
  emptyText: string;
};

export default function DialogsSectionView({
  items,
  viewer,
  emptyTitle,
  emptyText,
}: DialogsSectionViewProps) {
  if (items.length === 0) {
    return (
      <div className={styles.emptyState}>
        <h2 className={styles.emptyTitle}>{emptyTitle}</h2>
        <p className={styles.emptyText}>{emptyText}</p>
      </div>
    );
  }

  return (
    <ul className={styles.grid} role="list">
      {items.map((item) => {
        const isLocked = isLessonLocked(item, viewer);
        const isRevision = item.lessonType === "revision";

        // Twee verschillende redenen om een kaart niet aanklikbaar te maken,
        // bewust apart gehouden omdat ze een andere badge krijgen:
        //
        //   isLocked   -- premium content, de bezoeker mag er (nog) niet bij
        //   isRevision -- een revisieles heeft nog geen eigen pagina-indeling.
        //                 LessonPageView toont het dialoogvenster, en een
        //                 revisie heeft geen dialoog maar oefeningen. Tot die
        //                 indeling bestaat, leidt de link naar een pagina die
        //                 "Geen dialog gevonden" toont. Kaart wel tonen, niet
        //                 laten aanklikken.
        //
        // Zodra de revisiepagina er is, verdwijnt isRevision hier weer en
        // blijft alleen isLocked over.
        const isInert = isLocked || isRevision;

        return (
          <li key={item.lessonKey} className={styles.gridItem}>
            <article
              className={isRevision ? styles.revisionCard : styles.lessonCard}
            >
              <div
                className={
                  isRevision ? styles.revisionTop : styles.lessonCardTop
                }
              >
                <span className={styles.lessonNumber}>
                  {item.sequenceNumber}
                </span>

                {/*
                  Volgorde is niet vrij: de premium-revisie is zowel premium
                  als revisie. isLocked staat eerst, zodat die het kroontje
                  krijgt en niet het "Coming soon"-label.
                */}
                {isLocked ? (
                  <PremiumBadge />
                ) : isRevision ? (
                  <span className={styles.comingSoonBadge}>Coming soon</span>
                ) : (
                  <LessonCompletionButton lessonTitle={item.title} comingSoon />
                )}
              </div>

              <div
                className={isRevision ? styles.revisionBody : styles.lessonBody}
              >
                <h2
                  className={
                    isRevision ? styles.revisionTitle : styles.lessonTitle
                  }
                >
                  {/*
                    cardMainLink heeft een ::after die de hele kaart afdekt,
                    zodat je overal op de kaart kunt klikken. Die overlay hoort
                    niet op een inerte kaart -- vandaar cardMainText, dezelfde
                    typografie zonder het klikvlak.
                  */}
                  {isInert ? (
                    <span className={styles.cardMainText}>{item.title}</span>
                  ) : (
                    <Link
                      href={`/lessons/${item.slug}`}
                      className={styles.cardMainLink}
                    >
                      {item.title}
                    </Link>
                  )}
                </h2>

                {item.subtitle ? (
                  <p
                    className={
                      isRevision ? styles.revisionText : styles.lessonSubtitle
                    }
                  >
                    {item.subtitle}
                  </p>
                ) : isRevision ? (
                  <p className={styles.revisionText}>
                    Review key vocabulary and patterns from previous lessons.
                  </p>
                ) : null}
              </div>
            </article>
          </li>
        );
      })}
    </ul>
  );
}
