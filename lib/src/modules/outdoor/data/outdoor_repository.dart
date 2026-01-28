import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../../../shared/domain/bounding_box.dart';
import '../../../shared/domain/map_item.dart';
import '../domain/hiking_stamp.dart';

/// Repository für Outdoor-Daten (Wandernadel, etc.)
class OutdoorRepository {
  List<HikingStamp>? _cachedStamps;
  final _streamController = StreamController<List<HikingStamp>>.broadcast();

  /// Lädt alle Harzer Wandernadel Stempelstellen aus JSON-Assets
  Future<List<HikingStamp>> loadHikingStamps() async {
    if (_cachedStamps != null) return _cachedStamps!;

    final stamps = <HikingStamp>[];

    try {
      final stampsJson =
          await rootBundle.loadString('assets/data/outdoor/wandernadel.json');
      final stampsDecoded = jsonDecode(stampsJson);

      // JSON ist ein flaches Array
      final List<dynamic> stampsList;
      if (stampsDecoded is List) {
        stampsList = stampsDecoded;
      } else {
        stampsList =
            (stampsDecoded as Map<String, dynamic>)['data'] as List<dynamic>;
      }

      stamps.addAll(
        stampsList.map(
          (e) => HikingStamp.fromJson(e as Map<String, dynamic>),
        ),
      );

      debugPrint('Loaded ${stamps.length} Wandernadel Stempelstellen');
    } on Exception catch (e) {
      debugPrint('Konnte Wandernadel-Daten nicht laden: $e');
    }

    _cachedStamps = stamps;
    _streamController.add(stamps);
    return stamps;
  }

  /// Stempelstellen in einer Region (für MapItem Interface)
  Future<List<MapItem>> getStampsInRegion(BoundingBox region) async {
    final all = await loadHikingStamps();
    return all.where((s) => region.contains(s.coordinates)).toList();
  }

  /// Stream für reaktive Updates
  Stream<List<MapItem>> watchStampsInRegion(BoundingBox region) {
    // Initial laden
    loadHikingStamps();
    return _streamController.stream.map(
      (stamps) =>
          stamps.where((s) => region.contains(s.coordinates)).toList(),
    );
  }

  /// Alle Stempelstellen
  Future<List<HikingStamp>> getAllStamps() async {
    return loadHikingStamps();
  }

  /// Stempelstelle nach ID
  Future<HikingStamp?> getById(String id) async {
    final all = await loadHikingStamps();
    for (final stamp in all) {
      if (stamp.id == id) return stamp;
    }
    return null;
  }

  /// Stempelstellen nach Stadt/Region
  Future<List<HikingStamp>> getByCity(String city) async {
    final all = await loadHikingStamps();
    return all.where((s) => s.city == city).toList();
  }

  /// Barrierefreie Stempelstellen
  Future<List<HikingStamp>> getBarrierFree() async {
    final all = await loadHikingStamps();
    return all.where((s) => s.isBarrierFree).toList();
  }

  /// Cache leeren
  void clearCache() {
    _cachedStamps = null;
  }

  /// Stream schließen
  void dispose() {
    _streamController.close();
  }
}
