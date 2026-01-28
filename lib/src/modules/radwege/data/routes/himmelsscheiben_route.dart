import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Himmelsscheibenradweg - ~71km von Nebra nach Halle
/// Verbindet Fundort und Aufbewahrungsort der Himmelsscheibe von Nebra
final himmelsscheibenRoute = RadwegRoute(
  id: 'himmelsscheibe',
  name: 'Himmelsscheibenradweg',
  shortName: 'Himmelsscheibe',
  description: 'Vom Fundort der 3.600 Jahre alten Himmelsscheibe '
      'von Nebra bis zum Landesmuseum in Halle. '
      'Teil der touristischen Route "Himmelswege".',
  category: RadwegCategory.themenweg,
  lengthKm: 71,
  difficulty: 'Mittel',
  routeColor: const Color(0xFF1E3A5F), // Nachthimmelblau
  isLoop: false,
  elevationGain: 420,
  websiteUrl: 'https://www.himmelswege.de/',
  center: const LatLng(51.38, 11.75),
  overviewZoom: 10.5,
  routePoints: const [
    // === Start: Nebra (Unstrut) ===
    LatLng(51.2713, 11.5448),

    // === Abschnitt 1: Nebra zur Arche Nebra ===
    LatLng(51.2715, 11.5400),
    LatLng(51.2714, 11.5350),
    // Arche Nebra (Besucherzentrum)
    LatLng(51.2714, 11.5323),

    // === Abschnitt 2: Zum Mittelberg (Fundstätte) ===
    LatLng(51.2750, 11.5280),
    LatLng(51.2790, 11.5230),
    // Mittelberg - Fundstätte der Himmelsscheibe
    LatLng(51.2834, 11.5193),

    // === Abschnitt 3: Durch Ziegelrodaer Forst ===
    LatLng(51.2900, 11.5250),
    LatLng(51.2980, 11.5350),
    LatLng(51.3060, 11.5480),
    LatLng(51.3140, 11.5620),

    // === Abschnitt 4: Hermannseck - Leimbach ===
    LatLng(51.3220, 11.5750),
    LatLng(51.3300, 11.5880),
    LatLng(51.3380, 11.6010),

    // === Abschnitt 5: Querfurt ===
    LatLng(51.3450, 11.6150),
    LatLng(51.3520, 11.6280),
    // Querfurt (Burg)
    LatLng(51.3800, 11.5986),

    // === Abschnitt 6: Obhausen - Esperstedt ===
    LatLng(51.3900, 11.6100),
    LatLng(51.4000, 11.6250),
    LatLng(51.4100, 11.6400),
    LatLng(51.4200, 11.6550),

    // === Abschnitt 7: Schraplau - Röblingen ===
    LatLng(51.4300, 11.6650),
    LatLng(51.4400, 11.6700),
    // Röblingen am See
    LatLng(51.4630, 11.6600),

    // === Abschnitt 8: Aseleben - Seeburg (Süßer See) ===
    LatLng(51.4720, 11.6700),
    // Aseleben
    LatLng(51.4800, 11.6850),
    LatLng(51.4860, 11.6950),
    // Seeburg (Schloss)
    LatLng(51.4913, 11.6988),

    // === Abschnitt 9: Saale-Harz-Radweg nach Halle ===
    LatLng(51.4920, 11.7200),
    LatLng(51.4930, 11.7500),
    LatLng(51.4940, 11.7800),
    LatLng(51.4950, 11.8100),
    LatLng(51.4960, 11.8400),
    LatLng(51.4970, 11.8700),
    LatLng(51.4975, 11.9000),
    LatLng(51.4978, 11.9300),

    // === Ziel: Landesmuseum Halle ===
    LatLng(51.4979, 11.9622),
  ],
  pois: const [
    RadwegPoi(
      name: 'Nebra (Unstrut)',
      coords: LatLng(51.2713, 11.5448),
      description: 'Startpunkt, malerischer Ort an der Unstrut',
      icon: Icons.flag,
    ),
    RadwegPoi(
      name: 'Arche Nebra',
      coords: LatLng(51.2714, 11.5323),
      description: 'Besucherzentrum zur Himmelsscheibe mit Planetarium',
      icon: Icons.museum,
    ),
    RadwegPoi(
      name: 'Mittelberg (Fundstätte)',
      coords: LatLng(51.2834, 11.5193),
      description: 'Hier wurde 1999 die Himmelsscheibe gefunden',
      icon: Icons.stars,
    ),
    RadwegPoi(
      name: 'Burg Querfurt',
      coords: LatLng(51.3800, 11.5986),
      description: 'Eine der größten mittelalterlichen Burgen Deutschlands',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Schloss Seeburg',
      coords: LatLng(51.4913, 11.6988),
      description: 'Romantisches Schloss am Süßen See',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Landesmuseum Halle',
      coords: LatLng(51.4979, 11.9622),
      description: 'Ziel: Hier wird die Himmelsscheibe aufbewahrt',
      icon: Icons.museum,
    ),
  ],
);
