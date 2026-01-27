# MSH Map - UI Design Overhaul

> **Ziel:** Komplette Neugestaltung der UI mit Fokus auf Informationsarchitektur, goldenen Schnitt, visuelle Hierarchie und klare Gruppierung.

**Version:** 1.0
**Datum:** 2026-01-26
**Status:** 📋 Planung

---

## 📐 Design-Prinzipien

### 1. Goldener Schnitt & Proportionen
```
Verhältnis: 1:1.618 (φ)

Anwendung in der App:
- Content-Bereich zu Sidebar: 1.618:1 (Desktop)
- Card-Höhe zu Breite: ~0.618:1
- Header zu Content in Sheets: 1:1.618
- Spacing-Hierarchie: 8px → 13px → 21px → 34px → 55px (Fibonacci)
```

### 2. Whitespace & Breathing Room
```
Minimale Touch-Targets: 48px × 48px
Card-Spacing: 21px (statt 8px/16px gemischt)
Section-Spacing: 34px (klare Trennung)
Screen-Padding: 21px horizontal, 13px vertikal
```

### 3. Visuelle Hierarchie
```
Ebene 1: Primäre Aktion (FAB, CTA-Buttons)
Ebene 2: Navigation & Filter (AppBar, Chips)
Ebene 3: Content (Cards, Listen)
Ebene 4: Meta-Info (Timestamps, Badges)
```

### 4. Informationsgruppierung
```
Prinzip: Maximal 3-5 Items pro Gruppe
Subsektionen statt Überfüllung
Progressive Disclosure (Details on Demand)
```

---

## 🔍 Analyse: Aktuelle UI-Probleme

### HomeScreen - Überlagerung & Clutter
```
❌ Probleme:
- 7+ UI-Elemente übereinander (Banner, Search, 2× Filter, Counter, 3× FABs)
- Category + Age Filter beide horizontal scrollbar → verwirrend
- 3 FABs gleichzeitig → unklar welche primär ist
- POI Counter + Analytics Button in Ecke → leicht zu übersehen
- Keine klare visuelle Gruppierung

✅ Lösung:
- Konsolidierung in Tabs/Sections
- Maximal 1 primärer FAB
- Filter in Drawer/Sheet auslagern
- Map als Fokus (80% Viewport)
```

### Navigation - Inkonsistente Struktur
```
❌ Probleme:
- "Mehr"-Tab ist Catch-All ohne klare Struktur
- Engagement-Feature nicht in Navigation sichtbar
- Search-Modul registriert aber keine eigene Route
- ÖPNV/Mobilität Features versteckt

✅ Lösung:
- 5 Hauptkategorien statt 4
  1. Karte (Zentral)
  2. Entdecken (POIs gruppiert)
  3. Erleben (Events + Engagement)
  4. Mobilität (ÖPNV + Ladesäulen)
  5. Profil (Settings, About, Feedback)
```

### Filter & Kategorien - Zu flach
```
❌ Probleme:
- Alle Family-Kategorien auf einer Ebene (9 Chips)
- Keine Subsektionen (Natur, Indoor, Outdoor)
- Age Filter nur bei Family → sollte globaler sein

✅ Lösung:
- Hierarchische Filter:
  └─ Familie
     ├─ Indoor (Museum, Pool, Adventure)
     ├─ Outdoor (Playground, Zoo, Farm, Nature)
     └─ Kultur (Castle)
- Age Filter global sichtbar bei relevanten POIs
```

### Bottom Sheets - Inkonsistent
```
❌ Probleme:
- POI Sheet: DraggableScrollableSheet
- Event Sheet: Anderer Style
- Engagement Sheet: Wieder anderer Style
- Unterschiedliche Header, Buttons, Spacing

✅ Lösung:
- Einheitliche Sheet-Komponente (MshBottomSheet)
- Konsistente Sections: Header → Details → Actions
- Wiederverwendbare Widgets
```

### Engagement - Zu versteckt
```
❌ Probleme:
- Feature Flag enableEngagementWidget = false (standardmäßig)
- Nur auf Map als Layer sichtbar
- Kein dedizierter Screen
- Urgency-Marker nicht prominent

✅ Lösung:
- Eigener "Helfen & Engagieren" Tab
- Dashboard mit dringenden Bedarfen
- Filter nach: Tierheime, Soziales, Ehrenamt, Blutspende
- Integration mit Events ("Helfer-Events")
```

