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

### Block 13 – Wartung, Mechanik, Tuning
- **F37 Wartung/Verschleiß:** **Voll** – Kilometerstand, Serviceintervalle, Verschleißteile (Öl, Filter, Zündkerzen, Zahnriemen, Kupplung …), vernachlässigte Wartung → Folgeschäden.
- **F38 Mechaniker-Gameplay:** **Voll** – OBD-Diagnosegerät mit Fehlercodes, Teile als ox_inventory-Items, Einbau mit Werkzeug/Hebebühne, falscher Einbau möglich.
- **F39 Tuning:** **Bauteilbasiert** – echte Teile (Turbo, Ansaugung, Auspuff, Chiptuning, Fahrwerk) ändern Datenblattwerte physikalisch, mit Nebenwirkungen (Haltbarkeit, Verbrauch, TÜV/Zulassung).

### Block 14 – TÜV-Daten, Sound, Instrumente
- **F40 TÜV/Zulassung:** **Nur Daten bereitstellen** – Physik liefert Messwerte (Bremsen, Profil, Licht, Abgas, Lautstärke) über API; TÜV-Job/Script separat.
- **F41 Sound:** **Simulationsgesteuert** – Sounds aus RPM, Last, Schlupf, Bauteilzustand; kaputte Teile klingen kaputt.
- **F42 Cockpit/HUD:** **Realistisches NUI-Instrumentenbrett** im Stil des jeweiligen Fahrzeugs (Tacho, DZM, Temperatur, Tank, Warnleuchten).

### Block 15 – Instrumenten-Designs, Motorräder, Fahrräder
- **F43 Instrumenten-Designs:** **Realistische Systeme pro Fahrzeugkategorie, zusätzlich nach Baujahr/Epoche** (Oldtimer ≠ brandneuer Supersportwagen). **Schiffe & Fluggeräte bekommen eigene, typgerechte HUDs/Cockpits** – wegen geringer Anzahl, aber großer Unterschiedlichkeit ruhig individuell (z. B. Boeing-Glascockpit ≠ Helikopter-Cockpit).
- **F44 Motorräder:** **Voll** – Gegenlenken, Schräglage durch Grip begrenzt, Wheelie/Stoppie physikalisch, High-/Lowsider, Fahrer-Ragdoll, Helm/Schutzkleidung reduziert Verletzungen.
- **F45 Fahrräder:** **Voll** – Tretleistung aus Ausdauer/Kondition des Charakters, Gangschaltung, Steigungen, E-Bikes mit Akku, Stürze.

### Block 16 – LKW, Offroad, Anhänger
- **F46 LKW/Nutzfahrzeuge:** **Alles** – Druckluftbremse (Druckaufbau, Federspeicher, Leck, Motorbremse/Retarder), lange Getriebe (12–18 Gänge, Range/Splitter, AMT wie Realvorbild), physikalische Anhänger/Sattel (Knickwinkel, Jackknifing, Ankuppeln mit Luft/Strom), Achslast & Waage (Überladung messbar, Reifenplatzer).
- **F47 Offroad:** **Voll** – Einsinken je Masse & Reifendruck, Festfahren, Achsverschränkung, Wattiefe/Wasserschlag, Seilwinde, Bergung.
- **F48 Abschleppen/Anhänger PKW:** **Voll physikalisch** – Seil/Stange mit echten Kräften, Anhänger (Wohnwagen, Bootstrailer, Autotransporter) mit Stützlast, Pendeln, zulässiger Anhängelast.

### Block 17 – Standzeit, Kamera, g-Kräfte
- **F49 Standzeit-Zustand:** **Voll** – Zustände laufen auch offline/in der Garage weiter (zeitbasiert beim Ausparken nachberechnet: Abkühlen, Batterie-Selbstentladung, Luftverlust, Standschäden).
- **F50 Kamera:** **Freie Wahl** der Perspektive, keine Einschränkung.
- **F51 g-Kräfte/Erschütterungen:** **Voll** – Kopfbewegung durch Längs-/Querbeschleunigung, Vibration je Fahrbahn, Schläge bei Schlaglöchern.

