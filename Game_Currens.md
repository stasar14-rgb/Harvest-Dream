# Harvest Dream – aktueller Spielstand

## Zweck dieser Datei

Diese Datei enthält den aktuell gültigen Konzeptstand von **Harvest Dream**.

- Noch nicht endgültig entschiedene Punkte werden als **offen** gekennzeichnet.
- Spätere Inhalte werden getrennt vom Grundspiel dokumentiert.
- Veraltete oder gestrichene Ideen sollen entfernt oder klar als verworfen markiert werden.
- Bei widersprüchlichen Angaben darf nicht stillschweigend eine Variante gewählt werden. Der Widerspruch muss zuerst geklärt werden.
- Systeme sollen modular, erweiterbar und möglichst unabhängig voneinander aufgebaut werden, damit Inhalte später ergänzt, verändert oder entfernt werden können, ohne das gesamte Spiel umzubauen.

## Plattform, Darstellung und technische Zielrichtung

- **Zielplattform der ersten Entwicklungsphase:** PC
- **Spätere Zielplattform:** Handy
- Das Spiel wird zunächst vollständig auf dem PC entwickelt und getestet.
- Die technische Struktur, Benutzeroberfläche und Eingabeverarbeitung müssen so angelegt werden, dass eine spätere Handy-Version ergänzt werden kann, ohne die Kernsysteme neu aufzubauen.
- Das Spiel verwendet eine **2D-Top-down-Perspektive** im Pixelart-Stil.
- Grundlage der Spielwelt ist ein **32 × 32 Pixel** großes Raster. Geländekacheln sind 32 × 32 Pixel groß.
- Die Richtgröße für den Spielercharakter beträgt ungefähr **32 × 48 Pixel**.
- Die Darstellung erfolgt im **Querformat mit einem Seitenverhältnis von 16:9**.
- Die interne Basisauflösung und das PC-Testfenster betragen **1280 × 720 Pixel**.
- Pixelgrafiken werden ohne Glättung dargestellt. Die Spielwelt verwendet einen **2×-Kamerazoom**, damit das 32×32-Pixel-Raster und die Figuren trotz der höheren Basisauflösung in der vorgesehenen sichtbaren Größe erscheinen.
- Die Benutzeroberfläche wird später über Anker und flexible Container an unterschiedliche Bildschirmgrößen angepasst.
- Die erste PC-Steuerung verwendet **WASD** für die Bewegung und die **Maus** für Werkzeuge, Aktionen, Platzierung und Menüs.
- Touch-Eingaben für Handys und optionale Controller-Unterstützung werden später über dasselbe allgemeine Eingabesystem ergänzt.

## 1. Grundidee

**Harvest Dream** ist ein Farming- und Aufbauspiel.

Der Spieler baut zunächst einen eigenen Bauernhof auf. In der Nähe befindet sich ein kleines, verlassenes und beschädigtes Dorf. Mit der Zeit repariert und erweitert der Spieler dieses Dorf. Anfangs ist das Dorf leer. Neue Bewohner ziehen erst ein, nachdem passende Häuser wiederaufgebaut wurden.

Der langfristige Spielfortschritt besteht aus:

1. Bauernhof entwickeln
2. Rohstoffe sammeln und verarbeiten
3. Berufe verbessern
4. zerstörte Häuser reparieren
5. neue Bewohner ins Dorf holen
6. Dorf und Spielwelt schrittweise erweitern

## 2. Geschichte

Die Geschichte wird im Laufe der Entwicklung ausgearbeitet und geschrieben.

Aktuell gibt es noch keine festgelegte vollständige Handlung. Die technischen Systeme und Spielinhalte sollen deshalb so aufgebaut werden, dass Quests, Ereignisse, Bewohner und neue Handlungsabschnitte später ergänzt werden können.

## 3. Berufe und Sammelgegenstände

### Berufe im Grundspiel

- Bergbau
- Schmied
- Landwirtschaft
- Holzfäller
- Kochen
- Handwerk für den Bau von Hofobjekten wie Straßen und Fackeln
- Kampf

### Später geplante Berufe und Tätigkeiten

- Fischen
- Verzauberung
- weitere Berufe nach Bedarf

### Sammelbare Gegenstände im Grundspiel

In der Spielwelt sollen unter anderem folgende Gegenstände gesammelt werden können:

- Beeren
- Steine
- Holz
- Pilze

### Später geplante Funde

- vergrabene Artefakte
- alte Münzen
- Knochen
- weitere seltene oder besondere Fundstücke

Für die erste Version werden nur die notwendigen Grundressourcen umgesetzt. Zusätzliche Sammelgegenstände folgen später.

### Gegenstandsdaten und Katalog

Jeder Gegenstand besitzt eigenständige Daten:

- eindeutige ID
- sichtbarer Name
- Icon
- Beschreibung
- Kategorie
- Seltenheit
- Grundpreis
- maximale Stapelgröße
- optionale Wachstumsdauer in Tagen für Saatgut und Baumsetzlinge

Vorerst gelten folgende Standard-Stapelgrößen:

- Holz und Erz beziehungsweise Materialien: **99**
- Essen und Verbrauchsgegenstände: **10**
- Fische: **20 pro Fischart**
- nicht stapelbare Gegenstände: **1**

