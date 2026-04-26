import type { Metadata } from "next";
import "@/styles/main.css";
import { inter, notoSansThai } from "@/lib/fonts";
export const metadata: Metadata = {
  title: "Thai Learner App",
  description: "Learn Thai with dialogues, vocabulary, grammar and practice.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${inter.variable} ${notoSansThai.variable}`}>
      <body>{children}</body>
    </html>
  );
}
