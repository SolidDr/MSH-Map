import 'package:flutter/material.dart';

import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';

/// Stub: Such-Modul (Implementierung spaeter)
class SearchModule extends MshModule {
  @override
  String get moduleId => 'search';

  @override
  String get displayName => 'Suche';

  @override
  IconData get icon => Icons.search;

  @override
  Color get primaryColor => const Color(0xFF1976D2);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return Stream.value([]);
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) async {
    return [];
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('Regionale Suche - Coming Soon'),
        ],
      ),
    );
  }
}
