# 23 - Dashboard & Insights - Flutter Code

## Übersicht

Konkrete Flutter-Implementierungen für die Insights-Features.

---

## 1. Datenmodelle

```dart
// lib/src/features/insights/domain/models.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// Regionale Statistik für eine Stadt
@freezed
class CityStats with _$CityStats {
  const factory CityStats({
    required String cityName,
    required int locationCount,
    required Map<String, int> categoryDistribution,
    required double coverageScore,
    required double familyScore,
    double? avgRating,
    int? population,
  }) = _CityStats;
  
  factory CityStats.fromJson(Map<String, dynamic> json) => 
      _$CityStatsFromJson(json);
}

/// Erkannte Infrastruktur-Lücke
@freezed
class InfrastructureGap with _$InfrastructureGap {
  const factory InfrastructureGap({
    required String id,
    required String gapType,
    required double latitude,
    required double longitude,
    required String severity, // critical, moderate, low
    required String description,
    required String affectedArea,
    int? affectedPopulation,
    String? recommendation,
  }) = _InfrastructureGap;
  
  factory InfrastructureGap.fromJson(Map<String, dynamic> json) => 
      _$InfrastructureGapFromJson(json);
}

/// Insight/Erkenntnis
@freezed
class RegionalInsight with _$RegionalInsight {
  const factory RegionalInsight({
    required String id,
    required String type, // trend, gap, achievement, recommendation
    required String title,
    required String description,
    String? metric,
    double? value,
    String? iconName,
    DateTime? createdAt,
  }) = _RegionalInsight;
  
  factory RegionalInsight.fromJson(Map<String, dynamic> json) => 
      _$RegionalInsightFromJson(json);
}

/// Aggregierte Region-Statistik
@freezed
class RegionOverview with _$RegionOverview {
  const factory RegionOverview({
    required int totalLocations,
    required int totalCities,
    required Map<String, int> categoryTotals,
    required List<CityStats> cityStats,
    required List<InfrastructureGap> gaps,
    required List<RegionalInsight> insights,
    required DateTime lastUpdated,
  }) = _RegionOverview;
  
  factory RegionOverview.fromJson(Map<String, dynamic> json) => 
      _$RegionOverviewFromJson(json);
}
```

---

## 2. Repository

```dart
// lib/src/features/insights/data/insights_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insights_repository.g.dart';

@riverpod
InsightsRepository insightsRepository(InsightsRepositoryRef ref) {
  return InsightsRepository(FirebaseFirestore.instance);
}

class InsightsRepository {
  final FirebaseFirestore _firestore;
  
  InsightsRepository(this._firestore);
  
  /// Lädt Übersicht für die gesamte Region
  Future<RegionOverview> getRegionOverview() async {
    final statsDoc = await _firestore
        .collection('analytics')
        .doc('region_overview')
        .get();
    
    if (!statsDoc.exists) {
      return _getEmptyOverview();
    }
    
    return RegionOverview.fromJson(statsDoc.data()!);
  }
  
  /// Lädt Statistiken für eine Stadt
  Future<CityStats?> getCityStats(String cityName) async {
    final doc = await _firestore
        .collection('analytics')
        .doc('city_stats')
        .collection('cities')
        .doc(cityName.toLowerCase())
        .get();
    
    if (!doc.exists) return null;
    return CityStats.fromJson(doc.data()!);
  }
  
  /// Lädt alle erkannten Lücken
  Stream<List<InfrastructureGap>> watchGaps() {
    return _firestore
        .collection('analytics')
        .doc('gaps')
        .collection('items')
        .orderBy('severity')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => InfrastructureGap.fromJson(doc.data()))
            .toList());
  }
  
  /// Lädt aktuelle Insights
  Stream<List<RegionalInsight>> watchInsights({int limit = 10}) {
    return _firestore
        .collection('analytics')
        .doc('insights')
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RegionalInsight.fromJson(doc.data()))
            .toList());
  }
  
  /// Kategorie-Verteilung für Charts
  Future<Map<String, int>> getCategoryDistribution() async {
    final doc = await _firestore
        .collection('analytics')
        .doc('category_distribution')
        .get();
    
    if (!doc.exists) return {};
    return Map<String, int>.from(doc.data()!['categories'] ?? {});
  }
  
  RegionOverview _getEmptyOverview() {
    return RegionOverview(
      totalLocations: 0,
      totalCities: 0,
      categoryTotals: {},
      cityStats: [],
      gaps: [],
      insights: [],
      lastUpdated: DateTime.now(),
    );
  }
}
```

