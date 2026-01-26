# PROMPT 09a: Soziales Engagement Feature - Teil 1 (Konzept & Models)

## Übersicht

Dieses Feature zeigt Orte und Organisationen, die **dringend Hilfe brauchen** oder wo **soziales Engagement** möglich ist:

```
SOZIALES ENGAGEMENT IN MSH
═══════════════════════════════════════════════════════════════

🐕 TIERHEIME & TIERSCHUTZ
   ├── Tierheim Sangerhausen
   ├── Tierschutzverein MSH
   ├── Wildtierstation
   └── Tiere zur Vermittlung

🤝 VEREINE & EHRENAMT
   ├── Sportvereine (Trainer gesucht)
   ├── Kulturvereine (Helfer gesucht)
   ├── Feuerwehr (Mitglieder gesucht)
   └── Soziale Einrichtungen

🆘 AKTUELLE HILFSAUFRUFE
   ├── Blutspende-Termine
   ├── Spendenaktionen
   ├── Freiwillige gesucht
   └── Sachspenden benötigt

👴 SOZIALE EINRICHTUNGEN
   ├── Seniorenheime (Besuchsdienst)
   ├── Jugendclubs (Betreuer)
   ├── Tafel / Sozialkaufhaus
   └── Flüchtlingshilfe
═══════════════════════════════════════════════════════════════
```

### Besondere Darstellung auf der Karte

```
STANDARD MARKER          ENGAGEMENT MARKER (NEU)
                         
┌────┐                   ╔════╗  ← Goldener "Helfen"-Rahmen
│ 🏛️ │                   ║ 🐕 ║  ← Pulsierender Effekt
└──▼─┘                   ╚══▼═╝    wenn dringend

                         + Herz-Badge: ❤️
                         + Optional: Foto (Tier/Aktion)
```

---

## TEIL 1: Datenmodelle

### 1.1 Engagement Model erstellen

