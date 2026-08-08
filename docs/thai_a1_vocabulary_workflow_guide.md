# Vocabulary Card-workflowgids

Deze gids beschrijft de herhaalbare redactionele workflow voor het schrijven van Vocabulary Cards en hun canonieke voorbeelden, in dezelfde geest als `docs/thai_a1_dialog_workflow_guide.md`, `docs/illustration-system/04_illustration_workflow_guide.md` en `docs/thai_a1_language_note_workflow_guide.md`: de database blijft bron van waarheid, alleen goedgekeurde eindresultaten worden definitief opgeslagen, en elke stap heeft een expliciet goedkeuringsmoment.

Dit is een **redactionele** gids: ze beschrijft wat een auteur beslist en schrijft, niet hoe het technisch wordt opgeslagen. De technische kant (schema, migraties, seeds, audioscripts) is een apart onderwerp en hoort hier bewust niet thuis — regels over inhoud verouderen veel trager dan implementatiedetails, en dit document moet ook bruikbaar blijven als de opslag ooit verandert.

Deze workflow start pas **nadat** de dialoog van de les volledig is goedgekeurd en opgeslagen (Stap 10 van de dialoogworkflowgids), om dezelfde reden als bij de Language Notes: zolang de dialoog nog kan veranderen, kan de woordenset van de les nog verschuiven. Let op de nuance die deze gids uniek maakt: je schrijft de voorbeelden *na* de dialoog, maar je schrijft ze zó dat ze zonder die dialoog overeind blijven. Zie "Canonieke voorbeelden zijn lesneutraal" hieronder.

## Wat een Vocabulary Card wél en niet is

Een Vocabulary Card is de presentatie van **één woord uit de masterlijst**, zoals de leerling het in een les tegenkomt: het Thaise schrift, de Paiboon-transliteratie, de Engelse betekenis, de woordsoort en het register, met audio van het woord zelf en één **canonieke voorbeeldzin** die toont hoe het woord in een echte zin functioneert.

Een Vocabulary Card is **niet**:

- **Een woordenboekingang.** De card toont de betekenis die de leerling in dit curriculum nodig heeft, niet alle betekenissen die het woord kan hebben. Waarom: een A1-leerling die vier betekenissen leest, onthoudt er nul. Een tweede betekenis die er werkelijk toe doet, krijgt een eigen kaart met een eigen gloss in de les waar ze relevant wordt — zie vastgelegde beslissing 3.
- **Een Language Note.** De card toont; de note legt uit. Zodra je merkt dat je in een voorbeeld iets wil *uitleggen* — waarom de woordvolgorde zo is, wanneer je dit woord wel en niet gebruikt — hoort dat in een Language Note van die les, en zet je `requires_explanation` op het lesconcept.
- **Een tweede dialoog.** Voorbeelden zijn losstaande, zelfstandig leesbare zinnen. Ze hebben geen personages, geen scène en geen onderlinge samenhang.

## De twee eigenaarschappen

Dit is het kernconcept van deze gids, en de meeste fouten in deze workflow zijn een verwarring tussen de twee.

**Master-eigendom — het woord en zijn voorbeelden.** Het lemma (Thais schrift, Paiboon, gloss, woordsoort, register, gebruiksnotitie, lemma-audio) en zijn canonieke voorbeelden horen bij het wóórd. Ze bestaan één keer, worden één keer geschreven, en verschijnen ongewijzigd in élke les waar dat woord voorkomt — of dat er nu één is of zeven.

**Lesgebonden — de rol van het woord in déze les.** Per les wordt vastgelegd welke `role` het woord speelt (`target`, `supporting`, `review`, `bonus`), in welke volgorde het getoond wordt (`display_order`), of het geschreven uitleg nodig heeft (`requires_explanation`) en eventueel een lesspecifieke notitie (`notes`). Diezelfde woordkaart kan in les 3 een doelwoord zijn en in les 24 een herhalingswoord; dat verschil zit uitsluitend hier.

De praktische consequentie, en meteen de belangrijkste redactionele regel van deze gids:

> **Canonieke voorbeelden zijn lesneutraal.** Een voorbeeld mag nergens naar één specifieke les verwijzen — niet naar de scène, niet naar de personages, niet naar "zoals je net zag". Waarom: het voorbeeld wordt ook getoond in les 24, waar die scène nooit heeft plaatsgevonden.

Dit is precies het omgekeerde van de Language Note-regel, waar voorbeelden juist aan de dialoog verankerd moeten worden. Beide regels zijn correct binnen hun eigen eigenaarschap. Wie de twee door elkaar haalt, schrijft óf lesnotes die nergens landen, óf woordkaarten die in latere lessen onbegrijpelijk worden.

Concreet betekent lesneutraal:

- **Geen personagenamen** in een canoniek voorbeeld. Gebruik neutrale onderwerpen of het naamloze patroon. Mali en Narin horen in de dialoog en in de Language Notes, niet op de woordkaart.
- **Geen letterlijke overname van dialoogzinnen.** Verleidelijk, want de zin is al geschreven, gecontroleerd en vertaald — maar een zin die uit de scène van les 3 komt, oogt in les 24 willekeurig. Een voorbeeld dat *lijkt* op een dialoogzin is prima; een kopie is dat niet.
- **Geen verwijzing naar de leerstof-volgorde** ("this is the polite form you learned earlier"). De card weet niet waar de leerling zich bevindt.

## De first_lesson_id-progressieregel

Een canoniek voorbeeld bestaat uit meer woorden dan het doelwoord alleen. Die andere woorden mogen de leerling niet overvallen. De regel:

> **Een canoniek voorbeeld gebruikt uitsluitend woorden die de leerling al kent op het moment dat hij de kaart voor het eerst kan zien — dat wil zeggen: woorden die uiterlijk in de introductieles van het doelwoord zijn geïntroduceerd.**

De introductieles van een woord staat vast in `vocabulary_status.first_lesson_id`; de database dwingt via de Single Introduction Rule af dat elk woord precies één keer geïntroduceerd wordt. Het toegestane woordbudget voor een voorbeeld bij woord *W* is dus:

