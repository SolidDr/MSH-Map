# MSH Map Migration - Übersicht

## Projekt-Transformation: Lunch-Radar → MSH Map

**Ausgangspunkt:** Lunch-Radar MVP (Phase 4 - Firestore funktioniert)
**Ziel:** Modulare Regionalplattform für Mansfeld-Südharz

---

## 🎯 FOKUS: Familien mit Kindern

Die **ersten Punkte auf der Karte** sind Familienaktivitäten:
- 🛝 Spielplätze
- 🏛️ Kinderfreundliche Museen
- 🌲 Natur & Parks
- 🏰 Burgen & Schlösser
- 🏊 Badeseen & Schwimmbäder

Gastronomie wird als **zweites Modul** integriert.

---

## Dokumenten-Struktur

| Datei | Inhalt |
|-------|--------|
| `00_OVERVIEW.md` | Diese Übersicht |
| `01_ARCHITECTURE.md` | Ziel-Architektur & Ordnerstruktur |
| `02_CORE_INTERFACES.md` | MapItem, MshModule, Registry (Code) |
| `03_PHASE_A_INFRASTRUCTURE.md` | Phase A: Basis-Setup |
| `04_PHASE_B_MAP_WIDGETS.md` | Phase B: Karten-Komponenten |
| `05_PHASE_C_GASTRO_MODULE.md` | Phase C: Gastro-Migration |
| `06_PHASE_D_APP_SHELL.md` | Phase D: App-Integration |
| `07_PHASE_E_CLEANUP.md` | Phase E: Stubs & Aufräumen |
| `08_CHECKPOINT_TEMPLATE.md` | Neue Checkpoint-Datei |
| **`scraping/`** | **Daten-Sammlung** |
| `scraping/msh_scraper.py` | Python Scraper |
| `scraping/09_SCRAPING_GUIDE.md` | Scraping-Anleitung |

---

## Kernprinzipien

1. **KEIN Code löschen** - nur verschieben nach `_deprecated/`
2. **Nach jedem Schritt:** `flutter analyze` muss durchlaufen
3. **Checkpoint aktualisieren** nach jedem erledigten Task
4. **Bei Fehlern STOPPEN** und dokumentieren

---

## Quick-Start für Claude Code

```
Lies zuerst alle Dateien in dieser Reihenfolge:
1. 00_OVERVIEW.md (diese Datei)
2. 01_ARCHITECTURE.md
3. 02_CORE_INTERFACES.md

PARALLEL: Seed-Daten erstellen:
4. scraping/09_SCRAPING_GUIDE.md
5. python scraping/msh_scraper.py --seed

Dann Flutter-Migration:
6. 03_PHASE_A_INFRASTRUCTURE.md
```

---

## Neue Dependencies (pubspec.yaml)

```yaml
# Hinzufügen zu bestehenden dependencies:
flutter_map: ^6.1.0
latlong2: ^0.9.0
geolocator: ^11.0.0
```

---

## MSH-Region Koordinaten

- **Zentrum:** 51.4667°N, 11.3000°E (Sangerhausen)
- **Bounding Box:** 51.25-51.75°N, 10.75-11.85°E
- **Default Zoom:** 11.0

---

## Modul-Priorität

| Prio | Modul | Status | Beschreibung |
|------|-------|--------|--------------|
| **P0** | **Family** | NEU | Spielplätze, Museen, Natur - ERSTE Punkte! |
| P1 | Gastro | Migration | Restaurants (ehemals Lunch-Radar) |
| P2 | Events | Stub | Veranstaltungen (später) |
| P3 | Search | Stub | Regionale Suche (später) |