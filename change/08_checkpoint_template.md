# MSH Map - Development Checkpoint

## PROJECT: Lunch-Radar → MSH Map Migration

## STATUS: 🟡 IN PROGRESS

---

## MIGRATION OVERVIEW

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| A | Infrastructure & Shared Layer | ⬜ | Ordner, Interfaces |
| B | Shared Widgets & Map | ⬜ | Karte, Layer-Switcher |
| C | Gastro Module Migration | ⬜ | Restaurant, Repository |
| D | Auth Migration & App Shell | ⬜ | HomeScreen, Router |
| E | Stub Modules & Cleanup | ⬜ | Events, Search, Docs |

**Legende:** ⬜ Offen | 🟡 In Arbeit | ✅ Fertig | ❌ Blockiert

---

## CURRENT PHASE: A

## COMPLETED STEPS

| # | Timestamp | Phase | Task | Status |
|---|-----------|-------|------|--------|
| 1 | [DATUM] | - | Migration gestartet | ✅ |

---

## NEXT ACTION

- [ ] Phase A, Schritt A1: Ordnerstruktur anlegen

---

## FILES MOVED TO _deprecated

| Original | Deprecated | Datum |
|----------|------------|-------|
| (noch keine) | | |

---

## BLOCKERS

(keine)

---

## NOTES

- Dokumentation liegt in: `msh_migration/`
- Alte Dateien werden NICHT gelöscht, nur verschoben
- Nach jedem Schritt: `flutter analyze`
- Firebase Collections bleiben unverändert

---

## QUICK COMMANDS

```bash
# Analyse
flutter analyze

# Run
flutter run

# Ordner-Check
find lib/src -type d | head -30

# Deprecated-Inhalt
ls -la lib/_deprecated/
```

---

## DOCUMENTATION FILES

1. `00_OVERVIEW.md` - Übersicht
2. `01_ARCHITECTURE.md` - Ziel-Struktur
3. `02_CORE_INTERFACES.md` - Code-Vorlagen
4. `03_PHASE_A_INFRASTRUCTURE.md` - Phase A
5. `04_PHASE_B_MAP_WIDGETS.md` - Phase B
6. `05_PHASE_C_GASTRO_MODULE.md` - Phase C
7. `06_PHASE_D_APP_SHELL.md` - Phase D
8. `07_PHASE_E_CLEANUP.md` - Phase 