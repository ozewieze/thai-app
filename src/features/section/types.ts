export type Dialog = {
  id: string;
  type: "dialog";
  slug: string;
  number: number;
  access: "premium" | "free";
  title: string;
  subtitle: string;
  label: string;
};

export type Revision = {
  id: string;
  type: "revision";
  slug: string;
  rangeLabel: string;
  exerciseCount: number;
};

export type Theme = {
  id: string;
  slug: string;
  access: "premium" | "free";
  title: string;
  description: string;
  label: string;
};
import { levelSectionData } from "@/features/level/data";

export type SectionsForLevel =
  (typeof levelSectionData)[keyof typeof levelSectionData];
