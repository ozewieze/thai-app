import type { LessonWithDialog } from "@/features/lesson/types";

type LessonPageViewProps = {
  lesson: LessonWithDialog;
};

/**
 * LessonPageView
 *
 * Tijdelijke weergave om te verifiëren dat de data correct binnenkomt.
 * We vervangen deze ruwe tekst stap voor stap door de echte UI.
 */
export default function LessonPageView({ lesson }: LessonPageViewProps) {
  return (
    <div style={{ padding: "2rem", fontFamily: "monospace" }}>
      <h1>{lesson.title}</h1>
      {lesson.subtitle && <p>{lesson.subtitle}</p>}

      <hr style={{ margin: "1rem 0" }} />

      <p>
        <strong>Level:</strong> {lesson.cefrLevel}
      </p>
      <p>
        <strong>Type:</strong> {lesson.lessonType}
      </p>
      <p>
        <strong>Slug:</strong> {lesson.slug}
      </p>

      <hr style={{ margin: "1rem 0" }} />

      {lesson.dialog ? (
        <div>
          <h2>Dialog data ✓</h2>
          {lesson.dialog.title && (
            <p>
              <strong>Dialog title:</strong> {lesson.dialog.title}
            </p>
          )}
          <p>
            <strong>Thai text:</strong>
          </p>
          <pre style={{ whiteSpace: "pre-wrap" }}>{lesson.dialog.thaiText}</pre>

          {lesson.dialog.transliteration && (
            <>
              <p>
                <strong>Transliteration:</strong>
              </p>
              <pre style={{ whiteSpace: "pre-wrap" }}>
                {lesson.dialog.transliteration}
              </pre>
            </>
          )}

          {lesson.dialog.translationEn && (
            <>
              <p>
                <strong>English:</strong>
              </p>
              <pre style={{ whiteSpace: "pre-wrap" }}>
                {lesson.dialog.translationEn}
              </pre>
            </>
          )}
        </div>
      ) : (
        <p style={{ color: "red" }}>
          ⚠ Geen dialog gevonden voor deze lesson.
        </p>
      )}
    </div>
  );
}
