/// Riverpod Providers für ÖPNV-Daten
/// State Management für Haltestellen und Abfahrten
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../data/transit_api_service.dart';
import '../data/transit_repository.dart';
import '../domain/departure.dart';
import '../domain/transit_stop.dart';

// ═══════════════════════════════════════════════════════════════
// SERVICE & REPOSITORY PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// Transit API Service Provider
final transitApiProvider = Provider<TransitApiService>((ref) {
  final service = TransitApiService();
  ref.onDispose(service.dispose);
  return service;
});

/// Transit Repository Provider
final transitRepositoryProvider = Provider<TransitRepository>((ref) {
  final api = ref.watch(transitApiProvider);
  final repository = TransitRepository(api);
  ref.onDispose(repository.dispose);
  return repository;
});

// ═══════════════════════════════════════════════════════════════
// LOCATION PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// MSH Zentrum als Fallback (Sangerhausen)
const _mshCenterLat = 51.4667;
const _mshCenterLng = 11.3000;

/// Status für Location Provider
enum LocationStatus {
  userLocation,     // Echter Standort
  fallbackLocation, // Fallback auf MSH-Zentrum
  error,           // Fehler
}

/// Ergebnis des Location Providers mit Status
class LocationResult {
  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.status,
    this.errorMessage,
  });

  final double latitude;
  final double longitude;
  final LocationStatus status;
  final String? errorMessage;

  /// Fallback-Location für MSH
  static const fallback = LocationResult(
    latitude: _mshCenterLat,
    longitude: _mshCenterLng,
    status: LocationStatus.fallbackLocation,
  );
}

/// Benutzerstandort für ÖPNV-Suche mit Fallback
/// Gibt immer einen Standort zurück (User-Location oder MSH-Zentrum)
final transitLocationProvider =
    FutureProvider.autoDispose<LocationResult>((ref) async {
  try {
    // Prüfe ob Location-Service aktiviert ist
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('TransitLocation: Location service disabled - using fallback');
      return const LocationResult(
        latitude: _mshCenterLat,
        longitude: _mshCenterLng,
        status: LocationStatus.fallbackLocation,
        errorMessage: 'Standortdienst deaktiviert',
      );
    }

    // Prüfe Berechtigungen
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('TransitLocation: Permission denied - using fallback');
        return const LocationResult(
          latitude: _mshCenterLat,
          longitude: _mshCenterLng,
          status: LocationStatus.fallbackLocation,
          errorMessage: 'Standortzugriff verweigert',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('TransitLocation: Permission denied forever - using fallback');
      return const LocationResult(
        latitude: _mshCenterLat,
        longitude: _mshCenterLng,
        status: LocationStatus.fallbackLocation,
        errorMessage: 'Standortzugriff dauerhaft verweigert',
      );
    }

    // Position abrufen
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    ).timeout(const Duration(seconds: 10));

    debugPrint(
      'TransitLocation: Got position ${position.latitude}, ${position.longitude}',
    );
    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      status: LocationStatus.userLocation,
    );
  } on Exception catch (e) {
    debugPrint('TransitLocation: Error getting location: $e - using fallback');
    return const LocationResult(
      latitude: _mshCenterLat,
      longitude: _mshCenterLng,
      status: LocationStatus.fallbackLocation,
      errorMessage: 'Standort konnte nicht ermittelt werden',
    );
  }
});

// ═══════════════════════════════════════════════════════════════
// STOPS PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// Haltestellen in der Nähe des Benutzers
final nearbyStopsProvider =
    FutureProvider.autoDispose<List<TransitStop>>((ref) async {
  final locationResult = await ref.watch(transitLocationProvider.future);

  final repository = ref.watch(transitRepositoryProvider);
  return repository.getNearbyStops(
    locationResult.latitude,
    locationResult.longitude,
  );
});

/// Haltestellen für einen bestimmten Standort
final stopsAtLocationProvider = FutureProvider.autoDispose
    .family<List<TransitStop>, (double, double)>((ref, location) async {
  final repository = ref.watch(transitRepositoryProvider);
  return repository.getNearbyStops(location.$1, location.$2);
});

/// Haltestellensuche nach Name (für Autocomplete)
final searchLocationsProvider = FutureProvider.autoDispose
    .family<List<TransitStop>, String>((ref, query) async {
  if (query.length < 2) return [];

  final api = ref.watch(transitApiProvider);
  return api.searchLocations(query: query);
});

// ═══════════════════════════════════════════════════════════════
// DEPARTURES PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// Abfahrten für eine bestimmte Haltestelle (einmalig)
final departuresProvider =
    FutureProvider.autoDispose.family<List<Departure>, String>((
  ref,
  stopId,
) async {
  final repository = ref.watch(transitRepositoryProvider);
  return repository.getDepartures(stopId);
});

/// Abfahrten mit Auto-Refresh (alle 60 Sekunden)
final departuresAutoRefreshProvider =
    StreamProvider.autoDispose.family<List<Departure>, String>((
  ref,
  stopId,
) async* {
  final repository = ref.read(transitRepositoryProvider);

  // Initial laden
  try {
    final initial = await repository.getDepartures(stopId);
    yield initial;
  } on Exception catch (e) {
    debugPrint('DeparturesAutoRefresh: Initial fetch failed: $e');
    yield [];
  }

  // Periodisch aktualisieren
  await for (final _ in Stream<void>.periodic(const Duration(seconds: 60))) {
    try {
      // Cache invalidieren für frische Daten
      repository.invalidateDepartures(stopId);
      final departures = await repository.getDepartures(stopId);
      yield departures;
      debugPrint('DeparturesAutoRefresh: Refreshed ${departures.length} items');
    } on Exception catch (e) {
      debugPrint('DeparturesAutoRefresh: Refresh failed: $e');
      // Bei Fehler letzte Daten behalten (kein yield)
    }
  }
});

// ═══════════════════════════════════════════════════════════════
// HELPER PROVIDERS (Riverpod 3.x)
// ═══════════════════════════════════════════════════════════════

/// Notifier für Refresh-Counter
class StopsRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

/// Manueller Refresh-Trigger für Haltestellen
final stopsRefreshProvider = NotifierProvider<StopsRefreshNotifier, int>(
  StopsRefreshNotifier.new,
);

/// Haltestellen mit manuellem Refresh
final nearbyStopsWithRefreshProvider =
    FutureProvider.autoDispose<List<TransitStop>>((ref) async {
  // Watch refresh trigger
  ref.watch(stopsRefreshProvider);

  final locationResult = await ref.watch(transitLocationProvider.future);

  final repository = ref.watch(transitRepositoryProvider);

  // Cache leeren bei manuellem Refresh
  repository.clearCache();

  return repository.getNearbyStops(
    locationResult.latitude,
    locationResult.longitude,
  );
});

/// Trigger für manuellen Refresh
void refreshNearbyStops(WidgetRef ref) {
  ref.read(stopsRefreshProvider.notifier).increment();
}
