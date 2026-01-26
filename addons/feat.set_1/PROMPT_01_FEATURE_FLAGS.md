# PROMPT 1: Feature-Flag System

## Kontext

Du arbeitest am MSH Map Projekt - einer Flutter Web App für die Region Mansfeld-Südharz.
Das Projekt verwendet:
- Flutter Web
- flutter_map (OpenStreetMap)
- flutter_riverpod (State Management)
- go_router (Navigation)

## Deine Aufgabe

Implementiere ein Feature-Flag System, das es ermöglicht Features ein- und auszuschalten OHNE die UI anzupassen.

## Schritt 1: Feature-Flags Datei erstellen

Erstelle `lib/src/core/config/feature_flags.dart`:

```dart
/// Feature-Flags für MSH Map
/// 
/// Hier können Features ein/ausgeschaltet werden ohne UI-Änderungen.
/// true = Feature aktiv, false = Feature versteckt
class FeatureFlags {
  FeatureFlags._(); // Keine Instanzierung
  
  // ═══════════════════════════════════════════════════════════════
  // CORE FEATURES
  // ═══════════════════════════════════════════════════════════════
  
  /// Interaktive Karte mit Markern
  static const bool enableMap = true;
  
  /// Fog of War Effekt am Kartenrand (außerhalb MSH)
  static const bool enableFogOfWar = true;
  
  /// Kategorien-Filter auf der Karte
  static const bool enableCategoryFilter = true;
  
  /// Suchfunktion
  static const bool enableSearch = true;
  
  // ═══════════════════════════════════════════════════════════════
  // FAMILY FEATURES
  // ═══════════════════════════════════════════════════════════════
  
  /// Altersgerechte Empfehlungen (Kinder-Alter Filter)
  static const bool enableAgeFilter = true;
  
  /// Wetter-Integration mit Indoor/Outdoor Empfehlungen
  static const bool enableWeather = true;
  
  /// "Perfekt für deine Familie" Badges
  static const bool enableFamilyBadges = true;
  
  // ═══════════════════════════════════════════════════════════════
  // EVENTS & AKTUALITÄT
  // ═══════════════════════════════════════════════════════════════
  
  /// Veranstaltungen auf der Karte anzeigen
  static const bool enableEventsOnMap = true;
  
  /// "Diese Woche" Events Widget auf Startseite
  static const bool enableEventsWidget = true;
  
  /// Hinweise/Warnungen Banner (Sperrungen, etc.)
  static const bool enableNoticesBanner = true;
  
  /// Prognose "Wird es voll?" 
  static const bool enableCrowdPrediction = false;
  
  // ═══════════════════════════════════════════════════════════════
  // MOBILITÄT
  // ═══════════════════════════════════════════════════════════════
  
  /// ÖPNV-Verbindungen Link bei Orten
  static const bool enablePublicTransport = true;
  
  /// E-Ladesäulen als Layer auf der Karte
  static const bool enableChargingStations = true;
  
  /// Offline-Karten Download
  static const bool enableOfflineMaps = false;
  
  // ═══════════════════════════════════════════════════════════════
  // KARTEN-LAYER
  // ═══════════════════════════════════════════════════════════════
  
  /// Naturschutzgebiete Layer
  static const bool enableNatureProtectionLayer = true;
  
  /// Heatmap-Ansicht (Beliebtheit)
  static const bool enableHeatmapLayer = false;
  
  /// Layer-Auswahl UI
  static const bool enableLayerSwitcher = true;
  
  // ═══════════════════════════════════════════════════════════════
  // COMMUNITY & FEEDBACK
  // ═══════════════════════════════════════════════════════════════
  
  /// "Fehlt etwas?" - Ort vorschlagen
  static const bool enableSuggestLocation = true;
  
  /// "Problem melden" - Gefahren/Issues melden
  static const bool enableReportIssue = true;
  
  /// Anonyme Bewertungen (1-5 Sterne)
  static const bool enableRatings = false;
  
  /// "Ich war da" Check-ins
  static const bool enableCheckIns = false;
  
  /// Foto-Uploads von Nutzern
  static const bool enablePhotoUploads = false;
  
  // ═══════════════════════════════════════════════════════════════
  // MARKTPLATZ
  // ═══════════════════════════════════════════════════════════════
  
  /// Flohmarkt/Marketplace Modul
  static const bool enableMarketplace = true;
  
  /// Eigene Anzeige erstellen (sonst nur ansehen)
  static const bool enableMarketplaceCreate = true;
  
  // ═══════════════════════════════════════════════════════════════
  // DASHBOARD & ANALYTICS
  // ═══════════════════════════════════════════════════════════════
  
  /// "MSH in Zahlen" Dashboard
  static const bool enableDashboard = true;
  
  /// Infrastruktur-Lücken anzeigen
  static const bool enableGapAnalysis = true;
  
  /// Automatische Insights
  static const bool enableInsights = true;
  
  // ═══════════════════════════════════════════════════════════════
  // DEVELOPMENT & DEBUG
  // ═══════════════════════════════════════════════════════════════
  
  /// Debug-Overlay mit Extra-Infos
  static const bool enableDebugMode = false;
  
  /// Beta-Banner anzeigen
  static const bool showBetaBanner = false;
  
  /// Mock-Daten statt Firebase verwenden
  static const bool useMockData = true;
}
```