Ein einzelner Gegenstand kann seine Standard-Stapelgröße überschreiben. Qualitätsstufen werden technisch vorbereitet, aber erst später als eigenes System umgesetzt.

### Inventar und Aktionsleiste

- Ein neuer Spielstand beginnt mit **16 Inventarplätzen**.
- Die **10 Plätze der Aktionsleiste sind zusätzliche Gegenstandsplätze**. Damit stehen anfangs insgesamt 26 Plätze zur Verfügung.
- Es gibt zwei kaufbare Taschenerweiterungen. Jede Erweiterung schaltet 16 weitere Inventarplätze frei.
- Nach beiden Erweiterungen besitzt der Spieler 48 Inventarplätze und 10 Aktionsleistenplätze, insgesamt also 58 Plätze.
- Die Goldkosten der beiden Erweiterungen werden später festgelegt.
- Das Inventar wird auf dem PC mit **B** geöffnet und geschlossen.
- Die Aktionsleiste kann mit den Zahlentasten **1 bis 9 und 0** sowie mit der Maus ausgewählt werden.
- Für die aktuelle Testfläche beginnt die Aktionsleiste ausschließlich mit: **1 Kupferaxt, 2 Kupferspitzhacke, 3 Kupferhacke, 4 Kupfergießkanne, 5 Schaufel und 6 Kartoffelsaatgut**. Die übrigen vier Plätze bleiben leer.
- Gegenstände können mit gedrückter linker Maustaste zwischen Inventar- und Aktionsleistenplätzen verschoben werden.
- **Umschalt + linke Maustaste** verschiebt einen vollständigen Stapel automatisch in den nächsten verfügbaren Platz des jeweils anderen Bereichs.
- **Umschalt + rechte Maustaste** teilt einen Stapel zur Hälfte und legt den abgetrennten Teil in den nächsten freien Platz desselben Bereichs.
- **Strg + rechte Maustaste** öffnet eine Mengenauswahl und legt die gewählte Teilmenge in einen freien Platz desselben Bereichs.
- Bei Händlern soll Umschalt + linke Maustaste später den vollständigen angeklickten Stapel verkaufen.
- Ist die gesamte verfügbare Kapazität voll, bleiben nicht aufnehmbare Gegenstände auf dem Boden liegen.
- Käufe und Questabschlüsse mit Gegenstandsbelohnung werden bei fehlendem Platz verhindert und zeigen eine verständliche Meldung.
- Ein fehlgeschlagener Einfügeversuch entfernt oder ersetzt niemals bereits vorhandene Gegenstände.

## 4. Dorfaufbau

Die Siedlung beginnt als kleines **Dorf** mit **vier zerstörten und unbewohnten Häusern**. Durch den Wiederaufbau, neue Gebäude und einziehende Bewohner wächst das Dorf im späteren Spielverlauf zu einer **Stadt** heran.

Die Bezeichnungen richten sich nach dem Entwicklungsstand:

- am Anfang: Dorf
- später nach ausreichendem Ausbau: Stadt

- Der Spieler muss die Häuser mit gesammelten und verarbeiteten Materialien wiederaufbauen.
- Erst nach dem Wiederaufbau eines Hauses kann ein neuer Bewohner einziehen.
- Die genauen Bewohner und Bedingungen werden später festgelegt.
- Das Anfangsdorf muss räumlich so angelegt werden, dass es in mindestens eine vorgesehene Richtung sauber erweitert werden kann.
- Erweiterungsflächen dürfen nicht durch unveränderbare Kartengrenzen oder wichtige Startgebäude blockiert werden.
- Gebäudezustände wie zerstört, im Aufbau und repariert sollen getrennt verwaltet werden.

## 5. Kämpfe

Kämpfe spielen zu Beginn nur eine geringe Rolle und gehören nicht zum ersten Kernumfang.

Ein Kampfsystem wird später ergänzt. Die übrigen Systeme dürfen deshalb nicht fest von einem bereits vorhandenen Kampfsystem abhängig sein.

## 6. Berufsfortschritt

Berufe erhalten durch ihre aktive Benutzung Erfahrungspunkte.

Erfahrung wird ausschließlich für vollständig abgeschlossene Tätigkeiten vergeben. Einzelne Schläge oder begonnene, aber nicht fertiggestellte Aktionen geben keine Erfahrung.

Beispiele:

- Bergbau erhält Erfahrung, wenn ein Stein oder Erzvorkommen vollständig abgebaut wurde.
- Holzfäller erhält Erfahrung, wenn ein Baum vollständig gefällt wurde.
- Landwirtschaft erhält Erfahrung, wenn eine erntereife Pflanze erfolgreich geerntet wurde.
- Schmied, Kochen, Handwerk und Kampf erhalten später Erfahrung beim Abschluss ihrer jeweiligen Tätigkeit.

Für die ersten Tests geben das Fällen eines Baums, der vollständige Abbau eines Steins oder Erzvorkommens und die erfolgreiche Kartoffelernte jeweils **10 Erfahrungspunkte**. Auch die vorbereiteten Werte der übrigen Berufe beginnen bei 10. Jeder Tätigkeitswert bleibt einzeln im Inspector anpassbar.

### Geplanter Levelbereich

Berufe sollen zunächst von **Level 1 bis Level 50** aufsteigen können.

