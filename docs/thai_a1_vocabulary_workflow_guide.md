# Vocabulary Card-workflowgids

Deze gids beschrijft de herhaalbare redactionele workflow voor het schrijven van Vocabulary Cards en hun canonieke voorbeelden, in dezelfde geest als `docs/thai_a1_dialog_workflow_guide.md`, `docs/illustration-system/04_illustration_workflow_guide.md` en `docs/thai_a1_language_note_workflow_guide.md`: de database blijft bron van waarheid, alleen goedgekeurde eindresultaten worden definitief opgeslagen, en elke stap heeft een expliciet goedkeuringsmoment.

Deze gids beschrijft **zowel wat een auteur beslist als hoe dat wordt opgeslagen**. Tot 2026-08-08 stond hier het omgekeerde: het document beperkte zich bewust tot de redactionele kant, omdat regels over inhoud trager verouderen dan implementatiedetails. Die afbakening is losgelaten toen het seedformaat werd vastgelegd, om dezelfde reden als in de Language Note-gids: de twee kanten bleken niet los van elkaar te beschrijven.

Het duidelijkste voorbeeld staat in Stap 11. Dat een voorbeeld wordt geïdentificeerd via de sleutel van het *wóórd* en dat het invoerdocument geen `lesson_key` draagt, ziet eruit als een implementatiekeuze, maar het ís de lesneutraliteit uit "De twee eigenaarschappen" — mechanisch gemaakt, zodat de belangrijkste redactionele regel van deze gids niet meer per ongeluk te breken valt. Hetzelfde geldt voor de seed die `audio_url` opruimt zodra de tekst wijzigt: dat is de regel "na elke tekstwijziging wordt de audio opnieuw gegenereerd" uit Stap 9, afgedwongen in plaats van onthouden. Twee documenten zouden die verbanden doorknippen en allebei half kloppen.

De twee lagen blijven wel herkenbaar gescheiden. Stap 1 tot en met 10 zijn redactioneel: wat schrijf je, en waarom zo. Stap 11 bevat naast de redactionele regel over wat er in de brondata hoort ook het invoercontract, de concrete SQL, de bestandspaden en de commando's. Waar een technische instructie iets afdwingt wat redactioneel bedoeld is — of juist níet afdwingt — staat dat er expliciet bij.

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

`vocabulary_example_brief_view` beantwoordt Stap 1 en Stap 2 in één rij.

**De queries die je bij het invullen draait, staan in de mapping-checklist onderaan het template `supabase/planning/09_vocabulary_example_prompt_template.md` — niet in deze gids.** Twee stuks: één voor de werklijst, één voor het budget. Ze leveren precies de velden die de prompt nodig heeft, in de vorm die je plakt. Deze gids beschrijft wát de stap oplevert en waarom; het template draagt de mechaniek van het invullen, en die hoort op één plaats te staan.

**Wil je de rij zelf bekijken — bijvoorbeeld omdat er twee budgetblokken verschijnen of een waarde ontbreekt — doe dat dan in Supabase Studio.** Niet via psql: op een Windows-console verschijnt ได้ als `à¹"à¸"à¹%` zodra `chcp 65001` ontbreekt, en ook mét de juiste codepage klopt de uitlijning niet bij combinerende toontekens. Correcte bytes, verkeerd getekend — je beoordeelt dan iets anders dan wat er in de database staat. Zie "psql op Windows" in `docs/thai_a1_dialog_workflow_guide.md` voor de gevallen waarin psql wél nodig is; daar gaat het altijd om bestanden draaien of om md5-vergelijkingen, nooit om Thais van het scherm lezen.

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

#### De voorbeelden laten voorstellen

De zinnen worden vandaag door een model voorgesteld, met `supabase/planning/09_vocabulary_example_prompt_template.md`. Dat template is de mechanische kant van deze stap: het krijgt de goedgekeurde werklijst uit Stap 1 en het goedgekeurde budget uit Stap 2, en levert één JSON-document volgens het contract uit Stap 11.

Twee dingen die je vóór het invullen zelf beslist, omdat een model ze niet reproduceerbaar beslist:

- **Het `speaker_gender` per doelwoord** (`female` of `male`) — het model verdeelt, jij corrigeert bij het nalezen; zie vastgelegde beslissing 4.
- **Welke woorden meedoen** — de werklijst wordt gefilterd op `needs_example`, zodat een woord dat zijn voorbeeld al heeft de prompt niet eens bereikt.

De prompt noemt de les nergens, en de brief-view geeft de dialoog niet mee. Dat is geen omissie maar de lesneutraliteit uit "De twee eigenaarschappen", mechanisch gemaakt: wat het model niet weet te bestaan, kan het niet als anker gebruiken.