Erstelle `lib/src/features/engagement/domain/engagement_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'engagement_model.freezed.dart';
part 'engagement_model.g.dart';

/// Art des sozialen Engagements
enum EngagementType {
  /// Tierheim, Tierschutz
  animalShelter('animal_shelter', 'Tierschutz', '🐕', Color(0xFF8B4513)),
  
  /// Vereine die Mitglieder/Helfer suchen
  volunteer('volunteer', 'Ehrenamt', '🤝', Color(0xFF9B59B6)),
  
  /// Aktuelle Hilfsaufrufe
  helpNeeded('help_needed', 'Hilfe gesucht', '🆘', Color(0xFFE74C3C)),
  
  /// Soziale Einrichtungen
  socialService('social_service', 'Soziales', '💜', Color(0xFF3498DB)),
  
  /// Spendenaktionen
  donation('donation', 'Spenden', '🎁', Color(0xFF27AE60)),
  
  /// Blutspende
  bloodDonation('blood_donation', 'Blutspende', '🩸', Color(0xFFC0392B)),
  
  /// Umwelt & Naturschutz
  environment('environment', 'Umweltschutz', '🌱', Color(0xFF2ECC71));

  final String id;
  final String label;
  final String emoji;
  final Color color;

  const EngagementType(this.id, this.label, this.emoji, this.color);

  static EngagementType fromId(String id) {
    return EngagementType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => EngagementType.volunteer,
    );
  }
}

/// Dringlichkeitsstufe
enum UrgencyLevel {
  /// Normal - langfristige Möglichkeit
  normal('normal', 'Langfristig', Colors.blue),
  
  /// Erhöht - bald Hilfe benötigt
  elevated('elevated', 'Bald benötigt', Colors.orange),
  
  /// Dringend - sofortige Hilfe nötig
  urgent('urgent', 'Dringend', Colors.red),
  
  /// Kritisch - Notfall
  critical('critical', 'Notfall!', Colors.red);

  final String id;
  final String label;
  final Color color;

  const UrgencyLevel(this.id, this.label, this.color);

  static UrgencyLevel fromId(String id) {
    return UrgencyLevel.values.firstWhere(
      (e) => e.id == id,
      orElse: () => UrgencyLevel.normal,
    );
  }
}

/// Engagement-Ort (Tierheim, Verein, etc.)
@freezed
class EngagementPlace with _$EngagementPlace {
  const EngagementPlace._();

  const factory EngagementPlace({
    required String id,
    required String name,
    required EngagementType type,
    required double latitude,
    required double longitude,
    
    // Adresse
    String? street,
    String? city,
    String? postalCode,
    
    // Kontakt
    String? phone,
    String? email,
    String? website,
    
    // Details
    String? description,
    String? openingHours,
    
    // Engagement-spezifisch
    @Default([]) List<EngagementNeed> currentNeeds,
    @Default([]) List<AdoptableAnimal> adoptableAnimals,
    
    // Darstellung
    String? imageUrl,
    @Default(false) bool isVerified,
    
    // Meta
    DateTime? lastUpdated,
    String? dataSource,
  }) = _EngagementPlace;

  factory EngagementPlace.fromJson(Map<String, dynamic> json) =>
      _$EngagementPlaceFromJson(json);

  /// Hat dringende Bedürfnisse?
  bool get hasUrgentNeeds => currentNeeds.any(
    (n) => n.urgency == UrgencyLevel.urgent || n.urgency == UrgencyLevel.critical,
  );

  /// Höchste Dringlichkeit
  UrgencyLevel get maxUrgency {
    if (currentNeeds.isEmpty) return UrgencyLevel.normal;
    return currentNeeds
        .map((n) => n.urgency)
        .reduce((a, b) => a.index > b.index ? a : b);
  }

  /// Anzahl adoptierbare Tiere
  int get adoptableCount => adoptableAnimals.length;
}

/// Aktueller Bedarf/Hilfsaufruf
@freezed
class EngagementNeed with _$EngagementNeed {
  const EngagementNeed._();

  const factory EngagementNeed({
    required String id,
    required String title,
    required String description,
    required UrgencyLevel urgency,
    required NeedCategory category,
    
    // Zeitrahmen
    DateTime? neededBy,
    DateTime? validUntil,
    
    // Details
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    
    // Quantität (wenn messbar)
    int? targetAmount,
    int? currentAmount,
    String? unit,
    
    // Meta
    DateTime? createdAt,
    @Default(true) bool isActive,
  }) = _EngagementNeed;

  factory EngagementNeed.fromJson(Map<String, dynamic> json) =>
      _$EngagementNeedFromJson(json);

  /// Ist noch aktuell?
  bool get isCurrent {
    if (!isActive) return false;
    if (validUntil != null && DateTime.now().isAfter(validUntil!)) return false;
    return true;
  }

  /// Fortschritt in Prozent (wenn messbar)
  double? get progress {
    if (targetAmount == null || currentAmount == null) return null;
    if (targetAmount == 0) return 1.0;
    return (currentAmount! / targetAmount!).clamp(0.0, 1.0);
  }
}

/// Kategorie des Bedarfs
enum NeedCategory {
  /// Freiwillige Helfer
  volunteers('volunteers', 'Freiwillige', '👋'),
  
  /// Geldspenden
  money('money', 'Geldspenden', '💶'),
  
  /// Sachspenden
  goods('goods', 'Sachspenden', '📦'),
  
  /// Futter/Lebensmittel
  food('food', 'Futter/Lebensmittel', '🍖'),
  
  /// Zeit/Betreuung
  time('time', 'Zeit & Betreuung', '⏰'),
  
  /// Transport
  transport('transport', 'Transport', '🚗'),
  
  /// Fachkenntnisse
  expertise('expertise', 'Fachkenntnisse', '🎓'),
  
  /// Pflegestellen
  fosterHome('foster_home', 'Pflegestelle', '🏠'),
  
  /// Adoption
  adoption('adoption', 'Adoption', '❤️'),
  
  /// Sonstiges
  other('other', 'Sonstiges', '📋');

  final String id;
  final String label;
  final String emoji;

  const NeedCategory(this.id, this.label, this.emoji);

  static NeedCategory fromId(String id) {
    return NeedCategory.values.firstWhere(
      (e) => e.id == id,
      orElse: () => NeedCategory.other,
    );
  }
}

/// Tier zur Vermittlung
@freezed
class AdoptableAnimal with _$AdoptableAnimal {
  const AdoptableAnimal._();

  const factory AdoptableAnimal({
    required String id,
    required String name,
    required AnimalType type,
    
    // Eigenschaften
    String? breed,
    String? age,
    String? gender,
    String? size,
    
    // Beschreibung
    String? description,
    String? character,
    @Default([]) List<String> specialNeeds,
    
    // Bilder
    String? imageUrl,
    @Default([]) List<String> additionalImages,
    
    // Status
    @Default(false) bool isUrgent,
    @Default(false) bool isReserved,
    DateTime? availableSince,
    
    // Kontakt
    String? contactInfo,
  }) = _AdoptableAnimal;

  factory AdoptableAnimal.fromJson(Map<String, dynamic> json) =>
      _$AdoptableAnimalFromJson(json);

  /// Wartezeit in Tagen
  int? get waitingDays {
    if (availableSince == null) return null;
    return DateTime.now().difference(availableSince!).inDays;
  }

  /// Ist lange im Tierheim?
  bool get isLongStay => (waitingDays ?? 0) > 90;
}

/// Tierart
enum AnimalType {
  dog('dog', 'Hund', '🐕'),
  cat('cat', 'Katze', '🐱'),
  rabbit('rabbit', 'Kaninchen', '🐰'),
  bird('bird', 'Vogel', '🐦'),
  smallAnimal('small_animal', 'Kleintier', '🐹'),
  reptile('reptile', 'Reptil', '🦎'),
  horse('horse', 'Pferd', '🐴'),
  farm('farm', 'Nutztier', '🐄'),
  other('other', 'Sonstiges', '🐾');

  final String id;
  final String label;
  final String emoji;

  const AnimalType(this.id, this.label, this.emoji);

  static AnimalType fromId(String id) {
    return AnimalType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => AnimalType.other,
    );
  }
}
```

