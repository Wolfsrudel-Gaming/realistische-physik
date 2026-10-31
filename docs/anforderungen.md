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

### Block 28 – Schienennetz, Bewegung zu Fuß, Fallschaden
- **F82 Schienennetz:** **Eigene Strecken** – zusätzliche Gleise per Custom-Track-Dateien (Güterbahnhof, Rangiergleise …). *(Offen: Signalsystem/Fahrplan zusätzlich? → Nachfrage)*
- **F83 Bewegung zu Fuß:** **Alles** – Ausdauer & Gewicht (Inventargewicht, Fitness, Verletzung, Steigung), Trägheit/Momentum, Rutschen & Stürzen (Eis, Nässe, Hang), realistisches Klettern/Springen (kein Bunnyhop).
- **F84 Fallschaden/Ragdoll:** **Physikalisch** – Schaden aus Aufprallgeschwindigkeit & Untergrund (Wasser, Gras, Beton), Verletzungen je Körperteil, Abrollen möglich.

### Block 29 – Bahn-Signaltechnik, sonstige Fortbewegung, Spezialfahrzeuge
- **F85 Signale/Stellwerk:** **Ja, mit Stellwerk** – Signale (Hp0/Hp1/Vr), stellbare Weichen, Stellwerk-UI für Fahrdienstleiter-Spieler, Zugsicherung (PZB-artig), Fahrplan.
- **F86 Sonstige Fortbewegung:** **Alle** – Pferde/Reittiere (Ausdauer, Fütterung), Ski/Snowboard/Rodel (Gleitphysik), E-Scooter/Skateboard (Akku/Muskelkraft), Rollstuhl/Gehhilfen (Medical-Kopplung).
- **F87 Bau-/Spezialfahrzeuge:** **Funktional** – Hydraulik (Arm/Schaufel/Gabel), Lasten mit echtem Gewicht heben, Kippgefahr, Traktor mit Anbaugeräten/Zapfwelle.

### Block 30 – Ballistik, Objekte, Feuer
- **F88 Waffen-Ballistik:** **Voll** – Projektilflug (Drop, Wind, Flugzeit), Durchschlag je Material (Holz/Blech/Beton/Glas), Querschläger, kaliberspezifisch, Rückstoß, Fahrzeugtreffer → Bauteilschaden.
- **F89 Objekte & Tragen:** **Alles** – reales Gewicht & Volumen je ox_inventory-Item, Tragen/Ziehen großer Objekte & Personen (schwere Lasten zu zweit), Ladungssicherung (ungesicherte Ladung rutscht/fällt, Spanngurte), Werfen/Physik-Props mit realer Masse.
- **F90 Feuer & Explosionen:** **Voll** – Fahrzeugbrände aus Ursachen (Kurzschluss, Leck, Überhitzung, Akku-Thermal-Runaway), Brandausbreitung, Löschmittel (Wasser/Schaum/CO₂), keine Film-Explosionen.

### Block 31 – Trefferberechnung, Wetter/Klima, Regionalität
- **F91 Trefferberechnung:** **Client-Simulation + Server-Validierung** (Distanz, Sichtlinie, Flugzeit, Plausibilität).
- **F92 Wetter/Klima:** **Eigenes physikalisches Modul** – Temperatur, Luftdruck, Feuchte, Wind (Richtung/Stärke/Höhe), Niederschlag, Wassertemperatur, Jahreszeiten; steuert GTA-Wetter und liefert Daten an alle Module.
- **F93 Regionalität:** **Regional** – Wetterzonen mit Höhen-/Küsteneinfluss; GTA-Optik je Spielerposition, Physik nutzt lokale Werte.

### Block 32 – Zeit, Körpertemperatur, Synchronisation
- **F94 Zeit:** **Konfigurierbar** (Zeitfaktor einstellbar); Physik/Kräfte rechnen immer mit Echtzeit-Sekunden.
- **F95 Körper-Temperaturhaushalt:** **Voll** – Körpertemperatur aus Wetter, Kleidung (Isolationswert), Nässe, Wind-Chill → Unterkühlung/Hitzschlag; Fahrzeugheizung/Klima wirkt.
- **F96 Sync/Authority:** **Owner-Client simuliert + Server-State** – Ergebnisse über State Bags; Server speichert & validiert.

