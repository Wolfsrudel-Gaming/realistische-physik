# Konzept – `wr_physics`

**Realistisches Physik-System für FiveM-Hardcore-RP**

> Grundlage: [`anforderungen.md`](anforderungen.md) (160 Fragen, F1–F160). Verweise wie *(F17)* zeigen auf die jeweilige Antwort.
> Umsetzungsplan: [`roadmap.md`](roadmap.md).
> Status: Entwurf v1. Wird nach den Machbarkeits-Spikes (Roadmap Phase 0) aktualisiert.

---

## 1. Leitprinzipien

1. **Realismus bis zur Spielbarkeitsgrenze.** So viel Realismus wie möglich, solange das Spiel spielbar bleibt *(F6)*. Ein dynamisches Performance-Budget regelt die Simulationstiefe automatisch herunter, bevor die FPS einbrechen.
2. **Das Gefühl zählt am meisten.** Reale Messwerte (0–100, Bremsweg, Vmax, Verbrauch) dienen als Referenz. Wenn Messwert und Fahrgefühl auseinanderlaufen, gewinnt das Gefühl, weil das beim Spieler hängen bleibt *(F117)*. Force-Feedback, Kamera, Sound und Reaktionsverhalten sind deshalb vollwertige Teile der Simulation.
3. **Gleiche Physik für alle.** Es gibt keine Fahrhilfen, die nur bestimmte Eingabegeräte bekommen *(F15)*. Erlaubt ist nur eine Lenk-Rampe für die Tastatur *(F122)*. Assistenzsysteme gibt es nur dort, wo das reale Vorbild sie hat *(F29)*.
4. **Daten statt Hardcode.** Jedes Fahrzeug, Flugzeug und Boot wird über ein Datenblatt mit realen Werten beschrieben *(F9)*, und das Verhalten wird daraus berechnet.
5. **Lokale Physik bleibt 1:1, Strecken werden skaliert.** Kräfte, Beschleunigung und Bremsen entsprechen exakt der Realität. Was von der zurückgelegten Strecke abhängt (Verbrauch, Verschleiß, km-Zähler, Reichweite), läuft über einen berechneten Welt-Maßstabsfaktor *(F124/F125/F127)*.
6. **Zeitabhängige Prozesse laufen in Echtzeit.** Laden, Abkühlen, Promille-Abbau und Reparaturen dauern reale Minuten *(F129)*. Die Ingame-Uhr hat einen konfigurierbaren Zeitfaktor *(F94)*.
7. **Modular, konfigurierbar, Open Source.** Das System besteht aus einem Kern und einzeln aktivierbaren Modulen *(F107/F114)*, steht unter GPL-3.0 *(F70)* und läuft über Bridges mit ESX, QBCore, Qbox und Standalone *(F71)*.
8. **Bei Fremdsystemen nur Daten, wo gewünscht.** Lizenzen *(F119/F121)*, TÜV *(F40)* und Bußgelder *(F153)* bekommen vom System nur Daten. Durchgesetzt wird im RP.

---

## 2. Rahmenbedingungen

| Thema | Festlegung |
|---|---|
| Framework | ESX Legacy + ox_lib + oxmysql + ox_inventory *(F1/F5)*, Bridges für QBCore/Qbox/Standalone *(F71)* |
| Spieler | bis 64 gleichzeitig *(F3)* |
| Sprachen | Lua 5.4 (Logik & Physik), TypeScript (NUI & Web-Panel), C#/.NET (Companion-App) *(F4)* |
| Code/Doku | Code und Kommentare auf Englisch, Doku auf Deutsch und Englisch, Ingame-Texte mehrsprachig *(F72)* |
| Lizenz | GPL-3.0 *(F70)* |
| Ressourcen-Prefix | `wr_physics_*` *(F142)* |
| Game-Build | Neuester stabiler Build per `sv_enforceGameBuild` *(F113)* |
| Modelle | Vorerst nur Vanilla-Modelle, das System bleibt aber modell-agnostisch *(F141)* |
| Downloadgröße | unkritisch, Realismus geht vor *(F146)* |
| Team | Auftraggeber (Test) + Claude (Entwicklung), keine Deadline *(F109/F110)* |

---

## 3. Machbarkeit: Was GTA/FiveM vorgibt und wie wir damit umgehen

GTA V hat eine eigene, geschlossene Physik-Engine (Kollisionen, Reifen, Auftrieb). Man kann sie nicht ersetzen, aber über Parameter, Kräfte und Natives steuern. Die folgende Tabelle beschreibt die wichtigsten Grenzen offen. Alles, was mit **Spike** markiert ist, wird in Phase 0 mit einem Prototyp geprüft, bevor darauf aufgebaut wird.

| Bereich | Vorgabe der Engine | Lösungsansatz | Risiko |
|---|---|---|---|
| Fahrzeug-Handling | Handling-Werte gelten pro Fahrzeug-Instanz und nur lokal auf dem Client | Der Owner-Client simuliert und setzt die Handling- und Leistungsparameter pro Frame. Bei einem Owner-Wechsel werden sie neu gesetzt (über State Bags). **Spike** | mittel |
| Reifenmodell | GTA rechnet den Reifen intern | Eigenes Pacejka-Modell berechnet die Soll-Kräfte. Eine Mapping-Schicht steuert die GTA-Traktionsparameter dynamisch, Zusatzkräfte korrigieren den Rest. Kalibrierung über Messfahrten. **Spike** | hoch |
| Motor/Getriebe | GTA-Getriebe ist stark vereinfacht | Antriebsstrang komplett eigen simuliert. GTA bekommt Drehzahl, Gang und Antriebsmoment vorgegeben (FiveM-Erweiterungs-Natives für RPM, Gang, Kupplung, Radleistung; genaue Verfügbarkeit wird im **Spike** geprüft) | mittel |
| Flug-/Bootsphysik | Eigene GTA-Aerodynamik/-Hydrodynamik | GTA-Kräfte über Handling stark reduzieren, eigene Kräfte per `ApplyForceToEntity` an Flächen/Rumpfpunkten. **Spike** (Stabilität, Netzwerk-Jitter) | hoch |
| Netzwerk | OneSync: Owner simuliert, andere interpolieren | Owner-Client ist Autorität für die Simulation, der Server speichert und validiert *(F96)* | gering |
| Deformation | Es gibt kein „Set Deformation“-Native | Deformation an Gitterpunkten abtasten, speichern und per Schadens-Natives nachbilden (bewährtes Verfahren) | mittel |
| NPC-Verkehr | NPC-KI folgt der GTA-Kreuzungslogik | Eigene KI-Schicht für NPCs im Umfeld jedes Clients: an roter Ampel anhalten, Tempo, Persönlichkeit. **Spike** | hoch |
| Ampeln | Ampelzustände sind pro Client unsynchron | Server sendet Phasenpläne mit Zeitstempel, jeder Client berechnet daraus deterministisch denselben Zustand und überschreibt die Ampel-Props | gering |
| Lenkrad/HOTAS/FFB | FiveM kennt keine Rohdaten von DirectInput-Geräten | NUI-Gamepad-API für Achsen/Tasten. Optionale Companion-App (localhost-WebSocket) für FFB und Spezialgeräte *(F13/F123)*. **Spike** | mittel |
| Regionales Licht | Künstliches Licht lässt sich nur global pro Client schalten | Stromausfall-Licht nur für Spieler im betroffenen Bezirk umschalten; Ampeln, Säulen und Laternen-Props gezielt steuern | mittel |
| Feuer, Decals, Entities | Engine-Limits bei Anzahl gleichzeitiger Feuer, Decals, Objekte | Serverseitiges Zellmodell. Clients erzeugen nur Instanzen in ihrer Nähe | mittel |
| VR | Echtes Stereo-VR braucht DLL-Injektion, und die blockiert FiveM | Ganz ans Ende gestellt, Stufenplan: Head-Tracking, dann ggf. Pseudo-3D-Shader *(F145)* | sehr hoch |

