import styles from "./PremiumBadge.module.css";
import { Crown, Lock } from "lucide-react";
export default function PremiumBadge() {
  return (
    <div className={styles.premiumOverlay} aria-hidden="true">
      <div className={styles.premiumBadge}>
        <Crown className={styles.premiumIcon} />
        <span>Premium</span>
      </div>
      <div className={styles.premiumLock}>
        <Lock className={styles.lockIcon} />
      </div>
    </div>
  );
}