### Block 33 – Anti-Cheat, Admin-/Debug-Tools
- **F97 Manipulationsschutz:** **Integrierte Validierung** – Server prüft Plausibilität (Beschleunigung/Vmax vs. Datenblatt, Verbrauch, Teleport), Meldung an AC/Discord-Log.
- **F98 Anti-Cheat:** **Noch offen** → generische Schnittstelle (Whitelisting-Exports gegen False-Positives bei ApplyForce/Handling-Änderungen).
- **F99 Admin-/Debug-Tools:** **Alle** – Telemetrie-Overlay (Live-Graphen), Live-Tuning-Editor (→ Web-Panel), Fahrzeug-/Bauteil-Inspector, Daten-Logging (CSV/Replay, Unfallrekonstruktion).

### Block 34 – Unfalldaten im RP, Web-Panel, Datenimport
- **F100 Unfalldaten im RP:** **Voll** – EDR/Fahrtenschreiber (LKW) per Item auslesbar, Bremsspuren/Trümmer als persistente Spuren, Gutachter-Tool zur Unfallrekonstruktion.
- **F101 Web-Panel-Technik:** Entwickler entscheidet → geplant: Panel als HTTP-Endpoint der Ressource (SetHttpHandler) für Basisfunktionen + eigenständige Web-App (TypeScript) mit Login (Discord/CFX).
- **F102 Initiale Datenbefüllung:** **Auto-Import + Prüfung** – Ableitung aus handling.meta/Modellen + Realdaten-Recherche als Vorschlag, Admin prüft & gibt frei.

### Block 35 – Fremdsysteme, Fuel-System, Fahrerzustand
- **F103 Fremdsysteme:** Garage/Fahrzeugbesitz, Tankstellen/Laden, Polizei/Blitzer, Versicherung/Wirtschaft – **mit gängigen Standard-Scripts kompatibel, aber offen/adapterbasiert, damit jeder es für seine Zwecke anpassen kann**.
- **F104 Fuel-/Lade-System:** **Eigenes System** (ersetzt ox_fuel/LegacyFuel) – Kraftstoffarten, Falschbetankung, Tankwagen-Logistik, E-Ladekurven.
- **F105 Fahrerzustand:** **Voll** – Alkohol/Drogen/Müdigkeit → verzögerte Reaktion (Input-Lag), unruhige Lenkung, Tunnelblick; Verletzungen (z. B. gebrochener Arm) verhindern Schalten/Lenken.

### Block 36 – Zustandsquellen, Projektstruktur, MVP
- **F106 Quelle Alkohol/Drogen/Müdigkeit:** **Beides** – eigenes Basismodul (Promille-Abbau, Wirkkurven, Müdigkeit aus Wachzeit) + Bridge für externe Status-Scripts.
- **F107 Projektstruktur:** **Modulare Ressourcen** – Core-Ressource (Physik-Kern, API, DB) + einzeln aktivierbare Module (Fahrzeug, Luft, Wasser, Bahn, Person, Wetter, Ballistik …).
- **F108 MVP/Start:** **Kern + PKW zuerst** – Physik-Kern, Datenbank, Wetter-Basis, dann PKW-Fahrphysik (Reifen, Motor, Getriebe).

### Block 37 – Team, Zeitrahmen, Tests
- **F109 Team:** **Nur Auftraggeber + Claude** – Auftraggeber testet ingame, Claude entwickelt.
- **F110 Zeitrahmen:** **Keine Eile** – Qualität vor Geschwindigkeit.
- **F111 Tests:** **Alle** – Unit-Tests für Physikformeln (offline, z. B. busted), Dev-/Testserver, automatische Referenzmessungen (0–100, Elchtest, Bremsweg) gegen Herstellerdaten, CI/CD via GitHub Actions (Lint, Tests, Release-Pakete).

