# 01 - Ziel-Architektur

## Vision: MSH Map

Eine kartenbasierte Regionalplattform. Die interaktive Karte ist der zentrale Entry Point - alle Features sind Layer/Module auf dieser Karte.

## Module (Feature-Layer)

| Modul | Priorität | Beschreibung |
|-------|-----------|--------------|
| **Gastronomie** | P0 | Restaurants, Mittagstische (Migration von Lunch-Radar) |
| **Events** | P1 | Lokale Veranstaltungen (Stub) |
| **Suche** | P2 | Regionale Schnellsuche (Stub) |
| **[Weitere]** | P3 | Architektur erlaubt beliebige Erweiterungen |

---

## Ziel-Ordnerstruktur

```
lib/
├── main.dart
├── app.dart
│
└── src/
    ├── core/                           # ═══ INFRASTRUCTURE ═══
    │   ├── config/
    │   │   ├── app_config.dart
    │   │   └── map_config.dart         # [NEU]
    │   ├── theme/
    │   │   └── msh_theme.dart
    │   ├── router/
    │   │   └── app_router.dart
    │   └── services/
    │       ├── openai_service.dart     # [BEHALTEN]
    │       └── location_service.dart   # [NEU]
    │
    ├── shared/                         # ═══ CROSS-MODULE ═══
    │   ├── domain/
    │   │   ├── map_item.dart           # [NEU] ⭐ KERN-INTERFACE
    │   │   ├── coordinates.dart        # [NEU]
    │   │   └── bounding_box.dart       # [NEU]
    │   ├── data/
    │   │   └── base_repository.dart    # [NEU]
    │   └── widgets/
    │       ├── msh_map_view.dart       # [NEU] ⭐ ZENTRALE KARTE
    │       ├── layer_switcher.dart     # [NEU]
    │       ├── poi_bottom_sheet.dart   # [NEU]
    │       ├── loading_indicator.dart  # [MOVE]
    │       └── error_display.dart      # [MOVE]
    │
    ├── modules/                        # ═══ FEATURE MODULES ═══
    │   ├── _module_registry.dart       # [NEU]
    │   │
    │   ├── gastro/                     # ══ Modul 1 ══
    │   │   ├── gastro_module.dart
    │   │   ├── domain/
    │   │   │   ├── restaurant.dart
    │   │   │   ├── dish.dart           # [MOVE von feed]
    │   │   │   └── menu.dart           # [MOVE von merchant]
    │   │   ├── data/
    │   │   │   └── gastro_repository.dart
    │   │   ├── presentation/
    │   │   │   ├── gastro_layer.dart
    │   │   │   ├── restaurant_detail.dart
    │   │   │   └── menu_upload/
    │   │   │       ├── upload_screen.dart
    │   │   │       └── ocr_preview.dart
    │   │   └── providers/
    │   │       └── gastro_providers.dart
    │   │
    │   ├── events/                     # ══ Modul 2 (Stub) ══
    │   │   ├── events_module.dart
    │   │   └── domain/
    │   │       └── event.dart
    │   │
    │   └── search/                     # ══ Modul 3 (Stub) ══
    │       ├── search_module.dart
    │       └── domain/
    │           └── search_result.dart
    │
    └── features/                       # ═══ NON-MAP FEATURES ═══
        └── auth/                       # [MOVE von authentication]
            ├── data/
            ├── domain/
            └── presentation/
```

---

## Was passiert mit dem alten Code?

| Alt | Neu | Aktion |
|-----|-----|--------|
| `features/feed/` | `modules/gastro/` | MOVE + ADAPT |
| `features/merchant_cockpit/` | `modules/gastro/presentation/menu_upload/` | MOVE |
| `features/authentication/` | `features/auth/` | RENAME |
| `common_widgets/` | `shared/widgets/` | MOVE |
| `core/services/openai_service.dart` | bleibt | BEHALTEN |

---

## Legende

- **[NEU]** = Neue Datei erstellen
- **[MOVE]** = Verschieben (Original nach `_deprecated/`)
- **[ADAPT]** = Verschieben + Anpassen
- **[BEHALTEN]** = Nicht ändern