1. alle woorden waarvan de introductieles een lager `sequence_number` heeft dan de introductieles van *W*;
2. plus alle woorden die in diezelfde les worden geïntroduceerd, inclusief *W* zelf.

Punt 2 is een bewuste redactionele keuze. Strikt "alleen eerder geïntroduceerd" is technisch zuiverder, maar onwerkbaar: bij les 1 zou het woordbudget dan leeg zijn en zou geen enkel voorbeeld geschreven kunnen worden. Woorden uit dezelfde lesset zijn bovendien precies wat de leerling geacht wordt te leren op het moment dat hij de kaart bekijkt.

**Waarom het anker de introductieles is en niet "de les die je nu aan het schrijven bent":** het voorbeeld hoort bij het woord, niet bij een les, dus het moet geldig zijn in élke les waarin het verschijnt. De introductieles is de vroegste daarvan, en het aantal bekende woorden groeit alleen maar. Wie het voorbeeld valideert tegen de introductieles, weet daarmee dat het in alle latere lessen ook klopt. Eén controle, permanent geldig.

**Hoe je dit als auteur bewaakt:**

- **Stel het budget vast vóór je schrijft, niet erna.** Verzamel de lijst met toegestane woorden als een expliciete lijst en houd die naast je terwijl je schrijft. Waarom vooraf: wie eerst een mooie zin bedenkt en daarna controleert, gaat onderhandelen met zichzelf over dat ene woord dat er per se in moet.
- **Twijfel is een nee.** Weet je niet zeker of een woord al geïntroduceerd is, dan is het antwoord voor dit voorbeeld "niet gebruiken". Opzoeken kost meer tijd dan een alternatief bedenken.
- **Eigennamen, getallen en leenwoorden tellen mee.** Ze voelen "gratis" omdat ze internationaal herkenbaar lijken, maar de leerling moet ze in Thais schrift kunnen lezen. Dat is precies wat hij nog niet kan.
- **Een woord dat nog nergens geïntroduceerd is, krijgt nog geen canonieke voorbeelden.** Zonder introductieles is er geen anker en dus geen budget. Schrijf de voorbeelden in de les die het woord introduceert; dat is ook het natuurlijke moment.

**Wat te doen bij een schending.** Herschrijf het voorbeeld — dat is vrijwel altijd het goedkoopste. De twee alternatieven zijn duurder en zelden juist: het ontbrekende woord alsnog aan deze les toevoegen (dan verandert de lesset, en die was met een reden zo samengesteld), of het doelwoord naar een latere les verplaatsen (dan verschuift het hele curriculum). Een voorbeeld is het lichtste onderdeel van de keten; buig dat.

**Onderhoudsgeval: een woord verhuist naar een vroegere les.** Dan krimpt het budget met terugwerkende kracht en kunnen bestaande voorbeelden ongeldig worden zonder dat iemand iets aan die voorbeelden veranderd heeft. Controleer bij elke verschuiving van een introductieles naar voren de canonieke voorbeelden van dat woord opnieuw. Verschuiving naar achteren is altijd veilig: het budget groeit dan alleen.

## Hoeveel voorbeelden per woord?

De publicatieregel:

> **Elk woord met `role = 'target'` heeft precies één canoniek voorbeeld vóór de les gepubliceerd wordt.**

Eén, niet "minstens één". Dat is vastgelegde beslissing 2, en het is de enige regel in deze gids die zowel een ondergrens als een bovengrens stelt. Zie die beslissing voor de volledige motivering; de kern is dat een tweede voorbeeld een tweede functie alleen kan *tonen*, terwijl een Language Note haar kan *benoemen* — en dat een tweede voorbeeld precies daar geschreven moet worden waar het woordbudget het krapst is.

Dit is bewust géén databaseconstraint. Onvolledigheid tijdens het schrijven is normaal en toegestaan; het enige moment waarop volledigheid afdwingbaar moet zijn, is publicatie (zie Stap 10). Merk op dat deze regel losstaat van `requires_explanation`: een doelwoord kan uitstekend zonder Language Note, maar nooit zonder voorbeeld.

De regel dekt automatisch het hele curriculum, en dat is geen toeval: door de Single Introduction Rule is elk woord precies één keer een doelwoord. Wie de regel per les naleeft, heeft aan het eind van het A1-traject elk woord van een voorbeeld voorzien — zonder ooit een aparte inhaalslag te moeten plannen. Het totaal is daarmee ook vooraf bekend: één voorbeeld per woord in de masterlijst, en niet het veelvoud daarvan.

**`is_multifunctional` verandert hier niets aan.** De vlag zegt dat een woord meerdere functies *heeft*, niet dat dit curriculum ze allebei gebruikt — 145 van de 513 woorden staan op true. Zie vastgelegde beslissing 3 voor wat er wél gebeurt met een tweede functie die het curriculum werkelijk in gebruik neemt.

Woorden met `role = 'supporting'`, `'review'` of `'bonus'` krijgen geen eigen voorbeeldverplichting in die les: ze hebben hun voorbeelden al gekregen in de les die ze introduceerde, of krijgen die daar nog.

## Stapsgewijze workflow per les

### Stap 1 — Bepaal welke woorden voorbeelden nodig hebben

Verzamel de doelwoorden van de les — de woorden met `role = 'target'` — en controleer per woord of er al canonieke voorbeelden bestaan. Dat laatste is geen formaliteit: een woord kan al voorbeelden hebben gekregen zonder dat je het je herinnert, want voorbeelden horen bij het woord en niet bij de les.

Maak de werklijst expliciet: welke woorden krijgen een voorbeeld, en welke hebben er al één. Dat is een ja/nee-lijst, geen telling — elk doelwoord krijgt precies één voorbeeld (vastgelegde beslissing 2), dus `is_multifunctional` en de woordsoort spelen bij deze afbakening geen rol.

Waarom eerst afbakenen: het woordbudget van Stap 2 is werk dat je één keer per les doet en voor alle woorden hergebruikt. Wie woord voor woord improviseert, doet dat werk vier keer.

Kom je hier een woord tegen dat in deze les een *andere* functie of betekenis krijgt dan in zijn introductieles, dan hoort dat niet in deze werklijst thuis. Zie vastgelegde beslissing 3.

