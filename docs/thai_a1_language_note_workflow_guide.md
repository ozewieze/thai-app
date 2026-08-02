# Language Note-workflowgids

Deze gids beschrijft de herhaalbare redactionele workflow voor het schrijven van Language Notes, in dezelfde geest als `docs/thai_a1_dialog_workflow_guide.md` en `docs/illustration-system/04_illustration_workflow_guide.md`: de database blijft bron van waarheid, alleen goedgekeurde eindresultaten worden definitief opgeslagen, en elke stap heeft een expliciet goedkeuringsmoment.

Dit is een **redactionele** gids: ze beschrijft wat een auteur beslist en schrijft, niet hoe het technisch wordt opgeslagen. De technische kant (schema, migraties, seeds) is een apart onderwerp en hoort hier bewust niet thuis — regels over inhoud verouderen veel trager dan implementatiedetails, en dit document moet ook bruikbaar blijven als de opslag ooit verandert.

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

| Lesfase (`sequence_number`) | Notes per les | Blokken per note (richtlijn) |
| --------------------------- | ------------- | ---------------------------- |
| 1–10                        | 1–2           | 3–5                          |
| 11–30                       | 2–3           | 4–6                          |
| 31+                         | 2–4           | 4–7                          |

Dit is een richtlijn, geen harde grens. De achterliggende logica: vroege lessen introduceren weinig maar fundamenteel materiaal (één stevige note is beter dan drie dunne), latere lessen combineren meer concepten en verdragen meer notes. Een note die boven de ~7 blokken uitkomt behandelt vrijwel zeker twee onderwerpen en moet gesplitst worden.

De volgorde van notes binnen een les is betekenisvol: de leerling leest ze van boven naar onder. Zet de note over het centrale lesdoel eerst, ondersteunende notes (uitspraak, register, cultuur) daarna. Waarom: de eerste note bepaalt of de leerling de dialoog begrijpt; de rest verdiept.

## Stapsgewijze workflow per Language Note

### Stap 1 — Bepaal de behandelde concepten

Begin niet met schrijven maar met afbakenen. Verzamel de lesconcepten met `requires_explanation = true` (vocabulaire, grammatica, phrases, patterns) en verdeel ze over het geplande aantal notes: welke concepten vormen samen één uitlegbaar geheel, en welke verdienen een eigen note?

Wijkt je oordeel hier af van de vlag — een gevlagd concept blijkt toch geen note nodig te hebben, of een niet-gevlagd concept juist wel — pas dan het seedbestand aan; dat is de bron van waarheid. Breng de lokale database daarna in lijn door datzelfde seedbestand opnieuw te draaien: de leslink-seeds zijn idempotent, dus de gewijzigde waarden overschrijven wat er staat. Doe het niet omgekeerd: een correctie die alleen in de database staat, verdwijnt bij de eerstvolgende reset.

Leg dit vast als een simpel lijstje per note vóór je iets anders doet. Waarom eerst: de conceptafbakening bepaalt titel, structuur én voorbeelden. Wie eerst schrijft en achteraf kijkt welke concepten "erin zaten", krijgt notes die half over twee onderwerpen gaan.

**Goedkeuringsmoment:** de verdeling concepten → notes wordt goedgekeurd vóór er geschreven wordt.

### Stap 2 — Kies de titel

De titel is wat de leerling in de les ziet staan. Conventies:

- **Functioneel, niet grammaticaal.** Beschrijf wat de leerling ermee kán, niet hoe het verschijnsel heet: *"Asking yes/no questions with ไหม"*, niet *"The interrogative particle ไหม"*. Waarom: een A1-leerling kent de vakterm niet en hoeft die ook niet te kennen; de functie is wat hij zoekt als hij later terugbladert.
- **Neem het Thaise sleutelwoord op in Thais schrift** wanneer de note om één woord of partikel draait. Waarom: de leerling legt zo meteen de link met wat hij in de dialoog zag, en went aan het schriftbeeld.
- **Kort:** richtlijn maximaal ~60 tekens. Waarom: titels worden ook in overzichten en navigatie getoond; lange titels breken daar af.
- **Uniek binnen de les.** Twee notes met bijna dezelfde titel betekenen vrijwel altijd dat de conceptverdeling van Stap 1 niet klopt.

