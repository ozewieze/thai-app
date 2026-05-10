import Link from "next/link";
import styles from "./BreadCrumbs.module.css";

export type BreadcrumbItem = {
  label: string;
  href?: string;
};

interface BreadCrumbsProps {
  items: BreadcrumbItem[];
}

export default function BreadCrumbs({ items }: BreadCrumbsProps) {
  return (
    <nav className={styles.breadcrumbs} aria-label="Breadcrumb">
      <ol className={styles.breadcrumbList}>
        {items.map((item, idx) => (
          <li className={styles.breadcrumbItem} key={idx}>
            {item.href && idx !== items.length - 1 ? (
              <Link href={item.href} className={styles.breadcrumbLink}>
                {item.label}
              </Link>
            ) : (
              <span aria-current="page" className={styles.breadcrumbCurrent}>
                {item.label}
              </span>
            )}
          </li>
        ))}
      </ol>
    </nav>
  );
}
