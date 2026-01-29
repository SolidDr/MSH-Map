import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/popularity_service.dart';

/// Provider für den Popularity Service
final popularityServiceProvider = Provider<PopularityService>((ref) {
  return PopularityService();
});

/// Stream Provider für alle beliebten POIs mit ihren Scores
///
/// Gibt eine Map zurück: POI-ID -> Popularity Score (0.5-1.0)
/// Nur POIs die im Top-Prozentsatz liegen sind enthalten.
final popularPoisProvider = StreamProvider<Map<String, double>>((ref) {
  final service = ref.watch(popularityServiceProvider);
  return service.watchPopularPois();
});

/// Provider für den Popularity-Score eines einzelnen POIs
///
/// Gibt 0.0 zurück wenn nicht beliebt, 0.5-1.0 wenn beliebt.
final poiPopularityProvider =
    FutureProvider.family<double, String>((ref, poiId) async {
  final service = ref.watch(popularityServiceProvider);
  return service.getPopularityScore(poiId);
});

/// Provider der prüft ob ein POI beliebt ist (Riverpod 3.x)
final isPoiPopularProvider =
    Provider.family<bool, String>((ref, poiId) {
  final popularPois = ref.watch(popularPoisProvider).value ?? {};
  return popularPois.containsKey(poiId);
});

/// Provider für Top N beliebte POIs
final topPopularPoisProvider =
    FutureProvider.family<List<MapEntry<String, int>>, int>((ref, count) async {
  final service = ref.watch(popularityServiceProvider);
  return service.getTopPois(count);
});
