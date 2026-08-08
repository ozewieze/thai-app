# Language Note-workflowgids

Deze gids beschrijft de herhaalbare redactionele workflow voor het schrijven van Language Notes, in dezelfde geest als `docs/thai_a1_dialog_workflow_guide.md` en `docs/illustration-system/04_illustration_workflow_guide.md`: de database blijft bron van waarheid, alleen goedgekeurde eindresultaten worden definitief opgeslagen, en elke stap heeft een expliciet goedkeuringsmoment.

Deze gids beschrijft **zowel wat een auteur beslist als hoe dat wordt opgeslagen**. Tot 2026-08-03 stond hier het omgekeerde: het document beperkte zich bewust tot de redactionele kant, omdat regels over inhoud trager verouderen dan implementatiedetails. Die afbakening is losgelaten toen het seedformaat werd vastgelegd. De reden: de twee kanten bleken niet los van elkaar te beschrijven. Dat een conceptkoppeling naar de *koppelrij* van de les wijst en niet naar de masterrij, is geen implementatiedetail maar precies de reden dat een note alleen concepten van de eigen les kan claimen — een redactionele regel. Twee documenten zouden die verbanden doorknippen en allebei half kloppen.

De twee lagen blijven wel herkenbaar gescheiden. Stap 1 tot en met 5 en 7 zijn redactioneel: wat schrijf je, en waarom zo. Stap 6 bevat naast de redactionele regel over claimen ook de concrete SQL, bestandspaden en commando's. Waar een technische instructie iets afdwingt wat redactioneel bedoeld is, staat dat er expliciet bij.

Deze workflow start pas **nadat** de dialoog van de les volledig is goedgekeurd en opgeslagen (Stap 10 van de dialoogworkflowgids). Waarom pas dan: een Language Note legt concepten uit *zoals ze in deze les voorkomen*. Zolang de dialoog nog kan veranderen, kan de note naar zinnen of situaties verwijzen die straks niet meer bestaan.

## Wat een Language Note wél en niet is

Een Language Note is een **lesgebonden mini-les**: een korte, geordende uitleg die de leerling direct na (of tijdens) de dialoog van die ene les leest. Ze bestaat uit een geordende reeks blokken — alinea's, een formule, een groep voorbeeldzinnen, een gebruikstip — en behandelt één afgebakend taalpunt uit die les.

Een Language Note is **niet**:

- **Een naslagartikel.** Een note over ไหม in les 3 legt uit wat de leerling in les 3 nodig heeft, niet alles wat er over ไหม te zeggen valt. Waarom: de leerling in les 3 kent alleen de woorden van les 1–3. Volledigheid is hier een gebrek, geen kwaliteit.
- **De definitieve uitleg van een concept.** Hetzelfde concept mag in een latere les opnieuw en dieper worden uitgelegd, in een nieuwe note van díe les. De vroege note blijft dan gewoon staan zoals ze was. Waarom: het curriculum is progressief; wat een goede uitleg is hangt af van waar de leerling zich bevindt.

  Technisch verloopt dat **niet** via een tweede koppeling aan de oorspronkelijke les: de samengestelde foreign keys van `language_note_concepts` staan alleen claims toe op koppelrijen van de eigen les. De latere les heeft dus een eigen `lesson_*`-rij voor dat concept nodig, met rol `review` of `supporting` — `target` wordt door de Single Introduction Rule geblokkeerd. Die blokkade is precies de bedoeling: ze garandeert dat een woord nooit een tweede keer *als nieuw* wordt uitgelegd.

  **Let op:** die rollen zijn vandaag niet in gebruik — alle links zijn `target`. Zolang dat zo blijft, is herhaalde uitleg een voorziene mogelijkheid en geen bestaande praktijk. Of `review` ooit nodig blijkt, is een open curriculumvraag; het antwoord komt vanzelf wanneer een concept in een latere les werkelijk te kort blijkt uitgelegd.
- **Een tweede dialoog.** Voorbeeldzinnen in een note zijn illustraties bij één taalpunt, geen doorlopend gesprek met personages en scène.

## Wanneer krijgt een les een Language Note?

De beslissing is grotendeels al genomen vóór deze workflow begint. Bij het seeden van de leslinks (Stap 3 van de dialoogworkflow) krijgt elk lesconcept een bewust ingevulde `requires_explanation`-vlag. Die vlag is de opdrachtenlijst voor deze workflow:

> **Kernregel:** elk lesconcept met `requires_explanation = true` moet door minstens één Language Note van diezelfde les behandeld worden vóór de les gepubliceerd wordt.

Let op het verschil met `role`. `role = 'target'` zegt dat een concept in deze les geïntroduceerd wordt — een curriculumfeit dat de database afdwingt via de Single Introduction Rule. `requires_explanation` zegt dat het concept geschreven uitleg nodig heeft. Bij grammatica, patterns en phrases vallen die twee vrijwel altijd samen; bij vocabulaire niet, omdat de vocabulary card de basis al toont. Een doelwoord zonder note is dus normaal; een doelgrammaticapunt zonder note niet.

Waarom deze richting (vlag eerst, note daarna) en niet andersom: de vlag wordt gezet op het moment dat je het curriculum plant en het beste zicht hebt op wat nieuw en moeilijk is. Als de note-behoefte pas tijdens het schrijven zou worden bepaald, sluipt er willekeur in — de ene les krijgt rijke uitleg, de andere niets, zonder inhoudelijke reden.

Daarnaast geldt:

- **Niet elk concept verdient een eigen note.** Verwante concepten die samen één leerbaar geheel vormen (bijvoorbeeld een vraagpartikel en het antwoordpatroon dat erbij hoort) horen in één note. Waarom: drie micro-notes over één samenhangend verschijnsel versnipperen de aandacht en verdubbelen de voorbeelden.
- **Een les zonder `requires_explanation`-concepten krijgt geen verplichte note.** Een optionele note mag (bijvoorbeeld een cultuurtip bij een revisieles), maar de standaard is: geen vlag, geen note. Waarom: notes die er alleen zijn "omdat het kan" verwateren de verwachting van de leerling dat een note altijd iets belangrijks bevat.
- **Terloops aanwezige concepten worden niet geclaimd.** Een note "behandelt" alleen wat ze werkelijk uitlegt. Dat een woord toevallig in een voorbeeldzin voorkomt, maakt het nog geen behandeld concept. Waarom: de conceptkoppelingen (zie Stap 6) zijn straks de basis van de publicatievalidatie — valse claims maken die validatie waardeloos.

## Hoeveel notes per les, en hoe lang?

Richtlijn per lesfase, analoog aan de woorden-per-les-tabel in de dialoogworkflowgids:

| Lesfase (`sequence_number`) | Notes per les | Blokken per note (maximum) |
| --------------------------- | ------------- | -------------------------- |
| 1–10                        | 1–2           | 5                          |
| 11–30                       | 2–3           | 6                          |
| 31+                         | 2–4           | 7                          |

De achterliggende logica: vroege lessen introduceren weinig maar fundamenteel materiaal (één stevige note is beter dan drie dunne), latere lessen combineren meer concepten en verdragen meer notes.

**De blokkolom is een plafond, geen bereik.** Ze stond hier tot 2026-08-06 als "3–5", en dat leest als een te halen aantal: een note die op drie blokken uitkomt, krijgt er dan een formule en een tip bij om in de band te vallen. Er is geen ondergrens — twee blokken volstaan voor een note die één woordbetekenis uitlegt (zie Stap 3). Een note die tegen het maximum aanloopt, behandelt vrijwel zeker twee onderwerpen en moet gesplitst worden; dát is waar het getal voor dient.

De volgorde van notes binnen een les is betekenisvol: de leerling leest ze van boven naar onder. Zet de note over het centrale lesdoel eerst, ondersteunende notes (uitspraak, register, cultuur) daarna. Waarom: de eerste note bepaalt of de leerling de dialoog begrijpt; de rest verdiept.