### Stap 3 — Ontwerp de blokstructuur

Bepaal het skelet van de note vóór je de tekst schrijft, als een simpel lijstje bloktypes in volgorde. Het standaardskelet voor een taalpatroon-note:

```
1. paragraph      — wat is dit en waarom kwam je het tegen in de dialoog
2. formula        — het patroon schematisch (alleen bij patroon-achtige concepten)
3. example_group  — 2–4 voorbeelden van het patroon
4. usage_tip      — één praktische waarschuwing of tip
```

Richtlijnen per bloktype, met de reden erbij:

- **paragraph** — het werkpaard. Elke note begint met een paragraph die het concept in twee tot vier zinnen introduceert en verankert aan de dialoog ("In the dialogue, Mali asked ... — that little word at the end is ..."). Waarom verankeren: de leerling heeft de dialoog net gelezen; uitleg die daaraan vasthaakt beklijft beter dan abstracte uitleg. Eén idee per paragraph — een tweede idee krijgt een eigen paragraph.
- **subheading** — alleen voor notes met duidelijk gescheiden deelonderwerpen (bijvoorbeeld "Asking" en "Answering"). Nooit als eerste blok (de titel doet dat werk al), nooit als laatste blok (een kop zonder inhoud eronder is een lege belofte), nooit twee direct na elkaar. Waarom terughoudend: in een note van 4–6 blokken creëren koppen vooral visuele ruis; ze verdienen zich pas terug bij langere notes.
- **formula** — het patroon in schemavorm, bijvoorbeeld `[statement] + ไหม = yes/no question`. Slots in vierkante haken en in het Engels, vaste Thaise elementen in Thais schrift. Eén formule per blok; een tweede patroon krijgt een eigen formula-blok (meestal onder een eigen subheading). Waarom een apart bloktype en geen vetgedrukte tekstregel: formules worden visueel anders weergegeven en moeten als zelfstandig element herbruikbaar en herkenbaar blijven.
- **example_group** — zie Stap 4. Verplicht bij elke note die een patroon of constructie uitlegt. Waarom verplicht: uitleg zonder voorbeelden is voor een A1-leerling niet verifieerbaar — het voorbeeld ís het bewijs dat hij het begrepen heeft.
- **usage_tip** — één concrete tip: een valkuil, een beleefdheidsnuance, een verschil met het Engels. Eén tip per blok, en maximaal één à twee tip-blokken per note. Waarom beperkt: tips ontlenen hun kracht aan schaarste; vijf tips zijn een tweede uitlegtekst in vermomming.

**Goedkeuringsmoment:** het skelet (bloktypes + volgorde + welke voorbeelden er ongeveer komen) wordt goedgekeurd vóór de volledige tekst wordt geschreven. Waarom: een structuurfout herstellen kost na het uitschrijven vijf keer zoveel werk.

### Stap 4 — Schrijf de voorbeeldgroepen

Een voorbeeldgroep bestaat uit een optionele kop, een optionele intro-zin en twee tot vier voorbeelden. Elk voorbeeld is een drieluik: Thais schrift, Paiboon-transliteratie, Engelse vertaling.

Redactionele regels:

- **Eén taalpunt per groep.** Alle voorbeelden in één groep illustreren hetzelfde punt. Wil je een contrast tonen (vraag vs. antwoord, mannelijk vs. vrouwelijk partikel), gebruik dan twee groepen met elk een korte kop, of één groep waarvan de intro het contrast expliciet benoemt. Waarom: de leerling scant voorbeelden op het patroon dat ze gemeen hebben; een afwijker saboteert precies dat.
- **Alleen bekende woorden.** Voorbeelden gebruiken uitsluitend vocabulaire uit deze les of eerdere lessen. Een nieuw woord "smokkelen" omdat het zo'n mooi voorbeeld oplevert is verboden. Waarom: de leerling kan niet onderscheiden wat hij hoort te kennen en wat niet; elk onbekend woord in een voorbeeld voelt als een gat in zijn kennis.
- **Hergebruik dialoogzinnen waar het kan.** Een letterlijke (of licht vereenvoudigde) zin uit de dialoog als eerste voorbeeld werkt uitstekend: herkenning eerst, variatie daarna. Waarom: het bevestigt de leerling dat hij de dialoog écht begrepen heeft, en het kost geen nieuw vocabulaire-budget.
- **Kort en natuurlijk.** A1-voorbeelden zijn volledige maar korte zinnen zoals een Thai ze echt zou zeggen — inclusief beleefdheidspartikels waar die natuurlijk zijn. Geen kunstmatig uitgeklede telegramzinnen.
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

