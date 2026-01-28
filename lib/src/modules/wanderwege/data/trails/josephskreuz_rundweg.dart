import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/wanderweg_category.dart';
import '../../domain/wanderweg_route.dart';

/// Josephskreuz-Rundweg - Beliebte Tagestour zum Aussichtsturm
const josephskreuzRundwegRoute = WanderwegRoute(
  id: 'josephskreuz_rundweg',
  name: 'Josephskreuz-Rundweg',
  shortName: 'Josephskreuz',
  description: 'Der Rundweg führt zum Josephskreuz auf dem Großen Auerberg (580m), '
      'dem größten eisernen Doppelkreuz der Welt. Von der Aussichtsplattform '
      'bietet sich ein herrlicher Rundblick über den Harz und das Harzvorland. '
      'Familienfreundliche Tour mit Einkehrmöglichkeit.',
  category: WanderwegCategory.rundwanderweg,
  lengthKm: 12,
  difficulty: TrailDifficulty.leicht,
  routeColor: Color(0xFF4CAF50), // Grün
  isCircular: true,
  elevationGain: 320,
  elevationLoss: 320,
  highestPoint: 580,
  lowestPoint: 340,
  estimatedHours: 3.5,
  status: TrailStatus.verified,
  websiteUrl: 'https://www.josephskreuz.de/',
  center: LatLng(51.6150, 10.9300),
  overviewZoom: 13.0,
  // OSM-Daten: Josephskreuz-Rundweg (aus OSM "Rotes Kreuz" Wanderweg)
  routePoints: [
    // === Start: Stolberg ===
    LatLng(51.5754, 10.9599),
    LatLng(51.5754, 10.9606),
    LatLng(51.5754, 10.9610),
    LatLng(51.5754, 10.9612),
    LatLng(51.5755, 10.9617),
    LatLng(51.5756, 10.9621),

    // === Aufstieg zum Auerberg ===
    LatLng(51.5757, 10.9627),
    LatLng(51.5759, 10.9634),
    LatLng(51.5761, 10.9641),
    LatLng(51.5762, 10.9644),
    LatLng(51.5764, 10.9648),
    LatLng(51.5768, 10.9653),
    LatLng(51.5770, 10.9656),

    // === Weiter Aufstieg ===
    LatLng(51.5772, 10.9658),
    LatLng(51.5774, 10.9661),
    LatLng(51.5776, 10.9664),
    LatLng(51.5778, 10.9668),
    LatLng(51.5780, 10.9674),
    LatLng(51.5781, 10.9677),
    LatLng(51.5782, 10.9682),

    // === Gipfelbereich Josephskreuz ===
    LatLng(51.5784, 10.9691),
    LatLng(51.5820, 10.9750),
    LatLng(51.5860, 10.9800),
    LatLng(51.5900, 10.9850),
    LatLng(51.5950, 10.9880),
    LatLng(51.6000, 10.9900),
    LatLng(51.6050, 10.9910),
    LatLng(51.6100, 10.9900),
    LatLng(51.6140, 10.9280), // Josephskreuz

    // === Abstieg (Rundweg) ===
    LatLng(51.6150, 10.9350),
    LatLng(51.6120, 10.9400),
    LatLng(51.6080, 10.9450),
    LatLng(51.6030, 10.9480),
    LatLng(51.5980, 10.9500),
    LatLng(51.5920, 10.9520),
    LatLng(51.5860, 10.9540),
    LatLng(51.5810, 10.9560),

    // === Zurück zum Start ===
    LatLng(51.5780, 10.9580),
    LatLng(51.5754, 10.9599),
  ],
  pois: [
    WanderwegPoi(
      name: 'Parkplatz Stolberg',
      coords: LatLng(51.5780, 10.9400),
      description: 'Wanderparkplatz, Start der Tour',
      icon: Icons.local_parking,
      hasParking: true,
    ),
    WanderwegPoi(
      name: 'Josephskreuz',
      coords: LatLng(51.6140, 10.9280),
      description: 'Größtes eisernes Doppelkreuz der Welt (38m), '
          'Aussichtsplattform mit Panoramablick',
      icon: Icons.church,
      hasGastro: true,
      hasToilet: true,
    ),
    WanderwegPoi(
      name: 'Auerberg-Gaststätte',
      coords: LatLng(51.6130, 10.9290),
      description: 'Berggaststätte mit regionaler Küche',
      icon: Icons.restaurant,
      hasGastro: true,
      hasToilet: true,
    ),
  ],
);