De werklijst hoeft niet met de hand samengesteld te worden: `vocabulary_example_brief_view` levert hem in de kolom `target_words`, samen met het woordbudget van Stap 2. Zie "De briefing ophalen" onderaan Stap 2. Let daar op `needs_example` en `existing_examples` — die beantwoorden precies de vraag of het woord zijn voorbeeld al gekregen heeft.

**Goedkeuringsmoment:** de werklijst (welke woorden nog een voorbeeld nodig hebben) wordt goedgekeurd vóór er geschreven wordt.

### Stap 2 — Stel het toegestane woordbudget vast

Bepaal de lijst woorden die je in de voorbeelden van deze les mag gebruiken, volgens de progressieregel hierboven: alles wat vóór deze les geïntroduceerd is, plus de volledige lesset van deze les.

Leg die lijst vast als een concrete opsomming, niet als een gevoel. Waarom vastleggen: het budget is ook de input voor de kwaliteitscontrole in Stap 8, en later voor een geautomatiseerd voorstel (zie Toekomstige uitbreidbaarheid). Een lijst die alleen in je hoofd bestaat, kan geen van beide.

Deze lijst geldt voor alle doelwoorden van deze les tegelijk, zolang ze dezelfde introductieles delen — wat vandaag altijd zo is. Deelt een doelwoord die introductieles níet, dan heeft het een eigen, krapper budget; zie hieronder.

#### De briefing ophalen

`vocabulary_example_brief_view` beantwoordt Stap 1 en Stap 2 in één query. Draaien met (PowerShell):

```powershell
$env:PGCLIENTENCODING="UTF8"
psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -P pager=off -c "select jsonb_pretty(to_jsonb(v)) from public.vocabulary_example_brief_view v where lesson_key = 'a1-dialog-03';"
```

`PGCLIENTENCODING` is niet optioneel: zonder UTF-8 komt het Thaise schrift als vraagtekens terug en beoordeel je iets anders dan wat er in de database staat.

Twee kolommen dragen het werk:

- **`target_words`** — de werklijst van Stap 1, met de mastervelden, `needs_example`, en de voorbeelden die het woord al heeft.
- **`example_vocabulary_budgets`** — het budget van Stap 2, gegroepeerd **per introductieles**, elk woord met zijn paiboon-vorm.

Die groepering is het punt waarop deze view afwijkt van `language_note_brief_view`, en het is geen implementatiedetail. Daar is het budget lesgebonden; hier is het gebonden aan de introductieles van het doelwoord, precies zoals de progressieregel hierboven voorschrijft. Elk woord in `target_words` draagt `intro_lesson_id` en `is_introduced_here`, zodat je zijn blok kunt terugvinden. Vandaag is er altijd exact één blok — deelt een doelwoord de introductieles van de les niet, dan verschijnt er een tweede, krapper blok en staat `is_introduced_here` op `false`. Dat is het signaal dat je voor dát woord tegen een ander budget schrijft.

De dialoog van de les zit bewust **niet** in deze view, anders dan bij `language_note_brief_view`. Een canoniek voorbeeld moet lesneutraal zijn, en een briefing die de scène toont nodigt uit tot precies de fout die deze gids verbiedt: een dialoogzin kopiëren.

Controleer de view zelf met `supabase/qa/verify_vocabulary_example_brief_view.sql`. Lees de kop daarvan voor je de uitkomst interpreteert: een deel van de secties zijn datacontroles die op kapotte inhoud vuren, een ander deel zijn invariantcontroles die alleen een herschrijving van de view betrappen.

**Goedkeuringsmoment:** het woordbudget wordt goedgekeurd vóór er geschreven wordt.

### Stap 3 — Schrijf de voorbeelddrieluiken

Elk voorbeeld is een drieluik: **Thais schrift**, **Paiboon-transliteratie**, **Engelse vertaling**. Alle drie verplicht; een voorbeeld met twee van de drie is niet "bijna klaar" maar onbruikbaar.

Redactionele regels:

- **Het doelwoord staat centraal, niet in de marge.** Het voorbeeld bestaat om dít woord te tonen. Een zin waarin het doelwoord een bijrol speelt naast iets interessanters, leert de leerling het verkeerde.
- **Eén functie per voorbeeld — die van de introductieles.** Het voorbeeld toont de betekenis waarvoor het woord in déze les geïntroduceerd wordt, en alleen die. Twee functies in één zin proppen maakt beide onherkenbaar, en een tweede functie die het curriculum later in gebruik neemt heeft een eigen route (vastgelegde beslissing 3) — niet een tweede zin op deze kaart.
- **Kort en natuurlijk.** Een A1-voorbeeld is een volledige maar korte zin zoals een Thai die echt zou zeggen, inclusief beleefdheidspartikels waar die natuurlijk zijn. Geen kunstmatig uitgeklede telegramzinnen, en geen zinnen van tien woorden om één woord te tonen.
- **Lesneutraal.** Geen personages, geen scèneverwijzingen, geen letterlijke dialoogzinnen — zie "De twee eigenaarschappen".
- **Zelfstandig leesbaar.** Het voorbeeld moet kloppen zonder enige context eromheen. De toets: zou deze zin ook begrijpelijk zijn als hij als enige op het scherm stond?
- **Alleen woorden uit het budget van Stap 2.** Een nieuw woord "smokkelen" omdat het zo'n mooi voorbeeld oplevert, is verboden — de leerling kan niet onderscheiden wat hij hoort te kennen en wat niet, en elk onbekend woord voelt als een gat in zijn kennis.
- **Het is je enige kans.** Er komt geen tweede voorbeeld dat het beeld aanvult. Kies dus de zin die je zou kiezen als je er maar één mocht hebben — want dat is precies de situatie.

### Stap 4 — Paiboon-conventies