---

## 🎨 Neue UI-Architektur

### 1. Navigation & Information Architecture

```
┌─────────────────────────────────────────┐
│  MSH Map - Hauptnavigation (5 Tabs)    │
├─────────────────────────────────────────┤
│                                         │
│  1️⃣ KARTE                               │
│     └─ Hauptansicht (Map + Filter)     │
│     └─ Layer Switcher                   │
│     └─ Search                           │
│                                         │
│  2️⃣ ENTDECKEN                           │
│     ├─ 🎡 Familie & Freizeit            │
│     │  ├─ Indoor (Museum, Pool, etc.)   │
│     │  ├─ Outdoor (Spielplatz, Zoo)     │
│     │  └─ Kultur (Burgen, Schlösser)    │
│     │                                   │
│     ├─ 🍴 Gastronomie                   │
│     │  ├─ Restaurants                   │
│     │  ├─ Cafés & Bars                  │
│     │  └─ Regional & Bio                │
│     │                                   │
│     └─ 🏛️ Sehenswürdigkeiten            │
│        ├─ Historisch                    │
│        ├─ Natur & Wandern               │
│        └─ Aussichtspunkte               │
│                                         │
│  3️⃣ ERLEBEN                             │
│     ├─ 📅 Veranstaltungen               │
│     │  ├─ Diese Woche                   │
│     │  ├─ Dieses Wochenende             │
│     │  └─ Nach Kategorie                │
│     │                                   │
│     └─ ❤️ Helfen & Engagieren           │
│        ├─ Dringende Bedarfe             │
│        ├─ Tierheime & Adoption          │
│        ├─ Soziale Einrichtungen         │
│        └─ Ehrenamt & Blutspende         │
│                                         │
│  4️⃣ MOBILITÄT                           │
│     ├─ 🚌 ÖPNV & Verbindungen           │
│     ├─ 🚗 Parkplätze                    │
│     ├─ ⚡ E-Ladesäulen                  │
│     └─ 🚲 Fahrrad & Verleih             │
│                                         │
│  5️⃣ PROFIL                              │
│     ├─ ⚙️ Einstellungen                 │
│     ├─ 🎨 Darstellung & Themes          │
│     ├─ ♿ Barrierefreiheit              │
│     ├─ 💬 Feedback & Ort vorschlagen    │
│     └─ ℹ️ Über die App                  │
│                                         │
└─────────────────────────────────────────┘
```

### 2. HomeScreen - Neu strukturiert

#### Layout (Goldener Schnitt)
```
┌─────────────────────────────────────────┐
│  🗺️ AppBar (56px)                       │ ← Ebene 2
│  [Logo]  MSH Map  [Search] [Profile]   │
├─────────────────────────────────────────┤
│                                         │
│                                         │
│           MAP VIEW (80%)                │ ← Ebene 3 (Fokus)
│       φ = 1.618 height ratio            │
│                                         │
│                                         │
│          [Marker] [Marker]              │
│              [Marker]                   │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│  🏷️ Quick Filters (20%)                 │ ← Ebene 2
│  [Chip] [Chip] [Chip] [...]            │
│                                         │
│  📍 145 Orte gefunden                   │ ← Ebene 4 (Meta)
├─────────────────────────────────────────┤
│  [🎯 Filter]  🗺️  🎡  🍴  👤            │ ← Ebene 1 (Nav)
└─────────────────────────────────────────┘

Einziger FAB: 🎯 Filter Drawer (primäre Aktion)
```

#### Komponenten-Hierarchie
```dart
Stack(
  children: [
    // Background - Ebene 3 (80% Viewport)
    MshMapView(
      items: filteredItems,
      showFogOfWar: true,
    ),

    // Top Bar - Ebene 2
    Positioned(
      top: 0,
      child: SearchBar(compact: true),
    ),

    // Bottom Content Card - Ebene 2 (20% Viewport)
    DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.08,  // Nur Counter sichtbar
      maxChildSize: 0.6,   // Filter expandiert
      child: BottomContentCard(
        sections: [
          FilterChipsSection(),
          NearbyPoisSection(),
          UpcomingEventsSection(),
        ],
      ),
    ),

    // FAB - Ebene 1 (Primär)
    Positioned(
      bottom: 90,
      right: 21,
      child: FloatingActionButton(
        onPressed: _openFilterDrawer,
        child: Icon(Icons.tune),
      ),
    ),
  ],
)
```

