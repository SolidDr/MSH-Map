import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';
import '../../../shared/utils/opening_hours_parser.dart';

/// Schwimmbad / Pool Einrichtung
class Pool implements MapItem {
  const Pool({
    required this.id,
    required this.name,
    required this.location,
    this.poolType = PoolType.indoor,
    this.description,
    this.phone,
    this.phoneFormatted,
    this.email,
    this.website,
    this.address,
    this.postalCode,
    this.city,
    this.openingHours,
    this.openingHoursText,
    this.features = const [],
    this.aquaFitness = const [],
    this.isBarrierFree = false,
    this.hasParking = false,
    this.familyFriendly = false,
    this.ageGroups = const [],
    this.isSeasonal = false,
    this.seasonNote,
    this.lastUpdated,
  });

  factory Pool.fromJson(Map<String, dynamic> json) {
    // openingHours kann String oder Map sein
    final openingHoursValue = json['openingHours'];
    Map<String, dynamic>? openingHoursMap;
    String? openingHoursTextStr;

    if (openingHoursValue is Map<String, dynamic>) {
      openingHoursMap = openingHoursValue;
    } else if (openingHoursValue is String) {
      openingHoursTextStr = openingHoursValue;
    }

    // Expliziter Text überschreibt Map
    if (json['openingHoursText'] != null) {
      openingHoursTextStr = json['openingHoursText'] as String?;
    }

    return Pool(
      id: json['id'] as String,
      name: json['name'] as String,
      location: Coordinates(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      ),
      poolType: PoolType.fromString(json['poolType'] as String?),
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      phoneFormatted: json['phoneFormatted'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['street'] as String? ?? json['address'] as String?,
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
      openingHours: openingHoursMap,
      openingHoursText: openingHoursTextStr,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      aquaFitness: (json['aquaFitness'] as List<dynamic>?)
              ?.map((e) => AquaFitnessOffer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isBarrierFree: json['isBarrierFree'] as bool? ?? false,
      hasParking: json['hasParking'] as bool? ?? false,
      familyFriendly: json['familyFriendly'] as bool? ?? false,
      ageGroups: (json['ageGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isSeasonal: json['seasonal'] as bool? ?? false,
      seasonNote: json['seasonNote'] as String?,
      lastUpdated: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  final String id;
  final String name;
  final Coordinates location;
  final PoolType poolType;
  final String? description;
  final String? phone;
  final String? phoneFormatted;
  final String? email;
  final String? website;
  final String? address;
  final String? postalCode;
  final String? city;
  final Map<String, dynamic>? openingHours;
  final String? openingHoursText;
  final List<String> features;
  final List<AquaFitnessOffer> aquaFitness;
  final bool isBarrierFree;
  final bool hasParking;
  final bool familyFriendly;
  final List<String> ageGroups;
  final bool isSeasonal;
  final String? seasonNote;

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
  String? get subtitle => poolType.label;

  @override
  MapItemCategory get category => MapItemCategory.pool;

  @override
  Color get markerColor => MshColors.categoryPool;

  @override
  String get moduleId => 'leisure';

  @override
  Map<String, dynamic> get metadata => {
        'poolType': poolType.name,
        'phone': phone,
        'isBarrierFree': isBarrierFree,
        'hasParking': hasParking,
        'familyFriendly': familyFriendly,
        if (city != null) 'city': city,
        if (address != null) 'address': address,
        if (isSeasonal) 'seasonal': true,
      };

  // ═══════════════════════════════════════════════════════════════
  // Hilfsmethoden
  // ═══════════════════════════════════════════════════════════════

  String get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (postalCode != null || city != null) {
      parts.add('${postalCode ?? ''} ${city ?? ''}'.trim());
    }
    return parts.join(', ');
  }

  @override
  bool get isOpenNow {
    // Text-Format nutzt den Parser
    if (openingHoursText != null) {
      return OpeningHoursParser.isOpenNow(openingHoursText);
    }

    // Map-Format prüfen
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
    return nowMinutes >= fromMinutes && nowMinutes <= toMinutes;
  }

  @override
  double get markerOpacity {
    if (openingHoursText != null) {
      return OpeningHoursParser.getMarkerOpacity(openingHoursText);
    }
    if (openingHours == null) return 0.5;
    return isOpenNow ? 1.0 : 0.35;
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
}

/// Pool-Typ (Hallenbad, Freibad)
enum PoolType {
  indoor,
  outdoor,
  combined;

  String get label => switch (this) {
        PoolType.indoor => 'Hallenbad',
        PoolType.outdoor => 'Freibad',
        PoolType.combined => 'Hallen- & Freibad',
      };

  static PoolType fromString(String? value) {
    if (value == null) return PoolType.indoor;
    return PoolType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PoolType.indoor,
    );
  }
}

/// Aqua-Fitness Angebot
class AquaFitnessOffer {
  const AquaFitnessOffer({
    required this.name,
    this.description,
    this.day,
    this.requiresRegistration = false,
  });

  factory AquaFitnessOffer.fromJson(Map<String, dynamic> json) {
    return AquaFitnessOffer(
      name: json['name'] as String,
      description: json['description'] as String?,
      day: json['day'] as String?,
      requiresRegistration: json['requiresRegistration'] as bool? ?? false,
    );
  }

  final String name;
  final String? description;
  final String? day;
  final bool requiresRegistration;
}
