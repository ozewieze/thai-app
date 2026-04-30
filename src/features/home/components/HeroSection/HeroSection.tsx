import styles from "./HeroSection.module.css";
import Image from "next/image";
import { Sparkles } from "lucide-react";
export default function HeroSection() {
  return (
    <section className={styles.hero}>
      <div className={styles.content}>
        <p className={styles.eyebrow}>
          <span className={styles.eyebrowIcon} aria-hidden="true">
            <Sparkles size={18} strokeWidth={1.8} color="var(--color-accent)" />
          </span>
          <span>CEFR-structured learning path</span>
        </p>
        <h1 className={styles.title}>Master Thai With Confidence</h1>
        <p>
          Learn Thai through structured dialogs, thematic vocabulary, and
          contextual practice. Progress from A1 to C2 with a method designed for
          adult learners.
        </p>
        <button>Try free lessons</button>
        <button>See how it works</button>
      </div>
      <div className={styles.image}>
        <Image
          src="/hero-image.png"
          alt="Hero Image"
          width={1086}
          height={1448}
          loading="eager"
          priority
        />
      </div>
    </section>
  );
}
