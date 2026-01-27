import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_spacing.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../application/traffic_counter_provider.dart';
import '../../data/traffic_counter_service.dart';

/// Widget zur Anzeige anonymisierter Besucherzahlen
class TrafficCounterWidget extends ConsumerWidget {
  const TrafficCounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(trafficStatsStreamProvider);

    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.surfaceVariant,
        borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
        border: Border.all(
          color: Colors.amber.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MshColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: MshColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: MshSpacing.sm),
              Text(
                'Besucher',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              // Privacy Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: MshColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 12,
                      color: MshColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Anonym',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: MshColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MshSpacing.md),

          // Stats Grid
          statsAsync.when(
            data: (stats) => _buildStatsGrid(context, stats),
            loading: () => _buildLoadingState(),
            error: (_, __) => _buildErrorState(context),
          ),

          const SizedBox(height: MshSpacing.sm),

          // Privacy Note
          Text(
            'Keine Cookies, keine Tracking-IDs',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MshColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, TrafficStats stats) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Gesamt',
            value: _formatNumber(stats.total),
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Monat',
            value: _formatNumber(stats.monthly),
            icon: Icons.calendar_month,
          ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Woche',
            value: _formatNumber(stats.weekly),
            icon: Icons.date_range,
          ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Heute',
            value: _formatNumber(stats.daily),
            icon: Icons.today,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: MshColors.textMuted,
          ),
          const SizedBox(width: MshSpacing.sm),
          Text(
            'Statistiken nicht verfügbar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MshColors.textMuted,
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: MshSpacing.sm,
        horizontal: MshSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: MshColors.textMuted,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MshColors.primary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: MshColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
