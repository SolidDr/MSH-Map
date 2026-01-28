import 'dart:math';

import 'usage_analytics_service.dart';

/// Service für Beliebtheit-Berechnung von POIs
///
/// Bestimmt anhand der Klick-Statistiken, welche POIs im regionalen
/// Vergleich besonders beliebt sind und einen goldenen Glow verdienen.
class PopularityService {
  PopularityService({UsageAnalyticsService? analyticsService})
      : _analyticsService = analyticsService ?? UsageAnalyticsService();

  final UsageAnalyticsService _analyticsService;

  /// Mindestanzahl Klicks, ab der ein POI überhaupt für Beliebtheit
  /// in Betracht gezogen wird (verhindert Rauschen bei wenig Daten)
  static const int _minimumClicksForPopularity = 3;

  /// Prozentsatz der Top-POIs, die als "beliebt" gelten (Top 15%)
  static const double _topPercentile = 0.15;

  /// Cache für Klick-Statistiken
  Map<String, int>? _cachedStats;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Holt die aktuellen Klick-Statistiken (mit Caching)
  Future<Map<String, int>> _getStats() async {
    final now = DateTime.now();
    if (_cachedStats != null &&
        _cacheTime != null &&
        now.difference(_cacheTime!) < _cacheDuration) {
      return _cachedStats!;
    }

    _cachedStats = await _analyticsService.getPoiClickStats();
    _cacheTime = now;
    return _cachedStats!;
  }

  /// Berechnet die Beliebtheit eines POIs (0.0 - 1.0)
  ///
  /// Gibt 0.0 zurück wenn der POI nicht beliebt genug ist,
  /// und einen Wert zwischen 0.5 und 1.0 für beliebte POIs
  /// (höher = beliebter).
  Future<double> getPopularityScore(String poiId) async {
    final stats = await _getStats();

    if (stats.isEmpty) return 0.0;

    final clickCount = stats[poiId] ?? 0;

    // Mindestanzahl prüfen
    if (clickCount < _minimumClicksForPopularity) return 0.0;

    // Alle POIs mit genug Klicks sammeln
    final validPois = stats.entries
        .where((e) => e.value >= _minimumClicksForPopularity)
        .toList();

    if (validPois.isEmpty) return 0.0;

    // Sortieren nach Klicks
    validPois.sort((a, b) => b.value.compareTo(a.value));

    // Position dieses POIs finden
    final position = validPois.indexWhere((e) => e.key == poiId);
    if (position == -1) return 0.0;

    // Berechnen ob im Top-Prozentsatz
    final threshold = max(1, (validPois.length * _topPercentile).ceil());

    if (position >= threshold) return 0.0;

    // Popularity-Score berechnen (0.5 - 1.0 basierend auf Position)
    // Position 0 (beliebtester) = 1.0, Position threshold-1 = 0.5
    final normalizedPosition = position / threshold;
    return 1.0 - (normalizedPosition * 0.5);
  }

  /// Prüft ob ein POI als "beliebt" gilt
  Future<bool> isPopular(String poiId) async {
    final score = await getPopularityScore(poiId);
    return score > 0.0;
  }

  /// Gibt alle beliebten POI-IDs mit ihren Scores zurück
  Future<Map<String, double>> getPopularPois() async {
    final stats = await _getStats();

    if (stats.isEmpty) return {};

    final result = <String, double>{};

    for (final entry in stats.entries) {
      final score = await getPopularityScore(entry.key);
      if (score > 0.0) {
        result[entry.key] = score;
      }
    }

    return result;
  }

  /// Stream für Echtzeit-Updates der beliebten POIs
  Stream<Map<String, double>> watchPopularPois() {
    return _analyticsService.watchPoiClickStats().asyncMap((stats) async {
      // Cache aktualisieren
      _cachedStats = stats;
      _cacheTime = DateTime.now();

      if (stats.isEmpty) return <String, double>{};

      final result = <String, double>{};

      // Alle POIs mit genug Klicks
      final validPois = stats.entries
          .where((e) => e.value >= _minimumClicksForPopularity)
          .toList();

      if (validPois.isEmpty) return result;

      // Sortieren nach Klicks
      validPois.sort((a, b) => b.value.compareTo(a.value));

      // Threshold für Top-Prozentsatz
      final threshold = max(1, (validPois.length * _topPercentile).ceil());

      // Top-POIs mit Scores
      for (var i = 0; i < threshold && i < validPois.length; i++) {
        final entry = validPois[i];
        final normalizedPosition = i / threshold;
        final score = 1.0 - (normalizedPosition * 0.5);
        result[entry.key] = score;
      }

      return result;
    });
  }

  /// Gibt die Top N beliebten POIs zurück
  Future<List<MapEntry<String, int>>> getTopPois(int n) async {
    final stats = await _getStats();

    final sorted = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(n).toList();
  }

  /// Invalidiert den Cache (z.B. nach neuen Klicks)
  void invalidateCache() {
    _cachedStats = null;
    _cacheTime = null;
  }
}
