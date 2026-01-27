import 'dart:convert';
import 'package:flutter/services.dart';

/// Service für das Laden von GeoJSON-Daten aus Assets
///
/// Unterstützt das GeoJSON FeatureCollection Format:
/// {
///   "type": "FeatureCollection",
///   "features": [
///     {
///       "type": "Feature",
///       "geometry": {"type": "Point", "coordinates": [lon, lat]},
///       "properties": {...}
///     }
///   ]
/// }
class GeoJsonService {
  static Map<String, dynamic>? _cachedGeoJson;

  /// Lädt GeoJSON aus Assets
  static Future<Map<String, dynamic>> loadGeoJson(String assetPath) async {
    if (_cachedGeoJson != null) return _cachedGeoJson!;

    final jsonString = await rootBundle.loadString(assetPath);
    _cachedGeoJson = jsonDecode(jsonString) as Map<String, dynamic>;

    return _cachedGeoJson!;
  }

  /// Konvertiert GeoJSON FeatureCollection zu Location-List
  ///
  /// Extrahiert Koordinaten aus geometry und Properties aus properties
  static Future<List<Map<String, dynamic>>> loadLocationsFromGeoJson(
    String assetPath,
  ) async {
    final geoJson = await loadGeoJson(assetPath);

    if (geoJson['type'] != 'FeatureCollection') {
      throw const FormatException('Invalid GeoJSON: Expected FeatureCollection');
    }

    final features = geoJson['features'] as List<dynamic>;
    final locations = <Map<String, dynamic>>[];

    for (final feature in features) {
      if (feature['type'] != 'Feature') continue;

      final geometry = feature['geometry'] as Map<String, dynamic>;
      final properties = feature['properties'] as Map<String, dynamic>;

      // Extrahiere Koordinaten
      if (geometry['type'] == 'Point') {
        final coordinates = geometry['coordinates'] as List<dynamic>;
        final lon = coordinates[0] as double;
        final lat = coordinates[1] as double;

        // Erstelle Location-Objekt
        final location = {
          ...properties,
          'latitude': lat,
          'longitude': lon,
        };

        locations.add(location);
      }
    }

    return locations;
  }

  /// Lädt Seed-Locations aus GeoJSON Asset
  static Future<List<Map<String, dynamic>>> loadSeedLocations() async {
    return loadLocationsFromGeoJson('lib/assets/data/msh_seed_locations.geojson');
  }

  /// Cache zurücksetzen
  static void clearCache() {
    _cachedGeoJson = null;
  }

  /// Gibt Statistiken über die geladenen Daten zurück
  static Future<Map<String, dynamic>> getStatistics(String assetPath) async {
    final locations = await loadLocationsFromGeoJson(assetPath);

    // Kategorie-Verteilung
    final categories = <String, int>{};
    final cities = <String, int>{};

    for (final loc in locations) {
      final category = loc['category'] as String? ?? 'other';
      final city = loc['city'] as String? ?? 'Unbekannt';

      categories[category] = (categories[category] ?? 0) + 1;
      cities[city] = (cities[city] ?? 0) + 1;
    }

    return {
      'total': locations.length,
      'categories': categories,
      'cities': cities,
    };
  }
}
