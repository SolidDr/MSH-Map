import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_spacing.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../data/events_providers.dart';
import '../../domain/notice.dart';

/// Banner to display important notices and warnings
class NoticeBanner extends ConsumerStatefulWidget {
  const NoticeBanner({super.key, this.onNoticeLocationTap});

  final void Function(double latitude, double longitude)? onNoticeLocationTap;

  @override
  ConsumerState<NoticeBanner> createState() => _NoticeBannerState();
}

class _NoticeBannerState extends ConsumerState<NoticeBanner> {
  // IDs der vom Benutzer geschlossenen Notices (für diese Session)
  final Set<String> _dismissedIds = {};

  @override
  Widget build(BuildContext context) {
    final noticesAsync = ref.watch(activeNoticesProvider);

    return noticesAsync.when(
      data: (notices) {
        if (notices.isEmpty) return const SizedBox.shrink();

        // Show only critical and warning notices, sorted by priority
        // Filter out dismissed notices
        final important = notices
            .where((n) =>
                (n.severity == NoticeSeverity.critical ||
                n.severity == NoticeSeverity.warning) &&
                !_dismissedIds.contains(n.id),)
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

        final firstNotice = important.first;

        // Ohne extra Margin - HomeScreen kontrolliert Abstände
        return _NoticeCard(
          notice: firstNotice,
          additionalCount: important.length - 1,
          onTap: firstNotice.latitude != null && firstNotice.longitude != null
              ? () => widget.onNoticeLocationTap?.call(
                    firstNotice.latitude!,
                    firstNotice.longitude!,
                  )
              : null,
          onMoreTap: important.length > 1
              ? () => _showAllNotices(context, important, widget.onNoticeLocationTap)
              : null,
          onDismiss: () => setState(() => _dismissedIds.add(firstNotice.id)),
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
    this.onDismiss,
  });

  final MshNotice notice;
  final VoidCallback? onTap;
  final int additionalCount;
  final VoidCallback? onMoreTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = notice.color;
    final icon = notice.icon;

    // Kompaktes Banner (~35px Höhe)
    return Material(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            // Icon (ohne Circle, kompakt)
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),

            // Titel (einzeilig mit Ellipsis)
            Expanded(
              child: Text(
                notice.title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // "+X" Badge (kompakt)
            if (additionalCount > 0) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onMoreTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+$additionalCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            // "Zur Karte" Button
            if (onTap != null) ...[
              const SizedBox(width: 6),
              _CompactIconButton(
                icon: Icons.map_outlined,
                color: color,
                tooltip: 'Auf Karte zeigen',
                onTap: onTap!,
              ),
            ],

            // "Schließen" Button
            if (onDismiss != null) ...[
              const SizedBox(width: 4),
              _CompactIconButton(
                icon: Icons.close,
                color: color,
                tooltip: 'Schließen',
                onTap: onDismiss!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kompakter Icon-Button für Banner-Actions
class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
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
