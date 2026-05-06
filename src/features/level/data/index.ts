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
} as const;

export function isLevelSectionKey(value: string): value is LevelSectionKey {
  return ["dialogs", "themes", "stories", "practice"].includes(value);
}
