import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/engagement_model.dart';

class EngagementRepository {
  List<EngagementPlace>? _placesCache;

  /// Lädt alle Engagement-Orte
  Future<List<EngagementPlace>> getPlaces() async {
    if (_placesCache != null) return _placesCache!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/engagement/places.json',
      );
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = data['places'] as List;
      _placesCache = list
          .map((e) => EngagementPlace.fromJson(e as Map<String, dynamic>))
          .toList();
      return _placesCache!;
    } catch (e) {
      // Fallback: Mock-Daten
      return _getMockPlaces();
    }
  }

  /// Lädt Orte nach Typ
  Future<List<EngagementPlace>> getPlacesByType(EngagementType type) async {
    final all = await getPlaces();
    return all.where((p) => p.type == type).toList();
  }

  /// Lädt Orte mit dringenden Bedürfnissen
  Future<List<EngagementPlace>> getUrgentPlaces() async {
    final all = await getPlaces();
    return all.where((p) => p.hasUrgentNeeds).toList();
  }

  /// Lädt alle adoptierbaren Tiere
  Future<List<AdoptableAnimalWithPlace>> getAdoptableAnimals() async {
    final places = await getPlaces();
    final animals = <AdoptableAnimalWithPlace>[];

    for (final place in places) {
      for (final animal in place.adoptableAnimals) {
        animals.add(AdoptableAnimalWithPlace(
          animal: animal,
          place: place,
        ),);
      }
    }

    // Sortiere: Dringend zuerst, dann nach Wartezeit
    animals.sort((a, b) {
      if (a.animal.isUrgent && !b.animal.isUrgent) return -1;
      if (!a.animal.isUrgent && b.animal.isUrgent) return 1;
      return (b.animal.waitingDays ?? 0).compareTo(a.animal.waitingDays ?? 0);
    });

    return animals;
  }

  /// Lädt alle aktuellen Hilfsaufrufe
  Future<List<EngagementNeedWithPlace>> getCurrentNeeds() async {
    final places = await getPlaces();
    final needs = <EngagementNeedWithPlace>[];

    for (final place in places) {
      for (final need in place.currentNeeds) {
        if (need.isCurrent) {
          needs.add(EngagementNeedWithPlace(
            need: need,
            place: place,
          ),);
        }
      }
    }

    // Sortiere nach Dringlichkeit
    needs.sort((a, b) => b.need.urgency.index.compareTo(a.need.urgency.index));

    return needs;
  }

  void clearCache() => _placesCache = null;

  /// Fallback wenn keine echten Daten verfügbar
  /// HINWEIS: Keine Mock-Daten mehr - nur verifizierte Daten aus places.json verwenden
  List<EngagementPlace> _getMockPlaces() {
    // Leerer Array - keine unverifizierten Daten anzeigen
    // TODO: Echte, verifizierte Engagement-Daten in assets/data/engagement/places.json anlegen
    return [];
  }
}

/// Tier mit zugehörigem Ort
class AdoptableAnimalWithPlace {

  AdoptableAnimalWithPlace({
    required this.animal,
    required this.place,
  });
  final AdoptableAnimal animal;
  final EngagementPlace place;
}

/// Bedarf mit zugehörigem Ort
class EngagementNeedWithPlace {

  EngagementNeedWithPlace({
    required this.need,
    required this.place,
  });
  final EngagementNeed need;
  final EngagementPlace place;
}
