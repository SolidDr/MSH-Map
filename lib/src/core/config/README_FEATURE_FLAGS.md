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
