"use client";

import { useState } from "react";
import FullDialogPlayer from "../full-dialog-player/FullDialogPlayer";
import type { DialogSlide } from "@/features/lesson/types";

type DialogFullSectionProps = {
  audioUrl: string | null;
  slides: DialogSlide[];
  // className voor de imageCard wordt meegegeven vanuit LessonPageView
  // zodat de styling gecentraliseerd blijft in LessonPageView.module.css.
  imageCardClassName?: string;
};

/**
 * DialogFullSection
 *
 * Client component dat de slideshow-afbeelding en de FullDialogPlayer
 * combineert in één gedeelde state.
 *
 * Waarom een aparte component?
 * LessonPageView is een server component. Server components kunnen geen
 * callback-functies doorgeven aan client components. Omdat zowel de
 * imageCard (slide-display) als de FullDialogPlayer (audio + sync) de
 * activeSlideIndex moeten delen, moeten ze in dezelfde client component
 * leven.
 *
 * Dataflow:
 *   FullDialogPlayer roept onSlideChange aan wanneer de actieve slide wisselt.
 *   DialogFullSection beheert activeSlideIndex als state.
 *   De imageCard toont slides[activeSlideIndex].imageUrl zodra die beschikbaar is.
 */
export default function DialogFullSection({
  audioUrl,
  slides,
  imageCardClassName,
}: DialogFullSectionProps) {
  const [activeSlideIndex, setActiveSlideIndex] = useState<number>(-1);

  // De actieve slide op basis van de index die de player doorgeeft.
  // null als er geen slides zijn, de audio nog niet speelt, of de
  // currentTime buiten alle slide-tijdvensters valt.
  const activeSlide =
    activeSlideIndex >= 0 && activeSlideIndex < slides.length
      ? slides[activeSlideIndex]
      : null;

  return (
    <>
      {/* Slide-afbeelding of placeholder */}
      <div className={imageCardClassName}>
        {activeSlide?.imageUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={activeSlide.imageUrl}
            alt=""
            style={{ width: "100%", height: "100%", objectFit: "cover" }}
          />
        ) : (
          "Illustration coming soon"
        )}
      </div>

      {/* Full-dialog audioplayer met slide-synchronisatie */}
      <FullDialogPlayer
        audioUrl={audioUrl}
        slides={slides}
        onSlideChange={setActiveSlideIndex}
      />
    </>
  );
}
