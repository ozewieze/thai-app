import styles from "./SectionEyebrow.module.css";
interface SectionEyebrowProps {
  children: React.ReactNode;
  icon?: React.ReactNode;
  size?: "sm" | "md";
  className?: string;
}

interface SectionEyebrowProps {
  children: React.ReactNode;
  icon?: React.ReactNode;
  size?: "sm" | "md"; // Je kunt dit uitbreiden als nodig
  className?: string;
}

export default function SectionEyebrow({
  children,
  icon,
  size = "md",
  className = "",
}: SectionEyebrowProps) {
  return (
    <p className={`${styles.eyebrow} ${styles[size]} ${className}`}>
      {icon && (
        <span className={styles.icon} aria-hidden="true">
          {icon}
        </span>
      )}
      <span>{children}</span>
    </p>
  );
}
