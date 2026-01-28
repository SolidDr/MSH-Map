import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';
import 'data/civic_repository.dart';
import 'domain/civic_category.dart';
import 'domain/civic_facility.dart';
import 'presentation/civic_facility_detail.dart';

/// Modul für Behörden, Jugendzentren und Soziale Einrichtungen
class CivicModule extends MshModule {
  CivicModule({CivicRepository? repository})
      : _repository = repository ?? CivicRepository();

  final CivicRepository _repository;

  @override
  String get moduleId => 'civic';

  @override
  String get displayName => 'Service';

  @override
  IconData get icon => Icons.account_balance;

  @override
  Color get primaryColor => MshColors.categoryGovernment;

  @override
  Future<void> initialize() async {
    await _repository.loadFromAssets();
  }

  @override
  Future<void> dispose() async {
    _repository.dispose();
  }

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return _repository.watchFacilitiesInRegion(region);
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) {
    return _repository.getFacilitiesInRegion(region);
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is CivicFacility) {
      return CivicFacilityDetailContent(facility: item);
    }
    return const Text('Unbekannter Typ');
  }

  @override
  List<FilterOption> get filterOptions => [
        // Kategorie-Filter
        FilterOption(
          id: 'civic_government',
          label: 'Behörden',
          icon: Icons.account_balance,
          predicate: (item) =>
              item is CivicFacility &&
              item.civicCategory == CivicCategory.government,
        ),
        FilterOption(
          id: 'civic_youth',
          label: 'Jugendzentren',
          icon: Icons.group,
          predicate: (item) =>
              item is CivicFacility &&
              item.civicCategory == CivicCategory.youthCentre,
        ),
        FilterOption(
          id: 'civic_social',
          label: 'Soziale Einrichtungen',
          icon: Icons.volunteer_activism,
          predicate: (item) =>
              item is CivicFacility &&
              item.civicCategory == CivicCategory.socialFacility,
        ),

        // Zielgruppen-Filter
        FilterOption(
          id: 'civic_for_youth',
          label: 'Für Jugendliche',
          icon: Icons.people,
          predicate: (item) => item is CivicFacility && item.isYouthRelevant,
        ),
        FilterOption(
          id: 'civic_for_seniors',
          label: 'Für Senioren',
          icon: Icons.elderly,
          predicate: (item) => item is CivicFacility && item.isSeniorRelevant,
        ),

        // Barrierefreiheit
        FilterOption(
          id: 'civic_barrier_free',
          label: 'Barrierefrei',
          icon: Icons.accessible,
          predicate: (item) => item is CivicFacility && item.isBarrierFree,
        ),
      ];
}
