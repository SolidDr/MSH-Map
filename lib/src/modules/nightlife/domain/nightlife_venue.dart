import 'package:flutter/material.dart';
import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';
import '../../../shared/utils/opening_hours_parser.dart';
import 'nightlife_category.dart';

/// Nachtleben-Venue (Bar, Pub, Club, Diskothek)
class NightlifeVenue implements MapItem {
  const NightlifeVenue({
    required this.id,
    required this.name,
    required this.nightlifeCategory,
    required this.latitude,
    required this.longitude,
    this.street,
    this.postalCode,
    this.city,
    this.phone,
    this.phoneFormatted,
    this.website,
    this.openingHours,
    this.description,
    this.hasFood = false,
    this.hasLiveMusic = false,
  });

  factory NightlifeVenue.fromJson(Map<String, dynamic> json) {
    return NightlifeVenue(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nightlifeCategory: NightlifeCategory.fromString(json['type'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      street: json['street'] as String?,
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      phoneFormatted: json['phoneFormatted'] as String?,
      website: json['website'] as String?,
      openingHours: json['openingHours'] as String?,
      description: json['description'] as String?,
      hasFood: json['hasFood'] as bool? ?? false,
      hasLiveMusic: json['hasLiveMusic'] as bool? ?? false,
    );
  }

  @override
  final String id;
  final String name;
  final NightlifeCategory nightlifeCategory;
  final double latitude;
  final double longitude;
  final String? street;
  final String? postalCode;
  final String? city;
  final String? phone;
  final String? phoneFormatted;
  final String? website;
  final String? openingHours;
  final String? description;
  final bool hasFood;
  final bool hasLiveMusic;

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
  MapItemCategory get category => switch (nightlifeCategory) {
        NightlifeCategory.pub => MapItemCategory.pub,
        NightlifeCategory.bar => MapItemCategory.bar,
        NightlifeCategory.cocktailbar => MapItemCategory.cocktailbar,
        NightlifeCategory.club => MapItemCategory.club,
      };

  @override
  Color get markerColor => nightlifeCategory.color;

  @override
  String get moduleId => 'nightlife';

  @override
  DateTime? get lastUpdated => null;

  @override
  Map<String, dynamic> get metadata => {
        'street': street,
        'postalCode': postalCode,
        'city': city,
        'phone': phone,
        'phoneFormatted': phoneFormatted,
        'website': website,
        'openingHours': openingHours,
        'hasFood': hasFood,
        'hasLiveMusic': hasLiveMusic,
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

  /// Prüft ob jetzt geöffnet basierend auf Öffnungszeiten
  @override
  bool get isOpenNow => OpeningHoursParser.isOpenNow(openingHours);

  /// Marker-Opacity basierend auf Öffnungsstatus
  @override
  double get markerOpacity => OpeningHoursParser.getMarkerOpacity(openingHours);

  /// Gibt Öffnungszeiten für heute zurück
  String? get todayHours => OpeningHoursParser.getTodayHours(openingHours);
}
