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
  center: const LatLng(51.38, 11.72),
  overviewZoom: 10.0,
  routePoints: const [
    // === Start: Nebra (Unstrut) ===
    LatLng(51.2713, 11.5448),

    // === Abschnitt 1: Nebra → Wangen → Arche Nebra ===
    LatLng(51.2720, 11.5420),
    LatLng(51.2725, 11.5380),
    LatLng(51.2722, 11.5340),
    // Arche Nebra (Besucherzentrum)
    LatLng(51.2714, 11.5320),

    // === Abschnitt 2: Arche Nebra → Mittelberg (Fundstätte) ===
    LatLng(51.2740, 11.5300),
    LatLng(51.2770, 11.5260),
    LatLng(51.2800, 11.5220),
    // Mittelberg - Fundstätte der Himmelsscheibe (252m)
    LatLng(51.2839, 11.5200),

    // === Abschnitt 3: Mittelberg → durch Ziegelrodaer Forst ===
    LatLng(51.2880, 11.5240),
    LatLng(51.2920, 11.5300),
    LatLng(51.2960, 11.5380),
    LatLng(51.3000, 11.5470),
    LatLng(51.3040, 11.5560),
    LatLng(51.3080, 11.5640),

    // === Abschnitt 4: Hermannseck → Leimbach ===
    LatLng(51.3130, 11.5720),
    LatLng(51.3180, 11.5800),
    LatLng(51.3240, 11.5870),
    LatLng(51.3300, 11.5920),

    // === Abschnitt 5: → Querfurt (Burg) ===
    LatLng(51.3400, 11.5960),
    LatLng(51.3500, 11.5980),
    LatLng(51.3600, 11.5985),
    LatLng(51.3700, 11.5988),
    // Querfurt (Burg) - eine der größten Burgen Deutschlands
    LatLng(51.3812, 11.6005),

    // === Abschnitt 6: Querfurt → Obhausen → Kuckenburg ===
    LatLng(51.3880, 11.6100),
    LatLng(51.3950, 11.6200),
    LatLng(51.4020, 11.6320),
    LatLng(51.4080, 11.6440),

    // === Abschnitt 7: Esperstedt → Schraplau ===
    LatLng(51.4150, 11.6550),
    LatLng(51.4220, 11.6640),
    LatLng(51.4290, 11.6700),
    LatLng(51.4360, 11.6740),

    // === Abschnitt 8: → Röblingen am See ===
    LatLng(51.4430, 11.6720),
    LatLng(51.4500, 11.6680),
    LatLng(51.4570, 11.6640),
    // Röblingen am See
    LatLng(51.4630, 11.6580),

    // === Abschnitt 9: Röblingen → Aseleben → Seeburg (Süßer See) ===
    LatLng(51.4700, 11.6620),
    LatLng(51.4760, 11.6700),
    // Aseleben (am Süßen See)
    LatLng(51.4858, 11.6710),
    LatLng(51.4880, 11.6850),
    // Seeburg (Schloss am Süßen See)
    LatLng(51.4912, 11.7005),

    // === Abschnitt 10: Seeburg → Rollsdorf → Richtung Halle ===
    LatLng(51.4930, 11.7120),
    LatLng(51.4945, 11.7280),
    LatLng(51.4955, 11.7450),
    LatLng(51.4960, 11.7620),
    // Langenbogen
    LatLng(51.4965, 11.7800),
    LatLng(51.4970, 11.7980),
    // Höhnstedt
    LatLng(51.4975, 11.8160),
    LatLng(51.4980, 11.8350),
    LatLng(51.4982, 11.8540),
    // Bennstedt
    LatLng(51.4985, 11.8730),
    LatLng(51.4987, 11.8920),
    LatLng(51.4990, 11.9110),
    // Halle Neustadt
    LatLng(51.4992, 11.9300),
    LatLng(51.4995, 11.9450),

    // === Ziel: Landesmuseum für Vorgeschichte Halle ===
    LatLng(51.4981, 11.9625),
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
      coords: LatLng(51.2714, 11.5320),
      description: 'Besucherzentrum zur Himmelsscheibe mit Planetarium',
      icon: Icons.museum,
    ),
    RadwegPoi(
      name: 'Mittelberg (Fundstätte)',
      coords: LatLng(51.2839, 11.5200),
      description: 'Hier wurde 1999 die Himmelsscheibe gefunden',
      icon: Icons.stars,
    ),
    RadwegPoi(
      name: 'Burg Querfurt',
      coords: LatLng(51.3812, 11.6005),
      description: 'Eine der größten mittelalterlichen Burgen Deutschlands',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Schloss Seeburg',
      coords: LatLng(51.4912, 11.7005),
      description: 'Romantisches Schloss am Süßen See',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Landesmuseum Halle',
      coords: LatLng(51.4981, 11.9625),
      description: 'Ziel: Hier wird die Himmelsscheibe aufbewahrt',
      icon: Icons.museum,
    ),
  ],
);
