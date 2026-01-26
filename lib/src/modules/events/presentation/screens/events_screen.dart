import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../data/events_providers.dart';
import '../../domain/event.dart';
import '../widgets/upcoming_events_widget.dart';

/// Screen showing all events
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  EventCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = _selectedCategory == null
        ? ref.watch(allEventsProvider)
        : ref.watch(eventsByCategoryProvider(_selectedCategory!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veranstaltungen'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildCategoryFilter(),
        ),
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keine Events gefunden',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versuche einen anderen Filter',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(MshTheme.spacingMd),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _EventCard(event: events[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _CategoryChip(
            label: 'Alle',
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...EventCategory.values.map(
            (category) => _CategoryChip(
              label: category.label,
              icon: category.icon,
              color: category.color,
              isSelected: _selectedCategory == category,
              onTap: () => setState(() => _selectedCategory = category),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? MshColors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: chipColor.withValues(alpha: 0.1),
        selectedColor: chipColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final MshEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Reuse the detail sheet from UpcomingEventsWidget
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _EventDetailsSheet(event: event),
          );
        },
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(MshTheme.spacingMd),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: event.eventCategory.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                ),
                child: Icon(
                  event.eventCategory.icon,
                  color: event.eventCategory.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: MshColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: MshColors.textSecondary,
                              ),
                        ),
                        if (event.timeStart != null) ...[
                          const SizedBox(width: 12),
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
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: MshColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${event.city} • ${event.locationName}',
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
              const Icon(
                Icons.chevron_right,
                color: MshColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Heute';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Morgen';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}

// Import the detail sheet from upcoming_events_widget (simplified version here)
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

                  // Event details
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(event.description ?? 'Keine Beschreibung verfügbar'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