Alles in deze stap blijft redactioneel jouw beslissing. Het template neemt de regels hierboven niet over — het herhaalt ze alleen in de taal van het model, en de QA van Stap 8 blijft onverkort gelden.

### Stap 4 — Paiboon-conventies

- **Opzoeken, niet reconstrueren.** Voor elk woord dat al in de vocabulairemasterlijst staat, is de daar vastgelegde Paiboon-vorm de enige juiste — kopieer die letterlijk. Waarom dit een harde regel is: Paiboon is uit het hoofd verrassend foutgevoelig, en twee spellingen van hetzelfde woord op één lespagina ondermijnen het vertrouwen van de leerling in het hele systeem.
- **Geaspireerde medeklinkers krijgen géén h.** ข/ค → *k*, ถ/ท → *t*, ผ/พ/ภ → *p*. Schrijf nooit *kh*, *th* of *ph* — dat is RTGS, niet Paiboon. Waarom Paiboon die h niet nodig heeft: de niet-geaspireerde tegenhangers krijgen een eigen schrijfwijze (ก → *g*, ต → *dt*, ป → *bp*), zodat er geen digraaf nodig is om ze te onderscheiden. Waarom dit expliciet vermeld staat: dit is in het verleden structureel misgegaan en moest over honderden rijen van RTGS naar Paiboon gecorrigeerd worden. Het onderscheid blijft wezenlijk voor de uitspraak — ปา (*bpaa*) en พา (*paa*) zijn verschillende woorden — maar het wordt in Paiboon gedragen door *bp* tegenover *p*, niet door een *h*.
- **Klinkerlengte nooit afleiden, zeker niet bij อัว.** Of een klinker enkel of dubbel geschreven wordt (*u* vs. *uu*, *a* vs. *aa*) is niet betrouwbaar uit het schriftbeeld of het toonpatroon af te leiden. Bevestig het **per woord** in de masterlijst of een naslagwerk. Waarom: een verkeerde klinkerlengte is voor een leerling onhoorbaar fout gespeld — hij leert het verkeerd aan zonder het te merken, en de fout is later duur om terug te draaien.
- **Toontekens exact zoals de bron ze vastlegt — niets toevoegen, niets weglaten.** Middentoon wordt in Paiboon zonder teken geschreven, dus "een teken op elke lettergreep" is niet de regel: `chaa`, `yen` en `nom` zijn correct zoals ze zijn. De regel is trouw overschrijven. Een transliteratie waaruit de tekens zijn weggevallen is fout, niet onaf — maar een teken erbij verzinnen om een lettergreep "compleet" te maken is even fout, en dat is de fout die een taalmodel maakt zodra je het de eerste formulering geeft. Tot 2026-08-09 stond hier "consequent op elke lettergreep".
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
- Gebruikt elk voorbeeld de volledige bundel van het `speaker_gender` dat aan het woord is toegewezen — ผม met ครับ, ฉัน met ค่ะ of คะ, nooit één vorm uit elke kolom?
- Staat ค่ะ in mededelingen en คะ in vragen, en niet omgekeerd?
- Is er nergens een voornaamwoord of partikel bijgeplakt in een zin die er geen wil?
- Is de verdeling tussen de twee bundels over de lessen heen in evenwicht?
- Staan instruerende teksten in de imperatief?
- Is `display_order` aaneensluitend vanaf 1?

Waarom QA vóór audio en niet erna: elke tekstwijziging ná audiogeneratie maakt die audio ongeldig en dwingt tot regenereren. Tekst eerst bevriezen is goedkoper.

**Goedkeuringsmoment:** de volledige tekst van alle nieuwe kaarten en voorbeelden wordt goedgekeurd vóór er audio wordt gegenereerd.

### Stap 9 — Audio

Er zijn twee soorten audio op een Vocabulary Card, en ze worden apart gemaakt:

**Lemma-audio** — het woord alleen, in citeervorm. Duidelijk en op normaal spreektempo, niet overdreven traag: een verlengde citeervorm vervormt de tonen en leert de leerling een uitspraak aan die hij in een zin nooit terughoort. Lemma-audio gebruikt altijd de vrouwelijke narrator: een los woord draagt geen `speaker_gender`, dus er valt niets af te leiden en een vaste keuze voorkomt een stemdiscussie per woord.

**Voorbeeldaudio** — de volledige Thaise zin van elk voorbeeld.

Regels voor beide:

