# Testserver-Anleitung

Diese Anleitung beschreibt, wie der Testserver den aktuellen Entwicklungsstand selbst holt (F115),
wie Fehler und Messungen zurückfließen (F116) und wie die erste testbare Version bedient wird.

## 1. Voraussetzungen

- FXServer mit aktuellem Artefakt, `sv_enforceGameBuild` auf den neuesten stabilen Build
- `oxmysql` gestartet (ohne oxmysql läuft alles, nur ohne Persistenz)
- ESX Legacy ist optional: der Kern erkennt ESX, QBCore, Qbox oder läuft standalone
- Git auf dem Server

## 2. Einrichtung (einmalig)

```bash
# 1. Repo neben den Serverdaten auschecken (öffentliches Repo: kein Token nötig)
git clone https://github.com/wolfsrudel-gaming/realistische-physik.git /opt/wr_physics
cd /opt/wr_physics
git checkout claude/fivem-realistic-physics-7adz0r

# 2. Ressourcenordner in den Server verlinken
ln -s "/opt/wr_physics/resources/[wr_physics]" "/pfad/zum/server/resources/[wr_physics]"
```

In die `server.cfg`:

```cfg
ensure oxmysql
# ... Framework ...
ensure wr_physics_core
ensure wr_physics_vehicle
ensure wr_physics_devtools        # nur auf dem Testserver

# Optional: Konfiguration per Convar (siehe shared/config.lua für alle Schlüssel)
setr wrp_locale de
setr wrp_log_level info
setr wrp_vehicle_coupling hybrid       # power | force | hybrid
setr wrp_world_scale 1.0               # Welt-Maßstab k, siehe docs/spikes/README.md (S9)
setr wrp_vehicle_autoStartOnEnter 0    # 1 = Motor läuft beim Einsteigen (unrealistisch, zum Testen ok)
setr wrp_modules_devtools 1

# Admin-Rechte für wrp_status und spätere Editoren
add_ace group.admin wr_physics.admin allow
```

## 3. Updates ziehen

`tools/testserver/update.sh` holt den Branch, sammelt die Log-Dateien ein und gibt die
Restart-Befehle aus (oder führt sie aus, wenn `WRP_RCON_CMD` gesetzt ist).

```bash
# manuell
/opt/wr_physics/tools/testserver/update.sh

# automatisch alle 5 Minuten (crontab -e)
*/5 * * * * WRP_REPO_DIR=/opt/wr_physics /opt/wr_physics/tools/testserver/update.sh >> /var/log/wr_physics_update.log 2>&1
```

Danach in der Serverkonsole (oder automatisch über `WRP_RCON_CMD`):

```
restart wr_physics_core
restart wr_physics_vehicle
restart wr_physics_devtools
```

## 4. Rückweg: Fehler und Messungen

| Was | Wo |
|---|---|
| Client- und Serverfehler | `resources/[wr_physics]/wr_physics_core/logs/errors-YYYY-MM-DD.jsonl` |
| Messfahrten (`/wrp_measure`) | `resources/[wr_physics]/wr_physics_devtools/logs/measurements.jsonl` |
| Kopien beim Update | `.testserver-logs/` im Repo-Checkout |
| Status | `wrp_status` in der Konsole oder `http://<server>:30120/wr_physics_core/status` |

Die `.jsonl`-Dateien bitte bei Problemen als Datei in ein GitHub-Issue hängen oder in den Chat
kopieren. Für Fahrgefühl-Feedback reicht Freitext: Fahrzeug, Situation, was sich falsch anfühlt.

## 5. Bedienung der ersten testbaren Version (v0.1)

Steuerung (alle Tasten unter **Einstellungen → Tastenbelegung → FiveM** umlegbar):

| Taste | Funktion |
|---|---|
| **G** | Motor starten / abstellen (Start nur in Leerlauf/P oder mit gedrückter Kupplung) |
| **Linke Alt** (halten) | Kupplung |
| **Linke Shift** | Hochschalten (Automatik: Wählhebel P → R → N → D) |
| **Linke Strg** | Runterschalten (Automatik: D → N → R → P) |
| **F10** | Telemetrie-Overlay ein/aus |
| W / S | Gas / Bremse wie gewohnt (das Spiel steuert weiterhin Lenkung und Bremsen) |

Wichtig für den ersten Test:

1. Beim Einsteigen ist der Motor **aus**. Kupplung halten (Alt) oder Leerlauf, dann **G**.
2. Handschalter: Kupplung halten, Shift für den 1. Gang, Gas geben und die Kupplung langsam
   kommen lassen (Alt loslassen; der Pedalweg dauert 0,25 s). Ohne Gas bei geschlossener
   Kupplung würgt der Motor ab.
3. Automatik: Shift bis **D**, dann Gas. In **P** bewegt sich nichts.
4. Mit `/wrp_measure` eine Messfahrt starten: aus dem Stand Vollgas bis 100 km/h, dann voll
   bremsen. Ergebnis erscheint im Overlay und landet im Messlog.

Fahrzeuge mit Datenblatt (F10, Vanilla → Vorbild): `blista` (Honda Civic Si 2006, 6MT),
`futo` (Toyota AE86 1985, 5MT), `sultan` (Subaru WRX STI 2004, 6MT AWD),
`dominator` (Ford Mustang GT 2011, 6MT RWD), `premier` (Toyota Camry 2007, 5AT).
Alle anderen Modelle fahren mit einem **Klassen-Fallback** (Overlay zeigt „FALLBACK“).

### Kommandos

| Kommando | Zweck |
|---|---|
| `/wrp_telemetry` | Overlay ein/aus (F10) |
| `/wrp_measure` / `/wrp_measure vmax` | Messfahrt 0–100 + Bremsweg / Höchstgeschwindigkeit |
| `/wrp_coupling power\|force\|hybrid` | Kopplungsstrategie live wechseln (Spike S1/S2) |
| `/wrp_spec` | Datenblatt des aktuellen Fahrzeugs ausgeben |
| `/wrp_handling` | GTA-Handling-Werte und Spielzustand (rpm, Gang, Kupplung) |
| `/wrp_material` | Untergrundmaterial je Rad einblenden (Spike S8) |
| `/wrp_net` | Netzwerk-Owner und State Bag des Fahrzeugs (Spike S3) |
| `/wrp_scale` | Referenzstrecken für den Welt-Maßstab (Spike S9) |
| `wrp_status` (Konsole) | Kernstatus |
| `wrp_specs` (Konsole) | Liste der Datenblätter |

## 6. Was in v0.1 bewusst noch nicht drin ist

Reifenmodell, Fahrwerk, Bremsen, Aero-Kräfte in der Spielphysik, Schaden, Verschleiß, Wetter.
Diese Version dient dazu, die **Kopplung Simulation ↔ Spiel** (Spikes S1–S3) zu bewerten und das
erste Fahrgefühl (Motor, Kupplung, Getriebe, Verbrauch) zu beurteilen.
