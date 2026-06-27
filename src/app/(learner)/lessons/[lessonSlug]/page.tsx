import { notFound } from "next/navigation";
import {
  getLessonBySlug,
  getLessonNav,
} from "@/features/lesson/server/queries";
import LessonPageView from "@/features/lesson/components/lesson-page-view/LessonPageView";

type PageProps = { params: Promise<{ lessonSlug: string }> };

export default async function LessonPage({ params }: PageProps) {
  const { lessonSlug } = await params;

  const lesson = await getLessonBySlug(lessonSlug);
  if (!lesson) notFound();

  const lessonNav = await getLessonNav(lesson.id, lesson.sectionKey);

  return <LessonPageView lesson={lesson} lessonNav={lessonNav} />;
}