## Stapsgewijze workflow per Language Note

### Stap 1 — Bepaal de behandelde concepten

Begin niet met schrijven maar met afbakenen. Verzamel de lesconcepten met `requires_explanation = true` (vocabulaire, grammatica, phrases, patterns) en verdeel ze over het geplande aantal notes: welke concepten vormen samen één uitlegbaar geheel, en welke verdienen een eigen note?

**Waar die lijst vandaan komt.** Niet uit handwerk: `language_note_brief_view` levert per les de volledige briefing in één rij.

```sql
select *
from public.language_note_brief_view
where lesson_key = 'a1-dialog-XX';
```

De view geeft vier arrays met de gevlagde concepten (`vocabulary_to_explain`, `grammar_to_explain`, `phrases_to_explain`, `patterns_to_explain`), het gededupliceerde woordbudget voor voorbeeldzinnen met de Paiboon-vorm per woord, en de dialoogtekst van de les. Dat is precies de input van Stap 1, 4 en 5 — en van de prompts die notes genereren.

Wil je alleen de conceptlijst zien, dan volstaat:

```sql
select
  jsonb_array_length(vocabulary_to_explain) as vocab,
  jsonb_array_length(grammar_to_explain)    as grammar,
  jsonb_array_length(phrases_to_explain)    as phrases,
  jsonb_array_length(patterns_to_explain)   as patterns
from public.language_note_brief_view
where lesson_key = 'a1-dialog-XX';
```

De view is gecontroleerd met `supabase/qa/verify_language_note_brief_view.sql`; draai dat script als je twijfelt of de cijfers kloppen met de link-tabellen.

**Eén waarschuwing bij het lezen van de view.** Elk concept draagt naast de mastersleutel ook de koppelrij-id (`lesson_vocabulary_id`, `lesson_grammar_id`, `lesson_phrase_id`, `lesson_pattern_id`). Dat is een *controlemiddel*, geen waarde om over te nemen in een seedbestand: het is een identity-waarde die na een `db reset` kan verschuiven. De seeds zoeken de koppelrij zelf op via de sleutels (zie Stap 6). Gebruik de id uit de view om achteraf te controleren dat de seed dezelfde rij vond — niet om hem in te vullen.

Wijkt je oordeel hier af van de vlag — een gevlagd concept blijkt toch geen note nodig te hebben, of een niet-gevlagd concept juist wel — pas dan het seedbestand aan; dat is de bron van waarheid. Breng de lokale database daarna in lijn door datzelfde seedbestand opnieuw te draaien: de leslink-seeds zijn idempotent, dus de gewijzigde waarden overschrijven wat er staat. Doe het niet omgekeerd: een correctie die alleen in de database staat, verdwijnt bij de eerstvolgende reset.

Leg dit vast als een simpel lijstje per note vóór je iets anders doet. Waarom eerst: de conceptafbakening bepaalt titel, structuur én voorbeelden. Wie eerst schrijft en achteraf kijkt welke concepten "erin zaten", krijgt notes die half over twee onderwerpen gaan.

**Dit hoeft geen handwerk te zijn.** `supabase/planning/07_language_note_planner_prompt_template.md` neemt de brief-view-output op en stelt de verdeling voor, inclusief titel (Stap 2) en blokskelet (Stap 3). De ingevulde prompt gaat naar `supabase/prompts/language-notes/a1_dialog_XX_planner_prompt.md`, de output naar `supabase/generation/language-notes/a1_dialog_XX_plan.md`. Het blijft een *voorstel*: het goedkeuringsmoment hieronder verandert er niet door, en jouw correcties op het plan zijn de versie die doorgaat naar de schrijverprompt.

De planner krijgt bewust geen woordbudget en schrijft geen transliteratie. Reden: in deze fase heeft hij die niet nodig, en een gereconstrueerde Paiboon-vorm die in het plan belandt, wordt in de schrijffase klakkeloos overgenomen.

**Goedkeuringsmoment:** de verdeling concepten → notes wordt goedgekeurd vóór er geschreven wordt.

### Stap 2 — Kies de titel

De titel is wat de leerling in de les ziet staan. Conventies:

- **Functioneel, niet grammaticaal.** Beschrijf wat de leerling ermee kán, niet hoe het verschijnsel heet: *"Asking yes/no questions with ไหม"*, niet *"The interrogative particle ไหม"*. Waarom: een A1-leerling kent de vakterm niet en hoeft die ook niet te kennen; de functie is wat hij zoekt als hij later terugbladert.
- **Neem het Thaise sleutelwoord op in Thais schrift** wanneer de note om één woord of partikel draait. Waarom: de leerling legt zo meteen de link met wat hij in de dialoog zag, en went aan het schriftbeeld.
- **Dek wat de note leert, niet waar de voorbeelden over gaan.** De dialoog is het ankerpunt van een note, niet haar grens. Een note die uitlegt dat een beschrijvend woord ná het zelfstandig naamwoord komt, leert een regel die de leerling straks op auto's en mensen toepast, ook al gaat elk voorbeeld over koffie en thee. *"Describing drinks as hot or cold"* belooft dan te weinig; de leerling die later terugbladert voor de woordvolgorde vindt hem niet terug. Vergelijk met *"Talking about what you'll do with จะ"* — die zegt terecht niet "what you'll drink". Waarom dit apart staat van "functioneel, niet grammaticaal": een titel kan functioneel zijn en tóch te smal, en die tweede fout is de moeilijkere om te zien, want hij klopt met alles wat eronder staat.
- **Kort:** richtlijn maximaal ~60 tekens. Waarom: titels worden ook in overzichten en navigatie getoond; lange titels breken daar af.
- **Uniek binnen de les.** Twee notes met bijna dezelfde titel betekenen vrijwel altijd dat de conceptverdeling van Stap 1 niet klopt.

### Stap 3 — Ontwerp de blokstructuur

Bepaal het skelet van de note vóór je de tekst schrijft, als een simpel lijstje bloktypes in volgorde.

**Alleen `paragraph` is onvoorwaardelijk.** Elke note opent ermee. `example_group` is verplicht zodra de note een patroon of constructie uitlegt. De andere drie zijn situationeel:

| Bloktype | Wanneer |
| --- | --- |
| `paragraph` | verplicht — elke note opent ermee |
| `example_group` | verplicht zodra de note een patroon of constructie uitlegt |
| `formula` | alleen bij een constructie met een vaste vorm |
| `usage_tip` | alleen als er een echte valkuil is |
| `subheading` | alleen bij duidelijk gescheiden deelonderwerpen |

Waarom dit expliciet staat: de blokregels hieronder beschrijven wél wanneer je een type gebruikt, maar niet dat nul ook een geldig aantal is. Zonder die zin wordt het skelet een invuloefening en krijgt elke note een formule en een tip, ook waar er niets te schematiseren of te waarschuwen valt.

Er zijn dus twee skeletten. Een note over een taalpatroon:

```
1. paragraph      — wat is dit en waarom kwam je het tegen in de dialoog
2. formula        — het patroon schematisch
3. example_group  — 2–4 voorbeelden van het patroon
4. usage_tip      — één waarschuwing (alleen als er werkelijk een valkuil is)
```

Een note die een woordbetekenis uitlegt, heeft vaak genoeg aan twee blokken:

```
1. paragraph      — wat betekent het woord, en waar kwam je het tegen
2. example_group  — 2–3 voorbeelden
```

Een note van twee blokken is geen halve note. De blokrichtlijn per lesfase is een plafond, geen streefaantal: een blok toevoegen om een aantal te halen levert precies de opgevulde uitleg op die de tabel hierboven wil voorkomen.

Richtlijnen per bloktype, met de reden erbij:

