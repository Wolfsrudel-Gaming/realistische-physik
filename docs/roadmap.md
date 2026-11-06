# Roadmap – `wr_physics`

> Grundlage: [`anforderungen.md`](anforderungen.md) und [`konzept.md`](konzept.md).
> **Keine Termine** *(F110)*. Qualität geht vor Tempo. Jede Phase endet mit einem nutzbaren, getesteten Zwischenstand.
> **Reihenfolge** *(F108/F147/F145)*: Kern → PKW → Rest Straße → Verkehr → Person & Umwelt → Ballistik → Luftfahrt → Seefahrt → Bahn → … → Head-Tracking/VR ganz am Ende.

**Aufwand (grob):** S = wenige Sessions · M = einige Wochen · L = mehrere Wochen bis Monate · XL = mehrere Monate

---

## Überblick

| Phase | Inhalt | Aufwand | Ergebnis |
|---|---|---|---|
| **0** | Fundament & Machbarkeits-Spikes | M | Repo, CI, Testserver-Pipeline, technische Entscheidungen belegt |
| **1** | Kern (`wr_physics_core`) + Welt-Basis | L | Bibliothek, Bridges, Persistenz, LOD, Wetter-/Material-Basis |
| **2** | Fahrzeugdaten & Web-Panel | L | Datenblatt-Schema, Import, Web-Panel, Live-Editor |
| **3** | PKW-Simulation (MVP) | XL | Motor, Getriebe, Reifen, Fahrwerk, Bremsen, Aero, Elektrik, EV, Eingabe, Instrumente |
| **4** | Lenkrad-FFB & Companion-App v1 | M | Force-Feedback und volle Geräteunterstützung |
| **5** | Schaden, Insassen, Wartung, Bedienung | XL | Komponentenschaden, Gurt/Airbag, Verletzungen, Verschleiß, OBD, Tuning, EDR |
| **6** | Kraftstoff & Energie | M | eigenes Fuel- und Lade-System |
| **7** | Rest Straße | XL | Motorrad, Fahrrad & Co., LKW, Anhänger, Offroad, Spezialfahrzeuge |
| **8** | Verkehr & Infrastruktur | XL | Straßennetz, synchrone Ampeln, realistischer NPC-Verkehr, Blitzer, Stromnetz |
| **9** | Person & Umwelt | XL | Bewegung, Tragen, Fall, Körpertemperatur, Schwimmen/Tauchen, Naturereignisse, Brand, Wild, Strukturen |
| **10** | Ballistik | L | Projektilphysik, Durchschlag, Schutzklassen |
| **11** | Luftfahrt | XL+ | Flugmodell, Helikopter, Study-Level-Systeme, Avionik, ATC, Langstrecke |
| **12** | Seefahrt | XL | Rumpfphysik, Seegang, Segeln, Sinken/Bergen, U-Boote |
| **13** | Bahn | L | Strecken, Zugdynamik, Stellwerk, Fahrplan |
| **14** | Ausbau & Feinschliff | laufend | Feinschliff, weitere Fahrzeuge, Doku EN, Release 1.0 |
| **15** | Head-Tracking / VR | L | Stufenplan (ganz hinten) |
| **–** | Reittiere | M | sobald ein Addon-Pferd vorhanden ist *(F144)* |

---

## Phase 0 – Fundament & Machbarkeits-Spikes (M)

**Ziel:** Bevor auf die wackligen Stellen (Konzept Abschnitt 3) aufgebaut wird, sind sie mit kleinen Prototypen belegt.

**Infrastruktur**
- [x] Repo-Struktur (`resources/[wr_physics]/`, `web/`, `companion/`, `tools/`, `tests/`, `docs/`), Lizenz GPL-3.0, README DE/EN
- [ ] Code-Konventionen (Lua-Style, Namensschema, Einheiten SI), `CONTRIBUTING.md`
- [x] CI: Lua-Lint, eigener Test-Runner (busted-Ersatz, keine Abhängigkeiten), Release-Paket
- [x] Testserver-Update-Skript (Git-Pull + Neustart) *(F115)* und Anleitung
- [x] Fehlerreporter (Log-Dateien, optional Auto-Issue) *(F116)*
- [ ] Empfehlung und Doku für den Game-Build *(F113)*

