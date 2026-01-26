import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../data/events_providers.dart';
import '../../domain/event.dart';

/// Widget to display upcoming events
class UpcomingEventsWidget extends ConsumerWidget {
  const UpcomingEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const SizedBox.shrink();
        }

        // Group by date
        final grouped = _groupByDate(events);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: MshColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Veranstaltungen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/events'),
                  child: const Text('Alle anzeigen'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Show next 3 days
            ...grouped.entries.take(3).map(
                  (entry) => _DateSection(
                    date: entry.key,
                    events: entry.value,
                  ),
                ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(MshTheme.spacingMd),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Text('Fehler beim Laden der Events: $error'),
      ),
    );
  }

  Map<DateTime, List<MshEvent>> _groupByDate(List<MshEvent> events) {
    final map = <DateTime, List<MshEvent>>{};
    for (final event in events) {
      final dateOnly = DateTime(event.date.year, event.date.month, event.date.day);
      map.putIfAbsent(dateOnly, () => []).add(event);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection({
    required this.date,
    required this.events,
  });

  final DateTime date;
  final List<MshEvent> events;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final isTomorrow = _isTomorrow(date);

    final dateLabel = isToday
        ? 'Heute'
        : isTomorrow
            ? 'Morgen'
            : _formatDate(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isToday ? MshColors.primary : MshColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isToday ? Colors.white : MshColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...events.map((e) => _EventCard(event: e)),
        const SizedBox(height: 16),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, dd.MM.', 'de_DE').format(date);
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final MshEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Show event details
          _showEventDetails(context, event);
        },
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(MshTheme.spacingSm),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: event.eventCategory.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                ),
                child: Icon(
                  event.eventCategory.icon,
                  color: event.eventCategory.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (event.timeStart != null) ...[
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: MshColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.timeStart} Uhr',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: MshColors.textSecondary,
                                ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: MshColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            event.city,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: MshColors.textSecondary,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: MshColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, MshEvent event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailsSheet(event: event),
    );
  }
}

class _EventDetailsSheet extends StatelessWidget {
  const _EventDetailsSheet({required this.event});

  final MshEvent event;

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

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MshTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: event.eventCategory.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          event.eventCategory.icon,
                          size: 16,
                          color: event.eventCategory.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event.eventCategory.label,
                          style: TextStyle(
                            color: event.eventCategory.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Date & Time
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: DateFormat('EEEE, dd. MMMM yyyy', 'de_DE').format(event.date),
                  ),
                  if (event.timeStart != null)
                    _InfoRow(
                      icon: Icons.access_time,
                      label: '${event.timeStart}${event.timeEnd != null ? " - ${event.timeEnd}" : ""} Uhr',
                    ),

                  const SizedBox(height: 8),

                  // Location
                  _InfoRow(
                    icon: Icons.location_on,
                    label: event.locationName,
                  ),
                  _InfoRow(
                    icon: Icons.place,
                    label: event.city,
                  ),

                  const SizedBox(height: 8),

                  // Price
                  if (event.price != null)
                    _InfoRow(
                      icon: Icons.payments,
                      label: event.price!,
                    ),

                  const SizedBox(height: 16),

                  // Description
                  if (event.description != null) ...[
                    Text(
                      'Beschreibung',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (event.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: event.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              labelStyle: const TextStyle(fontSize: 12),
                              backgroundColor: MshColors.surfaceVariant,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Source
                  if (event.sourceUrl != null)
                    Text(
                      'Quelle: ${Uri.parse(event.sourceUrl!).host}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MshColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: MshColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
