# Anforderungskatalog – Realistisches Physik-System (FiveM Hardcore-RP)

> Wird während der Fragerunde fortlaufend gepflegt. Jede Antwort wird mit Fragenummer (F#) festgehalten.
> Ziel: Grundlage für Konzept (`docs/konzept.md`) und Roadmap (`docs/roadmap.md`).

## Projektziel (Ausgangslage)
- FiveM-Ressource(n) für einen **extremen Hardcore-RP-Server**.
- Physik von „so ziemlich allem“ so realistisch wie im echten Leben: Fahrzeuge, Flugzeuge, Boote, sonstige Fortbewegungsmittel – **und darüber hinaus** (nicht nur Fahrzeug-Handling).

## Antworten der Fragerunde

### Block 1 – Grundlagen
- **F1 Framework:** ESX (Legacy).
- **F2 Sprache:** Gemischt (Aufteilung wird in Folgefrage geklärt).
- **F3 Spielerzahl:** bis 64 Spieler (kleiner, exklusiver Hardcore-Server → mehr Performance-Budget pro Spieler möglich).

### Block 2 – Technischer Stack & Performance
- **F4 Sprachaufteilung:** Freie Wahl durch Entwickler → technisch beste Aufteilung je Modul (Vorschlag: Lua für Gameplay/Ticks, TypeScript für NUI, ggf. C#/JS für rechenintensive Module).
- **F5 Stack:** ESX Legacy + ox_lib + oxmysql + ox_inventory.
- **F6 Performance-Budget:** „Muss spielbar bleiben – solange das gewährleistet ist, so viel Realismus wie irgend möglich.“ → Realismus hat Priorität, Grenze ist Spielbarkeit (FPS/Netcode). Dynamisches Budget (LOD-Physik nach Distanz/Relevanz) einplanen.

### Block 3 – Handling-Ansatz & Fahrzeugdaten
- **F7 Handling-Ansatz:** Entwickler entscheidet → geplant: **Hybrid** (realistische handling.meta als Basis + Laufzeit-Simulation, die GTA-Werte dynamisch anpasst und gezielt Kräfte anwendet).
- **F8 Fahrzeugbestand:** Gemischt – Vanilla + Addon-Fahrzeuge.
- **F9 Realdaten:** Ja, **vollständiges Datenblatt pro Fahrzeug** (Gewicht, Leistung, Nm-Kurve, Getriebe, Reifen, cw-Wert …), Handling wird daraus berechnet.

### Block 4 – Vanilla-Daten, Datenpflege, Eingabegeräte
- **F10 Vanilla-Fahrzeuge:** Zuordnung zu **realem Vorbild**, Übernahme dessen technischer Daten.
- **F11 Datenpflege:** **Datenbank (MySQL) + Web-Panel** für die Datenblätter.
- **F12 Eingabegeräte:** Tastatur/Maus, Controller, Lenkrad + Pedale, HOTAS/Joystick – **alle**. Ausdrücklicher Wunsch: **echte Anbindung für Lenkrad und HOTAS** (nicht nur Tastatur-Emulation).

### Block 5 – Geräteanbindung, Force-Feedback, Fairness
- **F13 Anbindung Lenkrad/HOTAS:** Umsetzung freigestellt, Ziel: **volle Einbindung & vollständige Unterstützung** aller Controller. → Plan: NUI-Gamepad-API für Achsen/Tasten **plus optionale Companion-App** (Desktop) für Force-Feedback & Geräte, die die Gamepad-API nicht sauber abbildet.
- **F14 Force-Feedback:** **Voll physikbasiert** (Self-Aligning-Torque aus Reifenmodell, Fahrbahnbeschaffenheit, Kollisionen, Schläge).
- **F15 Fairness:** **Keine Hilfen** für Tastaturspieler – gleiche Physik für alle, Hardcore.

### Block 6 – Antriebsstrang & Kraftstoff
- **F16 Getriebe:** Alle Typen: **Manuell mit Kupplung** (Abwürgen möglich), **realistische Wandlerautomatik** (P/R/N/D, Kriechen, Kickdown), **DSG/Sequentiell** (Paddles, Launch Control wo real). **Jedes Fahrzeug hat genau das Getriebe seines Realvorbilds** – keine freie Wahl.
- **F17 Motor:** **Komplette Motorsimulation** – Kaltstart, Choke/Vorglühen, Leerlauf, Abwürgen, Begrenzer, Motortemperatur, Öldruck, Kühlmittel, Überhitzen, Motorschaden.
- **F18 Kraftstoff:** **Physikalisch berechnet** – Verbrauch aus Last/Drehzahl/Gewicht/Fahrweise; Kraftstoffarten (Benzin/Diesel/E10/Super+ …); **Falschbetankung mit Folgen**.

### Block 7 – Kupplung, E-Mobilität, Bordelektrik
- **F19 Kupplung (Tastatur/Controller):** **Beides konfigurierbar** – Kupplung als Taste oder Analogachse, Physik identisch für alle.
- **F20 E-/Hybridfahrzeuge:** **Vollständig** – Akku (kWh, SoC, Temperatur), Rekuperation, Ladekurven, AC/DC-Ladeinfrastruktur, Reichweite abhängig von Wetter/Fahrweise.
- **F21 Bordelektrik:** **Komplett** – 12V/24V-Batterie, Lichtmaschine, Anlasser, Verbraucher (Licht, Radio, Klima) entladen die Batterie, Starthilfe nötig.

### Block 8 – Reifen & Untergrund
- **F22 Reifenmodell:** **Pacejka Magic Formula** (inkl. kombiniertem Schlupf).
- **F23 Reifeneigenschaften:** **Alle** – Temperatur (Zonen, kalt/überhitzt), Luftdruck (Grip/Verschleiß/Verbrauch, schleichender Platten, Prüfung an Tankstelle), Verschleiß & Profiltiefe (Aquaplaning, Reifenalter), Reifentypen (Sommer/Winter/Ganzjahr/Offroad/Slicks/Spikes).
- **F24 Untergrund:** **Material + Zustand** – Asphalt, Beton, Kopfstein, Schotter, Sand, Gras, Schlamm, Eis × nass, Öl, Laub, Schnee; Grip & Rollwiderstand je Kombination.

### Block 9 – Fahrbahndynamik, Fahrwerk, Beladung
- **F25 Fahrbahnzustände:** **Voll dynamisch** – Nässe baut sich auf/ab, Pfützen in Senken, Unfall-Ölspuren, Spurrinnen; Streudienst/Straßenreinigung als RP-Job möglich.
- **F26 Fahrwerk:** **Voll** – Federrate, Dämpfer (Zug/Druck), Stabilisatoren, Sturz/Spur, Bodenfreiheit, Aufsetzen; tuningfähig & beschädigbar.
- **F27 Beladung:** **Mit Schwerpunkt** – jeder Insasse und jedes Inventar-Item mit Gewicht + Position → Masse, Schwerpunkt, Achslast, Bremsweg, Verbrauch.

### Block 10 – Bremsen, Assistenzsysteme, Aerodynamik
- **F28 Bremsen:** **Alles** – Temperatur & Fading (Glühen sichtbar), Verschleiß (Beläge/Scheiben, Quietschen), Hydraulik/Defekte (Flüssigkeit, Leck, Bremskreisausfall, mechanische Handbremse), dynamische Bremskraftverteilung/Blockieren ohne ABS.
- **F29 Assistenzsysteme:** **Nur wie Realvorbild** – abschaltbar wo real möglich, können ausfallen.
- **F30 Aerodynamik:** **Voll** – cw·A, Abtrieb vorne/hinten, Windschatten, Seitenwind, offene Fenster/Dach, Spoiler-Tuning.

### Block 11 – Differenziale, Schaden, Insassenverletzungen
- **F31 Differenziale:** **Voll** – offen/LSD/Torsen/Visco/starr, Mitteldifferenzial, zuschaltbarer Allrad, Untersetzung, manuelle Diff-Sperren.
- **F32 Fahrzeugschaden:** **Komponentenbasiert** – Aufprallenergie wird auf Bauteile verteilt (Motor, Kühler, Achsen, Lenkung, Tank, Elektrik, Airbags), jeder Defekt wirkt physikalisch.
- **F33 Insassenverletzungen:** **Ja, mit Medical-System** – g-Kräfte → konkrete Verletzungen (Schleudertrauma, Frakturen, Bewusstlosigkeit), Übergabe an Medic-Script.

### Block 12 – Medical-Anbindung, Gurt/Airbag, Deformation
- **F34 Medical-System:** **Noch offen** → Schnittstelle **generisch** halten (Events/Exports), Adapter für gängige Scripts später.
- **F35 Gurt & Airbag:** **Voll realistisch** – Gurt manuell (Taste + Animation), Gurtwarner wie Realvorbild, Airbag-Auslösung nach Crash-Puls, ausgelöster Airbag muss getauscht werden, Herausschleudern ohne Gurt.
- **F36 Sichtbare Deformation:** **Stärker + persistent** – verstärkte Deformation, in DB gespeichert, bleibt nach Ausparken/Restart erhalten, synchronisiert.