- **Voorbeeldaudio wordt nooit hergebruikt uit dialoogaudio**, ook niet wanneer de zin toevallig identiek zou zijn. Waarom: dialoogaudio is een personagestem in een scène, met de intonatie van dat moment. Een woordkaart hoort de neutrale instructiestem te gebruiken; een personagestem suggereert ten onrechte dat de zin uit een scène komt en bindt de kaart aan een personage dat er niets mee te maken heeft.
- **Instructiestem, geen personagestem.** Alle kaartaudio gebruikt een van de twee vaste narratorstemmen. Nooit de stem van Mali of Narin: dat zijn personagestemmen, en `scripts/voice-config.mjs` kent vandaag alleen die twee. De narratorstemmen moeten er nog bij komen; zie `docs/audio_pipeline_prompt.md`.
- **De stem volgt de zin, en wordt niet apart opgeschreven.** Bevat de zin ผม of ครับ, dan de mannelijke narrator; anders de vrouwelijke. Daarom staat `voice_key` niet in de redactionele brondata en weigert de generator het veld: een lege `voice_key` betekent "leid af uit de tekst", niet "onbekend". Die afleiding kan niet mislopen zolang Stap 3 de bundel heel houdt — en als ze wél misloopt, is dat het bewijs dat de bundel gebroken is en hoort de tekst gecorrigeerd te worden, niet de stem.
- **Een mannenstem die ค่ะ zegt is voor elke Thai onmiddellijk fout** en leert de leerling een verkeerde koppeling aan. Dat is geen audioprobleem maar een tekstprobleem: het `speaker_gender` wordt al in Stap 3 vastgelegd, per woord, en de audio voert het alleen uit.
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

#### De voorbeelden opslaan

Hier komen de redactionele en de technische laag samen; zie de derde alinea van deze gids voor waarom ze niet los te beschrijven zijn. De vorm volgt Stap 6 van `docs/thai_a1_language_note_workflow_guide.md`.

De voorbeelden worden gegenereerd, niet met de hand geschreven.

**Bestandspaden.**

```text
supabase/
  generation/vocabulary-examples/
    a1_dialog_XX_examples.json          ← goedgekeurde inhoud
  seed-data/vocabulary-examples/
    a1_dialog_XX_examples.seed.sql      ← gegenereerd, niet met de hand bewerken
  qa/
    verify_vocabulary_example_seed_format.sql   ← schrijft en ruimt op; test het formaat
    fixtures/
      vocabulary_example_format_fixture.json    ← testgeval, geen lesinhoud
scripts/
  generate-vocabulary-example-seed.mjs
```

De lesnaam in het bestandspad is een **archiveringslabel voor de batch**, geen betekenisdrager. Hij komt in geen enkele sleutel voor en in geen enkele regel SQL: de inhoud hoort bij het woord, de batch bij de les waarin je hem schreef.

`seed-data/vocabulary-examples/*.sql` staat als glob in `supabase/config.toml`, achteraan. Een nieuw lesbestand wordt dus vanzelf meegenomen bij de volgende `db reset`; je hoeft `config.toml` niet per les bij te werken. De enige harde eis aan de volgorde is dat de map ná `master/vocabulary_master.seed.sql` staat — de seed zoekt woorden op. Verder is er geen afhankelijkheid: geen lessen, geen leslinks. Dat is het verschil met de Language Note-seeds, en het is dezelfde lesneutraliteit in een andere gedaante.

**Genereren en uitvoeren** (PowerShell, één regel per commando):

```powershell
node scripts/generate-vocabulary-example-seed.mjs --lesson a1-dialog-XX
$env:PGCLIENTENCODING = "UTF8"
psql postgresql://postgres:postgres@127.0.0.1:5432/postgres -f supabase/seed-data/vocabulary-examples/a1_dialog_XX_examples.seed.sql
```

`--lesson` is uitsluitend padsuiker: het bepaalt waar de bestanden staan, meer niet. Anders dan bij de Language Notes is er dus geen kruiscontrole tussen `--lesson` en de inhoud van het bestand — die kán er niet zijn, want het document draagt geen les. Dat is de prijs van de keuze hieronder, en ze is bewust betaald.

