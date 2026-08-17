import styles from "./LevelsGrid.module.css";
import LevelCard from "@/features/levels/components/level-card/LevelCard";
import { CtaLabelMode, Level } from "@/features/curriculum/types";

type LevelsGridProps = {
  levels: Level[];
  ctaLabelMode?: CtaLabelMode;
};

export default function LevelsGrid({ levels, ctaLabelMode }: LevelsGridProps) {
  return (
    <div className={styles.grid}>
      {levels.map((level) => (
        <LevelCard key={level.id} level={level} ctaLabelMode={ctaLabelMode} />
      ))}
    </div>
  );
}
