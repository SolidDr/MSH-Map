import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';

enum PoiCategory {
  nature,
  museum,
  castle,
  pool,
  playground,
  zoo,
  farm,
  adventure,
  // Bildung
  school,
  kindergarten,
  library,
}

class Poi implements MapItem {
  const Poi({
    required this.id,
    required this.name,
    required this.location, required this.poiCategory, this.description,
    this.address,
    this.city,
    this.tags = const [],
    this.website,
    this.isFree = false,
    this.isIndoor = false,
    this.isOutdoor = true,
    this.isBarrierFree = false,
    this.ageRange = 'alle',
    this.activityType,
    this.openingHours,
    this.priceInfo,
    this.contactPhone,
    this.contactEmail,
    this.facilities = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Firestore
  factory Poi.fromFirestore(String id, Map<String, dynamic> data) {
    final geoPoint = data['location'] as GeoPoint?;
    final categoryStr = data['category'] as String?;

    return Poi(
      id: id,
      name: (data['name'] as String?) ?? '',
      description: data['description'] as String?,
      location: geoPoint != null
          ? Coordinates(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
          : const Coordinates(latitude: 0, longitude: 0),
      poiCategory: PoiCategory.values.firstWhere(
        (c) => c.name == categoryStr,
        orElse: () => PoiCategory.nature,
      ),
      address: data['address'] as String?,
      city: data['city'] as String?,
      tags: List<String>.from((data['tags'] as List?) ?? []),
      website: data['website'] as String?,
      isFree: (data['is_free'] as bool?) ?? false,
      isIndoor: (data['is_indoor'] as bool?) ?? false,
      isOutdoor: (data['is_outdoor'] as bool?) ?? true,
      isBarrierFree: (data['is_barrier_free'] as bool?) ?? false,
      ageRange: (data['age_range'] as String?) ?? 'alle',
      activityType: data['activity_type'] as String?,
      openingHours: data['opening_hours'] as String?,
      priceInfo: data['price_info'] as String?,
      contactPhone: data['contact_phone'] as String?,
      contactEmail: data['contact_email'] as String?,
      facilities: List<String>.from((data['facilities'] as List?) ?? []),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  @override
  final String id;

  final String name;
  final String? description;
  final Coordinates location;
  final PoiCategory poiCategory;
  final String? address;
  final String? city;
  final List<String> tags;
  final String? website;
  final bool isFree;
  final bool isIndoor;
  final bool isOutdoor;
  final bool isBarrierFree;
  final String ageRange;
  final String? activityType;
  final String? openingHours;
  final String? priceInfo;
  final String? contactPhone;
  final String? contactEmail;
  final List<String> facilities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // MapItem Implementation

  @override
  Coordinates get coordinates => location;

  @override
  String get displayName => name;

  @override
  String? get subtitle => description;

  @override
  MapItemCategory get category => switch (poiCategory) {
        PoiCategory.nature => MapItemCategory.nature,
        PoiCategory.museum => MapItemCategory.museum,
        PoiCategory.castle => MapItemCategory.castle,
        PoiCategory.pool => MapItemCategory.pool,
        PoiCategory.playground => MapItemCategory.playground,
        PoiCategory.zoo => MapItemCategory.zoo,
        PoiCategory.farm => MapItemCategory.farm,
        PoiCategory.adventure => MapItemCategory.adventure,
        PoiCategory.school => MapItemCategory.school,
        PoiCategory.kindergarten => MapItemCategory.kindergarten,
        PoiCategory.library => MapItemCategory.library,
      };

  @override
  Color get markerColor => switch (poiCategory) {
        PoiCategory.nature => MshColors.categoryNature,
        PoiCategory.museum => MshColors.categoryMuseum,
        PoiCategory.castle => MshColors.categoryCastle,
        PoiCategory.pool => MshColors.categoryPool,
        PoiCategory.playground => MshColors.categoryPlayground,
        PoiCategory.zoo => MshColors.categoryZoo,
        PoiCategory.farm => MshColors.categoryFarm,
        PoiCategory.adventure => MshColors.categoryAdventure,
        PoiCategory.school => MshColors.categorySchool,
        PoiCategory.kindergarten => MshColors.categoryKindergarten,
        PoiCategory.library => MshColors.categoryLibrary,
      };

  @override
  String get moduleId => 'family';

  @override
  DateTime? get lastUpdated => updatedAt;

  @override
  Map<String, dynamic> get metadata => {
        'address': address,
        'city': city,
        'tags': tags,
        'website': website,
        'isFree': isFree,
        'isIndoor': isIndoor,
        'isOutdoor': isOutdoor,
        'isBarrierFree': isBarrierFree,
        'ageRange': ageRange,
        'activityType': activityType,
        'openingHours': openingHours,
        'priceInfo': priceInfo,
        'contactPhone': contactPhone,
        'contactEmail': contactEmail,
        'facilities': facilities,
      };

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'location': GeoPoint(location.latitude, location.longitude),
        'category': poiCategory.name,
        'address': address,
        'city': city,
        'tags': tags,
        'website': website,
        'is_free': isFree,
        'is_indoor': isIndoor,
        'is_outdoor': isOutdoor,
        'is_barrier_free': isBarrierFree,
        'age_range': ageRange,
        'activity_type': activityType,
        'opening_hours': openingHours,
        'price_info': priceInfo,
        'contact_phone': contactPhone,
        'contact_email': contactEmail,
        'facilities': facilities,
        'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
        'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };
}
