import 'package:flutter/material.dart';

import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';

/// Event Model - MSH Radar Events
class MshEvent implements MapItem {

  /// Parse from JSON
  factory MshEvent.fromJson(Map<String, dynamic> json) {
    return MshEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      locationName: json['location_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String,
      eventCategory: EventCategory.fromString(json['category'] as String),
      dateEnd: json['date_end'] != null ? DateTime.parse(json['date_end'] as String) : null,
      timeStart: json['time_start'] as String?,
      timeEnd: json['time_end'] as String?,
      description: json['description'] as String?,
      price: json['price'] as String?,
      sourceUrl: json['source_url'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
  const MshEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.eventCategory,
    this.dateEnd,
    this.timeStart,
    this.timeEnd,
    this.description,
    this.price,
    this.sourceUrl,
    this.tags = const [],
  });

  @override
  final String id;
  final String name;
  final DateTime date;
  final DateTime? dateEnd;
  final String? timeStart;
  final String? timeEnd;
  final String locationName;
  final double latitude;
  final double longitude;
  final String city;
  final EventCategory eventCategory;
  final String? description;
  final String? price;
  final String? sourceUrl;
  final List<String> tags;

  // MapItem implementation
  @override
  Coordinates get coordinates => Coordinates(latitude: latitude, longitude: longitude);

  @override
  String get displayName => name;

  @override
  String? get subtitle => '$city ${timeStart != null ? "• $timeStart Uhr" : ""}';

  @override
  MapItemCategory get category => MapItemCategory.event;

  @override
  Color get markerColor => eventCategory.color;

  @override
  String get moduleId => 'events';

  @override
  DateTime? get lastUpdated => date;

  @override
  Map<String, dynamic> get metadata => {
        'city': city,
        'category': eventCategory.name,
        'price': price,
        'timeStart': timeStart,
        'tags': tags,
      };

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String().split('T')[0],
      if (dateEnd != null) 'date_end': dateEnd!.toIso8601String().split('T')[0],
      if (timeStart != null) 'time_start': timeStart,
      if (timeEnd != null) 'time_end': timeEnd,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'category': eventCategory.name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (sourceUrl != null) 'source_url': sourceUrl,
      'tags': tags,
    };
  }
}

/// Event Category Enum
enum EventCategory {
  konzert('konzert', 'Konzert', Icons.music_note, Color(0xFF9C27B0)),
  markt('markt', 'Markt', Icons.storefront, Color(0xFFFF9800)),
  theater('theater', 'Theater', Icons.theater_comedy, Color(0xFFE91E63)),
  sport('sport', 'Sport', Icons.sports_soccer, Color(0xFF4CAF50)),
  kinder('kinder', 'Kinder', Icons.child_care, Color(0xFFEC407A)),
  fest('fest', 'Fest', Icons.celebration, Color(0xFFFFCA28)),
  fuehrung('fuehrung', 'Führung', Icons.directions_walk, Color(0xFF2196F3)),
  ausstellung('ausstellung', 'Ausstellung', Icons.museum, Color(0xFF795548)),
  sonstiges('sonstiges', 'Sonstiges', Icons.event, Color(0xFF9E9E9E));

  const EventCategory(this.name, this.label, this.icon, this.color);

  final String name;
  final String label;
  final IconData icon;
  final Color color;

  static EventCategory fromString(String value) {
    return EventCategory.values.firstWhere(
      (cat) => cat.name == value,
      orElse: () => EventCategory.sonstiges,
    );
  }
}
