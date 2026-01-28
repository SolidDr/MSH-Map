import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Kupferspurenradweg - ~48km Rundweg um Sangerhausen
/// Verbindet Bergbau-Industriekultur der Region
final kupferspurenRoute = RadwegRoute(
  id: 'kupferspuren',
  name: 'Kupferspurenradweg',
  shortName: 'Kupferspuren',
  description: '800 Jahre Bergbaugeschichte auf einem Radweg: '
      'Entlang an Halden, Schächten und Kupferspuren '
      'durch Mansfeld-Südharz.',
  category: RadwegCategory.themenweg,
  lengthKm: 48,
  difficulty: 'Leicht',
  routeColor: const Color(0xFFB87333), // Kupferfarbe
  isLoop: true,
  elevationGain: 350,
  websiteUrl: 'https://www.seg-msh.de/kupferspuren-radweg/',
  contactName: 'Maximilian Bartczak',
  contactRole: 'Radwegekoordination',
  contactPhone: '+49 3464 545 99-27',
  contactEmail: 'maximilian.bartczak@lkmsh.de',
  center: const LatLng(51.5000, 11.2950),
  overviewZoom: 12.5,
  routePoints: const [
    // === Start: Europa-Rosarium Sangerhausen (Südosten) ===
    LatLng(51.4752, 11.3148),

    // === Abschnitt 1: Sangerhausen Richtung Westen ===
    LatLng(51.4760, 11.3100),
    LatLng(51.4770, 11.3050),
    LatLng(51.4780, 11.3000),
    LatLng(51.4790, 11.2950),

    // === Abschnitt 2: Nordwest zur Hohen Linde ===
    LatLng(51.4820, 11.2920),
    LatLng(51.4860, 11.2890),
    LatLng(51.4900, 11.2870),
    // Hohe Linde (Schachthalde, 145m)
    LatLng(51.4939, 11.2861),

    // === Abschnitt 3: Weiter NW zur Moltkewarte ===
    LatLng(51.4935, 11.2800),
    LatLng(51.4932, 11.2750),
    // Moltkewarte (Aussichtsturm)
    LatLng(51.4931, 11.2710),

    // === Abschnitt 4: Nord nach Lengefeld ===
    LatLng(51.4960, 11.2705),
    LatLng(51.5000, 11.2700),
    // Lengefeld
    LatLng(51.5041, 11.2705),

    // === Abschnitt 5: Nordost zum Röhrigschacht ===
    LatLng(51.5070, 11.2730),
    LatLng(51.5100, 11.2760),
    LatLng(51.5130, 11.2790),
    LatLng(51.5155, 11.2810),
    // Röhrigschacht Wettelrode
    LatLng(51.5173, 11.2821),

    // === Abschnitt 6: Nord zum Kunstteich ===
    LatLng(51.5195, 11.2830),
    LatLng(51.5220, 11.2850),
    // Kunstteich Wettelrode
    LatLng(51.5240, 11.2870),

    // === Abschnitt 7: Bogen nach Osten ===
    LatLng(51.5250, 11.2920),
    LatLng(51.5255, 11.2980),
    LatLng(51.5250, 11.3040),

    // === Abschnitt 8: Süd Richtung Grillenberg ===
    LatLng(51.5220, 11.3080),
    LatLng(51.5180, 11.3100),
    LatLng(51.5140, 11.3110),
    LatLng(51.5100, 11.3100),
    LatLng(51.5060, 11.3080),

    // === Abschnitt 9: Grillenberg Bereich ===
    LatLng(51.5020, 11.3050),
    LatLng(51.4980, 11.3030),
    LatLng(51.4940, 11.3020),

    // === Abschnitt 10: Zurück nach Sangerhausen ===
    LatLng(51.4900, 11.3040),
    LatLng(51.4860, 11.3070),
    LatLng(51.4820, 11.3100),
    LatLng(51.4790, 11.3120),
    LatLng(51.4770, 11.3135),

    // === Zurück zum Start ===
    LatLng(51.4752, 11.3148),
  ],
  pois: const [
    RadwegPoi(
      name: 'Europa-Rosarium Sangerhausen',
      coords: LatLng(51.4752, 11.3148),
      description: 'Weltgrößte Rosensammlung mit 8.700 Sorten',
      icon: Icons.local_florist,
    ),
    RadwegPoi(
      name: 'Hohe Linde',
      coords: LatLng(51.4939, 11.2861),
      description: '145m hohe Bergbauhalde, Wahrzeichen Sangerhausens',
      icon: Icons.landscape,
    ),
    RadwegPoi(
      name: 'Moltkewarte',
      coords: LatLng(51.4931, 11.2710),
      description: 'Aussichtsturm mit Blick über das Bergbaurevier',
      icon: Icons.visibility,
    ),
    RadwegPoi(
      name: 'Röhrigschacht Wettelrode',
      coords: LatLng(51.5173, 11.2821),
      description: 'ErlebnisZentrum Bergbau, 283m Tiefe erlebbar',
      icon: Icons.engineering,
    ),
    RadwegPoi(
      name: 'Kunstteich Wettelrode',
      coords: LatLng(51.5240, 11.2870),
      description: 'Historischer Bergbauteich von 1728',
      icon: Icons.water,
    ),
  ],
);
