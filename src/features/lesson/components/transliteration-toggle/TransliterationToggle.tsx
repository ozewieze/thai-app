"use client";

import { useEffect, useRef } from "react";
import styles from "./TransliterationToggle.module.css";

/**
 * TransliterationToggle
 *
 * Het enige client-eiland rond de instructiecontent: één subtiele
 * leesvoorkeur "Show transliteration" voor Vocabulary én Language Notes.
 *
 * Childless client-eiland: het omhullende `data-*`-element is server-
 * gerenderd (LessonPageView, `data-study-area`). Deze toggle flipt
 * `data-translit-visible` via `closest("[data-study-area]")`; verbergen
 * gebeurt puur via CSS op `[data-study-layer="transliteration"]`.
 * Selectie op "false" -> no-JS/pre-hydration-default is "zichtbaar".
 *
 * Uncontrolled checkbox (geen React-state): we sturen `.checked` en het
 * attribuut rechtstreeks in de DOM aan. Zo is er geen `setState` in een
 * effect nodig (React 19 waarschuwt daarvoor) en geen re-render van de
 * content.
 *
 * Persistentie: TIJDELIJK via localStorage, ná mount uitgelezen zodat
 * server en client-first-paint gelijk zijn (geen hydration-mismatch).
 * LATER wordt dit een account-instelling (gesynct over apparaten) zodra
 * er auth is — localStorage is dan niet meer de bron van waarheid. Zie
 * ook de fase-2-notitie in de visibility-architectuur.
 */
const STORAGE_KEY = "thainook:show-transliteration";

export default function TransliterationToggle() {
  const inputRef = useRef<HTMLInputElement>(null);

  // Zet het attribuut op de omhullende server-div; CSS verbergt/toont.
  function applyToStudyArea(next: boolean) {
    inputRef.current
      ?.closest<HTMLElement>("[data-study-area]")
      ?.setAttribute("data-translit-visible", String(next));
  }

  // Herstel de opgeslagen voorkeur ná mount (TIJDELIJK, localStorage).
  // Rechtstreeks in de DOM -> geen setState in een effect.
  useEffect(() => {
    try {
      if (localStorage.getItem(STORAGE_KEY) === "false") {
        if (inputRef.current) inputRef.current.checked = false;
        applyToStudyArea(false);
      }
    } catch {
      // localStorage kan geblokkeerd zijn (privémodus e.d.) — default aanhouden.
    }
  }, []);

  function handleChange(event: React.ChangeEvent<HTMLInputElement>) {
    const next = event.target.checked;
    applyToStudyArea(next);
    // TIJDELIJK: onthouden per apparaat. Later account-niveau.
    try {
      localStorage.setItem(STORAGE_KEY, String(next));
    } catch {
      // negeren als opslag niet beschikbaar is
    }
  }

  return (
    <div className={styles.controls}>
      <label className={styles.toggle}>
        <input
          ref={inputRef}
          type="checkbox"
          className={styles.checkbox}
          defaultChecked
          onChange={handleChange}
        />
        <span>Show transliteration</span>
      </label>
    </div>
  );
}
