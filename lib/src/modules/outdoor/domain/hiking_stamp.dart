import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';

/// Harzer Wandernadel Stempelstelle
class HikingStamp implements MapItem {
  const HikingStamp({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.stampNumber,
    this.stampSeries,
    this.city,
    this.elevation,
    this.operator,
    this.website,
    this.openingHours,
    this.is24h = true,
    this.isBarrierFree = false,
    this.osmUrl,
    this.lastUpdated,
  });

  factory HikingStamp.fromJson(Map<String, dynamic> json) {
    return HikingStamp(
      id: json['id'] as String,
      name: json['name'] as String,
      location: Coordinates(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      ),
      description: json['description'] as String?,
      stampNumber: json['stampNumber'] as String?,
      stampSeries: json['stampSeries'] as String?,
      city: json['city'] as String?,
      elevation: json['elevation'] as String?,
      operator: json['operator'] as String?,
      website: json['website'] as String?,
      openingHours: json['openingHours'] as String?,
      is24h: json['is24h'] as bool? ?? true,
      isBarrierFree: json['isBarrierFree'] as bool? ?? false,
      osmUrl: json['osmUrl'] as String?,
    );
  }

  @override
  final String id;

  final String name;
  final Coordinates location;
  final String? description;
  final String? stampNumber;
  final String? stampSeries;
  final String? city;
  final String? elevation;
  final String? operator;
  final String? website;
  final String? openingHours;
  final bool is24h;
  final bool isBarrierFree;
  final String? osmUrl;

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
    if (stampNumber != null) return 'Nr. $stampNumber';
    return stampSeries;
  }

  @override
  MapItemCategory get category => MapItemCategory.hikingStamp;

  @override
  Color get markerColor => MshColors.categoryHikingStamp;

  @override
  String get moduleId => 'outdoor';

  @override
  Map<String, dynamic> get metadata => {
        if (stampNumber != null) 'stampNumber': stampNumber,
        if (stampSeries != null) 'stampSeries': stampSeries,
        if (city != null) 'city': city,
        if (elevation != null) 'elevation': elevation,
        if (operator != null) 'operator': operator,
        if (website != null) 'website': website,
        'is24h': is24h,
        'isBarrierFree': isBarrierFree,
      };

  @override
  bool? get isOpenNow => is24h ? true : null;

  @override
  double get markerOpacity => 1; // Stempelstellen sind immer sichtbar

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      if (description != null) 'description': description,
      if (stampNumber != null) 'stampNumber': stampNumber,
      if (stampSeries != null) 'stampSeries': stampSeries,
      if (city != null) 'city': city,
      if (elevation != null) 'elevation': elevation,
      if (operator != null) 'operator': operator,
      if (website != null) 'website': website,
      if (openingHours != null) 'openingHours': openingHours,
      'is24h': is24h,
      'isBarrierFree': isBarrierFree,
      if (osmUrl != null) 'osmUrl': osmUrl,
    };
  }
}
