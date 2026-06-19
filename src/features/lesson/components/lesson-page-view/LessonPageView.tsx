import type { LessonWithDialog } from "@/features/lesson/types";
import { splitDialogIntoBlocks } from "@/features/lesson/utils";
import DialogBlock from "@/features/lesson/components/dialog-block/DialogBlock";

type LessonPageViewProps = {
  lesson: LessonWithDialog;
};

export default function LessonPageView({ lesson }: LessonPageViewProps) {
  const blocks = lesson.dialog ? splitDialogIntoBlocks(lesson.dialog) : [];
  const firstBlock = blocks[0] ?? null;

  return (
    <div style={{ maxWidth: "720px", margin: "0 auto", padding: "2rem" }}>
      <h1>{lesson.title}</h1>
      {lesson.subtitle && <p>{lesson.subtitle}</p>}

      <div style={{ marginTop: "2rem" }}>
        {firstBlock ? (
          <DialogBlock block={firstBlock} totalBlocks={blocks.length} />
        ) : (
          <p>Geen dialog gevonden voor deze lesson.</p>
        )}
      </div>
    </div>
  );
}
