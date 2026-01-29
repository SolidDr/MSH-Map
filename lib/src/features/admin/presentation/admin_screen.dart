import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../about/data/traffic_counter_service.dart';
import '../../analytics/data/usage_analytics_service.dart';
import '../../ratings/domain/rating_model.dart';
import '../../ratings/presentation/rating_input_widget.dart';
import '../application/admin_providers.dart';

/// Admin Dashboard Screen (Zugang über URL-Parameter ?key=...)
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key, this.adminKey});

  final String? adminKey;

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      ref.read(adminKeyProvider.notifier).setKey(widget.adminKey);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return const _AccessDeniedScreen();
    }

    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      body: statsAsync.when(
        data: (stats) => _EnhancedAdminDashboard(
          stats: stats,
          tabController: _tabController,
          onRefresh: () => ref.invalidate(adminStatsProvider),
        ),
        loading: () => const _LoadingScreen(),
        error: (error, _) => _ErrorScreen(
          error: error.toString(),
          onRetry: () => ref.invalidate(adminStatsProvider),
        ),
      ),
    );
  }
}

/// Loading Screen
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [MshColors.primary, Color(0xFF1a237e)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: MshSpacing.lg),
              Text(
                'Lade Dashboard...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error Screen
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: MshColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: MshColors.error,
                ),
              ),
              const SizedBox(height: MshSpacing.lg),
              Text(
                'Fehler beim Laden',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: MshSpacing.sm),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MshColors.error),
              ),
              const SizedBox(height: MshSpacing.xl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zugriff verweigert Screen
class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MshColors.error.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: MshColors.error.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: MshColors.error,
                ),
              ),
              const SizedBox(height: MshSpacing.xl),
              Text(
                'Zugriff verweigert',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: MshSpacing.sm),
              Text(
                'Diese Seite ist nur für Administratoren.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: MshColors.textSecondary,
                    ),
              ),
              const SizedBox(height: MshSpacing.xl),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Zurück'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Admin Dashboard
class _EnhancedAdminDashboard extends StatelessWidget {
  const _EnhancedAdminDashboard({
    required this.stats,
    required this.tabController,
    required this.onRefresh,
  });

  final AdminStats stats;
  final TabController tabController;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildAppBar(context, innerBoxIsScrolled),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          _OverviewTab(stats: stats),
          _TrafficTab(stats: stats),
          _RatingsTab(stats: stats),
          _BehaviorTab(usageStats: stats.usageStats),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: MshColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'Aktualisieren',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MshColors.primary, Color(0xFF1a237e)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(MshSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: MshSpacing.md),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'MSH-Map Analytics & Insights',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: MshSpacing.lg),
                  _QuickStatsRow(stats: stats),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: TabBar(
        controller: tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Übersicht'),
          Tab(icon: Icon(Icons.trending_up), text: 'Traffic'),
          Tab(icon: Icon(Icons.star), text: 'Bewertungen'),
          Tab(icon: Icon(Icons.psychology), text: 'Verhalten'),
        ],
      ),
    );
  }
}

