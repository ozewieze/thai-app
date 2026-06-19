import type { DialogBlock, DialogData } from "./types";

/**
 * splitDialogIntoBlocks
 *
 * Splits de volledige dialoogtekst op in losse blokken.
 * Elk blok is een regel (of uitwisseling) uit de dialoog.
 *
 * De drie tekstvelden (Thai, transliteratie, Engelse vertaling) worden
 * elk op regelafbrekingen gesplitst. Regel 1 van Thai hoort bij
 * regel 1 van de transliteratie en regel 1 van de Engelse vertaling.
 *
 * Lege regels worden genegeerd (filter(Boolean)).
 */
export function splitDialogIntoBlocks(dialog: DialogData): DialogBlock[] {
  const thaiLines = dialog.thaiText.split("\n").filter(Boolean);
  const translitLines = dialog.transliteration?.split("\n").filter(Boolean) ?? [];
  const englishLines = dialog.translationEn?.split("\n").filter(Boolean) ?? [];

  return thaiLines.map((thaiLine, i) => ({
    index: i,
    thaiLine,
    transliterationLine: translitLines[i] ?? null,
    translationLine: englishLines[i] ?? null,
  }));
}
