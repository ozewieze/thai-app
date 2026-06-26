import Link from "next/link";
import { Play, ChevronLeft, ChevronRight } from "lucide-react";
import styles from "./LessonPageView.module.css";
import type { LessonWithDialog, LessonNav } from "@/features/lesson/types";
import DialogPlayer from "@/features/lesson/components/dialog-player/DialogPlayer";
import { getLevelById } from "@/features/level/lib/getLevelById";

type LessonPageViewProps = {
  lesson: LessonWithDialog;
  lessonNav: LessonNav;
};

const REGISTER_LABELS: Record<string, string> = {
  polite: "Polite Thai",
  formal: "Formal Thai",
  informal: "Informal Thai",
  neutral: "Neutral Thai",
  colloquial: "Colloquial Thai",
};

export default function LessonPageView({ lesson, lessonNav }: LessonPageViewProps) {
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

          {/* Nav label + titel als één eenheid */}
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
                <span className={`${styles.lessonNavBtn} ${styles.lessonNavBtnDisabled}`}>
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
                <span className={`${styles.lessonNavBtn} ${styles.lessonNavBtnDisabled}`}>
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
                <span className={styles.learningFocusLabel}>What you&apos;ll learn</span>
                {lesson.dialog.learningFocus}
              </p>
            )}
            {registerLabel && (
              <span className={styles.registerLabel}>{registerLabel}</span>
            )}
          </div>

        </div>

        {/* Image */}
        <div className={styles.imageCard}>
          Illustration coming soon
        </div>

        {/* Audio player placeholder */}
        <div className={styles.audioCard}>
          <button className={styles.audioPlayBtn} disabled aria-label="Play full dialogue">
            <Play size={16} fill="currentColor" />
          </button>
          <div className={styles.audioMeta}>
            <span className={styles.audioLabel}>Full Dialogue</span>
            <div className={styles.audioTrack}>
              <div className={styles.audioTrackFill} />
            </div>
          </div>
          <span className={styles.audioTime}>0:00 / --:--</span>
        </div>

        {/* Dialog player */}
        {lesson.dialog && lesson.dialog.blocks.length > 0 ? (
          <DialogPlayer blocks={lesson.dialog.blocks} />
        ) : (
          <p>Geen dialog gevonden voor deze lesson.</p>
        )}

      </div>
    </div>
  );
}
