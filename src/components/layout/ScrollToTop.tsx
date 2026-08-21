"use client";

import { useEffect } from "react";
import { usePathname } from "next/navigation";

// Next 16 liet het default scrolgedrag van <Link> vallen: het onthoudt nu
// de scrollpositie zoals browser-back/forward dat doet, en scrollt alleen
// naar boven als het root-element van de nieuwe pagina niet overlapt met
// de huidige viewport (node_modules/next/dist/docs/.../link.md, "Disable
// scrolling to the top of the page"). Bij een lange lespagina overlapt die
// root vrijwel altijd nog met het huidige scrollpunt, dus de pagina opent
// waar de vorige eindigde in plaats van bovenaan. Dit component dwingt het
// oude, voorspelbare gedrag af: elke routewijziging scrollt naar boven.
export default function ScrollToTop() {
  const pathname = usePathname();

  useEffect(() => {
    // behavior: "instant" is nodig, niet enkel het object-argument zelf --
    // scrollTo(0, 0) en { behavior: "auto" } volgen allebei nog de globale
    // `scroll-behavior: smooth` uit base.css, waardoor de reset zichtbaar
    // geanimeerd verloopt in plaats van direct bovenaan te verschijnen.
    window.scrollTo({ top: 0, left: 0, behavior: "instant" });
  }, [pathname]);

  return null;
}
