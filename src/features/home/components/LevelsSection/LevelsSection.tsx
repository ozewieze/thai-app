import Link from "next/link";
import { ArrowRight } from "lucide-react";
import styles from "./LevelsSection.module.css";

type Level = {
  id: string;
  title: string;
  description: string;
  dialogs: number;
  themes: number;
};

const levels: Level[] = [
  {
    id: "A1",
    title: "A1 Beginner",
    description:
      "Start your Thai journey with basic greetings, numbers, and simple conversations.",
    dialogs: 50,
    themes: 12,
  },
  {
    id: "A2",
    title: "A2 Upper Beginner",
    description:
      "Build confidence with everyday situations and practical vocabulary.",
    dialogs: 50,
    themes: 15,
  },
  {
    id: "B1",
    title: "B1 Intermediate",
    description:
      "Express opinions and navigate more complex social situations.",
    dialogs: 50,
    themes: 18,
  },
  {
    id: "B2",
    title: "B2 Upper Intermediate",
    description:
      "Discuss abstract topics and understand more detailed texts and conversations.",
    dialogs: 50,
    themes: 20,
  },
  {
    id: "C1",
    title: "C1 Advanced",
    description:
      "Master nuanced communication in professional and academic contexts.",
    dialogs: 50,
    themes: 22,
  },
  {
    id: "C2",
    title: "C2 Fluent",
    description:
      "Achieve near-native fluency with advanced comprehension and expression.",
    dialogs: 50,
    themes: 25,
  },
];

export default function LevelsSection() {
  return (
    <section className={styles.section} aria-labelledby="levels-title">
      <div className={styles.header}>
        <h2 id="levels-title" className={styles.title}>
          Progress from A1 to C2
        </h2>
        <p className={styles.description}>
          Follow the internationally recognized CEFR framework, designed for
          structured language progression.
        </p>
      </div>

      <div className={styles.grid}>
        {levels.map((level) => (
          <Link
            href={`/levels/${level.id.toLowerCase()}`}
            key={level.id}
            className={styles.card}
          >
            <span className={styles.levelBadge}>{level.id}</span>

            <h3 className={styles.cardTitle}>{level.title}</h3>

            <p className={styles.cardText}>{level.description}</p>

            <div className={styles.stats}>
              <span>{level.dialogs} dialogs</span>
              <span aria-hidden="true">•</span>
              <span>{level.themes} themes</span>
            </div>

            <span className={styles.cta}>
              Start learning
              <ArrowRight size={16} className={styles.arrow} />
            </span>
          </Link>
        ))}
      </div>
    </section>
  );
}