Die vorläufige Testschwelle beträgt **100 Erfahrungspunkte pro Level**. Basiswert und zusätzliche Erfahrung pro Level sind im Inspector getrennt einstellbar; die endgültige Erfahrungskurve wird erst nach Spieltests festgelegt.

### Beispiel: Bergbau

Pro Bergbau-Level ist aktuell vorgesehen:

- **1 % schnelleres Abbauen**
- **0,5 feste Energiepunkte weniger Energieverbrauch**

Zusätzlich soll es alle zehn Level einen besonderen Berufs-Perk geben.

Beispiel für Bergbau-Level 10:

- Die Chance auf doppeltes Erz erhöht sich um **10 %**.

Geplante Meilensteine:

- Level 10
- Level 20
- Level 30
- Level 40
- Level 50

Die genauen Erfahrungskurven, Perks und Maximalwerte werden später festgelegt.

Bis Level 50 ergibt die Verringerung insgesamt **25 Energiepunkte weniger Verbrauch**. Ein Mindestverbrauch oder eine andere Begrenzung wird bei der späteren Balance festgelegt, damit Berufsaktionen nicht unbeabsichtigt einen negativen Energieverbrauch erhalten.

## 7. Energiesystem

Der Spieler beginnt mit **100 maximaler Energie**. Nach normalem Schlaf wird die Energie vollständig bis zum aktuellen Maximalwert aufgefüllt.

Geht der Spieler rechtzeitig schlafen, beginnt der nächste Tag mit voller Energie. Beim erzwungenen Einschlafen um 02:00 Uhr beginnt der nächste Tag nur mit **80 % der maximalen Energie**. Bei anfänglich 100 maximaler Energie sind das 80 Energie.

Die maximale Energie kann später durch verschiedene Fortschritte und Inhalte erhöht werden. Die Strafe für zu spätes Schlafen bleibt dabei prozentual und beträgt weiterhin 20 % des jeweils aktuellen Maximalwertes.

Im Winter kosten alle energieverbrauchenden Aktivitäten **25 % mehr Energie**. Aktive warme Kleidung verhindert diesen zusätzlichen Winterverbrauch vollständig.

Der Spieler besitzt Energie, die durch die Ausübung von Berufen verbraucht wird.

Beispiele für energieverbrauchende Berufsaktionen:

- Erz und Steine mit der Spitzhacke abbauen
- Bäume oder Holzquellen mit der Axt bearbeiten
- landwirtschaftliche Tätigkeiten mit Werkzeugen ausführen
- Gegenstände im Rahmen eines Berufs herstellen oder bearbeiten, sofern für die jeweilige Tätigkeit Energiekosten vorgesehen sind

Die Energiekosten müssen pro Aktion beziehungsweise Werkzeug festlegbar sein. Berufsboni können diesen Verbrauch reduzieren. Beim Bergbau sinkt der Verbrauch nach aktuellem Stand pro Berufslevel um feste **0,5 Energiepunkte**.

Die maximale Energie, Regeneration, Wiederherstellung und der Mindestverbrauch pro Aktion werden später festgelegt.

## 8. Zeit und Jahreszeiten

Es gibt vier Jahreszeiten:

1. Frühling
2. Sommer
3. Herbst
4. Winter

Jede Jahreszeit dauert **28 Spieltage**. Ein vollständiges Spieljahr umfasst damit **112 Spieltage**.

Ein Spieltag besitzt **24 Ingame-Stunden**.

Festgelegter Tagesablauf:

- Ein vollständiger normaler Spieltag dauert **20 Minuten in Echtzeit**.
- Ein normaler Tag beginnt um **06:00 Uhr**.
- Der Spieler kann bis spätestens **02:00 Uhr** wach bleiben.
- Ist der Spieler um 02:00 Uhr noch wach, schläft er automatisch ein.
- Nach einem erzwungenen Einschlafen wacht der Spieler erst um **08:00 Uhr** auf und verliert zusätzlich **20 % seiner Energie**.
- Die Zeit pausiert in Menüs, während Dialogen sowie im eigenen Haus und in Häusern von NPCs.

### Auswirkungen der Jahreszeiten

- Im Frühling, Sommer und Herbst können Pflanzen im Freien wachsen.
- Pflanzen können auf bestimmte Jahreszeiten begrenzt werden.
- Beeren und andere Waldfrüchte können abhängig von der Jahreszeit unterschiedliche Vorkommen besitzen.
- Pilze können im Frühling, Sommer und Herbst vorkommen.
- Im Winter wachsen wegen des Schnees keine Pflanzen im Freien und es erscheinen keine Pilze.
- Im Winter können stattdessen besondere Winterfrüchte im Wald vorkommen.
- Ein Gewächshaus soll später Pflanzenwachstum im Winter ermöglichen.
- Bestimmte Fischarten können nur in festgelegten Jahreszeiten gefangen werden.
- NPC-Geburtstage werden einem bestimmten Tag und einer bestimmten Jahreszeit zugeordnet.
- Im Winter soll der Energieverbrauch bestimmter Tätigkeiten erhöht sein.
- Später kann warme Kleidung den erhöhten Energieverbrauch im Winter verhindern.

**Noch offen:**