## Schritt 2: Feature-Flag Widget erstellen

Erstelle `lib/src/shared/widgets/feature_flag_wrapper.dart`:

```dart
import 'package:flutter/widgets.dart';

/// Widget das seinen Child nur anzeigt wenn das Feature aktiviert ist
class FeatureFlag extends StatelessWidget {
  final bool isEnabled;
  final Widget child;
  final Widget? fallback;
  
  const FeatureFlag({
    super.key,
    required this.isEnabled,
    required this.child,
    this.fallback,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isEnabled) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

/// Extension für einfachere Verwendung
extension FeatureFlagExtension on Widget {
  Widget withFeatureFlag(bool isEnabled, {Widget? fallback}) {
    return FeatureFlag(
      isEnabled: isEnabled,
      fallback: fallback,
      child: this,
    );
  }
}
```

## Schritt 3: Beispiel-Verwendung dokumentieren

Erstelle `lib/src/core/config/README_FEATURE_FLAGS.md`:

```markdown
# Feature-Flags Verwendung

## In Widgets

```dart
// Option 1: FeatureFlag Widget
FeatureFlag(
  isEnabled: FeatureFlags.enableWeather,
  child: WeatherWidget(),
)

// Option 2: Extension
WeatherWidget().withFeatureFlag(FeatureFlags.enableWeather)

// Option 3: Inline if
if (FeatureFlags.enableWeather) WeatherWidget(),

// Mit Fallback
FeatureFlag(
  isEnabled: FeatureFlags.enableWeather,
  child: WeatherWidget(),
  fallback: Text('Wetter-Feature kommt bald!'),
)
```

## In Listen (z.B. Sidebar)

```dart
final menuItems = [
  MenuItem('Karte', '/map', Icons.map),
  if (FeatureFlags.enableMarketplace)
    MenuItem('Flohmarkt', '/marketplace', Icons.store),
  if (FeatureFlags.enableDashboard)
    MenuItem('MSH in Zahlen', '/dashboard', Icons.analytics),
];
```

## In Routes

```dart
final routes = [
  GoRoute(path: '/', builder: (_, __) => HomeScreen()),
  GoRoute(path: '/map', builder: (_, __) => MapScreen()),
  if (FeatureFlags.enableMarketplace)
    GoRoute(path: '/marketplace', builder: (_, __) => MarketplaceScreen()),
  if (FeatureFlags.enableDashboard)
    GoRoute(path: '/dashboard', builder: (_, __) => DashboardScreen()),
];
```

## Feature ein/ausschalten

1. Öffne `lib/src/core/config/feature_flags.dart`
2. Ändere `true` zu `false` (oder umgekehrt)
3. Hot Reload / Rebuild

Keine weiteren Änderungen nötig!
```

## Schritt 4: Bestehenden Code anpassen

Suche im Projekt nach Stellen wo Features verwendet werden und wrapp sie mit FeatureFlags.

Beispiele:

### In der Sidebar/Navigation:
```dart
// VORHER:
ListTile(title: Text('Flohmarkt'), onTap: () => context.go('/marketplace')),

// NACHHER:
if (FeatureFlags.enableMarketplace)
  ListTile(title: Text('Flohmarkt'), onTap: () => context.go('/marketplace')),
```

### In der Map:
```dart
// VORHER:
FogOfWarLayer(),

// NACHHER:
if (FeatureFlags.enableFogOfWar) FogOfWarLayer(),
```

### Im Router:
```dart
// Alle optionalen Routes mit if wrappen
```

## Abschluss

Nach Fertigstellung:
- [ ] `feature_flags.dart` erstellt
- [ ] `feature_flag_wrapper.dart` erstellt
- [ ] README dokumentiert
- [ ] Mindestens 3 bestehende Features mit Flags gewrappt
- [ ] App startet ohne Fehler
- [ ] Feature kann durch Flag-Änderung versteckt werden

Zeige mir dann eine Zusammenfassung was du gemacht hast.
