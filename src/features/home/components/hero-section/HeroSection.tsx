import styles from "./HeroSection.module.css";
import Image from "next/image";
import { Sparkles } from "lucide-react";
import ActionLink from "@/components/ui/action-link/ActionLink";
import SectionEyebrow from "@/components/ui/section-eyebrow/SectionEyebrow";
export default function HeroSection() {
  return (
    <section className={`${styles.hero} u-w-max`}>
      <div className={styles.content}>
        <SectionEyebrow
          icon={
            <Sparkles size={18} strokeWidth={1.8} color="var(--color-accent)" />
          }
        >
          CEFR-structured learning path
        </SectionEyebrow>
        <h1 className={styles.title}>Your Cozy Corner To Learn Thai</h1>
        <p>
          Learn through dialogues, stories, vocabulary, and real-life
          conversations — from A1 to C2.
        </p>
        <div className={styles.actions}>
          <ActionLink href="/learn/a1/dialogs" variant="primary" size="lg">
            Try free lessons
          </ActionLink>

          <ActionLink href="/how-it-works" variant="secondary" size="lg">
            See how it works
          </ActionLink>
        </div>
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
