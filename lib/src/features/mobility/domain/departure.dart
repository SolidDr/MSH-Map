/// Departure Model für ÖPNV-Abfahrten
/// Datenquelle: v6.db.transport.rest API
library;

import 'package:flutter/material.dart';

/// Eine Abfahrt an einer Haltestelle
class Departure {
  const Departure({
    required this.tripId,
    required this.direction,
    required this.line,
    required this.plannedWhen,
    this.when,
    this.delay,
    this.platform,
    this.plannedPlatform,
    this.cancelled,
    this.remarks,
  });

  factory Departure.fromJson(Map<String, dynamic> json) {
    return Departure(
      tripId: json['tripId'] as String? ?? '',
      direction: json['direction'] as String? ?? 'Unbekannt',
      line: TransitLine.fromJson(json['line'] as Map<String, dynamic>? ?? {}),
      plannedWhen: _parseDateTime(json['plannedWhen']),
      when: json['when'] != null ? _parseDateTime(json['when']) : null,
      delay: json['delay'] as int?,
      platform: json['platform']?.toString(),
      plannedPlatform: json['plannedPlatform']?.toString(),
      cancelled: json['cancelled'] as bool?,
      remarks: (json['remarks'] as List<dynamic>?)
          ?.map((r) => (r as Map<String, dynamic>)['text']?.toString() ?? '')
          .where((r) => r.isNotEmpty)
          .toList(),
    );
  }

  /// Trip-ID für diese Fahrt
  final String tripId;

  /// Ziel/Richtung der Fahrt
  final String direction;

  /// Linie (z.B. "RE 10", "Bus 200")
  final TransitLine line;

  /// Geplante Abfahrtszeit
  final DateTime plannedWhen;

  /// Tatsächliche/prognostizierte Abfahrtszeit (Echtzeit)
  final DateTime? when;

  /// Verspätung in Sekunden (positiv = verspätet, negativ = verfrüht)
  final int? delay;

  /// Aktuelles Gleis/Steig
  final String? platform;

  /// Geplantes Gleis/Steig
  final String? plannedPlatform;

  /// Ob die Fahrt ausfällt
  final bool? cancelled;

  /// Hinweise/Warnungen
  final List<String>? remarks;

  /// Effektive Abfahrtszeit (Echtzeit wenn verfügbar, sonst geplant)
  DateTime get effectiveWhen => when ?? plannedWhen;

  /// Verspätung in Minuten
  int get delayMinutes => delay != null ? (delay! / 60).round() : 0;

  /// Ob die Fahrt verspätet ist (> 1 Minute)
  bool get isDelayed => delay != null && delay! > 60;

  /// Ob das Gleis geändert wurde
  bool get platformChanged =>
      platform != null &&
      plannedPlatform != null &&
      platform != plannedPlatform;

  /// Minuten bis zur Abfahrt
  int get minutesUntilDeparture {
    final diff = effectiveWhen.difference(DateTime.now()).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  /// Formatierte Abfahrtszeit für Anzeige
  String get departureTimeFormatted {
    final mins = minutesUntilDeparture;
    if (mins == 0) return 'jetzt';
    if (mins < 60) return '$mins min';
    return '${effectiveWhen.hour}:${effectiveWhen.minute.toString().padLeft(2, '0')}';
  }

  /// Farbe basierend auf Status
  Color get statusColor {
    if (cancelled ?? false) return Colors.red;
    if (isDelayed) return Colors.orange;
    return Colors.green;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'tripId': tripId,
        'direction': direction,
        'line': line.toJson(),
        'plannedWhen': plannedWhen.toIso8601String(),
        if (when != null) 'when': when!.toIso8601String(),
        if (delay != null) 'delay': delay,
        if (platform != null) 'platform': platform,
        if (plannedPlatform != null) 'plannedPlatform': plannedPlatform,
        if (cancelled != null) 'cancelled': cancelled,
        if (remarks != null) 'remarks': remarks,
      };
}

/// Verkehrslinie (z.B. "RE 10", "Bus 200")
class TransitLine {
  const TransitLine({
    required this.id,
    required this.name,
    required this.mode,
    required this.product,
    this.operator,
  });

  factory TransitLine.fromJson(Map<String, dynamic> json) {
    return TransitLine(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unbekannt',
      mode: json['mode'] as String? ?? 'train',
      product: json['product'] as String? ?? 'regional',
      operator: json['operator']?['name'] as String?,
    );
  }

  /// Linien-ID
  final String id;

  /// Linienname (z.B. "RE 10", "Bus 200", "ICE 702")
  final String name;

  /// Verkehrsmodus (train, bus, etc.)
  final String mode;

  /// Produkttyp (nationalExpress, regional, bus, etc.)
  final String product;

  /// Betreiber (optional)
  final String? operator;

  /// Kurzname für kompakte Anzeige
  String get shortName {
    // Entferne führende Nullen und Leerzeichen
    return name.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Icon basierend auf Produkttyp
  IconData get icon {
    switch (product) {
      case 'nationalExpress':
      case 'national':
        return Icons.train;
      case 'regionalExpress':
      case 'regional':
        return Icons.directions_railway;
      case 'suburban':
        return Icons.directions_transit;
      case 'bus':
        return Icons.directions_bus;
      case 'tram':
        return Icons.tram;
      case 'subway':
        return Icons.subway;
      case 'ferry':
        return Icons.directions_boat;
      default:
        return Icons.commute;
    }
  }

  /// Farbe basierend auf Produkttyp
  Color get color {
    switch (product) {
      case 'nationalExpress':
        return const Color(0xFFE30613); // ICE Rot
      case 'national':
        return const Color(0xFF006F8D); // IC Blau
      case 'regionalExpress':
      case 'regional':
        return const Color(0xFF1E88E5); // RE/RB Blau
      case 'suburban':
        return const Color(0xFF4CAF50); // S-Bahn Grün
      case 'bus':
        return const Color(0xFF9C27B0); // Bus Lila
      case 'tram':
        return const Color(0xFFFF9800); // Tram Orange
      case 'subway':
        return const Color(0xFF2196F3); // U-Bahn Blau
      case 'ferry':
        return const Color(0xFF00BCD4); // Fähre Cyan
      default:
        return const Color(0xFF757575); // Grau
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mode': mode,
        'product': product,
        if (operator != null) 'operator': {'name': operator},
      };
}
