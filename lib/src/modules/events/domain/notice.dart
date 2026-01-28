import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Notice Model - MSH Radar Hinweise (Straßensperrungen, Warnungen, etc.)
class MshNotice {
  const MshNotice({
    required this.id,
    required this.type,
    required this.title,
    required this.severity,
    this.description,
    this.affectedArea,
    this.validFrom,
    this.validUntil,
    this.timeStart,
    this.timeEnd,
    this.sourceUrl,
    this.sourceUrls,
    this.latitude,
    this.longitude,
    this.routeCoordinates,
  });

  /// Parse from JSON
  factory MshNotice.fromJson(Map<String, dynamic> json) {
    // Route-Koordinaten parsen (für Polylines bei Straßensperrungen)
    List<LatLng>? routeCoords;
    if (json['route_coordinates'] != null) {
      final coords = json['route_coordinates'] as List;
      routeCoords = coords.map((c) {
        final coord = c as List;
        return LatLng(
          (coord[0] as num).toDouble(),
          (coord[1] as num).toDouble(),
        );
      }).toList();
    }

    return MshNotice(
      id: json['id'] as String,
      type: NoticeType.fromString(json['type'] as String),
      title: json['title'] as String,
      severity: NoticeSeverity.fromString(json['severity'] as String),
      description: json['description'] as String?,
      affectedArea: json['affected_area'] as String?,
      validFrom: json['valid_from'] != null ? DateTime.parse(json['valid_from'] as String) : null,
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until'] as String) : null,
      timeStart: json['time_start'] as String?,
      timeEnd: json['time_end'] as String?,
      sourceUrl: json['source_url'] as String?,
      sourceUrls: (json['source_urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      routeCoordinates: routeCoords,
    );
  }

  final String id;
  final NoticeType type;
  final String title;
  final NoticeSeverity severity;
  final String? description;
  final String? affectedArea;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? timeStart;
  final String? timeEnd;
  final String? sourceUrl;
  /// Multiple source URLs for comprehensive information
  final List<String>? sourceUrls;
  final double? latitude;
  final double? longitude;
  /// Route coordinates for drawing polylines (street closures, etc.)
  /// Format: List of [latitude, longitude] pairs
  final List<LatLng>? routeCoordinates;

  /// Check if this notice has a route (polyline)
  bool get hasRoute => routeCoordinates != null && routeCoordinates!.length >= 2;

  /// Check if notice is currently active
  bool get isActive {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return true;
  }

  /// Get icon for notice type
  IconData get icon {
    return switch (type) {
      NoticeType.sperrung => Icons.block,
      NoticeType.baustelle => Icons.construction,
      NoticeType.oeffnungszeit => Icons.access_time,
      NoticeType.warnung => Icons.warning_amber,
      NoticeType.info => Icons.info,
    };
  }

  /// Get color for severity
  Color get color {
    return switch (severity) {
      NoticeSeverity.critical => const Color(0xFFD32F2F),
      NoticeSeverity.warning => const Color(0xFFF57C00),
      NoticeSeverity.info => const Color(0xFF1976D2),
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'severity': severity.name,
      if (description != null) 'description': description,
      if (affectedArea != null) 'affected_area': affectedArea,
      if (validFrom != null) 'valid_from': validFrom!.toIso8601String().split('T')[0],
      if (validUntil != null) 'valid_until': validUntil!.toIso8601String().split('T')[0],
      if (timeStart != null) 'time_start': timeStart,
      if (timeEnd != null) 'time_end': timeEnd,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (sourceUrls != null) 'source_urls': sourceUrls,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (routeCoordinates != null)
        'route_coordinates': routeCoordinates!
            .map((c) => [c.latitude, c.longitude])
            .toList(),
    };
  }
}

/// Notice Type Enum
enum NoticeType {
  sperrung('sperrung', 'Straßensperrung'),
  baustelle('baustelle', 'Baustelle'),
  oeffnungszeit('oeffnungszeit', 'Öffnungszeit'),
  warnung('warnung', 'Warnung'),
  info('info', 'Information');

  const NoticeType(this.name, this.label);

  final String name;
  final String label;

  static NoticeType fromString(String value) {
    return NoticeType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NoticeType.info,
    );
  }
}

/// Notice Severity Enum
enum NoticeSeverity {
  critical('critical', 'Kritisch'),
  warning('warning', 'Warnung'),
  info('info', 'Information');

  const NoticeSeverity(this.name, this.label);

  final String name;
  final String label;

  static NoticeSeverity fromString(String value) {
    return NoticeSeverity.values.firstWhere(
      (severity) => severity.name == value,
      orElse: () => NoticeSeverity.info,
    );
  }
}