### 3. Filter Drawer - Hierarchisch & Gruppiert

```
┌─────────────────────────────────────────┐
│  🎯 Filter & Kategorien                 │
├─────────────────────────────────────────┤
│                                         │
│  🎡 FAMILIE & FREIZEIT                  │ ← Gruppe 1
│  ┌─────────────────────────────────┐   │
│  │ 🏠 Indoor                        │   │
│  │  ☐ Museum & Ausstellung         │   │
│  │  ☐ Schwimmbad & Therme          │   │
│  │  ☐ Indoor-Spielplatz             │   │
│  │                                  │   │
│  │ 🌳 Outdoor                       │   │
│  │  ☐ Spielplatz                   │   │
│  │  ☐ Zoo & Tierpark               │   │
│  │  ☐ Bauernhof                    │   │
│  │  ☐ Natur & Wandern              │   │
│  │                                  │   │
│  │ 🏰 Kultur                        │   │
│  │  ☐ Burg & Schloss               │   │
│  └─────────────────────────────────┘   │
│                                         │
│  👶 Altersgruppen                       │
│  [0-3] [3-6] [6-12] [12+] [Alle]       │
│                                         │
│  ─────────────────────────────────────  │ ← Divider (34px)
│                                         │
│  🍴 GASTRONOMIE                         │ ← Gruppe 2
│  ┌─────────────────────────────────┐   │
│  │  ☐ Restaurant                    │   │
│  │  ☐ Café & Bar                    │   │
│  │  ☐ Imbiss & Fastfood             │   │
│  │  ☐ Regional & Bioprodukte        │   │
│  └─────────────────────────────────┘   │
│                                         │
│  🍽️ Besonderheiten                     │
│  [Vegetarisch] [Vegan] [Halal]         │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ❤️ HELFEN & ENGAGIEREN                 │ ← Gruppe 3
│  ┌─────────────────────────────────┐   │
│  │  ☐ Tierheim & Tierschutz         │   │
│  │  ☐ Soziale Einrichtungen         │   │
│  │  ☐ Ehrenamt & Vereine            │   │
│  │  ☐ Blutspende                    │   │
│  └─────────────────────────────────┘   │
│                                         │
│  🚨 Dringlichkeit                       │
│  [Kritisch] [Dringend] [Erhöht]        │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  [Zurücksetzen]    [Filter anwenden]   │ ← Actions
│                                         │
└─────────────────────────────────────────┘

Spacing:
- Section-Titel: 34px margin-top (goldener Schnitt)
- Checkbox-Items: 13px padding vertical
- Chips: 8px gap horizontal
- Buttons: 21px padding
```

### 4. Entdecken Screen - Kategorisiert

