"use client";

import { useRef, useState } from "react";
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
 * Fase 1 in-memory; persistentie (localStorage) is fase 2 — dit is er de
 * natuurlijke kandidaat voor, want een leesvoorkeur wil je onthouden.
 */
export default function TransliterationToggle() {
  const ref = useRef<HTMLDivElement>(null);
  const [show, setShow] = useState(true);

  function handleChange(event: React.ChangeEvent<HTMLInputElement>) {
    const next = event.target.checked;
    setShow(next);   
    ref.current
      ?.closest<HTMLElement>("[data-study-area]")
      ?.setAttribute("data-translit-visible", String(next));
  } //rechtstreeks in de DOM 

  return (
    <div ref={ref} className={styles.controls}>
      <label className={styles.toggle}>
        <input
          type="checkbox"
          className={styles.checkbox}
          checked={show}
          onChange={handleChange}
        />
        <span>Show transliteration</span>
      </label>
    </div>
  );
}
