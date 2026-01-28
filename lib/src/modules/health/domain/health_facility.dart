import 'package:flutter/material.dart';
import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';
import 'emergency_service.dart';
import 'health_category.dart';

/// Konvertiert JSON type zu HealthCategory (snake_case -> camelCase)
HealthCategory _parseHealthCategory(String? type) {
  if (type == null) return HealthCategory.doctor;

  // snake_case zu camelCase mapping
  const typeMap = {
    'doctor': HealthCategory.doctor,
    'pharmacy': HealthCategory.pharmacy,
    'hospital': HealthCategory.hospital,
    'physiotherapy': HealthCategory.physiotherapy,
    'fitness': HealthCategory.fitness,
    'care_service': HealthCategory.careService,
    'careService': HealthCategory.careService,
    'medical_supply': HealthCategory.medicalSupply,
    'medicalSupply': HealthCategory.medicalSupply,
  };

  return typeMap[type] ?? HealthCategory.doctor;
}

/// Gesundheitseinrichtung (Arzt, Apotheke, Krankenhaus, etc.)
class HealthFacility implements MapItem {
  const HealthFacility({
    required this.id,
    required this.name,
    required this.location,
    required this.healthCategory,
    this.specialization,
    this.description,
    this.phone,
    this.phoneFormatted,
    this.fax,
    this.email,
    this.website,
    this.address,
    this.postalCode,
    this.city,
    this.openingHours,
    this.walkInHours,
    this.hasHouseCalls = false,
    this.isBarrierFree = false,
    this.hasParking = false,
    this.languages = const ['Deutsch'],
    this.acceptsPublicInsurance = true,
    this.acceptsPrivateInsurance = true,
    this.rating,
    this.ratingCount,
    this.emergencyService,
    this.hasDelivery = false,
    this.services = const [],
    this.fitnessOffers = const [],
    this.lastUpdated,
  });

