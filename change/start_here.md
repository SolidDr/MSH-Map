# START HERE: MSH Map Migration

## Für Claude Code in VS Code

Du führst die Migration von "Lunch-Radar" zu "MSH Map" durch.

---

## 🎯 PROJEKT-FOKUS

**MSH Map ist eine Familienplattform!**

Die **ERSTEN Punkte auf der Karte** sollen sein:
- 🛝 Spielplätze
- 🏛️ Kinderfreundliche Museen  
- 🌲 Naturerlebnisse (Seen, Parks, Wanderwege)
- 🏰 Burgen & Schlösser
- 🎢 Freizeitaktivitäten

Gastronomie (das ursprüngliche Lunch-Radar) wird als **zweites Modul** integriert.

---

## ZWEI PARALLELE AUFGABEN

### Aufgabe 1: App-Migration (Flutter)
Die technische Umstrukturierung der App.

### Aufgabe 2: Daten-Sammlung (Python)
Parallel Daten für die Karte sammeln.

**Empfehlung:** Mit den Seed-Daten starten, damit sofort etwas auf der Karte ist!

---

## SCHRITT 1: Dokumentation lesen

```
msh_migration/00_OVERVIEW.md           # Übersicht
msh_migration/01_ARCHITECTURE.md       # Zielstruktur  
msh_migration/02_CORE_INTERFACES.md    # Code-Vorlagen
msh_migration/scraping/09_SCRAPING_GUIDE.md  # Daten-Sammlung
```

---

## SCHRITT 2: Seed-Daten erstellen (SOFORT)

```bash
cd msh_migration/scraping
python msh_scraper.py --seed
```

**Ergebnis:** `msh_data_seed.json` mit verifizierten Familienaktivitäten:
- Rosarium Sangerhausen
- Luthers Geburtshaus (UNESCO)
- Süßer See
- Wippertalsperre
- Schloss Mansfeld

Diese Daten können **sofort** in Firestore importiert werden!

---

## SCHRITT 3: Aktuellen Flutter-Stand prüfen

```bash
find lib -name "*.dart" -type f | head -30
cat pubspec.yaml
```

---

## SCHRITT 4: Checkpoint einrichten

Kopiere `08_CHECKPOINT_TEMPLATE.md` nach `_DEV_CHECKPOINT.md` im Projekt-Root.

---

## SCHRITT 5: Mit Phase A beginnen

Öffne `03_PHASE_A_INFRASTRUCTURE.md` und arbeite Schritt für Schritt ab.

---

## WICHTIGE REGELN

1. **KEIN Code löschen** - nur nach `_deprecated/` verschieben
2. **Nach JEDEM Schritt:** `flutter analyze` ausführen
3. **Checkpoint aktualisieren** nach jedem Task
4. **Bei Fehlern:** STOPPEN, dokumentieren, auf Anweisung warten
5. **Nicht überspringen:** Phasen der Reihe nach abarbeiten

---

## PHASEN-ÜBERSICHT

| Phase | Datei | Inhalt |
|-------|-------|--------|
| A | `03_PHASE_A_INFRASTRUCTURE.md` | Ordner, Interfaces |
| B | `04_PHASE_B_MAP_WIDGETS.md` | Karte, UI |
| C | `05_PHASE_C_GASTRO_MODULE.md` | Restaurant-Modul |
| D | `06_PHASE_D_APP_SHELL.md` | App-Integration |
| E | `07_PHASE_E_CLEANUP.md` | Stubs, Aufräumen |

**NEU:** `scraping/09_SCRAPING_GUIDE.md` - Daten-Sammlung

---

## MODULE PRIORITÄT

| Modul | Priorität | Status | Erste Daten |
|-------|-----------|--------|-------------|
| **Family** | P0 🎯 | NEU | Seed-Data vorhanden! |
| Gastro | P1 | Migration | Aus Lunch-Radar |
| Events | P2 | Stub | Später |
| Search | P3 | Stub | Später |

---

## NEUE FIRESTORE COLLECTION

Für Familienaktivitäten eine neue Collection anlegen:

```
Collection: family_activities
Document: {
  id: string
  name: string
  category: string (playground|museum|nature|zoo|castle|...)
  description: string
  location: GeoPoint
  city: string
  age_range: string (0-3|3-6|6-12|alle)
  is_free: boolean
  is_outdoor: boolean
  is_indoor: boolean
  tags: array
  source_url: string
}
```

---

## START-BEFEHL

```
Ich möchte die Migration von Lunch-Radar zu MSH Map durchführen.

FOKUS: Familienaktivitäten als erste Punkte auf der Karte!

1. Erstelle zuerst die Seed-Daten (Python-Script)
2. Dann beginne mit der Flutter-Migration Phase A

Zeige mir den aktuellen Dateistand.
```