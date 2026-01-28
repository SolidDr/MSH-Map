/// MSH Map - Timeline Card Component
///
/// Event-Karte mit Timeline-Indikator für:
/// - Events & Veranstaltungen
/// - Zeitlich begrenzte Aktionen
/// - Chronologische Darstellung
library;

import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';

/// Status eines Timeline-Events
enum MshTimelineStatus {
  /// Vergangen
  past(color: MshColors.textMuted, icon: Icons.check_circle_outline),

  /// Läuft gerade
  active(color: MshColors.engagementUrgent, icon: Icons.play_circle_outline),

  /// Kommend
  upcoming(color: MshColors.primary, icon: Icons.schedule),

  /// Heute
  today(color: MshColors.engagementCritical, icon: Icons.today);

  const MshTimelineStatus({required this.color, required this.icon});

  final Color color;
  final IconData icon;
}

/// Timeline Card für Events
///
/// Verwendung:
/// ```dart
/// MshTimelineCard(
///   title: 'Wochenmarkt',
///   subtitle: 'Marktplatz',
///   timeLabel: '08:00 - 13:00',
///   dateLabel: 'Heute',
///   status: MshTimelineStatus.active,
///   onTap: () => ...,
/// )
/// ```
class MshTimelineCard extends StatelessWidget {
  const MshTimelineCard({
    required this.title,
    required this.timeLabel,
    super.key,
    this.subtitle,
    this.dateLabel,
    this.status = MshTimelineStatus.upcoming,
    this.icon,
    this.imageUrl,
    this.tags,
    this.onTap,
    this.showTimelineConnector = false,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
  final String? subtitle;
  final String timeLabel;
  final String? dateLabel;
  final MshTimelineStatus status;
  final IconData? icon;
  final String? imageUrl;
  final List<String>? tags;
  final VoidCallback? onTap;
  final bool showTimelineConnector;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Indicator
          if (showTimelineConnector) _buildTimelineIndicator(),

          // Card Content
          Expanded(
            child: _buildCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return SizedBox(
      width: MshSpacing.xl, // 34px
      child: Column(
        children: [
          // Top Connector
          if (!isFirst)
            Expanded(
              child: Container(
                width: 2,
                color: MshColors.textMuted.withValues(alpha: 0.3),
              ),
            ),

          // Dot
          Container(
            width: MshSpacing.md, // 13px
            height: MshSpacing.md, // 13px
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: MshColors.surface,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: status.color.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),

          // Bottom Connector
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: MshColors.textMuted.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: MshSpacing.md, // 13px
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MshTheme.radiusMedium), // 13px
          child: Container(
            decoration: BoxDecoration(
              color: MshColors.surface,
              borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
              border: Border.all(
                color: status == MshTimelineStatus.active
                    ? status.color.withValues(alpha: 0.5)
                    : MshColors.textMuted.withValues(alpha: 0.2),
                width: status == MshTimelineStatus.active ? 2 : 1,
              ),
              boxShadow: status == MshTimelineStatus.active
                  ? [
                      BoxShadow(
                        color: status.color.withValues(alpha: 0.1),
                        blurRadius: MshSpacing.sm, // 8px
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image (optional)
                if (imageUrl != null) _buildImage(),

                // Content
                Padding(
                  padding: const EdgeInsets.all(MshSpacing.md), // 13px
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      _buildHeader(context),

                      const SizedBox(height: MshSpacing.sm), // 8px

                      // Title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: MshColors.textStrong,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Subtitle
                      if (subtitle != null) ...[
                        const SizedBox(height: MshSpacing.xs), // 5px
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: MshColors.textSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Tags
                      if (tags != null && tags!.isNotEmpty) ...[
                        const SizedBox(height: MshSpacing.sm), // 8px
                        _buildTags(context),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(MshTheme.radiusMedium - 1),
      ),
      child: AspectRatio(
        aspectRatio: MshSpacing.phi, // Golden Ratio 1.618
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: MshColors.textMuted.withValues(alpha: 0.1),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: MshColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Status Icon
        Icon(
          status.icon,
          size: 16,
          color: status.color,
        ),

        const SizedBox(width: MshSpacing.xs), // 5px

        // Date Label
        if (dateLabel != null)
          Text(
            dateLabel!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
          ),

        const Spacer(),

        // Time Label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm, // 8px
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MshSpacing.xs), // 5px
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time,
                size: 12,
                color: MshColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                timeLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MshColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: MshSpacing.xs, // 5px
      runSpacing: MshSpacing.xs, // 5px
      children: tags!
          .take(3) // Max 3 Tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MshSpacing.sm, // 8px
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: MshColors.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MshSpacing.xs), // 5px
              ),
              child: Text(
                tag,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MshColors.textSecondary,
                    ),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Timeline List Builder
class MshTimelineList extends StatelessWidget {
  const MshTimelineList({
    required this.items,
    super.key,
    this.padding,
    this.showConnectors = true,
  });

  final List<MshTimelineCard> items;
  final EdgeInsets? padding;
  final bool showConnectors;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? MshSpacing.screenPadding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MshTimelineCard(
          title: item.title,
          subtitle: item.subtitle,
          timeLabel: item.timeLabel,
          dateLabel: item.dateLabel,
          status: item.status,
          icon: item.icon,
          imageUrl: item.imageUrl,
          tags: item.tags,
          onTap: item.onTap,
          showTimelineConnector: showConnectors,
          isFirst: index == 0,
          isLast: index == items.length - 1,
        );
      },
    );
  }
}