---

## 4. Architektur

### 4.1 Ressourcen-Übersicht

Alle Ressourcen liegen im Ordner `resources/[wr_physics]/`. Nur `wr_physics_core` ist Pflicht. Jedes Modul lässt sich einzeln deaktivieren, zum Beispiel um ein vorhandenes Fuel-Script zu behalten *(F114)*.

| Ressource | Inhalt |
|---|---|
| `wr_physics_core` | Mathe-/Physikbibliothek, Einheiten, Config, Bridges, State-Bag-Schema, Event-Bus/API, LOD-Scheduler, Persistenz-Layer, Validierung, Logging, Locales |
| `wr_physics_world` | Wetter/Klima (regional), Zeit, Fahrbahnzustand, Materialien und Overrides, Welt-Maßstab, Naturereignisse |
| `wr_physics_vehicle` | Simulation der Landfahrzeuge: Motor, Getriebe, Differenziale, Reifen, Fahrwerk, Bremsen, Aero, Assistenzsysteme, Bordelektrik, EV/Hybrid, Beladung, Anhänger |
| `wr_physics_damage` | Komponentenschaden, Crash-Erkennung, persistente Deformation, Fahrzeugbrand, Zufallsdefekte (MTBF), Unfalldatenspeicher (EDR) |
| `wr_physics_occupant` | Gurt, Airbag, Verletzungen aus g-Kräften, Kamera-Effekte, Fahrerzustand (Alkohol, Drogen, Müdigkeit), Sitzplätze, Bedienung |
| `wr_physics_maintenance` | Verschleiß, Serviceintervalle, OBD-Diagnose, Teile als Items, Tuning-Bauteile, TÜV-Messdaten |
| `wr_physics_fuel` | Tankstellen, Kraftstoffarten, Falschbetankung, Ladesäulen AC/DC, Vorrat und Tanklaster-Logistik |
| `wr_physics_input` | Eingabegeräte, Achsen-Mapping, Kupplungsmodus, Lenk-Rampe, NUI-Gamepad, Companion-Brücke, FFB-Signale |
| `wr_physics_hud` | NUI-Instrumente: Vorlagen pro Kategorie und Epoche, eigene Cockpits für Luft- und Seefahrzeuge |
| `wr_physics_sound` | Simulationsgesteuerte Sounds und Defektgeräusche |
| `wr_physics_traffic` | Straßennetz, Ampeln, NPC-Verkehr und -Fußgänger, lernendes Verhalten, Blitzer und Messgeräte |
| `wr_physics_grid` | Stromnetz (Umspannwerke, Bezirke, Ausfälle) |
| `wr_physics_ped` | Bewegung zu Fuß, Tragen und Ladungssicherung, Fallschaden, Körpertemperatur, Schwimmen/Tauchen, Fallschirm, Rollstuhl, Ski/Rodel |
| `wr_physics_ballistics` | Projektilflug, Durchschlag, Querschläger, Schutzklassen, Trefferzonen |
| `wr_physics_structures` | Türen/Tore, Zäune/Mauern, Glas, Brückenlast, Infrastruktur-Props (Masten, Leitplanken, Ampeln) |
| `wr_physics_fire` | Brandausbreitung, Löschmittel |
| `wr_physics_wildlife` | Wildwechsel, Tiermassen |
| `wr_physics_aviation` | Flugmodell (Blade-Element), Helikopter, Atmosphäre, Systeme, Avionik/Navdaten, ATC-Radar, erweiterter Luftraum |
| `wr_physics_marine` | Rumpf-Voxel-Auftrieb, Seegang, Strömung/Gezeiten, Propeller, Segel, Wassereinbruch, Wracks, U-Boote |
| `wr_physics_rail` | Eigene Strecken, Zugdynamik, Signale/Stellwerk, Zugsicherung, Fahrplan |
| `wr_physics_special` | Bau- und Landwirtschaftsfahrzeuge (Hydraulik, Lasten, Anbaugeräte) |
| `wr_physics_admin` | Telemetrie-Overlay, Live-Tuning-Editor, Inspector, Aufzeichnung/Replay, Editoren (Materialzonen, Straßen, Ampeln, Netz) |
| `wr_physics_devtools` | Fehlerreporter, automatische Messfahrten, Profiler (nur auf Dev-/Testserver) |

Außerhalb von `resources/`:

| Ordner | Inhalt |
|---|---|
| `web/` | Web-Panel (TypeScript): Datenblätter, Freigaben, Editoren, Telemetrie |
| `companion/` | Companion-App (C#/.NET, Windows): Geräte, Force-Feedback, später Head-Tracking |
| `tools/` | Datenblatt-Importer, Offline-Simulator, Testserver-Update-Skript |
| `tests/` | Unit-Tests (busted) für die reinen Lua-Physikmodule |
| `docs/` | Anforderungen, Konzept, Roadmap, Modul-Doku (DE/EN) |

### 4.2 Schichten

```
┌────────────────────────────────────────────────────────────────┐
│ UI-Schicht        NUI (Svelte/TS): Instrumente, Cockpits, Editoren│
├────────────────────────────────────────────────────────────────┤
│ Game-Adapter      Natives, State Bags, Events (je Modul)          │
├────────────────────────────────────────────────────────────────┤
│ Simulation        Antrieb, Reifen, Aero, Rumpf, Rotor ... (Lua)   │
├────────────────────────────────────────────────────────────────┤
│ Physik-Bibliothek Vektoren, Quaternionen, Integratoren, Filter,   │
│                   Einheiten, Tabellen/Kennfelder (reines Lua)     │
├────────────────────────────────────────────────────────────────┤
│ Bridges           Framework, Inventar, Voice, Medical, Garage,    │
│                   Schlüssel, Polizei, Wirtschaft, Anti-Cheat      │
└────────────────────────────────────────────────────────────────┘
```

**Wichtigste Regel:** Die Simulationsschicht ruft **keine Natives** auf. Sie bekommt Eingaben (Zustand, Inputs, Umwelt) und liefert Ausgaben (Kräfte, Sollwerte). Dadurch lässt sie sich offline mit Unit-Tests und einem Offline-Simulator prüfen *(F111)*, und nur der Game-Adapter muss im Spiel getestet werden.

### 4.3 Datenfluss und Autorität *(F96)*

```
 Fahrer-Client (Owner)                 Server                      andere Clients
 ─────────────────────                 ──────                      ──────────────
 Inputs ─► Simulation ─► Natives       Validierung (Plausibilität)
            │                          Persistenz (oxmysql)
            ├─► State Bags (5–10 Hz) ──► Zustand ───────────────► Optik/Sound
            └─► Ereignisse (Crash,     Weltzustand (Wetter, Ampeln,
                Defekt, Verbrauch) ──►  Netz, Spuren, Wracks) ───► alle Clients
```

- **Owner-Client:** simuliert das Fahrzeug, in dem der Spieler Fahrer oder Netzwerk-Owner ist.
- **Server:** hält den dauerhaften Zustand (Bauteile, Flüssigkeiten, Reifen, km-Stand, Deformation), prüft die Plausibilität *(F97)* und berechnet den Weltzustand (Wetter, Ampelphasen, Stromnetz, Brandzellen).
- **Andere Clients:** bekommen nur darstellungsrelevante Werte (Drehzahl für den Sound, Licht, Bremsglühen, Rauch, Schäden).
- **Owner-Wechsel:** Der neue Owner liest den Zustand aus den State Bags und setzt die lokalen Handling-Werte neu.

### 4.4 Simulations-Loop und LOD-Stufen

| Stufe | Wann | Simulation |
|---|---|---|
| **T0 Voll** | eigenes Fahrzeug als Fahrer oder Pilot | jedes Frame, Fixed-Timestep mit Substeps für steife Teilsysteme (Reifen, Rotor) |
| **T1 Reduziert** | Owner ohne Fahrer (rollendes Fahrzeug, Anhänger, treibendes Boot) | 10–20 Hz: Rollen, Bremsen, Abkühlen, Auftrieb |
| **T2 Darstellung** | Fahrzeuge anderer Spieler in der Nähe | keine Physik, nur replizierte Optik und Sound |
| **T3 Ruhend** | geparkt oder in der Garage | Server rechnet analytisch nach, sobald das Fahrzeug wieder benutzt wird: Abkühlen, Selbstentladung, Luftverlust, Standschäden *(F49)* |
| **NPC-Lite** | NPC-Fahrzeuge | realistische Basis-Handling-Profile, Crash-Regeln, Bremswege *(F130)* |

Ein **Profiler im Kern** misst die Zeit pro Modul. Wird das Frame-Budget überschritten, regelt der Scheduler in einer festen Reihenfolge herunter: Darstellungsdetails → Update-Raten von T1/T2 → Substeps. Die Kernphysik von T0 wird zuletzt reduziert *(F6)*.

### 4.5 Persistenz (oxmysql, Tabellen-Prefix `wr_`)

| Tabelle | Inhalt |
|---|---|
| `wr_vehicle_specs` | Datenblätter (JSON, versioniert, Status Entwurf/Geprüft/Freigegeben, Quelle) |
| `wr_vehicle_mapping` | Zuordnung Vanilla-Modell → reales Vorbild *(F10)* |
| `wr_vehicles` | Fahrzeugidentität (eigene **FIN/VIN**, unabhängig vom Kennzeichen) |
| `wr_vehicle_state` | Bauteilzustände, Flüssigkeiten, Reifen, km-Stand, Deformation, letzte Nutzung |
| `wr_edr_records` | Unfalldatenspeicher und Fahrtenschreiber *(F100)* |
| `wr_world_traces` | Bremsspuren, Trümmer, Ölspuren (mit Ablaufzeit) |
| `wr_world_objects` | Wracks, beschädigte Infrastruktur, Zäune *(F76/F138)* |
| `wr_material_zones` | Material-Overrides als Polygone *(F131)* |
| `wr_road_network` | Straßengraph, Tempolimits, Vorfahrt, Zeichen *(F150)* |
| `wr_traffic_lights` | Kreuzungen und Phasenpläne *(F148)* |
| `wr_traffic_stats` | anonymisierte Fahrstatistik und Fahrmuster für den lernenden Verkehr *(F151)* |
| `wr_power_grid` | Umspannwerke, Leitungen, Bezirke *(F154)* |
| `wr_fuel_stations` | Stationen, Kraftstoffarten, Vorrat, Ladepunkte *(F104/F134)* |
| `wr_navdata` | Flugplätze, Pisten, Funkfeuer, Wegpunkte, Verfahren *(F59)* |
| `wr_rail` | Strecken, Signale, Stellwerkslogik, Fahrpläne *(F82/F85)* |
| `wr_weather_state` | aktueller Klimazustand pro Zone |

### 4.6 Bridges (Adapter)

Jede Bridge ist eine kleine, austauschbare Datei mit fester Schnittstelle. Andere Server passen nur Bridges an und müssen den Kern nicht anfassen *(F103)*.

| Bridge | Mitgelieferte Adapter | Zweck |
|---|---|---|
| Framework | ESX Legacy, QBCore, Qbox, Standalone | Spieler, Jobs, Geld, Berechtigungen |
| Inventar | ox_inventory (weitere über die Schnittstelle) | Item-Gewichte und -Volumen, Teile, Werkzeuge |
| Voice | pma-voice, SaltyChat, YaCA *(F66)* | Funk, Intercom, Lärmdämpfung *(F68)* |
| Medical | generisch (Events/Exports) *(F34)* | Verletzungsobjekte (Körperregion, Art, Schwere) |
| Garage / Schlüssel | generisch und gängige Scripts | Zustand beim Ein-/Ausparken, Wegfahrsperre |
| Fuel | eigenes System oder Bridge zu Fremd-Scripts | Verbrauch und Tankstand |
| Polizei / Wirtschaft / Versicherung | generisch | Messprotokolle, Schadenshöhe, Teilepreise |
| Status | eigenes Basismodul oder externe Scripts *(F106)* | Alkohol, Drogen, Müdigkeit |
| Anti-Cheat | generisch *(F98)* | Whitelisting-Exports gegen False-Positives bei Kräften oder Handling |

### 4.7 API-Konventionen

- Events: `wr_physics:<modul>:<ereignis>`, z. B. `wr_physics:damage:crash` oder `wr_physics:occupant:injury`.
- Exports: lesend (`GetVehicleState`, `GetComponentHealth`, `GetMeasuredSpeed` …) und schreibend über serverseitig validierte Funktionen (`RepairComponent`, `InstallPart` …).
- State-Bag-Schlüssel: `wrp:<bereich>` mit quantisierten, kompakten Werten.
- Einheiten intern immer SI (m, kg, s, N, K, Pa, W). Umgerechnet wird erst bei der Anzeige *(F126)*.

---

## 5. Welt-Maßstab *(F124/F125/F127/F128)*

Figuren (~1,8 m) und Fahrzeuge (~4,5 m) haben in GTA reale Größe. Gestaucht sind nur die **Entfernungen** zwischen den Orten. Daraus ergibt sich:

1. **Lokale Physik 1:1:** Kräfte, Beschleunigung, Bremsweg, Kurvenverhalten und Geschwindigkeit bleiben real. Der Tacho zeigt die echte Geschwindigkeit.
2. **Streckenabhängige Größen × Welt-Faktor `k`:** Kraftstoff-/Energieverbrauch pro gefahrenem Meter, Verschleiß pro Meter und der km-Zähler werden mit `k` multipliziert. Die Reichweite erscheint dadurch realistisch.
3. **Bestimmung von `k`:** Man vergleicht Referenzstrecken in GTA (z. B. Los Santos ↔ Sandy Shores ↔ Paleto Bay, Stadtblöcke, Highway-Abschnitte) mit ihren realen Vorbildern (Großraum Los Angeles, Salton Sea, nördliches Kalifornien) und gewichtet nach typischer Nutzung (Stadt/Land). Vorläufig ist eine **Größenordnung von ca. 7–12 (linear)** zu erwarten. Der genaue Wert wird in Phase 0 gemessen, dokumentiert und ist per Config überschreibbar.
4. **Zeitabhängige Größen werden nicht skaliert** (Echtzeit, F129). Die Abkühlung eines Motors dauert also real lange, auch wenn die Fahrt „virtuell“ länger war.
5. **Langstrecken in Luft- und Seefahrt:** Der Luft- und Seeraum wird über die Kartengrenze hinaus erweitert. Dazu kommen Off-Map-Ziele (z. B. „San Fierro“, „Las Venturas“) mit realer Reisezeit und einem optionalen Reiseflug-Zeitraffer für sehr lange Strecken. Die Ankunft erfolgt per Anflug oder Einfahrt auf der Karte. Die technische Umsetzung (Weltgrenzen, Streaming über offenem Meer) wird im **Spike** geprüft.

---

## 6. Fachmodule

### 6.1 Fahrzeugdaten und Datenblätter *(F9–F11, F102, F120, F132)*

- **Ein Datenblatt pro Modell** (JSON, versioniert). Es enthält:
  - **Identität:** Hersteller, Modell, Baujahr, Markt, reales Vorbild.
  - **Masse:** Leergewicht, zulässiges Gesamtgewicht, Achslastverteilung, Schwerpunkthöhe.
  - **Motor:** Typ, Hubraum, Aufladung, Drehmomentkurve, Drehzahlgrenzen, Trägheit, Thermik, Ölmenge, Verbrauchskennfeld (BSFC).
  - **Getriebe:** Typ, Übersetzungen, Achsübersetzung, Schaltzeiten, Wandler.
  - **Antrieb:** Layout, Differenziale, Momentverteilung.
  - **Reifen:** Dimension, Typ, Solldruck, Pacejka-Parametersatz.
  - **Fahrwerk:** Federn, Dämpfer, Stabis, Sturz/Spur, Bodenfreiheit.
  - **Bremsen:** Scheibengröße, Beläge, Bremskraftverteilung, ABS.
  - **Aerodynamik:** cw, Stirnfläche, Abtrieb.
  - **Elektrik:** Bordnetzspannung, Batterie, Lichtmaschine.
  - **Energie:** Kraftstoffart, Tankinhalt bzw. Akku-kWh, Ladekurven.
  - **Assistenzsysteme:** vorhanden und/oder abschaltbar.
  - **Ausstattung:** Gurtwarner, Airbags, Wegfahrsperre, Lenkradschloss, Scheinwerfertyp.
  - **Darstellung:** Instrumenten-Vorlage, Einheiten, Sound-Profil.
  - **Lizenzklasse.**
- **Geometrie aus dem Modell** (Radstand, Spur, Radpositionen), **Masse und Leistung aus den Realdaten** *(F120)*.
- **Vanilla-Fahrzeuge** bekommen die Daten ihres realen Vorbilds *(F10)*.
- **Import-Pipeline** *(F102)*: Werte aus `handling.meta` und den Modellmaßen werden abgeleitet, dazu kommt ein Vorschlag aus der Realdaten-Recherche. Ein Admin prüft und gibt im Web-Panel frei.
- **Fallback** *(F132)*: Fahrzeuge ohne freigegebenes Datenblatt bekommen automatisch ein Klassen-Datenblatt, und im Panel erscheint eine Warnung.

### 6.2 Simulation der Landfahrzeuge

**Antriebsstrang** *(F16–F19, F31)*
- Motor:
  - Drehmoment ergibt sich aus Kurve × Lastkennfeld, mit Trägheit, Leerlaufregelung, Abwürgen und Begrenzer.
  - Kaltstart mit Choke bzw. Vorglühen je nach Motortyp und Temperatur.
  - Thermik: Brennraum, Kühlmittel, Kühler mit Fahrtwind und Lüfter, Umgebungstemperatur aus dem Wetter.
  - Öldruck abhängig von Drehzahl, Temperatur und Ölstand.
  - Überhitzung führt zu Schäden.
- Kupplung als Reibmodell (Haft-/Gleitreibung, Verschleiß, Temperatur), bedienbar über Taste oder Analogachse *(F19)*.
- Getriebe:
  - manuell (H-Schaltung oder sequentiell),
  - Wandlerautomatik mit P/R/N/D, Kriechen und Kickdown,
  - DSG mit Launch Control,
  - immer genau wie beim Vorbild *(F16)*.
- Differenziale: offen, LSD, Torsen, Visco oder starr. Dazu Mitteldifferenzial, zuschaltbarer Allrad, Untersetzung und manuelle Sperren.
- Verbrauch physikalisch aus BSFC × Leistung, Lastzustand, Leerlauf und Schubabschaltung *(F18)*, mit Welt-Faktor (Abschnitt 5).

**Reifen und Untergrund** *(F22–F25)*
- Pacejka Magic Formula mit kombiniertem Schlupf, ein Parametersatz pro Reifentyp und Dimension.
- Die Haftung hängt ab von:
  - Untergrund-μ (Material × Zustand),
  - Temperatur (Grip-Fenster, drei Zonen pro Reifen),
  - Luftdruck (Aufstandsfläche, Walkarbeit, Verschleiß, schleichender Platten),
  - Profiltiefe (Aquaplaning aus Wasserfilmdicke, Geschwindigkeit und Profil),
  - Reifenalter.
- Reifentypen: Sommer, Winter, Ganzjahr, Offroad, Slicks, Spikes.
- Der Untergrund kommt aus dem GTA-Material pro Rad und den Material-Overrides *(F131)*. Sein Zustand stammt aus dem Weltmodul: Nässe, Pfützen, Öl, Laub, Schnee, Eis.

**Fahrwerk, Bremsen, Aero, Masse** *(F26–F30)*
- Fahrwerk: Federrate, Dämpferkennlinien (Zug/Druck), Stabis, Sturz/Spur, Bodenfreiheit, Aufsetzen. Alles ist tuningfähig und kann beschädigt werden.
- Bremsen:
  - Hydraulik (Flüssigkeit, Leck, zwei Bremskreise),
  - Temperatur und Fading (Glühen ist sichtbar),
  - Verschleiß von Belägen und Scheiben,
  - dynamische Lastverlagerung, Blockieren ohne ABS,
  - mechanische Handbremse,
  - Druckluftbremse beim LKW (Abschnitt 6.8).
- Aerodynamik: cw·A, Abtrieb vorne/hinten, Windschatten, Seitenwind aus dem Windfeld, offene Fenster und Dach, Spoiler.
- Masse und Schwerpunkt: Jeder Insasse und jedes Item (ox_inventory-Gewicht und Ablageort Kofferraum/Rücksitz/Ladefläche) verändert Masse, Schwerpunkt und Achslasten *(F27)*.
- Assistenzsysteme (ABS, ESP, ASR, Launch Control, Tempomat): nur wo das Vorbild sie hat, abschaltbar wo das real möglich ist, und sie können ausfallen *(F29)*.

**Bordelektrik und E-Mobilität** *(F20/F21)*
- 12V/24V-Netz:
  - Batterie mit Ladezustand und Spannungseinbruch beim Starten,
  - Lichtmaschine mit Leistung abhängig von der Drehzahl,
  - Verbraucher (Licht, Radio, Klima, Gebläse).
  - Eine leere Batterie bedeutet: kein Start und keine Zentralverriegelung *(F54)*.
  - Abhilfe über Starthilfe, Ladegerät oder Anschieben *(F52)*.
- EV und Hybrid:
  - Akku mit kWh, Ladezustand, Temperatur, Innenwiderstand und Rekuperation,
  - Ladekurven für AC und DC,
  - Reichweite abhängig von Temperatur und Fahrweise.
  - Thermal Runaway nach einer Beschädigung ist möglich *(F90)*.

### 6.3 Schaden, Insassen, Wartung *(F32–F38, F49, F64)*

- **Crash-Erkennung:** Der Geschwindigkeitssprung pro Frame ergibt Crash-Puls, Richtung und Aufprallzone.
- **Komponentenschaden:** Die Aufprallenergie wird nach Zone auf Bauteile verteilt (Kühler, Motor, Lenkung, Achsen, Tank, Elektrik, Airbags …). Jeder Defekt wirkt sich physikalisch aus, z. B. Kühlmittelverlust → Überhitzung oder verbogene Spurstange → Schiefziehen.
- **Deformation:** stärker als in Vanilla, wird gespeichert und nach dem Ausparken oder einem Restart wiederhergestellt *(F36)*.
- **Insassen:**
  - Gurt manuell (Taste + Animation), Gurtwarner wie beim Vorbild.
  - Airbag löst nach dem Crash-Puls aus und muss danach getauscht werden.
  - Ohne Gurt kann man herausgeschleudert werden.
  - Aus g-Kräften werden Verletzungen pro Körperregion berechnet und als standardisiertes Objekt an die Medical-Bridge übergeben *(F33–F35)*.
- **Zufallsdefekte** *(F64)*: MTBF pro Bauteil. Die Ausfallrate steigt mit Alter, Verschleiß und versäumter Wartung, ist aber auch bei guter Wartung nie null.
- **Wartung:**
  - km-Stand, Serviceintervalle, Verschleißteile (Öl, Filter, Kerzen, Zahnriemen, Kupplung, Bremsen, Reifen, Batterie).
  - Standzeit-Effekte werden beim Ausparken nachberechnet *(F49)*.
- **Mechanik-Gameplay** *(F38)*:
  - OBD-Diagnosegerät (Item) mit Fehlercodes.
  - Teile sind ox_inventory-Items.
  - Ein- und Ausbau mit Werkzeug und Hebebühne; falscher Einbau hat Folgen.
- **Tuning** *(F39)*: Bauteile verändern die Werte im Datenblatt und haben Nebenwirkungen (Haltbarkeit, Verbrauch, Lautstärke, Abgas).
- **TÜV** *(F40)*: Das System liefert über eine API Messwerte (Bremsen, Profil, Licht, Abgas, Lautstärke).
- **EDR und Spuren** *(F100)*:
  - Der Unfalldatenspeicher hält ±5 s rund um den Crash fest: Geschwindigkeit, Pedale, Lenkung, Gurt, Δv.
  - LKW haben einen Fahrtenschreiber; beides ist per Item auslesbar.
  - Bremsspuren, Trümmer und Ölspuren bleiben eine Zeit lang liegen.
  - Ein Gutachter-Tool rekonstruiert den Unfall.

### 6.4 Bedienung, Sicht, Kamera, Sound, Instrumente

- **Bedienung** *(F135)*:
  - Türen, Fenster, Verdeck, Haube und Kofferraum einzeln bedienbar.
  - Durchrutschen auf den Nachbarsitz, Kindersitze.
  - Blinker, Warnblinker, Lichtschalter, Wischerstufen, Heizung/Klima.
  - Einsteigen, Anschnallen und Starten dauern realistisch lange.
- **Schlüssel** *(F54)*: Wegfahrsperre und Lenkradschloss je nach Baujahr. Kurzschließen geht nur bei alten Fahrzeugen.
- **Licht und Sicht** *(F53)*:
  - Scheinwerfertyp nach Baujahr (Halogen, Xenon, LED); Fernlicht blendet; Lampen können defekt sein.
  - Scheiben beschlagen, vereisen und verschmutzen. Dagegen helfen Wischer und Defroster.
- **Kamera** *(F50/F51)*: Die Perspektive ist frei wählbar. Längs- und Querbeschleunigung bewegen den Kopf mit; Fahrbahnvibration und Schlaglöcher sind spürbar.
- **Sound** *(F41)*: Motor- und Getriebesound folgen der simulierten Drehzahl und Last. Dazu kommen Turbo, Schlupfquietschen und Defektgeräusche (Klappern, Schleifen, Pfeifen) aus eigenen Audio-Bänken mit 3D-Positionierung.
- **Instrumente** *(F42/F43)*:
  - NUI-Vorlagen nach **Fahrzeugkategorie und Epoche**, z. B. Oldtimer (bis ca. 1975), Klassiker (1975–1995), modern analog (1995–2012), digital (ab 2012), Sport/Supersport, Motorrad klassisch/modern, LKW, Bus, Offroad/Nutzfahrzeug, EV.
  - Skalen, Einheiten und Warnleuchten kommen aus dem Datenblatt.
  - **Luft- und Seefahrzeuge bekommen eigene, typgerechte Cockpits**, zum Beispiel:
    - GA analog (Six-Pack), GA Glascockpit,
    - Business-Jet, Airliner,
    - Militärjet mit HUD, Transporter,
    - Zivil- und Militärhelikopter,
    - Sportboot, Schiffsbrücke, U-Boot,
    - Führerstand für Züge.

### 6.5 Eingabe, Force-Feedback, Companion-App *(F12–F15, F19, F122, F123)*

- Unterstützt werden Tastatur/Maus, Controller, Lenkrad mit Pedalen und H-Schaltung sowie HOTAS/Joystick mit Pedalen.
- Die **NUI-Gamepad-API** liest Achsen und Tasten ohne Zusatzsoftware. Mapping, Kalibrierung, Deadzones und Kurven pro Gerät werden pro Spieler gespeichert.
- Die **Companion-App** (C#/.NET, Windows, Open Source, signierter Release, optional) ergänzt:
  - DirectInput-Force-Feedback,
  - Geräte, die die Gamepad-API nicht sauber abbildet,
  - später Head-Tracking.
  - Verbindung: WebSocket an `127.0.0.1` mit Pairing-Token. Die App nimmt nur lokale Verbindungen an.
- **FFB** *(F14)*: Das Spiel sendet 30–60 Mal pro Sekunde Effekt-Parameter:
  - Self-Aligning-Torque aus dem Reifenmodell,
  - Federkraft und Dämpfung,
  - Fahrbahntextur,
  - Stöße und Kollisionen.
  - Die App rendert daraus lokal mit ca. 1 kHz flüssiges Force-Feedback.
- Tastatur: Lenk-Rampe (der Einschlag baut sich auf), aber keine Stabilitäts- oder Gegenlenkhilfen *(F122)*. Kupplung als Taste oder Achse *(F19)*.

### 6.6 Kraftstoff und Energie *(F18, F104, F134)*

- Ein eigenes Fuel- und Lade-System ersetzt ox_fuel/LegacyFuel. Für Server, die ihr Fuel-Script behalten wollen, lässt sich das Modul deaktivieren und eine Bridge nutzen.
- Kraftstoffarten: Super E5/E10, Super Plus, Diesel, AvGas 100LL, Jet A-1, Marinediesel, Strom (AC/DC).
- Falschbetankung hat Folgen, zum Beispiel:
  - Benzin im Diesel → Schaden an der Einspritzpumpe,
  - E10 in einem nicht freigegebenen Oldtimer → Langzeitschaden,
  - Jet-A in einem Kolbenmotor → Triebwerksausfall.
- Der Vorrat pro Station und Kraftstoffart ist konfigurierbar. Wenn er begrenzt ist, beliefert ein Tanklaster (Spielerjob) die Stationen. Flughäfen haben Tankwagen *(F60)*.
- Zapfsäulen und Ladesäulen hängen am Stromnetz *(F154)*.

### 6.7 Motorräder, Fahrräder, Kleinfahrzeuge *(F44/F45/F86)*

- Motorrad:
  - Gegenlenken, Schräglage durch den Grip begrenzt, Wheelie und Stoppie physikalisch, High- und Lowsider.
  - Der Fahrer stürzt als Ragdoll. Helm und Schutzkleidung reduzieren Verletzungen.
- Fahrrad:
  - Die Tretleistung kommt aus Ausdauer und Kondition des Charakters.
  - Gangschaltung, Steigungen, E-Bike mit Akku, Stürze.
- E-Scooter, Skateboard, Rollstuhl/Gehhilfen (gekoppelt an das Medical), Ski, Snowboard und Rodel mit Gleitphysik auf Schnee.

### 6.8 Nutzfahrzeuge, Anhänger, Offroad, Spezialfahrzeuge *(F46–F48, F87)*

- LKW:
  - Druckluftbremse: Druckaufbau vor der Abfahrt, Federspeicher, Leck, Motorbremse/Retarder.
  - Getriebe mit 12–18 Gängen, Range/Splitter oder AMT wie beim Vorbild.
  - Achslasten und Überladung, die eine Polizei-Waage messen kann. Bei Überlast können Reifen platzen.
- Anhänger und Sattel:
  - eigene Masse, Stützlast, Knickwinkel, Pendeln, Jackknifing.
  - Beim Ankuppeln werden Luft und Strom verbunden.
  - Die zulässige Anhängelast kommt aus dem Datenblatt.
  - Abschleppseil und -stange übertragen echte Kräfte.
- Offroad:
  - Einsinken abhängig von Masse, Reifendruck und Untergrund; Festfahren.
  - Achsverschränkung, Wattiefe, Wasserschlag.
  - Seilwinde und Bergung.
- Spezialfahrzeuge: Hydraulik (Arm, Schaufel, Gabel), Lasten mit realem Gewicht, Kippgefahr, Traktor mit Anbaugeräten und Zapfwelle.

### 6.9 Verkehr, Ampeln, Straßennetz, Messgeräte, Stromnetz *(F130, F148–F155)*

- **Straßennetz:**
  - Graph aus den GTA-Pfadknoten mit Tempolimits, Vorfahrt, Spuren und Verkehrszeichen.
  - Bearbeitung im Admin-Editor und im Web-Panel.
  - Genutzt von NPCs, Blitzern, Tempomat und Verkehrszeichenerkennung sowie der Polizei.
- **Ampeln:**
  - Der Server verteilt Phasenpläne mit Zeitstempel. Jeder Client berechnet daraus denselben Zustand, sodass alle Spieler dieselbe Ampelschaltung sehen.
  - Rot-Gelb je nach Region, Fußgängerampeln, Grüne Welle.
  - Bedarfsschaltung über virtuelle Induktionsschleifen.
  - Nachts gelb blinkend.
  - Ausfall bei Stromausfall oder wenn ein Mast umgefahren wurde.
- **NPC-Verkehr:**
  - regelkonform: Ampeln, Vorfahrt, Tempolimits, Blinken, Abstand.
  - Dichte nach Tageszeit und Wochentag, Staus an Engstellen und Unfällen.
  - Reaktionen: Rettungsgasse, Umfahren, Gaffer.
  - Persönlichkeiten: vorsichtig, normal, aggressiv, abgelenkt.
- **Lernender Verkehr** *(F151)*:
  - Anonymisierte Statistik pro Zone und Stunde (Tempo im Verhältnis zum Limit, Rotläufe, Abstände) verschiebt den Persönlichkeits-Mix der NPCs.
  - Zusätzlich fahren gelegentlich „Kopierfahrer“ aufgezeichnete Fahrmuster echter Spieler nach. Dadurch heizt auch mal ein NPC durch die City.
- **NPC-Fußgänger** *(F152)*: nutzen Zebrastreifen und Fußgängerampeln, gehen manchmal bei Rot und erleiden bei einem Anstoß dieselbe Crash-Physik wie Spieler.
- **Messgeräte** *(F153/F155)*:
  - Stationäre und mobile Blitzer, Rotlichtblitzer, Radar und Laser, Waage, Promilletester, Profiltiefenmesser.
  - Sie haben reale Messfehler (Cosinus-Effekt, Sichtlinie beim Laser) und Toleranzen und müssen geeicht sein.
  - Ergebnis ist ein Messprotokoll für die Polizei- oder Wirtschafts-Bridge.
- **Stromnetz** *(F154)*:
  - Umspannwerke und Leitungen versorgen Bezirke.
  - Sturm, Unfall oder Sabotage verursachen Ausfälle von Ampeln, Laternen, Lade- und Zapfsäulen.
  - Die Reparatur ist ein RP-Job.

### 6.10 Welt: Wetter, Fahrbahn, Ereignisse, Strukturen

- **Klimamodell (serverseitig)** *(F92/F93/F136)*:
  - Zonen: Küste, Stadt, Wüste, Berge, Wald, offenes Meer, mit Höhengradient.
  - Größen: Temperatur, Luftdruck, Feuchte, Wind in Höhenschichten, Niederschlag, Bewölkung und Wolkenuntergrenze, Sicht, Nebel, Wassertemperatur, Wellenhöhe.
  - Jahreszeiten- und Tagesgang nach kalifornischem Klima: Schnee regelmäßig am Chiliad, in der Stadt sehr selten.
  - Der Client zeigt das passende GTA-Wetter zu seiner Position, mit Übergängen. Für Flugplätze wird ein METAR erzeugt.
- **Fahrbahnzustand** *(F25)*:
  - Die Wasserfilmdicke pro Zone baut sich aus Regen auf und wieder ab (Abfluss, Verdunstung).
  - Pfützen in Senken (automatisch erkannt und über den Editor).
  - Ölspuren nach Unfällen bleiben, bis sie gereinigt werden.
  - Schnee und Eis in den Bergen, Laub im Herbst.
  - Streudienst und Straßenreinigung sind als RP-Jobs möglich.
- **Naturereignisse** *(F137)*: Sturm/Orkan (Böen, umstürzende Bäume und Schilder), Starkregen und Hochwasser (Fahrzeuge saufen ab oder treiben ab), Waldbrand, Erdbeben, dichter Nebel.
- **Brand** *(F90)*:
  - Fahrzeugbrände haben Ursachen (Kurzschluss, Leck, Überhitzung, Akku).
  - Die Ausbreitung wird in Zellen berechnet (Brandlast, Vegetation, Wind).
  - Löschmittel: Wasser, Schaum, CO₂.
  - Explosionen gibt es nur, wo sie physikalisch plausibel sind.
- **Wildwechsel** *(F158)*:
  - nachts und in der Dämmerung häufiger, in Wald- und Landgebieten.
  - Tiere reagieren auf Licht und Hupe.
  - Bei einer Kollision zählt die reale Masse (Reh ~25 kg, Hirsch ~150 kg, Kuh ~600 kg).
- **Strukturen** *(F138/F159)*:
  - Masten, Leitplanken und Ampeln brechen je nach Energie oder halten; der Schaden bleibt bis zur Reparatur (Straßenmeisterei).
  - Türen und Tore lassen sich mit realer Kraft aufbrechen (Rammbock, Kuhfuß, Fahrzeug).
  - Zäune geben nach, Mauern halten.
  - Glas bricht je nach Energie und Glastyp (Verbundglas, ESG, Panzerglas).
  - Für Brücken und Stege gelten Lastgrenzen. Kartengeometrie kann nicht einstürzen, Konsequenzen gibt es deshalb nur bei eigenen Props.

### 6.11 Person *(F79, F83, F84, F89, F95, F105)*

- **Bewegung:**
  - Ausdauer und Tempo hängen von Gewicht, Fitness, Verletzung und Steigung ab.
  - Trägheit über eine Glättung der Bewegung.
  - Ausrutschen auf Eis, Nässe und Hängen.
  - Klettern und Springen abhängig von Gewicht und Fitness, kein Bunnyhop.
- **Tragen** *(F89)*:
  - reales Gewicht und Volumen jedes Items.
  - Große Objekte und Personen werden getragen oder gezogen; schwere Lasten nur zu zweit.
  - Ungesicherte Ladung rutscht oder fällt herunter. Abhilfe: Spanngurte.
  - Geworfene Objekte haben reale Masse.
- **Fallschaden:** ergibt sich aus Aufprallgeschwindigkeit und Untergrund, Verletzungen pro Körperregion, Abrollen ist möglich.
- **Körpertemperatur** *(F95)*:
  - Wärmebilanz aus Stoffwechsel, Kleidung (Isolationswert pro Kleidungsstück), Nässe und Wind-Chill.
  - Folgen: Unterkühlung oder Hitzschlag.
  - Heizung und Klimaanlage im Fahrzeug wirken.
- **Schwimmen und Tauchen** *(F79/F80)*:
  - Ausrüstung macht schwer; Strömung und Wellen treiben ab.
  - Ertrinken, Unterkühlung nach Wassertemperatur.
  - Tauchgas-Verbrauch nach Tiefe, Stickstoffsättigung (vereinfachtes Bühlmann-Modell), Dekompressionskrankheit.
  - Schwimmweste, Rettungsinsel, EPIRB.
- **Fallschirm** *(F69)*: Freifall-Aerodynamik, Öffnungsstoß, Schirmsteuerung mit Wind, Fehlöffnung und Reserve, Landeverletzungen.
- **Fahrerzustand** *(F105/F106)*:
  - Promille-Abbau, Drogen-Wirkkurven, Müdigkeit aus der Wachzeit.
  - Folgen: Input-Verzögerung, unruhige Lenkung, Tunnelblick.
  - Verletzungen schränken die Bedienung ein (z. B. ein gebrochener Arm).

### 6.12 Ballistik *(F88, F91, F133)*

- Waffen-Datenblatt: Kaliber, Geschossmasse, Mündungsgeschwindigkeit, ballistischer Koeffizient (G1/G7), Rückstoß.
- Flugbahn mit Luftwiderstand, Schwerkraft und Wind, berechnet über schrittweise Raycasts.
- Durchschlag:
  - Material aus dem Raycast, Materialdicke über einen Gegenraycast.
  - Restenergie nach Materialtabelle (Holz, Blech, Beton, Glas, Panzerglas).
  - Querschläger abhängig vom Auftreffwinkel.
- Personen:
  - Schutzwesten nach VPAM/NIJ-Klasse je Kaliber.
  - Trefferzonen und Energieübertrag; das Verletzungsobjekt geht an die Medical-Bridge.
  - Ein Durchschuss kann die Person dahinter treffen.
- Fahrzeuge: Treffer schädigen gezielt Bauteile (Reifen, Kühler, Tank, Motor, Insassen durch die Karosserie).
- Autorität:
  - Der Client simuliert, damit es flüssig wirkt.
  - Der Server validiert Distanz, Sichtlinie, Flugzeit, Munition und Feuerrate.
  - Der GTA-Hitscan-Schaden wird serverseitig verworfen.

### 6.13 Luftfahrt *(F55–F65, F128)*

- **Flugmodell (Blade-Element):**
  - Flügel und Leitwerk in Segmente zerlegt. Pro Segment: lokale Anströmung (Bahngeschwindigkeit + Drehung + Wind + Propellerstrahl), Anstellwinkel, Beiwerte aus Tabellen inklusive Post-Stall, dazu Ruder und Klappen.
  - Effekte: Stall, Trudeln, Bodeneffekt, Trimmung.
  - Die Summe aus Kräften und Momenten wird auf die Entity angewendet; die GTA-Aerodynamik wird über Handling-Werte reduziert (**Spike**).
- **Triebwerke:**
  - Kolbenmotor mit Gemisch, Magnetos und Vergaservereisung.
  - Turboprop.
  - Jet mit N1/N2, EGT, Schub abhängig von Höhe und Mach, APU.
- **Atmosphäre:** ISA mit QNH und Temperaturabweichung, Dichtehöhe, Wind in Schichten, Böen und Scherwinde, Turbulenzmodell, Thermik, Lee-Turbulenz, Wirbelschleppen, Vereisung.
- **Weight & Balance:** Leergewicht, Passagiere, Fracht, Tanks → Schwerpunkt, Vr und Startstrecke. Tank-Management, Betankung per Tankwagen.
- **Systeme in Study-Level-Tiefe** *(F57/F58)*:
  - Elektrik, Kraftstoff, Hydraulik, Bleed Air und Triebwerke werden pro Typ datengetrieben definiert.
  - Bedienung über detaillierte NUI-Panels (Overhead, Pedestal, MCP, FMC).
  - Ohne korrekte Prozedur gibt es keinen Start.
  - Checklisten werden als Items mitgeliefert *(F118)*.
- **Avionik:**
  - VOR, NDB, ILS, GPS.
  - Eigene Navdaten für San Andreas: Flugplätze, Pisten, Funkfeuer, Wegpunkte, Airways, SID/STAR/Anflüge.
  - FMC mit LNAV/VNAV, Autopilot, Transponder.
  - ATC-Radarschirm für Lotsen-Spieler *(F65)*.
- **Helikopter** *(F61)*:
  - Rotor aus Impuls- und Blattelement-Theorie mit Rotordrehzahl.
  - Effekte: Translational Lift, Bodeneffekt, Vortex Ring State, Retreating Blade Stall, Dynamic Rollover, Mast Bumping.
  - Autorotation.
  - Außenlast am Seil (Pendeln) und Rettungswinde.
- **Ausfälle** *(F63/F64)*: Strukturgrenzen (Vne, g-Limits) bis zum Strukturversagen, Triebwerksausfall, Vogelschlag, Systemausfälle, Fahrwerksschaden bei harter Landung, Wartung wie bei Fahrzeugen.
- **Lärm und Voice** *(F68)*: Cockpitlärm dämpft die Stimme. Headset und Intercom über die Voice-Bridge.
- **Vanilla-Flotte:** Bei den Flugzeugen sind das unter anderem Duster, Mammatus, Cuban 800, Velum, Dodo (Wasserflugzeug), Luxor, Shamal, Nimbus, Jet, Titan, Cargo Plane und Lazer. Bei den Helikoptern unter anderem Maverick, Frogger, Swift, Buzzard und Cargobob.

### 6.14 Seefahrt *(F73–F80)*

- **Rumpf:**
  - Stützpunkte (Voxel) pro Rumpfmodell. Pro Punkt: eingetauchtes Volumen → Auftrieb.
  - Viskoser und Druckwiderstand, dynamischer Auftrieb beim Gleiter.
  - Trimm, Krängung und metazentrische Stabilität; Kentern ist möglich.
- **Seegang:**
  - Eigenes Wellenmodell (Überlagerung von Gerstner-Wellen) mit Seed und Zeitbasis vom Server, sodass alle dieselben Wellen haben.
  - Die Wellen kommen aus dem Wind (Beaufort). Die GTA-Wasseroptik wird angenähert. Slamming bei hoher Fahrt.
- **Strömung und Gezeiten:** Strömungsfelder im Meer und in Flüssen, Ebbe und Flut verändern den Wasserstand (**Spike**: was GTA-Wasser hergibt).
- **Grund:** Wassertiefe über einen Raycast zum Grund, Tiefgang, Grundberührung, Propellerschaden, Echolot.
- **Antrieb:**
  - Motor wie beim Auto.
  - Propeller: Schub abhängig vom Fortschrittsgrad, Kavitation, Radeffekt.
  - Trimm des Außenborders, Salzwasserkühlung, Ansaugen von Schmutz.
  - Bugstrahlruder, Anker, Schlepper.
- **Segeln:** Auftrieb und Widerstand des Segels aus dem scheinbaren Wind. Krängungsmoment gegen das aufrichtende Moment von Kiel und Ballast. Am-Wind-Kurse, Wende und Halse.
- **Wassereinbruch:** Lecks nach Kollision oder Grundberührung, Kompartments, Lenzpumpen, Sinken.
- **Wracks:** bleiben am Grund (persistent) und lassen sich mit Hebesäcken und Kran bergen (RP-Job).
- **U-Boote:** Ballasttanks, Trimm, Tauchtiefe und Druck, Sauerstoff (Vanilla: Kosatka, Submersible).

### 6.15 Bahn *(F81/F82/F85)*

- Eigene Strecken per Custom-Track-Dateien (Güterbahnhof, Rangiergleise …) neben den GTA-Strecken.
- Zugdynamik:
  - Zugkraftkurve und Fahrwiderstand (Davis-Formel).
  - Druckluftbremse mit Durchschlagzeit und Bremshundertsteln.
  - Entgleisen bei zu hoher Geschwindigkeit in Kurven.
- Signale (Hp0/Hp1/Vr), stellbare Weichen, Stellwerk-UI für Fahrdienstleiter-Spieler, PZB-artige Zugsicherung, Fahrplan.
- Waggons kuppeln: Wie flexibel Zugverbände zur Laufzeit zusammengestellt werden können, wird im **Spike** geprüft.

### 6.16 Admin, Telemetrie, Web-Panel, Anti-Cheat *(F97–F101)*

- **Ingame:**
  - Telemetrie-Overlay mit Live-Graphen (Schlupf, Reifenkräfte, Temperaturen, Drehmoment, Aero, Flugdaten).
  - Live-Tuning-Editor: Änderungen werden als Datenblatt-Entwurf gespeichert und im Panel freigegeben.
  - Fahrzeug- und Bauteil-Inspector.
  - Aufzeichnung mit 20 Hz als CSV oder Replay.
  - Editoren für Materialzonen, Straßennetz, Ampeln, Stromnetz und Navdaten.
- **Web-Panel (TypeScript):**
  - Datenblätter mit Versionierung und Freigabe-Workflow, Vanilla-Zuordnung, Import-Warteschlange.
  - Kartenansichten für Zonen, Straßen, Ampeln, Netz und Navdaten.
  - Telemetrie- und Fehlerberichte.
  - Login per Discord mit Rollen.
  - Liest und schreibt direkt in der Datenbank und meldet Änderungen live über die HTTP-API der Ressource an den Spielserver.
- **Validierung:**
  - Der Server prüft gegen das Datenblatt (maximale Beschleunigung, Vmax, Verbrauchsuntergrenze, Teleport).
  - Meldungen gehen in ein Discord-Log und an die Anti-Cheat-Bridge.
  - Whitelist-Exports verhindern False-Positives durch unsere Kräfte.

---

## 7. Qualitätssicherung *(F111, F112, F115, F116)*

1. **Unit-Tests (busted)** für alle reinen Physikmodule (Reifen, Motor, Getriebe, Thermik, Elektrik, Rumpf, Flügelsegment …).
2. **Offline-Simulator (`tools/`)**: Ein Fahrzeug wird ohne Spiel aus dem Datenblatt simuliert und mit Herstellerdaten verglichen (0–100, 80–120, Bremsweg 100–0, Vmax, Verbrauch).
3. **Automatische Messfahrten im Spiel** auf einer Teststrecke:
   - 0–100 und Bremsweg,
   - Elchtest (ISO 3888-2),
   - Kreisbahn (stationäre Querbeschleunigung),
   - Vmax,
   - Verbrauchszyklus.
   - Ergebnis ist ein Bericht im Vergleich zum Datenblatt. Zielwert: ±5 %.
4. **Gefühls-Abnahme:** Der Tester bewertet pro Referenzfahrzeug mit einer Checkliste (Lenkgefühl, Gewicht, Bremsdosierung, Grenzbereich, Sound, FFB). Das Ergebnis fließt in die Feinabstimmung ein *(F117)*.
5. **CI (GitHub Actions):** Lua-Lint (selene/luacheck), Formatierung, busted, TypeScript-Typecheck/Lint/Build, Release-Pakete.
6. **Testserver-Pipeline** *(F115/F116)*:
   - Der Testserver holt den Test-Branch selbst (Git-Pull per Skript in `tools/testserver/`, ausgelöst per Cron oder txAdmin) und startet die Ressourcen neu.
   - Ein Fehlerreporter sammelt Client- und Serverfehler sowie Telemetrie-Anomalien in Log-Dateien.
   - Optional legt er automatisch GitHub-Issues an. Dafür braucht es einen fein eingeschränkten Token, der nur Issues in diesem Repo anlegen darf und nur in der `server.cfg` steht, nie im Repo. Doppelte Meldungen werden über einen Stacktrace-Hash erkannt.
   - Feedback zum Fahrgefühl kommt manuell vom Tester.

---

## 8. Risiken und Gegenmaßnahmen

| # | Risiko | Gegenmaßnahme |
|---|---|---|
| R1 | Die GTA-Physik ist eine Blackbox, das Reifen- und Flugverhalten lässt sich nur annähern | Spikes in Phase 0, Mapping-Schicht mit Kalibrierung, Gefühl vor Messwert |
| R2 | Lua-Performance bei vielen Natives pro Frame | Native-Aufrufe minimieren und cachen, LOD-Stufen, Profiler mit Auto-Degradation |
| R3 | Handling ist nur lokal, beim Owner-Wechsel geht es verloren | Zustand in State Bags, Reapply-Hook beim Owner-Wechsel |
| R4 | Deformation lässt sich nur näherungsweise wiederherstellen | Gitter-Abtastung, bewährtes Nachbildungsverfahren, Grenzen dokumentieren |
| R5 | Die Steuerung der NPC-KI ist begrenzt (Ampeln, Persönlichkeit) | Spike, eigene KI-Schicht nur im Nahbereich, schrittweise Ausbaustufen |
| R6 | Engine-Limits bei Feuer, Decals, Entities und Wellen | serverseitige Zellmodelle, nur lokale Instanziierung, Pooling |
| R7 | Jitter durch eigene Kräfte bei Flugzeugen und Booten im Netzwerk | Kräfte nur beim Owner, Glättung, Tests mit mehreren Clients |
| R8 | Hoher Aufwand für die Realdaten von hunderten Modellen | Import-Pipeline, Klassen-Fallback, Priorisierung nach Nutzung |
| R9 | Sehr großer Umfang (mehrjährig) | strikte Modularität, MVP zuerst, jede Phase ist für sich nutzbar |
| R10 | Sicherheit der Companion-App | nur localhost, Pairing-Token, Open Source, signierte Releases |
| R11 | VR ist technisch kaum machbar | ganz am Ende, ehrlicher Stufenplan *(F145)* |
| R12 | Künstliches Licht lässt sich nur global schalten (regionaler Stromausfall) | Umschalten pro Client nach Position, gezielte Steuerung der Props |