- **paragraph** — het werkpaard. Elke note begint met een paragraph die het concept in twee tot vier zinnen introduceert en verankert aan de dialoog ("In the dialogue, Mali asked ... — that little word at the end is ..."). Waarom verankeren: de leerling heeft de dialoog net gelezen; uitleg die daaraan vasthaakt beklijft beter dan abstracte uitleg. Eén idee per paragraph — een tweede idee krijgt een eigen paragraph.
- **subheading** — alleen voor notes met duidelijk gescheiden deelonderwerpen (bijvoorbeeld "Asking" en "Answering"). Nooit als eerste blok (de titel doet dat werk al), nooit als laatste blok (een kop zonder inhoud eronder is een lege belofte), nooit twee direct na elkaar. Waarom terughoudend: in een korte note creëren koppen vooral visuele ruis; ze verdienen zich pas terug bij langere notes.
- **formula** — het patroon in schemavorm, bijvoorbeeld `[statement] + ไหม = yes/no question`. Slots in vierkante haken en in het Engels, vaste Thaise elementen in Thais schrift. Eén formule per blok; een tweede patroon krijgt een eigen formula-blok (meestal onder een eigen subheading). Waarom een apart bloktype en geen vetgedrukte tekstregel: formules worden visueel anders weergegeven en moeten als zelfstandig element herbruikbaar en herkenbaar blijven. Een note die geen constructie met een vaste vorm uitlegt, krijgt geen formule — een schema van iets wat geen patroon is, suggereert een regelmaat die er niet is.
- **example_group** — zie Stap 4. Verplicht bij elke note die een patroon of constructie uitlegt. Waarom verplicht: uitleg zonder voorbeelden is voor een A1-leerling niet verifieerbaar — het voorbeeld ís het bewijs dat hij het begrepen heeft.
- **usage_tip** — één concrete tip: een valkuil, een beleefdheidsnuance, een verschil met het Engels. Eén tip per blok, en maximaal één à twee tip-blokken per note. Heeft het concept geen valkuil, dan krijgt de note geen tip. Waarom beperkt: tips ontlenen hun kracht aan schaarste; vijf tips zijn een tweede uitlegtekst in vermomming, en een tip die er alleen staat omdat het skelet er een voorzag, leert de leerling dat tips overslaan mag.

Het skelet komt uit dezelfde plannerprompt als Stap 1 (`07_language_note_planner_prompt_template.md`), zodat conceptverdeling en structuur in één voorstel te beoordelen zijn — het skelet is juist wat de conceptverdeling toetsbaar maakt.

**Goedkeuringsmoment:** het skelet (bloktypes + volgorde + welke voorbeelden er ongeveer komen) wordt goedgekeurd vóór de volledige tekst wordt geschreven. Waarom: een structuurfout herstellen kost na het uitschrijven vijf keer zoveel werk.

### Stap 4 — Schrijf de voorbeeldgroepen

Een voorbeeldgroep bestaat uit een optionele kop, een optionele intro-zin en twee tot vier voorbeelden. Elk voorbeeld is een drieluik: Thais schrift, Paiboon-transliteratie, Engelse vertaling.

Redactionele regels:

- **Eén taalpunt per groep.** Alle voorbeelden in één groep illustreren hetzelfde punt. Wil je een contrast tonen (vraag vs. antwoord, mannelijk vs. vrouwelijk partikel), gebruik dan twee groepen met elk een korte kop, of één groep waarvan de intro het contrast expliciet benoemt. Waarom: de leerling scant voorbeelden op het patroon dat ze gemeen hebben; een afwijker saboteert precies dat.
- **Alleen bekende woorden.** Voorbeelden gebruiken uitsluitend vocabulaire uit deze les of eerdere lessen. Een nieuw woord "smokkelen" omdat het zo'n mooi voorbeeld oplevert is verboden. Waarom: de leerling kan niet onderscheiden wat hij hoort te kennen en wat niet; elk onbekend woord in een voorbeeld voelt als een gat in zijn kennis.

  **Eén smalle uitzondering: het Thaise element van het concept dat de note uitlegt.** จะ, ไหม en dergelijke zijn patterns of grammaticapunten, geen vocabulairerijen, dus ze staan niet in het woordbudget — terwijl een note over จะ het woord จะ onmogelijk kan vermijden. De uitzondering geldt alleen voor het element van een concept dat de note werkelijk behandelt, en ontgrendelt verder niets.

  Let op waar de transliteratie dan vandaan komt: ook die staat niet in het budget. De dialoogtekst is de enige geverifieerde bron — `jà` voor จะ komt uit blok 0 van les 3. Staat het element niet in de dialoog, dan is er geen betrouwbare vorm en hoort `[uncertain]` erbij te staan. Zonder die volgorde wordt de uitzondering een achterdeur om de opzoekregel van Stap 5 heen.

  Deze uitzondering is toegevoegd op 2026-08-06, nadat de eerste schrijverrun op les 03 hem in de praktijk nodig had en het model zelf de dialoog als bron koos.
- **Hergebruik dialoogzinnen waar het kan.** Een letterlijke (of licht vereenvoudigde) zin uit de dialoog als eerste voorbeeld werkt uitstekend: herkenning eerst, variatie daarna. Waarom: het bevestigt de leerling dat hij de dialoog écht begrepen heeft, en het kost geen nieuw vocabulaire-budget.
- **Kort en natuurlijk.** A1-voorbeelden zijn volledige maar korte zinnen zoals een Thai ze echt zou zeggen — inclusief beleefdheidspartikels waar die natuurlijk zijn. Geen kunstmatig uitgeklede telegramzinnen.
- **Gegenderde vormen passen bij de instructiestem.** Eerste persoon is ฉัน, partikel ค่ะ of คะ; nooit ผม of ครับ. Zie vastgelegde beslissing 2 — dit wordt hier in de schrijffase vastgelegd, niet pas bij de audiogeneratie ontdekt.
- **Volgorde is didactiek.** Van eenvoudig naar iets rijker binnen de groep; het eenvoudigste of meest herkenbare voorbeeld staat bovenaan.

### Stap 5 — Transliteratie- en vertaalconventies

**Transliteratie (Paiboon):**

- **Opzoeken, niet reconstrueren.** Voor elk woord dat al in de vocabulairemasterlijst staat, is de daar vastgelegde Paiboon-vorm de enige juiste — kopieer die letterlijk. Waarom dit een harde regel is: Paiboon is uit het hoofd verrassend foutgevoelig, en twee spellingen van hetzelfde woord op één lespagina ondermijnen het vertrouwen van de leerling in het hele systeem.
- **Geaspireerde medeklinkers krijgen géén h.** ข/ค → *k*, ถ/ท → *t*, ผ/พ/ภ → *p*. Schrijf nooit *kh*, *th* of *ph* — dat is RTGS, niet Paiboon. Waarom Paiboon die h niet nodig heeft: de niet-geaspireerde tegenhangers krijgen een eigen schrijfwijze (ก → *g*, ต → *dt*, ป → *bp*), zodat er geen digraaf nodig is om ze te onderscheiden. Waarom dit expliciet vermeld staat: dit is in het verleden structureel misgegaan (167 vocabulairerijen en 19 dialoogblokken moesten van RTGS naar Paiboon gecorrigeerd worden). Het onderscheid blijft wezenlijk voor de uitspraak — ปา (*bpaa*) en พา (*paa*) zijn verschillende woorden — maar het wordt in Paiboon gedragen door *bp* tegenover *p*, niet door een *h*.
- **Klinkerlengte nooit gokken, zeker niet bij อัว.** Of een klinker enkel of dubbel geschreven wordt (*u* vs. *uu*, *a* vs. *aa*) is niet altijd betrouwbaar uit het schriftbeeld af te leiden. Bij twijfel: opzoeken in de masterlijst of naslagwerk, per woord bevestigen. Waarom: een verkeerde klinkerlengte is voor een leerling onhoorbaar fout gespeld — hij leert het verkeerd aan zonder het te merken.
- **Toontekens volgens Paiboon, consequent op elke lettergreep.** Een voorbeeld zonder toontekens is niet "bijna klaar" maar fout.

