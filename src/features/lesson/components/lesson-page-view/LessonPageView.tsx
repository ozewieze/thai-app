import type { LessonWithDialog } from "@/features/lesson/types";
import { splitDialogIntoBlocks } from "@/features/lesson/utils";
import DialogPlayer from "@/features/lesson/components/dialog-player/DialogPlayer";

type LessonPageViewProps = {
  lesson: LessonWithDialog;
};

export default function LessonPageView({ lesson }: LessonPageViewProps) {
  const blocks = lesson.dialog ? splitDialogIntoBlocks(lesson.dialog) : [];

  return (
    <div style={{ maxWidth: "720px", margin: "0 auto", padding: "2rem" }}>
      <h1>{lesson.title}</h1>
      {lesson.subtitle && <p>{lesson.subtitle}</p>}

      <div style={{ marginTop: "2rem" }}>
        {blocks.length > 0 ? (
          <DialogPlayer blocks={blocks} />
        ) : (
          <p>Geen dialog gevonden voor deze lesson.</p>
        )}
      </div>
    </div>
  );
}
