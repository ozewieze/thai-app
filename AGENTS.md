<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

# Database: twee valkuilen

Alles hieronder staat bewust *buiten* het gegenereerde blok hierboven, zodat het
een regeneratie van die regels overleeft.

## `schema.sql` is een momentopname, geen bron van waarheid

`schema.sql` is een dump van de database op het moment dat iemand hem draaide.
Hij wordt **niet** automatisch bijgewerkt als er een migratie bijkomt. Staat een
trigger, view of kolom niet in `schema.sql`, dan bewijst dat niets — kijk in
`supabase/migrations/`, want dat is wel de bron van waarheid.

Op 2026-08-01 kostte dit een halve dag: `schema.sql` was voor het laatst ververst
op 11 juli, terwijl de `AFTER DELETE`-triggers uit
`20260717120000_lesson_link_revert_on_delete.sql` er al sinds 17 juli waren. Het
bestand liet de wereld van vóór die migratie zien en de conclusie was dat de
triggers ontbraken.

**Regel:** ververs `schema.sql` na elke migratie.

```bash
npm run db:status   # controleer eerst dat alle migraties toegepast zijn
npm run db:dump     # pas daarna dumpen
```

Die volgorde is niet optioneel. Een dump legt vast wat er ín de database zit, niet
wat er in `supabase/migrations/` staat. Dump je terwijl een migratie nog niet is
toegepast, dan krijg je een bestand dat er accuraat uitziet maar het niet is —
dezelfde val, alleen omgekeerd.

Bekijk daarna de `git diff` vóór je commit. De wijzigingen die je verwacht horen
er te staan; zie je ze niet, dan is er iets misgegaan met de dump.

## Een seedbestand bewerken verandert de database niet

De bestanden in `supabase/seed-data/` worden alleen uitgevoerd door
`npm run db:reset`. Haal je een regel uit een seedbestand, dan blijft de
bijbehorende rij gewoon in de draaiende database staan — er vuurt geen `DELETE`,
dus ook geen enkele trigger.

Dat maakt twee dingen mogelijk die op elkaar lijken maar niet hetzelfde zijn:

- **Alleen het seedbestand bewerkt** → database en seed lopen uiteen tot de
  volgende reset. De statustabellen kloppen nog met de oude situatie.
- **Alleen in Supabase Studio verwijderd** → de triggers vuren correct en de
  status wordt teruggedraaid, maar bij de volgende `db:reset` komt de rij terug,
  want het seedbestand kent de verwijdering niet.

**Regel:** verwijder je een koppeling, doe het dan op beide plekken — in de
database én in het seedbestand.
