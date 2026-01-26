import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../data/events_providers.dart';
import '../../domain/notice.dart';

/// Banner to display important notices and warnings
class NoticeBanner extends ConsumerWidget {
  const NoticeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(activeNoticesProvider);

    return noticesAsync.when(
      data: (notices) {
        if (notices.isEmpty) return const SizedBox.shrink();

        // Show only critical and warning notices
        final important = notices
            .where((n) =>
                n.severity == NoticeSeverity.critical ||
                n.severity == NoticeSeverity.warning)
            .toList();

        if (important.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(MshTheme.spacingSm),
          child: Column(
            children: [
              // Show first notice
              _NoticeCard(notice: important.first),

              // Show count if there are more
              if (important.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () => _showAllNotices(context, notices),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: Text(
                      '+${important.length - 1} weitere Hinweise',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showAllNotices(BuildContext context, List<MshNotice> notices) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoticesSheet(notices: notices),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice});

  final MshNotice notice;

  @override
  Widget build(BuildContext context) {
    final color = notice.color;
    final icon = notice.icon;

    return Container(
      padding: const EdgeInsets.all(MshTheme.spacingSm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      notice.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                    ),
                    if (notice.severity == NoticeSeverity.critical) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'KRITISCH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (notice.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    notice.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (notice.validUntil != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: MshColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
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
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy', 'de_DE').format(date);
  }
}

class _NoticesSheet extends StatelessWidget {
  const _NoticesSheet({required this.notices});

  final List<MshNotice> notices;

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
            padding: const EdgeInsets.all(MshTheme.spacingMd),
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
              padding: const EdgeInsets.all(MshTheme.spacingMd),
              itemCount: notices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _NoticeDetailCard(notice: notices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeDetailCard extends StatelessWidget {
  const _NoticeDetailCard({required this.notice});

  final MshNotice notice;

  @override
  Widget build(BuildContext context) {
    final color = notice.color;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(MshTheme.spacingMd),
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
          ],
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