**Spikes** (jeweils ein Mini-Prototyp und ein kurzer Bericht in `docs/spikes/`; `[~]` = Prototyp gebaut, Ingame-Test offen)
- [~] S1 – Drehmoment, Drehzahl, Gang, Kupplung und Radleistung pro Frame steuern (FiveM-Natives, Kosten pro Frame)
- [~] S2 – Traktionsparameter pro Frame steuern plus Zusatzkräfte: Wie nah kommt man an ein vorgegebenes Reifenkraft-Ziel?
- [~] S3 – Handling bei einem Owner-Wechsel und State-Bag-Rate (Netzwerk-Tests mit 2+ Clients)
- [ ] S4 – NUI-Gamepad-API mit Lenkrad und HOTAS (Achsen, Latenz) und Localhost-WebSocket aus der NUI
- [ ] S5 – Ampel-Props überschreiben und NPC-Verhalten an Kreuzungen beeinflussen
- [ ] S6 – Eigene Flug- und Bootskräfte über ApplyForce: Stabilität und Jitter im Netzwerk; GTA-Aero/-Auftrieb neutralisieren
- [ ] S7 – Wasser-API: Wellenhöhe abfragen und setzen, Wasserstand (Gezeiten), Grundabfrage
- [~] S8 – Untergrundmaterial pro Rad, Materiallisten der Vanilla-Map
- [~] S9 – **Welt-Maßstabsfaktor messen:** Referenzstrecken GTA ↔ Realität, Faktor `k` festlegen *(F127)*
- [ ] S10 – Deformation speichern und wiederherstellen (Gitter-Verfahren)
- [ ] S11 – Erweiterter Luft- und Seeraum über die Kartengrenze hinaus *(F128)*
- [ ] S12 – Zugverbände kuppeln und eigene Strecken laden *(F82)*

**Abnahme:** Alle Spike-Berichte liegen vor. Das Konzept ist mit den Ergebnissen aktualisiert. Wo ein Ansatz nicht trägt, ist die Alternative dokumentiert.

---

## Phase 1 – Kern + Welt-Basis (L)

- [ ] **Physik-Bibliothek:** Vektoren, Quaternionen, Integratoren (semi-implizit, RK4), Filter, Kennfelder, Einheiten, mit Unit-Tests
- [ ] **Config-System:** pro Modul, Defaults, Validierung, Überschreiben pro Server
- [ ] **Bridges:** Framework (ESX/QB/Qbox/Standalone), Inventar (ox), Voice (pma/Salty/YaCA), Medical (generisch), Garage und Schlüssel (generisch), Status, Anti-Cheat
- [ ] **Event-Bus, Exports, State-Bag-Schema** (quantisiert, gedrosselt)
- [ ] **Persistenz-Layer** (oxmysql, Migrationen), Fahrzeugidentität per eigener FIN
- [ ] **LOD-Scheduler und Profiler** mit Auto-Degradation *(F6)*
- [ ] **Validierungs-Framework** (serverseitige Plausibilität) *(F97)*
- [ ] **Locales** (DE/EN)
- [ ] **Welt-Basis:** Zeit (konfigurierbarer Faktor, Echtzeit-Uhren für Prozesse), regionales Klimamodell v1 (Temperatur, Wind, Niederschlag, Feuchte), Untergrund-Material-Lookup und Zonen-Override-Editor *(F131)*, Nässe-Basis
- [ ] **Debug-Overlay v1** (Zahlenwerte)

**Abnahme:** Der Kern läuft auf ESX und Standalone. Die Bridges sind getestet. Das Wetter ist regional und für alle synchron. Material-Overrides werden gespeichert und wirken.

---

## Phase 2 – Fahrzeugdaten & Web-Panel (L)

