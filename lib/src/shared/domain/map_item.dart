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

  /// Öffnungsstatus: true=offen, false=geschlossen, null=unbekannt
  /// Wird für Marker-Opacity verwendet
  bool? get isOpenNow => null;

  /// Marker-Opacity basierend auf Öffnungsstatus
  /// 1.0 = voll sichtbar, 0.35 = geschlossen
  /// Überschreiben für dynamische Opacity basierend auf Schließzeit
  double get markerOpacity => 1;
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
  // Outdoor / Wandern
  hikingStamp,
  // Bildung
  school,
  kindergarten,
  library,
  // Civic (Behörden, Jugendzentren, Soziales)
  government,
  youthCentre,
  socialFacility,
  // Gesundheit
  doctor,
  pharmacy,
  hospital,
  physiotherapy,
  fitness,
  careService,
  defibrillator,
  // Nachtleben
  pub,
  cocktailbar,
  club,
  // Other
  service,
  search,
  custom,
}