**Engelse vertaling:**

- **Natuurlijk Engels, trouw aan het Thais.** De vertaling zegt wat de zin betekent in normaal Engels — geen woord-voor-woord-glossen in de vertaalregel zelf. Waarom: de vertaalregel is voor begrip; structuuruitleg hoort in de paragraph of formula, niet in de vertaling.
- **Vertaal de functie van partikels, niet het woord.** ครับ/ค่ะ worden in de vertaling niet als los woord weergegeven; hun beleefdheid zit in de toon van de Engelse zin of blijft onvertaald. Waarom: er bestaat geen Engels equivalent, en een geforceerde vertaling ("yes, polite-particle") leert de leerling iets verkeerds.
- **Consistent met de dialoogvertalingen.** Een zin die (bijna) letterlijk uit de dialoog komt, krijgt dezelfde vertaling als daar. Twee verschillende vertalingen van dezelfde zin op één lespagina zijn een fout, geen stijlvariatie.

### Stap 6 — Leg de conceptkoppelingen en sla de notes op

Koppel de note nu expliciet aan de lesconcepten die ze behandelt — de lijst uit Stap 1, bijgewerkt met wat er tijdens het schrijven eventueel verschoven is (dat gebeurt, en dat is prima, zolang de koppeling het eindresultaat weerspiegelt).

Regels:

- **Claim wat je uitlegt, niets meer.** De toets per concept: "zou een leerling na het lezen van deze note dit concept begrijpen?" Zo nee, geen koppeling.
- **Eén note mag meerdere concepten behandelen** (het cluster uit Stap 1), en **meerdere notes mogen hetzelfde concept behandelen** (bijvoorbeeld een introductie-note en een verdiepings-note in een latere les). Beide zijn normaal.
- **Koppelingen zijn lesgebonden.** Een note behandelt het concept *zoals het in deze les voorkomt* — dat een ander concept in een andere les hetzelfde heet, is niet relevant.

Waarom deze stap niet mag worden overgeslagen of uitgesteld: de koppelingen zijn de brug tussen curriculumplanning en inhoud. De validatie vóór publicatie (Stap 9) beantwoordt de vraag "is alles wat uitleg vereist ook uitgelegd?" uitsluitend via deze koppelingen. Een perfecte note zonder koppeling telt daar als een gat.

#### De notes opslaan

De koppelingen en de note-inhoud belanden in hetzelfde seedbestand, en dat bestand wordt gegenereerd — niet met de hand geschreven.

**Bestandspaden.**

```text
supabase/
  planning/
    07_language_note_planner_prompt_template.md ← blanco template, Stap 1-3
    08_language_note_writer_prompt_template.md  ← blanco template, Stap 2-6
  prompts/language-notes/
    a1_dialog_XX_planner_prompt.md ← ingevuld, audit trail
    a1_dialog_XX_writer_prompt.md  ← ingevuld, audit trail
  generation/language-notes/
    a1_dialog_XX_plan.md           ← plannervoorstel (conceptverdeling + skelet)
    a1_dialog_XX_notes.json        ← goedgekeurde inhoud, met de hand of via de prompt
  seed-data/language-notes/
    a1_dialog_XX_notes.seed.sql    ← gegenereerd, niet met de hand bewerken
  qa/
    verify_language_note_upsert_keys.sql   ← leest alleen; waarom de sleutels bestaan
    verify_language_note_seed_format.sql   ← schrijft en ruimt op; test het formaat
    fixtures/
      language_note_format_fixture_a1_dialog_03.json ← testgeval, geen lesinhoud
      language_note_format_fixture_a1_dialog_01.json ← idem; dekt de phrase-arm
```

De fixtures staan als JSON in de repo, niet als SQL: de SQL wordt door de generator gemaakt vlak voor het verificatiescript draait (zie de kop van dat script). Twee bestanden en niet één, omdat les 3 geen phrases heeft — zonder het bestand van les 1 blijft de `lesson_phrase_id`-arm van de exclusive arc permanent ongetest.

`seed-data/language-notes/*.sql` staat als glob in `supabase/config.toml`, ná `dialogs/*.sql`. Een nieuw lesbestand wordt dus vanzelf meegenomen bij de volgende `db reset`; je hoeft `config.toml` niet per les bij te werken. De volgorde is niet vrijblijvend: de seeds zoeken lessen en koppelrijen op, dus die moeten er al staan.

**Genereren en uitvoeren.**

```
node scripts/generate-language-note-seed.mjs --lesson a1-dialog-XX
psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -f supabase/seed-data/language-notes/a1_dialog_XX_notes.seed.sql
```

**Op Windows/PowerShell.** Twee dingen gaan hier standaard mis, en allebei stil.

