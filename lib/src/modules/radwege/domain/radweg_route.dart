import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'radweg_category.dart';

/// POI entlang eines Radwegs
class RadwegPoi {
  const RadwegPoi({
    required this.name,
    required this.coords,
    required this.description,
    this.icon = Icons.place,
  });

  final String name;
  final LatLng coords;
  final String description;
  final IconData icon;
}

/// Repräsentiert einen Radweg mit allen Daten
class RadwegRoute {
  const RadwegRoute({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.category,
    required this.lengthKm,
    required this.difficulty,
    required this.routeColor,
    required this.routePoints,
    required this.pois,
    required this.center,
    required this.overviewZoom,
    this.websiteUrl,
    this.contactName,
    this.contactRole,
    this.contactPhone,
    this.contactEmail,
    this.isLoop = false,
    this.elevationGain,
  });

  /// Eindeutige ID
  final String id;

  /// Vollständiger Name
  final String name;

  /// Kurzname für Chips/Labels
  final String shortName;

  /// Beschreibung
  final String description;

  /// Kategorie
  final RadwegCategory category;

  /// Länge in km
  final double lengthKm;

  /// Schwierigkeit: 'Leicht', 'Mittel', 'Schwer'
  final String difficulty;

  /// Farbe für die Route auf der Karte
  final Color routeColor;

  /// GPS-Punkte der Route
  final List<LatLng> routePoints;

  /// POIs entlang der Route
  final List<RadwegPoi> pois;

  /// Zentrum für Kartenzentrierung
  final LatLng center;

  /// Zoom-Level für Übersicht
  final double overviewZoom;

  /// Website-URL
  final String? websiteUrl;

  /// Kontaktdaten
  final String? contactName;
  final String? contactRole;
  final String? contactPhone;
  final String? contactEmail;

  /// Ist es ein Rundweg?
  final bool isLoop;

  /// Höhenmeter (optional)
  final int? elevationGain;

  /// Glow-Farbe für Karteneffekt
  Color get glowColor => routeColor.withAlpha(64);

  /// Hellere Variante der Routenfarbe
  Color get lightColor => Color.lerp(routeColor, Colors.white, 0.3)!;
}
