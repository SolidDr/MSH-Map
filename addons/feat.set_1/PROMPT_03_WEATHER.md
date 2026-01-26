# PROMPT 3: Wetter-Integration

## Kontext

Du arbeitest am MSH Map Projekt. 
Feature-Flags und Altersfilter sind bereits implementiert.
`FeatureFlags.enableWeather` ist auf `true` gesetzt.

## Deine Aufgabe

Implementiere eine Wetter-Integration mit Open-Meteo (kostenlos, kein API-Key, DSGVO-konform).

## Anforderungen

1. Aktuelles Wetter für MSH anzeigen
2. Automatische Empfehlung: Indoor bei Regen, Outdoor bei Sonne
3. Wetter-Widget auf der Startseite
4. Keine externen Tracker, kein API-Key nötig

## Schritt 1: Wetter-Model erstellen

Erstelle `lib/src/features/weather/domain/weather_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_model.freezed.dart';
part 'weather_model.g.dart';

@freezed
class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    required double temperature,
    required int weatherCode,
    required double windSpeed,
    required bool isDay,
    required DateTime time,
  }) = _CurrentWeather;
  
  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

/// Wetter-Codes nach WMO Standard
/// https://open-meteo.com/en/docs
enum WeatherCondition {
  clearSky(0, 'Klar', '☀️', true),
  mainlyClear(1, 'Überwiegend klar', '🌤️', true),
  partlyCloudy(2, 'Teilweise bewölkt', '⛅', true),
  overcast(3, 'Bewölkt', '☁️', true),
  fog(45, 'Nebel', '🌫️', false),
  depositingRimeFog(48, 'Nebel mit Reif', '🌫️', false),
  drizzleLight(51, 'Leichter Nieselregen', '🌧️', false),
  drizzleModerate(53, 'Nieselregen', '🌧️', false),
  drizzleDense(55, 'Starker Nieselregen', '🌧️', false),
  freezingDrizzle(56, 'Gefrierender Nieselregen', '🌧️', false),
  freezingDrizzleDense(57, 'Starker gefr. Nieselregen', '🌧️', false),
  rainSlight(61, 'Leichter Regen', '🌧️', false),
  rainModerate(63, 'Regen', '🌧️', false),
  rainHeavy(65, 'Starker Regen', '🌧️', false),
  freezingRain(66, 'Gefrierender Regen', '🌧️', false),
  freezingRainHeavy(67, 'Starker gefr. Regen', '🌧️', false),
  snowSlight(71, 'Leichter Schneefall', '🌨️', false),
  snowModerate(73, 'Schneefall', '🌨️', false),
  snowHeavy(75, 'Starker Schneefall', '🌨️', false),
  snowGrains(77, 'Schneegriesel', '🌨️', false),
  showersSlight(80, 'Leichte Schauer', '🌦️', false),
  showersModerate(81, 'Schauer', '🌦️', false),
  showersViolent(82, 'Starke Schauer', '🌦️', false),
  snowShowersSlight(85, 'Leichte Schneeschauer', '🌨️', false),
  snowShowersHeavy(86, 'Starke Schneeschauer', '🌨️', false),
  thunderstorm(95, 'Gewitter', '⛈️', false),
  thunderstormHailSlight(96, 'Gewitter mit Hagel', '⛈️', false),
  thunderstormHailHeavy(99, 'Starkes Gewitter mit Hagel', '⛈️', false),
  unknown(-1, 'Unbekannt', '❓', true);
  
  final int code;
  final String description;
  final String emoji;
  final bool isGoodForOutdoor;
  
  const WeatherCondition(this.code, this.description, this.emoji, this.isGoodForOutdoor);
  
  static WeatherCondition fromCode(int code) {
    return WeatherCondition.values.firstWhere(
      (c) => c.code == code,
      orElse: () => WeatherCondition.unknown,
    );
  }
}

extension CurrentWeatherExtension on CurrentWeather {
  WeatherCondition get condition => WeatherCondition.fromCode(weatherCode);
  
  String get emoji => condition.emoji;
  
  String get description => condition.description;
  
  bool get isGoodForOutdoor => condition.isGoodForOutdoor && temperature > 5;
  
  String get temperatureFormatted => '${temperature.round()}°C';
  
  String get recommendation {
    if (isGoodForOutdoor) {
      if (temperature > 25) {
        return '☀️ Perfektes Badewetter! Ab zum See!';
      } else if (temperature > 15) {
        return '🌳 Ideal für Outdoor-Aktivitäten!';
      } else {
        return '🧥 Warm anziehen, dann raus!';
      }
    } else {
      return '🏠 Indoor-Aktivitäten empfohlen';
    }
  }
}
```

## Schritt 2: Wetter-Repository erstellen

Erstelle `lib/src/features/weather/data/weather_repository.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/weather_model.dart';

class WeatherRepository {
  // MSH Zentrum (Sangerhausen)
  static const double _latitude = 51.4667;
  static const double _longitude = 11.3000;
  
  // Open-Meteo API (kostenlos, kein Key, DSGVO-konform)
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  Future<CurrentWeather> getCurrentWeather() async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$_latitude&longitude=$_longitude'
      '&current_weather=true'
      '&timezone=Europe/Berlin'
    );
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final currentWeather = json['current_weather'];
        
        return CurrentWeather(
          temperature: (currentWeather['temperature'] as num).toDouble(),
          weatherCode: currentWeather['weathercode'] as int,
          windSpeed: (currentWeather['windspeed'] as num).toDouble(),
          isDay: currentWeather['is_day'] == 1,
          time: DateTime.parse(currentWeather['time']),
        );
      } else {
        throw Exception('Wetter konnte nicht geladen werden');
      }
    } catch (e) {
      // Fallback bei Netzwerk-Fehler
      return CurrentWeather(
        temperature: 15,
        weatherCode: 2, // Teilweise bewölkt
        windSpeed: 10,
        isDay: true,
        time: DateTime.now(),
      );
    }
  }
}
```