Ten eerste is `\` geen regelvervolg in PowerShell — dat is bash-syntax. Deze gids gebruikte die vorm tot 2026-08-06; psql kreeg `-f` dan niet binnen en opende een interactieve sessie in plaats van het bestand te draaien. Dat ziet er niet uit als een fout. Vandaar dat het commando nu op één regel staat, zoals de andere psql-aanroepen in de dialoogworkflowgids.

Ten tweede de tekencodering. Deze seedbestanden staan vol Thais schrift en Paiboon-toontekens (`ɔ́`, `ʉ̀`, `ǎ`). Draait je console op codepage 850 of 1252 — psql waarschuwt daarvoor bij het starten — dan kan die tekst onderweg naar de server beschadigd raken. Zet daarom vooraf:

```powershell
chcp 65001
$env:PGCLIENTENCODING = "UTF8"
```

**Gebruik `-A -P pager=off` bij elke query die Thais aanraakt.** De Windows-console berekent kolombreedtes verkeerd bij Thais schrift met combinerende toontekens: psql lijnt de kolommen uit op tekenaantal, de console rendert ze breder, en het gevolg is dat regels elkaar overschrijven. Op 2026-08-06 leverde dat een uitgelezen `ชาเย็น / chaa yen` op als `chaa yeni-nǎ` — met `i-nǎ` overgebleven uit een eerdere, langere regel. De data was ongeschonden; alleen het scherm loog. `-A` zet psql op ongelijnde uitvoer en haalt het probleem weg.

Controleer daarna of de tekst intact is. Kijk daarvoor **niet** naar uitgelezen Thaise tekst — zie hierboven waarom die onbetrouwbaar is. Vergelijk in plaats daarvan de bytes met de goedgekeurde JSON, via een uitvoer waarin geen enkel Thais teken voorkomt:

```
psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -A -P pager=off -c "select n.note_key, b.block_key, e.example_key, length(e.thai_script) as thai_len, length(e.paiboon) as pb_len, md5(e.thai_script || '|' || e.paiboon) as md5 from public.language_note_examples e join public.language_note_blocks b on b.id = e.block_id join public.language_notes n on n.id = b.language_note_id order by n.display_order, b.display_order, e.display_order;"
```

De verwachte waarden reken je uit het JSON-bestand:

```
node -e "const d=require('./supabase/generation/language-notes/a1_dialog_XX_notes.json'),c=require('crypto');for(const n of d.notes)for(const b of n.blocks)for(const e of b.examples||[])console.log(n.note_key,b.block_key,e.example_key,[...e.thai_script].length,[...e.paiboon].length,c.createHash('md5').update(e.thai_script+'|'+e.paiboon).digest('hex'))"
```

Komt elke md5 overeen, dan staat er in de database exact wat je hebt goedgekeurd. Wijkt er één af, dan wijzen de lengtekolommen aan waar: verschilt `pb_len` maar niet `thai_len`, dan zit de schade in de transliteratie. Gooi die rijen weg (zie "Verwijderen" hieronder) voor je verder gaat — een beschadigde vorm die blijft staan, wordt straks ingesproken.

Waarom md5 en niet "staan er Thaise tekens in": een codepunt-telling zegt alleen dát er Thais schrift is, niet dat het het júiste is. En de eerste versie van deze stap gebruikte zo'n telling met uitgelijnde uitvoer — die werd door precies het overschrijfprobleem hierboven onleesbaar.

Het script leest `supabase/generation/language-notes/a1_dialog_XX_notes.json` en schrijft het seedbestand. Het doet uitsluitend mechanisch werk: sleutels opzoeken via subquery's, volgorde afleiden, tekst escapen. Het beoordeelt geen inhoud en verandert geen letter Thais of Paiboon.

**Het invoercontract.** Dit is het formaat waar de schrijverprompt op mikt. Die prompt is `supabase/planning/08_language_note_writer_prompt_template.md`: hij krijgt het goedgekeurde plan uit Stap 1–3, het woordbudget met Paiboon per woord, en de dialoogtekst, en levert precies dit document terug — alleen JSON, geen toelichting en geen markdown-weergave ernaast. Dat laatste is een bewuste keuze: een tweede weergave die niemand valideert, loopt bij de eerste correctie uit de pas met de JSON, en de generator leest alleen de JSON, dus zo'n afwijking faalt nooit luid. De JSON staat in versiebeheer en de diff erop is de audit trail.

Beide templates volgen de taalregel uit de dialoogworkflowgids ("Taal van de prompttemplates"): Nederlandse invulinstructies en mapping-checklist, Engels promptgedeelte. `07` stond tot 2026-08-06 volledig in het Nederlands.

Het schrijvertemplate is zelfstandig leesbaar; er is geen same-chat-variant zoals `04` naast `06`. Het woordbudget wordt altijd volledig herhaald, ook als de planner in dezelfde chat draaide — wat niet letterlijk in de directe context staat, wordt gereconstrueerd, en dat is precies hoe de RTGS-fout ontstond.

```json
{
  "lesson_key": "a1-dialog-XX",
  "notes": [
    {
      "note_key": "a1-dialog-XX-note-1",
      "title": "Asking yes/no questions with ไหม",
      "blocks": [
        { "block_key": "b1", "block_type": "paragraph", "content": "..." },
        { "block_key": "b2", "block_type": "formula",   "content": "[statement] + ไหม = yes/no question" },
        {
          "block_key": "b3",
          "block_type": "example_group",
          "heading": "Asking",
          "content": null,
          "examples": [
            { "example_key": "e1", "thai_script": "...", "paiboon": "...", "translation_en": "..." }
          ]
        }
      ],
      "concepts": [
        { "type": "vocabulary", "key": "hot" },
        { "type": "grammar",    "key": "adjective_after_noun" },
        { "type": "pattern",    "key": "ja_verb" },
        { "type": "phrase",     "key": "self_introduction_name" }
      ]
    }
  ]
}
```

Zes regels, elk met een reden:

- **`display_order` staat er niet in.** De volgorde van de array *is* de volgorde op het scherm. Dat haalt een hele klasse fouten weg: je kunt geen nummering hebben die niet klopt met de leesvolgorde. Geef je het veld toch mee, dan weigert het script — anders zou het lijken alsof het iets doet.
- **De sleutels staan er wél in, en zijn verplicht.** `note_key`, `block_key`, `example_key`. Ze zijn de identiteit van een rij en bewegen nooit mee met de volgorde: verplaats je een blok, dan verplaats je het object en houd je zijn `block_key`. Zou het script de sleutel uit de positie afleiden, dan zou herordenen de identiteit veranderen en zou de upsert een nieuwe rij invoegen in plaats van de bestaande te verplaatsen — inclusief een wees met zijn voorbeelden en audio.
- **Concepten dragen de mastersleutel**, niet de koppelrij-id: `source_key` voor vocabulaire, `concept_key` voor grammatica, `phrase_key`, `pattern_key`. Zie de waarschuwing in Stap 1. Dit is ook waarom de schrijverprompt de sleutel moet teruggeven en niet `thai_script` of `title` — เดือน bestaat twee keer in `vocabulary_master` en is via script en vertaling niet te onderscheiden.
- **De tekst van een `subheading` hoort in `content`, niet in `heading`.** Dat is contra-intuïtief maar volgt het schema: `heading` bestaat uitsluitend voor `example_group`. De vormcheck van de database dwingt het af.
- **Onbekende velden zijn een fout.** Een prompt die afdrijft levert extra of hernoemde velden op, en dat hoor je liever meteen dan drie lessen later.
- **`[uncertain]` ergens in het bestand is een harde fout.** De schrijverprompt markeert daarmee een Paiboon-vorm die niet uit de meegeleverde lijst kwam. Zo'n markering hoort door een mens beslecht te worden; belandt ze in de database, dan ziet niemand haar ooit nog.

**Wat de generator níet afvangt.** Een note met een lege `concepts`-array komt er gewoon door. Technisch klopt dat — een note zonder claim is een geldig document — maar redactioneel is het precies het gat dat de publicatievalidatie in Stap 9 niet kan zien: de note bestaat, en toch is het concept "niet uitgelegd". De schrijverprompt eist daarom minstens één claim per note, en de QA-checklist in Stap 7 controleert het. Reken hier niet op het script.

**Hoe het seedbestand eruitziet, en waarom.** De conceptclaims zijn het deel dat het makkelijkst fout gaat, en hebben daarom bewust een andere vorm dan de rest:

```sql
insert into public.language_note_concepts
  (language_note_id, lesson_id, lesson_vocabulary_id)
values (
  (select id from public.language_notes where note_key = 'a1-dialog-03-note-1'),
  (select id from public.lessons where lesson_key = 'a1-dialog-03'),
  (select link.id
     from public.lesson_vocabulary link
    where link.lesson_id     = (select id from public.lessons where lesson_key = 'a1-dialog-03')
      and link.vocabulary_id = (select id from public.vocabulary_master where source_key = 'hot'))
)
on conflict (lesson_vocabulary_id, language_note_id)
  where lesson_vocabulary_id is not null
do nothing;
```

- **`values ((select ...))` en niet `select ... from ... where`.** Vindt de subquery niets, dan levert deze vorm `null` op, en dan slaat `language_note_concepts_exactly_one_check` toe: het bestand faalt luid. De `select`-vorm zou nul rijen invoegen en zwijgen — en dan mist er stil een claim waarvan de publicatievalidatie later dénkt dat hij bestaat. Beide gedragingen zijn gemeten in `verify_language_note_seed_format.sql`, sectie 5.
- **Filter op `lesson_id` én de mastersleutel.** `language_note_concepts` wijst naar de koppelrij (`lesson_vocabulary.id`), niet naar de masterrij. Zonder de `lesson_id`-filter pak je de koppelrij van een willekeurige les. De samengestelde foreign key vangt dat af, maar pas nadat je het fout hebt gedaan.
- **Geen `limit 1`.** `(lesson_id, vocabulary_id)` is uniek, dus `limit 1` doet niets behalve een toekomstige dubbele sleutel stilzwijgend verkeerd oplossen in plaats van luid te falen.
- **Het predicaat `where lesson_vocabulary_id is not null` moet mee.** De arbiter is een partiële unique index; zonder het predicaat weigert Postgres met *"there is no unique or exclusion constraint matching the ON CONFLICT specification"*.
- **`do nothing` en niet `do update`.** Alle kolommen van die tabel zijn sleutelkolom of `created_at`. Er valt niets bij te werken: een claim bestaat of bestaat niet.
- **Geen `updated_at = now()` in de do-update-clausules** van notes, blocks en examples. Die tabellen hebben een `BEFORE UPDATE`-trigger die het veld zelf zet. De dialoogseed schrijft die regel wél, en terecht — `dialogs` en `dialog_blocks` hebben zo'n trigger niet.

**Waarom de sleutel niet `display_order` is.** `language_notes`, `language_note_blocks` en `language_note_examples` dragen hun volgorde in een `unique (parent, display_order)`-constraint. Die is niet bruikbaar als botsingssleutel, om twee onafhankelijke redenen.

Technisch: de constraints zijn `deferrable initially immediate` aangemaakt, en Postgres weigert een deferrable unique constraint als `on conflict`-arbiter. Let op bij het narekenen — dit is een *uitvoeringsfout, geen planfout*. `explain (costs off) insert ... on conflict (lesson_id, display_order) ...` slaagt gewoon en drukt zelfs `Conflict Arbiter Indexes: language_notes_lesson_order_unique` af. Wie dit met `EXPLAIN` controleert, concludeert precies het tegenovergestelde van de waarheid.

Inhoudelijk, en dat weegt zwaarder: `display_order` is precies het veld dat je wilt kunnen wijzigen. Een upsert die daarop botst, zou bij het verplaatsen van blok 3 naar positie 1 geen bestaande rij bijwerken maar een nieuwe invoegen, en het oude blok 3 als wees achterlaten. Vandaar de aparte sleutels, toegevoegd in `20260803120000_add_language_note_natural_keys.sql`.

**Herordenen vereist één extra handeling.** Verwissel je de volgorde van blokken of notes, draai het seedbestand dan binnen een transactie:

```sql
begin;
set constraints all deferred;
\i supabase/seed-data/language-notes/a1_dialog_XX_notes.seed.sql
commit;
```

Zonder dat botst de tussenstand op de `display_order`-constraint. Precies daarvoor is die constraint deferrable aangemaakt.

**Wat idempotentie hier wél en niet dekt.** Het bestand opnieuw draaien is de manier om een correctie door te voeren — voor **toevoegen en wijzigen**. Niet voor **verwijderen**: haal je een note, blok, voorbeeld of conceptclaim uit de JSON, dan blijft de rij gewoon in de database staan. Er is geen mechanisme dat rijen opruimt die uit het bestand verdwenen zijn, en dat is een bewuste keuze — een seed die weggelaten rijen verwijdert, wist bij een half afgemaakt bestand stilzwijgend werk.

Verwijderen is dus een aparte, expliciete handeling:

```sql
-- een hele note, inclusief blokken, voorbeelden en claims (cascades)
delete from public.language_notes where note_key = 'a1-dialog-XX-note-2';