/// Quick Stats Row im Header
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickStatChip(
          icon: Icons.people,
          value: _formatNumber(stats.trafficStats.total),
          label: 'Besucher',
        ),
        const SizedBox(width: MshSpacing.sm),
        _QuickStatChip(
          icon: Icons.star,
          value: stats.totalRatings.toString(),
          label: 'Bewertungen',
        ),
        const SizedBox(width: MshSpacing.sm),
        _QuickStatChip(
          icon: Icons.touch_app,
          value: _formatNumber(stats.usageStats.totalPoiClicks),
          label: 'POI-Klicks',
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _QuickStatChip extends StatelessWidget {
  const _QuickStatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 1: ÜBERSICHT
// ═══════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Insights Cards
          _InsightsSection(stats: stats),
          const SizedBox(height: MshSpacing.lg),

          // Key Metrics Grid
          _KeyMetricsGrid(stats: stats),
          const SizedBox(height: MshSpacing.lg),

          // Recent Activity
          const _SectionTitle(title: 'Letzte Aktivitäten', icon: Icons.history),
          const SizedBox(height: MshSpacing.sm),
          _RecentActivityCard(stats: stats),
        ],
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Insights', icon: Icons.lightbulb),
        const SizedBox(height: MshSpacing.sm),
        ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: MshSpacing.sm),
              child: _InsightCard(insight: insight),
            ),),
      ],
    );
  }

  List<_Insight> _generateInsights() {
    final insights = <_Insight>[];

    // Traffic Insight
    final dailyVsWeeklyAvg = stats.trafficStats.weekly > 0
        ? stats.trafficStats.daily / (stats.trafficStats.weekly / 7)
        : 0.0;

    if (dailyVsWeeklyAvg > 1.2) {
      insights.add(_Insight(
        icon: Icons.trending_up,
        color: MshColors.success,
        title: 'Überdurchschnittlicher Traffic',
        description:
            'Heute ${(dailyVsWeeklyAvg * 100 - 100).toStringAsFixed(0)}% mehr Besucher als im Wochendurchschnitt.',
      ),);
    } else if (dailyVsWeeklyAvg < 0.8 && dailyVsWeeklyAvg > 0) {
      insights.add(_Insight(
        icon: Icons.trending_down,
        color: MshColors.warning,
        title: 'Weniger Traffic als üblich',
        description:
            'Heute ${(100 - dailyVsWeeklyAvg * 100).toStringAsFixed(0)}% weniger Besucher als im Wochendurchschnitt.',
      ),);
    }

    // Peak Zeit Insight
    if (stats.usageStats.peakHour != null) {
      insights.add(_Insight(
        icon: Icons.schedule,
        color: MshColors.primary,
        title: 'Aktivste Zeit: ${stats.usageStats.peakHour}',
        description: 'Die meisten Nutzer sind zu dieser Zeit aktiv.',
      ),);
    }

    // Top Kategorie Insight
    final topCategories = stats.usageStats.topCategories(1);
    if (topCategories.isNotEmpty) {
      insights.add(_Insight(
        icon: Icons.category,
        color: const Color(0xFF7C3AED),
        title: 'Beliebteste Kategorie: ${topCategories.first.key}',
        description: '${topCategories.first.value} Klicks auf diese Kategorie.',
      ),);
    }

    // Rating Insight
    if (stats.averageRating > 0) {
      insights.add(_Insight(
        icon: Icons.star,
        color: MshColors.starFilled,
        title: 'Durchschnittsbewertung: ${stats.averageRating.toStringAsFixed(1)}',
        description:
            '${stats.totalRatings} Bewertungen von zufriedenen Nutzern.',
      ),);
    }

    return insights;
  }
}

