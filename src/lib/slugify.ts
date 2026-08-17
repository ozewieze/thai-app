/**
 * Converts a string to a URL-safe ASCII slug.
 * Strips diacritics, lowercases, and replaces non-alphanumeric characters with hyphens.
 *
 * Examples:
 *   slugify("At the Cafe")    => "at-the-cafe"
 *   slugify("Sawadee Krap!")  => "sawadee-krap"
 *   slugify("  Hello World ") => "hello-world"
 */
export function slugify(text: string): string {
  return text
    .normalize("NFD")                      // split accented chars: e.g. e + combining accent
    .replace(/[̀-ͯ]/g, "")       // remove combining diacritical marks
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")           // replace non-alphanumeric runs with a hyphen
    .replace(/^-|-$/g, "");               // trim leading/trailing hyphens
}
