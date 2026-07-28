import { notFound } from "next/navigation";
import {
  getLessonBySlug,
  getLessonNav,
  getLessonInstructionalContent,
} from "@/features/lesson/server/queries";
import LessonPageView from "@/features/lesson/components/lesson-page-view/LessonPageView";

type PageProps = { params: Promise<{ lessonSlug: string }> };

export default async function LessonPage({ params }: PageProps) {
  const { lessonSlug } = await params;

  const lesson = await getLessonBySlug(lessonSlug);
  if (!lesson) notFound();

  // Nav en instructiecontent hebben geen onderlinge afhankelijkheid en
  // hangen allebei alleen van lesson.id af -> parallel ophalen.
  const [lessonNav, instructionalContent] = await Promise.all([
    getLessonNav(lesson.id, lesson.sectionKey),
    getLessonInstructionalContent(lesson.id),
  ]);

  return (
    <LessonPageView
      lesson={lesson}
      lessonNav={lessonNav}
      instructionalContent={instructionalContent}
    />
  );
}