## Schritt 3: Wetter-Provider

Erstelle `lib/src/features/weather/application/weather_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/weather_repository.dart';
import '../domain/weather_model.dart';

final weatherRepositoryProvider = Provider((ref) => WeatherRepository());

final currentWeatherProvider = FutureProvider<CurrentWeather>((ref) async {
  final repo = ref.watch(weatherRepositoryProvider);
  return repo.getCurrentWeather();
});

/// Empfehlung: Indoor oder Outdoor?
final weatherRecommendationProvider = Provider<String>((ref) {
  final weatherAsync = ref.watch(currentWeatherProvider);
  return weatherAsync.when(
    data: (weather) => weather.recommendation,
    loading: () => '⏳ Wetter wird geladen...',
    error: (_, __) => '❓ Wetter nicht verfügbar',
  );
});

/// Ist es gutes Outdoor-Wetter?
final isOutdoorWeatherProvider = Provider<bool>((ref) {
  final weatherAsync = ref.watch(currentWeatherProvider);
  return weatherAsync.when(
    data: (weather) => weather.isGoodForOutdoor,
    loading: () => true, // Im Zweifel: ja
    error: (_, __) => true,
  );
});
```

## Schritt 4: Wetter-Widget

Erstelle `lib/src/features/weather/presentation/weather_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/weather_provider.dart';
import '../../../core/config/feature_flags.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enableWeather) {
      return const SizedBox.shrink();
    }
    
    final weatherAsync = ref.watch(currentWeatherProvider);
    
    return weatherAsync.when(
      data: (weather) => _WeatherCard(weather: weather),
      loading: () => const _WeatherCardLoading(),
      error: (_, __) => const _WeatherCardError(),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final CurrentWeather weather;
  
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutdoor = weather.isGoodForOutdoor;
    
    return Card(
      color: isOutdoor 
          ? Colors.blue.shade50 
          : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  weather.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wetter in MSH',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        weather.temperatureFormatted,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Beschreibung
            Text(
              weather.description,
              style: theme.textTheme.bodyMedium,
            ),
            
            const Divider(height: 24),
            
            // Empfehlung
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOutdoor 
                    ? Colors.green.shade50 
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isOutdoor ? Icons.wb_sunny : Icons.home,
                    color: isOutdoor ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      weather.recommendation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCardLoading extends StatelessWidget {
  const _WeatherCardLoading();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Wetter wird geladen...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCardError extends StatelessWidget {
  const _WeatherCardError();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey),
            SizedBox(width: 12),
            Text('Wetter nicht verfügbar'),
          ],
        ),
      ),
    );
  }
}
```

## Schritt 5: Kompaktes Wetter-Badge für Header

Erstelle `lib/src/features/weather/presentation/weather_badge.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/weather_provider.dart';
import '../../../core/config/feature_flags.dart';

/// Kleines Badge für AppBar oder Header
class WeatherBadge extends ConsumerWidget {
  const WeatherBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enableWeather) {
      return const SizedBox.shrink();
    }
    
    final weatherAsync = ref.watch(currentWeatherProvider);
    
    return weatherAsync.when(
      data: (weather) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(weather.emoji),
            const SizedBox(width: 4),
            Text(
              weather.temperatureFormatted,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

## Schritt 6: HTTP Package hinzufügen

In `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
```

Dann: `flutter pub get`

## Schritt 7: In Startseite einbauen

Auf der Home-Screen oder Map-Screen:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Wetter-Widget (wenn Feature aktiv)
        if (FeatureFlags.enableWeather)
          const Padding(
            padding: EdgeInsets.all(16),
            child: WeatherWidget(),
          ),
        
        // Rest der UI...
      ],
    ),
  );
}
```

Oder in der AppBar:

```dart
AppBar(
  title: Text('MSH Map'),
  actions: [
    if (FeatureFlags.enableWeather)
      const Padding(
        padding: EdgeInsets.only(right: 8),
        child: WeatherBadge(),
      ),
  ],
)
```

## Schritt 8: Freezed generieren

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Abschluss

Nach Fertigstellung:
- [ ] WeatherModel mit allen WMO Codes
- [ ] WeatherRepository mit Open-Meteo API
- [ ] Provider für State Management
- [ ] WeatherWidget (große Karte)
- [ ] WeatherBadge (kompakt für Header)
- [ ] http Package hinzugefügt
- [ ] Freezed generiert
- [ ] Feature-Flag integriert
- [ ] Empfehlung Indoor/Outdoor funktioniert

Teste:
1. App starten
2. Wetter-Widget zeigt aktuelles Wetter
3. Empfehlung passt zum Wetter (Regen → Indoor)
4. Badge in AppBar zeigt Temperatur

Zeige mir eine Zusammenfassung.
