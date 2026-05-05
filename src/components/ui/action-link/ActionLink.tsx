import Link from "next/link";
import styles from "./ActionLink.module.css"; //wordt geimporteerd als een object met classnames als properties en de bijbehorende gegenereerde classnames als waarden.

type ActionLinkProps = {
  href: string;
  children: React.ReactNode;
  variant?: "primary" | "secondary";
  size?: "sm" | "md" | "lg";
  className?: string;
  ariaLabel?: string;
};
export default function ActionLink({
  href,
  children,
  variant = "primary",
  size = "md",
  className = "",
  ariaLabel,
}: ActionLinkProps) {
  const classes = [styles.actionLink, styles[variant], styles[size], className]
    .filter(Boolean)
    .join(" ");
  return (
    <Link href={href} className={classes} aria-label={ariaLabel}>
      {children}
    </Link>
  );
}
