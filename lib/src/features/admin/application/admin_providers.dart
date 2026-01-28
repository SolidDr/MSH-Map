import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../about/data/traffic_counter_service.dart';
import '../../analytics/data/usage_analytics_service.dart';
import '../../ratings/application/rating_providers.dart';
import '../../ratings/domain/rating_model.dart';

// ═══════════════════════════════════════════════════════════════
// ADMIN-KONFIGURATION
// ═══════════════════════════════════════════════════════════════

/// Geheimer Admin-Schlüssel (URL-Parameter: ?key=...)
const _adminKey = 'msh2024admin';

/// Prüft ob der Schlüssel gültig ist
bool isValidAdminKey(String? key) {
  if (key == null || key.isEmpty) return false;
  return key == _adminKey;
}

// ═══════════════════════════════════════════════════════════════
// ADMIN PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// State Provider für Admin-Status (wird von URL-Parameter gesetzt)
final adminKeyProvider = StateProvider<String?>((ref) => null);

/// Provider für den aktuellen Admin-Status
final isAdminProvider = Provider<bool>((ref) {
  final key = ref.watch(adminKeyProvider);
  return isValidAdminKey(key);
});

/// Provider für Traffic-Statistiken
final trafficStatsProvider = StreamProvider<TrafficStats>((ref) {
  final service = TrafficCounterService();
  return service.watchStats();
});

/// Provider für alle POI-Bewertungen (sortiert nach Anzahl)
final topRatedPoisProvider = FutureProvider<List<PoiRating>>((ref) async {
  final service = ref.watch(ratingServiceProvider);
  return service.getAllRatings();
});

/// Provider für die neuesten Bewertungen
final latestReviewsProvider =
    FutureProvider<List<({String poiId, ReviewEntry review})>>((ref) async {
  final service = ref.watch(ratingServiceProvider);
  return service.getRecentReviews(limit: 15);
});

/// Admin Dashboard Statistiken
class AdminStats {
  const AdminStats({
    required this.trafficStats,
    required this.totalRatings,
    required this.averageRating,
    required this.topRatedPois,
    required this.recentReviews,
    required this.usageStats,
  });

  final TrafficStats trafficStats;
  final int totalRatings;
  final double averageRating;
  final List<PoiRating> topRatedPois;
  final List<({String poiId, ReviewEntry review})> recentReviews;
  final UsageStats usageStats;
}

/// Aggregierter Provider für alle Admin-Statistiken
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final trafficService = TrafficCounterService();
  final ratingService = ref.watch(ratingServiceProvider);
  final usageAnalyticsService = UsageAnalyticsService();

  final trafficStats = await trafficService.getStats();
  final allRatings = await ratingService.getAllRatings();
  final recentReviews = await ratingService.getRecentReviews(limit: 15);
  final usageStats = await usageAnalyticsService.getStats();

  // Berechne Gesamtstatistiken
  var totalRatings = 0;
  var totalScore = 0.0;

  for (final rating in allRatings) {
    totalRatings += rating.totalCount;
    totalScore += rating.averageRating * rating.totalCount;
  }

  final averageRating = totalRatings > 0 ? totalScore / totalRatings : 0.0;

  return AdminStats(
    trafficStats: trafficStats,
    totalRatings: totalRatings,
    averageRating: averageRating,
    topRatedPois: allRatings.take(10).toList(),
    recentReviews: recentReviews,
    usageStats: usageStats,
  );
});
