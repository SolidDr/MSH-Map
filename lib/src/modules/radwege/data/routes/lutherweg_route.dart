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
  center: const LatLng(51.25, 10.90),
  overviewZoom: 8.5,
  routePoints: const [
    // === Start: Lutherstadt Eisleben ===
    // Luthers Geburtshaus
    LatLng(51.5276, 11.5497),

    // === Abschnitt 1: Eisleben Zentrum ===
    LatLng(51.5284, 11.5449),
    LatLng(51.5290, 11.5380),
    LatLng(51.5300, 11.5300),

    // === Abschnitt 2: Eisleben → Norden nach Mansfeld ===
    LatLng(51.5350, 11.5200),
    LatLng(51.5420, 11.5100),
    LatLng(51.5500, 11.5020),
    LatLng(51.5580, 11.4950),
    LatLng(51.5660, 11.4880),
    LatLng(51.5740, 11.4800),
    LatLng(51.5820, 11.4720),
    LatLng(51.5900, 11.4660),
    // Mansfeld-Lutherstadt (Schloss)
    LatLng(51.5980, 11.4580),

    // === Abschnitt 3: Mansfeld → Westen durch Südharz ===
    LatLng(51.5950, 11.4400),
    LatLng(51.5920, 11.4200),
    LatLng(51.5890, 11.3980),
    LatLng(51.5870, 11.3750),
    LatLng(51.5850, 11.3500),
    LatLng(51.5840, 11.3250),
    LatLng(51.5830, 11.3000),
    LatLng(51.5820, 11.2750),
    LatLng(51.5810, 11.2500),
    LatLng(51.5800, 11.2250),
    LatLng(51.5790, 11.2000),
    LatLng(51.5780, 11.1750),
    LatLng(51.5770, 11.1500),
    LatLng(51.5760, 11.1250),
    LatLng(51.5750, 11.1000),
    LatLng(51.5745, 11.0750),
    LatLng(51.5742, 11.0500),
    LatLng(51.5740, 11.0250),
    LatLng(51.5738, 11.0000),
    // Stolberg (Harz) - Fachwerkstadt
    LatLng(51.5740, 10.9500),

    // === Abschnitt 4: Stolberg → durch Südharz nach SW ===
    LatLng(51.5700, 10.9200),
    LatLng(51.5650, 10.8900),
    LatLng(51.5580, 10.8600),
    LatLng(51.5500, 10.8300),
    LatLng(51.5400, 10.8000),
    LatLng(51.5280, 10.7750),
    // Nordhausen Gebiet
    LatLng(51.5100, 10.7900),

    // === Abschnitt 5: → Süden Richtung Mühlhausen ===
    LatLng(51.4800, 10.7600),
    LatLng(51.4500, 10.7300),
    LatLng(51.4200, 10.6900),
    LatLng(51.3900, 10.6500),
    LatLng(51.3600, 10.6100),
    LatLng(51.3300, 10.5700),
    LatLng(51.3000, 10.5300),
    LatLng(51.2700, 10.5000),
    LatLng(51.2400, 10.4700),
    // Mühlhausen (historische Reichsstadt)
    LatLng(51.2086, 10.4528),

    // === Abschnitt 6: Mühlhausen → Eisenach ===
    LatLng(51.1800, 10.4400),
    LatLng(51.1500, 10.4200),
    LatLng(51.1200, 10.4000),
    LatLng(51.0900, 10.3800),
    LatLng(51.0600, 10.3600),
    LatLng(51.0300, 10.3400),
    LatLng(51.0000, 10.3250),

    // === Abschnitt 7: Eisenach + Wartburg ===
    // Wartburg (UNESCO-Welterbe)
    LatLng(50.9667, 10.3066),
    // Eisenach Zentrum
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
      coords: LatLng(51.5284, 11.5449),
      description: 'Hier starb Luther 1546',
      icon: Icons.museum,
    ),
    RadwegPoi(
      name: 'Mansfeld-Lutherstadt',
      coords: LatLng(51.5980, 11.4580),
      description: 'Luthers Kindheit: Elternhaus und Schloss',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Stolberg (Harz)',
      coords: LatLng(51.5740, 10.9500),
      description: 'Fachwerkstadt im Südharz',
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