- **Opzoeken, niet reconstrueren.** Voor elk woord dat al in de vocabulairemasterlijst staat, is de daar vastgelegde Paiboon-vorm de enige juiste — kopieer die letterlijk. Waarom dit een harde regel is: Paiboon is uit het hoofd verrassend foutgevoelig, en twee spellingen van hetzelfde woord op één lespagina ondermijnen het vertrouwen van de leerling in het hele systeem.
- **Geaspireerde medeklinkers krijgen géén h.** ข/ค → *k*, ถ/ท → *t*, ผ/พ/ภ → *p*. Schrijf nooit *kh*, *th* of *ph* — dat is RTGS, niet Paiboon. Waarom Paiboon die h niet nodig heeft: de niet-geaspireerde tegenhangers krijgen een eigen schrijfwijze (ก → *g*, ต → *dt*, ป → *bp*), zodat er geen digraaf nodig is om ze te onderscheiden. Waarom dit expliciet vermeld staat: dit is in het verleden structureel misgegaan en moest over honderden rijen van RTGS naar Paiboon gecorrigeerd worden. Het onderscheid blijft wezenlijk voor de uitspraak — ปา (*bpaa*) en พา (*paa*) zijn verschillende woorden — maar het wordt in Paiboon gedragen door *bp* tegenover *p*, niet door een *h*.
- **Klinkerlengte nooit afleiden, zeker niet bij อัว.** Of een klinker enkel of dubbel geschreven wordt (*u* vs. *uu*, *a* vs. *aa*) is niet betrouwbaar uit het schriftbeeld of het toonpatroon af te leiden. Bevestig het **per woord** in de masterlijst of een naslagwerk. Waarom: een verkeerde klinkerlengte is voor een leerling onhoorbaar fout gespeld — hij leert het verkeerd aan zonder het te merken, en de fout is later duur om terug te draaien.
- **Toontekens consequent op elke lettergreep.** Een voorbeeld zonder toontekens is fout, niet onaf.
- **De transliteratie van het voorbeeld en die van het lemma moeten identiek zijn** voor het doelwoord. Wijken ze af, dan is één van beide fout — controleer welke, en corrigeer de bron.

### Stap 5 — Engelse vertaling

- **Natuurlijk Engels, trouw aan het Thais.** De vertaling zegt wat de zin betekent in normaal Engels — geen woord-voor-woord-glossen in de vertaalregel zelf. Waarom: de vertaalregel is voor begrip; structuuruitleg hoort in een Language Note, niet in de vertaling.
- **Vertaal de functie van partikels, niet het woord.** ครับ/ค่ะ worden niet als los woord weergegeven; hun beleefdheid zit in de toon van de Engelse zin of blijft onvertaald. Waarom: er bestaat geen Engels equivalent, en een geforceerde vertaling ("yes, polite-particle") leert de leerling iets verkeerds.
- **De vertaling van het voorbeeld moet verenigbaar zijn met de gloss van het lemma.** Als de kaart zegt dat het woord "to go" betekent en de voorbeeldvertaling maakt er "to leave" van, dan klopt één van de twee niet. Dit is de meest voorkomende stille inconsistentie op een woordkaart.
- **Consistent met de dialoog- en note-vertalingen.** Dezelfde constructie krijgt overal dezelfde Engelse weergave. Twee verschillende vertalingen van hetzelfde patroon op één lespagina zijn een fout, geen stijlvariatie.

### Stap 6 — Lemma-teksten en lesnotities

Naast de voorbeelden staan er teksten op en rond de kaart die hun eigen conventies hebben:

- **`english_gloss` is een betekenis, geen definitie.** Kort, in de vorm waarin de leerling het woord zal gebruiken. Werkwoorden zonder "to" tenzij dat verwarring geeft; naamwoorden zonder lidwoord.
- **`usage_note` (master) beschrijft het woord altijd en overal.** Register, een valkuil, een vaste combinatie. Kort en lesneutraal — deze notitie verschijnt in élke les met dit woord.
- **`notes` (lesgebonden) beschrijft iets dat alleen in déze les geldt.** Gebruik deze spaarzaam: als de opmerking ook in de volgende les waar zou zijn, hoort ze in `usage_note`.
- **Instruerende teksten staan in de imperatief.** Dit is een bestaande projectconventie: de `learning_focus` van de dialoog is geformuleerd als "Say hello, ask someone's name, …" — niet als "Saying hello, asking …". AI-gegenereerde tekst drift hier structureel naar de gerundium-vorm; corrigeer dat consequent terug, ook in `usage_note` en `notes` waar die instrueren. Waarom: één grammaticale vorm voor alle doelstellingen maakt ze onderling vergelijkbaar en herkenbaar als "wat je nu kan".
- **De woordenset van de les moet de `learning_focus` van de dialoog daadwerkelijk dienen.** Een doelwoord dat aan geen enkel onderdeel van die focus bijdraagt, staat in de verkeerde les.

### Stap 7 — Volgorde

**Volgorde van de voorbeelden binnen een woord** (`display_order`): begin bij 1 en tel op zonder gaten. In de praktijk is dit altijd `1`, omdat elk woord precies één voorbeeld heeft. De regel blijft staan omdat de kolom en haar constraint blijven bestaan en de validatie in Stap 10 de nummering hoe dan ook controleert — een `display_order` van 2 is straks een signaal dat er iets is gebeurd wat niet hoort.

**Volgorde van de woorden binnen de les** (`display_order` op de leskoppeling): doelwoorden eerst in de volgorde waarin de dialoog ze introduceert, ondersteunende en herhalingswoorden daarna. Waarom deze volgorde en niet alfabetisch of thematisch: de leerling gebruikt de woordenlijst tijdens en na de dialoog, en zoekt daarin op de volgorde waarin hij de woorden hoorde.

### Stap 8 — Redactionele QA

Controleer vóór de audio-stap minstens:

- Heeft elk doelwoord van deze les precies één voorbeeld — niet nul, en niet twee?
- Gebruikt elk voorbeeld uitsluitend woorden uit het budget van Stap 2?
- Is elk voorbeeld lesneutraal — geen personages, geen scèneverwijzing, geen gekopieerde dialoogzin?
- Is elk voorbeeld zelfstandig leesbaar?
- Staat het doelwoord centraal in zijn eigen voorbeeld?
- Toont het voorbeeld de betekenis waarvoor het woord in déze les geïntroduceerd wordt?
- Is elke Paiboon-vorm gecontroleerd tegen de masterlijst (aspiratie-h, klinkerlengte, tonen)?
- Komt de transliteratie van het doelwoord in het voorbeeld overeen met die van het lemma?
- Is elke vertaling natuurlijk Engels, verenigbaar met de gloss, en consistent met dialoog en notes?
- Zijn ครับ/ค่ะ natuurlijk gebruikt en passen ze bij de stem die het voorbeeld gaat inspreken?
- Staan instruerende teksten in de imperatief?
- Is `display_order` aaneensluitend vanaf 1?

