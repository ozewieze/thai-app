import Link from "next/link";
import { ChevronLeft, ChevronRight } from "lucide-react";
import styles from "./LessonPageView.module.css";
import type {
  LessonWithDialog,
  LessonNav,
  LessonInstructionalContent,
} from "@/features/lesson/types";
import DialogPlayer from "@/features/lesson/components/dialog-player/DialogPlayer";
import DialogFullSection from "@/features/lesson/components/dialog-full-section/DialogFullSection";
import LessonVocabularySection from "@/features/lesson/components/lesson-vocabulary-section/LessonVocabularySection";
import LanguageNotesSection from "@/features/lesson/components/language-notes-section/LanguageNotesSection";
import { getLevelById } from "@/features/level/lib/getLevelById";

type LessonPageViewProps = {
  lesson: LessonWithDialog;
  lessonNav: LessonNav;
  instructionalContent: LessonInstructionalContent;
};

const REGISTER_LABELS: Record<string, string> = {
  polite: "Polite Thai",
  formal: "Formal Thai",
  informal: "Informal Thai",
  neutral: "Neutral Thai",
  colloquial: "Colloquial Thai",
};

export default function LessonPageView({
  lesson,
  lessonNav,
  instructionalContent,
}: LessonPageViewProps) {
  const levelData = getLevelById(lesson.cefrLevel);
  const backHref = `/learn/${lesson.cefrLevel.toLowerCase()}/${lesson.sectionKey ?? "dialogs"}`;
  const levelTitle = levelData?.title ?? lesson.cefrLevel;
  const registerLabel = lesson.dialog?.register
    ? (REGISTER_LABELS[lesson.dialog.register] ?? null)
    : null;

  return (
    <div className={styles.page}>
      <div className={styles.content}>
        {/* Breadcrumb */}
        <div className={styles.subHeader}>
          <Link href={backHref} className={styles.backLink}>
            <ChevronLeft size={16} />
            Back to {levelTitle}
          </Link>
        </div>

        {/* Lesson header */}
        <div className={styles.lessonHeader}>
          {/* Nav label + titel als een eenheid */}
          <div className={styles.lessonTitleGroup}>
            <div className={styles.lessonNav}>
              {lessonNav.prevSlug ? (
                <Link
                  href={`/lessons/${lessonNav.prevSlug}`}
                  className={styles.lessonNavBtn}
                  aria-label="Previous lesson"
                >
                  <ChevronLeft size={14} />
                </Link>
              ) : (
                <span
                  className={`${styles.lessonNavBtn} ${styles.lessonNavBtnDisabled}`}
                >
                  <ChevronLeft size={14} />
                </span>
              )}
              <span className={styles.lessonNavLabel}>{lesson.title}</span>
              {lessonNav.nextSlug ? (
                <Link
                  href={`/lessons/${lessonNav.nextSlug}`}
                  className={styles.lessonNavBtn}
                  aria-label="Next lesson"
                >
                  <ChevronRight size={14} />
                </Link>
              ) : (
                <span
                  className={`${styles.lessonNavBtn} ${styles.lessonNavBtnDisabled}`}
                >
                  <ChevronRight size={14} />
                </span>
              )}
            </div>

            {lesson.subtitle && (
              <h1 className={styles.lessonTitle}>{lesson.subtitle}</h1>
            )}
          </div>

          {/* Learning focus + register */}
          <div className={styles.lessonMeta}>
            {lesson.dialog?.learningFocus && (
              <p className={styles.learningFocus}>
                <span className={styles.learningFocusLabel}>
                  What you&apos;ll learn
                </span>
                {lesson.dialog.learningFocus}
              </p>
            )}
            {registerLabel && (
              <span className={styles.registerLabel}>{registerLabel}</span>
            )}
          </div>
        </div>

        {/* Slideshow + full-dialog audioplayer (gecombineerd in één client component) */}
        <DialogFullSection
          audioUrl={lesson.dialog?.audioUrl ?? null}
          audioDurationMs={lesson.dialog?.audioDurationMs ?? null}
          slides={lesson.dialog?.slides ?? []}
          imageCardClassName={styles.imageCard}
        />

        {/* Dialog player */}
        {lesson.dialog && lesson.dialog.blocks.length > 0 ? (
          <DialogPlayer blocks={lesson.dialog.blocks} />
        ) : (
          <p>Geen dialog gevonden voor deze lesson.</p>
        )}

        {/*
          Instructiecontent: dialoog -> Vocabulary Cards -> Language Notes.         
        */}
        <LessonVocabularySection
          items={instructionalContent.vocabularyItems}
        />

        <LanguageNotesSection notes={instructionalContent.languageNotes} />
      </div>
    </div>
  );
}