class _Insight {
  const _Insight({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final _Insight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            insight.color.withValues(alpha: 0.1),
            insight.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(color: insight.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(insight.icon, color: insight.color, size: 20),
          ),
          const SizedBox(width: MshSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: insight.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
}

class _KeyMetricsGrid extends StatelessWidget {
  const _KeyMetricsGrid({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: MshSpacing.md,
      crossAxisSpacing: MshSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          icon: Icons.people,
          label: 'Besucher Gesamt',
          value: stats.trafficStats.total.toString(),
          gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        _MetricCard(
          icon: Icons.today,
          label: 'Besucher Heute',
          value: stats.trafficStats.daily.toString(),
          gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
        ),
        _MetricCard(
          icon: Icons.star_rounded,
          label: 'Bewertungen',
          value: stats.totalRatings.toString(),
          gradient: const [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        _MetricCard(
          icon: Icons.touch_app,
          label: 'POI-Interaktionen',
          value: stats.usageStats.totalPoiClicks.toString(),
          gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.recentReviews.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.lg),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.inbox, size: 48, color: MshColors.textMuted),
                const SizedBox(height: MshSpacing.sm),
                Text(
                  'Noch keine Aktivitäten',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MshColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < stats.recentReviews.length && i < 5; i++)
            _ActivityItem(
              review: stats.recentReviews[i],
              isLast: i == 4 || i == stats.recentReviews.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.review, this.isLast = false});

  final ({String poiId, ReviewEntry review}) review;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: !isLast
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: MshColors.textMuted.withValues(alpha: 0.2),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MshColors.starFilled.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: MshColors.starFilled, size: 16),
          ),
          const SizedBox(width: MshSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.poiId,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                if (review.review.text != null)
                  Text(
                    '"${review.review.text}"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MshColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RatingDisplayWidget(
                rating: review.review.rating.toDouble(),
                showCount: false,
                size: 12,
              ),
              Text(
                review.review.relativeTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 2: TRAFFIC
// ═══════════════════════════════════════════════════════════════

class _TrafficTab extends StatelessWidget {
  const _TrafficTab({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Traffic Übersicht', icon: Icons.trending_up),
          const SizedBox(height: MshSpacing.sm),
          _TrafficOverviewCard(stats: stats.trafficStats),
          const SizedBox(height: MshSpacing.lg),

          const _SectionTitle(title: 'Aktivität nach Stunde', icon: Icons.schedule),
          const SizedBox(height: MshSpacing.sm),
          _HourlyActivityChart(hourlyData: stats.usageStats.hourlyActivity),
          const SizedBox(height: MshSpacing.lg),

          const _SectionTitle(title: 'Aktivität nach Wochentag', icon: Icons.calendar_today),
          const SizedBox(height: MshSpacing.sm),
          _WeekdayActivityChart(weekdayData: stats.usageStats.weekdayDistribution),
        ],
      ),
    );
  }
}

class _TrafficOverviewCard extends StatelessWidget {
  const _TrafficOverviewCard({required this.stats});

  final TrafficStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.lg),
        child: Row(
          children: [
            _TrafficStatItem(
              label: 'Gesamt',
              value: stats.total,
              icon: Icons.people,
              color: MshColors.primary,
            ),
            _buildDivider(),
            _TrafficStatItem(
              label: 'Monat',
              value: stats.monthly,
              icon: Icons.calendar_month,
              color: const Color(0xFF7C3AED),
            ),
            _buildDivider(),
            _TrafficStatItem(
              label: 'Woche',
              value: stats.weekly,
              icon: Icons.date_range,
              color: MshColors.success,
            ),
            _buildDivider(),
            _TrafficStatItem(
              label: 'Heute',
              value: stats.daily,
              icon: Icons.today,
              color: MshColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: MshSpacing.sm),
      color: MshColors.textMuted.withValues(alpha: 0.2),
    );
  }
}

class _TrafficStatItem extends StatelessWidget {
  const _TrafficStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: MshSpacing.sm),
          Text(
            _formatNumber(value),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MshColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _HourlyActivityChart extends StatelessWidget {
  const _HourlyActivityChart({required this.hourlyData});

  final Map<String, int> hourlyData;

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const _EmptyDataCard(message: 'Noch keine Stundendaten vorhanden');
    }

    final maxValue = hourlyData.values.fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (hour) {
                  final key = hour.toString().padLeft(2, '0');
                  final value = hourlyData[key] ?? 0;
                  final height = maxValue > 0 ? (value / maxValue) * 120 : 0.0;

                  return Expanded(
                    child: Tooltip(
                      message: '$hour:00 - ${hour + 1}:00: $value',
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: height + 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              MshColors.primary,
                              MshColors.primary.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: MshSpacing.sm),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0:00', style: TextStyle(fontSize: 10, color: MshColors.textMuted)),
                Text('6:00', style: TextStyle(fontSize: 10, color: MshColors.textMuted)),
                Text('12:00', style: TextStyle(fontSize: 10, color: MshColors.textMuted)),
                Text('18:00', style: TextStyle(fontSize: 10, color: MshColors.textMuted)),
                Text('24:00', style: TextStyle(fontSize: 10, color: MshColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayActivityChart extends StatelessWidget {
  const _WeekdayActivityChart({required this.weekdayData});

  final Map<String, int> weekdayData;

  @override
  Widget build(BuildContext context) {
    if (weekdayData.isEmpty) {
      return const _EmptyDataCard(message: 'Noch keine Wochentagsdaten vorhanden');
    }

    final maxValue = weekdayData.values.fold(0, (a, b) => a > b ? a : b);
    final days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final fullDays = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Column(
          children: List.generate(7, (index) {
            final day = fullDays[index];
            final value = weekdayData[day] ?? 0;
            final width = maxValue > 0 ? value / maxValue : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      days[index],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: MshSpacing.sm),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: MshColors.textMuted.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: width,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  MshColors.primary,
                                  MshColors.primary.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: MshSpacing.sm),
                  SizedBox(
                    width: 40,
                    child: Text(
                      value.toString(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MshColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 3: BEWERTUNGEN
// ═══════════════════════════════════════════════════════════════

class _RatingsTab extends StatelessWidget {
  const _RatingsTab({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Bewertungs-Übersicht', icon: Icons.star_rounded),
          const SizedBox(height: MshSpacing.sm),
          _RatingSummaryCard(
            totalRatings: stats.totalRatings,
            averageRating: stats.averageRating,
          ),
          const SizedBox(height: MshSpacing.lg),

          const _SectionTitle(title: 'Top bewertete Orte', icon: Icons.emoji_events),
          const SizedBox(height: MshSpacing.sm),
          _TopRatedPoisCard(pois: stats.topRatedPois),
          const SizedBox(height: MshSpacing.lg),

          const _SectionTitle(title: 'Neueste Bewertungen', icon: Icons.schedule),
          const SizedBox(height: MshSpacing.sm),
          _RecentReviewsCard(reviews: stats.recentReviews),
        ],
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  const _RatingSummaryCard({
    required this.totalRatings,
    required this.averageRating,
  });

  final int totalRatings;
  final double averageRating;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MshColors.starFilled.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      averageRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: MshColors.starFilled,
                          ),
                    ),
                  ),
                  const SizedBox(height: MshSpacing.sm),
                  RatingDisplayWidget(
                    rating: averageRating,
                    showCount: false,
                    size: 20,
                  ),
                  const SizedBox(height: MshSpacing.xs),
                  Text(
                    'Durchschnitt',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MshColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 80,
              color: MshColors.textMuted.withValues(alpha: 0.2),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MshColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      totalRatings.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: MshColors.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: MshSpacing.sm),
                  const Icon(Icons.rate_review, color: MshColors.primary),
                  const SizedBox(height: MshSpacing.xs),
                  Text(
                    'Bewertungen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MshColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopRatedPoisCard extends StatelessWidget {
  const _TopRatedPoisCard({required this.pois});

  final List<PoiRating> pois;

  @override
  Widget build(BuildContext context) {
    if (pois.isEmpty) {
      return const _EmptyDataCard(message: 'Noch keine Bewertungen vorhanden');
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < pois.length && i < 10; i++)
            _buildPoiRow(context, i + 1, pois[i], i == pois.length - 1 || i == 9),
        ],
      ),
    );
  }

  Widget _buildPoiRow(BuildContext context, int rank, PoiRating poi, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MshSpacing.md,
        vertical: MshSpacing.sm,
      ),
      decoration: !isLast
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: MshColors.textMuted.withValues(alpha: 0.2),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getRankGradient(rank),
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: MshSpacing.md),
          Expanded(
            child: Text(
              poi.poiId,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          RatingDisplayWidget(
            rating: poi.averageRating,
            totalCount: poi.totalCount,
            size: 14,
          ),
        ],
      ),
    );
  }

  List<Color> _getRankGradient(int rank) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)];
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      default:
        return [MshColors.textSecondary, MshColors.textMuted];
    }
  }
}

class _RecentReviewsCard extends StatelessWidget {
  const _RecentReviewsCard({required this.reviews});

  final List<({String poiId, ReviewEntry review})> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const _EmptyDataCard(message: 'Noch keine Bewertungen vorhanden');
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < reviews.length; i++)
            _buildReviewRow(context, reviews[i], isLast: i == reviews.length - 1),
        ],
      ),
    );
  }

  Widget _buildReviewRow(
    BuildContext context,
    ({String poiId, ReviewEntry review}) item, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: !isLast
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: MshColors.textMuted.withValues(alpha: 0.2),
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingDisplayWidget(
                rating: item.review.rating.toDouble(),
                showCount: false,
                size: 14,
              ),
              const SizedBox(width: MshSpacing.sm),
              Expanded(
                child: Text(
                  item.poiId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MshColors.textMuted,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item.review.relativeTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textMuted,
                    ),
              ),
            ],
          ),
          if (item.review.text != null && item.review.text!.isNotEmpty) ...[
            const SizedBox(height: MshSpacing.xs),
            Container(
              padding: const EdgeInsets.all(MshSpacing.sm),
              decoration: BoxDecoration(
                color: MshColors.surfaceVariant,
                borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
              ),
              child: Text(
                item.review.text!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 4: VERHALTEN
// ═══════════════════════════════════════════════════════════════

class _BehaviorTab extends StatelessWidget {
  const _BehaviorTab({required this.usageStats});

  final UsageStats usageStats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Modul-Nutzung', icon: Icons.apps),
          const SizedBox(height: MshSpacing.sm),
          _ModuleUsageCard(moduleVisits: usageStats.moduleVisits),
          const SizedBox(height: MshSpacing.lg),

          const _SectionTitle(title: 'Beliebte Kategorien', icon: Icons.category),
          const SizedBox(height: MshSpacing.sm),
          _CategoryUsageCard(poiClicks: usageStats.poiClicks),
          const SizedBox(height: MshSpacing.lg),

          const _SectionTitle(title: 'Filter-Nutzung', icon: Icons.filter_list),
          const SizedBox(height: MshSpacing.sm),
          _FilterUsageCard(filterUsage: usageStats.filterUsage),
          const SizedBox(height: MshSpacing.lg),

          const _SectionTitle(title: 'Aktionen', icon: Icons.touch_app),
          const SizedBox(height: MshSpacing.sm),
          _ActionsCard(actions: usageStats.actions),
        ],
      ),
    );
  }
}

