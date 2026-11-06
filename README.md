# wr_physics

**DE:** Modulares, extrem realistisches Physik-System für FiveM-Hardcore-Roleplay: Land-, Luft-, Wasser- und Schienenfahrzeuge, Personen, Ballistik, Wetter, Verkehr und Infrastruktur.
**EN:** Modular, highly realistic physics system for FiveM hardcore roleplay: land, air, water and rail vehicles, characters, ballistics, weather, traffic and infrastructure.

> Status: **v0.1 – erste testbare Version.** Kern, Antriebsstrang-Simulation (Motor, Kupplung, Getriebe, Verbrauch), Kopplung an die GTA-Physik, Telemetrie-Overlay und Messfahrten laufen. Anleitung: [`docs/testserver.md`](docs/testserver.md).

## Dokumente / Documents
| Dokument | Inhalt |
|---|---|
| [`docs/anforderungen.md`](docs/anforderungen.md) | Anforderungskatalog: 160 geklärte Fragen (F1–F160) |
| [`docs/konzept.md`](docs/konzept.md) | Technisches Konzept: Architektur, Module, Machbarkeit, Risiken |
| [`docs/roadmap.md`](docs/roadmap.md) | Roadmap: Phasen 0–15 mit Abnahmekriterien |
| [`docs/testserver.md`](docs/testserver.md) | Testserver einrichten, Updates ziehen, Bedienung v0.1 |
| [`docs/spikes/README.md`](docs/spikes/README.md) | Stand der Machbarkeits-Spikes (Phase 0) |

## Eckdaten / Key facts
- Framework: ESX Legacy (ox_lib, oxmysql, ox_inventory), Bridges für QBCore, Qbox und Standalone
- Sprachen: Lua 5.4 (Logik & Physik), TypeScript (NUI, Web-Panel), C#/.NET (optionale Companion-App für Force-Feedback)
- Ressourcen-Prefix: `wr_physics_*`
- Lizenz / License: [GPL-3.0](LICENSE)

## Entwicklung / Development
```bash
lua5.4 tests/run.lua          # Unit-Tests (reines Lua, kein busted nötig)
luacheck resources tests tools
lua5.4 tools/sim/accel.lua    # Offline-Referenz: 0-100, Vmax je Datenblatt
```
Ressourcen: `wr_physics_core` (Pflicht), `wr_physics_vehicle`, `wr_physics_devtools` (nur Testserver).
