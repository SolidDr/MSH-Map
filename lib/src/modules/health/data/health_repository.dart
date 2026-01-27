import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../../../shared/domain/bounding_box.dart';
import '../../../shared/domain/map_item.dart';
import '../domain/health_category.dart';
import '../domain/health_facility.dart';

/// Repository für Gesundheitseinrichtungen
class HealthRepository {
  List<HealthFacility>? _cachedFacilities;
  final _streamController = StreamController<List<HealthFacility>>.broadcast();

  /// Lädt alle Einrichtungen aus JSON-Assets
  Future<List<HealthFacility>> loadFromAssets() async {
    if (_cachedFacilities != null) return _cachedFacilities!;

    final facilities = <HealthFacility>[];

    // Lade Ärzte
    try {
      final doctorsJson =
          await rootBundle.loadString('assets/data/health/doctors.json');
      final doctorsData = jsonDecode(doctorsJson) as Map<String, dynamic>;
      final doctorsList = doctorsData['data'] as List<dynamic>;
      facilities.addAll(
        doctorsList.map(
          (e) => HealthFacility.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on Exception catch (e) {
      // Fallback: Keine Ärzte-Daten
      debugPrint('Konnte Ärzte nicht laden: $e');
    }

    // Lade Apotheken
    try {
      final pharmaciesJson =
          await rootBundle.loadString('assets/data/health/pharmacies.json');
      final pharmaciesData = jsonDecode(pharmaciesJson) as Map<String, dynamic>;
      final pharmaciesList = pharmaciesData['data'] as List<dynamic>;
      facilities.addAll(
        pharmaciesList.map(
          (e) => HealthFacility.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Konnte Apotheken nicht laden: $e');
    }

    // Lade Fitness
    try {
      final fitnessJson =
          await rootBundle.loadString('assets/data/health/fitness.json');
      final fitnessData = jsonDecode(fitnessJson) as Map<String, dynamic>;
      final fitnessList = fitnessData['data'] as List<dynamic>;
      facilities.addAll(
        fitnessList.map(
          (e) => HealthFacility.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Konnte Fitness nicht laden: $e');
    }

    _cachedFacilities = facilities;
    _streamController.add(facilities);
    return facilities;
  }

  /// Einrichtungen in einer Region (für MapItem Interface)
  Future<List<MapItem>> getFacilitiesInRegion(BoundingBox region) async {
    final all = await loadFromAssets();
    return all.where((f) => region.contains(f.coordinates)).toList();
  }

  /// Stream für reaktive Updates
  Stream<List<MapItem>> watchFacilitiesInRegion(BoundingBox region) {
    // Initial laden
    loadFromAssets();
    return _streamController.stream.map(
      (facilities) =>
          facilities.where((f) => region.contains(f.coordinates)).toList(),
    );
  }

  /// Einrichtungen nach Kategorie
  Future<List<HealthFacility>> getByCategory(HealthCategory category) async {
    final all = await loadFromAssets();
    return all.where((f) => f.healthCategory == category).toList();
  }

  /// Ärzte nach Fachrichtung
  Future<List<HealthFacility>> getDoctorsBySpecialization(
    DoctorSpecialization specialization,
  ) async {
    final all = await loadFromAssets();
    return all
        .where(
          (f) =>
              f.healthCategory == HealthCategory.doctor &&
              f.specialization == specialization,
        )
        .toList();
  }

  /// Apotheken im Notdienst
  Future<List<HealthFacility>> getEmergencyPharmacies() async {
    final all = await loadFromAssets();
    return all
        .where(
          (f) =>
              f.healthCategory == HealthCategory.pharmacy &&
              (f.emergencyService?.isCurrentlyOnDuty ?? false),
        )
        .toList();
  }

  /// Barrierefreie Einrichtungen
  Future<List<HealthFacility>> getBarrierFree() async {
    final all = await loadFromAssets();
    return all.where((f) => f.isBarrierFree).toList();
  }

  /// Einrichtungen mit Hausbesuchen
  Future<List<HealthFacility>> getWithHouseCalls() async {
    final all = await loadFromAssets();
    return all.where((f) => f.hasHouseCalls).toList();
  }

  /// Aktuell geöffnete Einrichtungen
  Future<List<HealthFacility>> getOpenNow() async {
    final all = await loadFromAssets();
    return all.where((f) => f.isOpenNow).toList();
  }

  /// Einrichtung nach ID
  Future<HealthFacility?> getById(String id) async {
    final all = await loadFromAssets();
    for (final facility in all) {
      if (facility.id == id) return facility;
    }
    return null;
  }

  /// Cache leeren
  void clearCache() {
    _cachedFacilities = null;
  }

  /// Stream schließen
  void dispose() {
    _streamController.close();
  }
}
