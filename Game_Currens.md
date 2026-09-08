# Havest Dream – aktueller Spielstand

## Zweck dieser Datei

Diese Datei enthält den aktuell gültigen Konzeptstand von **Havest Dream**.

- Noch nicht endgültig entschiedene Punkte werden als **offen** gekennzeichnet.
- Spätere Inhalte werden getrennt vom Grundspiel dokumentiert.
- Veraltete oder gestrichene Ideen sollen entfernt oder klar als verworfen markiert werden.
- Bei widersprüchlichen Angaben darf nicht stillschweigend eine Variante gewählt werden. Der Widerspruch muss zuerst geklärt werden.
- Systeme sollen modular, erweiterbar und möglichst unabhängig voneinander aufgebaut werden, damit Inhalte später ergänzt, verändert oder entfernt werden können, ohne das gesamte Spiel umzubauen.

## 1. Grundidee

**Havest Dream** ist ein Farming- und Aufbauspiel.

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

Das Dorf besteht am Anfang aus **vier zerstörten und unbewohnten Häusern**.

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
- **0,5 weniger Energieverbrauch**

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

**Offener Balancepunkt:** Eine Senkung des Energieverbrauchs um 0,5 pro Level ergibt bis Level 50 insgesamt 25 Punkte weniger Energieverbrauch. Ein Mindestverbrauch oder eine andere Begrenzung muss noch bestimmt werden, damit Aktionen nicht unbeabsichtigt kostenlos oder negativ werden.

## 7. Zeit und Jahreszeiten

Es gibt vier Jahreszeiten:

1. Frühling
2. Sommer
3. Herbst
4. Winter

Jede Jahreszeit dauert **28 Spieltage**. Ein vollständiges Spieljahr umfasst damit **112 Spieltage**.

Ein Spieltag besitzt **24 Ingame-Stunden**.

**Noch offen:**

- Dauer eines vollständigen Spieltages in Echtzeit
- Uhrzeit des Tagesbeginns
- Uhrzeit des Tagesendes beziehungsweise erzwungene Nachtruhe
- Verhalten der Zeit in Menüs
- mögliche Zeitgeschwindigkeit in Innenräumen
- jahreszeitabhängige Pflanzen, Ressourcen und Ereignisse

## 8. Werkzeuge

### Werkzeuge im Grundspiel

- Spitzhacke
- Harke
- Axt
- Sichel

### Später geplante Werkzeuge

- Angel
- weitere Werkzeuge passend zu neuen Berufen und Inhalten

Werkzeuge sollen als eigenständige Daten und nicht fest im Spieler-Code angelegt werden. Dadurch können neue Werkzeuge, Werte, Verbesserungen und Aktionen später ergänzt oder geändert werden.

## 9. Welt und Areale

### Areale im Grundspiel

- Hof
- Stadt beziehungsweise Dorf
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

## 10. Ziel der ersten Version

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

## 11. Später geplante Inhalte

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

## 12. Technische Strukturregeln

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

## Aktueller Entwicklungsfokus

Zuerst wird ein kleines, stabiles Grundspiel aufgebaut. Der Fokus liegt auf den Kernsystemen und einer sauberen Struktur. Umfangreiche Inhalte, zusätzliche Berufe und spätere Erweiterungen werden erst eingefügt, wenn das Fundament zuverlässig funktioniert.
