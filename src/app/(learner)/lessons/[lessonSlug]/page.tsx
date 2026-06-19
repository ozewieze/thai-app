import { notFound } from "next/navigation";
import { getLessonBySlug } from "@/features/lesson/server/queries";
import LessonPageView from "@/features/lesson/components/lesson-page-view/LessonPageView";

type PageProps = {
  params: Promise<{ lessonSlug: string }>;
};

export default async function LessonPage({ params }: PageProps) {
  const { lessonSlug } = await params;
  const lesson = await getLessonBySlug(lessonSlug);

  if (!lesson) {
    notFound();
  }

  return <LessonPageView lesson={lesson} />;
}
