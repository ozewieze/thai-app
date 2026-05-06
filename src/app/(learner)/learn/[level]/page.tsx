import LevelBadge from "@/components/ui/level-badge/LevelBadge";
import { notFound } from "next/navigation";
import { getLevelById } from "@/features/level/lib/getLevelById";
import Link from "next/link";
type PageProps = {
  params: Promise<{ level: string }>;
};

export default async function Page({ params }: PageProps) {
  const { level } = await params;
  const levelData = getLevelById(level);

  if (!levelData) {
    notFound();
  }
  return (
    <>
      <LevelBadge levelId={levelData.id} size="lg" />
      <h1>{levelData.title} level page</h1>
      <p>{levelData.description}</p>

      <nav aria-label="Level sections">
        <ul>
          <li>
            <Link href={`/learn/${level}/dialogs`}>Dialogs</Link>
            <Link href={`/learn/${level}/themes`}>Themes</Link>
          </li>
        </ul>
      </nav>
    </>
  );
}
// TODO vervangen door componenten in features/Level/components/...
