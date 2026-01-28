import 'package:flutter/material.dart';
import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';
import 'civic_category.dart';

/// Öffentliche/soziale Einrichtung (Behörde, Jugendzentrum, Soziale Einrichtung)
class CivicFacility implements MapItem {
  const CivicFacility({
    required this.id,
    required this.name,
    required this.civicCategory,
    required this.latitude,
    required this.longitude,
    this.street,
    this.postalCode,
    this.city,
    this.phone,
    this.phoneFormatted,
    this.email,
    this.website,
    this.openingHours,
    this.description,
    this.isBarrierFree = false,
    this.hasParking = false,
    this.operator,
    this.targetAudience = TargetAudience.all,
    this.source,
  });

  factory CivicFacility.fromJson(Map<String, dynamic> json) {
    return CivicFacility(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      civicCategory: CivicCategory.fromString(json['type'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      street: json['street'] as String?,
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      phoneFormatted: json['phoneFormatted'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      openingHours: json['openingHours'] as String?,
      description: json['description'] as String?,
      isBarrierFree: json['isBarrierFree'] as bool? ?? false,
      hasParking: json['hasParking'] as bool? ?? false,
      operator: json['operator'] as String?,
      targetAudience: TargetAudience.fromString(json['targetAudience'] as String?),
      source: json['source'] as String?,
    );
  }

  @override
  final String id;
  final String name;
  final CivicCategory civicCategory;
  final double latitude;
  final double longitude;
  final String? street;
  final String? postalCode;
  final String? city;
  final String? phone;
  final String? phoneFormatted;
  final String? email;
  final String? website;
  final String? openingHours;
  final String? description;
  final bool isBarrierFree;
  final bool hasParking;
  final String? operator;
  final TargetAudience targetAudience;
  final String? source;

  // MapItem Implementation

  @override
  Coordinates get coordinates => Coordinates(
        latitude: latitude,
        longitude: longitude,
      );

  @override
  String get displayName => name;

  @override
  String? get subtitle => description ?? city;

  @override
  MapItemCategory get category => switch (civicCategory) {
        CivicCategory.government => MapItemCategory.government,
        CivicCategory.youthCentre => MapItemCategory.youthCentre,
        CivicCategory.socialFacility => MapItemCategory.socialFacility,
      };

  @override
  Color get markerColor => civicCategory.color;

  @override
  String get moduleId => 'civic';

  @override
  DateTime? get lastUpdated => null;

  @override
  Map<String, dynamic> get metadata => {
        'street': street,
        'postalCode': postalCode,
        'city': city,
        'phone': phone,
        'phoneFormatted': phoneFormatted,
        'email': email,
        'website': website,
        'openingHours': openingHours,
        'isBarrierFree': isBarrierFree,
        'hasParking': hasParking,
        'operator': operator,
        'targetAudience': targetAudience.name,
      };

  /// Vollständige Adresse
  String get fullAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (postalCode != null && city != null) {
      parts.add('$postalCode $city');
    } else if (city != null) {
      parts.add(city!);
    }
    return parts.join(', ');
  }

  /// Ist für Jugendliche relevant?
  bool get isYouthRelevant =>
      civicCategory == CivicCategory.youthCentre ||
      targetAudience == TargetAudience.youth;

  /// Ist für Senioren relevant?
  bool get isSeniorRelevant =>
      civicCategory == CivicCategory.socialFacility ||
      targetAudience == TargetAudience.seniors;
}