Voor de tekencodering gelden dezelfde twee valkuilen als bij de Language Notes, en ze gaan allebei stil mis: `\` is geen regelvervolg in PowerShell (psql opent dan een interactieve sessie in plaats van het bestand te draaien), en zonder `chcp 65001` plus `PGCLIENTENCODING` kan Thais schrift onderweg beschadigd raken. Gebruik `-A -P pager=off` bij elke query die Thais aanraakt. Zie Stap 6 van de Language Note-gids voor de volledige uitleg.

**Het invoercontract.**

```json
{
  "examples": [
    {
      "source_key": "tea",
      "example_key": "e1",
      "thai_script": "ฉันชอบชาเย็นค่ะ",
      "paiboon": "chǎn chɔ̂ɔp chaa yen kâ",
      "translation_en": "I like iced tea."
    }
  ]
}
```

Zeven regels, elk met een reden:

- **`display_order` staat er niet in.** De volgorde van de array *is* de volgorde op het scherm. Geef je het veld toch mee, dan weigert het script — anders zou het lijken alsof het iets doet.
- **`lesson_key` staat er ook niet in.** Dat is het verschil met het note-contract, en het is het belangrijkste veld dat híer ontbreekt. Het script heeft de les nergens voor nodig: de enige opzoeking is `source_key` → `vocabulary_master.id`. En inhoudelijk zou het veld schadelijk zijn: een lesveld in de brondata nodigt uit tot een lesgebonden zin, en dat voorbeeld verschijnt ook in les 24. Een veld dat het script zou moeten negeren, is precies het veld waarvan iemand denkt dat het iets doet.
- **De sleutels staan er wél in, en zijn verplicht.** De identiteit van een rij is het paar (`source_key`, `example_key`). `example_key` is uniek binnen het woord, niet globaal — vandaag altijd `e1`. Zie "Waarom de sleutel niet `display_order` is" hieronder.
- **`source_key` volgt de schrijfwijze van `vocabulary_master`:** kleine letters, cijfers en **underscores** (`thank_you`), nooit koppeltekens. `example_key` volgt de sleutelconventie van dit project en gebruikt juist **koppeltekens**. Dat verschil is niet cosmetisch: het script controleert beide vormen, zodat een model dat `thank-you` schrijft meteen faalt in plaats van pas bij het seeden.
- **Geen `audio_url` en geen `voice_key`.** Die worden door de audiostap gezet, niet door de redactionele brondata — zie de tweede bullet bovenaan Stap 11.
- **Onbekende velden zijn een fout.** Een prompt die afdrijft levert extra of hernoemde velden op, en dat hoor je liever meteen dan drie lessen later.
- **`[uncertain]` ergens in het bestand is een harde fout.** De schrijverprompt markeert daarmee een Paiboon-vorm die niet uit de meegeleverde lijst kwam. Zo'n markering hoort door een mens beslecht te worden; belandt ze in de database, dan ziet niemand haar ooit nog.

**Wat de generator wél en niet bewaakt.** Dit is bij de Language Notes pas achteraf gebleken (daar accepteerde het script `"concepts": []`, een geldig document dat redactioneel een gat is), en het staat hier daarom vooraf.

*Wél:* de vorm van het document, de verplichte velden, beide sleutelvormen, geen onbekende velden, geen `[uncertain]`, en **niet meer dan één voorbeeld per woord**. Dat laatste is vastgelegde beslissing 2, afgedwongen in het script en bewust niet in de database: een redactionele beslissing hoort herzienbaar te blijven, en dat kost hier één regel code in plaats van een migratie.

*Niet:*

- **Dekking.** Het bestand mag twee van de vijf doelwoorden bevatten en komt er gewoon door. Het script weet niet welke les je schrijft en kán het niet weten — er staat geen les in het document. Dit is de ondergrens van beslissing 2, en die hoort thuis in Stap 10, punt 1.
- **Een tweede voorbeeld dat via een ánder bestand binnenkomt.** De bovengrens wordt binnen één document bewaakt. Geeft bestand A `e1` en bestand B `e2` aan hetzelfde woord, dan staan er straks twee rijen. Daarom toont `vocabulary_example_brief_view` de bestaande voorbeelden mét hun tekst en niet alleen als teller.
- **Een niet-bestaande `source_key`.** Het script heeft geen databasetoegang. Dit faalt niet bij het genereren maar wél luid bij het seeden — zie hieronder.
- **Alle redactionele kwaliteit:** het woordbudget en de progressieregel, lesneutraliteit, of de Paiboon klopt (alleen `[uncertain]` wordt gezien), of de vertaling verenigbaar is met de gloss, de bundel stem/partikel/eerste persoon, en of het doelwoord centraal staat in zijn eigen voorbeeld. Dat is de checklist van Stap 8. Reken hier niet op het script.

**Hoe het seedbestand eruitziet, en waarom.** Eén statement per voorbeeld:

```sql
insert into public.vocabulary_examples
  (vocabulary_id, example_key, display_order, thai_script, paiboon, translation_en)
values (
  (select id from public.vocabulary_master where source_key = 'tea'),
  'e1', 1, 'ฉันชอบชาเย็นค่ะ', 'chǎn chɔ̂ɔp chaa yen kâ', 'I''d like iced tea.'
)
on conflict (vocabulary_id, example_key) do update set
  display_order  = excluded.display_order,
  thai_script    = excluded.thai_script,
  paiboon        = excluded.paiboon,
  translation_en = excluded.translation_en,
  audio_url      = case
                     when vocabulary_examples.thai_script is distinct from excluded.thai_script
                     then null
                     else vocabulary_examples.audio_url
                   end;