- genaue Pflanzen, Beeren, Winterfrüchte und Fische pro Jahreszeit
- Höhe des zusätzlichen Energieverbrauchs im Winter
- notwendiger Wärmewert der Kleidung

## 9. Werkzeuge

### Werkzeuge im Grundspiel

- Spitzhacke
- Hacke
- Gießkanne
- Schaufel
- Axt
- Sichel

### Später geplante Werkzeuge

- Angel
- weitere Werkzeuge passend zu neuen Berufen und Inhalten

Werkzeuge sollen als eigenständige Daten und nicht fest im Spieler-Code angelegt werden. Dadurch können neue Werkzeuge, Werte, Verbesserungen und Aktionen später ergänzt oder geändert werden.

### Haltbarkeit und Verbesserungsstufen

- Werkzeuge besitzen **keine Haltbarkeit**, gehen nicht kaputt und müssen nicht repariert werden.
- Der Spieler beginnt bei verbesserbaren Werkzeugen mit der Stufe **Kupfer**. Eine zusätzliche Werkzeugstufe vor Kupfer ist nicht vorgesehen.
- Die Materialstufen für verbesserbare Werkzeuge sind:
  1. Kupfer
  2. Bronze
  3. Eisen
  4. Stahl
- **Axt, Spitzhacke, Hacke und Gießkanne** verwenden diese vier Verbesserungsstufen.
- Bei **Axt und Spitzhacke** erhält jede Ressource eine Grund-Schlagzahl für ein Kupferwerkzeug. Jede höhere Materialstufe benötigt genau einen Schlag weniger:
  - Kupfer: Grund-Schlagzahl der Ressource
  - Bronze: Grund-Schlagzahl − 1
  - Eisen: Grund-Schlagzahl − 2
  - Stahl: Grund-Schlagzahl − 3
- Unabhängig von der Werkzeugstufe bleibt mindestens **ein Schlag** notwendig. Dadurch können verschiedene Bäume, Steine und Erze eigene Grund-Schlagzahlen besitzen.
- Jeder einzelne Schlag mit Axt oder Spitzhacke besitzt abhängig von der Materialstufe folgende Grundkosten:
  - Kupfer: **5 Energie**
  - Bronze: **4 Energie**
  - Eisen: **3 Energie**
  - Stahl: **2 Energie**
- Winteraufschlag und spätere Berufsboni werden auf diese Grundkosten angewendet.
- **Hacke und Gießkanne** verwenden dieselben freischaltbaren Bearbeitungsflächen:
  1. Kupfer (Stufe 1): **1 Feld**
  2. Bronze (Stufe 2): **3 Felder** als 3×1-Reihe
  3. Eisen (Stufe 3): **6 Felder** als 3×2-Fläche
  4. Stahl (Stufe 4): **9 Felder** als 3×3-Fläche
- Hacke und Gießkanne werden mit gedrückt gehaltener **linker Maustaste** aufgeladen:
  - kurzer Klick: 1 Feld für **5 Energie**
  - erste Aufladestufe: 3 Felder für **7,5 Energie**
  - zweite Aufladestufe: 6 Felder für **10 Energie**
  - dritte Aufladestufe: 9 Felder für **12,5 Energie**
- Dies sind die vorläufigen Grundkosten vor späteren Verringerungen durch Werkzeugstufen oder Berufsboni und vor dem winterlichen Aufschlag.
- Jede höhere Aufladestufe kostet mehr Energie, ist bezogen auf die Anzahl der gleichzeitig bearbeiteten Felder jedoch effizienter.
- Jede zusätzliche Aufladestufe benötigt **1 Sekunde**. Ein kurzer Klick bearbeitet 1 Feld, nach 1 Sekunde werden 3 Felder, nach 2 Sekunden 6 Felder und nach 3 Sekunden 9 Felder erreicht.
- Die maximal erreichbare Aufladestufe wird durch die aktuelle Materialstufe des Werkzeugs begrenzt. Längeres Gedrückthalten überschreitet die bereits freigeschaltete Fläche nicht.
- Während des Aufladens wächst die Zielmarkierung nach jeder erreichten Sekunde sichtbar auf die neue Fläche. Beim Loslassen wird genau die angezeigte Fläche bearbeitet.
- Die Bearbeitungsfläche liegt unmittelbar vor dem Spieler und dreht sich passend zu seiner Blickrichtung.
- Mit jeder höheren Materialstufe sinkt außerdem der Energieverbrauch von Hacke und Gießkanne.
- Mögliche spätere Werkzeugstufen vergrößern die Fläche nicht über 3×3 hinaus, sondern senken ausschließlich den Energieverbrauch.
- Die Grund-Schlagzahlen der einzelnen Bäume, Steine und Erze bleiben offen und werden bei den jeweiligen Ressourcendaten festgelegt.
- Die **Sichel** besitzt keine Verbesserungsstufen, da sie Gras unabhängig vom Material gleich schneidet. Ein Einsatz kostet **5 Energie**.
- Die **Schaufel** besitzt keine Verbesserungsstufen, da sie ausschließlich ein Loch beziehungsweise eine dafür vorgesehene Bodenstelle gräbt. Ein Einsatz kostet **5 Energie**.
- Winteraufschlag und spätere Berufsboni werden auch bei Sichel und Schaufel auf diese Grundkosten angewendet.

### Erze und Barren