Waarom QA vóór audio en niet erna: elke tekstwijziging ná audiogeneratie maakt die audio ongeldig en dwingt tot regenereren. Tekst eerst bevriezen is goedkoper.

**Goedkeuringsmoment:** de volledige tekst van alle nieuwe kaarten en voorbeelden wordt goedgekeurd vóór er audio wordt gegenereerd.

### Stap 9 — Audio

Er zijn twee soorten audio op een Vocabulary Card, en ze worden apart gemaakt:

**Lemma-audio** — het woord alleen, in citeervorm. Duidelijk en op normaal spreektempo, niet overdreven traag: een verlengde citeervorm vervormt de tonen en leert de leerling een uitspraak aan die hij in een zin nooit terughoort.

**Voorbeeldaudio** — de volledige Thaise zin van elk voorbeeld.

Regels voor beide:

- **Voorbeeldaudio wordt nooit hergebruikt uit dialoogaudio**, ook niet wanneer de zin toevallig identiek zou zijn. Waarom: dialoogaudio is een personagestem in een scène, met de intonatie van dat moment. Een woordkaart hoort de neutrale instructiestem te gebruiken; een personagestem suggereert ten onrechte dat de zin uit een scène komt en bindt de kaart aan een personage dat er niets mee te maken heeft.
- **Instructiestem, geen personagestem.** Alle kaartaudio gebruikt de vaste narratorstem. De standaard is de vrouwelijke narrator; de mannelijke wordt gebruikt wanneer de taal genderspecifiek is.
- **Partikel en stem moeten overeenkomen.** Een zin die op ค่ะ eindigt wordt door een vrouwenstem ingesproken, een zin op ครับ door een mannenstem. Een mannenstem die ค่ะ zegt is voor elke Thai onmiddellijk fout en leert de leerling een verkeerde koppeling aan. Praktisch: kies het partikel al in Stap 3 passend bij de standaardstem, en wijk alleen af wanneer het voorbeeld juist het ครับ/ค่ะ-contrast toont.
- **Na elke tekstwijziging wordt de audio van dát item opnieuw gegenereerd.** Tekst en audio die niet overeenkomen zijn erger dan geen audio: de leerling traint zijn oor op de verkeerde zin.
- **Dit is dezelfde tijdelijke TTS-pipeline als bij de dialogen**, later vervangen door opnames met stemacteurs. Investeer geen tijd in het verfraaien ervan; de redactionele regel is alleen: elk gepubliceerd lemma en elk gepubliceerd voorbeeld heeft audio, en die audio komt overeen met de exacte huidige tekst.

### Stap 10 — Validatie vóór publicatie

Vóór de les gepubliceerd wordt, wordt gecontroleerd:

1. Elk doelwoord van de les heeft precies één canoniek voorbeeld.
2. Elk voorbeeld voldoet aan de progressieregel, gemeten tegen de introductieles van zijn woord.
3. Elk voorbeeld heeft alle drie de onderdelen: Thais schrift, Paiboon, Engelse vertaling.
4. Elk lemma en elk voorbeeld van de les heeft audio.
5. `display_order` is aaneensluitend, zowel binnen elk woord als binnen de les.
6. De Stap 8-checklist is doorlopen.

Vandaag is dit een handmatige controle; het is de bedoeling dat dit een geautomatiseerd publicatierapport wordt dat precies deze punten afloopt. De workflow verandert daardoor niet — alleen wie het lijstje afvinkt.

Waarom validatie een aparte stap is en geen doorlopend gevoel: onvolledigheid is tijdens het schrijven normaal en toegestaan. Het enige moment waarop volledigheid afdwingbaar moet zijn, is publicatie.

### Stap 11 — Vastleggen en committen

Canonieke voorbeelden en lemma-gegevens die alleen in de werkdatabase staan, zijn niet duurzaam: een volledige herbouw van de lokale database vertrekt van de vastgelegde brondata, niet van wat er toevallig in de database staat. Leg nieuwe voorbeelden en gewijzigde lemma-gegevens daarom vast in de brondata vóór je verder gaat, en commit die samen met de overige redactionele bestanden van de les.

Wat wél en niet in de brondata hoort:

- **Wel:** de voorbeeldteksten, de lemma-gegevens, en de stemkeuze per item — dat zijn redactionele beslissingen.
- **Niet:** de verwijzingen naar de audiobestanden zelf. Die zijn een afgeleid artefact dat opnieuw wordt aangemaakt, net als bij de dialoogaudio. Een vastgelegde verwijzing naar een bestand dat na een herbouw niet meer bestaat, is schadelijker dan geen verwijzing: het audioproces slaat zo'n item over omdat er "al" audio is, en de leerling krijgt stilte zonder dat iemand een foutmelding ziet.

Commit alles wat nodig is om te reconstrueren *waarom* de inhoud is zoals ze is, volgens hetzelfde principe als de andere drie workflows.

## Bestaande cards bewerken