```

- **`values ((select ...))` en niet `select ... join vocabulary_master`.** Vindt de subquery de `source_key` niet, dan levert deze vorm `null` op en botst hij op NOT NULL: het bestand faalt luid. De join-vorm zou nul rijen invoegen en zwijgen — en dan mist er stil een voorbeeld waarvan de publicatievalidatie later dénkt dat het bestaat. Beide gedragingen zijn gemeten in `verify_vocabulary_example_seed_format.sql`, sectie 6. Dit is dezelfde les als bij de conceptclaims van de Language Notes.
- **`audio_url` gaat op null zodra `thai_script` wijzigt.** Audio die bij een oudere zin hoort is erger dan geen audio: het audioscript slaat een item met een gevulde `audio_url` over ("er is al audio"), en de leerling hoort dan de vorige zin zonder dat iemand een foutmelding ziet — precies het gevaar dat de tweede bullet bovenaan Stap 11 beschrijft. Dit is het enige punt waarop dit seedformaat bewust afwijkt van dat van de Language Notes. `voice_key` blijft wél staan: dat is een redactionele keuze en geen verwijzing die kan verouderen.
- **Geen `updated_at = now()`.** `vocabulary_examples` heeft een `BEFORE UPDATE`-trigger die dat veld zelf zet. De dialoogseed schrijft die regel wél, en terecht — `dialogs` en `dialog_blocks` hebben zo'n trigger niet.

**Waarom de sleutel niet `display_order` is.** `vocabulary_examples` draagt zijn volgorde in `unique (vocabulary_id, display_order)`. Die is niet bruikbaar als botsingssleutel, om twee onafhankelijke redenen.

Technisch: de constraint is `deferrable initially immediate` aangemaakt, en Postgres weigert een deferrable unique constraint als `on conflict`-arbiter. Let op bij het narekenen — dit is een *uitvoeringsfout, geen planfout*. `explain (costs off) insert ... on conflict (vocabulary_id, display_order) ...` slaagt gewoon en drukt zelfs `Conflict Arbiter Indexes: vocabulary_examples_vocab_order_unique` af. Wie dit met `EXPLAIN` controleert, concludeert precies het tegenovergestelde van de waarheid. Sectie 1 van het QA-script voert daarom echt uit.

Inhoudelijk, en dat weegt zwaarder: `display_order` is precies het veld dat je wilt kunnen wijzigen. Een upsert die daarop botst, zou bij het verplaatsen van een voorbeeld geen bestaande rij bijwerken maar een nieuwe invoegen, en de oude als wees achterlaten — inclusief zijn audio.

Vandaar de aparte sleutel, toegevoegd in `20260808120000_add_vocabulary_example_natural_key.sql`. Hij is **uniek binnen het woord** en niet globaal: het woord draagt de context al via de foreign key, en een sleutel als `hello-e1` zou de `source_key` een tweede keer opschrijven. Een sleutel als `a1-dialog-03-...` is hier fout — dat is de conventie van de Language Notes, waar een note bij een *les* hoort. Zie vastgelegde beslissing 8.

**Wat idempotentie wél en niet dekt.** Het bestand opnieuw draaien is de manier om een correctie door te voeren — voor **toevoegen en wijzigen**. Niet voor **verwijderen**: haal je een voorbeeld uit de JSON, dan blijft de rij gewoon in de database staan. Er is geen mechanisme dat rijen opruimt die uit het bestand verdwenen zijn, en dat is een bewuste keuze — een seed die weggelaten rijen verwijdert, wist bij een half afgemaakt bestand stilzwijgend werk.

Een voorbeeld **vervangen** is dus geen verwijderen: wijzig de tekst en houd `example_key` op `e1`. De seed werkt de bestaande rij bij, met behoud van id, en ruimt de verouderde audio op. Verwijderen is een aparte, expliciete handeling:

```sql
delete from public.vocabulary_examples e
using public.vocabulary_master v
where v.id = e.vocabulary_id
  and v.source_key = 'tea'
  and e.example_key = 'e1';