- Kupferbarren: **3 Kupfererz = 1 Kupferbarren**
- Bronzebarren: **2 Kupfererz + 1 Zinnerz = 1 Bronzebarren**
- Eisenbarren: **3 Eisenerz + 1 Kohle = 1 Eisenbarren**
- Stahlbarren: **3 Eisenerz + 2 Kohle = 1 Stahlbarren**
- Silberbarren: **3 Silbererz = 1 Silberbarren**
- Goldbarren: **3 Golderz = 1 Goldbarren**
- Silber- und Goldbarren sind für Schmuck und weitere spätere Gegenstände vorgesehen, nicht als anfängliche Werkzeugstufen.
- Jeder Barren benötigt zunächst **60 Sekunden reale Spielzeit**. Die Dauer bleibt pro Rezept anpassbar.
- Eine beliebige herstellbare Menge kann gemeinsam in Auftrag gegeben werden. Die Schmiede stellt trotzdem immer nur einen Barren nach dem anderen her.
- Alle Rohstoffe des Auftrags werden sofort reserviert. Fehlende Mengen werden aus dem Spielerinventar in das Schmiedelager übertragen; vorhandene freie Materialien im Schmiedelager werden zuerst verwendet.
- Die Schmiede verarbeitet ihre Warteschlange weiter, während der Spieler das Menü geschlossen hat oder sich in einem anderen Areal befindet. Eine Offline-Produktion bei beendetem Spiel ist noch nicht festgelegt.
- Das gemeinsame Schmiedelager besitzt **20 Plätze als 5 × 4 Raster** und enthält Rohstoffe sowie fertige Gegenstände.
- Das Schmiedelager ist ausschließlich ein Zwischenlager für die Herstellung und kann nicht manuell aus dem Spielerinventar befüllt werden.
- Verfügbare Stapel werden mit **Umschalt + linker Maustaste** aus dem Schmiedelager ins Spielerinventar verschoben. Für laufende Aufträge reservierte Mengen können nicht entnommen werden.
- Beim Abbruch bleiben alle noch nicht verbrauchten Materialien im Schmiedelager und können direkt für weitere Aufträge verwendet werden.
- Das Schmiedemenü zeigt links die Rezeptliste mit Icon, Namen und farbigem Materialstatus. Rechts stehen Rezeptdetails, benötigte und vorhandene Mengen sowie die Schaltflächen 1×, 10× und Max. Unten werden laufender Auftrag, Fortschritt, Abbruch und das gemeinsame Lager angezeigt.
- Das Schmiedemenü kann mit **Escape** oder über einen sichtbaren Schließen-Button geschlossen werden.
- Die Schmiede muss später zuerst auf dem Hof gebaut werden. Bis das Gebäude-Bausystem existiert, steht auf der Testfläche eine ausdrücklich freigeschaltete Test-Schmiede bereit.

### Bedienung und allgemeine Interaktion

- Werkzeuge werden auf dem PC mit der **linken Maustaste** benutzt.
- Gespräche mit NPCs sowie das Öffnen von Türen, Truhen und ähnlichen Objekten erfolgen mit der Taste **E**.
- Die anfängliche Interaktionsreichweite beträgt **32 Pixel**, entsprechend einem Feld des 32 × 32-Pixel-Rasters.
- Das nächstgelegene erreichbare Interaktionsobjekt wird sichtbar hervorgehoben.
- Werkzeugaktionen und allgemeine Interaktionen bleiben getrennte Eingabeaktionen, damit später Touch- und Controller-Bedienung ergänzt werden können.
- Das Werkzeug im aktuell ausgewählten Aktionsleistenplatz ist das aktive Werkzeug. Ein leerer Platz oder ein normaler Gegenstand löst keine Werkzeugaktion aus.
- Ein Wechsel des Aktionsleistenplatzes während des Aufladens bricht die laufende Aufladung ab.
- Das Öffnen des Inventars verhindert Werkzeugaktionen.
- Jedes ausgewählte Werkzeug zeigt seine tatsächlichen Zielfelder sichtbar an. Axt, Spitzhacke, Schaufel und Sichel markieren jeweils das einzelne **32 × 32-Pixel-Rasterfeld** direkt vor dem Spieler. Hacke und Gießkanne zeigen abhängig von Aufladung und Materialstufe alle Felder ihrer jeweiligen Bearbeitungsfläche.
- Alle Werkzeuge verwenden dasselbe allgemeine Zielfeldsystem. Die Markierung liegt unmittelbar am Feld des Spielers an und wechselt entsprechend seiner Blickrichtung nach oben, unten, links oder rechts.
- Die Werkzeug-Zielfeldanzeige ist beim Start sichtbar und kann jederzeit mit **K** vollständig aus- oder wieder eingeblendet werden. Das Umschalten verändert ausschließlich die Anzeige, nicht die tatsächliche Werkzeugwirkung.
- Sie zeigt genau das Feld beziehungsweise bei Hacke und Gießkanne alle Felder an, die beim nächsten Einsatz bearbeitet werden:
  - Hacke: angezeigte Fläche als Ackerboden bearbeiten
  - Gießkanne: angezeigte Fläche bewässern
  - Schaufel: einzelnes Feld ausgraben beziehungsweise eine dafür vorgesehene Bodenaktion ausführen
