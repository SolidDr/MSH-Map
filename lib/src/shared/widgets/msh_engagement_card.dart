/// MSH Map - Engagement Card Component
///
/// Urgency-basierte Engagement-Karte für:
/// - Bürgerbeteiligung
/// - Ehrenamtliche Aktionen
/// - Spendenaufrufe
/// - Zeitkritische Angebote
library;

import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';

/// Dringlichkeitsstufen mit 4-Level Hierarchie
enum MshEngagementUrgency {
  /// Kritisch - Sofortiger Handlungsbedarf (rot)
  critical(
    color: MshColors.engagementCritical,
    icon: Icons.priority_high,
    label: 'Dringend',
  ),

  /// Urgent - Zeitnah (orange)
  urgent(
    color: MshColors.engagementUrgent,
    icon: Icons.warning_amber_outlined,
    label: 'Zeitnah',
  ),

  /// Erhöht - Bald (amber)
  elevated(
    color: MshColors.engagementElevated,
    icon: Icons.schedule,
    label: 'Bald',
  ),

  /// Normal - Kein Zeitdruck (grün)
  normal(
    color: MshColors.engagementNormal,
    icon: Icons.check_circle_outline,
    label: 'Offen',
  );

  const MshEngagementUrgency({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;
}

/// Engagement-Typ
enum MshEngagementType {
  /// Bürgerbeteiligung
  participation(icon: Icons.how_to_vote, label: 'Beteiligung'),

  /// Ehrenamt
  volunteer(icon: Icons.volunteer_activism, label: 'Ehrenamt'),

  /// Spende
  donation(icon: Icons.favorite, label: 'Spende'),

  /// Umfrage
  survey(icon: Icons.poll, label: 'Umfrage'),

  /// Workshop/Veranstaltung
  workshop(icon: Icons.groups, label: 'Workshop'),

  /// Petition
  petition(icon: Icons.edit_document, label: 'Petition');

  const MshEngagementType({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Engagement Card für Bürgerbeteiligung
///
/// Verwendung:
/// ```dart
/// MshEngagementCard(
///   title: 'Stadtentwicklung 2030',
///   subtitle: 'Ihre Meinung ist gefragt!',
///   urgency: MshEngagementUrgency.urgent,
///   type: MshEngagementType.participation,
///   deadline: DateTime.now().add(Duration(days: 5)),
///   participantCount: 234,
///   targetCount: 500,
///   onTap: () => ...,
/// )
/// ```
class MshEngagementCard extends StatelessWidget {
  const MshEngagementCard({
    required this.title,
    required this.urgency,
    required this.type,
    super.key,
    this.subtitle,
    this.description,
    this.deadline,
    this.participantCount,
    this.targetCount,
    this.imageUrl,
    this.location,
    this.onTap,
    this.showProgress = true,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final String? description;
  final MshEngagementUrgency urgency;
  final MshEngagementType type;
  final DateTime? deadline;
  final int? participantCount;
  final int? targetCount;
  final String? imageUrl;
  final String? location;
  final VoidCallback? onTap;
  final bool showProgress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium), // 13px
        child: Container(
          decoration: BoxDecoration(
            color: MshColors.surface,
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
            border: Border.all(
              color: urgency.color.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: urgency.color.withValues(alpha: 0.08),
                blurRadius: MshSpacing.sm, // 8px
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Urgency Banner
              _buildUrgencyBanner(context),

              // Image (optional)
              if (imageUrl != null && !compact) _buildImage(),

              // Content
              Padding(
                padding: EdgeInsets.all(
                  compact ? MshSpacing.sm : MshSpacing.md,
                ), // 8px or 13px
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Badge & Deadline
                    _buildHeaderRow(context),

                    SizedBox(height: compact ? MshSpacing.xs : MshSpacing.sm),

                    // Title
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: MshColors.textStrong,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtitle
                    if (subtitle != null && !compact) ...[
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

                    // Description
                    if (description != null && !compact) ...[
                      const SizedBox(height: MshSpacing.sm), // 8px
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MshColors.textPrimary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Progress Bar
                    if (showProgress &&
                        participantCount != null &&
                        targetCount != null &&
                        !compact) ...[
                      const SizedBox(height: MshSpacing.md), // 13px
                      _buildProgressBar(context),
                    ],

                    // Location
                    if (location != null && !compact) ...[
                      const SizedBox(height: MshSpacing.sm), // 8px
                      _buildLocation(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? MshSpacing.sm : MshSpacing.md,
        vertical: compact ? 4 : MshSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: urgency.color.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(MshTheme.radiusMedium - 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            urgency.icon,
            size: compact ? 14 : 16,
            color: urgency.color,
          ),
          const SizedBox(width: MshSpacing.xs), // 5px
          Text(
            urgency.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: urgency.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          if (deadline != null) _buildDeadlineChip(context),
        ],
      ),
    );
  }

  Widget _buildDeadlineChip(BuildContext context) {
    final daysLeft = deadline!.difference(DateTime.now()).inDays;
    final String deadlineText;

    if (daysLeft < 0) {
      deadlineText = 'Abgelaufen';
    } else if (daysLeft == 0) {
      deadlineText = 'Heute';
    } else if (daysLeft == 1) {
      deadlineText = 'Morgen';
    } else if (daysLeft < 7) {
      deadlineText = 'Noch $daysLeft Tage';
    } else {
      deadlineText = 'Noch ${(daysLeft / 7).floor()} Wochen';
    }

    return Text(
      deadlineText,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: urgency.color,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      child: AspectRatio(
        aspectRatio: MshSpacing.phi, // Golden Ratio 1.618
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: urgency.color.withValues(alpha: 0.1),
            child: Icon(
              type.icon,
              size: 48,
              color: urgency.color.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        // Type Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm, // 8px
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: MshColors.textMuted.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MshSpacing.xs), // 5px
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type.icon,
                size: 12,
                color: MshColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                type.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MshColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Participant Count (compact view)
        if (participantCount != null && compact)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_outline,
                size: 14,
                color: MshColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                participantCount.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MshColors.textMuted,
                    ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = (participantCount! / targetCount!).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$participantCount von $targetCount',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: MshColors.textSecondary,
                  ),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: urgency.color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),

        const SizedBox(height: MshSpacing.xs), // 5px

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(MshSpacing.xs), // 5px
          child: LinearProgressIndicator(
            value: progress,
            minHeight: MshSpacing.xs, // 5px
            backgroundColor: MshColors.textMuted.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(urgency.color),
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: MshColors.textMuted,
        ),
        const SizedBox(width: MshSpacing.xs), // 5px
        Expanded(
          child: Text(
            location!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MshColors.textMuted,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Horizontale scrollbare Liste von Engagement Cards
class MshEngagementCardRow extends StatelessWidget {
  const MshEngagementCardRow({
    required this.children,
    super.key,
    this.padding,
    this.cardWidth,
  });

  final List<Widget> children;
  final EdgeInsets? padding;
  final double? cardWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: MshSpacing.lg, // 21px
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            SizedBox(
              width: cardWidth ?? 280, // Golden Ratio friendly width
              child: children[i],
            ),
            if (i < children.length - 1)
              const SizedBox(width: MshSpacing.md), // 13px
          ],
        ],
      ),
    );
  }
}
