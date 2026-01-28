import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Daten für den Kupferspurenradweg
/// ~48km Rundweg um Sangerhausen, verbindet Bergbau-Industriekultur
class KupferRouteData {
  KupferRouteData._();

  /// Kupferfarbe für die Route
  static const Color kupferColor = Color(0xFFB87333);
  static const Color kupferGlow = Color(0x40B87333);
  static const Color kupferLight = Color(0xFFD4956A);

  /// Gesamtlänge in km
  static const double totalLengthKm = 48;

  /// Kontakt
  static const String contactName = 'Maximilian Bartczak';
  static const String contactRole = 'Radwegekoordination';
  static const String contactPhone = '+49 3464 545 99-27';
  static const String contactEmail = 'maximilian.bartczak@lkmsh.de';

  /// Webseiten
  static const String websiteSeg = 'https://www.seg-msh.de/kupferspuren-radweg/';
  static const String websiteKupferspuren = 'https://kupferspuren.eu/';

  /// Hauptroute (~48km Rundweg um Sangerhausen)
  /// Basierend auf bekannten Punkten: Europa-Rosarium, Hohe Linde,
  /// Lengefeld, Röhrigschacht Wettelrode, Kunstteich, Grillenburg
  static final List<LatLng> mainRoute = [
    // Start: Europa-Rosarium Sangerhausen
    const LatLng(51.4748, 11.2965),
    // Richtung Norden zur Hohen Linde
    const LatLng(51.4765, 11.2958),
    const LatLng(51.4785, 11.2945),
    // Hohe Linde (144m Halde)
    const LatLng(51.4810, 11.2935),
    const LatLng(51.4835, 11.2950),
    // Weiter nach Norden Richtung Lengefeld
    const LatLng(51.4865, 11.2980),
    const LatLng(51.4895, 11.3015),
    const LatLng(51.4925, 11.3055),
    // Lengefeld
    const LatLng(51.4955, 11.3095),
    const LatLng(51.4985, 11.3135),
    // Weiter nach Nordosten Richtung Wettelrode
    const LatLng(51.5015, 11.3175),
    const LatLng(51.5045, 11.3215),
    const LatLng(51.5070, 11.3255),
    // Röhrigschacht Wettelrode
    const LatLng(51.5095, 11.3290),
    const LatLng(51.5110, 11.3310),
    // Kunstteich Wettelrode (nördlich)
    const LatLng(51.5135, 11.3285),
    const LatLng(51.5155, 11.3250),
    const LatLng(51.5170, 11.3210),
    // Bogen nach Osten
    const LatLng(51.5165, 11.3160),
    const LatLng(51.5150, 11.3120),
    const LatLng(51.5130, 11.3090),
    // Richtung Südosten
    const LatLng(51.5100, 11.3150),
    const LatLng(51.5065, 11.3220),
    const LatLng(51.5030, 11.3290),
    // Grillenburg Bereich
    const LatLng(51.4995, 11.3350),
    const LatLng(51.4960, 11.3400),
    const LatLng(51.4920, 11.3440),
    const LatLng(51.4875, 11.3470),
    // Südliche Route zurück
    const LatLng(51.4830, 11.3480),
    const LatLng(51.4785, 11.3460),
    const LatLng(51.4740, 11.3420),
    const LatLng(51.4695, 11.3370),
    const LatLng(51.4655, 11.3310),
    const LatLng(51.4620, 11.3245),
    const LatLng(51.4595, 11.3175),
    const LatLng(51.4580, 11.3100),
    // Zurück nach Sangerhausen
    const LatLng(51.4590, 11.3025),
    const LatLng(51.4615, 11.2960),
    const LatLng(51.4650, 11.2920),
    const LatLng(51.4690, 11.2905),
    const LatLng(51.4720, 11.2925),
    // Zurück zum Start
    const LatLng(51.4748, 11.2965),
  ];

  /// Wichtige Punkte entlang der Route (POIs)
  static const List<KupferPoi> pois = [
    KupferPoi(
      name: 'Europa-Rosarium Sangerhausen',
      coords: LatLng(51.4748, 11.2965),
      description: 'Weltgrößte Rosensammlung mit 8.700 Sorten',
      icon: Icons.local_florist,
    ),
    KupferPoi(
      name: 'Hohe Linde',
      coords: LatLng(51.4810, 11.2935),
      description: '144m hohe Bergbauhalde, Wahrzeichen Sangerhausens',
      icon: Icons.landscape,
    ),
    KupferPoi(
      name: 'Röhrigschacht Wettelrode',
      coords: LatLng(51.5095, 11.3290),
      description: 'ErlebnisZentrum Bergbau, 283m Tiefe erlebbar',
      icon: Icons.engineering,
    ),
    KupferPoi(
      name: 'Kunstteich Wettelrode',
      coords: LatLng(51.5155, 11.3250),
      description: 'Historischer Bergbauteich von 1728',
      icon: Icons.water,
    ),
    KupferPoi(
      name: 'Grillenburg',
      coords: LatLng(51.4920, 11.3440),
      description: 'Historischer Aussichtspunkt',
      icon: Icons.castle,
    ),
  ];

  /// Zentrum der Route (für Kartenzentrierung)
  static const LatLng center = LatLng(51.4900, 11.3200);

  /// Zoom-Level für Übersicht
  static const double overviewZoom = 12.5;
}

/// POI entlang der Kupferspuren-Route
class KupferPoi {
  const KupferPoi({
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