- Die Markierung ist nur sichtbar, solange eines dieser drei Werkzeuge als aktives Werkzeug ausgewählt ist.
- Ob das markierte Feld mit dem jeweiligen Werkzeug bearbeitet werden darf, entscheidet später das zuständige Landwirtschafts- beziehungsweise Bodensystem. Eine ungültige Stelle darf durch den Einsatz nicht verändert werden.

### Boden- und Ackerfeldregeln

- Die Hacke wandelt ein dafür erlaubtes normales Bodenfeld in Ackerboden um.
- Die Schaufel entfernt angelegten Ackerboden und stellt das Feld wieder als normalen Boden her.
- Ein bewässertes Ackerfeld bleibt bis zum Beginn des nächsten Spieltages feucht und wird dann wieder trocken.
- Ackerboden ohne Pflanze verschwindet nach **drei vollständigen Spieltagen** automatisch und wird wieder zu normalem Boden.
- Ein bepflanztes Ackerfeld wird durch diese Drei-Tage-Regel nicht entfernt.
- Welche Bodenfelder bearbeitbar sind, wird später pro Karte beziehungsweise Bodenart festgelegt.
- Enthält eine Mehrfeldaktion sowohl gültige als auch ungültige Zielfelder, werden ausschließlich die gültigen Felder bearbeitet.
- Die Energiekosten werden proportional zur Anzahl gültiger Zielfelder angepasst: Grundkosten der gewählten Aufladestufe × gültige Felder ÷ alle Zielfelder der Aufladestufe.
- Das proportionale Ergebnis wird mathematisch auf den nächsten **0,5-Energiewert** gerundet.
- Ein gültiges Feld zählt für die Energiekosten auch dann mit, wenn die Aktion seinen Zustand nicht mehr verändert, beispielsweise beim erneuten Bewässern eines bereits nassen Feldes.
- Sind sämtliche Zielfelder ungültig, wird keine Aktion ausgeführt und keine Energie verbraucht.
- Das Bewässern eines leeren Ackerfeldes setzt dessen Drei-Tage-Zähler nicht zurück. Nur eine vorhandene Pflanze verhindert das automatische Zurücksetzen zu normalem Boden.

### Pflanzen-Grundregeln

- Saatgut kann sowohl auf trockenem als auch auf bewässertem Ackerboden ausgesät werden.
- Eine Pflanze wächst am Tagesbeginn nur dann um einen Wachstumstag weiter, wenn ihr Feld am vorherigen Tag bewässert wurde.
- Wird eine Pflanze nicht gegossen, pausiert ihr Wachstum für diesen Tag.
- Nach **drei aufeinanderfolgenden trockenen Tagen** verdirbt die Pflanze und wächst nicht weiter.
- Ein späterer bewässerter Tag setzt die laufende Zählung trockener Tage wieder auf null, solange die Pflanze noch nicht verdorben ist.
- Nach der Ernte bleibt das Feld als Ackerboden bestehen. Es muss nicht erneut mit der Hacke bearbeitet werden.
- Ob der bestehende Ackerboden nach der Ernte trocken oder bewässert ist, bleibt unverändert.
- Konkrete Pflanzenarten, Wachstumszeiten, Erntemengen, Jahreszeiten und Grafiken werden später als austauschbare Pflanzendaten eingetragen.
- Die erste Testpflanze ist die **Kartoffel**. Sie wächst im Frühling und benötigt **vier bewässerte Wachstumstage**.
- Eine erntereife Kartoffelpflanze liefert bei der Ernte zufällig **eine bis drei Kartoffeln**.
- Kartoffelsaatgut wird aus der Aktionsleiste mit der linken Maustaste auf das markierte Feld direkt vor dem Spieler gesät.
- Eine erntereife Pflanze auf dem Feld direkt vor dem Spieler wird mit **E** geerntet.

### Ressourcenabbau

- Bäume werden mit der Axt bearbeitet. Ein Testbaum benötigt mit der Kupferaxt **8 Schläge** und liefert **3 Holz**.
- Steine und Erzvorkommen werden mit der Spitzhacke bearbeitet.
- Ein Teststein benötigt mit der Kupferspitzhacke **6 Schläge** und liefert **2 Stein**.
- Ein Test-Erzvorkommen benötigt mit der Kupferspitzhacke **7 Schläge** und liefert **1 Erz**.
- Bronze benötigt jeweils einen Schlag weniger als Kupfer, Eisen zwei und Stahl drei Schläge weniger.
- Die Energiekosten pro Schlag betragen weiterhin 5 für Kupfer, 4 für Bronze, 3 für Eisen und 2 für Stahl.
- Abgebaute Bäume, Steine und Erzvorkommen erscheinen nach **3 vollständigen Spieltagen** erneut.
- Beim vollständigen Abbau wird die erhaltene Ressource als Bodenbeute an der Position des Vorkommens abgelegt.
- Trefferstand und verbleibende Wiedererscheinungstage sind für spätere Spielstände vorbereitet.

### Bodenbeute

