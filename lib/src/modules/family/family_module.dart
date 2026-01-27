import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';
import 'data/family_repository.dart';
import 'domain/poi.dart';
import 'presentation/poi_detail.dart';

class FamilyModule extends MshModule {
  FamilyModule({FamilyRepository? repository})
      : _repository = repository ?? FamilyRepository();

  final FamilyRepository _repository;

  @override
  String get moduleId => 'family';

  @override
  String get displayName => 'Freizeit & Familie';

  @override
  IconData get icon => Icons.family_restroom;

  @override
  Color get primaryColor => MshColors.categoryFamily;

  @override
  Future<void> initialize() async {
    // Optional: Initiale Daten laden
  }

  @override
  Future<void> dispose() async {}

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return _repository.watchPoisInRegion(region);
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) {
    return _repository.getPoisInRegion(region);
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is Poi) {
      return PoiDetailContent(poi: item);
    }
    return const Text('Unbekannter Typ');
  }

  @override
  List<FilterOption> get filterOptions => [
        FilterOption(
          id: 'free',
          label: 'Kostenlos',
          icon: Icons.money_off,
          predicate: (item) => item is Poi && item.isFree,
        ),
        FilterOption(
          id: 'barrier_free',
          label: 'Barrierefrei',
          icon: Icons.accessible,
          predicate: (item) => item is Poi && item.isBarrierFree,
        ),
        FilterOption(
          id: 'indoor',
          label: 'Indoor',
          icon: Icons.home,
          predicate: (item) => item is Poi && item.isIndoor,
        ),
        FilterOption(
          id: 'outdoor',
          label: 'Outdoor',
          icon: Icons.wb_sunny,
          predicate: (item) => item is Poi && item.isOutdoor,
        ),
        // Altersfilter
        FilterOption(
          id: 'age_0-3',
          label: AppStrings.ageRanges['0-3']!,
          icon: Icons.child_care,
          predicate: (item) =>
              item is Poi && _matchesAgeFilter(item.ageRange, '0-3'),
        ),
        FilterOption(
          id: 'age_3-6',
          label: AppStrings.ageRanges['3-6']!,
          icon: Icons.child_friendly,
          predicate: (item) =>
              item is Poi && _matchesAgeFilter(item.ageRange, '3-6'),
        ),
        FilterOption(
          id: 'age_6-12',
          label: AppStrings.ageRanges['6-12']!,
          icon: Icons.school,
          predicate: (item) =>
              item is Poi && _matchesAgeFilter(item.ageRange, '6-12'),
        ),
        FilterOption(
          id: 'age_12+',
          label: AppStrings.ageRanges['12+']!,
          icon: Icons.face,
          predicate: (item) =>
              item is Poi && _matchesAgeFilter(item.ageRange, '12+'),
        ),
      ];

  /// Hilfsmethode für Altersfilter-Predicates
  /// Verwendet half-open intervals [min, max) für exakte Gruppierung
  bool _matchesAgeFilter(String poiAge, String filterAge) {
    // "alle" passt zu jedem Filter
    if (poiAge == 'alle') return true;

    // Exakte Übereinstimmung
    if (poiAge == filterAge) return true;

    // Parse und prüfe Überlappung mit half-open intervals
    final poiRange = _parseAgeRange(poiAge);
    final filterRange = _parseAgeRange(filterAge);

    if (poiRange == null || filterRange == null) return false;

    // Half-open intervals: [min1, max1) overlaps [min2, max2) wenn min1 < max2 && min2 < max1
    return poiRange.$1 < filterRange.$2 && filterRange.$1 < poiRange.$2;
  }

  /// Parst einen Altersbereich-String zu (min, max)
  (int, int)? _parseAgeRange(String range) {
    if (range == 'alle') return null;
    if (range.endsWith('+')) {
      final min = int.tryParse(range.replaceAll('+', ''));
      return min != null ? (min, 999) : null;
    }
    final parts = range.split('-');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]);
      final max = int.tryParse(parts[1]);
      return (min != null && max != null) ? (min, max) : null;
    }
    return null;
  }
}
