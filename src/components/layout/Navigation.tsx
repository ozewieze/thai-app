"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Menu, X } from "lucide-react";

export default function Navigation() {
  const [menuOpen, setMenuOpen] = useState(false);
  // TODO: Bereken navItems in server-side layout (of via server action) op basis van sessie. Om pricing pagina te verbergen voor ingelogde gebruikers, en om een "My Account" link toe te voegen.
  const navItems = [
    { href: "/", label: "Home" },
    { href: "/levels", label: "Levels" },
    { href: "/thai-script", label: "Thai Script" },
    { href: "/pricing", label: "Pricing" },
  ];

  function openMenu() {
    setMenuOpen(true);
  }

  function closeMenu() {
    setMenuOpen(false);
  }

  useEffect(() => {
    document.body.style.overflow = menuOpen ? "hidden" : "";

    function handleEscape(event: KeyboardEvent) {
      if (event.key === "Escape") {
        setMenuOpen(false);
      }
    }

    window.addEventListener("keydown", handleEscape);

    return () => {
      document.body.style.overflow = "";
      window.removeEventListener("keydown", handleEscape);
    };
  }, [menuOpen]);

  return (
    <header className="site-header">
      <div className="site-header__inner u-w-max">
        <Link href="/" className="site-header__brand" onClick={closeMenu}>
          ThaiNook
        </Link>

        <button
          type="button"
          className="site-header__toggle"
          aria-expanded={menuOpen}
          aria-controls="mobile-menu"
          aria-label={menuOpen ? "Sluit menu" : "Open menu"}
          onClick={menuOpen ? closeMenu : openMenu}
        >
          <span>
            {menuOpen ? (
              <X size={24} strokeWidth={1.75} aria-hidden="true" />
            ) : (
              <Menu size={24} strokeWidth={1.75} aria-hidden="true" />
            )}
          </span>
        </button>

        <nav className="site-header__nav" aria-label="Main navigation">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="site-header__link"
            >
              {item.label}
            </Link>
          ))}
        </nav>
      </div>

      {menuOpen && (
        <div className="mobile-menu">
          <button
            type="button"
            className="mobile-menu__backdrop"
            aria-label="Sluit menu"
            onClick={closeMenu}
          />

          <div
            className="mobile-menu__panel"
            role="dialog"
            aria-modal="true"
            aria-labelledby="mobile-menu-title"
          >
            <div className="mobile-menu__header">
              <h2 id="mobile-menu-title" className="mobile-menu__title">
                Menu
              </h2>

              <button
                type="button"
                className="mobile-menu__close"
                aria-label="Sluit menu"
                onClick={closeMenu}
              >
                <X size={20} strokeWidth={1.75} aria-hidden="true" />
              </button>
            </div>

            <nav
              className="mobile-menu__nav"
              aria-label="Mobile navigation links"
            >
              {navItems.map((item, index) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`mobile-menu__link${index === 0 ? " mobile-menu__link--active" : ""}`}
                  onClick={closeMenu}
                >
                  {item.label}
                </Link>
              ))}
            </nav>

            <div className="mobile-menu__footer">
              <Link
                href="/pricing"
                className="mobile-menu__secondary"
                onClick={closeMenu}
              >
                View pricing
              </Link>

              <Link href="/" className="mobile-menu__cta" onClick={closeMenu}>
                Continue learning
              </Link>
            </div>
          </div>
        </div>
      )}
    </header>
  );
}
