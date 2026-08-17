import levels from "@/features/curriculum/levels";

export function getLevelById(levelId: string) {
  return levels.find(
    (level) => level.id.toLowerCase() === levelId.toLowerCase(),
  );
}
