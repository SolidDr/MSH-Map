import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/wanderweg_category.dart';
import '../../domain/wanderweg_route.dart';

/// Selketal-Stieg - Qualitätswanderweg durch das Selketal
const selketalStiegRoute = WanderwegRoute(
  id: 'selketal_stieg',
  name: 'Selketal-Stieg',
  shortName: 'Selketal',
  description: 'Der Selketal-Stieg führt entlang der Selke durch eines der '
      'romantischsten Täler des Harzes. Der zertifizierte Qualitätswanderweg '
      'verbindet Naturerlebnis mit historischen Sehenswürdigkeiten wie der '
      'Selketalbahn und mittelalterlichen Burgen.',
  category: WanderwegCategory.fernwanderweg,
  lengthKm: 75,
  difficulty: TrailDifficulty.mittel,
  routeColor: Color(0xFF1B5E20), // Dunkelgrün
  isCircular: false,
  elevationGain: 1200,
  elevationLoss: 1150,
  highestPoint: 480,
  lowestPoint: 160,
  estimatedHours: 20,
  status: TrailStatus.verified,
  websiteUrl: 'https://www.harzinfo.de/erlebnisse/wandern/selketal-stieg',
  center: LatLng(51.68, 11.15),
  overviewZoom: 10.0,
  // OSM-Daten: Selketal-Stieg (vereinfacht)
  routePoints: [
    // === Start: Stiege Bereich ===
    LatLng(51.6612, 10.8806),
    LatLng(51.6605, 10.8840),
    LatLng(51.6595, 10.8855),
    LatLng(51.6591, 10.8877),
    LatLng(51.6594, 10.8901),

    // === Durch Selketal ===
    LatLng(51.6574, 10.8995),
    LatLng(51.6586, 10.8956),
    LatLng(51.6574, 10.9028),
    LatLng(51.6528, 10.9098),
    LatLng(51.6547, 10.9071),
    LatLng(51.6515, 10.9131),

    // === Güntersberge Bereich ===
    LatLng(51.6482, 10.9155),
    LatLng(51.6463, 10.9161),
    LatLng(51.6448, 10.9171),
    LatLng(51.6434, 10.9273),
    LatLng(51.6429, 10.9285),
    LatLng(51.6391, 10.9299),

    // === Entlang Selke ===
    LatLng(51.6379, 10.9311),
    LatLng(51.6365, 10.9353),
    LatLng(51.6381, 10.9355),
    LatLng(51.6391, 10.9455),
    LatLng(51.6393, 10.9544),
    LatLng(51.6392, 10.9588),

    // === Alexisbad Bereich ===
    LatLng(51.6394, 10.9630),
    LatLng(51.6392, 10.9659),
    LatLng(51.6376, 10.9682),
    LatLng(51.6364, 10.9687),
    LatLng(51.6383, 10.9696),
    LatLng(51.6405, 10.9769),
    LatLng(51.6410, 10.9781),

    // === Mägdesprung Richtung ===
    LatLng(51.6450, 10.9900),
    LatLng(51.6500, 11.0050),
    LatLng(51.6550, 11.0200),
    LatLng(51.6600, 11.0350),
    LatLng(51.6650, 11.0500),

    // === Burg Falkenstein Bereich ===
    LatLng(51.6700, 11.0650),
    LatLng(51.6750, 11.0800),
    LatLng(51.6800, 11.0950),
    LatLng(51.6850, 11.1100),
    LatLng(51.6900, 11.1250),

    // === Meisdorf Richtung ===
    LatLng(51.6950, 11.1400),
    LatLng(51.7000, 11.1550),
    LatLng(51.7050, 11.1700),
    LatLng(51.7100, 11.1850),

    // === Ende Ballenstedt ===
    LatLng(51.7150, 11.2000),
    LatLng(51.7180, 11.2150),
    LatLng(51.7150, 11.2350),
  ],
  pois: [
    WanderwegPoi(
      name: 'Stiege',
      coords: LatLng(51.6500, 10.8800),
      description: 'Startpunkt, Selketalbahn-Station',
      icon: Icons.train,
      hasParking: true,
    ),
    WanderwegPoi(
      name: 'Alexisbad',
      coords: LatLng(51.6900, 11.0550),
      description: 'Historischer Kurort mit Selketalbahn',
      icon: Icons.spa,
      hasParking: true,
      hasGastro: true,
      hasToilet: true,
    ),
    WanderwegPoi(
      name: 'Burg Falkenstein',
      coords: LatLng(51.7100, 11.1450),
      description: 'Gut erhaltene Höhenburg aus dem 12. Jh.',
      icon: Icons.castle,
      hasGastro: true,
    ),
    WanderwegPoi(
      name: 'Ballenstedt',
      coords: LatLng(51.7150, 11.2350),
      description: 'Residenzstadt mit Schloss und Schlosspark',
      icon: Icons.location_city,
      hasParking: true,
      hasGastro: true,
      hasToilet: true,
    ),
  ],
);
