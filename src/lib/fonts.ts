import { Inter, Noto_Sans_Thai_Looped } from "next/font/google";

export const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

export const notoSansThai = Noto_Sans_Thai_Looped({
  weight: ["400", "500", "600", "700"],
  subsets: ["thai"],
  variable: "--font-noto-thai",
});