class _ModuleUsageCard extends StatelessWidget {
  const _ModuleUsageCard({required this.moduleVisits});

  final Map<String, int> moduleVisits;

  @override
  Widget build(BuildContext context) {
    if (moduleVisits.isEmpty) {
      return const _EmptyDataCard(message: 'Noch keine Modul-Nutzungsdaten');
    }

    final sorted = moduleVisits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = sorted.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Column(
          children: sorted.take(8).map((entry) {
            final percentage = maxValue > 0 ? entry.value / maxValue : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getModuleColor(entry.key).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getModuleIcon(entry.key),
                      color: _getModuleColor(entry.key),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: MshSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getModuleName(entry.key),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 6,
                            backgroundColor: MshColors.textMuted.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(_getModuleColor(entry.key)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: MshSpacing.md),
                  Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getModuleColor(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getModuleIcon(String moduleId) {
    switch (moduleId) {
      case 'events':
        return Icons.celebration;
      case 'health':
        return Icons.local_hospital;
      case 'gastro':
        return Icons.restaurant;
      case 'family':
        return Icons.family_restroom;
      case 'civic':
        return Icons.volunteer_activism;
      case 'nightlife':
        return Icons.nightlife;
      case 'mobility':
        return Icons.directions_bus;
      default:
        return Icons.apps;
    }
  }

  Color _getModuleColor(String moduleId) {
    switch (moduleId) {
      case 'events':
        return MshColors.categoryEvent;
      case 'health':
        return MshColors.categoryHealth;
      case 'gastro':
        return MshColors.categoryGastro;
      case 'family':
        return MshColors.categoryFamily;
      case 'civic':
        return MshColors.categorySocialFacility;
      case 'nightlife':
        return MshColors.categoryNightlife;
      default:
        return MshColors.primary;
    }
  }

  String _getModuleName(String moduleId) {
    switch (moduleId) {
      case 'events':
        return 'Veranstaltungen';
      case 'health':
        return 'Gesundheit';
      case 'gastro':
        return 'Gastronomie';
      case 'family':
        return 'Familie';
      case 'civic':
        return 'Soziales';
      case 'nightlife':
        return 'Nachtleben';
      case 'mobility':
        return 'Mobilität';
      default:
        return moduleId;
    }
  }
}

class _CategoryUsageCard extends StatelessWidget {
  const _CategoryUsageCard({required this.poiClicks});

  final Map<String, int> poiClicks;

  @override
  Widget build(BuildContext context) {
    if (poiClicks.isEmpty) {
      return const _EmptyDataCard(message: 'Noch keine Kategorie-Daten');
    }

    final sorted = poiClicks.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = poiClicks.values.fold(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Wrap(
          spacing: MshSpacing.sm,
          runSpacing: MshSpacing.sm,
          children: sorted.take(12).map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MshColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: MshColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: MshColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterUsageCard extends StatelessWidget {
  const _FilterUsageCard({required this.filterUsage});

  final Map<String, int> filterUsage;

  @override
  Widget build(BuildContext context) {
    if (filterUsage.isEmpty) {
      return const _EmptyDataCard(message: 'Noch keine Filter-Nutzungsdaten');
    }

    final sorted = filterUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Column(
          children: sorted.take(10).map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: MshColors.textMuted),
                  const SizedBox(width: MshSpacing.sm),
                  Expanded(
                    child: Text(entry.key),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MshColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.value}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.actions});

  final Map<String, int> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const _EmptyDataCard(message: 'Noch keine Aktions-Daten');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Row(
          children: actions.entries.map((entry) {
            return Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MshColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getActionIcon(entry.key),
                      color: MshColors.primary,
                    ),
                  ),
                  const SizedBox(height: MshSpacing.sm),
                  Text(
                    entry.value.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _getActionLabel(entry.key),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MshColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'search':
        return Icons.search;
      case 'rating_submitted':
        return Icons.star;
      case 'share':
        return Icons.share;
      case 'route':
        return Icons.directions;
      default:
        return Icons.touch_app;
    }
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'search':
        return 'Suchen';
      case 'rating_submitted':
        return 'Bewertungen';
      case 'share':
        return 'Geteilt';
      case 'route':
        return 'Routen';
      default:
        return action;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MshColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: MshColors.primary, size: 20),
        ),
        const SizedBox(width: MshSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _EmptyDataCard extends StatelessWidget {
  const _EmptyDataCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.xl),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.inbox, size: 48, color: MshColors.textMuted),
              const SizedBox(height: MshSpacing.sm),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MshColors.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