### Stap 6 — Leg de conceptkoppelingen

Koppel de note nu expliciet aan de lesconcepten die ze behandelt — de lijst uit Stap 1, bijgewerkt met wat er tijdens het schrijven eventueel verschoven is (dat gebeurt, en dat is prima, zolang de koppeling het eindresultaat weerspiegelt).

Regels:

- **Claim wat je uitlegt, niets meer.** De toets per concept: "zou een leerling na het lezen van deze note dit concept begrijpen?" Zo nee, geen koppeling.
- **Eén note mag meerdere concepten behandelen** (het cluster uit Stap 1), en **meerdere notes mogen hetzelfde concept behandelen** (bijvoorbeeld een introductie-note en een verdiepings-note in een latere les). Beide zijn normaal.
- **Koppelingen zijn lesgebonden.** Een note behandelt het concept *zoals het in deze les voorkomt* — dat een ander concept in een andere les hetzelfde heet, is niet relevant.

Waarom deze stap niet mag worden overgeslagen of uitgesteld: de koppelingen zijn de brug tussen curriculumplanning en inhoud. De validatie vóór publicatie (Stap 9) beantwoordt de vraag "is alles wat uitleg vereist ook uitgelegd?" uitsluitend via deze koppelingen. Een perfecte note zonder koppeling telt daar als een gat.

### Stap 7 — Redactionele QA van de tekst

Controleer vóór de audio-stap minstens:

- Behandelt elke note precies de concepten uit haar (bijgewerkte) Stap 1-lijst?
- Begint elke note met een paragraph die aan de dialoog verankert?
- Heeft elke uitleg van een patroon of constructie een voorbeeldgroep?
- Bevatten de voorbeelden uitsluitend bekende woorden?
- Is elke Paiboon-vorm gecontroleerd tegen de masterlijst (aspiratie-h, klinkerlengte, tonen)?
- Zijn ครับ/ค่ะ natuurlijk en consequent gebruikt in de voorbeelden?
- Zijn de vertalingen natuurlijk Engels én consistent met de dialoogvertalingen?
- Is er geen subheading als eerste of laatste blok, en geen lege voorbeeldgroep?

Waarom QA vóór audio en niet erna: elke tekstwijziging ná audiogeneratie maakt die audio ongeldig en dwingt tot regenereren. Tekst eerst bevriezen is goedkoper.

**Goedkeuringsmoment:** de volledige tekst van alle notes van de les wordt goedgekeurd vóór er audio wordt gegenereerd.

### Stap 8 — Genereer audio voor de voorbeelden

Elk voorbeeld krijgt eigen audio van de Thaise zin. De werkwijze volgt het patroon van de dialoog-audio (Stap 12 van de dialoogworkflowgids): pas ná goedkeuring van de tekst, in batch, en alleen voor voorbeelden die nog geen audio hebben.

