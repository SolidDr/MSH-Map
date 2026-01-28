import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'wanderweg_category.dart';

/// Schwierigkeit nach deutscher Wanderskala
enum TrailDifficulty {
  /// Einfache Wege, auch für Familien
  leicht,

  /// Bergpfade, gutes Schuhwerk erforderlich
  mittel,

  /// Anspruchsvolle Wege, Trittsicherheit nötig
  schwer,
}

extension TrailDifficultyExtension on TrailDifficulty {
  String get label {
    switch (this) {
      case TrailDifficulty.leicht:
        return 'Leicht';
      case TrailDifficulty.mittel:
        return 'Mittel';
      case TrailDifficulty.schwer:
        return 'Schwer';
    }
  }

  Color get color {
    switch (this) {
      case TrailDifficulty.leicht:
        return const Color(0xFF4CAF50); // Grün
      case TrailDifficulty.mittel:
        return const Color(0xFFFF9800); // Orange
      case TrailDifficulty.schwer:
        return const Color(0xFFF44336); // Rot
    }
  }

  IconData get icon {
    switch (this) {
      case TrailDifficulty.leicht:
        return Icons.terrain;
      case TrailDifficulty.mittel:
        return Icons.landscape;
      case TrailDifficulty.schwer:
        return Icons.filter_hdr;
    }
  }
}

/// Verifizierungsstatus für Sicherheit
enum TrailStatus {
  /// Geprüft und sicher begehbar
  verified,

  /// Nicht geprüft - Hinweis anzeigen!
  unverified,

  /// Saisonal eingeschränkt
  seasonal,

  /// Begehbar mit erhöhter Vorsicht
  caution,
}

extension TrailStatusExtension on TrailStatus {
  String get label {
    switch (this) {
      case TrailStatus.verified:
        return 'Geprüft';
      case TrailStatus.unverified:
        return 'Nicht verifiziert';
      case TrailStatus.seasonal:
        return 'Saisonal eingeschränkt';
      case TrailStatus.caution:
        return 'Vorsicht geboten';
    }
  }

  String get warningText {
    switch (this) {
      case TrailStatus.verified:
        return 'Offiziell geprüfter Wanderweg';
      case TrailStatus.unverified:
        return 'Dieser Weg wurde nicht offiziell verifiziert. '
            'Bitte informieren Sie sich vor Ort über die aktuelle Begehbarkeit.';
      case TrailStatus.seasonal:
        return 'Dieser Weg unterliegt saisonalen Einschränkungen. '
            'Bitte beachten Sie die aktuellen Hinweise.';
      case TrailStatus.caution:
        return 'Auf diesem Weg ist erhöhte Vorsicht geboten. '
            'Bitte beachten Sie die Sicherheitshinweise.';
    }
  }

  Color get color {
    switch (this) {
      case TrailStatus.verified:
        return const Color(0xFF4CAF50); // Grün
      case TrailStatus.unverified:
        return const Color(0xFFFF9800); // Orange
      case TrailStatus.seasonal:
        return const Color(0xFFFFC107); // Amber
      case TrailStatus.caution:
        return const Color(0xFFFF5722); // Deep Orange
    }
  }

  IconData get icon {
    switch (this) {
      case TrailStatus.verified:
        return Icons.verified_user;
      case TrailStatus.unverified:
        return Icons.help_outline;
      case TrailStatus.seasonal:
        return Icons.calendar_month;
      case TrailStatus.caution:
        return Icons.warning_amber;
    }
  }
}

/// POI entlang eines Wanderwegs
class WanderwegPoi {
  const WanderwegPoi({
    required this.name,
    required this.coords,
    required this.description,
    this.icon = Icons.place,
    this.hasWater = false,
    this.hasToilet = false,
    this.hasParking = false,
    this.hasGastro = false,
  });

  final String name;
  final LatLng coords;
  final String description;
  final IconData icon;

  /// Trinkwasser verfügbar
  final bool hasWater;

  /// Toilette verfügbar
  final bool hasToilet;

  /// Parkplatz in der Nähe
  final bool hasParking;

  /// Gastronomie in der Nähe
  final bool hasGastro;
}

/// Repräsentiert einen Wanderweg mit allen Daten
class WanderwegRoute {
  const WanderwegRoute({
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
    required this.status,
    this.estimatedHours,
    this.elevationGain,
    this.elevationLoss,
    this.highestPoint,
    this.lowestPoint,
    this.safetyWarning,
    this.seasonalInfo,
    this.isCircular = false,
    this.websiteUrl,
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
  final WanderwegCategory category;

  /// Länge in km
  final double lengthKm;

  /// Schwierigkeit
  final TrailDifficulty difficulty;

  /// Farbe für die Route auf der Karte
  final Color routeColor;

  /// GPS-Punkte der Route
  final List<LatLng> routePoints;

  /// POIs entlang der Route
  final List<WanderwegPoi> pois;

  /// Zentrum für Kartenzentrierung
  final LatLng center;

  /// Zoom-Level für Übersicht
  final double overviewZoom;

  /// Verifizierungsstatus
  final TrailStatus status;

  /// Geschätzte Gehzeit in Stunden
  final double? estimatedHours;

  /// Höhenmeter aufwärts
  final int? elevationGain;

  /// Höhenmeter abwärts
  final int? elevationLoss;

  /// Höchster Punkt (m ü. NN)
  final int? highestPoint;

  /// Tiefster Punkt (m ü. NN)
  final int? lowestPoint;

  /// Spezifische Sicherheitswarnung
  final String? safetyWarning;

  /// Saisonale Informationen
  final String? seasonalInfo;

  /// Ist es ein Rundweg?
  final bool isCircular;

  /// Website-URL
  final String? websiteUrl;

  /// Zeigt Warnhinweis an wenn nicht verifiziert
  bool get needsWarning => status != TrailStatus.verified;

  /// Glow-Farbe für Karteneffekt
  Color get glowColor => routeColor.withAlpha(64);

  /// Hellere Variante der Routenfarbe
  Color get lightColor => Color.lerp(routeColor, Colors.white, 0.3)!;

  /// Formatierte Gehzeit
  String get formattedDuration {
    if (estimatedHours == null) return '—';
    final hours = estimatedHours!.floor();
    final minutes = ((estimatedHours! - hours) * 60).round();
    if (hours == 0) return '${minutes}min';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }

  /// Formatierte Höhenmeter
  String get formattedElevation {
    if (elevationGain == null) return '—';
    return '↑${elevationGain}m';
  }
}