- [ ] **Datenblatt-Schema** (JSON-Schema, versioniert) für Landfahrzeuge, mit Erweiterungspunkten für Luft und See
- [ ] **Import-Pipeline:** handling.meta und Modellmaße → Entwurf; Vanilla → reales Vorbild *(F10/F102)*
- [ ] **Klassen-Fallback** mit Warnung *(F132)*
- [ ] **Web-Panel v1:** Discord-Login, Datenblätter bearbeiten, Freigabe-Workflow, Versionsvergleich, Live-Push an den Server
- [ ] **Ingame-Live-Tuning-Editor** → Entwurf ins Panel *(F99)*
- [ ] **Erste Datensätze:** 10 Referenzfahrzeuge (quer durch die Klassen: Kleinwagen, Kompakt, Limousine, SUV, Sportwagen, Supersportler, Pickup, Oldtimer, EV, Transporter)

**Abnahme:** Die 10 Referenz-Datenblätter sind freigegeben. Änderungen im Panel kommen ohne Neustart im Spiel an.

---

## Phase 3 – PKW-Simulation, MVP (XL)

**3a Antriebsstrang** *(F16–F19, F31)*
- [ ] Motor: Drehmomentkurve, Trägheit, Leerlauf, Abwürgen, Begrenzer, Start (Choke/Vorglühen), Thermik, Öl
- [ ] Kupplung (Taste oder Achse), manuelles Getriebe, Wandlerautomatik, DSG, Launch Control
- [ ] Differenziale, Allrad, Untersetzung, Sperren
- [ ] Physikalischer Verbrauch (BSFC) mit Welt-Faktor

**3b Reifen & Fahrwerk** *(F22–F30)*
- [ ] Pacejka mit kombiniertem Schlupf; Temperatur, Druck, Verschleiß, Reifentypen
- [ ] Untergrund × Zustand, dynamische Nässe, Pfützen, Aquaplaning
- [ ] Fahrwerk (Federn, Dämpfer, Stabis, Geometrie, Aufsetzen)
- [ ] Bremsen (Hydraulik, Temperatur, Fading, Verschleiß, Lastverlagerung, ABS)
- [ ] Aero (cw·A, Abtrieb, Windschatten, Seitenwind)
- [ ] Masse und Schwerpunkt aus Insassen und Beladung *(F27)*
- [ ] Assistenzsysteme wie beim Vorbild *(F29)*

**3c Elektrik & EV** *(F20/F21)*
- [ ] Bordnetz (Batterie, Lichtmaschine, Verbraucher, Starthilfe)
- [ ] EV/Hybrid (Akku, Rekuperation, Thermik); Laden folgt in Phase 6

**3d Eingabe** *(F12, F15, F19, F122)*
- [ ] Tastatur mit Lenk-Rampe, Controller, Lenkrad/Pedale/H-Schaltung über die NUI-Gamepad-API, Mapping-UI

**3e Instrumente** *(F42/F43)*
- [ ] NUI-Vorlagen PKW: Oldtimer, Klassiker, modern analog, digital, Sport; Einheiten nach Markt *(F126)*

**3f Gefühl & Messung** *(F117)*
- [ ] Offline-Simulator und automatische Messfahrten im Spiel
- [ ] Kamera-g-Effekte *(F51)*
- [ ] Simulationsgesteuerter Motorsound v1 *(F41)*
- [ ] Feinabstimmung mit den Gefühls-Abnahmen des Testers

**Abnahme (Meilenstein „Ein Auto fühlt sich echt an“):** Bei den 10 Referenzfahrzeugen liegen 0–100, Bremsweg und Vmax innerhalb von ±5 %. Der Tester gibt das Fahrgefühl frei. Das Frame-Budget ist eingehalten.

---

## Phase 4 – Lenkrad-FFB & Companion-App v1 (M)