### Block 38 – Testserver, Game-Build, Override-Verhalten
- **F112 Testweg:** **Testserver vorhanden**, Zugang für Claude möglich → Weg wird in Nachfrage geklärt (Empfehlung: Deploy über GitHub statt direktem Serverzugang).
- **F113 Game-Build:** Unbekannt → Empfehlung: aktuellen stabilen `sv_enforceGameBuild` erzwingen (neueste DLC-Fahrzeuge, Natives, Materialien); wird in Doku festgehalten.
- **F114 Override:** **Konfigurierbar** – jedes Modul einzeln ein-/abschaltbar; wer andere Scripts (Handling/Fuel/Seatbelt …) nutzen will, deaktiviert das jeweilige Modul. Kollisionserkennung mit Warnung.

### Block 39 – Deploy, Feedback-Rückweg, Realismus-Priorität
- **F115 Deploy:** **Server zieht selbst** – Testserver holt den Branch per Git-Pull/txAdmin-Script (kein Serverzugang für Claude nötig).
- **F116 Feedback-Rückweg:** **Beides** – Fehler/Telemetrie automatisch (Issue/Log-Datei), Fahrgefühl-Feedback manuell.
- **F117 Realismus-Priorität:** **Beides – aber „fühlt sich echt an“ ist wichtiger**, weil das beim Spieler hängen bleibt. → Messwerte als Referenz, Feinabstimmung zugunsten des echten Gefühls (FFB, Kamera, Sound, Reaktionsverhalten).

### Block 40 – Einstieg für Spieler, Lizenzen, Geometrie-Abweichungen
- **F118 Spieler-Einstieg:** **Beides** – RP-Ausbildung (Fahr-/Flugschule, Mechaniker) + Betriebsanleitungen/Checklisten als Items (Handschuhfach) + externes Wiki.
- **F119 Lizenzen/Führerscheinklassen:** **Nur Daten liefern** – benötigte Klasse je Fahrzeug (B, BE, C, CE, A, PPL, CPL, Musterberechtigung, Bootsschein), Durchsetzung über Polizei-RP. *(Klärung nötig: Widerspruch zu F65 „Lizenzprüfung je Musterberechtigung“ → Nachfrage F121)*
- **F120 Geometrie vs. Realdaten:** **Physik nach Realdaten** – Masse/Leistung real, Geometrie (Radstand, Spur, Schwerpunkt) aus dem sichtbaren Modell → Physik konsistent zum Fahrzeug.

---
## Nachfragen (Klärungsrunde ab F121)

### Block 41 – Lizenz-Klärung, Tastatur-Lenkung, Companion-App
- **F121 Lizenzen (Klärung F65↔F119):** **Überall nur Daten** – auch in der Luftfahrt liefert das System nur die benötigte Berechtigung; Prüfung/Strafe ausschließlich über RP. (F65 wird entsprechend gelesen: ATC/Transponder ja, keine technische Sperre.)
- **F122 Tastatur-Lenkung:** **Lenk-Rampe ok, aber keine Assists** – Einschlag baut sich zeitlich auf, keine Gegenlenk-/Stabilitätshilfen.
- **F123 Companion-App:** **Optional, Open Source** – signierter GitHub-Release; ohne App funktioniert alles außer FFB/Spezialgeräten.

### Block 42 – Map-Maßstab, Verbrauch, Einheiten
- **F124 Map-Maßstab:** **Umrechnen und anpassen, sodass es sich real anfühlt.**
- **F125 Verbrauch:** **Map umrechnen** – Bezugsgrößen (Fahrzeug, Spielfigur) nutzen, berechnen, wie groß die Insel real wäre, und streckenabhängige Größen so anpassen, dass es wieder real passt. → Konzept „Welt-Maßstabsfaktor“ (siehe Nachfrage F127).
- **F126 Einheiten:** **Wie Realvorbild/Markt** – US-Fahrzeuge mph/°F/gal, EU-Fahrzeuge km/h/°C/l; Luftfahrt kt/ft/inHg bzw. hPa wie real; Boote kn.

