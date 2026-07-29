"use client";

import { useEffect } from "react";
import styles from "./error.module.css";

/**
 * Error (route-level error boundary)
 *
 * Vangt fouten in dit route-segment op (data-fetching of rendering) en
 * houdt de app-shell intact. Moet een Client Component zijn — React error
 * boundaries werken alleen client-side. `reset()` probeert het segment
 * opnieuw te renderen.
 */
type ErrorProps = {
  error: Error & { digest?: string };
  reset: () => void;
};

export default function LessonError({ error, reset }: ErrorProps) {
  useEffect(() => {
    // Log voor diagnose; `digest` correleert met de server-log.
    console.error(error);
  }, [error]);

  return (
    <div className={styles.wrap} role="alert">
      <h1 className={styles.title}>Something went wrong</h1>
      <p className={styles.text}>
        This lesson couldn&apos;t be loaded. Please try again.
      </p>
      <button type="button" className={styles.button} onClick={reset}>
        Try again
      </button>
    </div>
  );
}
