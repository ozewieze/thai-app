import Link from "next/link";
import { Play, ChevronLeft } from "lucide-react";
import styles from "./LessonPageView.module.css";
import type { LessonWithDialog } from "@/features/lesson/types";
import { splitDialogIntoBlocks } from "@/features/lesson/utils";
import DialogPlayer from "@/features/lesson/components/dialog-player/DialogPlayer";
import { getLevelById } from "@/features/level/lib/getLevelById";

type LessonPageViewProps = {
  lesson: LessonWithDialog;
};

const REGISTER_LABELS: Record<string, string> = {
  polite: "Polite Thai",
  formal: "Formal Thai",
  informal: "Informal Thai",
  neutral: "Neutral Thai",
  colloquial: "Colloquial Thai",
};

export default function LessonPageView({ lesson }: LessonPageViewProps) {
  const blocks = lesson.dialog ? splitDialogIntoBlocks(lesson.dialog) : [];
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
          {registerLabel && (
            <span className={styles.registerLabel}>{registerLabel}</span>
          )}
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
        {blocks.length > 0 ? (
          <DialogPlayer blocks={blocks} />
        ) : (
          <p>Geen dialog gevonden voor deze lesson.</p>
        )}

      </div>
    </div>
  );
}