- **Feitelijke fouten worden direct verbeterd**: een verkeerde Paiboon-vorm, een kromme vertaling, een verkeerde gloss. Daarna geldt Stap 9: audio van gewijzigde items regenereren.
- **Een voorbeeld vervángen mag altijd**, mits het nieuwe voorbeeld voldoet aan het budget van de **introductieles van dat woord** — niet aan dat van de les waarin je toevallig werkt. Dit is de meest voorkomende manier om de progressieregel per ongeluk te breken: je werkt in les 24, kent daar veel woorden, en herschrijft een voorbeeld van een woord uit les 3.
- **Een tweede voorbeeld toevoegen mag niet.** Dat is vastgelegde beslissing 2, en de verleiding komt vrijwel altijd uit hetzelfde motief: het woord blijkt in een latere les een tweede functie te hebben. Beslissing 3 beschrijft wat er dan wél gebeurt.
- **Een voorbeeld verwijderen** doe je alleen samen met het schrijven van zijn vervanger: een doelwoord zonder voorbeeld blokkeert publicatie.
- **Verdieping hoort niet op de kaart.** Wie later merkt dat een woord "eigenlijk rijker uitgelegd kan worden", schrijft een Language Note in de les waar die verdieping thuishoort. De kaart blijft wat ze is: een compacte, permanente weergave van één betekenis van het woord.
- **Een woord uit een les verwijderen** raakt de canonieke voorbeelden niet — die horen bij het woord. Was het de introductieles, dan verhuist de introductie en moet het budget van alle voorbeelden opnieuw gecontroleerd worden.

## Veelvoorkomende fouten

- **Lesgebonden taal in een canoniek voorbeeld.** Personages, scèneverwijzingen, "zoals je net zag". Onzichtbaar in de les waarvoor je schrijft, pijnlijk in elke andere.
- **Een dialoogzin kopiëren.** Voelt efficiënt, maar bindt een permanente kaart aan één scène.
- **Het budget meten tegen de verkeerde les.** Meet altijd tegen de introductieles van het wóórd, niet tegen de les waarin je werkt — zie "Bestaande cards bewerken".
- **Eén woord smokkelen.** Het voelt als een detail en is de reden dat de leerling denkt dat hij iets gemist heeft.
- **Paiboon uit het hoofd.** De meest voorkomende én best verstopte fout. Aspiratie-h en klinkerlengte zijn de bekende recidivisten; อัว wordt per woord bevestigd, nooit afgeleid.
- **Voorbeeldvertaling die de gloss tegenspreekt.** Twee betekenissen op één kaart zonder dat iemand het merkt.
- **Een tweede voorbeeld schrijven voor een tweede functie.** Tot 2026-08-07 was dit de voorgeschreven werkwijze; sindsdien is het een fout. Zie beslissing 2 en 3.
- **Een gloss die twee betekenissen samenperst** ("to suspect, to wonder") terwijl het voorbeeld er maar één toont. De kaart belooft dan meer dan ze levert. Dit is het signaal dat je twee masterrijen nodig hebt — zie beslissing 3.
- **`is_multifunctional` lezen als een opdracht.** De vlag staat op 145 van de 513 woorden en zegt alleen dat het woord meerdere functies héeft. Of dit curriculum ze allebei gebruikt, is een aparte vraag die je per woord beantwoordt op het moment dat de tweede functie in een les opduikt.
- **Gerundium in plaats van imperatief** in instruerende teksten — structurele AI-drift, corrigeer consequent.
- **Audio vergeten na een tekstcorrectie.** Tekst en audio lopen dan uit elkaar — erger dan geen audio.
- **Voorbeeldaudio uit de dialoog hergebruiken.** Verkeerde stem, verkeerde suggestie.
- **Werk alleen in de database laten staan.** Verdwijnt stilzwijgend bij de eerstvolgende herbouw — zie Stap 11.

## Toekomstige uitbreidbaarheid

- **AI-ondersteund voorstel voor voorbeeldzinnen.** Het woordbudget van Stap 2 en de werklijst van Stap 1 zijn precies de input die een generatieve stap nodig heeft: "hier is het toegestane vocabulaire, hier zijn de doelwoorden, stel per woord één voorbeeld voor". Dat is een geplande volgende stap — zie taak 3 van `docs/vocab_card_prompts.md`. Deze gids is daarom kanaal-agnostisch geschreven: nergens staat *wie* de zin bedenkt, alleen welke regels de zin moet halen. Wanneer die stap er is, komt hij tussen Stap 2 en Stap 3, en blijven alle redactionele regels en goedkeuringsmomenten ongewijzigd gelden.
- **Geautomatiseerd publicatierapport** dat de punten van Stap 10 afloopt, in het bijzonder de progressieregel — die is machinaal volledig controleerbaar zodra het budget formeel wordt vastgesteld.
- **Stemacteurs vervangen de TTS-audio** zodra het A1-traject inhoudelijk staat. Alleen Stap 9 verandert dan (opnemen in plaats van genereren); alle redactionele regels blijven gelden. Op dat moment wordt ook de afweging in Stap 11 herzien: opgenomen audio is een asset die niet opnieuw berekend kan worden, en moet dan wél duurzaam bewaard worden.
- **Extra weergavevelden op de kaart** (bijvoorbeeld een classifier bij naamwoorden, of een tegengesteld woord) zijn denkbaar. Tot ze bestaan, hoort die informatie in `usage_note` of in een Language Note — niet verstopt in een voorbeeldzin.
- **Lesgebonden voorbeelden — overwogen en afgewezen op 2026-08-07.** Het idee: een woord houdt meerdere voorbeelden in de masterlijst, en een les rendert alleen het voorbeeld dat daar aan de orde is. De vorm zou zijn: een eigen anker per voorbeeld, en renderen vanaf dat anker in plaats van in elke les. De afwijzing is geen complexiteitsargument maar een dubbelingsargument — een `example_group` in een Language Note is dit al: lesgebonden per constructie, met audio uit dezelfde pijplijn, en met uitleg eromheen die een tweede kaartvoorbeeld niet kan geven. Wat de kaartvariant daarbovenop zou kosten: een lesdimensie op `vocabulary_examples`, een tweede ankerregel naast de progressieregel — waarmee "één controle, permanent geldig" vervalt — plus doorwerking in de brief-view, de generator en de rendering. Allemaal voor een geval dat zich nog geen enkele keer heeft voorgedaan.
- **Een zichtbaarheidskolom op `lesson_vocabulary` — overwogen en afgewezen op 2026-08-07.** Het idee: een leslink die de vlag `requires_explanation` draagt zonder dat het woord als kaart verschijnt. Nodig leek dat omdat de kaartquery nergens op filtert, dus elke leslink een kaart wordt. Niet gebouwd, omdat beslissing 3 het probleem opheft: de dragers die je nodig hebt (een tweede masterrij, of een grammaticaconcept) hebben de kolom niet nodig, en het geval dat hem wél nodig zou hebben is per definitie te klein om aandacht te verdienen. Komt de kolom er ooit alsnog, dan is het een boolean plus één filterregel in `getLessonInstructionalContentRows` — klein werk, maar een nieuw begrip in het datamodel, en dat is de reden om het niet vooruit te nemen.
- **Andere platformen** (een toekomstige mobiele app) lezen dezelfde inhoud. Schrijf dus nooit platform-specifiek ("tik op het geluidsicoon") — de kaart weet niet waar ze wordt weergegeven.

