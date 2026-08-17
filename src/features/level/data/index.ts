// import { a1Themes } from "./a1Themes";

export type LevelSectionKey = "dialogs" | "themes" | "stories" | "practice";

export const sectionLabels: Record<LevelSectionKey, string> = {
  dialogs: "Dialogs",
  themes: "Themes",
  stories: "Stories",
  practice: "Practice",
};

export function isLevelSectionKey(value: string): value is LevelSectionKey {
  return ["dialogs", "themes", "stories", "practice"].includes(value);
}
