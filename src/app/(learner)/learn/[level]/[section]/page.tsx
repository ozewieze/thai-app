import { notFound } from "next/navigation";

import { getLevelById } from "@/features/level/lib/getLevelById";
import {
  isLevelSectionKey,
  levelSectionData,
  getSectionLabels,
} from "@/features/level/data";
import SectionPageView from "@/features/section/components/section-page-view/SectionPageView";

type PageProps = {
  params: Promise<{ level: string; section: string }>;
};

export default async function LevelSectionPage({ params }: PageProps) {
  const { level, section } = await params;
  const levelData = getLevelById(level);

  if (!levelData) {
    notFound();
  }

  const sectionsForLevel =
    levelSectionData[level as keyof typeof levelSectionData];

  if (!sectionsForLevel || !isLevelSectionKey(section)) {
    notFound();
  }
  const sectionLabels = getSectionLabels(
    level as keyof typeof levelSectionData,
  );

  return (
    <SectionPageView
      level={level}
      section={section}
      levelData={levelData}
      sectionsForLevel={sectionsForLevel}
      sectionLabels={sectionLabels}
    />
  );
}
