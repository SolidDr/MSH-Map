import 'package:flutter/material.dart';
import 'coordinates.dart';

/// KERN-INTERFACE: Alles auf der Karte implementiert dies.
abstract class MapItem {
  /// Eindeutige ID
  String get id;

  /// GPS-Position
  Coordinates get coordinates;

  /// Anzeigename
  String get displayName;

  /// Untertitel (optional)
  String? get subtitle;

  /// Kategorie für Icon
  MapItemCategory get category;

  /// Marker-Farbe
  Color get markerColor;

  /// Modul-ID (z.B. "gastro", "events", "family")
  String get moduleId;

  /// Zeitstempel (optional)
  DateTime? get lastUpdated;

  /// Zusätzliche Daten
  Map<String, dynamic> get metadata => {};
}

enum MapItemCategory {
  // Gastro
  restaurant,
  cafe,
  imbiss,
  bar,
  // Events
  event,
  culture,
  sport,
  // Family
  playground,
  museum,
  nature,
  zoo,
  castle,
  pool,
  indoor,
  farm,
  adventure,
  // Bildung
  school,
  kindergarten,
  library,
  // Other
  service,
  search,
  custom,
}