```
┌─────────────────────────────────────────┐
│  🎡 Entdecken                           │
├─────────────────────────────────────────┤
│  [Suche...]                🗺️           │ ← Search + Map Toggle
├─────────────────────────────────────────┤
│                                         │
│  🎡 Familie & Freizeit                  │ ← Card 1 (Ratio 1.618:1)
│  ┌───────────────────────────────────┐ │
│  │  📸 [Hero Image]                  │ │
│  │                                   │ │
│  │  145 Orte • Für Familien          │ │ ← Meta
│  │                                   │ │
│  │  [Indoor] [Outdoor] [Kultur] →   │ │ ← Sub-Nav
│  └───────────────────────────────────┘ │
│                                         │ ← 34px spacing
│  🍴 Gastronomie                         │ ← Card 2
│  ┌───────────────────────────────────┐ │
│  │  📸 [Hero Image]                  │ │
│  │                                   │ │
│  │  87 Restaurants • Regional        │ │
│  │                                   │ │
│  │  [Restaurant] [Café] [Regional] →│ │
│  └───────────────────────────────────┘ │
│                                         │
│  🏛️ Sehenswürdigkeiten                 │ ← Card 3
│  ┌───────────────────────────────────┐ │
│  │  📸 [Hero Image]                  │ │
│  │                                   │ │
│  │  23 Orte • Historisch & Natur     │ │
│  │                                   │ │
│  │  [Historisch] [Natur] [Aussicht]→│ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

### 5. Erleben Screen - Events & Engagement

```
┌─────────────────────────────────────────┐
│  📅 Erleben                             │
├─────────────────────────────────────────┤
│  [Diese Woche] [Wochenende] [Monat]    │ ← Tab Bar
├─────────────────────────────────────────┤
│                                         │
│  📅 VERANSTALTUNGEN                     │
│  ┌───────────────────────────────────┐ │
│  │  Fr, 31. Jan • 19:00 Uhr          │ │ ← Timeline
│  │  🎵 Konzert im Rosarium            │ │
│  │  Sangerhausen                      │ │
│  │                     [Details →]    │ │
│  ├───────────────────────────────────┤ │
│  │  Sa, 01. Feb • 14:00 Uhr          │ │
│  │  🎨 Kunstmarkt Lutherstadt         │ │
│  │  Eisleben                          │ │
│  │                     [Details →]    │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ─────────────────────────────────────  │ ← Divider (34px)
│                                         │
│  ❤️ HELFEN & ENGAGIEREN                 │
│  ┌───────────────────────────────────┐ │
│  │  🚨 DRINGEND                       │ │ ← Urgency Badge
│  │  🐾 Tierheim Sangerhausen          │ │
│  │  Gassigeher dringend gesucht       │ │
│  │  Blutgruppen 0- und AB- benötigt  │ │
│  │                      [Helfen →]    │ │
│  ├───────────────────────────────────┤ │
│  │  🏥 DRK Blutspende                 │ │
│  │  Nächster Termin: Mo, 03. Feb     │ │
│  │                     [Termin →]     │ │
│  └───────────────────────────────────┘ │
│                                         │
│  [🎯 Alle Engagement-Orte anzeigen]    │ ← CTA
│                                         │
└─────────────────────────────────────────┘
```

### 6. Mobilität Screen - ÖPNV & Infrastruktur

```
┌─────────────────────────────────────────┐
│  🚌 Mobilität                           │
├─────────────────────────────────────────┤
│  [ÖPNV] [Parken] [Laden] [Fahrrad]    │ ← Tab Bar
├─────────────────────────────────────────┤
│                                         │
│  🚌 ÖPNV & VERBINDUNGEN                 │
│  ┌───────────────────────────────────┐ │
│  │  Von: [Sangerhausen HBF]     🎯   │ │ ← GPS Button
│  │  Nach: [Eisleben Markt]      🔍   │ │ ← Search
│  │                                   │ │
│  │  [Jetzt] [Abfahrt] [Ankunft]     │ │ ← Time Filter
│  │                                   │ │
│  │  ─────────────────────────────    │ │
│  │  Nächste Verbindungen:            │ │
│  │                                   │ │
│  │  🚌 14:35 → 15:12 (37 Min)        │ │
│  │     Bus 280 → Bus 340             │ │
│  │     [Details] [Tickets]           │ │
│  │                                   │ │
│  │  🚂 15:05 → 15:48 (43 Min)        │ │
│  │     RB nach Halle → Bus 340       │ │
│  │     [Details] [Tickets]           │ │
│  └───────────────────────────────────┘ │
│                                         │
│  🚏 Haltestellen in der Nähe            │
│  ┌───────────────────────────────────┐ │
│  │  📍 Sangerhausen, Bahnhof (50m)   │ │
│  │     280, 340, RB                  │ │
│  │                        [Karte →]  │ │
│  │  📍 Rosenweg (320m)               │ │
│  │     280, 285                      │ │
│  │                        [Karte →]  │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

### 7. Profil Screen - Settings & Über