### Block 18 – Rollen/Anschieben, Licht & Sicht, Schlüssel
- **F52 Wegrollen/Anschieben:** **Voll** – ohne Handbremse/P/Gang rollt das Fahrzeug; Anschieben möglich (startet Motor bei Handschaltern).
- **F53 Licht & Sicht:** **Voll** – Scheinwerfertyp je Baujahr (Halogen/Xenon/LED), Fernlicht blendet, defekte Lampen, beschlagene/vereiste/verschmutzte Scheiben, Wischer & Defroster nötig.
- **F54 Schlüssel/Diebstahl:** **Eingebunden** – Wegfahrsperre/Lenkradschloss je Baujahr, Kurzschließen nur bei alten Fahrzeugen, leere Batterie = keine Zentralverriegelung.

### Block 19 – Luftfahrt: Flugmodell, Typen, Systemtiefe
- **F55 Flugmodell:** **Blade-Element / flächenbasiert** (X-Plane-ähnlich) – Auftrieb/Widerstand je Fläche, Anstellwinkel, Stall, Trudeln, Bodeneffekt, Klappen, Trimmung.
- **F56 Flugzeugtypen:** **Alle** – Kleinflugzeuge (GA), Verkehrsflugzeuge (Jet, Glascockpit, Autopilot), Militär/Jets/Transporter, Sonder (Segelflug, Wasserflugzeug, UL, Drohnen).
- **F57 Bedienung/Systeme:** **Study-Level** – vollständige Startprozeduren (Batterie, Fuel Pumps, Magnetos, APU, Bleed Air …), klickbare Cockpits, ohne korrekte Prozedur kein Start.

### Block 20 – Cockpit-Bedienung, Avionik, Weight & Balance
- **F58 Klickbare Cockpits:** **NUI-Panels** – detaillierte 2D-Panels (Overhead, Pedestal, MCP, FMC) als Overlay, per Maus/HOTAS bedienbar.
- **F59 Avionik/Navigation:** **Voll** – VOR/NDB/ILS/GPS, eigene Navdaten für San Andreas (Wegpunkte, Airways, Anflugverfahren), FMC/Autopilot mit LNAV/VNAV, Transponder.
- **F60 Weight & Balance/Treibstoff:** **Voll** – Leergewicht, Passagiere, Fracht, Treibstoff je Tank → Schwerpunkt, Vr, Startstrecke; AvGas/Jet-A, Betankung per Tankwagen, Tank-Management.

### Block 21 – Helikopter, Atmosphäre, Ausfälle in der Luft
- **F61 Helikopter:** **Alles** – Collective/Cyclic/Pedale getrennt, Drehmomentausgleich, Translational Lift, Bodeneffekt; Vortex Ring State, Retreating Blade Stall, Dynamic Rollover, Mast Bumping; Autorotation inkl. Rotordrehzahl-Management; Außenlast (Pendeln), Rettungswinde.
- **F62 Atmosphäre:** **Alles** – Wind in Höhenschichten, Böen, Scherwinde; Thermik, Lee-Turbulenz, Wirbelschleppen; ISA-Atmosphäre/Dichtehöhe/QNH; Vergaser-/Flächenvereisung, Enteisung, IMC/Wolken, METAR.
- **F63 Ausfälle:** **Voll realistisch** – Strukturgrenzen (Vne, g-Limits) → Strukturversagen; Triebwerksausfall, Vogelschlag, Systemausfälle; Wartung wie bei Fahrzeugen; harte Landung beschädigt Fahrwerk.

### Block 22 – Zufallsdefekte, ATC/Lizenzen, Voice
- **F64 Zufallsdefekte:** **Immer möglich** – MTBF-basierte Ausfälle pro Bauteil, Wahrscheinlichkeit steigt mit Alter/Verschleiß/versäumter Wartung, aber auch gut gewartete Teile können (selten) ausfallen. Gilt für **alle** Fahrzeugarten (Auto, Boot, Luftfahrzeug).
- **F65 ATC & Lizenzen:** **Eingebunden** – Transponder/Squawk auf ATC-Radarschirm (Spieler-ATC), Funkfrequenzen, Lizenzprüfung je Musterberechtigung.
- **F66 Voice:** Aktuell **pma-voice**, aber **SaltyChat und YaCA müssen ebenfalls unterstützt werden** → Voice-Adapter-Layer, pro Server per Config umschaltbar.

