# MSH Map - Development Checkpoint

## PROJECT: Lunch-Radar → MSH Map Migration

## STATUS: MIGRATION COMPLETE

---

## MIGRATION OVERVIEW

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| A | Infrastructure & Shared Layer | DONE | Ordner, Interfaces |
| B | Shared Widgets & Map | DONE | Karte, Layer-Switcher |
| C | Gastro Module Migration | DONE | Restaurant, Repository, Menu Upload |
| D | Auth Migration & App Shell | DONE | HomeScreen, Router, Modul-Registrierung |
| E | Stub Modules & Cleanup | DONE | Events, Search, Docs |

---

## CURRENT PHASE: E - Stub Modules & Cleanup (DONE)

## COMPLETED STEPS

| # | Timestamp | Phase | Task | Status |
|---|-----------|-------|------|--------|
| 1 | 2026-01-26 | - | Lunch-Radar MVP (Phase 4) complete | Done |
| 2 | 2026-01-26 | - | Migration documentation read | Done |
| 3 | 2026-01-26 | - | Seed data created (6 family activities) | Done |
| 4 | 2026-01-26 | - | Checkpoint updated for MSH Map | Done |
| 5 | 2026-01-26 | A | A1: Ordnerstruktur angelegt | Done |
| 6 | 2026-01-26 | A | A2: Dependencies hinzugefügt (flutter_map, latlong2, geolocator) | Done |
| 7 | 2026-01-26 | A | A2: coordinates.dart erstellt | Done |
| 8 | 2026-01-26 | A | A2: bounding_box.dart erstellt | Done |
| 9 | 2026-01-26 | A | A2: map_item.dart erstellt (inkl. Family-Kategorien) | Done |
| 10 | 2026-01-26 | A | A3: _module_registry.dart erstellt | Done |
| 11 | 2026-01-26 | A | A4: map_config.dart erstellt | Done |
| 12 | 2026-01-26 | A | A5: flutter analyze - 0 errors (20 info hints) | Done |
| 13 | 2026-01-26 | B | B2: msh_map_view.dart erstellt | Done |
| 14 | 2026-01-26 | B | B3: layer_switcher.dart erstellt | Done |
| 15 | 2026-01-26 | B | B4: poi_bottom_sheet.dart erstellt | Done |
| 16 | 2026-01-26 | B | B5: common_widgets nach shared/widgets + _deprecated | Done |
| 17 | 2026-01-26 | B | B6: flutter analyze - 0 errors (30 info hints) | Done |
| 18 | 2026-01-26 | C | C1: restaurant.dart erstellt (MapItem impl) | Done |
| 19 | 2026-01-26 | C | C2: gastro_repository.dart erstellt | Done |
| 20 | 2026-01-26 | C | C3: restaurant_detail.dart erstellt | Done |
| 21 | 2026-01-26 | C | C4: gastro_module.dart erstellt | Done |
| 22 | 2026-01-26 | C | C5: dish.dart, menu_repository.dart, upload_controller.dart migriert | Done |
| 23 | 2026-01-26 | C | C5: upload_screen.dart, ocr_preview.dart migriert | Done |
| 24 | 2026-01-26 | C | C6: feed_old, merchant_cockpit_old nach _deprecated | Done |
| 25 | 2026-01-26 | C | C7: flutter analyze - 0 errors (56 info hints) | Done |
| 26 | 2026-01-26 | D | D1: Auth nach features/auth verschoben | Done |
| 27 | 2026-01-26 | D | D2: home_screen.dart erstellt | Done |
| 28 | 2026-01-26 | D | D3: app_router.dart erstellt | Done |
| 29 | 2026-01-26 | D | D4: app.dart aktualisiert (MshMapApp) | Done |
| 30 | 2026-01-26 | D | D5: main.dart mit Modul-Registrierung | Done |
| 31 | 2026-01-26 | D | D6: flutter analyze - 0 errors (61 info hints) | Done |
| 32 | 2026-01-26 | E | E1: EventsModule Stub erstellt | Done |
| 33 | 2026-01-26 | E | E2: SearchModule Stub erstellt | Done |
| 34 | 2026-01-26 | E | E3: Stubs in main.dart registriert | Done |
| 35 | 2026-01-26 | E | E4: pubspec.yaml aktualisiert (msh_map) | Done |
| 36 | 2026-01-26 | E | E5: _deprecated README erstellt | Done |
| 37 | 2026-01-26 | E | E6: flutter analyze - 0 errors (61 info hints) | Done |
| 38 | 2026-01-26 | F | F1: FamilyModule erstellt (Poi domain, Repository, Detail) | Done |
| 39 | 2026-01-26 | F | F2: 38 POIs über web/import.html importiert | Done |
| 40 | 2026-01-26 | F | F3: FamilyModule in main.dart registriert | Done |
| 41 | 2026-01-26 | F | F4: App getestet - alle Marker sichtbar | Done |

---

## NEXT ACTION

- [x] Migration abgeschlossen!
- [x] Seed-Daten in Firestore importieren
- [x] App mit `flutter run` testen
- [ ] Firestore Security Rules aktualisieren

---

## SEED DATA

Datei: `msh_seed_data.json` (38 Einträge - gesamter MSH + Umgebung)
- Sangerhausen: Rosarium, Spengler-Museum, Erlebnisbad, Stadtpark
- Eisleben: Luthers Geburtshaus/Sterbehaus, Röhrigschacht
- Hettstedt: Mansfeld-Museum, Saigertor, Freibad
- Mansfeld: Schloss Mansfeld, Luthers Elternhaus
- Südharz: Stolberg, Josephskreuz, Wippertalsperre, Heimkehle
- Seeland: Süßer See, Concordia See, Schloss Seeburg
- Harz-Rand: Burg Falkenstein, Burg Querfurt, Kyffhäuser, Thale, Pullman City

---

## FILES MOVED TO _deprecated

| Original | Deprecated | Datum |
|----------|------------|-------|
| lib/src/common_widgets/ | lib/_deprecated/common_widgets/ | 2026-01-26 |
| lib/src/features/feed/ | lib/_deprecated/feed_old/ | 2026-01-26 |
| lib/src/features/merchant_cockpit/ | lib/_deprecated/merchant_cockpit_old/ | 2026-01-26 |
| lib/src/features/authentication/ | lib/_deprecated/authentication_old/ | 2026-01-26 |

---

## BLOCKERS

(keine)

---

## NOTES

- Firebase Project: lunch-radar-5d984
- Bundle ID: com.kolan.lunchradar
- Dokumentation liegt in: `change/`
- Alte Dateien werden NICHT gelöscht, nur nach `_deprecated/` verschoben
- Nach jedem Schritt: `flutter analyze`

---

## DEPENDENCIES TO ADD

```yaml
# pubspec.yaml - Hinzufügen:
flutter_map: ^6.1.0
latlong2: ^0.9.0
geolocator: ^11.0.0
```

---

## QUICK COMMANDS

```bash
# Analyse
flutter analyze

# Run
flutter run

# Ordner-Check (Windows)
dir lib\src /s /b /ad

# Build Runner
flutter pub run build_runner build
```