## Vastgelegde redactionele beslissingen

Deze beslissingen zijn vastgelegd op 2026-08-07 en gelden voor alle Vocabulary Cards. Ze zijn bewust niet per kaart herzienbaar: hun waarde zit juist in de uniformiteit. Wil je er structureel van afwijken, wijzig dan deze lijst — niet één kaart.

1. **De kaartinhoud is Engelstalig.** Alle leerlinggerichte tekst — `english_gloss`, `usage_note`, lesgebonden `notes`, voorbeeldvertalingen — staat in het Engels. Waarom: consistent met de leerlinginterface, de dialoogvertalingen en de Language Notes (vastgelegde beslissing 1 daar); een tweetalige leeromgeving dwingt de leerling voortdurend te schakelen.

2. **Eén canoniek voorbeeld per doelwoord.** Niet "minstens één" en niet "één tot twee": precies één. Drie redenen, in volgorde van gewicht.

   **De card toont, de note legt uit.** Dat onderscheid staat bovenaan in deze gids, en het bepaalt wat een tweede voorbeeld kán. Een tweede zin kan een tweede functie alleen *tonen*: de leerling ziet twee zinnen naast elkaar en moet zelf raden waarin ze verschillen — en of dat verschil er een is dat hij moet onthouden of toevallige variatie. Een Language Note kan het verschil benoemen. Een tweede voorbeeld is dus niet een halve note, het is een note zonder de zin die hem werkt maakt.

   **De tweede functie duikt bijna altijd later op dan de introductie.** Een canoniek voorbeeld mag alleen woorden gebruiken die bekend zijn bij de introductieles van het doelwoord — zie de first_lesson_id-progressieregel. Dat is precies het moment waarop het woordbudget het krapst is. Een tweede voorbeeld dat een functie uit les 24 moet tonen, moet dus geschreven worden met het vocabulaire van les 3. Een note in les 24 heeft dat probleem niet: die put uit alles wat de leerling inmiddels kent.

   **De schaal.** Bij een richtlijn van één tot twee voorbeelden praat je over ruwweg duizend voorbeelden voor het hele A1-traject, elk met redactie, Paiboon-controle en audio. Bij één voorbeeld per woord is het er 513, en dat getal is vooraf bekend in plaats van geschat. Dit argument weegt het lichtst van de drie, maar het is wel het enige dat niet verdwijnt als je harder gaat werken.

3. **Een tweede functie van een woord gaat niet naar een tweede voorbeeld.** Merk je dat dit curriculum werkelijk meer dan één functie of betekenis van een woord in gebruik neemt, dan is er één vraag die daarover beslist:

   > **Kun je de tweede betekenis een eigen `english_gloss` geven die de leerling van de eerste onderscheidt?**

   **Ja → een tweede rij in `vocabulary_master`,** met een eigen `source_key` en die eigen gloss. Dat is dan een eigen woord: het krijgt een eigen introductieles met `role = 'target'`, een eigen `requires_explanation`, en zijn eigen enkele voorbeeld, gemeten tegen zijn eigen introductieles. De Single Introduction Rule kijkt naar `vocabulary_id`, dus dit botst niet met de eerste rij.

   Dit is geen nieuwe praktijk maar bestaande: `face` en `page` staan al als twee rijen op หน้า (*nâa*), elk met een eigen gloss. Neem ook de tegenhanger ter harte — `month` en `calendar_month` staan allebei op เดือน (*dʉan*) en zijn identiek op script, Paiboon, gloss én woordsoort. Alleen de sleutel scheidt ze, en de leerling zou daar twee identieke kaarten zien. Dát is de mislukte versie van deze splitsing, en de gloss-toets bestaat om haar te voorkomen.

   Waarom de toets bij de gloss ligt en niet bij het gevoel dat de betekenis "anders" is: als je geen onderscheidende gloss kunt schrijven, kan de leerling de twee kaarten ook niet uit elkaar houden — dan splits je administratie en lekt dat in de interface. Omgekeerd: is de nuance te klein voor een eigen gloss, dan is ze ook te klein voor een tweede kaart, en hoort ze helemaal niet opnieuw in de vocabulairesectie thuis. Beide drempels zijn dezelfde drempel.

   Ter illustratie (het woord is A2+ en staat niet in de A1-masterlijst): สงสัย betekent zowel *to suspect* als *to wonder*. Eén kaart met de gloss "to suspect, to wonder" en een voorbeeld dat maar één van beide toont, belooft meer dan ze levert. Twee rijen, elk met een eigen gloss en een eigen voorbeeld in de les waar die betekenis geïntroduceerd wordt, doen dat niet.

   **Nee, want het verschil is grammaticaal in plaats van lexicaal → een concept in `grammar_master`,** gelinkt aan die latere les met `requires_explanation = true`. จะ als toekomstmarkering is geen tweede gloss maar een tweede constructie; dat hoort thuis bij de grammatica van die les, en de note claimt dat concept. Let op de reden: grammar is hier de juiste arm omdat het inhoudelijk een grammaticaconcept ís. Dat `lesson_grammar` vandaag nergens in `src/` gerenderd wordt is toevallig waar en geen argument — komt er ooit een grammaticasectie op de lespagina, dan blijft deze keuze juist.

   **Wat er niet gebeurt: een tweede `lesson_vocabulary`-link op het bestaande woord.** Die zou het woord opnieuw als kaart laten verschijnen zonder dat er iets nieuws op die kaart staat, want de kaartquery filtert nergens op: elke `lesson_vocabulary`-rij wordt een kaart. Valt een tweede functie door beide takken hierboven heen, dan is dat het bewijs dat ze te klein was om apart aandacht te verdienen. Het woord staat dan gewoon in het woordbudget van die les en wordt in de dialoog gebruikt zoals elk ander bekend woord.

   **`is_multifunctional` is geen trigger voor deze beslissing.** 145 van de 513 woorden staan op true; die allemaal behandelen zou een onhoudbare notelast opleveren. De vlag zegt dat het woord meerdere functies *heeft*, niet dat dit curriculum ze allebei *gebruikt*. Die tweede vraag is een oordeel per woord, en het wordt genomen op het moment dat de tweede functie werkelijk in een les opduikt — niet vooruit, op basis van een kolom.