- Bodenbeute wird automatisch aufgenommen, sobald sich der Spieler auf **48 Pixel** nähert. Diese anfängliche Entfernung bleibt im Inspector anpassbar.
- Reicht der freie Inventarplatz nur für einen Teil des Stapels, wird nur diese Menge aufgenommen. Der Rest bleibt unverändert auf dem Boden.
- Ist das Inventar vollständig gefüllt, bleibt die gesamte Beute auf dem Boden liegen.
- Gleiche Gegenstände innerhalb von **32 Pixeln** verbinden sich automatisch bis zur jeweiligen maximalen Stapelgröße.
- Mengen oberhalb der maximalen Stapelgröße bilden einen weiteren Bodenstapel.
- Nicht aufgenommene Bodenbeute verschwindet beim nächsten Tagesbeginn.
- Bodenbeute besitzt eigene Daten für spätere Spielstände, damit sie beim Speichern während desselben Tages erhalten werden kann.

## 10. Welt und Areale

### Areale im Grundspiel

- Hof
- Dorf, das später zur Stadt ausgebaut wird
- Wald

Weitere Gebiete werden später ergänzt.

Jedes Gebiet bleibt ein eigenes Areal. Hof, Dorf und Wald sollen nicht als eine einzige untrennbare Karte aufgebaut werden. Übergänge verbinden die einzelnen Areale miteinander.

### Karte

Es soll eine Gebietskarte geben.

Im Grundspiel zeigt sie:

- das aktuelle Gebiet
- die Position des Spielers innerhalb dieses Gebiets

Später soll sie zusätzlich die Position befreundeter NPCs anzeigen können.

Die Kartenanzeige muss deshalb Markierungen dynamisch hinzufügen und entfernen können, ohne für jeden NPC fest programmiert zu werden.

## 11. Ziel der ersten Version

Die erste spielbare Version bildet das technische und spielerische Fundament.

Sie soll zunächst sicherstellen, dass die wichtigsten Grundabläufe funktionieren:

- Spieler bewegen
- zwischen den einzelnen Arealen wechseln
- Zeit und Jahreszeiten verwalten
- Energie verwenden und regenerieren
- Grundressourcen sammeln
- Werkzeuge benutzen
- Landwirtschaft betreiben
- Berufe durch Benutzung steigern
- Gegenstände lagern und verarbeiten
- erste zerstörte Häuser wiederaufbauen
- neue Bewohner grundsätzlich einziehen lassen
- Spielstand speichern und laden
- Karte und Spielerposition anzeigen

Zusätzliche Inhalte werden erst danach schrittweise ergänzt.

## 12. Später geplante Inhalte

Diese Inhalte gehören ausdrücklich nicht zum ersten Grundumfang:

- Tierhaltung
- umfangreicheres Kampfsystem
- Fischen
- Verzauberung
- zusätzliche Berufe
- vergrabene Artefakte und besondere Funde
- weitere Gebiete
- zusätzliche Dorfbewohner und Gebäude
- Anzeige befreundeter NPCs auf der Karte
- umfangreiche Geschichte, Quests und Ereignisse

## 13. Technische Strukturregeln

Das Projekt muss so aufgebaut werden, dass spätere Änderungen keine unnötigen Abhängigkeiten oder großflächigen Umbauten verursachen.

### Grundregeln

- Jeder Hauptbereich erhält ein eigenes System.
- Inhalte und Werte sollen möglichst datenbasiert statt fest im Code gespeichert werden.
- Berufe, Gegenstände, Werkzeuge, Pflanzen, Rezepte, Gebäude, Bewohner, Jahreszeiten und Areale müssen unabhängig erweiterbar sein.
- Grafiken und Platzhalter dürfen keine notwendige Spiellogik enthalten.
- Das Austauschen einer Textur darf keine Skriptänderung erfordern.
- Entfernte Inhalte dürfen keine ungenutzten Abhängigkeiten im Projekt hinterlassen.
- Gebäudeausbau und Bewohner-Einzug sollen über klar definierte Bedingungen miteinander verbunden werden.
- Arealwechsel sollen über ein allgemeines Übergangssystem funktionieren.
- Speicherdaten benötigen eine klare Versionsstruktur, damit spätere Updates ältere Spielstände möglichst weiterverwenden können.
- Zentrale Systeme kommunizieren über klar definierte Schnittstellen oder Signale und greifen nicht unnötig direkt ineinander.
- Systeme für spätere Inhalte dürfen vorbereitet, aber nicht vorzeitig vollständig gebaut werden.
- Jede im Godot-Inspektor sichtbare Einstellung erhält einen kurzen deutschen Hilfetext, der Zweck und Auswirkung verständlich erklärt.
- Aufbau und Aussehen jedes Spielmenüs werden vom Nutzer vorgegeben. Neue Menüs dürfen erst nach einer bestätigten Layoutvorgabe gestaltet werden.

### Vorgesehene getrennte Datenbereiche

- Berufe und Berufserfahrung
- Gegenstände und Inventar
- Werkzeuge und Werkzeugwerte
- Ressourcen und Sammelpunkte
- Pflanzen und Landwirtschaft
- Rezepte und Verarbeitung
- Gebäude, Baukosten und Bauzustände
- Bewohner und Einzugsbedingungen
- Zeit, Kalender und Jahreszeiten
- Areale, Übergänge und Kartenmarkierungen
- Spielerwerte und Energie
- Speicherstände
- spätere Quests und Geschichte
- späteres Kampfsystem
- spätere Tierhaltung

## 14. Assets Maße