- **Dit is dezelfde tijdelijke TTS-pipeline als bij de dialogen** — later vervangen door opnames met stemacteurs. Investeer geen tijd in het verfraaien ervan; de redactionele regel is alleen: elke gepubliceerde voorbeeldzin heeft audio, en die audio komt overeen met de exacte huidige tekst.
- **Stemkeuze:** voorbeelden in een note zijn *instructiestem*, geen personagestem. Gebruik de vaste vrouwelijke standaardstem voor notes (zie "Vastgelegde redactionele beslissingen"), niet de stem van Mali of Narin. Waarom: een personagestem suggereert ten onrechte dat de zin uit de scène komt, en bindt de note aan een personage dat er inhoudelijk niets mee te maken heeft.
- **Partikel en stem moeten overeenkomen.** Een zin die op ค่ะ eindigt wordt door een vrouwenstem ingesproken, een zin op ครับ door een mannenstem. Waarom: een mannenstem die ค่ะ zegt is voor elke Thai onmiddellijk fout en leert de leerling een verkeerde koppeling aan. Praktisch betekent dit: kies het partikel in de schrijffase (Stap 4) al passend bij de standaardstem, en wijk alleen af wanneer de note juist het ครับ/ค่ะ-contrast onderwijst — dan krijgen die voorbeelden elk de passende stem.
- **Na elke tekstwijziging aan een voorbeeld wordt de audio van dát voorbeeld opnieuw gegenereerd.** Tekst en audio die niet overeenkomen zijn erger dan geen audio: de leerling traint zijn oor op de verkeerde zin.

### Stap 9 — Validatie vóór publicatie

Vóór de les gepubliceerd wordt, wordt gecontroleerd:

1. Elk lesconcept met `requires_explanation = true` is gekoppeld aan minstens één note van deze les.
2. Elk doelwoord uit `lesson_vocabulary` komt werkelijk voor in de dialoogtekst van de les. Waarom dit hier óók staat: notes putten uit die woordenset, dus een woord dat de dialoog nooit haalde is een lesfout die pas bij het schrijven van de notes zichtbaar wordt. Zie Stap 3 van de dialoogworkflowgids voor de correctie.
3. Geen enkele note is leeg (elke note heeft minstens één blok).
4. Geen enkele voorbeeldgroep is leeg (elke groep heeft minstens één voorbeeld).
5. Elk voorbeeld heeft audio.
6. De Stap 7-checklist is doorlopen voor elke note.

Vandaag is dit een handmatige controle; het is de bedoeling dat dit een geautomatiseerd publicatierapport wordt dat precies deze punten afloopt. De workflow verandert daardoor niet — alleen wie het lijstje afvinkt.

Waarom validatie een aparte stap is en geen doorlopend gevoel: onvolledigheid is tijdens het schrijven normaal en toegestaan (een note mag dagen half af staan). Het enige moment waarop volledigheid afdwingbaar moet zijn, is publicatie.

### Stap 10 — Commit

Commit de redactionele bestanden van deze les samen (conceptverdeling, drafts, definitieve inhoud), volgens hetzelfde principe als de andere twee workflows: alles wat nodig is om te reconstrueren *waarom* de inhoud is zoals ze is, hoort in versiebeheer.

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
- **Te veel concepten in één note.** Boven de ~7 blokken: splitsen.
- **Audio vergeten na een tekstcorrectie.** Tekst en audio lopen dan uit elkaar — erger dan geen audio.
- **ครับ/ค่ะ die niet bij de stem past.** Vastleggen in de schrijffase, niet pas bij audiogeneratie ontdekken.
- **Een subheading als afsluiter of een lege voorbeeldgroep laten staan** na herstructureren.

## Toekomstige uitbreidbaarheid

- **Vergelijkingsblokken** (bijvoorbeeld ไหม naast หรือ in twee kolommen) zijn voorzien als mogelijk later bloktype. Tot dat bestaat, wordt een vergelijking gewoon geschreven als twee voorbeeldgroepen met eigen koppen — dat blijft ook daarna een geldige vorm.
- **Herbruikbare vocabulairevoorbeelden** (voorbeelden die bij een wóórd horen in plaats van bij een les) zijn een apart, nog niet gebouwd systeem. Language Note-voorbeelden blijven lesgebonden; probeer ze niet alvast "herbruikbaar te schrijven" — dat levert vage voorbeelden op die nergens goed passen.
- **Stemacteurs vervangen de TTS-audio** zodra het A1-traject inhoudelijk staat. De workflow verandert dan alleen in Stap 8 (opnemen in plaats van genereren); alle redactionele regels — partikel/stem-overeenkomst, audio volgt bevroren tekst — blijven gelden.
- **Andere platformen** (een toekomstige mobiele app) lezen dezelfde inhoud. Schrijf dus nooit platform-specifiek ("klik hieronder", "scroll naar rechts") — de note weet niet waar ze wordt weergegeven.

