import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';
import 'data/events_repository.dart';
import 'domain/event.dart';

/// Events Module - MSH Radar Events & Veranstaltungen
class EventsModule extends MshModule {
  EventsModule() : _repository = EventsRepository();

  final EventsRepository _repository;
  List<MshEvent> _cachedEvents = [];

  @override
  String get moduleId => 'events';

  @override
  String get displayName => 'Events';

  @override
  IconData get icon => Icons.event;

  @override
  Color get primaryColor => MshColors.categoryEvent;

  @override
  Future<void> initialize() async {
    // Load events into cache
    _cachedEvents = await _repository.getAllEvents();
  }

  @override
  Future<void> dispose() async {
    _cachedEvents = [];
  }

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) async* {
    // Initial load
    yield await getItemsInRegion(region);

    // In a real implementation, this could watch for updates
    // For now, just return the initial data
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) async {
    // Filter cached events by bounding box
    return _cachedEvents.where((event) {
      return region.contains(event.coordinates);
    }).toList();
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is! MshEvent) {
      return const Center(child: Text('Ungültiges Event'));
    }

    // Use the same detail view from UpcomingEventsWidget
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(item.description ?? 'Keine Beschreibung verfügbar'),
        ],
      ),
    );
  }
}
