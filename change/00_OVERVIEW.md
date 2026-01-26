# MSH Map Migration - Übersicht

## Projekt-Transformation: Lunch-Radar → MSH Map

**Ausgangspunkt:** Lunch-Radar MVP (Phase 4 - Firestore funktioniert)
**Ziel:** Modulare Regionalplattform für Mansfeld-Südharz

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

Dann starte mit:
4. 03_PHASE_A_INFRASTRUCTURE.md

Arbeite Phase für Phase ab. NICHT überspringen!
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