```
┌─────────────────────────────────────────┐
│  👤 Profil                              │
├─────────────────────────────────────────┤
│                                         │
│  ⚙️ EINSTELLUNGEN                       │
│  ┌───────────────────────────────────┐ │
│  │  🎨 Darstellung                    │ │
│  │     Hell • Dunkel • Automatisch   │ │
│  │                                   │ │
│  │  ♿ Barrierefreiheit               │ │
│  │     Hoher Kontrast • Schriftgröße│ │
│  │                                   │ │
│  │  🗺️ Karten-Einstellungen          │ │
│  │     Layer • Zoom • Fog of War     │ │
│  │                                   │ │
│  │  🔔 Benachrichtigungen            │ │
│  │     Events • Engagement • Updates │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  💬 FEEDBACK & COMMUNITY                │
│  ┌───────────────────────────────────┐ │
│  │  📍 Ort vorschlagen                │ │
│  │  🐛 Problem melden                 │ │
│  │  ⭐ App bewerten                   │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ℹ️ ÜBER DIE APP                        │
│  ┌───────────────────────────────────┐ │
│  │  MSH Map v1.0.0                   │ │
│  │  Regionale Plattform für          │ │
│  │  Mansfeld-Südharz                 │ │
│  │                                   │ │
│  │  [GitHub] [Datenschutz] [Lizenz] │ │
│  │                                   │ │
│  │  Powered by OpenStreetMap         │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🎨 Theme Updates - Goldener Schnitt & Spacing

### Neue Spacing-Konstanten (Fibonacci)
```dart
// lib/src/core/theme/msh_spacing.dart

class MshSpacing {
  // Fibonacci Sequence für harmonische Proportionen
  static const double xs = 5.0;     // Fibonacci 5
  static const double sm = 8.0;     // Fibonacci 8
  static const double md = 13.0;    // Fibonacci 13 (neu)
  static const double lg = 21.0;    // Fibonacci 21 (neu)
  static const double xl = 34.0;    // Fibonacci 34 (neu)
  static const double xxl = 55.0;   // Fibonacci 55 (neu)

  // Goldener Schnitt Ratios
  static const double phi = 1.618;
  static const double phiInverse = 0.618;

