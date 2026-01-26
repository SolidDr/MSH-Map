# GeoJSON Service - Verwendung

## Übersicht

Der `GeoJsonService` ermöglicht das Laden von GeoJSON-Daten aus Assets und deren Konvertierung in ein App-internes Format.

## Datenquelle

Die Seed-Daten stammen aus dem **MSH DeepScan System** und enthalten:
- 58 manuell kuratierte Locations (Seed-Daten)
- Europa-Rosarium, Schlösser, Museen, Spielplätze, etc.
- Vollständige Metadaten (Öffnungszeiten, Preise, Barrierefreiheit)

## Verwendung

### 1. Seed-Locations laden

```dart
import 'package:msh_map/src/core/services/geojson_service.dart';

// Lädt alle Seed-Locations aus GeoJSON
final locations = await GeoJsonService.loadSeedLocations();

// locations ist eine List<Map<String, dynamic>> mit:
// - id, name, displayName
// - latitude, longitude
// - category, city, address
// - description, tags, etc.
```

### 2. Statistiken anzeigen

```dart
final stats = await GeoJsonService.getStatistics(
  'lib/assets/data/msh_seed_locations.geojson'
);

print('Total: ${stats['total']}');
print('Categories: ${stats['categories']}');
print('Cities: ${stats['cities']}');
```

### 3. In Riverpod Provider verwenden

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
Future<List<Poi>> seedLocations(SeedLocationsRef ref) async {
  final rawData = await GeoJsonService.loadSeedLocations();

  return rawData.map((data) => Poi.fromJson(data)).toList();
}
```

## Datenformat

### Input (GeoJSON)
```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [11.2936, 51.4731]
      },
      "properties": {
        "id": "europa-rosarium-sangerhausen",
        "name": "Europa-Rosarium",
        "category": "nature",
        ...
      }
    }
  ]
}
```

### Output (Dart Map)
```dart
{
  "id": "europa-rosarium-sangerhausen",
  "name": "Europa-Rosarium",
  "displayName": "Europa-Rosarium Sangerhausen",
  "category": "nature",
  "latitude": 51.4731,
  "longitude": 11.2936,
  "city": "Sangerhausen",
  "address": "Steinberger Weg 3, 06526 Sangerhausen",
  "description": "...",
  "tags": ["rose", "garten", "unesco"],
  "accessibility": "rollstuhlgerecht",
  "parking": true
}
```

## Performance

- **Caching**: Die Daten werden beim ersten Laden gecached
- **Asset-based**: Keine Netzwerk-Requests, instant verfügbar
- **File Size**: ~48 KB (58 Locations)

## Erweiterung

Weitere GeoJSON-Dateien können hinzugefügt werden:

1. **In pubspec.yaml registrieren:**
```yaml
flutter:
  assets:
    - lib/assets/data/my_new_data.geojson
```

2. **Laden:**
```dart
final locations = await GeoJsonService.loadLocationsFromGeoJson(
  'lib/assets/data/my_new_data.geojson'
);
```

## DeepScan Integration

Die Seed-Daten können jederzeit aktualisiert werden:

```bash
# 1. DeepScan ausführen
cd deepscan
python deepscan_main.py --seed

# 2. GeoJSON kopieren
cp output/merged/msh_complete_*.geojson ../lib/assets/data/msh_seed_locations.geojson

# 3. App neu starten (Hot Restart für Asset-Änderungen)
```

## Zukünftige Erweiterungen

- **OSM-Daten**: 7.134 zusätzliche Locations aus OpenStreetMap
- **Wikidata**: 455 Burgen & Schlösser
- **Live-Updates**: Firestore-Integration für Echtzeit-Daten
- **Offline-First**: GeoJSON als Fallback, Firestore für aktuelle Daten