Das Grundspiel verwendet ein **32×32-Pixel-Raster**. Nicht jedes Objekt muss selbst 32×32 Pixel groß sein. Positionen, Türen, Wege und begehbare Flächen müssen jedoch sauber zum Raster passen.

### Notwendige Asset-Größen

| Asset | Größe pro Bild oder Frame | Tatsächlich sichtbare Größe |
|---|---:|---:|
| Boden, Gras, Wege und Wasser | 32×32 px | vollständig |
| Übergänge und Kartenränder | 32×32 px | vollständig |
| Klippen und niedrige Wände | 32×32 px | vollständig |
| hohe Innenwände | 32×64 px | vollständig |
| Spieler | 48×48 px Frame | ungefähr 22×28 px |
| normale NPCs | 48×48 px Frame | ungefähr 22×28 px |
| Werkzeuganimationen | innerhalb des 48×48-Charakterframes | dürfen über den Körper hinausragen |
| kleine Pflanzen und Blumen | 32×32 px | etwa 8×8 bis 24×24 px |
| Nutzpflanzen | 32×32 px je Wachstumsstufe | maximal etwa 28×30 px |
| Beerenbusch | 32×32 px | etwa 28×30 px |
| normaler Busch | 32×32 px | maximal 32×32 px |
| Baum | 64×96 px | Stamm mittig über einem Feld |
| Baumstumpf | 32×32 px | ungefähr 24×20 px |
| kleiner Stein | 32×32 px | etwa 12×10 px |
| abbaubarer Felsen | 32×32 px | etwa 28×26 px |
| Erzvorkommen | 32×32 px | etwa 28×26 px |
| Holzstamm | 64×32 px | ungefähr 56×22 px |
| aufhebbare Gegenstände | 32×32 px | ungefähr 12×12 bis 24×24 px |
| Truhe | 32×32 px | ungefähr 28×24 px |
| Tür | 32×48 px | Durchgang 32 px breit |
| Zaun und Tor | 32×32 px je Teil | vollständig |
| kleines Möbelstück | 32×32 px | passend zum Objekt |
| breites Möbelstück | 64×32 px | zwei Felder breit |
| hohes Möbelstück | 32×64 px | ein Feld breit |
| normales Wohnhaus | 160×128 px | Grundfläche ungefähr 5×4 Felder |
| Hauszustände | immer 160×128 px | zerstört, im Bau und repariert gleich groß |
| Gegenstands- und Werkzeugicons | 32×32 px | ungefähr 24×24 bis 28×28 px |
| Berufsicons | 32×32 px | ungefähr 26×26 px |
| Kartenmarkierungen | 16×16 px | vollständig |
| NPC-Porträts | 64×64 px | Kopf und Oberkörper |
| kleine Effekte | 32×32 px pro Frame | Staub, Treffer und Blätter |

### Charakter und Animationen

Der sichtbare Charakter ist ungefähr **22×28 Pixel** groß. Der zugehörige Animationsframe ist **48×48 Pixel** groß.

- Der Charakter wird unten mittig im Frame ausgerichtet.
- Der zusätzliche freie Platz wird für Axt, Spitzhacke, Sichel und andere Werkzeugbewegungen verwendet.
- Werkzeuge dürfen bei einer Animation über den Körper hinausragen.
- Spieler und normale NPCs verwenden dieselbe Framegröße.
- Die größere Framefläche verändert nicht die sichtbare Größe des Charakters.

### Ausrichtung am Raster

- Die Füße des Charakters stehen mittig auf einem 32×32-Feld.
- Türen sind grundsätzlich 32 Pixel breit.
- Wege sind mindestens 32 Pixel breit.
- Häuser und größere Objekte werden in 32-Pixel-Schritten platziert.
- Baumkronen und Häuser dürfen mehrere Felder sichtbar überdecken.
- Kollisionen liegen nur an den tatsächlich blockierenden Bereichen und nicht über dem gesamten sichtbaren Bild.
- Für den Spieler ist zunächst eine Kollisionsfläche von ungefähr **14×12 Pixeln an den Füßen** vorgesehen. Dieser Wert kann nach einem Spieltest angepasst werden.

### Sprite-Sheets

Die Gesamtgröße eines Sprite-Sheets ist nicht fest vorgegeben. Die einzelnen Frames bleiben einheitlich:

- Charaktere: 48×48 px pro Frame
- Pflanzen: 32×32 px pro Wachstumsstufe
- Gegenstände und kleine Effekte: 32×32 px pro Frame
- Bäume: 64×96 px pro Frame

### Verwendete Standardgrößen

Für das Grundspiel werden zunächst nur diese Standardgrößen verwendet:

- 16×16 px
- 32×32 px
- 48×48 px
- 64×32 px
- 32×64 px
- 64×64 px
- 64×96 px
- 160×128 px

Weitere Größen werden erst ergänzt, wenn ein notwendiges Asset mit diesen Standards nicht sinnvoll umgesetzt werden kann.

## Aktueller Entwicklungsfokus

Zuerst wird ein kleines, stabiles Grundspiel aufgebaut. Der Fokus liegt auf den Kernsystemen und einer sauberen Struktur. Umfangreiche Inhalte, zusätzliche Berufe und spätere Erweiterungen werden erst eingefügt, wenn das Fundament zuverlässig funktioniert.