- [ ] Companion-App (C#/.NET, Windows): Geräteerkennung, DirectInput-FFB, Localhost-WebSocket mit Pairing
- [ ] FFB-Signale aus dem Reifenmodell (Self-Aligning-Torque), Fahrbahn, Stöße; lokale Effekt-Synthese mit ~1 kHz *(F14)*
- [ ] Geräteprofile (Logitech, Thrustmaster, Fanatec, Moza) und Kalibrierung
- [ ] Signierter GitHub-Release mit Installationsanleitung *(F123)*

**Abnahme:** Mindestens zwei Lenkradmarken liefern physikalisch plausibles FFB. Ohne App funktioniert weiterhin alles, nur ohne FFB.

---

## Phase 5 – Schaden, Insassen, Wartung, Bedienung (XL)

- [ ] Crash-Erkennung, Komponentenschaden, persistente und verstärkte Deformation *(F32/F36)*
- [ ] Gurt, Airbag, Herausschleudern, Verletzungen → Medical-Bridge *(F33–F35)*
- [ ] Fahrzeugbrand mit Ursachen *(F90, Fahrzeugteil)*
- [ ] Zufallsdefekte (MTBF) *(F64)*, Standzeit-Nachberechnung *(F49)*
- [ ] Verschleiß und Serviceintervalle, OBD-Gerät, Teile als Items, Einbau-Flow *(F37/F38)*
- [ ] Tuning-Bauteile *(F39)*, TÜV-Messdaten-API *(F40)*
- [ ] EDR und Fahrtenschreiber, persistente Spuren, Gutachter-Tool *(F100)*
- [ ] Bedienung: Türen, Fenster, Sitzplätze, Blinker, Licht, Wischer, Klima, realistische Einstiegsdauer *(F135)*
- [ ] Wegrollen und Anschieben *(F52)*, Licht und Sicht (Scheinwerfertypen, Beschlag, Eis, Wischer) *(F53)*, Schlüssel und Wegfahrsperre *(F54)*
- [ ] Fahrerzustand (Alkohol, Drogen, Müdigkeit, Verletzungen) mit Basismodul und Bridge *(F105/F106)*
- [ ] Defektgeräusche *(F41)*, Lärm → Voice *(F68)*
- [ ] Betriebsanleitung als Item *(F118)*

**Abnahme:** Ein Unfall erzeugt nachvollziehbare Bauteil- und Personenschäden, die nach einem Restart erhalten bleiben. Ein Mechaniker kann per OBD diagnostizieren und reparieren.

---

## Phase 6 – Kraftstoff & Energie (M)

- [ ] Tankstellen, Kraftstoffarten, Falschbetankung *(F18/F104)*
- [ ] Ladesäulen AC/DC mit Ladekurven *(F20)*
- [ ] Vorrat und Tanklaster-Logistik (konfigurierbar) *(F134)*
- [ ] Bridge-Modus für Server mit eigenem Fuel-Script
- [ ] Schnittstelle zum Stromnetz vorbereiten (Netz folgt in Phase 8)

---

## Phase 7 – Rest Straße (XL)

- [ ] Motorrad: Gegenlenken, Schräglage, Wheelie/Stoppie, High- und Lowsider, Schutzkleidung *(F44)*
- [ ] Fahrrad und E-Bike mit Ausdauer, E-Scooter, Skateboard *(F45/F86)*
- [ ] LKW: Druckluftbremse, Retarder, AMT/Range/Splitter, Achslasten und Waage *(F46)*
- [ ] Anhänger und Sattel, Abschleppen mit Seil und Stange, Autotransporter, Bootstrailer *(F46/F48)*
- [ ] Offroad: Einsinken, Festfahren, Wattiefe, Seilwinde, Bergung *(F47)*
- [ ] Bau- und Landwirtschaftsfahrzeuge: Hydraulik, Lasten, Kippen, Anbaugeräte *(F87)*
- [ ] Instrumente: Motorrad, LKW, Bus, Nutzfahrzeug
- [ ] Datenblätter für alle gängigen Vanilla-Straßenfahrzeuge

---

## Phase 8 – Verkehr & Infrastruktur (XL)

*Vom Auftraggeber ausdrücklich höher priorisiert als VR (F145).*

- [ ] Straßennetz-Graph aus den Pfadknoten, Editor für Tempolimits, Vorfahrt, Spuren und Zeichen *(F150)*
- [ ] Synchrone Ampeln mit Phasenplänen, Fußgängerampeln, Grüner Welle, Bedarfsschaltung, Nachtbetrieb und Ausfällen *(F148)*
- [ ] NPC-Verkehr: regelkonform, Dichte nach Tageszeit, Reaktionen, Persönlichkeiten *(F149)*
- [ ] Lernender Verkehr: anonymisierte Statistik und Kopierfahrer *(F151)*
- [ ] NPC-Fußgänger realistisch *(F152)*
- [ ] Messgeräte (Radar, Laser, Rotlicht, Waage, Promille, Profil) mit Messfehlern, Messprotokolle *(F153/F155)*
- [ ] Stromnetz mit Bezirken und Ausfällen *(F154)*
- [ ] Persistente Infrastruktur-Schäden (Masten, Leitplanken, Ampeln) *(F138)*
- [ ] Verkehrszeichenerkennung und Tempomat-Anbindung bei passenden Fahrzeugen

**Abnahme:** Alle Spieler sehen dieselben Ampeln, NPCs halten bei Rot, und die Verkehrsdichte folgt der Tageszeit. Ein Blitzer erzeugt ein korrektes Protokoll inklusive Toleranzabzug.

---

## Phase 9 – Person & Umwelt (XL)

- [ ] Bewegung: Ausdauer und Gewicht, Trägheit, Rutschen, Klettern *(F83)*
- [ ] Tragen und Ziehen, schwere Lasten zu zweit, Ladungssicherung, Wurfphysik *(F89)*
- [ ] Physikalischer Fallschaden *(F84)*, Fallschirm *(F69)*
- [ ] Körpertemperatur mit Kleidungs-Isolationswerten *(F95)*
- [ ] Schwimmen und Tauchen (Dekompression), Seenot-Ausrüstung *(F79/F80)*
- [ ] Rollstuhl und Gehhilfen, Ski, Snowboard, Rodel *(F86)*
- [ ] Klimamodell v2: Jahreszeiten, regionaler Schnee, Nebel *(F136)*
- [ ] Naturereignisse: Sturm, Hochwasser, Waldbrand, Erdbeben *(F137)*
- [ ] Brandausbreitung und Löschmittel *(F90)*
- [ ] Wildwechsel *(F158)*
- [ ] Strukturen: Türen und Tore aufbrechen, Zäune und Mauern, Glas, Brückenlast *(F159)*

---

## Phase 10 – Ballistik (L)

- [ ] Waffen-Datenblätter, Flugbahn (Widerstand, Schwerkraft, Wind) *(F88)*
- [ ] Durchschlag nach Material und Dicke, Querschläger
- [ ] Schutzklassen und Trefferzonen → Medical, Durchschuss *(F133)*
- [ ] Fahrzeugtreffer → Bauteilschaden
- [ ] Server-Validierung, GTA-Hitscan-Schaden ersetzen *(F91)*

---

## Phase 11 – Luftfahrt (XL+)

**11a Flugmodell & Atmosphäre**
- [ ] Blade-Element-Flugmodell, Stall und Trudeln, Bodeneffekt, Klappen, Trimmung *(F55)*
- [ ] ISA, QNH, Wind in Schichten, Turbulenz, Thermik, Wirbelschleppen, Vereisung, METAR *(F62)*
- [ ] Weight & Balance, Tanks, Betankung per Tankwagen *(F60)*

**11b Triebwerke & Systeme (Study-Level)**
- [ ] Kolbenmotor, Turboprop, Jet, APU
- [ ] Datengetriebene Systemdefinitionen pro Typ, NUI-Panels und Checklisten *(F57/F58)*
- [ ] Eigene Cockpits pro Typ: GA analog, GA Glascockpit, Business-Jet, Airliner, Militärjet, Transporter *(F43)*

**11c Helikopter** *(F61)*
- [ ] Rotormodell, gefährliche Zustände, Autorotation, Außenlast und Winde; Heli-Cockpits

**11d Avionik & ATC** *(F59/F65)*
- [ ] Navdaten-Editor für San Andreas (Flugplätze, Funkfeuer, Wegpunkte, Verfahren)
- [ ] VOR, NDB, ILS, GPS, FMC (LNAV/VNAV), Autopilot, Transponder, ATC-Radar

**11e Langstrecke & Ausfälle** *(F63/F128)*
- [ ] Erweiterter Luftraum, Off-Map-Ziele, Reiseflug-Zeitraffer
- [ ] Strukturgrenzen, Triebwerksausfall, Vogelschlag, Fahrwerksschäden, Wartung
- [ ] HOTAS-Profile (Companion-App) *(F12)*

**Abnahme:** Eine Cessna-ähnliche GA-Maschine und der Jet sind nach Prozedur startbar. Stall- und Landeverhalten werden vom Tester abgenommen. Ein ILS-Anflug am LSIA ist möglich.

---

## Phase 12 – Seefahrt (XL)

- [ ] Rumpf-Voxel-Auftrieb, Gleitfahrt, Stabilität und Kentern *(F73)*
- [ ] Wellenmodell (synchron), Strömung, Gezeiten, Grund und Echolot *(F74)*
- [ ] Propellerphysik, Außenborder-Trimm, Bugstrahlruder, Anker *(F78)*
- [ ] Segelphysik *(F74/F77)*
- [ ] Wassereinbruch, Lenzpumpen, Sinken, persistente Wracks und Bergung *(F75/F76)*
- [ ] Große Schiffe und Schlepper, U-Boote *(F77)*
- [ ] Erweiterter Seeraum *(F128)*, Cockpits für Boot, Brücke und U-Boot

---

## Phase 13 – Bahn (L)

- [ ] Eigene Strecken *(F82)*, Zugdynamik, Bremsen, Entgleisung *(F81)*
- [ ] Signale, Weichen, Stellwerk-UI, Zugsicherung, Fahrplan *(F85)*
- [ ] Führerstand-Instrumente

---

## Phase 14 – Ausbau & Feinschliff (laufend)

- [ ] Datenblätter für den restlichen Bestand, Addon-Unterstützung
- [ ] Englische Fassung der Doku vollständig *(F72)*, externes Wiki *(F118)*
- [ ] Performance-Review aller Module, Profiling mit 64 Spielern *(F3)*
- [ ] Release 1.0 (Semver, Changelog, GitHub-Releases)

## Phase 15 – Head-Tracking / VR (L, ganz hinten) *(F140/F143/F145)*

- [ ] Stufe 1: 6DoF-Head-Tracking über die Companion-App (OpenTrack/OpenXR, Quest 2)
- [ ] Stufe 2: Machbarkeitstest für Pseudo-3D per Shader (nur wenn FiveM es zulässt)
- [ ] Stufe 3: echtes VR nur, falls Cfx.re das offiziell ermöglicht

## Reittiere (sobald ein Modell vorhanden ist) *(F144)*

- [ ] Reitphysik, Ausdauer, Fütterung; Schnittstellen sind ab Phase 1 vorbereitet

---

## Arbeitsweise

- **Branches:** Entwicklung auf Feature-Branches. Der Testserver zieht einen festen Test-Branch *(F115)*.
- **Pro Arbeitspaket:** Umsetzung → Unit-Tests → CI grün → Push → Testserver zieht → Rückmeldung (automatische Fehlerberichte und manuelles Gefühls-Feedback) *(F116)* → Feinabstimmung.
- **Doku:** Jedes Modul bekommt eine Doku in `docs/` (DE, EN folgt). Das Konzept wird nach jeder Phase aktualisiert.

## Nächste Schritte

1. **Auftraggeber:** Testserver vorbereiten. Bei einem öffentlichen Repo reicht ein Git-Pull. Bei einem privaten Repo wird ein read-only Deploy-Key gebraucht. Das Update-Skript liefere ich in Phase 0.
2. **Claude:** Phase 0 starten: Repo-Gerüst, CI, Testserver-Skript, dann die Spikes S1–S12 nacheinander mit Bericht.
3. **Gemeinsam:** Die 10 Referenzfahrzeuge für Phase 2/3 festlegen.
