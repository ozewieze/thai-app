import type { Metadata } from "next";
import type { ReactNode } from "react";
import "@/styles/main.css";
import { inter, notoSansThai } from "@/lib/fonts";
import Navigation from "@/components/layout/Navigation";
import Footer from "@/components/layout/Footer";
export const metadata: Metadata = {
  title: "Thai Learner App",
  description: "Learn Thai with dialogues, vocabulary, grammar and practice.",
};
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${notoSansThai.variable}`}>
      <body>
        <div className="app-shell ">
          <Navigation />
          <main className="app-shell__main u-w-max">{children}</main>
          <Footer />
        </div>
      </body>
    </html>
  );
}
