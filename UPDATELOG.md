# MSH Map - Updatelog

## Änderungen seit Commit `2e522cf` (last commit before ui overhaul)

**Zeitraum:** Januar 2026
**Status:** In Entwicklung (uncommitted)

---

### Neue Module & Features

#### Gesundheit (`lib/src/modules/health/`)
- Komplettes Gesundheitsmodul mit Ärzten, Apotheken, Fitness
- Notfall-Bereich mit 112, 116117, Notdienst-Apotheke
- Suchfunktion und Kategorie-Filter
- Detailansicht für Einrichtungen
- Datenbasis: `assets/data/health/`

#### Mobilität (`lib/src/features/mobility/`)
- ÖPNV-Screen (vorbereitet für v6.db.transport.rest API)
- Sharing-Optionen (E-Scooter, Carsharing) als Coming Soon

#### Profil (`lib/src/features/profile/`)
- Einstellungen-Screen
- Barrierefreiheit, Datenschutz, Über die App
- Coming Soon Hinweise für nicht implementierte Features

#### Entdecken (`lib/src/features/discover/`)
- Neue Entdecken-Ansicht

#### Impressum (`lib/src/features/about/presentation/impressum_screen.dart`)
- Rechtliche Informationen

---

### UI/UX Verbesserungen

#### Theme-System
- `msh_spacing.dart` - Konsistente Abstände (xs, sm, md, lg, xl, xxl)
- `msh_colors.dart` - Erweiterte Farbpalette für Kategorien
- `msh_theme.dart` - Golden Ratio basierte Proportionen

#### Neue Shared Widgets
- `msh_bottom_sheet.dart` - Einheitliche Bottom Sheets
- `msh_category_card.dart` - Kategorie-Karten
- `msh_engagement_card.dart` - Engagement-Karten
- `msh_filter_drawer.dart` - Filter-Drawer
- `msh_timeline_card.dart` - Timeline-Karten
- `reviews_section.dart` - Bewertungen
- `search_autocomplete.dart` - Such-Autocomplete

#### Navigation
- ESC-Taste für Zurück-Navigation (global)
- Gesundheit in Desktop-Seitenleiste integriert
- Verbesserte Shell-Struktur für Mobile/Tablet/Desktop

---

### Bugfixes

#### Phase 2.3 - Detailkacheln Positionierung
- Bottom Sheets waren auf Web-Ansichten zu niedrig
- Adaptive Sizing basierend auf Viewport-Höhe
- MaxWidth-Constraint (600px) für Desktop

#### Phase 2.4 - Nicht-funktionale Buttons
- Profile Screen: 10 leere onTap-Handler ersetzt
- Mobility Screen: Sharing Cards zeigen "Demnächst"
- Bestätigungsdialog für "Daten löschen"

#### Phase 2.5 - ESC-Navigation
- KeyboardListener in AppShell
- Prioritäten: canPop() → pop(), sonst → '/'

---

### Plattform-Support

- `android/` - Android-Konfiguration
- `ios/` - iOS-Konfiguration
- `linux/` - Linux-Desktop
- `macos/` - macOS-Desktop

---

### Tools (Development)

- `fix_missing_pois.dart`
- `geocode_pois.dart`
- `poi_corrections.dart`
- `sync_pois_to_firebase.dart`
- `update_coords_web.dart`
- `update_poi_coords.dart`
- `verify_pois.dart`

---

### Dateistatistik

| Kategorie | Anzahl |
|-----------|--------|
| Geänderte Dateien | ~65 |
| Neue Dateien | ~40 |
| Neue Module | 4 |
| Neue Widgets | 8 |

---

### Noch offen (Phase 3)

- [ ] 3.2: Up Next Events Widget
- [ ] 3.3: Welcomescreen Update (Module-Status)
- [ ] 3.4: Lunch-Radar Hinweis
- [ ] 3.5: Profil-Bereich Login Coming Soon