### 1.2 Feature Flags erweitern

In `lib/src/core/config/feature_flags.dart` hinzufügen:

```dart
// ═══════════════════════════════════════════════════════════════
// SOZIALES ENGAGEMENT
// ═══════════════════════════════════════════════════════════════

/// Zeigt Engagement-Orte (Tierheime, Vereine, etc.)
static const bool enableEngagement = true;

/// Zeigt Engagement-Orte auf der Karte
static const bool enableEngagementOnMap = true;

/// Zeigt spezielle Marker für dringende Hilfsaufrufe
static const bool enableUrgentMarkers = true;

/// Zeigt adoptierbare Tiere
static const bool enableAdoptableAnimals = true;

/// Zeigt Engagement-Widget auf Home
static const bool enableEngagementWidget = true;

/// Pulsierender Effekt für dringende Marker
static const bool enablePulsingMarkers = true;
```

### 1.3 MshColors erweitern

In `lib/src/core/theme/msh_colors.dart` hinzufügen:

```dart
// ═══════════════════════════════════════════════════════════════
// ENGAGEMENT - Spezielle Farben für soziales Engagement
// ═══════════════════════════════════════════════════════════════

/// Engagement-Gold - für "Helfen"-Rahmen
static const Color engagementGold = Color(0xFFD4A853);

/// Engagement-Herz - für Adoption
static const Color engagementHeart = Color(0xFFE74C3C);

/// Tierheim-Braun
static const Color engagementAnimal = Color(0xFF8B4513);

/// Ehrenamt-Violett
static const Color engagementVolunteer = Color(0xFF9B59B6);

/// Dringend-Rot
static const Color engagementUrgent = Color(0xFFE74C3C);

/// Sozial-Blau
static const Color engagementSocial = Color(0xFF3498DB);

/// Spenden-Grün
static const Color engagementDonation = Color(0xFF27AE60);

/// Gibt Engagement-Typ-Farbe zurück
static Color getEngagementColor(String typeId) {
  switch (typeId) {
    case 'animal_shelter':
      return engagementAnimal;
    case 'volunteer':
      return engagementVolunteer;
    case 'help_needed':
      return engagementUrgent;
    case 'social_service':
      return engagementSocial;
    case 'donation':
      return engagementDonation;
    case 'blood_donation':
      return const Color(0xFFC0392B);
    case 'environment':
      return const Color(0xFF2ECC71);
    default:
      return engagementVolunteer;
  }
}
```

---

## TEIL 2: Repository und Provider

### 2.1 Engagement Repository

Erstelle `lib/src/features/engagement/data/engagement_repository.dart`:

