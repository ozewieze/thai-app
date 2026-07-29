import styles from "./loading.module.css";

/**
 * Loading (route-level skeleton)
 *
 * Fallback van de Suspense-boundary die Next rond page.tsx zet. Verschijnt
 * meteen bij navigatie terwijl de server de les-, nav- en instructiecontent-
 * query's afwerkt. Server Component; puur presentational.
 */
export default function Loading() {
  return (
    <div className={styles.wrap} aria-busy="true" aria-live="polite">
      <span className={styles.srOnly}>Loading lesson…</span>

      <div className={`${styles.pulse} ${styles.crumb}`} />
      <div className={`${styles.pulse} ${styles.title}`} />
      <div className={`${styles.pulse} ${styles.media}`} />
      <div className={`${styles.pulse} ${styles.card}`} />
      <div className={`${styles.pulse} ${styles.card}`} />
    </div>
  );
}
