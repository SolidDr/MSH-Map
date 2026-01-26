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
        ));
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
          ));
        }
      }
    }

    // Sortiere nach Dringlichkeit
    needs.sort((a, b) => b.need.urgency.index.compareTo(a.need.urgency.index));

    return needs;
  }

  void clearCache() => _placesCache = null;

  /// Mock-Daten für Entwicklung
  List<EngagementPlace> _getMockPlaces() {
    return [
      EngagementPlace(
        id: 'tierheim_sgh',
        name: 'Tierheim Sangerhausen',
        type: EngagementType.animalShelter,
        latitude: 51.4725,
        longitude: 11.2978,
        city: 'Sangerhausen',
        street: 'Tierheimweg 1',
        phone: '03464 123456',
        email: 'info@tierheim-sangerhausen.de',
        website: 'https://tierheim-sangerhausen.de',
        description: 'Tierheim des Tierschutzvereins Sangerhausen e.V.',
        openingHours: 'Di-Fr 14-17 Uhr, Sa 10-12 Uhr',
        isVerified: true,
        currentNeeds: [
          EngagementNeed(
            id: 'need_1',
            title: 'Gassigeher gesucht',
            description: 'Wir suchen ehrenamtliche Gassigeher für unsere Hunde.',
            urgency: UrgencyLevel.elevated,
            category: NeedCategory.volunteers,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          EngagementNeed(
            id: 'need_2',
            title: 'Futterspenden',
            description: 'Hochwertiges Hundefutter wird dringend benötigt.',
            urgency: UrgencyLevel.urgent,
            category: NeedCategory.food,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        adoptableAnimals: [
          AdoptableAnimal(
            id: 'dog_1',
            name: 'Max',
            type: AnimalType.dog,
            breed: 'Schäferhund-Mix',
            age: '4 Jahre',
            gender: 'männlich',
            size: 'groß',
            description: 'Max ist ein freundlicher Rüde, der ein Zuhause mit Garten sucht.',
            character: 'Verspielt, treu, kinderlieb',
            imageUrl: 'assets/images/engagement/max.jpg',
            availableSince: DateTime.now().subtract(const Duration(days: 120)),
            isUrgent: true,
          ),
          AdoptableAnimal(
            id: 'cat_1',
            name: 'Mimi',
            type: AnimalType.cat,
            breed: 'Europäisch Kurzhaar',
            age: '2 Jahre',
            gender: 'weiblich',
            description: 'Mimi ist eine verschmuste Katze.',
            character: 'Verschmust, ruhig',
            imageUrl: 'assets/images/engagement/mimi.jpg',
            availableSince: DateTime.now().subtract(const Duration(days: 45)),
          ),
        ],
        lastUpdated: DateTime.now(),
      ),

      EngagementPlace(
        id: 'feuerwehr_eisleben',
        name: 'Freiwillige Feuerwehr Eisleben',
        type: EngagementType.volunteer,
        latitude: 51.5274,
        longitude: 11.5481,
        city: 'Lutherstadt Eisleben',
        description: 'Die Freiwillige Feuerwehr sucht engagierte Mitglieder.',
        isVerified: true,
        currentNeeds: [
          EngagementNeed(
            id: 'need_ff_1',
            title: 'Nachwuchs gesucht',
            description: 'Wir suchen Frauen und Männer ab 16 Jahren für den aktiven Dienst.',
            urgency: UrgencyLevel.elevated,
            category: NeedCategory.volunteers,
          ),
        ],
      ),

      EngagementPlace(
        id: 'tafel_sgh',
        name: 'Tafel Sangerhausen',
        type: EngagementType.socialService,
        latitude: 51.4698,
        longitude: 11.3012,
        city: 'Sangerhausen',
        description: 'Lebensmittel retten, Menschen helfen.',
        isVerified: true,
        currentNeeds: [
          EngagementNeed(
            id: 'need_tafel_1',
            title: 'Fahrer gesucht',
            description: 'Ehrenamtliche Fahrer für Lebensmitteltransporte gesucht.',
            urgency: UrgencyLevel.urgent,
            category: NeedCategory.transport,
          ),
          EngagementNeed(
            id: 'need_tafel_2',
            title: 'Helfer für Ausgabe',
            description: 'Unterstützung bei der Lebensmittelausgabe.',
            urgency: UrgencyLevel.normal,
            category: NeedCategory.volunteers,
          ),
        ],
      ),

      EngagementPlace(
        id: 'blutspende_msh',
        name: 'DRK Blutspendedienst',
        type: EngagementType.bloodDonation,
        latitude: 51.4756,
        longitude: 11.3045,
        city: 'Sangerhausen',
        description: 'Blutspendetermine im Landkreis MSH',
        isVerified: true,
        currentNeeds: [
          EngagementNeed(
            id: 'need_blut_1',
            title: 'Blutspende-Termin',
            description: 'Nächster Termin: Jeden 1. Mittwoch im Monat',
            urgency: UrgencyLevel.normal,
            category: NeedCategory.other,
            neededBy: DateTime.now().add(const Duration(days: 14)),
          ),
        ],
      ),
    ];
  }
}

/// Tier mit zugehörigem Ort
class AdoptableAnimalWithPlace {
  final AdoptableAnimal animal;
  final EngagementPlace place;

  AdoptableAnimalWithPlace({
    required this.animal,
    required this.place,
  });
}

/// Bedarf mit zugehörigem Ort
class EngagementNeedWithPlace {
  final EngagementNeed need;
  final EngagementPlace place;

  EngagementNeedWithPlace({
    required this.need,
    required this.place,
  });
}