```dart
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
      final data = jsonDecode(jsonString);
      final list = data['places'] as List;
      _placesCache = list.map((e) => EngagementPlace.fromJson(e)).toList();
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
```

### 2.2 Engagement Provider

Erstelle `lib/src/features/engagement/application/engagement_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/engagement_repository.dart';
import '../domain/engagement_model.dart';

/// Repository Provider
final engagementRepositoryProvider = Provider((ref) => EngagementRepository());

/// Alle Engagement-Orte
final engagementPlacesProvider = FutureProvider<List<EngagementPlace>>((ref) {
  return ref.watch(engagementRepositoryProvider).getPlaces();
});

/// Orte nach Typ
final engagementPlacesByTypeProvider = FutureProvider.family<List<EngagementPlace>, EngagementType>(
  (ref, type) {
    return ref.watch(engagementRepositoryProvider).getPlacesByType(type);
  },
);

/// Orte mit dringenden Bedürfnissen
final urgentEngagementPlacesProvider = FutureProvider<List<EngagementPlace>>((ref) {
  return ref.watch(engagementRepositoryProvider).getUrgentPlaces();
});

/// Alle adoptierbaren Tiere
final adoptableAnimalsProvider = FutureProvider<List<AdoptableAnimalWithPlace>>((ref) {
  return ref.watch(engagementRepositoryProvider).getAdoptableAnimals();
});

/// Adoptierbare Tiere nach Tierart
final adoptableAnimalsByTypeProvider = FutureProvider.family<List<AdoptableAnimalWithPlace>, AnimalType>(
  (ref, animalType) async {
    final all = await ref.watch(adoptableAnimalsProvider.future);
    return all.where((a) => a.animal.type == animalType).toList();
  },
);

/// Dringende Tiere (lange wartend oder als dringend markiert)
final urgentAnimalsProvider = FutureProvider<List<AdoptableAnimalWithPlace>>((ref) async {
  final all = await ref.watch(adoptableAnimalsProvider.future);
  return all.where((a) => a.animal.isUrgent || a.animal.isLongStay).toList();
});

/// Alle aktuellen Hilfsaufrufe
final currentNeedsProvider = FutureProvider<List<EngagementNeedWithPlace>>((ref) {
  return ref.watch(engagementRepositoryProvider).getCurrentNeeds();
});

/// Dringende Hilfsaufrufe
final urgentNeedsProvider = FutureProvider<List<EngagementNeedWithPlace>>((ref) async {
  final all = await ref.watch(currentNeedsProvider.future);
  return all.where((n) => 
    n.need.urgency == UrgencyLevel.urgent || 
    n.need.urgency == UrgencyLevel.critical
  ).toList();
});

/// Statistiken
final engagementStatsProvider = FutureProvider<EngagementStats>((ref) async {
  final places = await ref.watch(engagementPlacesProvider.future);
  final animals = await ref.watch(adoptableAnimalsProvider.future);
  final needs = await ref.watch(currentNeedsProvider.future);
  
  return EngagementStats(
    totalPlaces: places.length,
    urgentPlaces: places.where((p) => p.hasUrgentNeeds).length,
    totalAnimals: animals.length,
    urgentAnimals: animals.where((a) => a.animal.isUrgent || a.animal.isLongStay).length,
    totalNeeds: needs.length,
    urgentNeeds: needs.where((n) => 
      n.need.urgency == UrgencyLevel.urgent || 
      n.need.urgency == UrgencyLevel.critical
    ).length,
    byType: {
      for (final type in EngagementType.values)
        type: places.where((p) => p.type == type).length,
    },
  );
});

class EngagementStats {
  final int totalPlaces;
  final int urgentPlaces;
  final int totalAnimals;
  final int urgentAnimals;
  final int totalNeeds;
  final int urgentNeeds;
  final Map<EngagementType, int> byType;

  EngagementStats({
    required this.totalPlaces,
    required this.urgentPlaces,
    required this.totalAnimals,
    required this.urgentAnimals,
    required this.totalNeeds,
    required this.urgentNeeds,
    required this.byType,
  });
}
```

---

## Nächster Schritt

Fahre fort mit **PROMPT 09b** für:
- Engagement-Marker Widget (mit Pulsier-Effekt)
- Engagement-Widget für Home
- Tier-Karte mit Bild
- Detail-Sheets
- DeepScan Integration
