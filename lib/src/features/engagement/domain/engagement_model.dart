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
  const EngagementPlace._();

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
  const EngagementNeed._();

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
    if (targetAmount == 0) return 1;
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
  const AdoptableAnimal._();

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
