import 'package:flutter/material.dart';
import '../../core/services/locations_service.dart';
import '../../shared/domain/asset_location.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';

/// Modul für das Laden von Locations aus Assets
class AssetLocationsModule extends MshModule {
  List<AssetLocation>? _cachedLocations;

  @override
  String get moduleId => 'asset_locations';

  @override
  String get displayName => 'MSH Locations';

  @override
  IconData get icon => Icons.map;

  @override
  Color get primaryColor => Colors.blueAccent;

  @override
  Future<void> initialize() async {
    // Locations beim Start laden
    final data = await LocationsService.loadLocations();
    _cachedLocations = data.map(AssetLocation.fromJson).toList();
  }

  @override
  Future<void> dispose() async {
    _cachedLocations = null;
  }

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) async* {
    final items = await getItemsInRegion(region);
    yield items;
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) async {
    // Lade Locations falls noch nicht gecacht
    if (_cachedLocations == null) {
      final data = await LocationsService.loadLocations();
      _cachedLocations = data.map(AssetLocation.fromJson).toList();
    }

    // Filtere nach BoundingBox
    return _cachedLocations!
        .where((location) => region.contains(location.coordinates))
        .cast<MapItem>()
        .toList();
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is AssetLocation) {
      return _AssetLocationDetail(location: item);
    }
    return const Text('Unbekannter Typ');
  }

  @override
  List<FilterOption> get filterOptions => [
        FilterOption(
          id: 'nature',
          label: 'Natur',
          icon: Icons.forest,
          predicate: (item) =>
              item is AssetLocation && item.category == MapItemCategory.nature,
        ),
        FilterOption(
          id: 'culture',
          label: 'Kultur',
          icon: Icons.theater_comedy,
          predicate: (item) =>
              item is AssetLocation && item.category == MapItemCategory.culture,
        ),
        FilterOption(
          id: 'gastro',
          label: 'Gastronomie',
          icon: Icons.restaurant,
          predicate: (item) =>
              item is AssetLocation &&
              (item.category == MapItemCategory.restaurant ||
                  item.category == MapItemCategory.cafe ||
                  item.category == MapItemCategory.imbiss),
        ),
        FilterOption(
          id: 'family',
          label: 'Familie',
          icon: Icons.family_restroom,
          predicate: (item) =>
              item is AssetLocation &&
              (item.category == MapItemCategory.playground ||
                  item.category == MapItemCategory.zoo ||
                  item.category == MapItemCategory.farm),
        ),
      ];
}

/// Detail-Widget für Asset Locations
class _AssetLocationDetail extends StatelessWidget {
  const _AssetLocationDetail({required this.location});

  final AssetLocation location;

  @override
  Widget build(BuildContext context) {
    final metadata = location.metadata;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            location.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Stadt
          if (location.subtitle != null)
            Row(
              children: [
                const Icon(Icons.location_city, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  location.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Beschreibung
          if (location.description.isNotEmpty) ...[
            Text(
              location.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          // Adresse
          if (metadata['address'] != null) ...[
            _buildInfoRow(
              context,
              Icons.location_on,
              'Adresse',
              metadata['address'] as String,
            ),
            const SizedBox(height: 8),
          ],

          // Öffnungszeiten
          if (metadata['openingHours'] != null) ...[
            _buildInfoRow(
              context,
              Icons.access_time,
              'Öffnungszeiten',
              metadata['openingHours'] as String,
            ),
            const SizedBox(height: 8),
          ],

          // Eintritt
          if (metadata['admissionFee'] != null) ...[
            _buildInfoRow(
              context,
              Icons.euro,
              'Eintritt',
              metadata['admissionFee'] as String,
            ),
            const SizedBox(height: 8),
          ],

          // Altersempfehlung
          if (metadata['ageRecommendation'] != null) ...[
            _buildInfoRow(
              context,
              Icons.child_care,
              'Alter',
              metadata['ageRecommendation'] as String,
            ),
            const SizedBox(height: 8),
          ],

          // Website
          if (metadata['website'] != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Launch URL
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Website öffnen'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],

          // Tags
          if (metadata['tags'] != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (metadata['tags'] as List<dynamic>)
                  .map(
                    (tag) => Chip(
                      label: Text(tag.toString()),
                      backgroundColor: Colors.grey[200],
                    ),
                  )
                  .toList(),
            ),
          ],

          // Features
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (metadata['parking'] == true)
                _buildFeatureChip(Icons.local_parking, 'Parkplatz'),
              if (metadata['accessibility'] != null)
                _buildFeatureChip(Icons.accessible, metadata['accessibility'] as String),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.blue[50],
    );
  }
}
