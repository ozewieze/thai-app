// import Link from "next/link";
import { notFound } from "next/navigation";
// import LevelBadge from "@/components/ui/level-badge/LevelBadge";
import { getLevelById } from "@/features/level/lib/getLevelById";
import { isLevelSectionKey, levelSectionData } from "@/features/level/data";
// import styles from "./LevelSectionPage.module.css";
import SectionPageView from "@/features/section/components/section-page-view/SectionPageView";

type PageProps = {
  params: Promise<{ level: string; section: string }>;
};

const sectionLabels = {
  dialogs: "Dialogs",
  themes: "Themes",
  stories: "Stories",
  practice: "Practice",
} as const;

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
