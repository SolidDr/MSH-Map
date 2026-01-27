/// MSH Map - Up Next Events Section
///
/// Kompakte Event-Vorschau für den Home-Screen
/// Zeigt die nächsten 2-3 Events als horizontale Scroll-Karten
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';
import '../../modules/events/data/events_providers.dart';
import '../../modules/events/domain/event.dart';

/// Kompakte "Up Next" Events-Sektion
class UpNextSection extends ConsumerWidget {
  const UpNextSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) return const SizedBox.shrink();

        // Nur die nächsten 3 Events anzeigen
        final upNext = events.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: MshColors.primary,
                  ),
                  const SizedBox(width: MshSpacing.xs),
                  Text(
                    'Demnächst',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: MshColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/events'),
                    child: Text(
                      'Alle →',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: MshColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: MshSpacing.sm),

            // Horizontal Event Cards
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
                itemCount: upNext.length,
                separatorBuilder: (_, __) => const SizedBox(width: MshSpacing.sm),
                itemBuilder: (context, index) => _CompactEventCard(
                  event: upNext[index],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Kompakte Event-Karte für horizontales Scrollen
class _CompactEventCard extends StatelessWidget {
  const _CompactEventCard({required this.event});

  final MshEvent event;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(event.date);
    final isTomorrow = _isTomorrow(event.date);

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isToday
            ? MshColors.primary.withValues(alpha: 0.1)
            : MshColors.background,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(
          color: isToday
              ? MshColors.primary.withValues(alpha: 0.3)
              : MshColors.textMuted.withValues(alpha: 0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/events'),
          borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(MshSpacing.sm),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: event.eventCategory.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                  ),
                  child: Icon(
                    event.eventCategory.icon,
                    color: event.eventCategory.color,
                    size: 20,
                  ),
                ),

                const SizedBox(width: MshSpacing.sm),

                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Date Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isToday
                              ? MshColors.primary
                              : MshColors.textMuted.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDateLabel(event.date, isToday, isTomorrow),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isToday ? Colors.white : MshColors.textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Event Name
                      Text(
                        event.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: MshColors.textPrimary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Time & Location
                      Text(
                        '${event.timeStart ?? ""} ${event.city}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: MshColors.textMuted,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  String _formatDateLabel(DateTime date, bool isToday, bool isTomorrow) {
    if (isToday) return 'Heute';
    if (isTomorrow) return 'Morgen';
    return DateFormat('E dd.MM.', 'de_DE').format(date);
  }
}
