import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../../../shared/domain/bounding_box.dart';
import '../../../shared/domain/map_item.dart';
import '../domain/nightlife_category.dart';
import '../domain/nightlife_venue.dart';

/// Repository für Nachtleben-Venues (Bars, Clubs, Pubs)
class NightlifeRepository {
  List<NightlifeVenue>? _cachedVenues;
  final _streamController = StreamController<List<NightlifeVenue>>.broadcast();

  /// Lädt alle Venues aus JSON-Assets
  Future<List<NightlifeVenue>> loadFromAssets() async {
    if (_cachedVenues != null) return _cachedVenues!;

    final venues = <NightlifeVenue>[];

    try {
      final json =
          await rootBundle.loadString('assets/data/nightlife/venues.json');
      final data = jsonDecode(json) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      venues.addAll(
        list.map(
          (e) => NightlifeVenue.fromJson(e as Map<String, dynamic>),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Konnte Nachtleben-Venues nicht laden: $e');
    }

    _cachedVenues = venues;
    _streamController.add(venues);
    return venues;
  }

  /// Venues in einer Region (für MapItem Interface)
  Future<List<MapItem>> getVenuesInRegion(BoundingBox region) async {
    final all = await loadFromAssets();
    return all.where((v) => region.contains(v.coordinates)).toList();
  }

  /// Stream für reaktive Updates
  Stream<List<MapItem>> watchVenuesInRegion(BoundingBox region) {
    loadFromAssets();
    return _streamController.stream.map(
      (venues) =>
          venues.where((v) => region.contains(v.coordinates)).toList(),
    );
  }

  /// Venues nach Kategorie
  Future<List<NightlifeVenue>> getByCategory(NightlifeCategory category) async {
    final all = await loadFromAssets();
    return all.where((v) => v.nightlifeCategory == category).toList();
  }

  /// Nur Pubs
  Future<List<NightlifeVenue>> getPubs() async {
    return getByCategory(NightlifeCategory.pub);
  }

  /// Nur Bars
  Future<List<NightlifeVenue>> getBars() async {
    return getByCategory(NightlifeCategory.bar);
  }

  /// Nur Clubs
  Future<List<NightlifeVenue>> getClubs() async {
    return getByCategory(NightlifeCategory.club);
  }

  /// Venues mit Essen
  Future<List<NightlifeVenue>> getWithFood() async {
    final all = await loadFromAssets();
    return all.where((v) => v.hasFood).toList();
  }

  /// Venues mit Live-Musik
  Future<List<NightlifeVenue>> getWithLiveMusic() async {
    final all = await loadFromAssets();
    return all.where((v) => v.hasLiveMusic).toList();
  }

  /// Aktuell geöffnete Venues
  Future<List<NightlifeVenue>> getOpenNow() async {
    final all = await loadFromAssets();
    return all.where((v) => v.isOpenNow).toList();
  }

  /// Venue nach ID
  Future<NightlifeVenue?> getById(String id) async {
    final all = await loadFromAssets();
    for (final venue in all) {
      if (venue.id == id) return venue;
    }
    return null;
  }

  /// Cache leeren
  void clearCache() {
    _cachedVenues = null;
  }

  /// Stream schließen
  void dispose() {
    _streamController.close();
  }
}
