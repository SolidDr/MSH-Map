import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/usage_analytics_service.dart';

/// Provider für den Usage Analytics Service
final usageAnalyticsServiceProvider = Provider<UsageAnalyticsService>((ref) {
  return UsageAnalyticsService();
});

/// Provider für Echtzeit-Nutzungsstatistiken
final usageStatsProvider = StreamProvider<UsageStats>((ref) {
  final service = ref.watch(usageAnalyticsServiceProvider);
  return service.watchStats();
});

/// Provider für einmalige Statistik-Abfrage
final usageStatsFutureProvider = FutureProvider<UsageStats>((ref) async {
  final service = ref.watch(usageAnalyticsServiceProvider);
  return service.getStats();
});

/// Provider für Top-Module
final topModulesProvider = Provider<List<MapEntry<String, int>>>((ref) {
  final stats = ref.watch(usageStatsProvider).valueOrNull;
  return stats?.topModules(6) ?? [];
});

/// Provider für Top-Kategorien
final topCategoriesProvider = Provider<List<MapEntry<String, int>>>((ref) {
  final stats = ref.watch(usageStatsProvider).valueOrNull;
  return stats?.topCategories(10) ?? [];
});

/// Provider für Peak-Zeiten Insights
final peakTimesProvider = Provider<PeakTimesInsight>((ref) {
  final stats = ref.watch(usageStatsProvider).valueOrNull;
  return PeakTimesInsight(
    peakHour: stats?.peakHour,
    peakWeekday: stats?.peakWeekday,
    hourlyDistribution: stats?.hourlyActivity ?? {},
    weekdayDistribution: stats?.weekdayDistribution ?? {},
  );
});

/// Datenklasse für Peak-Zeiten Insights
class PeakTimesInsight {
  const PeakTimesInsight({
    required this.hourlyDistribution,
    required this.weekdayDistribution,
    this.peakHour,
    this.peakWeekday,
  });

  final Map<String, int> hourlyDistribution;
  final Map<String, int> weekdayDistribution;
  final String? peakHour;
  final String? peakWeekday;

  bool get hasData => hourlyDistribution.isNotEmpty || weekdayDistribution.isNotEmpty;
}