  factory HealthFacility.fromJson(Map<String, dynamic> json) {
    return HealthFacility(
      id: json['id'] as String,
      name: json['name'] as String,
      location: Coordinates(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      ),
      healthCategory: _parseHealthCategory(json['type'] as String?),
      specialization: DoctorSpecialization.fromString(
        json['specialization'] as String?,
      ),
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      phoneFormatted: json['phoneFormatted'] as String?,
      fax: json['fax'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['street'] as String? ?? json['address'] as String?,
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
      openingHours: json['openingHours'] as Map<String, dynamic>?,
      walkInHours: json['walkInHours'] as String?,
      hasHouseCalls: json['hasHouseCalls'] as bool? ?? false,
      isBarrierFree: json['isBarrierFree'] as bool? ?? false,
      hasParking: json['hasParking'] as bool? ?? false,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['Deutsch'],
      acceptsPublicInsurance: json['acceptsPublicInsurance'] as bool? ?? true,
      acceptsPrivateInsurance: json['acceptsPrivateInsurance'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
      emergencyService: json['emergencyService'] != null
          ? EmergencyService.fromJson(
              json['emergencyService'] as Map<String, dynamic>,
            )
          : null,
      hasDelivery: json['hasDelivery'] as bool? ?? false,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fitnessOffers: (json['fitnessOffers'] as List<dynamic>?)
              ?.map((e) => FitnessOffer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastUpdated: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  final String id;

  final String name;
  final Coordinates location;
  final HealthCategory healthCategory;
  final DoctorSpecialization? specialization;
  final String? description;
  final String? phone;
  final String? phoneFormatted;
  final String? fax;
  final String? email;
  final String? website;
  final String? address;
  final String? postalCode;
  final String? city;
  final Map<String, dynamic>? openingHours;
  final String? walkInHours;
  final bool hasHouseCalls;
  final bool isBarrierFree;
  final bool hasParking;
  final List<String> languages;
  final bool acceptsPublicInsurance;
  final bool acceptsPrivateInsurance;
  final double? rating;
  final int? ratingCount;
  final EmergencyService? emergencyService;
  final bool hasDelivery;
  final List<String> services;
  final List<FitnessOffer> fitnessOffers;

  @override
  final DateTime? lastUpdated;

  // ═══════════════════════════════════════════════════════════════
  // MapItem Implementation
  // ═══════════════════════════════════════════════════════════════

  @override
  Coordinates get coordinates => location;

  @override
  String get displayName => name;

  @override
  String? get subtitle {
    if (specialization != null) return specialization!.label;
    return healthCategory.label;
  }

  @override
  MapItemCategory get category => switch (healthCategory) {
        HealthCategory.doctor => MapItemCategory.doctor,
        HealthCategory.pharmacy => MapItemCategory.pharmacy,
        HealthCategory.hospital => MapItemCategory.hospital,
        HealthCategory.physiotherapy => MapItemCategory.physiotherapy,
        HealthCategory.fitness => MapItemCategory.fitness,
        HealthCategory.careService => MapItemCategory.careService,
        HealthCategory.medicalSupply => MapItemCategory.service,
      };

  @override
  Color get markerColor => healthCategory.color;

  @override
  String get moduleId => 'health';

  @override
  Map<String, dynamic> get metadata => {
        'healthCategory': healthCategory.name,
        'phone': phone,
        'isBarrierFree': isBarrierFree,
        'hasHouseCalls': hasHouseCalls,
        if (specialization != null) 'specialization': specialization!.name,
        if (emergencyService != null)
          'isOnDuty': emergencyService!.isCurrentlyOnDuty,
        // Für Suche
        if (city != null) 'city': city,
        if (address != null) 'address': address,
      };

  // ═══════════════════════════════════════════════════════════════
  // Hilfsmethoden
  // ═══════════════════════════════════════════════════════════════

  /// Vollständige Adresse formatiert
  String get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (postalCode != null || city != null) {
      parts.add('${postalCode ?? ''} ${city ?? ''}'.trim());
    }
    return parts.join(', ');
  }

  /// Prüft ob jetzt geöffnet (vereinfachte Logik)
  bool get isOpenNow {
    if (openingHours == null) return false;
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final todayHours = openingHours![dayName] as Map<String, dynamic>?;
    if (todayHours == null) return false;

    final fromStr = todayHours['from'] as String?;
    final toStr = todayHours['to'] as String?;
    if (fromStr == null || toStr == null) return false;

    final nowMinutes = now.hour * 60 + now.minute;
    final fromMinutes = _parseTimeToMinutes(fromStr);
    final toMinutes = _parseTimeToMinutes(toStr);

    if (fromMinutes == null || toMinutes == null) return false;

    // Prüfe Vormittag
    if (nowMinutes >= fromMinutes && nowMinutes <= toMinutes) return true;

    // Prüfe Nachmittag falls vorhanden
    final afternoon = todayHours['afternoon'] as Map<String, dynamic>?;
    if (afternoon != null) {
      final pmFrom = _parseTimeToMinutes(afternoon['from'] as String?);
      final pmTo = _parseTimeToMinutes(afternoon['to'] as String?);
      if (pmFrom != null && pmTo != null) {
        if (nowMinutes >= pmFrom && nowMinutes <= pmTo) return true;
      }
    }

    return false;
  }

  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[weekday - 1];
  }

  int? _parseTimeToMinutes(String? time) {
    if (time == null) return null;
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': healthCategory.name,
      if (specialization != null) 'specialization': specialization!.name,
      if (description != null) 'description': description,
      if (phone != null) 'phone': phone,
      if (phoneFormatted != null) 'phoneFormatted': phoneFormatted,
      if (fax != null) 'fax': fax,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (address != null) 'street': address,
      if (postalCode != null) 'postalCode': postalCode,
      if (city != null) 'city': city,
      if (openingHours != null) 'openingHours': openingHours,
      if (walkInHours != null) 'walkInHours': walkInHours,
      'hasHouseCalls': hasHouseCalls,
      'isBarrierFree': isBarrierFree,
      'hasParking': hasParking,
      'languages': languages,
      'acceptsPublicInsurance': acceptsPublicInsurance,
      'acceptsPrivateInsurance': acceptsPrivateInsurance,
      if (rating != null) 'rating': rating,
      if (ratingCount != null) 'ratingCount': ratingCount,
      if (emergencyService != null)
        'emergencyService': emergencyService!.toJson(),
      'hasDelivery': hasDelivery,
      if (services.isNotEmpty) 'services': services,
      if (fitnessOffers.isNotEmpty)
        'fitnessOffers': fitnessOffers.map((o) => o.toJson()).toList(),
      if (lastUpdated != null) 'updatedAt': lastUpdated!.toIso8601String(),
    };
  }
}
