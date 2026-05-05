import styles from "./LevelBadge.module.css";

type LevelBadgeSize = "sm" | "md" | "lg";

type LevelBadgeProps = {
  levelId: string;
  size?: LevelBadgeSize;
  className?: string;
};

export default function LevelBadge({
  levelId,
  size = "sm",
  className,
}: LevelBadgeProps) {
  const classes = [styles.levelBadge, styles[size], className]
    .filter(Boolean)
    .join(" ");

  return <span className={classes}>{levelId}</span>;
}
