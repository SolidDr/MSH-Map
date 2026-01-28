import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/wanderweg_category.dart';
import '../../domain/wanderweg_route.dart';

/// Thyra-Talweg - Familienfreundlicher Weg entlang der Thyra
const thyraTalwegRoute = WanderwegRoute(
  id: 'thyra_talweg',
  name: 'Thyra-Talweg',
  shortName: 'Thyra',
  description: 'Der familienfreundliche Thyra-Talweg folgt dem gleichnamigen '
      'Flüsschen von der Talsperre Kelbra bis nach Stolberg. Der überwiegend '
      'flache Weg ist auch für Kinderwagen geeignet und bietet viele '
      'Rastmöglichkeiten am Wasser. Ideal für heiße Sommertage.',
  category: WanderwegCategory.familientour,
  lengthKm: 10,
  difficulty: TrailDifficulty.leicht,
  routeColor: Color(0xFF81C784), // Mintgrün
  elevationGain: 80,
  elevationLoss: 50,
  highestPoint: 320,
  lowestPoint: 180,
  estimatedHours: 2.5,
  status: TrailStatus.verified,
  seasonalInfo: 'Ganzjährig begehbar, im Winter kann der Weg vereist sein.',
  websiteUrl: 'https://www.kyffhaeuser-tourismus.de/',
  center: LatLng(51.5400, 10.9800),
  overviewZoom: 12.5,
  // OSM-Daten: Thyra-Talweg (vereinfacht aus OSM Thyra-Routen)
  routePoints: [
    // === Start: Talsperre Kelbra ===
    LatLng(51.4650, 10.9947), // Nähe Talsperre
    LatLng(51.4648, 10.9946),
    LatLng(51.4647, 10.9944),
    LatLng(51.4648, 10.9939),

    // === Entlang Thyra nordwärts ===
    LatLng(51.4680, 10.9920),
    LatLng(51.4720, 10.9880),
    LatLng(51.4760, 10.9850),
    LatLng(51.4800, 10.9810),
    LatLng(51.4850, 10.9770),
    LatLng(51.4900, 10.9730),

    // === Mittelteil durch Thyratal ===
    LatLng(51.4950, 10.9700),
    LatLng(51.5000, 10.9670),
    LatLng(51.5050, 10.9640),
    LatLng(51.5100, 10.9620),
    LatLng(51.5150, 10.9600),

    // === Richtung Stolberg ===
    LatLng(51.5200, 10.9590),
    LatLng(51.5250, 10.9575),
    LatLng(51.5300, 10.9560),
    LatLng(51.5350, 10.9550),
    LatLng(51.5400, 10.9545),

    // === Stolberg Bereich ===
    LatLng(51.5450, 10.9540),
    LatLng(51.5500, 10.9535),
    LatLng(51.5550, 10.9525),
    LatLng(51.5600, 10.9520),
    LatLng(51.5650, 10.9515),
    LatLng(51.5700, 10.9515),

    // === Ende: Stolberg Markt ===
    LatLng(51.5740, 10.9520),
  ],
  pois: [
    WanderwegPoi(
      name: 'Talsperre Kelbra',
      coords: LatLng(51.4650, 11.0450),
      description: 'Stausee mit Bademöglichkeit im Sommer',
      icon: Icons.water,
      hasParking: true,
      hasToilet: true,
    ),
    WanderwegPoi(
      name: 'Thyra-Rastplatz',
      coords: LatLng(51.5100, 10.9850),
      description: 'Schöner Rastplatz am Bach mit Picknicktischen',
      icon: Icons.deck,
      hasWater: true,
    ),
    WanderwegPoi(
      name: 'Wassermühle',
      coords: LatLng(51.5350, 10.9600),
      description: 'Historische Wassermühle (nur Außenbesichtigung)',
      icon: Icons.water_damage,
    ),
    WanderwegPoi(
      name: 'Stolberg',
      coords: LatLng(51.5740, 10.9520),
      description: 'Ziel: Historische Fachwerkstadt',
      icon: Icons.flag,
      hasParking: true,
      hasGastro: true,
      hasToilet: true,
    ),
  ],
);