```

Haal daarna ook de bijbehorende JSON weg, anders komt de rij bij de volgende run terug. En let op Stap 10, punt 1: een doelwoord zonder voorbeeld blokkeert publicatie, dus verwijderen doe je samen met het schrijven van de vervanger.

**Herordenen** is vandaag niet aan de orde — één voorbeeld per woord heeft geen volgorde om te wisselen. Zou dat ooit veranderen, dan geldt dezelfde regel als bij de Language Notes: draai het seedbestand binnen een transactie met `set constraints all deferred;`, anders botst de tussenstand op de `display_order`-constraint.

**Controleren.** `supabase/qa/verify_vocabulary_example_seed_format.sql` meet dat de deferrable constraint geen arbiter kan zijn, draait de fixture twee keer en controleert dat een tweede run niets toevoegt, vergelijkt Thais schrift en Paiboon op `md5` in plaats van op het oog, controleert dat herordenen de sleutels bij hun rij houdt, dat een tekstwijziging de verouderde `audio_url` opruimt en een ongewijzigde run niet, en dat een onbekende `source_key` luid faalt. Het maakt daarvoor twee tijdelijke woorden aan in `vocabulary_master` en ruimt zichzelf op. Draai het na elke wijziging aan het seedformaat of aan de generator.

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
- **Eén vorm uit elke kolom.** `ผมชอบกาแฟค่ะ` — een mannelijk voornaamwoord met een vrouwelijk partikel. Het woordbudget verhindert het niet, want beide voornaamwoorden staan er vanaf les 1 in. Sinds er twee bundels zijn, is dit de fout die het vaakst zal opduiken.
- **Een partikel bijplakken om een `speaker_gender` te tonen.** Een zin die geen eerste persoon en geen eindpartikel heeft, draagt er geen. `นมหวานมากครับ` is niet "beleefder", het is een zin waar iemand iets in heeft gehangen.
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

- **~~AI-ondersteund voorstel voor voorbeeldzinnen.~~ Gebouwd op 2026-08-09**, zie "De voorbeelden laten voorstellen" in Stap 3. Het woordbudget van Stap 2 en de werklijst van Stap 1 bleken inderdaad precies de input die de generatieve stap nodig had. Alle redactionele regels en goedkeuringsmomenten gelden ongewijzigd; deze gids blijft kanaal-agnostisch geschreven, en nergens staat *wie* de zin bedenkt — alleen welke regels de zin moet halen.
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

4. **Lemma-audio in één vrouwelijke stem; voorbeelden in beide bundels, bewust verdeeld.** Een los lemma draagt geen `speaker_gender` en krijgt altijd de vrouwelijke narrator. Een voorbeeldzin krijgt per woord een toegewezen `speaker_gender`, `female` of `male`, en er wordt over de lessen heen naar evenwicht gestreefd.

   Deze beslissing is **letterlijk gelijk aan vastgelegde beslissing 2 van de Language Note-gids**, en dat is de bedoeling: kaart en note verschijnen in dezelfde les, en van sprekersgeslacht wisselen tussen die twee zonder reden is voor de leerling onverklaarbaar. Wijzigt die beslissing daar, dan wijzigt ze hier mee.

   **Herzien op 2026-08-09.** Tot dan gold hier één vrouwelijke standaardstem en dus ค่ะ als standaardpartikel, met een mannenstem alleen in voorbeelden die het contrast zélf tonen. Drie redenen om dat om te draaien, in volgorde van gewicht.

   *De bundelregel was onbeproefd.* "Nooit ผม" is een verbod op één woord, en dat haalt elk model. Wat we daarmee nooit te weten kwamen, is of het model de vormen kan *koppelen*. Met twee bundels wordt van een verbod een invariant die elke run wordt uitgeoefend en die in Stap 8 te controleren is.

   *Een mannelijke leerling zag nergens een zin die hij zelf kan zeggen.* Bij 513 kaarten met elk één voorbeeld is dat een groot oppervlak om ongebruikt te laten, en het kost redactioneel niets extra.

   *De kosten vielen weg bij nader inzien.* Er bestaat vandaag nog geen kaartaudio en `scripts/voice-config.mjs` kent nog geen enkele narratorstem — alleen de personagestemmen `mali` en `narin`, die op een kaart juist verboden zijn. Eén narrator en twee narrators zijn allebei werk dat nog gedaan moet worden; het verschil is één regel configuratie, geen herontwerp.

   **Gegenderde elementen vormen één bundel.** Stem, beleefdheidspartikel én eerste persoon horen bij elkaar; klopt er één niet, dan klopt de zin niet. Neem nooit één vorm uit de ene kolom en één uit de andere:

   | | `speaker_gender: female` | `speaker_gender: male` |
   | --- | --- | --- |
   | eerste persoon | ฉัน (*chǎn*) | ผม (*pǒm*) |
   | mededeling | ค่ะ (*kâ*) | ครับ (*kráp*) |
   | vraag | คะ (*ká*) | ครับ (*kráp*) |

   Let op de asymmetrie onderaan: ค่ะ en คะ zijn niet uitwisselbaar — ชอบเค้กไหม**คะ**, nooit ไหม**ค่ะ** — terwijl ครับ in beide gevallen ครับ blijft.

   **Het `speaker_gender` is een beperking, geen opdracht om een voornaamwoord te gebruiken.** Veel natuurlijke Thaise zinnen hebben geen eerste persoon en geen eindpartikel; die dragen er dan ook geen, en hun toewijzing blijft simpelweg ongebruikt. Plak nooit een voornaamwoord of partikel op een zin die er geen wil, alleen om een toegewezen `speaker_gender` zichtbaar te maken. Zulke zinnen tellen ook niet mee in het evenwicht.

   **Waarom `speaker_gender` en niet `register`.** "Register" lag voor de hand en was de eerste keuze, maar `register` is een bestaande kolom met een check constraint op vijf mastertabellen — `dialogs`, `vocabulary_master`, `grammar_master`, `pattern_master` en `phrase_master` — waar hij formaliteit betekent (`formal`, `informal`). `vocabulary_example_brief_view.target_words` levert die kolom bovendien al mee, dus twee betekenissen zouden op één regel van de werklijst terechtkomen. En het is precies het domein waar de andere betekenis thuishoort: beleefdheidspartikels *zijn* een registerverschijnsel in de formaliteitszin. `speaker_gender` zegt wat het bestuurt en botst nergens.

   **Wie het `speaker_gender` toewijst.** Het model verdeelt binnen één run, jij corrigeert bij het nalezen — hetzelfde patroon als overal in deze keten. Er is niets extra's voor nodig om te zien wat het gekozen heeft: ครับ of ค่ะ staat in de zin.

   Wat het model niet kan zien is de rest van het curriculum; het krijgt één les. Het evenwicht over de lessen heen is daarom jouw controle, en die is te tellen over `vocabulary_examples`. Zie de notities onderaan `supabase/planning/09_vocabulary_example_prompt_template.md` voor de query.

   **Het budget vangt dit niet af.** `vocabulary_master` bevat zowel `i` (ฉัน) als `i_male` (ผม), allebei geïntroduceerd in les 1, dus allebei staan ze vanaf les 1 in elk woordbudget. Niets in dat budget verhindert `ผมชอบกาแฟค่ะ`. Waarom dit gat juist hier bestaat: in een dialoog regelen de personages het, maar een canoniek voorbeeld heeft geen personage — alleen het toegewezen `speaker_gender`, en dat moet dus expliciet gemaakt worden.

5. **Een beleefdheidspartikel staat er waar een Thai het echt zou zeggen.** Bij aanspreken, antwoorden en vragen wel; bij een losse constatering niet. Waarom niet altijd: elk voorbeeld op ค่ะ laten eindigen maakt de zinnen beleefd maar ook eentonig, en het verstopt de kale zinsstructuur die de leerling juist moet leren zien. Voer het onderscheid consequent door, zodat de aanwezigheid van het partikel zelf informatie draagt in plaats van decoratie te zijn.

6. **Geen eigennamen in canonieke voorbeelden, op één geval na.** Gebruik een voornaamwoord, of laat het onderwerp weg zoals in natuurlijk Thais gebruikelijk is. Twee redenen die samenvallen: een naam is leesmateriaal in Thais schrift dat nergens is aangeleerd (zie de progressieregel — eigennamen tellen mee in het budget), en de namen die voor de hand liggen zijn Mali en Narin, wat het voorbeeld meteen aan een scène bindt die het niet mag hebben.

   **De uitzondering, toegevoegd 2026-08-09: een voorbeeld over iemands naam.** `ฉันชื่อ …` valt niet af te maken zonder naam, en `i`, `i_male` en `name` zijn alle drie doelwoorden van les 1. Zonder uitzondering bestaat er voor die woorden geen zinnig voorbeeld — de eerste generatierun leverde `ฉันชื่ออะไรคะ` op, "hoe heet ik?", omdat dat het enige was wat grammaticaal kon.

   **De naam komt niet uit een tabel.** Hij hoort niet in `vocabulary_master`: mét leslink zou de kaartquery hem als woordkaart renderen — die filtert nergens op, elke `lesson_vocabulary`-rij wordt een kaart — en zonder leslink heeft hij geen `first_lesson_id` en komt hij in geen enkel woordbudget. Een eigennaam is geen woord dat uitgelegd wordt. In plaats daarvan staat er een **vaste namenlijst in het promptgedeelte zelf**, in `supabase/planning/09_vocabulary_example_prompt_template.md` en woordelijk hetzelfde in `08` — één roster voor het hele project, zoals de partikeltabel.

   **Waarom vast en niet per generatierun.** Dat was de eerste opzet, maar een canoniek voorbeeld is permanent en lesneutraal: het verschijnt ook in les 24. Een lijst die per run verschilt, levert de leerling twee schrijfwijzen van dezelfde naam op — op 2026-08-09 stond `มะลิ` in de dialogen naast `มาลี` in de `usage_note` van `name` — en brengt bij elke run opnieuw de kans op een gereconstrueerde Paiboon-vorm. De prijs is duplicatie over twee templates; die staat in beide bestanden vermeld.

   Drie voorwaarden voor een naam die je later toevoegt. De Paiboon komt uit een betrouwbare bron en niet uit het hoofd — er is geen masterlijst om hem tegen te controleren, dus dit is de enige plek in de keten waar een transliteratie ongecontroleerd binnenkomt. De naam is niet die van een personage uit een dialoog, want dat is precies de scènebinding die de hoofdregel verbiedt. En hij gaat op beide plaatsen tegelijk erin. Zie "De eigennamen" onderaan `09` voor de huidige lijst en de herkomst ervan.

7. **Prompts en audit trail volgen het bestaande kanaal.** Blanco template in `supabase/planning/`, ingevulde prompt in `supabase/prompts/`, modeloutput in `supabase/generation/`, alles in versiebeheer — zoals bij de dialogen en de Language Notes.

   Uitgewerkt op 2026-08-09. Voor deze keten:

   | | Pad |
   | --- | --- |
   | template | `supabase/planning/09_vocabulary_example_prompt_template.md` |
   | ingevulde prompt | `supabase/prompts/vocabulary-examples/a1_dialog_XX_examples_prompt.md` |
   | modeloutput | `supabase/generation/vocabulary-examples/a1_dialog_XX_examples.json` |

   Eén template, geen planner en schrijver — anders dan bij de Language Notes, waar `07` en `08` naast elkaar staan omdat de verdeling concepten → notes goedkeuring vraagt vóór er geschreven wordt. Hier valt er niets te verdelen: elk doelwoord krijgt precies één voorbeeld en de werklijst volgt rechtstreeks uit de brief-view. De twee goedkeuringsmomenten van Stap 1 en Stap 2 blijven bestaan; ze liggen vóór het invullen van de prompt in plaats van tussen twee prompts.

8. **Een voorbeeld wordt geïdentificeerd via de sleutel van het wóórd, nooit via een les.** Een sleutel in de vorm `a1-dialog-03-...` is fout, ook al is dat de conventie bij de Language Notes — daar hoort een voorbeeld bij een les, hier bij een woord. Dat verschil is de lesneutraliteit uit "De twee eigenaarschappen", en het hoort ook in de brondata zichtbaar te zijn.

   Uitgewerkt op 2026-08-08. De identiteit van een rij is het paar (`source_key`, `example_key`), waarbij `example_key` uniek is binnen het woord en vandaag altijd `e1` luidt. Het invoerdocument draagt geen `lesson_key`; de les zit alleen in de bestandsnaam, als archiveringslabel voor de batch. Zie Stap 11 voor het volledige contract en `20260808120000_add_vocabulary_example_natural_key.sql` voor de motivering van de sleutel.

## Praktische checklist per les

1. Verzamel de doelwoorden, controleer bestaande voorbeelden, en stel de werklijst op; laat die goedkeuren (Stap 1).
2. Stel het toegestane woordbudget vast volgens de progressieregel; laat het goedkeuren (Stap 2).
3. Schrijf per doelwoord één voorbeelddrieluik — lesneutraal, zelfstandig leesbaar, binnen budget, met de twee `speaker_gender`-bundels evenwichtig verdeeld (Stap 3).
4. Controleer elke Paiboon-vorm tegen de masterlijst; bevestig อัว-klinkerlengte per woord (Stap 4).
5. Schrijf natuurlijke Engelse vertalingen, verenigbaar met de gloss en consistent met dialoog en notes (Stap 5).
6. Controleer lemma-teksten en lesnotities; instruerende tekst in de imperatief (Stap 6).
7. Zet de volgorde: prototypisch voorbeeld eerst, woorden in dialoogvolgorde (Stap 7).
8. Doorloop de redactionele QA-checklist en laat de tekst goedkeuren (Stap 8).
9. Genereer lemma- en voorbeeldaudio; bewaak stem/partikel-overeenkomst; nooit dialoogaudio hergebruiken (Stap 9).
10. Valideer vóór publicatie: dekking, progressieregel, volledige drieluiken, audio, nummering (Stap 10).
11. Leg de voorbeelden vast in `supabase/generation/vocabulary-examples/`, genereer en draai het seedbestand, en commit alles samen (Stap 11).
