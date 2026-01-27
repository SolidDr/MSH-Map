import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_spacing.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../data/events_providers.dart';
import '../../domain/notice.dart';

/// Banner to display important notices and warnings
class NoticeBanner extends ConsumerWidget {
  const NoticeBanner({super.key, this.onNoticeLocationTap});

  final void Function(double latitude, double longitude)? onNoticeLocationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(activeNoticesProvider);

    return noticesAsync.when(
      data: (notices) {
        if (notices.isEmpty) return const SizedBox.shrink();

        // Show only critical and warning notices, sorted by priority
        final important = notices
            .where((n) =>
                n.severity == NoticeSeverity.critical ||
                n.severity == NoticeSeverity.warning,)
            .toList()
          // Sort by priority: critical > warning
          ..sort((a, b) {
            const priorityOrder = {
              NoticeSeverity.critical: 0,
              NoticeSeverity.warning: 1,
              NoticeSeverity.info: 2,
            };
            return priorityOrder[a.severity]!.compareTo(priorityOrder[b.severity]!);
          });

        if (important.isEmpty) return const SizedBox.shrink();

        // Ohne extra Margin - HomeScreen kontrolliert Abstände
        return _NoticeCard(
          notice: important.first,
          additionalCount: important.length - 1,
          onTap: important.first.latitude != null && important.first.longitude != null
              ? () => onNoticeLocationTap?.call(
                    important.first.latitude!,
                    important.first.longitude!,
                  )
              : null,
          onMoreTap: important.length > 1
              ? () => _showAllNotices(context, important, onNoticeLocationTap)
              : null,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showAllNotices(
    BuildContext context,
    List<MshNotice> notices,
    void Function(double, double)? onLocationTap,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoticesSheet(
        notices: notices,
        onLocationTap: onLocationTap,
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
    this.onTap,
    this.additionalCount = 0,
    this.onMoreTap,
  });

  final MshNotice notice;
  final VoidCallback? onTap;
  final int additionalCount;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final color = notice.color;
    final icon = notice.icon;

    return Material(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(MshSpacing.sm + 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Circle with colored background
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // Content (Titel, Beschreibung, Datum)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titel
                    Text(
                      notice.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    // Beschreibung
                    if (notice.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        notice.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MshColors.textPrimary,
                              height: 1.2,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Datum
                    if (notice.validUntil != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: MshColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Bis ${_formatDate(notice.validUntil!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: MshColors.textSecondary,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // "+X weitere" Badge (rechts im Banner)
              if (additionalCount > 0) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onMoreTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: MshColors.warning,
                      borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+$additionalCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'weitere',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy', 'de_DE').format(date);
  }
}

class _NoticesSheet extends StatelessWidget {
  const _NoticesSheet({
    required this.notices,
    this.onLocationTap,
  });

  final List<MshNotice> notices;
  final void Function(double, double)? onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(MshSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: MshColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Alle Hinweise',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(MshSpacing.md),
              itemCount: notices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notice = notices[index];
                return _NoticeDetailCard(
                  notice: notice,
                  onLocationTap: notice.latitude != null && notice.longitude != null
                      ? () {
                          Navigator.pop(context);
                          onLocationTap?.call(notice.latitude!, notice.longitude!);
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeDetailCard extends StatelessWidget {
  const _NoticeDetailCard({
    required this.notice,
    this.onLocationTap,
  });

  final MshNotice notice;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final color = notice.color;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onLocationTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.md),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    notice.icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        notice.type.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MshColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    notice.severity.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Description
            if (notice.description != null) ...[
              const SizedBox(height: 12),
              Text(
                notice.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],

            // Details
            const SizedBox(height: 12),
            if (notice.affectedArea != null)
              _InfoRow(
                icon: Icons.place,
                label: notice.affectedArea!,
              ),
            if (notice.validFrom != null || notice.validUntil != null)
              _InfoRow(
                icon: Icons.calendar_today,
                label: _formatDateRange(notice.validFrom, notice.validUntil),
              ),
            if (notice.timeStart != null)
              _InfoRow(
                icon: Icons.access_time,
                label:
                    '${notice.timeStart}${notice.timeEnd != null ? " - ${notice.timeEnd}" : ""} Uhr',
              ),

            // Source
            if (notice.sourceUrl != null) ...[
              const SizedBox(height: 8),
              Text(
                'Quelle: ${Uri.parse(notice.sourceUrl!).host}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],

            // Auf Karte anzeigen Button
            if (onLocationTap != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, size: 16, color: color),
                        const SizedBox(width: 6),
                        Text(
                          'Auf Karte anzeigen',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  String _formatDateRange(DateTime? from, DateTime? until) {
    final formatter = DateFormat('dd.MM.yyyy', 'de_DE');
    if (from != null && until != null) {
      return '${formatter.format(from)} - ${formatter.format(until)}';
    } else if (from != null) {
      return 'Ab ${formatter.format(from)}';
    } else if (until != null) {
      return 'Bis ${formatter.format(until)}';
    }
    return 'Datum unbekannt';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: MshColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