---

## 3. Dashboard Screen

```dart
// lib/src/features/insights/presentation/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_theme.dart';
import '../data/insights_repository.dart';
import 'widgets/stat_card.dart';
import 'widgets/category_chart.dart';
import 'widgets/city_comparison.dart';
import 'widgets/gap_list.dart';
import 'widgets/insight_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(regionOverviewProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSH in Zahlen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(regionOverviewProvider),
          ),
        ],
      ),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (overview) => _DashboardContent(overview: overview),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final RegionOverview overview;
  
  const _DashboardContent({required this.overview});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══ ÜBERSICHT ZAHLEN ═══
          _buildStatsRow(),
          
          const SizedBox(height: MshTheme.spacingLg),
          
          // ═══ KATEGORIE-VERTEILUNG ═══
          Text(
            'Kategorien',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: MshTheme.spacingMd),
          CategoryChart(distribution: overview.categoryTotals),
          
          const SizedBox(height: MshTheme.spacingLg),
          
          // ═══ STÄDTE-VERGLEICH ═══
          Text(
            'Städte im Vergleich',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: MshTheme.spacingMd),
          CityComparison(cities: overview.cityStats),
          
          const SizedBox(height: MshTheme.spacingLg),
          
          // ═══ LÜCKEN ═══
          if (overview.gaps.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Erkannte Lücken',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {}, // TODO: Alle anzeigen
                  child: const Text('Alle anzeigen'),
                ),
              ],
            ),
            const SizedBox(height: MshTheme.spacingMd),
            GapList(gaps: overview.gaps.take(3).toList()),
          ],
          
          const SizedBox(height: MshTheme.spacingLg),
          
          // ═══ INSIGHTS ═══
          if (overview.insights.isNotEmpty) ...[
            Text(
              'Erkenntnisse',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: MshTheme.spacingMd),
            ...overview.insights.take(5).map((insight) => 
              Padding(
                padding: const EdgeInsets.only(bottom: MshTheme.spacingSm),
                child: InsightCard(insight: insight),
              ),
            ),
          ],
          
          const SizedBox(height: MshTheme.spacingXl),
          
          // ═══ FOOTER ═══
          Center(
            child: Text(
              'Letzte Aktualisierung: ${_formatDate(overview.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsRow() {
    return Wrap(
      spacing: MshTheme.spacingMd,
      runSpacing: MshTheme.spacingMd,
      children: [
        StatCard(
          title: 'Orte',
          value: '${overview.totalLocations}',
          icon: Icons.place,
          color: MshColors.primary,
        ),
        StatCard(
          title: 'Spielplätze',
          value: '${overview.categoryTotals['playground'] ?? 0}',
          icon: Icons.toys,
          color: MshColors.categoryPlayground,
        ),
        StatCard(
          title: 'Museen',
          value: '${overview.categoryTotals['museum'] ?? 0}',
          icon: Icons.museum,
          color: MshColors.categoryMuseum,
        ),
        StatCard(
          title: 'Gastronomie',
          value: '${overview.categoryTotals['restaurant'] ?? 0}',
          icon: Icons.restaurant,
          color: MshColors.categoryGastro,
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

// Provider
@riverpod
Future<RegionOverview> regionOverview(RegionOverviewRef ref) {
  return ref.watch(insightsRepositoryProvider).getRegionOverview();
}
```

---

## 4. Widgets

### 4.1 StatCard

```dart
// lib/src/features/insights/presentation/widgets/stat_card.dart

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(MshTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trend!.startsWith('+') 
                        ? MshColors.success.withOpacity(0.2)
                        : MshColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: trend!.startsWith('+') 
                          ? MshColors.success 
                          : MshColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: MshTheme.spacingSm),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: MshColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4.2 CategoryChart

```dart
// lib/src/features/insights/presentation/widgets/category_chart.dart

class CategoryChart extends StatelessWidget {
  final Map<String, int> distribution;
  
  const CategoryChart({super.key, required this.distribution});
  
