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
  /// Route: Europa-Rosarium → Hohe Linde → Moltkewarte → Lengefeld →
  /// Röhrigschacht Wettelrode → Kunstteich → Grillenberg → zurück
  /// Koordinaten basierend auf OpenStreetMap/Mapcarta Recherche
  static final List<LatLng> mainRoute = [
    // === Start: Europa-Rosarium Sangerhausen (Südosten) ===
    const LatLng(51.4752, 11.3148),

    // === Abschnitt 1: Sangerhausen Richtung Westen ===
    const LatLng(51.4760, 11.3100),
    const LatLng(51.4770, 11.3050),
    const LatLng(51.4780, 11.3000),
    const LatLng(51.4790, 11.2950),

    // === Abschnitt 2: Nordwest zur Hohen Linde ===
    const LatLng(51.4820, 11.2920),
    const LatLng(51.4860, 11.2890),
    const LatLng(51.4900, 11.2870),
    // Hohe Linde (Schachthalde, 145m)
    const LatLng(51.4939, 11.2861),

    // === Abschnitt 3: Weiter NW zur Moltkewarte ===
    const LatLng(51.4935, 11.2800),
    const LatLng(51.4932, 11.2750),
    // Moltkewarte (Aussichtsturm)
    const LatLng(51.4931, 11.2710),

    // === Abschnitt 4: Nord nach Lengefeld ===
    const LatLng(51.4960, 11.2705),
    const LatLng(51.5000, 11.2700),
    // Lengefeld
    const LatLng(51.5041, 11.2705),

    // === Abschnitt 5: Nordost zum Röhrigschacht ===
    const LatLng(51.5070, 11.2730),
    const LatLng(51.5100, 11.2760),
    const LatLng(51.5130, 11.2790),
    const LatLng(51.5155, 11.2810),
    // Röhrigschacht Wettelrode
    const LatLng(51.5173, 11.2821),

    // === Abschnitt 6: Nord zum Kunstteich ===
    const LatLng(51.5195, 11.2830),
    const LatLng(51.5220, 11.2850),
    // Kunstteich Wettelrode
    const LatLng(51.5240, 11.2870),

    // === Abschnitt 7: Bogen nach Osten ===
    const LatLng(51.5250, 11.2920),
    const LatLng(51.5255, 11.2980),
    const LatLng(51.5250, 11.3040),

    // === Abschnitt 8: Süd Richtung Grillenberg ===
    const LatLng(51.5220, 11.3080),
    const LatLng(51.5180, 11.3100),
    const LatLng(51.5140, 11.3110),
    const LatLng(51.5100, 11.3100),
    const LatLng(51.5060, 11.3080),

    // === Abschnitt 9: Grillenberg Bereich ===
    const LatLng(51.5020, 11.3050),
    const LatLng(51.4980, 11.3030),
    const LatLng(51.4940, 11.3020),

    // === Abschnitt 10: Zurück nach Sangerhausen ===
    const LatLng(51.4900, 11.3040),
    const LatLng(51.4860, 11.3070),
    const LatLng(51.4820, 11.3100),
    const LatLng(51.4790, 11.3120),
    const LatLng(51.4770, 11.3135),

    // === Zurück zum Start ===
    const LatLng(51.4752, 11.3148),
  ];

  /// Wichtige Punkte entlang der Route (POIs)
  /// Koordinaten basierend auf Mapcarta/OpenStreetMap Recherche
  static const List<KupferPoi> pois = [
    KupferPoi(
      name: 'Europa-Rosarium Sangerhausen',
      coords: LatLng(51.4752, 11.3148),
      description: 'Weltgrößte Rosensammlung mit 8.700 Sorten',
      icon: Icons.local_florist,
    ),
    KupferPoi(
      name: 'Hohe Linde',
      coords: LatLng(51.4939, 11.2861),
      description: '145m hohe Bergbauhalde, Wahrzeichen Sangerhausens',
      icon: Icons.landscape,
    ),
    KupferPoi(
      name: 'Moltkewarte',
      coords: LatLng(51.4931, 11.2710),
      description: 'Aussichtsturm mit Blick über das Bergbaurevier',
      icon: Icons.visibility,
    ),
    KupferPoi(
      name: 'Röhrigschacht Wettelrode',
      coords: LatLng(51.5173, 11.2821),
      description: 'ErlebnisZentrum Bergbau, 283m Tiefe erlebbar',
      icon: Icons.engineering,
    ),
    KupferPoi(
      name: 'Kunstteich Wettelrode',
      coords: LatLng(51.5240, 11.2870),
      description: 'Historischer Bergbauteich von 1728',
      icon: Icons.water,
    ),
  ];

  /// Zentrum der Route (für Kartenzentrierung)
  static const LatLng center = LatLng(51.5000, 11.2950);

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
