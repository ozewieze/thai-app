import Link from "next/link";

export default function Navigation() {
  return (
    <header className="site-header">
      <div className="site-header__inner">
        <Link href="/" className="site-header__brand">
          ThaiNook
        </Link>

        <nav className="site-header__nav" aria-label="Main navigation">
          <Link href="/" className="site-header__link">
            Home
          </Link>
          <Link href="/levels" className="site-header__link">
            Levels
          </Link>
          <Link href="/thai-script" className="site-header__link">
            Thai Script
          </Link>
          <Link href="/pricing" className="site-header__link">
            Pricing
          </Link>
        </nav>
      </div>
    </header>
  );
}