### Block 43 – Welt-Maßstab, Langstrecken, Zeitbezug
- **F127 Maßstabs-Prinzip:** **Bestätigt** – lokale Physik (Beschleunigung, Bremsen, Kurven, Kräfte) bleibt **1:1 real**; streckenabhängige Größen (Verbrauch, Verschleiß, km-Zähler, Akku-Reichweite) werden mit einem **berechneten Welt-Faktor** skaliert (aus Referenzstrecken GTA ↔ reales Vorbild, per Config überschreibbar).
- **F128 Langstrecken Luft/See:** **Beides kombiniert** – erweiterter Luft-/Seeraum über die Map hinaus + Off-Map-Ziele (z. B. „San Fierro“, „Las Venturas“) mit realer Reisezeit, Zeitraffer-Option für sehr lange Strecken, Ankunft per Anflug/Einfahrt.
- **F129 Zeitbezug:** **Echtzeit** – Ladezeiten, Abkühlung, Promille-Abbau, Reparaturdauer in **realen Minuten** (unabhängig vom Ingame-Zeitfaktor F94).

### Block 44 – NPC-Verkehr, Material-Overrides, Datenblatt-Fallback
- **F130 NPC-Verkehr:** **Vereinfacht** – realistische Basis-Handling-Werte, Unfallschaden & Bremswege, keine volle Simulation.
- **F131 Kollisionsmaterialien:** **Zonen-Override-Editor** – Admin markiert Polygone ingame und überschreibt das Material (z. B. „Kopfstein“), gespeichert in DB.
- **F132 Fehlendes Datenblatt:** **Klassen-Fallback + Warnung** – automatisch geschätztes Datenblatt aus Klasse/handling.meta, Admin-Warnung im Panel.

### Block 45 – Körpertreffer, Tankstellen-Vorrat, Fahrzeugbedienung
- **F133 Körpertreffer:** **Voll** – Schutzwesten nach Schutzklassen (VPAM/NIJ) je Kaliber, Trefferzonen → Verletzungen ans Medical, Energieübertrag, Durchschuss trifft Person dahinter.
- **F134 Tankstellen-Vorrat:** **Konfigurierbar** – Server entscheidet: begrenzter Vorrat je Kraftstoffart mit Tanklaster-Logistik oder unbegrenzt.
- **F135 Fahrzeugbedienung:** **Alles** – Türen/Fenster/Verdeck/Kofferraum/Haube manuell; Sitzplatz-Logik (Durchrutschen, Kindersitze, Gewichtsverteilung); Bedienelemente (Blinker, Warnblinker, Lichtschalter, Hupe, Wischerstufen, Heizung/Klima); realistische Dauer für Einsteigen/Anschnallen/Starten.

### Block 46 – Schnee, Naturereignisse, Infrastruktur
- **F136 Schnee:** **Realistisch regional** – Schnee in den Bergen (Chiliad) regelmäßig, in der Stadt sehr selten (kalifornisches Klima); Physik regional, Optik bestmöglich.
- **F137 Naturereignisse:** **Alle** – Sturm/Orkan (Böen auf alle Fahrzeugarten, umstürzende Bäume/Schilder), Starkregen/Hochwasser (überflutete Senken, Absaufen/Abtreiben), Waldbrand (Ausbreitung nach Wind/Trockenheit/Vegetation), Erdbeben, dichter Nebel.
- **F138 Infrastruktur:** **Mit Persistenz** – realistische Festigkeit (Mast bricht/hält je nach Energie), umgefahrene Objekte bleiben bis zur Reparatur (Straßenmeisterei-Job), Ampelausfall.

### Block 47 – Projektname, Head-Tracking/VR, Modelle
- **F139 Projektname:** **Wolfsrudel-Name** (genauer Prefix → Nachfrage F142).
- **F140 Head-Tracking/VR:** **Ja, wenn irgendwie möglich – auch VR über Oculus Quest 2** (Gerät vorhanden). *(Technische Grenzen → Nachfrage F143)*
- **F141 Modelle:** **Vorerst nur Vanilla-Modelle** (z. B. Jet/Luxor/Shamal/Titan, Jetmax/Tug/Kosatka/Submersible, Dozer/Handler, Freight). System muss trotzdem modell-agnostisch für spätere Addons sein.

