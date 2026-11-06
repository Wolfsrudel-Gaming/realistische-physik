# Phase 0 – Machbarkeits-Spikes

Status der Prototypen aus der Roadmap. Jeder Spike bekommt nach dem Ingame-Test einen kurzen
Bericht (`S<n>-<thema>.md`) mit Ergebnis, Messwerten und Entscheidung.

| Spike | Thema | Stand | Wie testen |
|---|---|---|---|
| S1 | Drehzahl, Gang, Kupplung pro Frame steuern | **Prototyp im Spiel** (`wr_physics_vehicle`) | Fahren, `/wrp_handling` zeigt, ob GTA die gesetzten Werte behält; Overlay zeigt Sim-Werte |
| S2 | Antriebskraft vorgeben (Power-Multiplikator vs. Kraft) | **Prototyp im Spiel** (`client/coupling.lua`) | `/wrp_coupling power`, `force`, `hybrid` nacheinander, jeweils `/wrp_measure`; Overlay-Graph „a soll/ist“ |
| S3 | Owner-Wechsel, State Bags | **Prototyp im Spiel** | Zu zweit: Fahrer wechseln, `/wrp_net`, Motorzustand muss erhalten bleiben |
| S4 | NUI-Gamepad-API (Lenkrad/HOTAS), Localhost-WebSocket | offen | – |
| S5 | Ampel-Props und NPC-Verhalten an Kreuzungen | offen | – |
| S6 | Eigene Flug-/Bootskräfte, Jitter | offen | – |
| S7 | Wasser-API (Wellen, Wasserstand, Grund) | offen | – |
| S8 | Untergrundmaterial je Rad | **Prototyp im Spiel** | `/wrp_material` auf Asphalt, Schotter, Gras, Sand, Kopfstein |
| S9 | Welt-Maßstabsfaktor | **Vorrechnung, siehe unten** | `/wrp_scale`, dann Referenzfahrten mit km-Zähler |
| S10 | Deformation speichern/wiederherstellen | offen | – |
| S11 | Erweiterter Luft-/Seeraum | offen | – |
| S12 | Zugverbände, eigene Strecken | offen | – |

## S9 – Welt-Maßstab: Vorrechnung

Luftlinie zwischen GTA-Landmarken gegen die (groben) realen Distanzen ihrer Vorbilder:

| Strecke | GTA | real ≈ | k |
|---|---|---|---|
| LSIA → Paleto Bay (LAX → Nordkalifornien) | 9,0 km | 900 km | 100 |
| Downtown → Sandy Shores (DTLA → Salton Sea) | 5,1 km | 260 km | 51 |
| Del Perro Pier → Downtown (Santa Monica → DTLA) | 1,7 km | 25 km | 15 |
| Vespucci → LSIA (Venice → LAX) | 1,3 km | 10 km | 8 |
| Downtown → Mt. Chiliad (DTLA → Mt. San Antonio) | 6,5 km | 90 km | 14 |

**Erkenntnis:** Der Faktor ist stark regional. Innerhalb der Stadt liegt er bei ca. 8–15,
Richtung Norden bei 50–100. Ein einzelner globaler Faktor (Mittel ≈ 38) würde Stadtfahrten
massiv zu teuer machen oder Landfahrten zu billig.

**Empfehlung (Entscheidung offen, F127 Option „zonenweise“):**
- Welt-Faktor als **Zonenkarte** statt Einzelwert: Stadt ≈ 10, Vorstadt/Küste ≈ 20, Land/Berge ≈ 40.
- Bis dahin bleibt `wrp_world_scale` auf 1,0 (unverzerrt), damit Messfahrten sauber sind.

## S1/S2 – Was im Prototyp gemessen werden soll

1. **Hält GTA die Vorgaben?** `SetVehicleCurrentRpm`, `SetVehicleCurrentGear`/`SetVehicleNextGear`,
   `SetVehicleClutch` werden jeden Frame gesetzt. Beobachten: schaltet das Spiel trotzdem selbst?
   Passt der Motorsound zur Sim-Drehzahl?
2. **Power-Pfad:** Folgt die Ist-Beschleunigung der Soll-Beschleunigung (Overlay-Graph, blau = soll,
   orange = ist)? Wie groß ist der Multiplikator (×)? Bei > 4 oder < 0,3 stimmt die
   Vorsteuerung nicht und muss aus `fInitialDriveForce` besser hergeleitet werden.
3. **Kraft-Pfad:** `/wrp_coupling force` – stimmt die Skalierung von `ApplyForceToEntity`
   (forceType 0, Kraft × dt)? Wenn das Auto deutlich zu schwach oder zu stark beschleunigt, muss
   `forceType`/`forceScale` in `coupling.lua` kalibriert werden. Ziel: 0–100 der Messfahrt nahe
   am Offline-Simulator (`lua5.4 tools/sim/accel.lua`).
4. **Rückwärts und Schubbetrieb:** Im Hybrid-Modus laufen Rückwärtsgang, Kriechen (Automatik)
   und Motorbremse ausschließlich über den Kraft-Pfad. Fühlt sich die Motorbremse an?
5. **Abwürgen/Starten:** Motor aus beim Einsteigen, Start mit G, Abwürgen ohne Gas.

## Offline-Referenz (Stand der Datenblätter)

```
$ lua5.4 tools/sim/accel.lua
Ford Mustang GT (S197)      0-100: 5.43 s (+13%)   vmax 263 km/h (+5%)
Honda Civic Si (FG2)        0-100: 7.24 s (+8%)    vmax 212 km/h (-2%)
Subaru Impreza WRX STI (GD) 0-100: 4.43 s (-15%)   vmax 271 km/h (+9%)
Toyota Corolla GT-S (AE86)  0-100: 8.82 s (-1%)    vmax 188 km/h (-1%)
Toyota Camry LE 2.4 (XV40)  0-100: 9.85 s (+9%)    vmax 216 km/h (+8%)
```

Abweichungen zu den Werksangaben kommen aus synthetischen Drehmomentkurven, fehlender
Reifenschlupf-Dynamik und geschätzten Anfahr-/Schaltzeiten. Ziel nach Phase 3: ±5 %.