### Block 23 – Vertrieb, Lärm/Voice, Fallschirm
- **F67 Vertrieb:** **Open Source** → saubere Modul-Architektur, Konfigurierbarkeit, Doku für Fremdserver.
- **F68 Lärm beeinflusst Voice:** **Ja** – Umgebungslärm (Fahrzeug, Fahrtwind, Triebwerk) dämpft Reichweite/Verständlichkeit; Headsets/Intercom nötig.
- **F69 Fallschirm:** **Voll** – Freifall-Aerodynamik (Haltung, Terminalgeschwindigkeit), Öffnungsstoß, Schirmsteuerung mit Wind, Fehlöffnungen/Reserve, Landeverletzungen.

### Block 24 – Lizenz, Framework-Bridges, Sprache
- **F70 Lizenz:** **GPL-3.0**.
- **F71 Framework-Bridges:** **ESX Legacy, QBCore, Qbox, Standalone**.
- **F72 Sprache:** **Code & Kommentare Englisch, Doku zweisprachig (DE + EN), Ingame-Texte mehrsprachig** (Locales, Deutsch Standard).

### Block 25 – Seefahrt: Rumpfphysik, Seegang, Sinken
- **F73 Bootsphysik:** **Rumpf-Voxel/Punkte** – Auftrieb pro Segment (Archimedes), Verdränger vs. Gleiter, Trimm, Krängung, metazentrische Stabilität, physikalisches Kentern.
- **F74 Seegang & Gewässer:** **Alles** – Wellen aus Wind (Beaufort), Slamming; Meeres-/Flussströmung, Ebbe/Flut mit Wasserstand; Tiefgang, Grundberührung, Propellerschaden, Echolot; Windversatz + **echte Segelphysik** (Am-Wind, Halse, Kentern).
- **F75 Wassereinbruch:** **Voll** – Lecks nach Kollision/Grundberührung, Kompartments, Lenzpumpen, Sinken, Boot bleibt als Wrack.

### Block 26 – Wracks, Schiffstypen, Bootsantrieb
- **F76 Wracks:** **Persistent + bergbar** – Wrack bleibt am Grund (DB), Bergung durch Taucher/Bergungsschiff (Hebesäcke, Kran) als RP-Job.
- **F77 Wasserfahrzeuge:** **Alle** – Motorboote/Jetski, Segelboote (Kiel, Ballast), große Schiffe (Frachter, Fähren, Yachten; träge, Bugstrahlruder, Anker, Schlepper), U-Boote (Ballasttanks, Tauchtiefe, Druck, Sauerstoff).
- **F78 Bootsantrieb:** **Voll** – Motorsimulation wie Autos + Propellerphysik (Steigung, Kavitation, Radeffekt), Salzwasserkühlung, Trimm des Außenborders, Ansaugen von Schmutz.

### Block 27 – Schwimmen/Tauchen, Seenot, Züge
- **F79 Schwimmen & Tauchen:** **Voll** – Schwimmausdauer, Kleidung/Ausrüstung macht schwer, Strömung/Wellen, Ertrinken, Unterkühlung nach Wassertemperatur, Tauchphysik (Druck, Dekompression, Flaschenluft).
- **F80 Seenot/Rettungsmittel:** **Physikalisch** – Schwimmweste hält Kopf über Wasser, Rettungsinsel als treibendes Objekt, Notsignal/EPIRB-Position für Küstenwache.
- **F81 Züge:** **Fahrbar & realistisch** – Spieler-Lokführer, Zugmasse, Bremswege (Druckluft, Bremshundertstel), Signale, Weichen, Kuppeln von Waggons, Entgleisung bei Übergeschwindigkeit.