4. **Eén vrouwelijke standaardstem, en dus ค่ะ als standaardpartikel.** Alle kaartaudio — lemma én voorbeeld — gebruikt de vaste vrouwelijke instructiestem. Een mannenstem wordt alleen ingezet in voorbeelden die het ครับ/ค่ะ-contrast zélf tonen.

   Deze beslissing is **letterlijk gelijk aan vastgelegde beslissing 2 van de Language Note-gids**, en dat is de bedoeling: kaart en note verschijnen in dezelfde les, en van stem wisselen tussen die twee is voor de leerling onverklaarbaar. Wijzigt die beslissing daar, dan wijzigt ze hier mee.

   **Gegenderde elementen vormen één bundel.** Stem, beleefdheidspartikel én eerste persoon horen bij elkaar; klopt er één niet, dan klopt de zin niet. Voor de vrouwelijke standaardstem:

   | | Standaard in canonieke voorbeelden |
   | --- | --- |
   | eerste persoon | ฉัน (*chǎn*) — nooit ผม |
   | mededeling | ค่ะ (*kâ*) |
   | vraag | คะ (*ká*) |

   ค่ะ en คะ zijn niet uitwisselbaar: ชอบเค้กไหม**คะ**, nooit ไหม**ค่ะ**. En het voornaamwoord vangt zichzelf niet af — `vocabulary_master` bevat zowel `i` (ฉัน) als `i_male` (ผม), allebei geïntroduceerd in les 1, dus allebei staan ze vanaf les 1 in elk woordbudget. Niets in dat budget verhindert `ผมชอบกาแฟค่ะ`. Waarom dit gat juist hier bestaat: in een dialoog regelen de personages het, maar een canoniek voorbeeld heeft geen personage — alleen de instructiestem, en dat is precies het element dat de keuze automatisch maakte.

5. **Een beleefdheidspartikel staat er waar een Thai het echt zou zeggen.** Bij aanspreken, antwoorden en vragen wel; bij een losse constatering niet. Waarom niet altijd: elk voorbeeld op ค่ะ laten eindigen maakt de zinnen beleefd maar ook eentonig, en het verstopt de kale zinsstructuur die de leerling juist moet leren zien. Voer het onderscheid consequent door, zodat de aanwezigheid van het partikel zelf informatie draagt in plaats van decoratie te zijn.

6. **Geen eigennamen in canonieke voorbeelden.** Gebruik een voornaamwoord, of laat het onderwerp weg zoals in natuurlijk Thais gebruikelijk is. Twee redenen die samenvallen: een naam is leesmateriaal in Thais schrift dat nergens is aangeleerd (zie de progressieregel — eigennamen tellen mee in het budget), en de namen die voor de hand liggen zijn Mali en Narin, wat het voorbeeld meteen aan een scène bindt die het niet mag hebben.

7. **Prompts en audit trail volgen het bestaande kanaal.** Blanco template in `supabase/planning/`, ingevulde prompt in `supabase/prompts/`, modeloutput in `supabase/generation/`, alles in versiebeheer — zoals bij de dialogen en de Language Notes. De concrete invulling voor deze keten wordt niet hier beslist maar in taak 3 van `docs/vocab_card_prompts.md`, en landt in Stap 11 van deze gids. Waarom als verwijzing en niet als eigen beslissing: het is één beslissing over drie ketens, en drie plaatsen waar ze staat is twee te veel.

8. **De naamgeving van de brondata wordt niet hier beslist maar in taak 2** van `docs/vocab_card_prompts.md`, samen met de natuurlijke sleutel, het invoercontract en de generator. Wat wél redactioneel vastligt en die taak bindt: een voorbeeld wordt geïdentificeerd via de sleutel van het **wóórd**, nooit via een les. Een sleutel in de vorm `a1-dialog-03-...` is fout, ook al is dat de conventie bij de Language Notes — daar hoort een voorbeeld bij een les, hier bij een woord. Dat verschil is de lesneutraliteit uit "De twee eigenaarschappen", en het hoort ook in de brondata zichtbaar te zijn.

## Praktische checklist per les

1. Verzamel de doelwoorden, controleer bestaande voorbeelden, en stel de werklijst op; laat die goedkeuren (Stap 1).
2. Stel het toegestane woordbudget vast volgens de progressieregel; laat het goedkeuren (Stap 2).
3. Schrijf per woord één voorbeelddrieluik — lesneutraal, zelfstandig leesbaar, binnen budget (Stap 3).
4. Controleer elke Paiboon-vorm tegen de masterlijst; bevestig อัว-klinkerlengte per woord (Stap 4).
5. Schrijf natuurlijke Engelse vertalingen, verenigbaar met de gloss en consistent met dialoog en notes (Stap 5).
6. Controleer lemma-teksten en lesnotities; instruerende tekst in de imperatief (Stap 6).
7. Zet de volgorde: prototypisch voorbeeld eerst, woorden in dialoogvolgorde (Stap 7).
8. Doorloop de redactionele QA-checklist en laat de tekst goedkeuren (Stap 8).
9. Genereer lemma- en voorbeeldaudio; bewaak stem/partikel-overeenkomst; nooit dialoogaudio hergebruiken (Stap 9).
10. Valideer vóór publicatie: dekking, progressieregel, volledige drieluiken, audio, nummering (Stap 10).
11. Leg de redactionele gegevens vast in de brondata en commit ze samen (Stap 11).
