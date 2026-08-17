export type Level = {
  id: string;
  title: string;
  description: string;
};

export type CtaLabelMode = "generic" | "level";

export type LessonRow = {
  lesson_key: string;
  slug: string;
  lesson_type: "dialog" | "revision" | "theme" | "story";
  title: string;
  subtitle: string | null;
  sequence_number: number;
  access_tier: "free" | "premium";
};

export type SectionLessonCardItem = {
  lessonKey: string;
  slug: string;
  lessonType: "dialog" | "revision" | "theme" | "story";
  title: string;
  subtitle: string | null;
  sequenceNumber: number;
  accessTier: "free" | "premium";
};
