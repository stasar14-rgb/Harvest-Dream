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
- Die interne Basisauflösung beträgt **640 × 360 Pixel**. Das PC-Testfenster startet mit **1280 × 720 Pixeln**.
- Pixelgrafiken werden ohne Glättung dargestellt und möglichst ganzzahlig skaliert.
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
- Schmieden
- Landwirtschaft
- Holzfällen

### Später geplante Berufe und Tätigkeiten

- Kämpfen
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

Beispiele:

- Bergbau erhält Erfahrung durch das Abbauen geeigneter Vorkommen.
- Holzfällen erhält Erfahrung durch das Fällen oder Bearbeiten von Holzquellen.
- Landwirtschaft erhält Erfahrung durch landwirtschaftliche Tätigkeiten.
- Schmieden erhält Erfahrung durch das Herstellen oder Bearbeiten geeigneter Gegenstände.

### Geplanter Levelbereich

Berufe sollen zunächst von **Level 1 bis Level 50** aufsteigen können.

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
- Harke
- Axt
- Sichel

### Später geplante Werkzeuge

- Angel
- weitere Werkzeuge passend zu neuen Berufen und Inhalten

Werkzeuge sollen als eigenständige Daten und nicht fest im Spieler-Code angelegt werden. Dadurch können neue Werkzeuge, Werte, Verbesserungen und Aktionen später ergänzt oder geändert werden.

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
