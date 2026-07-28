import styles from "./SectionHeading.module.css";

/**
 * SectionHeading
 *
 * Gedeelde, gecentreerde sectiekop met ronde icoon-badge, conform de
 * Figma-stijl. Gebruikt door de instructiesecties (Vocabulary Cards,
 * Language Notes). Server Component — puur presentational.
 *
 * `id` wordt op de <h2> gezet zodat secties via aria-labelledby en
 * (bij Language Notes) via anchorlinks bereikbaar zijn.
 */
type SectionHeadingProps = {
  icon: React.ReactNode;
  id?: string;
  children: React.ReactNode;
};

export default function SectionHeading({
  icon,
  id,
  children,
}: SectionHeadingProps) {
  return (
    <div className={styles.wrap}>
      <span className={styles.badge} aria-hidden="true">
        {icon}
      </span>
      <h2 id={id} className={styles.heading}>
        {children}
      </h2>
    </div>
  );
}
