import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';
import 'data/health_repository.dart';
import 'domain/health_category.dart';
import 'domain/health_facility.dart';
import 'presentation/health_facility_detail.dart';

/// Modul für Gesundheit & Fitness
/// Speziell optimiert für ältere Nutzer (60+)
class HealthModule extends MshModule {
  HealthModule({HealthRepository? repository})
      : _repository = repository ?? HealthRepository();

  final HealthRepository _repository;

  @override
  String get moduleId => 'health';

  @override
  String get displayName => 'Gesundheit';

  @override
  IconData get icon => Icons.local_hospital;

  @override
  Color get primaryColor => MshColors.categoryHealth;

  @override
  Future<void> initialize() async {
    // Daten aus Assets vorladen
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
    if (item is HealthFacility) {
      return HealthFacilityDetailContent(facility: item);
    }
    return const Text('Unbekannter Typ');
  }

  @override
  List<FilterOption> get filterOptions => [
        // Status-Filter
        FilterOption(
          id: 'health_open_now',
          label: 'Jetzt geöffnet',
          icon: Icons.access_time,
          predicate: (item) => item is HealthFacility && item.isOpenNow,
        ),
        FilterOption(
          id: 'health_barrier_free',
          label: 'Barrierefrei',
          icon: Icons.accessible,
          predicate: (item) => item is HealthFacility && item.isBarrierFree,
        ),
        FilterOption(
          id: 'health_house_calls',
          label: 'Hausbesuche',
          icon: Icons.home,
          predicate: (item) => item is HealthFacility && item.hasHouseCalls,
        ),
        FilterOption(
          id: 'health_emergency',
          label: 'Notdienst',
          icon: Icons.local_pharmacy,
          predicate: (item) =>
              item is HealthFacility &&
              (item.emergencyService?.isCurrentlyOnDuty ?? false),
        ),

        // Kategorie-Filter
        FilterOption(
          id: 'health_cat_doctor',
          label: 'Ärzte',
          icon: Icons.medical_services,
          predicate: (item) =>
              item is HealthFacility &&
              item.healthCategory == HealthCategory.doctor,
        ),
        FilterOption(
          id: 'health_cat_pharmacy',
          label: 'Apotheken',
          icon: Icons.local_pharmacy,
          predicate: (item) =>
              item is HealthFacility &&
              item.healthCategory == HealthCategory.pharmacy,
        ),
        FilterOption(
          id: 'health_cat_fitness',
          label: 'Fitness',
          icon: Icons.fitness_center,
          predicate: (item) =>
              item is HealthFacility &&
              item.healthCategory == HealthCategory.fitness,
        ),
      ];
}
