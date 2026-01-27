import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../about/data/traffic_counter_service.dart';
import '../../ratings/application/rating_providers.dart';
import '../../ratings/domain/rating_model.dart';

// ═══════════════════════════════════════════════════════════════
// ADMIN-KONFIGURATION
// ═══════════════════════════════════════════════════════════════

/// Liste der Admin-Email-Adressen
const _adminEmails = <String>{
  'konstantin.lange@kolan-system.de',
  'admin@msh-map.de',
};

/// Prüft ob eine Email Admin-Rechte hat
bool isAdminEmail(String? email) {
  if (email == null) return false;
  return _adminEmails.contains(email.toLowerCase());
}

// ═══════════════════════════════════════════════════════════════
// ADMIN PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// Provider für den aktuellen Admin-Status
final isAdminProvider = Provider<bool>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final user = authRepo.currentUser;
  return user != null && isAdminEmail(user.email);
});

/// Stream Provider für Admin-Status (reagiert auf Auth-Änderungen)
final isAdminStreamProvider = StreamProvider<bool>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges.map((user) {
    return user != null && isAdminEmail(user.email);
  });
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
  });

  final TrafficStats trafficStats;
  final int totalRatings;
  final double averageRating;
  final List<PoiRating> topRatedPois;
  final List<({String poiId, ReviewEntry review})> recentReviews;
}

/// Aggregierter Provider für alle Admin-Statistiken
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final trafficService = TrafficCounterService();
  final ratingService = ref.watch(ratingServiceProvider);

  final trafficStats = await trafficService.getStats();
  final allRatings = await ratingService.getAllRatings();
  final recentReviews = await ratingService.getRecentReviews(limit: 15);

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
  );
});
