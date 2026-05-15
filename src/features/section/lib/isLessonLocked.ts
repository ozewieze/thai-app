import type { SectionLessonCardItem } from "@/features/curriculum/types";
export function isLessonLocked(
  item: SectionLessonCardItem,
  viewer: { plan: "free" | "premium" } | null,
) {
  if (item.accessTier !== "premium") return false;
  if (!viewer) return true;
  return viewer.plan !== "premium";
}
