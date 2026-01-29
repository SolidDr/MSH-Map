import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Kupferspurenradweg - ~48km Rundweg um Sangerhausen
/// Verbindet Bergbau-Industriekultur der Region
const kupferspurenRoute = RadwegRoute(
  id: 'kupferspuren',
  name: 'Kupferspurenradweg',
  shortName: 'Kupferspuren',
  description: '800 Jahre Bergbaugeschichte auf einem Radweg: '
      'Entlang an Halden, Schächten und Kupferspuren '
      'durch Mansfeld-Südharz.\n\n'
      '⚠️ Hinweis: Dieser Radweg befindet sich in der Ausbauphase. '
      'Der dargestellte Verlauf entspricht dem aktuellen Planungsstand.',
  category: RadwegCategory.themenweg,
  lengthKm: 48,
  difficulty: 'Leicht',
  routeColor: Color(0xFFB87333), // Kupferfarbe
  isLoop: true,
  elevationGain: 350,
  websiteUrl: 'https://www.seg-msh.de/kupferspuren-radweg/',
  contactName: 'Maximilian Bartczak',
  contactRole: 'Radwegekoordination',
  contactPhone: '+49 3464 545 99-27',
  contactEmail: 'maximilian.bartczak@lkmsh.de',
  center: LatLng(51.5050, 11.3100),
  overviewZoom: 11.5,
  routePoints: [
    // === Start: Sangerhausen Rosarium ===
    LatLng(51.4752, 11.3148),

    // === Abschnitt 1: Sangerhausen nach Westen ===
    LatLng(51.4755, 11.3080),
    LatLng(51.4760, 11.3000),
    LatLng(51.4768, 11.2920),
    LatLng(51.4780, 11.2850),

    // === Abschnitt 2: Nordwest Richtung Hohe Linde ===
    LatLng(51.4810, 11.2800),
    LatLng(51.4850, 11.2750),
    LatLng(51.4890, 11.2700),
    // Hohe Linde
    LatLng(51.4939, 11.2680),

    // === Abschnitt 3: Weiter nach Lengefeld ===
    LatLng(51.4980, 11.2650),
    LatLng(51.5020, 11.2620),
    // Lengefeld
    LatLng(51.5041, 11.2580),
    LatLng(51.5070, 11.2550),

    // === Abschnitt 4: Nord Richtung Wettelrode ===
    LatLng(51.5100, 11.2580),
    LatLng(51.5130, 11.2650),
    // Röhrigschacht Wettelrode
    LatLng(51.5163, 11.2852),

    // === Abschnitt 5: Kunstteich und weiter Nord ===
    LatLng(51.5200, 11.2880),
    // Kunstteich
    LatLng(51.5240, 11.2870),
    LatLng(51.5280, 11.2900),

    // === Abschnitt 6: Grillenberg Bereich ===
    LatLng(51.5320, 11.2950),
    LatLng(51.5350, 11.3000),
    // Grillenberg
    LatLng(51.5380, 11.3100),

    // === Abschnitt 7: Ost nach Obersdorf ===
    LatLng(51.5370, 11.3180),
    LatLng(51.5350, 11.3250),
    // Obersdorf
    LatLng(51.5320, 11.3320),
    LatLng(51.5280, 11.3400),

    // === Abschnitt 8: Südost nach Gonna ===
    LatLng(51.5230, 11.3480),
    LatLng(51.5180, 11.3550),
    // Gonna
    LatLng(51.5120, 11.3620),
    LatLng(51.5050, 11.3650),

    // === Abschnitt 9: Süd zurück nach Sangerhausen ===
    LatLng(51.4980, 11.3600),
    LatLng(51.4920, 11.3520),
    LatLng(51.4870, 11.3450),
    LatLng(51.4830, 11.3380),
    LatLng(51.4800, 11.3300),
    LatLng(51.4770, 11.3220),

    // === Zurück zum Start ===
    LatLng(51.4752, 11.3148),
  ],
  pois: [
    RadwegPoi(
      name: 'Europa-Rosarium Sangerhausen',
      coords: LatLng(51.4752, 11.3148),
      description: 'Weltgrößte Rosensammlung mit 8.700 Sorten',
      icon: Icons.local_florist,
    ),
    RadwegPoi(
      name: 'Hohe Linde',
      coords: LatLng(51.4939, 11.2680),
      description: '145m hohe Bergbauhalde, Wahrzeichen Sangerhausens',
      icon: Icons.landscape,
    ),
    RadwegPoi(
      name: 'Lengefeld',
      coords: LatLng(51.5041, 11.2580),
      description: 'Historisches Bergbaudorf',
      icon: Icons.home_work,
    ),
    RadwegPoi(
      name: 'Röhrigschacht Wettelrode',
      coords: LatLng(51.5163, 11.2852),
      description: 'ErlebnisZentrum Bergbau, 283m Tiefe erlebbar',
      icon: Icons.engineering,
    ),
    RadwegPoi(
      name: 'Kunstteich Wettelrode',
      coords: LatLng(51.5240, 11.2870),
      description: 'Historischer Bergbauteich von 1728',
      icon: Icons.water,
    ),
    RadwegPoi(
      name: 'Grillenberg',
      coords: LatLng(51.5380, 11.3100),
      description: 'Staatlich anerkannter Erholungsort am Harzrand',
      icon: Icons.landscape,
    ),
    RadwegPoi(
      name: 'Obersdorf',
      coords: LatLng(51.5320, 11.3320),
      description: 'Ortsteil von Sangerhausen',
      icon: Icons.location_city,
    ),
    RadwegPoi(
      name: 'Gonna',
      coords: LatLng(51.5120, 11.3620),
      description: 'Historisches Dorf mit Bergbautradition',
      icon: Icons.location_city,
    ),
  ],
);
