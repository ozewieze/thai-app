import Link from "next/link";
import { ArrowRight } from "lucide-react";
import styles from "./LevelCard.module.css";
import { CtaLabelMode, Level } from "@/features/curriculum/types";
import LevelBadge from "@/components/ui/level-badge/LevelBadge";
type LevelCardProps = {
  level: Level;
  ctaLabelMode?: CtaLabelMode;
};

export default function LevelCard({
  level,
  ctaLabelMode = "generic",
}: LevelCardProps) {
  const ctaLabel =
    ctaLabelMode === "level" ? `Start ${level.id}` : "Start learning";

  return (
    <Link href={`/learn/${level.id.toLowerCase()}`} className={styles.card}>
      <LevelBadge levelId={level.id} />

      <h3 className={styles.cardTitle}>{level.title}</h3>

      <p className={styles.cardText}>{level.description}</p>

      <span className={styles.cta}>
        {ctaLabel}
        <ArrowRight size={16} className={styles.arrow} />
      </span>
    </Link>
  );
}
