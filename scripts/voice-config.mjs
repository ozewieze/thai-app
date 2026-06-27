// ============================================================
// voice-config.mjs
//
// Koppelt character_key (uit character_profiles) aan een
// Google Cloud TTS stem.
//
// Stemmen:
//   Neural2  — huidige generatie, betrouwbaar voor Thai
//   Chirp3   — nieuwste generatie, natuurlijker, ondersteunt
//              custom voice training (fase 2: voice actors)
//
// Om te wisselen naar Chirp3: vervang de `name` waarde door
// bijv. 'th-TH-Chirp3-HD-Aoede' en test via de Google Cloud
// Text-to-Speech console (https://cloud.google.com/text-to-speech).
//
// SSML: standaard uitgeschakeld. Zet `ssml: true` in een
// toekomstig script voor oefeningen die trager of met pauzes
// worden uitgesproken. De API call gebruikt dan `ssmlText`
// in plaats van `text`.
// ============================================================

export const VOICE_MAP = {
  mali: {
    languageCode: "th-TH",
    name: "th-TH-Neural2-C", // vrouwelijk
  },
  narin: {
    languageCode: "th-TH",
    name: "th-TH-Chirp3-HD-Fenrir", // mannelijk (Chirp3 — Neural2 heeft geen Thaise mannenstem)
  },
};

// Audioformaat voor Supabase Storage.
// MP3 is het breedst ondersteund in browsers en iOS Safari.
export const AUDIO_CONFIG = {
  audioEncoding: "MP3",
};