-- één blok, inclusief zijn voorbeelden
delete from public.language_note_blocks b
using public.language_notes n
where n.id = b.language_note_id
  and n.note_key = 'a1-dialog-XX-note-1'
  and b.block_key = 'b4';
```

Haal daarna ook de bijbehorende JSON weg, anders komt de rij bij de volgende run terug.

**Controleren.** `supabase/qa/verify_language_note_seed_format.sql` draait de fixture twee keer, controleert dat een tweede run niets toevoegt, dat Thais schrift en apostroffen ongeschonden blijven, dat herordenen de sleutels bij hun rij houdt, en dat een ontbrekend of verkeerd-les concept luid faalt. Het ruimt zichzelf op. Draai het na elke wijziging aan het seedformaat of aan de generator.

### Stap 7 — Redactionele QA van de tekst

Controleer vóór de audio-stap minstens:

- Behandelt elke note precies de concepten uit haar (bijgewerkte) Stap 1-lijst?
- Begint elke note met een paragraph die aan de dialoog verankert?
- Heeft elke uitleg van een patroon of constructie een voorbeeldgroep?
- Bevatten de voorbeelden uitsluitend bekende woorden?
- Is elke Paiboon-vorm gecontroleerd tegen de masterlijst (aspiratie-h, klinkerlengte, tonen)?
- Zijn ครับ/ค่ะ natuurlijk en consequent gebruikt in de voorbeelden, en staat er คะ (niet ค่ะ) aan het eind van een vraag?
- Komt ผม nergens voor in een voorbeeld met ค่ะ of คะ? Eerste persoon is ฉัน, tenzij de note het register-contrast onderwijst.
- Heeft elke note minstens één conceptkoppeling? De generator laat een lege `concepts`-array door.
- Zijn de vertalingen natuurlijk Engels én consistent met de dialoogvertalingen?
- Is er geen subheading als eerste of laatste blok, en geen lege voorbeeldgroep?
- Verdient elk blok zijn plaats? Een formule bij iets zonder vaste vorm, of een tip zonder echte valkuil, is een blok dat er staat om het skelet vol te maken.

Waarom QA vóór audio en niet erna: elke tekstwijziging ná audiogeneratie maakt die audio ongeldig en dwingt tot regenereren. Tekst eerst bevriezen is goedkoper.

**Goedkeuringsmoment:** de volledige tekst van alle notes van de les wordt goedgekeurd vóór er audio wordt gegenereerd.

### Stap 8 — Genereer audio voor de voorbeelden

Elk voorbeeld krijgt eigen audio van de Thaise zin. De werkwijze volgt het patroon van de dialoog-audio (Stap 12 van de dialoogworkflowgids): pas ná goedkeuring van de tekst, in batch, en alleen voor voorbeelden die nog geen audio hebben.

> **Technisch nog niet gebouwd (stand 2026-08-03).** Er is vandaag geen commando voor deze stap. `scripts/generate-audio.mjs` verwerkt uitsluitend `dialog_blocks` en kent `language_note_examples` niet, en `service_role` heeft nog geen grants op de Language Note-tabellen — de migratie die die tabellen aanmaakte houdt die bewust achter tot er een script is dat ze nodig heeft. `audio_url` en `voice_key` blijven dus leeg na het seeden, en het seedformaat vult ze ook niet in. De redactionele regels hieronder gelden onverkort zodra het script er is.
>
> **De twee velden zijn niet hetzelfde soort veld, en dat bepaalt hoe het script ze hoort te behandelen.**
>
> `audio_url` is pure output: het bestaat pas nadat het script een bestand heeft gemaakt. Leeg betekent hier "nog niet gegenereerd", en dat is de enige mogelijke volgorde — audio volgt op bevroren tekst, niet andersom.
>
> `voice_key` is een redactionele beslissing die het script alleen maar uitvoert. **Leeg betekent daarom "gebruik de vaste vrouwelijke standaardstem", niet "onbekend".** Het script hoort die default zelf toe te passen en niet te wachten op een waarde. Waarom die keuze zo vastligt: vastgelegde beslissing 2 maakt die stem de norm, dus voor vrijwel elk voorbeeld is `voice_key` een constante. Die constante in elk voorbeeld herhalen levert alleen ruis op, en in de JSON-invoer (Stap 6) nodigt het het model uit om te gaan variëren waar het niets te kiezen heeft.
>
> Een expliciete `voice_key` is dus uitsluitend bedoeld voor de uitzondering hieronder: een note die het ครับ/ค่ะ-contrast zélf onderwijst. Komt die note er, dan wordt `voice_key` een optioneel veld in het JSON-contract — niet eerder. Een veld toevoegen dat niemand vult, verwatert de betekenis van de default.
>
> Praktisch gevolg voor wie het script bouwt: een voorbeeld met `voice_key is null` krijgt de standaardstem, een voorbeeld met een expliciete waarde krijgt die stem, en een zin die op ครับ eindigt terwijl de standaardstem vrouwelijk is, hoort een waarschuwing te geven in plaats van stil verkeerd ingesproken te worden.

- **Dit is dezelfde tijdelijke TTS-pipeline als bij de dialogen** — later vervangen door opnames met stemacteurs. Investeer geen tijd in het verfraaien ervan; de redactionele regel is alleen: elke gepubliceerde voorbeeldzin heeft audio, en die audio komt overeen met de exacte huidige tekst.
- **Stemkeuze:** voorbeelden in een note zijn *instructiestem*, geen personagestem. Gebruik de vaste vrouwelijke standaardstem voor notes (zie "Vastgelegde redactionele beslissingen"), niet de stem van Mali of Narin. Waarom: een personagestem suggereert ten onrechte dat de zin uit de scène komt, en bindt de note aan een personage dat er inhoudelijk niets mee te maken heeft.
- **Partikel, voornaamwoord en stem moeten overeenkomen.** Een zin die op ค่ะ eindigt wordt door een vrouwenstem ingesproken, een zin op ครับ door een mannenstem — en de eerste persoon in die zin hoort bij dezelfde bundel (ฉัน bij ค่ะ, ผม bij ครับ). Waarom: een mannenstem die ค่ะ zegt is voor elke Thai onmiddellijk fout en leert de leerling een verkeerde koppeling aan; hetzelfde geldt voor een vrouwenstem die ผม zegt. Praktisch betekent dit: kies het partikel in de schrijffase (Stap 4) al passend bij de standaardstem, en wijk alleen af wanneer de note juist het ครับ/ค่ะ-contrast onderwijst — dan krijgen die voorbeelden elk de passende stem.
- **Na elke tekstwijziging aan een voorbeeld wordt de audio van dát voorbeeld opnieuw gegenereerd.** Tekst en audio die niet overeenkomen zijn erger dan geen audio: de leerling traint zijn oor op de verkeerde zin.

### Stap 9 — Validatie vóór publicatie

Vóór de les gepubliceerd wordt, wordt gecontroleerd:

1. Elk lesconcept met `requires_explanation = true` is gekoppeld aan minstens één note van deze les.
2. Elk doelwoord uit `lesson_vocabulary` komt werkelijk voor in de dialoogtekst van de les. Waarom dit hier óók staat: notes putten uit die woordenset, dus een woord dat de dialoog nooit haalde is een lesfout die pas bij het schrijven van de notes zichtbaar wordt. Zie Stap 3 van de dialoogworkflowgids voor de correctie.
3. Geen enkele note is leeg (elke note heeft minstens één blok).
4. Geen enkele voorbeeldgroep is leeg (elke groep heeft minstens één voorbeeld).
5. Elk voorbeeld heeft audio.
6. De Stap 7-checklist is doorlopen voor elke note.

**Punt 1, 3 en 4 zijn geautomatiseerd** in `supabase/qa/verify_language_note_coverage.sql` (2026-08-06). Het script is alleen-lezen — geen transactie, geen rollback — en toont per les een status, gevolgd door drie lijsten die leeg horen te zijn: gevlagde concepten zonder note, notes zonder conceptclaim, en notes of voorbeeldgroepen die leeg zijn. Punt 5 staat er informatief bij en wordt zinvol zodra het audioscript bestaat.

```
psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -A -P pager=off -f supabase/qa/verify_language_note_coverage.sql
```

Een les waarvan de Language Note-workflow nog niet gestart is, krijgt status `geen notes` in plaats van een berg gaten. Dat is werk dat nog moet gebeuren, geen defect, en het scheiden van die twee is wat het rapport leesbaar houdt zolang je halverwege het A1-traject zit.

**Wat het script niet kan zien: een valse claim.** Of een note een concept werkelijk uitlegt of het alleen terloops noemt, is een redactioneel oordeel; het script telt alleen of de claim bestaat. Een note die drie concepten claimt en er één uitlegt, komt hier als volledig gedekt uit. De toets uit Stap 6 blijft dus mensenwerk — het script maakt haar niet overbodig, alleen vindbaar.

Punt 2 en 6 blijven handmatig.

Waarom validatie een aparte stap is en geen doorlopend gevoel: onvolledigheid is tijdens het schrijven normaal en toegestaan (een note mag dagen half af staan). Het enige moment waarop volledigheid afdwingbaar moet zijn, is publicatie.

### Stap 10 — Commit

Commit de redactionele bestanden van deze les samen (conceptverdeling, drafts, definitieve inhoud), volgens hetzelfde principe als de andere twee workflows: alles wat nodig is om te reconstrueren *waarom* de inhoud is zoals ze is, hoort in versiebeheer.

Concreet per les:

- `supabase/prompts/language-notes/a1_dialog_XX_planner_prompt.md` — de ingevulde plannerprompt
- `supabase/prompts/language-notes/a1_dialog_XX_writer_prompt.md` — de ingevulde schrijverprompt
- `supabase/generation/language-notes/a1_dialog_XX_plan.md` — het goedgekeurde plannervoorstel
- `supabase/generation/language-notes/a1_dialog_XX_notes.json` — de goedgekeurde inhoud
- `supabase/seed-data/language-notes/a1_dialog_XX_notes.seed.sql` — het gegenereerde bestand

Het gegenereerde bestand gaat mee in versiebeheer, ook al is het afleidbaar. Reden: het is wat er werkelijk gedraaid heeft, en een diff erop laat zien wat er tussen twee versies aan de database is veranderd — dat leest sneller dan een JSON-diff.

## Bestaande notes bewerken

- **Feitelijke fouten worden direct verbeterd**: een verkeerde Paiboon-vorm, een kromme vertaling, een typfout. Daarna geldt Stap 8: audio van gewijzigde voorbeelden regenereren.
- **Verdieping gaat naar een nieuwe note in de les waar de verdieping thuishoort — nooit naar de oude note.** Wie in les 24 merkt dat de ไหม-uitleg van les 3 "eigenlijk vollediger kan", schrijft een note bij les 24. Waarom: de note van les 3 is geschreven voor een leerling die drie lessen kent; haar eenvoud is haar functie. Retroactief verrijken maakt haar stuk voor precies de leerling voor wie ze bedoeld was.
- **Herstructureren binnen een note mag altijd** (blokken herordenen, een paragraph splitsen, een voorbeeld vervangen), zolang de conceptkoppelingen daarna nog kloppen met wat de note werkelijk uitlegt.
- **Een concept uit een les verwijderen** betekent dat de bijbehorende claim van de note vervalt. Controleer daarna of de note nog bestaansrecht heeft: een note die niets meer behandelt, wordt herschreven of verwijderd — de publicatievalidatie signaleert dit soort wezen.

## Veelvoorkomende fouten

- **Voorbeelden in de lopende tekst.** Voorbeeldzinnen horen in een voorbeeldgroep, nooit uitgeschreven in een paragraph. Waarom: alleen in een groep krijgen ze transliteratie, vertaling én audio; in een paragraph zijn ze dode tekst.
- **De naslag-reflex.** Alles over een onderwerp willen vertellen. De toets: bevat de note iets dat de leerling *op dit punt in het curriculum* niet kan gebruiken? Schrappen.
- **Paiboon uit het hoofd.** De meest voorkomende én best verstopte fout. Altijd de masterlijst als bron nemen; aspiratie-h en klinkerlengte zijn de bekende recidivisten.
- **Nieuwe woorden in voorbeelden.** Voelt onschuldig, is het niet — zie Stap 4.
- **Concepten claimen die alleen vermeld worden.** Ondermijnt de publicatievalidatie — zie Stap 6.
- **Formule zonder voorbeeldgroep.** Een schema zonder toepassing is voor een A1-leerling betekenisloos.
- **Te veel concepten in één note.** Tegen het lesfase-maximum aan: splitsen.
- **Blokken toevoegen om een aantal te halen.** Een formule bij iets wat geen patroon is, of een tip zonder valkuil. Ontstaat wanneer de blokrichtlijn als streefaantal gelezen wordt in plaats van als plafond — zie Stap 3.
- **Audio vergeten na een tekstcorrectie.** Tekst en audio lopen dan uit elkaar — erger dan geen audio.
- **ครับ/ค่ะ die niet bij de stem past.** Vastleggen in de schrijffase, niet pas bij audiogeneratie ontdekken.
- **ผม in een zin die op ค่ะ eindigt.** Beide voornaamwoorden staan vanaf les 1 in het woordbudget, dus het budget vangt dit niet. Stem, partikel en eerste persoon horen bij elkaar — zie beslissing 2.
- **Een subheading als afsluiter of een lege voorbeeldgroep laten staan** na herstructureren.

## Toekomstige uitbreidbaarheid

- **Vergelijkingsblokken** (bijvoorbeeld ไหม naast หรือ in twee kolommen) zijn voorzien als mogelijk later bloktype. Tot dat bestaat, wordt een vergelijking gewoon geschreven als twee voorbeeldgroepen met eigen koppen — dat blijft ook daarna een geldige vorm.
- **Herbruikbare vocabulairevoorbeelden** (voorbeelden die bij een wóórd horen in plaats van bij een les) zijn een apart systeem met een eigen workflow: `vocabulary_examples` bestaat sinds `20260722130000`, en `docs/thai_a1_vocabulary_workflow_guide.md` beschrijft de redactionele regels. Language Note-voorbeelden blijven lesgebonden; probeer ze niet alvast "herbruikbaar te schrijven" — dat levert vage voorbeelden op die nergens goed passen. Andersom geldt hetzelfde: een canoniek voorbeeld mag juist níet aan de dialoog verankeren. Beide regels zijn correct binnen hun eigen eigenaarschap.
- **Stemacteurs vervangen de TTS-audio** zodra het A1-traject inhoudelijk staat. De workflow verandert dan alleen in Stap 8 (opnemen in plaats van genereren); alle redactionele regels — partikel/stem-overeenkomst, audio volgt bevroren tekst — blijven gelden.
- **Andere platformen** (een toekomstige mobiele app) lezen dezelfde inhoud. Schrijf dus nooit platform-specifiek ("klik hieronder", "scroll naar rechts") — de note weet niet waar ze wordt weergegeven.

## Vastgelegde redactionele beslissingen

Deze beslissingen zijn vastgelegd op 2026-07-31 en gelden voor alle notes. Ze zijn bewust niet per note herzienbaar: hun waarde zit juist in de uniformiteit. Wil je er structureel van afwijken, wijzig dan deze lijst — niet één note.

1. **De note-inhoud is Engelstalig.** Alle leerlinggerichte tekst — titels, paragraphs, tips, vertalingen — staat in het Engels. Waarom: consistent met de leerlinginterface en met de dialoogvertalingen; een tweetalige leeromgeving dwingt de leerling voortdurend te schakelen.
2. **Eén vrouwelijke standaardstem, en dus ค่ะ als standaardpartikel.** Alle note-voorbeelden gebruiken dezelfde neutrale instructiestem; de bestaande stemconfiguratie heeft daar al een geschikte vrouwenstem voor. Een mannenstem wordt alleen ingezet in voorbeelden die het ครับ/ค่ะ-contrast zélf onderwijzen. Waarom één vaste keuze: ze voorkomt een stemdiscussie per note, en ze maakt de partikelkeuze in de schrijffase (Stap 4) een automatisme in plaats van een valkuil.

   **Gegenderde elementen vormen één bundel.** Stem, beleefdheidspartikel én eerste persoon horen bij elkaar; klopt er één niet, dan klopt de zin niet. Voor de vrouwelijke standaardstem:

   | | Standaard in note-voorbeelden |
   | --- | --- |
   | eerste persoon | ฉัน (*chǎn*) — nooit ผม |
   | mededeling | ค่ะ (*kâ*) |
   | vraag | คะ (*ká*) |

   Twee dingen die zonder deze tabel misgaan. **Ten eerste het partikel:** ค่ะ en คะ zijn niet uitwisselbaar — ชอบเค้กไหม**คะ**, nooit ไหม**ค่ะ**. De vijf bestaande dialogen doen dit consequent (nul treffers voor ไหมค่ะ), maar de regel stond nergens, en een model dat alleen "ค่ะ is het standaardpartikel" leest, zet het ook achter een vraag. **Ten tweede het voornaamwoord:** `vocabulary_master` bevat zowel `i` (ฉัน) als `i_male` (ผม), allebei geïntroduceerd in les 1, dus allebei staan ze vanaf les 1 in het woordbudget van elke les. Niets in dat budget verhindert `ผมชอบกาแฟค่ะ` — een mannelijk voornaamwoord met een vrouwelijk partikel, even fout als een mannenstem die ค่ะ zegt.

   Waarom dit gat juist bij notes bestaat en niet bij dialogen: in een dialoog regelen de personages het. Narin is man, Mali is vrouw, en daarmee liggen partikel en voornaamwoord vast zonder dat er een regel voor nodig is. Een note-voorbeeld heeft geen personage, alleen de instructiestem — precies het element dat de keuze automatisch maakte, is weg.

   ผม en ครับ (*kráp*, verandert niet van vorm) worden samen gebruikt, en alleen in een note die het register-contrast zélf onderwijst.
3. **Formulenotatie ligt vast:** Engelse slotnamen tussen vierkante haken, vaste Thaise elementen in Thais schrift, `=` gevolgd door de functie. Dus: `[statement] + ไหม = yes/no question`. Waarom: de leerling leert het schemaformaat één keer; elke variatie kost hem opnieuw aandacht die naar de inhoud had moeten gaan.
4. **Een voorbeeldgroep krijgt een kop zodra er twee of meer groepen in dezelfde note staan**, zodat ze onderscheidbaar zijn. Een intro-zin komt er alleen bij wanneer de voorbeelden zonder context verkeerd gelezen kunnen worden. Geen van beide is ooit verplicht bij één enkele groep. Waarom: koppen zijn navigatie, intro's zijn betekenisredding — ze lossen verschillende problemen op en horen niet standaard samen.
5. **Notes volgen dezelfde prompt- en outputstructuur als de dialoogworkflow**, met prompt en output per les bewaard in versiebeheer. Waarom: die audit trail heeft zich bij dialogen bewezen, en de conceptlijst uit Stap 1 is een natuurlijke prompt-input. Het AI-kanaal volgt de bestaande projectpraktijk.

   **Verduidelijkt op 2026-08-06:** "dezelfde structuur" slaat op het *kanaal* — blanco template in `planning/`, ingevulde prompt in `prompts/`, modeloutput in `generation/`, alles in versiebeheer — niet op het bestandsformaat. De dialoogworkflow levert markdown omdat een mens die output naar SQL overzet; de schrijverprompt levert JSON omdat een generator die output leest. Er komt geen markdown-weergave naast de JSON: een tweede weergave die niemand valideert, loopt bij de eerste correctie uit de pas, en niets faalt er luid op. De planneroutput is wél markdown, want die wordt alleen door een mens gelezen.
6. **Notes worden per les genummerd in leesvolgorde:** `a1-dialog-03-note-1`, `a1-dialog-03-note-2`, enzovoort. Waarom: bestandsnamen en leesvolgorde vallen dan samen, zoals bij `a1_dialog_XX`.

## Praktische checklist per les

1. Vul `07_language_note_planner_prompt_template.md` met de brief-view-output; het voorstel dekt conceptverdeling, titels en blokskeletten (Stap 1–3). Laat het goedkeuren en bewaar de gecorrigeerde versie als `generation/language-notes/a1_dialog_XX_plan.md`.
2. Vul `08_language_note_writer_prompt_template.md` met dat goedgekeurde plan, het woordbudget en de dialoogtekst (Stap 2–6).
3. Sla de modeloutput op als `generation/language-notes/a1_dialog_XX_notes.json` — één JSON-document, geen toelichting.
4. Controleer elke Paiboon-vorm tegen de masterlijst; controleer vertalingen op natuurlijkheid en consistentie met de dialoog (Stap 5).
5. Controleer de conceptkoppelingen — claim alleen wat werkelijk wordt uitgelegd, en let erop dat elke note er minstens één heeft; de generator dwingt dat niet af (Stap 6).
6. Draai `generate-language-note-seed.mjs`, dan `psql -f` (Stap 6).
7. Doorloop de redactionele QA-checklist en laat de tekst goedkeuren (Stap 7).
8. Genereer audio voor alle voorbeelden; bewaak de partikel/stem-overeenkomst (Stap 8).
9. Valideer vóór publicatie: dekking, geen lege notes of groepen, audio compleet (Stap 9).
10. Commit de redactionele bestanden samen — inclusief de twee ingevulde prompts en het plan (Stap 10).
