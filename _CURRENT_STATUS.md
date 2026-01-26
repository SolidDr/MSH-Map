# MSH Map - Aktueller Stand
**Datum:** 2026-01-26
**Status:** Bereit für nächstes Addon

## Zuletzt abgeschlossene Arbeiten

### 1. Welcome Overlay nach goldenem Schnitt optimiert
**Datei:** `lib/src/shared/widgets/welcome_overlay.dart`

- Layout nach goldenem Schnitt mit harmonischen Abständen (6px, 12px, 24px, 39px)
- Features in 2×2 Grid statt vertikaler Liste für kompakteres Design
- Maximale Breite 480px für bessere Zentrierung
- Alle Inhalte zentriert ausgerichtet
- Kleinere, ausgewogene Icon- und Schriftgrößen

### 2. AppShell im Router integriert
**Datei:** `lib/src/core/router/app_router.dart`

- Responsive Navigation Shell über `ShellRoute` integriert
- About-Seite (`/about`) ist jetzt über Navigation erreichbar
- Desktop: Sidebar mit Logo, Navigation, Footer (Privacy + Powered By Badge)
- Tablet: NavigationRail
- Mobile: Bottom NavigationBar
- Login/Upload-Routes bleiben ohne Shell (standalone)

### 3. Trackpad Pinch-Zoom aktiviert
**Datei:** `lib/src/shared/widgets/msh_map_view.dart`

- `InteractiveFlag.all` aktiviert alle Interaktionen:
  - Trackpad Pinch-to-Zoom ✓
  - Mausrad-Zoom ✓
  - Touch-Pinch-Zoom ✓
  - Drag zum Verschieben ✓

### 4. Layer Switcher (Pin-Ausblenden)
**Status:** Korrekt implementiert

- Layer Switcher ruft `onLayerChanged: _loadItems` auf
- `_loadItems()` lädt nur Items aus aktiven Modulen
- Filter-Integration über `filterProvider` aktiv
- **Hinweis:** Funktionalität muss noch im laufenden System getestet werden

## Aktive Features

✅ Filter-System über Riverpod (`filter_provider.dart`)
✅ Category Quick Filter Bar (8 Kategorien)
✅ Welcome Overlay mit SharedPreferences
✅ Privacy Badge mit Bottom Sheet
✅ Responsive Navigation (Mobile/Tablet/Desktop)
✅ Modul-basierte Architektur (Family, Gastro, Events)

## Bekannte Einschränkungen

- Layer Switcher: Funktionalität noch nicht live getestet (Callback ist verbunden)
- About-Seite: Routing funktioniert, aber Navigation-Index-Synchronisation könnte verbessert werden
- Pinch-Zoom: Trackpad-Zoom sollte mit `InteractiveFlag.all` funktionieren, muss aber auf echtem Gerät getestet werden

## Code-Qualität

- **Fehler:** 0
- **Warnungen:** 0
- **Info (Linting):** 75 (nur kosmetische Hinweise)

## Nächste Schritte

Bereit für nächstes Addon.

---

## Dateistruktur (Wichtigste Änderungen)

```
lib/
├── app.dart (WelcomeOverlay integriert)
├── src/
│   ├── core/
│   │   ├── router/app_router.dart (ShellRoute mit AppShell)
│   │   ├── shell/app_shell.dart (Responsive Navigation)
│   │   └── providers/filter_provider.dart (Filter-State)
│   ├── shared/
│   │   └── widgets/
│   │       ├── welcome_overlay.dart (Golden Ratio Layout)
│   │       ├── privacy_badge.dart
│   │       ├── category_quick_filter.dart
│   │       └── msh_map_view.dart (Pinch-Zoom)
│   └── home_screen.dart (Filter + Layer Switcher Integration)
```