  // Anwendungen
  static double goldenRatio(double base) => base * phi;
  static double goldenInverse(double base) => base * phiInverse;
}
```

### Card Proportionen
```dart
// Ratio 1.618:1 für alle Cards
class MshCard extends StatelessWidget {
  static const double aspectRatio = 1.618;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Card(
        margin: EdgeInsets.all(MshSpacing.lg), // 21px
        child: Padding(
          padding: EdgeInsets.all(MshSpacing.md), // 13px
          child: content,
        ),
      ),
    );
  }
}
```

---

## 📦 Neue Komponenten (Übersicht)

### 1. MshBottomSheet - Einheitliche Sheets
Ersetzt: POI Sheet, Event Sheet, Engagement Sheet
Features: Draggable, Konsistentes Layout, Goldener Schnitt Header:Content

### 2. MshCategoryCard - Gruppierte Kategorien
Für: Entdecken Screen
Features: AspectRatio 1.618:1, Hero Images, Subcategories

### 3. MshFilterDrawer - Hierarchische Filter
Ersetzt: Category Quick Filter, Age Filter Row
Features: Gruppierung, Subsektionen, Progressive Disclosure

### 4. MshTimelineCard - Events mit Timeline
Für: Erleben Screen
Features: DateTime Indicator, Consistent Layout, CTA

### 5. MshEngagementCard - Urgency-basierte Cards
Für: Erleben Screen, Engagement Tab
Features: Urgency-Badge, Visual Hierarchy, Elevated bei Critical

---

## 📋 Implementierungsplan

### Phase 1: Foundation (Theme & Spacing)
**Dateien:** 3 Dateien
1. [lib/src/core/theme/msh_spacing.dart](../../lib/src/core/theme/msh_spacing.dart) (NEU)
2. [lib/src/core/theme/msh_colors.dart](../../lib/src/core/theme/msh_colors.dart) (UPDATE)
3. [lib/src/core/theme/msh_theme.dart](../../lib/src/core/theme/msh_theme.dart) (UPDATE)

**Aufgaben:**
- Fibonacci-Spacing System
- Goldenen Schnitt Ratios
- Color Hierarchy (4 Abstufungen)
- Typography mit Line Height 1.618

---

### Phase 2: Basis-Komponenten
**Dateien:** 5 neue Komponenten
1. [lib/src/shared/widgets/msh_bottom_sheet.dart](../../lib/src/shared/widgets/msh_bottom_sheet.dart) (NEU)
2. [lib/src/shared/widgets/msh_category_card.dart](../../lib/src/shared/widgets/msh_category_card.dart) (NEU)
3. [lib/src/shared/widgets/msh_filter_drawer.dart](../../lib/src/shared/widgets/msh_filter_drawer.dart) (NEU)
4. [lib/src/shared/widgets/msh_timeline_card.dart](../../lib/src/shared/widgets/msh_timeline_card.dart) (NEU)
5. [lib/src/shared/widgets/msh_engagement_card.dart](../../lib/src/shared/widgets/msh_engagement_card.dart) (NEU)

---

### Phase 3: Navigation Update (5 Tabs)
**Dateien:** 4 Dateien (2 Updates, 2 NEU)
1. [lib/src/core/shell/app_shell.dart](../../lib/src/core/shell/app_shell.dart) (UPDATE)
2. [lib/src/core/router/app_router.dart](../../lib/src/core/router/app_router.dart) (UPDATE)
3. [lib/src/modules/discover/discover_module.dart](../../lib/src/modules/discover/discover_module.dart) (NEU)
4. [lib/src/modules/mobility/mobility_module.dart](../../lib/src/modules/mobility/mobility_module.dart) (NEU)

**Neue Navigation:**
- Karte
- Entdecken (NEU)
- Erleben (Events + Engagement)
- Mobilität (NEU)
- Profil

---

### Phase 4: HomeScreen Redesign
**Dateien:** 3 Dateien
1. [lib/src/home_screen.dart](../../lib/src/home_screen.dart) (MAJOR UPDATE)
2. [lib/src/shared/widgets/bottom_content_card.dart](../../lib/src/shared/widgets/bottom_content_card.dart) (NEU)
3. [lib/src/shared/widgets/msh_map_view.dart](../../lib/src/shared/widgets/msh_map_view.dart) (UPDATE)

**Änderungen:**
- 80/20 Ratio (Map vs. Content)
- Filter in Drawer ausgelagert
- Nur 1 FAB (Filter)
- DraggableScrollableSheet für Bottom Content

---

### Phase 5: Filter Hierarchie & Gruppierung
**Dateien:** 4 Dateien
1. [lib/src/core/providers/filter_provider.dart](../../lib/src/core/providers/filter_provider.dart) (UPDATE)
2. [lib/src/core/models/filter_model.dart](../../lib/src/core/models/filter_model.dart) (NEU)
3. [lib/src/modules/family/family_module.dart](../../lib/src/modules/family/family_module.dart) (UPDATE)
4. [lib/src/modules/gastro/gastro_module.dart](../../lib/src/modules/gastro/gastro_module.dart) (UPDATE)

**Neue Hierarchie:**
- Familie: Indoor / Outdoor / Kultur
- Gastro: Restaurant / Café / Regional + Besonderheiten
- Engagement: Tierheim / Sozial / Ehrenamt / Blutspende

---

### Phase 6-12: Weitere Phasen
- Phase 6: Entdecken Screen
- Phase 7: Erleben Screen
- Phase 8: Mobilität Screen
- Phase 9: Profil Screen
- Phase 10: Bottom Sheets Vereinheitlichung
- Phase 11: Responsive Anpassungen
- Phase 12: Polish & Details

---

## 📊 Zusammenfassung

### Geschätzte Dateien Gesamt
- **NEU:** 25+ Dateien
- **UPDATE:** 15+ Dateien
- **GESAMT:** ~40 Dateien

### Priorität
1. 🔴 **Kritisch:** Phase 1-5 (Foundation, Navigation, HomeScreen)
2. 🟠 **Wichtig:** Phase 6-9 (Neue Screens)
3. 🟢 **Nice-to-Have:** Phase 10-12 (Polish)

---

## 🎯 Nächste Schritte

**Möchtest du:**

1. ✅ **Mit Phase 1 starten** (Theme & Spacing Foundation)
2. 📋 **Detaillierten Plan für eine Phase** sehen
3. 🎨 **Visual Mockups/Wireframes** erstellen
4. 🔍 **Einzelne Komponente** zuerst implementieren

**Empfehlung:** Start mit Phase 1 (Theme Foundation), da alle anderen Phasen darauf aufbauen.

---

## 📚 Referenzen

- **Goldener Schnitt:** https://en.wikipedia.org/wiki/Golden_ratio
- **Fibonacci Spacing:** Material Design 3 adaptiert
- **Flutter Best Practices:** https://docs.flutter.dev/ui/layout
- **Accessibility:** WCAG 2.1 AA Standard

---

**Erstellt:** 2026-01-26
**Version:** 1.0
