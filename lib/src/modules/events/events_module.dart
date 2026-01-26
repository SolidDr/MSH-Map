import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';

/// Stub: Events-Modul (Implementierung spaeter)
class EventsModule extends MshModule {
  @override
  String get moduleId => 'events';

  @override
  String get displayName => 'Events';

  @override
  IconData get icon => Icons.event;

  @override
  Color get primaryColor => MshColors.categoryEvent;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return Stream.value([]); // Keine Daten
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) async {
    return []; // Keine Daten
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('Events - Coming Soon'),
        ],
      ),
    );
  }
}
