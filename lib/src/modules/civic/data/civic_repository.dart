import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../../../shared/domain/bounding_box.dart';
import '../../../shared/domain/map_item.dart';
import '../domain/civic_category.dart';
import '../domain/civic_facility.dart';

/// Repository für öffentliche/soziale Einrichtungen
class CivicRepository {
  List<CivicFacility>? _cachedFacilities;
  final _streamController = StreamController<List<CivicFacility>>.broadcast();

  /// Lädt alle Einrichtungen aus JSON-Assets
  Future<List<CivicFacility>> loadFromAssets() async {
    if (_cachedFacilities != null) return _cachedFacilities!;

    final facilities = <CivicFacility>[];

    // Lade Behörden
    try {
      final govJson =
          await rootBundle.loadString('assets/data/civic/government.json');
      final govData = jsonDecode(govJson) as Map<String, dynamic>;
      final govList = govData['data'] as List<dynamic>;
      facilities.addAll(
        govList.map(
          (e) => CivicFacility.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Konnte Behörden nicht laden: $e');
    }

    // Lade Jugendzentren
    try {
      final youthJson =
          await rootBundle.loadString('assets/data/civic/youth_centres.json');
      final youthData = jsonDecode(youthJson) as Map<String, dynamic>;
      final youthList = youthData['data'] as List<dynamic>;
      facilities.addAll(
        youthList.map(
          (e) => CivicFacility.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Konnte Jugendzentren nicht laden: $e');
    }

    // Lade Soziale Einrichtungen
    try {
      final socialJson =
          await rootBundle.loadString('assets/data/civic/social_facilities.json');
      final socialData = jsonDecode(socialJson) as Map<String, dynamic>;
      final socialList = socialData['data'] as List<dynamic>;
      facilities.addAll(
        socialList.map(
          (e) => CivicFacility.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Konnte Soziale Einrichtungen nicht laden: $e');
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
  Future<List<CivicFacility>> getByCategory(CivicCategory category) async {
    final all = await loadFromAssets();
    return all.where((f) => f.civicCategory == category).toList();
  }

  /// Nur Behörden
  Future<List<CivicFacility>> getGovernmentOffices() async {
    return getByCategory(CivicCategory.government);
  }

  /// Nur Jugendzentren
  Future<List<CivicFacility>> getYouthCentres() async {
    return getByCategory(CivicCategory.youthCentre);
  }

  /// Nur Soziale Einrichtungen
  Future<List<CivicFacility>> getSocialFacilities() async {
    return getByCategory(CivicCategory.socialFacility);
  }

  /// Einrichtungen nach Zielgruppe
  Future<List<CivicFacility>> getByAudience(TargetAudience audience) async {
    final all = await loadFromAssets();
    return all.where((f) => f.targetAudience == audience).toList();
  }

  /// Für Jugendliche relevante Einrichtungen
  Future<List<CivicFacility>> getYouthRelevant() async {
    final all = await loadFromAssets();
    return all.where((f) => f.isYouthRelevant).toList();
  }

  /// Für Senioren relevante Einrichtungen
  Future<List<CivicFacility>> getSeniorRelevant() async {
    final all = await loadFromAssets();
    return all.where((f) => f.isSeniorRelevant).toList();
  }

  /// Barrierefreie Einrichtungen
  Future<List<CivicFacility>> getBarrierFree() async {
    final all = await loadFromAssets();
    return all.where((f) => f.isBarrierFree).toList();
  }

  /// Einrichtung nach ID
  Future<CivicFacility?> getById(String id) async {
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
