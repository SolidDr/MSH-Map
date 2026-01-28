import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';
import 'data/outdoor_repository.dart';
import 'domain/hiking_stamp.dart';

/// Modul für Outdoor-Aktivitäten (Wandernadel, etc.)
class OutdoorModule extends MshModule {
  OutdoorModule({OutdoorRepository? repository})
      : _repository = repository ?? OutdoorRepository();

  final OutdoorRepository _repository;

  @override
  String get moduleId => 'outdoor';

  @override
  String get displayName => 'Wandern';

  @override
  IconData get icon => Icons.hiking;

  @override
  Color get primaryColor => MshColors.categoryHikingStamp;

  @override
  Future<void> initialize() async {
    // Daten aus Assets vorladen
    await _repository.loadHikingStamps();
  }

  @override
  Future<void> dispose() async {
    _repository.dispose();
  }

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return _repository.watchStampsInRegion(region);
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) {
    return _repository.getStampsInRegion(region);
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is HikingStamp) {
      return _HikingStampDetailContent(stamp: item);
    }
    return const Text('Unbekannter Typ');
  }

  @override
  List<FilterOption> get filterOptions => [
        FilterOption(
          id: 'outdoor_barrier_free',
          label: 'Barrierefrei',
          icon: Icons.accessible,
          predicate: (item) => item is HikingStamp && item.isBarrierFree,
        ),
        FilterOption(
          id: 'outdoor_24h',
          label: '24/7 zugänglich',
          icon: Icons.access_time,
          predicate: (item) => item is HikingStamp && item.is24h,
        ),
      ];

  /// Zugriff auf das Repository für erweiterte Abfragen
  OutdoorRepository get repository => _repository;
}

/// Detail-Ansicht für Wandernadel-Stempelstellen
class _HikingStampDetailContent extends StatelessWidget {
  const _HikingStampDetailContent({required this.stamp});

  final HikingStamp stamp;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stempelnummer Badge
          if (stamp.stampNumber != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MshColors.categoryHikingStamp,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nr. ${stamp.stampNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Name
          Text(
            stamp.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          // Beschreibung
          if (stamp.description != null) ...[
            const SizedBox(height: 8),
            Text(
              stamp.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],

          const Divider(height: 24),

          // Info-Zeilen
          if (stamp.city != null)
            _InfoRow(icon: Icons.location_city, label: 'Region', value: stamp.city!),
          if (stamp.elevation != null)
            _InfoRow(icon: Icons.terrain, label: 'Höhe', value: stamp.elevation!),
          if (stamp.stampSeries != null)
            _InfoRow(icon: Icons.collections_bookmark, label: 'Serie', value: stamp.stampSeries!),
          if (stamp.operator != null)
            _InfoRow(icon: Icons.business, label: 'Betreiber', value: stamp.operator!),

          const SizedBox(height: 16),

          // Status-Chips
          Wrap(
            spacing: 8,
            children: [
              if (stamp.is24h)
                Chip(
                  avatar: const Icon(Icons.access_time, size: 18),
                  label: const Text('24/7 zugänglich'),
                  backgroundColor: Colors.green.shade100,
                ),
              if (stamp.isBarrierFree)
                Chip(
                  avatar: const Icon(Icons.accessible, size: 18),
                  label: const Text('Barrierefrei'),
                  backgroundColor: Colors.blue.shade100,
                ),
            ],
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
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: MshColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(color: MshColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
