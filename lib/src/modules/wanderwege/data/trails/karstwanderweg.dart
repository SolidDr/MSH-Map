import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/wanderweg_category.dart';
import '../../domain/wanderweg_route.dart';

/// Karstwanderweg - MSH-Abschnitt (~60km)
/// Verbindet Karstlandschaften am Südharz
const karstwanderwegRoute = WanderwegRoute(
  id: 'karstwanderweg',
  name: 'Karstwanderweg (MSH-Abschnitt)',
  shortName: 'Karst',
  description: 'Der Karstwanderweg führt durch die einzigartige Gipskarstlandschaft '
      'am Südharzrand. Im Landkreis MSH erleben Sie Dolinen, Erdfälle und '
      'naturbelassene Buchenwälder. Der Weg ist Teil des Qualitätswanderwegs '
      '"Wanderbares Deutschland".',
  category: WanderwegCategory.fernwanderweg,
  lengthKm: 60,
  difficulty: TrailDifficulty.mittel,
  routeColor: Color(0xFF2E7D32), // Waldgrün
  isCircular: false,
  elevationGain: 850,
  elevationLoss: 780,
  highestPoint: 420,
  lowestPoint: 180,
  estimatedHours: 16,
  status: TrailStatus.verified,
  websiteUrl: 'https://www.karstwanderweg.de/',
  center: LatLng(51.52, 10.95),
  overviewZoom: 10.5,
  // OSM-Daten: Karstwanderweg MSH-Abschnitt (vereinfacht)
  routePoints: [
    // === Start: Questenberg/Bad Sachsa Richtung ===
    LatLng(51.6678, 10.2897),
    LatLng(51.6695, 10.2989),
    LatLng(51.6693, 10.3117),
    LatLng(51.6641, 10.3098),
    LatLng(51.6578, 10.3139),
    LatLng(51.6550, 10.3179),
    LatLng(51.6529, 10.3307),

    // === Durch den Südharz ===
    LatLng(51.6475, 10.3154),
    LatLng(51.6335, 10.3246),
    LatLng(51.6188, 10.3089),
    LatLng(51.6101, 10.3131),
    LatLng(51.6077, 10.3251),
    LatLng(51.6013, 10.3196),
    LatLng(51.5900, 10.3106),

    // === Richtung Stolberg ===
    LatLng(51.5864, 10.3228),
    LatLng(51.5946, 10.3269),
    LatLng(51.6056, 10.3282),
    LatLng(51.6165, 10.3391),
    LatLng(51.6100, 10.3486),
    LatLng(51.6041, 10.3749),
    LatLng(51.5976, 10.3831),

    // === Durch Karstlandschaft ===
    LatLng(51.6018, 10.3900),
    LatLng(51.6051, 10.4071),
    LatLng(51.5968, 10.4329),
    LatLng(51.5995, 10.4460),
    LatLng(51.5969, 10.4575),
    LatLng(51.5874, 10.4678),

    // === Richtung Uftrungen ===
    LatLng(51.5812, 10.4811),
    LatLng(51.5779, 10.5036),
    LatLng(51.5672, 10.5179),
    LatLng(51.5556, 10.5296),
    LatLng(51.5526, 10.5487),
    LatLng(51.5562, 10.5589),
    LatLng(51.5544, 10.5908),

    // === Bauerngraben Bereich ===
    LatLng(51.5577, 10.6016),
    LatLng(51.5569, 10.6225),
    LatLng(51.5575, 10.6308),
    LatLng(51.5515, 10.6363),
    LatLng(51.5447, 10.6324),
    LatLng(51.5368, 10.6427),
    LatLng(51.5386, 10.6577),

    // === Richtung Stolberg/Hohnstein ===
    LatLng(51.5486, 10.6774),
    LatLng(51.5542, 10.6803),
    LatLng(51.5688, 10.6975),
    LatLng(51.5725, 10.6837),
    LatLng(51.5743, 10.6714),
    LatLng(51.5792, 10.6659),
    LatLng(51.5794, 10.6513),

    // === Ende bei Stolberg ===
    LatLng(51.5829, 10.6445),
    LatLng(51.5775, 10.6320),
    LatLng(51.5758, 10.6251),
    LatLng(51.5825, 10.6120),
    LatLng(51.5857, 10.5984),
    LatLng(51.5812, 10.5846),
    LatLng(51.5759, 10.5765),
  ],
  pois: [
    WanderwegPoi(
      name: 'Questenberg',
      coords: LatLng(51.4650, 11.0400),
      description: 'Historisches Dorf mit Burgruine und Queste-Fest',
      icon: Icons.castle,
      hasParking: true,
    ),
    WanderwegPoi(
      name: 'Bauerngraben',
      coords: LatLng(51.5780, 10.8200),
      description: 'Eindrucksvolle Karstschlucht, Naturdenkmal',
      icon: Icons.landscape,
    ),
    WanderwegPoi(
      name: 'Heimkehle',
      coords: LatLng(51.5280, 10.9100),
      description: 'Große Karsthöhle, Führungen möglich',
      icon: Icons.dark_mode,
      hasParking: true,
      hasToilet: true,
    ),
    WanderwegPoi(
      name: 'Stolberg (Harz)',
      coords: LatLng(51.5780, 10.7500),
      description: 'Historische Fachwerkstadt mit Schloss',
      icon: Icons.location_city,
      hasParking: true,
      hasGastro: true,
      hasToilet: true,
    ),
  ],
);
