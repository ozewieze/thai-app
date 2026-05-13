import { a1LevelFlow } from "./a1LevelFlow";
import { a1Themes } from "./a1Themes";

export type LevelSectionKey = "dialogs" | "themes" | "stories" | "practice";

export const levelSectionData = {
  a1: {
    dialogs: a1LevelFlow,
    themes: a1Themes,
    stories: [],
    practice: [],
  },
}; // as const; :gezien dit een readonly geeft, voorlopig gecomment

export const getSectionLabels = (level: keyof typeof levelSectionData) => {
  // Haal de keys op en typeer ze direct als de correcte array
  const keys = Object.keys(levelSectionData[level]) as LevelSectionKey[];

  return Object.fromEntries(
    keys.map((key) => [key, key.charAt(0).toUpperCase() + key.slice(1)]),
  ) as Record<LevelSectionKey, string>;
};

export function isLevelSectionKey(value: string): value is LevelSectionKey {
  return ["dialogs", "themes", "stories", "practice"].includes(value);
}
