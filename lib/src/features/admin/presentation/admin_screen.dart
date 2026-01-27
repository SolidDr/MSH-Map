import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../about/data/traffic_counter_service.dart';
import '../../ratings/domain/rating_model.dart';
import '../../ratings/presentation/rating_input_widget.dart';
import '../application/admin_providers.dart';

/// Admin Dashboard Screen (nur für authentifizierte Admins)
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return const _AccessDeniedScreen();
    }

    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: MshColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => _AdminDashboard(stats: stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: MshColors.error),
              const SizedBox(height: MshSpacing.md),
              Text('Fehler: $error'),
              const SizedBox(height: MshSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(adminStatsProvider),
                child: const Text('Erneut versuchen'),
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
      body: Center(
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
                Icons.lock_outline,
                size: 64,
                color: MshColors.error,
              ),
            ),
            const SizedBox(height: MshSpacing.lg),
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
    );
  }
}

/// Admin Dashboard Content
class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Traffic Stats
          _buildSectionTitle(context, 'Traffic', Icons.trending_up),
          const SizedBox(height: MshSpacing.sm),
          _TrafficStatsCard(stats: stats.trafficStats),

          const SizedBox(height: MshSpacing.lg),

          // Bewertungs-Übersicht
          _buildSectionTitle(context, 'Bewertungen', Icons.star_rounded),
          const SizedBox(height: MshSpacing.sm),
          _RatingSummaryCard(
            totalRatings: stats.totalRatings,
            averageRating: stats.averageRating,
          ),

          const SizedBox(height: MshSpacing.lg),

          // Top bewertete POIs
          _buildSectionTitle(context, 'Top bewertete Orte', Icons.emoji_events),
          const SizedBox(height: MshSpacing.sm),
          _TopRatedPoisCard(pois: stats.topRatedPois),

          const SizedBox(height: MshSpacing.lg),

          // Neueste Bewertungen
          _buildSectionTitle(context, 'Neueste Bewertungen', Icons.schedule),
          const SizedBox(height: MshSpacing.sm),
          _RecentReviewsCard(reviews: stats.recentReviews),

          const SizedBox(height: MshSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: MshColors.primary, size: 24),
        const SizedBox(width: MshSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

/// Traffic Stats Card
class _TrafficStatsCard extends StatelessWidget {
  const _TrafficStatsCard({required this.stats});

  final TrafficStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Row(
          children: [
            _buildStatItem(context, 'Gesamt', stats.total, Icons.trending_up),
            _buildStatItem(context, 'Monat', stats.monthly, Icons.calendar_month),
            _buildStatItem(context, 'Woche', stats.weekly, Icons.date_range),
            _buildStatItem(context, 'Heute', stats.daily, Icons.today),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: MshColors.textMuted, size: 20),
          const SizedBox(height: MshSpacing.xs),
          Text(
            _formatNumber(value),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MshColors.primary,
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

/// Bewertungs-Zusammenfassung
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
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Row(
          children: [
            // Durchschnitt
            Expanded(
              child: Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MshColors.starFilled,
                        ),
                  ),
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
              height: 60,
              color: MshColors.textMuted.withValues(alpha: 0.3),
            ),
            // Gesamt
            Expanded(
              child: Column(
                children: [
                  Text(
                    totalRatings.toString(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MshColors.primary,
                        ),
                  ),
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

/// Top bewertete POIs
class _TopRatedPoisCard extends StatelessWidget {
  const _TopRatedPoisCard({required this.pois});

  final List<PoiRating> pois;

  @override
  Widget build(BuildContext context) {
    if (pois.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.lg),
          child: Center(
            child: Text(
              'Noch keine Bewertungen vorhanden',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MshColors.textMuted,
                  ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < pois.length && i < 10; i++)
            _buildPoiRow(context, i + 1, pois[i]),
        ],
      ),
    );
  }

  Widget _buildPoiRow(BuildContext context, int rank, PoiRating poi) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MshSpacing.md,
        vertical: MshSpacing.sm,
      ),
      decoration: rank < 10
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: MshColors.textMuted.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          // Rang
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getRankColor(rank).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(rank),
                ),
              ),
            ),
          ),
          const SizedBox(width: MshSpacing.md),
          // POI ID
          Expanded(
            child: Text(
              poi.poiId,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Rating
          RatingDisplayWidget(
            rating: poi.averageRating,
            totalCount: poi.totalCount,
            size: 14,
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silber
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return MshColors.textSecondary;
    }
  }
}

/// Neueste Bewertungen
class _RecentReviewsCard extends StatelessWidget {
  const _RecentReviewsCard({required this.reviews});

  final List<({String poiId, ReviewEntry review})> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.lg),
          child: Center(
            child: Text(
              'Noch keine Bewertungen vorhanden',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MshColors.textMuted,
                  ),
            ),
          ),
        ),
      );
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
                  color: MshColors.textMuted.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
          // Kommentar (wenn vorhanden)
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
