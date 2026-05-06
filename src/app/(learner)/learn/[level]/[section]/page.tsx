import { getLevelById } from "@/features/level/lib/getLevelById";
import { notFound } from "next/navigation";
import LevelBadge from "@/components/ui/level-badge/LevelBadge";
import Link from "next/link";
import { levelSectionData, isLevelSectionKey } from "@/features/level/data";

type PageProps = { params: Promise<{ level: string; section: string }> };

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
    <>
      <LevelBadge levelId={levelData.id} size="lg" />
      <h1>{levelData.title}</h1>
      <p>{levelData.description}</p>

      <nav aria-label="Level sections">
        <ul>
          <li>
            <Link href={`/learn/${level}/dialogs`}>Dialogs</Link>
          </li>
          <li>
            <Link href={`/learn/${level}/themes`}>Themes</Link>
          </li>
          <li>
            <Link href={`/learn/${level}/stories`}>Stories</Link>
          </li>
          <li>
            <Link href={`/learn/${level}/practice`}>Practice</Link>
          </li>
        </ul>
      </nav>

      <div>
        {section === "dialogs" && (
          <ul>
            {sectionsForLevel.dialogs.map((item) => (
              <li key={item.id}>
                {item.type === "dialog" ? (
                  <Link href={`/learn/${level}/dialogs/${item.slug}`}>
                    <p>{item.number}</p>
                    <h2>{item.title}</h2>
                    <p>{item.subtitle}</p>
                    <span>{item.label}</span>
                  </Link>
                ) : (
                  <Link href={`/learn/${level}/practice/${item.slug}`}>
                    <h2>{item.title}</h2>
                    <p>{item.rangeLabel}</p>
                    <p>{item.exerciseCount} exercises</p>
                  </Link>
                )}
              </li>
            ))}
          </ul>
        )}

        {section === "themes" && (
          <ul>
            {sectionsForLevel.themes.map((theme) => (
              <li key={theme.id}>
                <Link href={`/learn/${level}/themes/${theme.slug}`}>
                  <h2>{theme.title}</h2>
                  <p>{theme.description}</p>
                  <span>{theme.label}</span>
                </Link>
              </li>
            ))}
          </ul>
        )}
      </div>
    </>
  );
}
