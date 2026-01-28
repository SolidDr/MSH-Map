import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Lutherweg (Radwege zu Luther) - ~239km Eisleben nach Eisenach
/// Auf den Spuren Martin Luthers durch Sachsen-Anhalt und Thüringen
final lutherwegRoute = RadwegRoute(
  id: 'lutherweg',
  name: 'Radwege zu Luther (Eisleben-Eisenach)',
  shortName: 'Lutherweg',
  description: 'Von Luthers Geburts- und Sterbestadt Eisleben '
      'über Mansfeld und Stolberg bis zur Wartburg in Eisenach, '
      'wo Luther das Neue Testament übersetzte.',
  category: RadwegCategory.fernradweg,
  lengthKm: 239,
  difficulty: 'Schwer',
  routeColor: const Color(0xFF8B4513), // Luther-Braun (Kutte)
  isLoop: false,
  elevationGain: 1850,
  websiteUrl: 'https://www.lutherweg.de/',
  center: const LatLng(51.25, 10.95),
  overviewZoom: 9.0,
  routePoints: const [
    // === Start: Lutherstadt Eisleben ===
    // Luthers Geburtshaus
    LatLng(51.5276, 11.5497),

    // === Abschnitt 1: Eisleben Zentrum ===
    LatLng(51.5284, 11.5449),
    // St. Andreas Kirche
    LatLng(51.5284, 11.5449),

    // === Abschnitt 2: Eisleben Richtung Westen ===
    LatLng(51.5260, 11.5300),
    LatLng(51.5240, 11.5100),
    LatLng(51.5220, 11.4900),

    // === Abschnitt 3: Richtung Mansfeld ===
    LatLng(51.5200, 11.4700),
    LatLng(51.5180, 11.4500),
    LatLng(51.5160, 11.4300),
    // Mansfeld-Lutherstadt
    LatLng(51.5980, 11.4600),

    // === Abschnitt 4: Richtung Stolberg (Harz) ===
    LatLng(51.5800, 11.4000),
    LatLng(51.5700, 11.3500),
    LatLng(51.5650, 11.3000),
    // Stolberg (Harz)
    LatLng(51.5740, 10.9500),

    // === Abschnitt 5: Durch den Harz ===
    LatLng(51.5600, 10.9000),
    LatLng(51.5500, 10.8500),
    LatLng(51.5400, 10.8000),

    // === Abschnitt 6: Thüringen - Richtung Nordhausen ===
    LatLng(51.5000, 10.7500),
    LatLng(51.4600, 10.7000),
    // Nordhausen Gebiet
    LatLng(51.5000, 10.7900),

    // === Abschnitt 7: Mühlhausen ===
    LatLng(51.3500, 10.6000),
    LatLng(51.2500, 10.5000),
    // Mühlhausen
    LatLng(51.2086, 10.4528),

    // === Abschnitt 8: Richtung Eisenach ===
    LatLng(51.1500, 10.4000),
    LatLng(51.1000, 10.3500),
    LatLng(51.0500, 10.3200),

    // === Abschnitt 9: Eisenach ===
    LatLng(51.0000, 10.3200),
    // Wartburg
    LatLng(50.9667, 10.3066),

    // === Ziel: Eisenach Markt ===
    LatLng(50.9749, 10.3203),
  ],
  pois: const [
    RadwegPoi(
      name: 'Luthers Geburtshaus',
      coords: LatLng(51.5276, 11.5497),
      description: 'Start: Hier wurde Martin Luther 1483 geboren',
      icon: Icons.home,
    ),
    RadwegPoi(
      name: 'Luthers Sterbehaus',
      coords: LatLng(51.5269, 11.5501),
      description: 'Hier starb Luther 1546',
      icon: Icons.museum,
    ),
    RadwegPoi(
      name: 'Mansfeld-Lutherstadt',
      coords: LatLng(51.5980, 11.4600),
      description: 'Luthers Kindheit: Elternhaus und Schloss',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Stolberg (Harz)',
      coords: LatLng(51.5740, 10.9500),
      description: 'Thomas-Müntzer-Stadt im Südharz',
      icon: Icons.location_city,
    ),
    RadwegPoi(
      name: 'Mühlhausen',
      coords: LatLng(51.2086, 10.4528),
      description: 'Historische Reichsstadt in Thüringen',
      icon: Icons.church,
    ),
    RadwegPoi(
      name: 'Wartburg',
      coords: LatLng(50.9667, 10.3066),
      description: 'UNESCO-Welterbe: Luther übersetzte hier die Bibel',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Eisenach',
      coords: LatLng(50.9749, 10.3203),
      description: 'Ziel: Lutherhaus und Bachstadt',
      icon: Icons.flag_outlined,
    ),
  ],
);
