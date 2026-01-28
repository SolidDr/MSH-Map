/// MSH Map - Erleben Screen (Events & Engagement)
///
/// Kombinierter Screen für:
/// - Veranstaltungen mit Timeline
/// - Bürgerbeteiligung & Engagement
/// - Kulturelle Angebote
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_spacing.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../../../features/analytics/data/usage_analytics_service.dart';
import '../../../../features/engagement/application/engagement_provider.dart';
import '../../../../features/engagement/data/engagement_repository.dart';
import '../../../../features/engagement/domain/engagement_model.dart';
import '../../../../features/engagement/presentation/engagement_detail_sheet.dart';
import '../../../../shared/widgets/msh_bottom_sheet.dart';
import '../../../../shared/widgets/msh_engagement_card.dart';
import '../../../../shared/widgets/msh_timeline_card.dart';
import '../../data/events_providers.dart';
import '../../domain/event.dart';

/// Erleben Screen - Events & Engagement Hub
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EventCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Track module visit
    UsageAnalyticsService().trackModuleVisit('events');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: const Text('Erleben'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.event),
                  text: 'Events',
                ),
                Tab(
                  icon: Icon(Icons.volunteer_activism),
                  text: 'Mitmachen',
                ),
              ],
              indicatorColor: MshColors.primary,
              labelColor: MshColors.primary,
              unselectedLabelColor: MshColors.textSecondary,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Events
            _buildEventsTab(),

            // Tab 2: Engagement/Mitmachen
            _buildEngagementTab(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EVENTS TAB
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEventsTab() {
    final eventsAsync = _selectedCategory == null
        ? ref.watch(allEventsProvider)
        : ref.watch(eventsByCategoryProvider(_selectedCategory!));

    return Column(
      children: [
        // Category Filter
        _buildCategoryFilter(),

        // Events List
        Expanded(
          child: eventsAsync.when(
            data: _buildEventsList,
            loading: () => const Center(
              child: CircularProgressIndicator(color: MshColors.primary),
            ),
            error: (error, _) => _buildErrorState(error.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: MshColors.surface,
        border: Border(
          bottom: BorderSide(
            color: MshColors.textMuted.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: MshSpacing.lg,
          vertical: MshSpacing.sm,
        ),
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

  Widget _buildEventsList(List<MshEvent> events) {
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    // Gruppiere Events nach Datum
    final today = DateTime.now();
    final todayEvents = <MshEvent>[];
    final upcomingEvents = <MshEvent>[];

    for (final event in events) {
      if (event.date.year == today.year &&
          event.date.month == today.month &&
          event.date.day == today.day) {
        todayEvents.add(event);
      } else {
        upcomingEvents.add(event);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(MshSpacing.lg),
      children: [
        // Heute
        if (todayEvents.isNotEmpty) ...[
          _buildSectionHeader(context, 'Heute', todayEvents.length),
          const SizedBox(height: MshSpacing.sm),
          ...todayEvents.map((event) => _buildEventCard(event, isToday: true)),
          const SizedBox(height: MshSpacing.lg),
        ],

        // Kommende Events
        if (upcomingEvents.isNotEmpty) ...[
          _buildSectionHeader(context, 'Kommende Events', upcomingEvents.length),
          const SizedBox(height: MshSpacing.sm),
          ...upcomingEvents
              .take(10) // Max 10 zur Übersichtlichkeit
              .map((event) => _buildEventCard(event, isToday: false)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: MshColors.textStrong,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: MshColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MshSpacing.sm),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: MshColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(MshEvent event, {required bool isToday}) {
    final status = isToday
        ? MshTimelineStatus.today
        : event.date.isBefore(DateTime.now())
            ? MshTimelineStatus.past
            : MshTimelineStatus.upcoming;

    return MshTimelineCard(
      title: event.name,
      subtitle: '${event.city} • ${event.locationName}',
      timeLabel: event.timeStart ?? 'Ganztägig',
      dateLabel: _formatDate(event.date),
      status: status,
      tags: [event.eventCategory.label],
      onTap: () => _showEventDetails(event),
    );
  }

  void _showEventDetails(MshEvent event) {
    MshBottomSheet.show(
      context: context,
      title: event.name,
      subtitle: event.eventCategory.label,
      icon: event.eventCategory.icon,
      iconColor: event.eventCategory.color,
      size: MshBottomSheetSize.large,
      builder: (context) => _EventDetailsContent(event: event),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ENGAGEMENT TAB
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEngagementTab() {
    final needsAsync = ref.watch(currentNeedsProvider);

    return needsAsync.when(
      data: _buildEngagementContent,
      loading: () => const Center(
        child: CircularProgressIndicator(color: MshColors.primary),
      ),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEngagementContent(List<EngagementNeedWithPlace> needs) {
    // Sortiere nach Dringlichkeit
    final urgentNeeds = needs
        .where((n) =>
            n.need.urgency == UrgencyLevel.urgent ||
            n.need.urgency == UrgencyLevel.critical,)
        .toList();
    final otherNeeds = needs
        .where((n) =>
            n.need.urgency != UrgencyLevel.urgent &&
            n.need.urgency != UrgencyLevel.critical,)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(MshSpacing.lg),
      children: [
        // Intro Text
        Container(
          padding: const EdgeInsets.all(MshSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MshColors.primary.withValues(alpha: 0.1),
                MshColors.primaryLight.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.favorite,
                color: MshColors.primary,
                size: 32,
              ),
              const SizedBox(width: MshSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mach mit!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: MshColors.textStrong,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gestalte die Region aktiv mit',
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

        const SizedBox(height: MshSpacing.lg),

        // Dringende Beteiligungen
        if (urgentNeeds.isNotEmpty) ...[
          _buildSectionHeader(context, 'Aktuell dringend', urgentNeeds.length),
          const SizedBox(height: MshSpacing.sm),
          ...urgentNeeds.map((needWithPlace) => Padding(
                padding: const EdgeInsets.only(bottom: MshSpacing.md),
                child: _buildEngagementCard(needWithPlace, compact: false),
              ),),
          const SizedBox(height: MshSpacing.lg),
        ],

        // Weitere Möglichkeiten
        if (otherNeeds.isNotEmpty) ...[
          _buildSectionHeader(context, 'Weitere Möglichkeiten', otherNeeds.length),
          const SizedBox(height: MshSpacing.sm),
          ...otherNeeds.map((needWithPlace) => Padding(
                padding: const EdgeInsets.only(bottom: MshSpacing.sm),
                child: _buildEngagementCard(needWithPlace, compact: true),
              ),),
        ],

        // Fallback wenn keine Daten
        if (needs.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volunteer_activism,
                  size: 64,
                  color: MshColors.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: MshSpacing.md),
                Text(
                  'Aktuell keine Aktionen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: MshColors.textSecondary,
                      ),
                ),
                const SizedBox(height: MshSpacing.xs),
                Text(
                  'Schauen Sie später wieder vorbei',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MshColors.textMuted,
                      ),
                ),
              ],
            ),
          ),

        const SizedBox(height: MshSpacing.xxl),
      ],
    );
  }

  Widget _buildEngagementCard(EngagementNeedWithPlace needWithPlace, {required bool compact}) {
    final need = needWithPlace.need;
    final place = needWithPlace.place;

    // Mappe UrgencyLevel auf MshEngagementUrgency
    final urgency = switch (need.urgency) {
      UrgencyLevel.critical => MshEngagementUrgency.critical,
      UrgencyLevel.urgent => MshEngagementUrgency.urgent,
      UrgencyLevel.elevated => MshEngagementUrgency.elevated,
      UrgencyLevel.normal => MshEngagementUrgency.normal,
    };

    // Mappe NeedCategory auf MshEngagementType
    final type = switch (need.category) {
      NeedCategory.volunteers => MshEngagementType.volunteer,
      NeedCategory.money || NeedCategory.goods || NeedCategory.food => MshEngagementType.donation,
      NeedCategory.time || NeedCategory.transport => MshEngagementType.volunteer,
      NeedCategory.expertise => MshEngagementType.workshop,
      _ => MshEngagementType.participation, // other, fosterHome, etc.
    };

    return MshEngagementCard(
      title: need.title,
      subtitle: place.name,
      description: compact ? null : need.description,
      urgency: urgency,
      type: type,
      deadline: need.neededBy,
      location: place.city,
      compact: compact,
      onTap: () => _showEngagementDetails(place),
    );
  }

  void _showEngagementDetails(EngagementPlace place) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EngagementDetailSheet(place: place),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: MshColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: MshSpacing.md),
          Text(
            'Keine Events gefunden',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: MshColors.textSecondary,
                ),
          ),
          const SizedBox(height: MshSpacing.xs),
          Text(
            'Versuche einen anderen Filter',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MshColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: MshColors.error,
          ),
          const SizedBox(height: MshSpacing.md),
          Text(
            'Fehler beim Laden',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: MshColors.error,
                ),
          ),
          const SizedBox(height: MshSpacing.xs),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MshColors.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Heute';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Morgen';
    } else {
      final weekday = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][date.weekday - 1];
      return '$weekday, ${date.day}.${date.month}.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// CATEGORY CHIP
// ═══════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.only(right: MshSpacing.sm),
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
              const SizedBox(width: MshSpacing.xs),
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
        padding: const EdgeInsets.symmetric(
          horizontal: MshSpacing.sm,
          vertical: MshSpacing.xs,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EVENT DETAILS CONTENT
// ═══════════════════════════════════════════════════════════════

class _EventDetailsContent extends StatelessWidget {
  const _EventDetailsContent({required this.event});

  final MshEvent event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Datum & Zeit
        _buildDetailRow(
          context,
          icon: Icons.calendar_today,
          label: 'Datum',
          value: '${event.date.day}.${event.date.month}.${event.date.year}',
        ),

        if (event.timeStart != null)
          _buildDetailRow(
            context,
            icon: Icons.access_time,
            label: 'Uhrzeit',
            value: event.timeEnd != null
                ? '${event.timeStart} - ${event.timeEnd} Uhr'
                : '${event.timeStart} Uhr',
          ),

        _buildDetailRow(
          context,
          icon: Icons.location_on,
          label: 'Ort',
          value: '${event.locationName}\n${event.city}',
        ),

        const SizedBox(height: MshSpacing.lg),

        // Beschreibung
        Text(
          'Beschreibung',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: MshColors.textStrong,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshSpacing.sm),
        Text(
          event.description ?? 'Keine Beschreibung verfügbar.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MshColors.textPrimary,
                height: MshSpacing.phi,
              ),
        ),

        const SizedBox(height: MshSpacing.xl),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: In Kalender speichern
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Speichern'),
              ),
            ),
            const SizedBox(width: MshSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // TODO: Route zur Location
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.directions),
                label: const Text('Route'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MshSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(MshSpacing.sm),
            decoration: BoxDecoration(
              color: MshColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
            ),
            child: Icon(icon, size: 18, color: MshColors.primary),
          ),
          const SizedBox(width: MshSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: MshColors.textMuted,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MshColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
