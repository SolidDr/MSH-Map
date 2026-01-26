import 'dart:convert';
import 'package:flutter/services.dart';

/// Service für das Laden und Caching von Location-Daten aus Assets
class LocationsService {
  static List<Map<String, dynamic>>? _cachedLocations;

  /// Lädt alle Locations aus assets/data/locations.json
  static Future<List<Map<String, dynamic>>> loadLocations() async {
    if (_cachedLocations != null) return _cachedLocations!;

    final jsonString = await rootBundle.loadString('lib/assets/data/locations.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;

    _cachedLocations = data.cast<Map<String, dynamic>>();
    return _cachedLocations!;
  }

  /// Gibt gecachte Locations zurück oder lädt sie neu
  static Future<List<Map<String, dynamic>>> getLocations() async {
    return _cachedLocations ?? await loadLocations();
  }

  /// Filtert Locations nach Stadt
  static Future<List<Map<String, dynamic>>> getLocationsByCity(String city) async {
    final locations = await getLocations();
    return locations.where((loc) => loc['city'] == city).toList();
  }

  /// Filtert Locations nach Kategorie
  static Future<List<Map<String, dynamic>>> getLocationsByCategory(String category) async {
    final locations = await getLocations();
    return locations.where((loc) => loc['category'] == category).toList();
  }

  /// Gibt Metadaten zurück
  static Future<Map<String, dynamic>> getMetadata() async {
    final jsonString = await rootBundle.loadString('lib/assets/data/locations.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return json['meta'] as Map<String, dynamic>;
  }

  /// Cache zurücksetzen
  static void clearCache() {
    _cachedLocations = null;
  }
}
