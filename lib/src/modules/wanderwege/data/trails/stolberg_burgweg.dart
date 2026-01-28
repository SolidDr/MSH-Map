import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/wanderweg_category.dart';
import '../../domain/wanderweg_route.dart';

/// Stolberger Burgweg - Historischer Rundweg durch die Fachwerkstadt
const stolbergBurgwegRoute = WanderwegRoute(
  id: 'stolberg_burgweg',
  name: 'Stolberger Burgweg',
  shortName: 'Stolberg',
  description: 'Der Stolberger Burgweg führt durch die historische Fachwerkstadt '
      'Stolberg und hinauf zum Schloss. Der Rundweg verbindet mittelalterliche '
      'Geschichte mit herrlichen Ausblicken über das Tal. Thomas Müntzer wirkte '
      'hier als Prediger - Geschichte zum Anfassen.',
  category: WanderwegCategory.themenwanderweg,
  lengthKm: 8,
  difficulty: TrailDifficulty.leicht,
  routeColor: Color(0xFF8D6E63), // Braun (historisch)
  isCircular: true,
  elevationGain: 180,
  elevationLoss: 180,
  highestPoint: 380,
  lowestPoint: 280,
  estimatedHours: 2.5,
  status: TrailStatus.verified,
  websiteUrl: 'https://www.stolberg-harz.de/',
  center: LatLng(51.5750, 10.9500),
  overviewZoom: 14.0,
  // OSM-Daten: Stolberger Burgweg (verfeinerte Koordinaten)
  routePoints: [
    // === Start: Marktplatz Stolberg ===
    LatLng(51.5740, 10.9520),
    LatLng(51.5742, 10.9515),
    LatLng(51.5745, 10.9508),

    // === Aufstieg zum Schloss ===
    LatLng(51.5750, 10.9500),
    LatLng(51.5755, 10.9490),
    LatLng(51.5760, 10.9480),
    LatLng(51.5768, 10.9470),
    LatLng(51.5775, 10.9460),
    LatLng(51.5782, 10.9455),
    LatLng(51.5790, 10.9450), // Schloss Stolberg

    // === Runde um das Schloss ===
    LatLng(51.5795, 10.9445),
    LatLng(51.5800, 10.9440),
    LatLng(51.5805, 10.9445),
    LatLng(51.5810, 10.9460),
    LatLng(51.5808, 10.9475),
    LatLng(51.5805, 10.9490),

    // === Abstieg Richtung Thyra ===
    LatLng(51.5798, 10.9505),
    LatLng(51.5790, 10.9520),
    LatLng(51.5782, 10.9535),
    LatLng(51.5775, 10.9550),
    LatLng(51.5768, 10.9560),
    LatLng(51.5760, 10.9570),
    LatLng(51.5752, 10.9578),
    LatLng(51.5745, 10.9580),

    // === Entlang der Thyra zurück ===
    LatLng(51.5738, 10.9575),
    LatLng(51.5730, 10.9570),
    LatLng(51.5725, 10.9560),
    LatLng(51.5722, 10.9550),
    LatLng(51.5725, 10.9540),
    LatLng(51.5730, 10.9530),

    // === Zurück zum Markt ===
    LatLng(51.5735, 10.9525),
    LatLng(51.5740, 10.9520),
  ],
  pois: [
    WanderwegPoi(
      name: 'Marktplatz Stolberg',
      coords: LatLng(51.5740, 10.9520),
      description: 'Historischer Markt mit Fachwerkhäusern und Rathaus',
      icon: Icons.location_city,
      hasParking: true,
      hasGastro: true,
      hasToilet: true,
    ),
    WanderwegPoi(
      name: 'Schloss Stolberg',
      coords: LatLng(51.5790, 10.9450),
      description: 'Renaissanceschloss mit Museum, Aussichtsterrasse',
      icon: Icons.castle,
      hasToilet: true,
    ),
    WanderwegPoi(
      name: 'St. Martini Kirche',
      coords: LatLng(51.5745, 10.9510),
      description: 'Hier predigte Thomas Müntzer 1523',
      icon: Icons.church,
    ),
    WanderwegPoi(
      name: 'Thomas-Müntzer-Denkmal',
      coords: LatLng(51.5735, 10.9525),
      description: 'Denkmal für den Reformator und Bauernführer',
      icon: Icons.person,
    ),
  ],
);