### Block 48 – Prefix, VR-Wunsch, Reittiere
- **F142 Prefix:** **`wr_physics`** → `wr_physics_core`, `wr_physics_vehicle`, `wr_physics_aviation` …
- **F143 VR:** Leinwand allein reicht nicht – Wunsch nach **möglichst echtem VR** (Idee: als Shader oder Grafik-Mod à la QuantV). *(Technische Einordnung & Stufenplan → Nachfrage F145)*
- **F144 Reittiere:** **Spätere Ausbaustufe** – Schnittstellen vorbereiten, Umsetzung sobald ein Addon-Pferd vorhanden ist.

### Block 49 – VR-Priorität, Downloadgröße, Reihenfolge
- **F145 VR/Head-Tracking:** **Ganz nach hinten** in der Roadmap (Stufenplan: Head-Tracking 6DoF via Quest → ggf. Pseudo-3D-Shader, echtes VR nur falls Cfx es offiziell erlaubt). **Wichtiger:** realistische **Ampelschaltungen** und realistischer **Verkehr** (→ Nachfragen F148 ff.).
- **F146 Downloadgröße:** **Egal** – Realismus vor Größe (trotzdem sinnvoll komprimieren/streamen).
- **F147 Reihenfolge:** Nach Kern + PKW zuerst **Rest Straße** (Motorrad, LKW/Anhänger, Offroad, Fahrrad, Fuel-System), danach Luft/See.

### Block 50 – Ampeln, NPC-Verkehr, Straßennetz
- **F148 Ampeln:** **Voll realistisch** – serverseitig synchron für alle, Phasenpläne je Kreuzung (Gelb/Rot-Gelb nach Region), Fußgängerampeln, Grüne Welle, Induktionsschleifen/Bedarfsschaltung, Nachtabschaltung (Gelb blinkend), Ausfall bei Stromausfall/Unfall (vgl. F138).
- **F149 NPC-Verkehrsverhalten:** **Alles** – regelkonform (Ampeln, Vorfahrt, Tempolimits, Blinken, Abstand), Dichte nach Tageszeit (Rushhour, Nacht, Wochenende, Staus), Reaktionen (Rettungsgasse, Umfahren, Gaffer, Bremsen), Fahrer-Persönlichkeiten (vorsichtig/normal/aggressiv/abgelenkt). **Zusätzlich:** System soll sich am **Spielerverhalten orientieren/es kopieren**, sodass auch mal ein NPC durch die City heizt. *(Methode → Nachfrage F151)*
- **F150 Straßennetz:** **Eigenes Straßennetz** – Graph mit Tempolimits, Vorfahrt, Spuren, Verkehrszeichen; Editor im Admin-Tool; Basis aus GTA-Pfadknoten. Genutzt von NPCs, Blitzern, Tempomat/Verkehrszeichenerkennung, Polizei.

### Block 51 – Lernender Verkehr, Fußgänger, Verkehrsverstöße
- **F151 Lernen vom Spielerverhalten:** **Beides** – anonymisierte Statistik je Zone/Uhrzeit (Tempo vs. Limit, Rotläufe, Abstände) passt den NPC-Persönlichkeits-Mix an **+** gelegentliche „Kopierfahrer“, die konkrete Spielerfahrmuster nachfahren.
- **F152 NPC-Fußgänger:** **Voll** – Zebrastreifen/Fußgängerampeln (synchron), gelegentliches Bei-Rot-Gehen, realistische Reaktion & Verletzungen bei Anstoß (Crash-Physik wie bei Spielern).
- **F153 Verkehrsverstöße:** **Erfassen + Daten liefern** – stationäre/mobile Blitzer & Rotlichtblitzer erzeugen Messprotokolle (Foto, Kennzeichen, Wert, Toleranzabzug); Bußgeld über Polizei-/Wirtschafts-Script.

