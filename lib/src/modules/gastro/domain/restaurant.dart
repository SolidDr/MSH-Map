import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';

enum RestaurantType { restaurant, cafe, imbiss, bar }

class Restaurant implements MapItem {

  const Restaurant({
    required this.id,
    required this.name,
    required this.location, required this.type, this.description,
    this.address,
    this.phone,
    this.website,
    this.openingHours = const [],
    this.lastMenuUpdate,
    this.todaySpecial,
    this.todayPrice,
  });

  // Firestore

  factory Restaurant.fromFirestore(String id, Map<String, dynamic> data) {
    final geoPoint = data['location'] as GeoPoint?;
    return Restaurant(
      id: id,
      name: (data['name'] as String?) ?? '',
      description: data['description'] as String?,
      location: geoPoint != null
          ? Coordinates(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
          : const Coordinates(latitude: 0, longitude: 0),
      type: RestaurantType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => RestaurantType.restaurant,
      ),
      address: data['address'] as String?,
      phone: data['phone'] as String?,
      website: data['website'] as String?,
      openingHours: List<String>.from((data['openingHours'] as List?) ?? []),
      lastMenuUpdate: (data['lastMenuUpdate'] as Timestamp?)?.toDate(),
      todaySpecial: data['todaySpecial'] as String?,
      todayPrice: (data['todayPrice'] as num?)?.toDouble(),
    );
  }
  @override
  final String id;

  final String name;
  final String? description;
  final Coordinates location;
  final RestaurantType type;
  final String? address;
  final String? phone;
  final String? website;
  final List<String> openingHours;
  final DateTime? lastMenuUpdate;
  final String? todaySpecial;
  final double? todayPrice;

  // MapItem Implementation

  @override
  Coordinates get coordinates => location;

  @override
  String get displayName => name;

  @override
  String? get subtitle => todaySpecial != null && todayPrice != null
      ? 'Heute: $todaySpecial – ${todayPrice!.toStringAsFixed(2)} €'
      : description;

  @override
  MapItemCategory get category => switch (type) {
    RestaurantType.restaurant => MapItemCategory.restaurant,
    RestaurantType.cafe => MapItemCategory.cafe,
    RestaurantType.imbiss => MapItemCategory.imbiss,
    RestaurantType.bar => MapItemCategory.bar,
  };

  @override
  Color get markerColor => const Color(0xFFE53935);

  @override
  String get moduleId => 'gastro';

  @override
  DateTime? get lastUpdated => lastMenuUpdate;

  @override
  Map<String, dynamic> get metadata => {
    'address': address,
    'phone': phone,
    'website': website,
    'openingHours': openingHours,
  };

  @override
  bool? get isOpenNow => null;

  @override
  double get markerOpacity => 1;

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'location': GeoPoint(location.latitude, location.longitude),
    'type': type.name,
    'address': address,
    'phone': phone,
    'website': website,
    'openingHours': openingHours,
    'lastMenuUpdate': lastMenuUpdate != null ? Timestamp.fromDate(lastMenuUpdate!) : null,
    'todaySpecial': todaySpecial,
    'todayPrice': todayPrice,
  };
}
