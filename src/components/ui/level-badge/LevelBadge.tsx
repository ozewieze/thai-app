import styles from "./LevelBadge.module.css";

type LevelBadgeSize = "sm" | "md" | "lg";

type LevelBadgeProps = {
  levelId: string;
  size?: LevelBadgeSize;
  responsive?: boolean;
  className?: string;
};

export default function LevelBadge({
  levelId,
  size = "sm",
  responsive,
  className,
}: LevelBadgeProps) {
  const sizeClass = responsive ? styles["responsive-size"] : styles[size];

  const classes = [styles.levelBadge, sizeClass, className]
    .filter(Boolean)
    .join(" ");

  return <span className={classes}>{levelId}</span>;
}