## Vastgelegde redactionele beslissingen

Deze beslissingen zijn vastgelegd op 2026-07-31 en gelden voor alle notes. Ze zijn bewust niet per note herzienbaar: hun waarde zit juist in de uniformiteit. Wil je er structureel van afwijken, wijzig dan deze lijst — niet één note.

1. **De note-inhoud is Engelstalig.** Alle leerlinggerichte tekst — titels, paragraphs, tips, vertalingen — staat in het Engels. Waarom: consistent met de leerlinginterface en met de dialoogvertalingen; een tweetalige leeromgeving dwingt de leerling voortdurend te schakelen.
2. **Eén vrouwelijke standaardstem, en dus ค่ะ als standaardpartikel.** Alle note-voorbeelden gebruiken dezelfde neutrale instructiestem; de bestaande stemconfiguratie heeft daar al een geschikte vrouwenstem voor. Een mannenstem wordt alleen ingezet in voorbeelden die het ครับ/ค่ะ-contrast zélf onderwijzen. Waarom één vaste keuze: ze voorkomt een stemdiscussie per note, en ze maakt de partikelkeuze in de schrijffase (Stap 4) een automatisme in plaats van een valkuil.
3. **Formulenotatie ligt vast:** Engelse slotnamen tussen vierkante haken, vaste Thaise elementen in Thais schrift, `=` gevolgd door de functie. Dus: `[statement] + ไหม = yes/no question`. Waarom: de leerling leert het schemaformaat één keer; elke variatie kost hem opnieuw aandacht die naar de inhoud had moeten gaan.
4. **Een voorbeeldgroep krijgt een kop zodra er twee of meer groepen in dezelfde note staan**, zodat ze onderscheidbaar zijn. Een intro-zin komt er alleen bij wanneer de voorbeelden zonder context verkeerd gelezen kunnen worden. Geen van beide is ooit verplicht bij één enkele groep. Waarom: koppen zijn navigatie, intro's zijn betekenisredding — ze lossen verschillende problemen op en horen niet standaard samen.
5. **Notes volgen dezelfde prompt- en outputstructuur als de dialoogworkflow**, met prompt en output per les bewaard in versiebeheer. Waarom: die audit trail heeft zich bij dialogen bewezen, en de conceptlijst uit Stap 1 is een natuurlijke prompt-input. Het AI-kanaal volgt de bestaande projectpraktijk.
6. **Notes worden per les genummerd in leesvolgorde:** `a1-dialog-03-note-1`, `a1-dialog-03-note-2`, enzovoort. Waarom: bestandsnamen en leesvolgorde vallen dan samen, zoals bij `a1_dialog_XX`.

## Praktische checklist per les

1. Verzamel de `requires_explanation`-concepten en verdeel ze over notes; laat de verdeling goedkeuren (Stap 1).
2. Kies per note een functionele titel met het Thaise sleutelwoord (Stap 2).
3. Ontwerp per note het blokskelet en laat het goedkeuren (Stap 3).
4. Schrijf paragraphs, formules, voorbeeldgroepen en tips volgens de blokregels (Stap 3–4).
5. Controleer elke Paiboon-vorm tegen de masterlijst; controleer vertalingen op natuurlijkheid en consistentie met de dialoog (Stap 5).
6. Leg de conceptkoppelingen — claim alleen wat werkelijk wordt uitgelegd (Stap 6).
7. Doorloop de redactionele QA-checklist en laat de tekst goedkeuren (Stap 7).
8. Genereer audio voor alle voorbeelden; bewaak de partikel/stem-overeenkomst (Stap 8).
9. Valideer vóór publicatie: dekking, geen lege notes of groepen, audio compleet (Stap 9).
10. Commit de redactionele bestanden samen (Stap 10).
