"use client";

import styles from "./LessonCompletionButton.module.css";
import { Check } from "lucide-react";
import { useId } from "react";

type LessonCompletionButtonProps = {
  lessonTitle: string;
  isCompleted?: boolean;
  comingSoon?: boolean;
};

export default function LessonCompletionButton({
  lessonTitle,
  isCompleted = true,
  comingSoon = true,
}: LessonCompletionButtonProps) {
  const actionLabel = isCompleted
    ? `Marked as completed: ${lessonTitle}`
    : `Mark as completed: ${lessonTitle}`;

  const tooltipId = useId();

  return (
    <button
      type="button"
      className={`${styles.completeButton} ${
        isCompleted ? styles.isCompleted : ""
      } ${comingSoon ? styles.isComingSoon : ""}`}
      aria-pressed={isCompleted}
      aria-label={comingSoon ? `${actionLabel}. Coming soon.` : actionLabel}
      aria-describedby={tooltipId}
      //   title={isCompleted ? "Marked as completed" : "Mark as completed"}
      onClick={(event) => {
        if (comingSoon) {
          event.preventDefault();
          event.stopPropagation();
          return;
        }

        // TODO: connect to persisted user lesson completion state
      }}
    >
      <span className={styles.rings} aria-hidden="true">
        <span className={styles.outerCircle}>
          <span className={styles.innerCircle}>
            <Check className={styles.checkIcon} />
          </span>
        </span>
      </span>

      <span id={tooltipId} className={styles.tooltip}>
        {isCompleted ? "Marked as completed" : "Mark as completed"}
      </span>
    </button>
  );
}