  static const _categoryMeta = {
    'playground': (Icons.toys, 'Spielplätze', Color(0xFF10B981)),
    'museum': (Icons.museum, 'Museen', Color(0xFF8B5CF6)),
    'nature': (Icons.park, 'Natur', Color(0xFF22C55E)),
    'pool': (Icons.pool, 'Schwimmbäder', Color(0xFF06B6D4)),
    'castle': (Icons.castle, 'Burgen', Color(0xFFEC4899)),
    'restaurant': (Icons.restaurant, 'Restaurants', Color(0xFFEF4444)),
    'cafe': (Icons.coffee, 'Cafés', Color(0xFF8B5CF6)),
    'church': (Icons.church, 'Kirchen', Color(0xFF6366F1)),
  };
  
  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();
    
    final sorted = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      children: sorted.take(8).map((entry) {
        final meta = _categoryMeta[entry.key];
        final icon = meta?.$1 ?? Icons.place;
        final label = meta?.$2 ?? entry.key;
        final color = meta?.$3 ?? MshColors.textSecondary;
        final percentage = entry.value / total;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Text(label, style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${entry.value}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
```

### 4.3 CityComparison

```dart
// lib/src/features/insights/presentation/widgets/city_comparison.dart

class CityComparison extends StatelessWidget {
  final List<CityStats> cities;
  
  const CityComparison({super.key, required this.cities});
  
  @override
  Widget build(BuildContext context) {
    final sorted = [...cities]
      ..sort((a, b) => b.coverageScore.compareTo(a.coverageScore));
    
    return Column(
      children: sorted.take(5).map((city) {
        final scorePercent = (city.coverageScore * 100).round();
        final color = _getScoreColor(city.coverageScore);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  city.cityName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: MshColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: city.coverageScore,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '$scorePercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${city.locationCount}',
                style: TextStyle(
                  color: MshColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 0.7) return MshColors.success;
    if (score >= 0.4) return MshColors.warning;
    return MshColors.error;
  }
}
```

### 4.4 GapList

```dart
// lib/src/features/insights/presentation/widgets/gap_list.dart

class GapList extends StatelessWidget {
  final List<InfrastructureGap> gaps;
  
  const GapList({super.key, required this.gaps});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: gaps.map((gap) => _GapItem(gap: gap)).toList(),
    );
  }
}

class _GapItem extends StatelessWidget {
  final InfrastructureGap gap;
  
  const _GapItem({required this.gap});
  
  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getSeverityStyle(gap.severity);
    
    return Card(
      margin: const EdgeInsets.only(bottom: MshTheme.spacingSm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          gap.description,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          gap.affectedArea + 
          (gap.affectedPopulation != null 
              ? ' · ${gap.affectedPopulation} Einwohner betroffen' 
              : ''),
          style: TextStyle(
            fontSize: 12,
            color: MshColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.map_outlined, size: 20),
          onPressed: () {
            // TODO: Auf Karte zeigen
          },
        ),
      ),
    );
  }
  
  (IconData, Color) _getSeverityStyle(String severity) {
    return switch (severity) {
      'critical' => (Icons.error, MshColors.error),
      'moderate' => (Icons.warning, MshColors.warning),
      _ => (Icons.info, MshColors.info),
    };
  }
}
```

### 4.5 InsightCard

```dart
// lib/src/features/insights/presentation/widgets/insight_card.dart

class InsightCard extends StatelessWidget {
  final RegionalInsight insight;
  
  const InsightCard({super.key, required this.insight});
  
  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getTypeStyle(insight.type);
    
    return Container(
      padding: const EdgeInsets.all(MshTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: MshTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: MshColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  (IconData, Color) _getTypeStyle(String type) {
    return switch (type) {
      'trend' => (Icons.trending_up, MshColors.info),
      'gap' => (Icons.warning_amber, MshColors.warning),
      'achievement' => (Icons.emoji_events, MshColors.success),
      'recommendation' => (Icons.lightbulb, MshColors.primary),
      _ => (Icons.info, MshColors.textSecondary),
    };
  }
}
```

---

## 5. Route registrieren

```dart
// In app_router.dart:

GoRoute(
  path: '/dashboard',
  builder: (context, state) => const DashboardScreen(),
),

// Im Menü:
_SidebarItem(
  icon: Icons.analytics,
  label: 'MSH in Zahlen',
  onTap: () => context.go('/dashboard'),
),
```
