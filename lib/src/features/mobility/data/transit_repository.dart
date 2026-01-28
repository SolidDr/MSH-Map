/// Transit Repository mit Caching
/// Abstrahiert den API-Zugriff und bietet Offline-Fallback
library;

import 'package:flutter/foundation.dart' show debugPrint;

import '../domain/departure.dart';
import '../domain/transit_stop.dart';
import 'transit_api_service.dart';

/// Repository für ÖPNV-Daten mit Caching
class TransitRepository {
  TransitRepository(this._api);

  final TransitApiService _api;

  // Cache für Haltestellen (länger gültig)
  List<TransitStop>? _nearbyStopsCache;
  (double, double)? _lastStopsLocation;
  DateTime? _stopsLastFetched;
  static const _stopsCacheDuration = Duration(minutes: 5);

  // Cache für Abfahrten (kurz gültig - Echtzeit)
  final Map<String, _DeparturesCache> _departuresCache = {};
  static const _departuresCacheDuration = Duration(seconds: 45);

  /// Haltestellen in der Nähe abrufen
  ///
  /// Nutzt Cache wenn:
  /// - Letzte Abfrage < 5 Minuten her
  /// - Standort sich nicht wesentlich geändert hat (< 100m)
  Future<List<TransitStop>> getNearbyStops(double lat, double lng) async {
    // Cache prüfen
    if (_isCacheValid(lat, lng)) {
      debugPrint('TransitRepository: Using cached stops');
      return _nearbyStopsCache!;
    }

    try {
      final stops = await _api.getNearbyStops(
        latitude: lat,
        longitude: lng,
        distance: 2000, // Max 2km
      );

      // Cache aktualisieren
      _nearbyStopsCache = stops;
      _lastStopsLocation = (lat, lng);
      _stopsLastFetched = DateTime.now();

      debugPrint('TransitRepository: Fetched ${stops.length} stops');
      return stops;
    } catch (e) {
      debugPrint('TransitRepository: Error fetching stops: $e');

      // Fallback zu Cache wenn verfügbar
      if (_nearbyStopsCache != null) {
        debugPrint('TransitRepository: Using stale cache as fallback');
        return _nearbyStopsCache!;
      }

      rethrow;
    }
  }

  bool _isCacheValid(double lat, double lng) {
    if (_nearbyStopsCache == null ||
        _lastStopsLocation == null ||
        _stopsLastFetched == null) {
      return false;
    }

    // Zeitlich abgelaufen?
    if (DateTime.now().difference(_stopsLastFetched!) > _stopsCacheDuration) {
      return false;
    }

    // Standort zu weit entfernt? (> 100m)
    final distance = _calculateDistance(
      _lastStopsLocation!.$1,
      _lastStopsLocation!.$2,
      lat,
      lng,
    );

    return distance < 100;
  }

  /// Einfache Distanzberechnung (Haversine approximation)
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000; // Meter
    final dLat = (lat2 - lat1) * 0.0174533; // Grad zu Radiant
    final dLng = (lng2 - lng1) * 0.0174533;

    final a = (dLat / 2) * (dLat / 2) +
        (lat1 * 0.0174533).abs() *
            (lat2 * 0.0174533).abs() *
            (dLng / 2) *
            (dLng / 2);

    return earthRadius * 2 * a.abs();
  }

  /// Abfahrten für eine Haltestelle abrufen
  ///
  /// Cache: 45 Sekunden (Echtzeit-Daten)
  Future<List<Departure>> getDepartures(String stopId) async {
    // Cache prüfen
    final cached = _departuresCache[stopId];
    if (cached != null && cached.isValid) {
      debugPrint('TransitRepository: Using cached departures for $stopId');
      return cached.departures;
    }

    try {
      final departures = await _api.getDepartures(
        stopId: stopId,
        duration: 60, // Nächste 60 Minuten
        results: 10,
      );

      // Cache aktualisieren
      _departuresCache[stopId] = _DeparturesCache(
        departures: departures,
        fetchedAt: DateTime.now(),
      );

      debugPrint(
        'TransitRepository: Fetched ${departures.length} departures for $stopId',
      );
      return departures;
    } catch (e) {
      debugPrint('TransitRepository: Error fetching departures: $e');

      // Fallback zu Cache (auch wenn abgelaufen)
      if (cached != null) {
        debugPrint('TransitRepository: Using stale departures cache');
        return cached.departures;
      }

      rethrow;
    }
  }

  /// Cache für eine Haltestelle invalidieren
  void invalidateDepartures(String stopId) {
    _departuresCache.remove(stopId);
  }

  /// Alle Caches leeren
  void clearCache() {
    _nearbyStopsCache = null;
    _lastStopsLocation = null;
    _stopsLastFetched = null;
    _departuresCache.clear();
    debugPrint('TransitRepository: Cache cleared');
  }

  /// Ressourcen freigeben
  void dispose() {
    _api.dispose();
  }
}

/// Cache-Eintrag für Abfahrten
class _DeparturesCache {
  _DeparturesCache({
    required this.departures,
    required this.fetchedAt,
  });

  final List<Departure> departures;
  final DateTime fetchedAt;

  bool get isValid =>
      DateTime.now().difference(fetchedAt) <
      TransitRepository._departuresCacheDuration;
}
