import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Salzstraßen-Radweg - ~90km historische Salzhandelsroute
/// Von Merseburg über den Geiseltalsee nach Allstedt
final salzstrasseRoute = RadwegRoute(
  id: 'salzstrasse',
  name: 'Salzstraßen-Radweg',
  shortName: 'Salzstraße',
  description: 'Auf den Spuren des historischen Salzhandels '
      'von Merseburg über den Geiseltalsee und den '
      'Fundort der Himmelsscheibe bis nach Allstedt.',
  category: RadwegCategory.themenweg,
  lengthKm: 90,
  difficulty: 'Mittel',
  routeColor: const Color(0xFF78909C), // Salzgrau (besser sichtbar)
  isLoop: false,
  elevationGain: 480,
  websiteUrl: 'https://www.fluss-radwege.de/salzstrassen-radweg/',
  center: const LatLng(51.35, 11.65),
  overviewZoom: 9.5,
  routePoints: const [
    // === Start: Merseburg (Dom) ===
    LatLng(51.4605, 11.9990),

    // === Abschnitt 1: Merseburg → Richtung Südwesten ===
    LatLng(51.4550, 11.9900),
    LatLng(51.4480, 11.9780),
    LatLng(51.4400, 11.9640),
    LatLng(51.4320, 11.9480),
    LatLng(51.4240, 11.9300),

    // === Abschnitt 2: → Bad Lauchstädt Gebiet ===
    LatLng(51.4160, 11.9100),
    LatLng(51.4080, 11.8880),
    LatLng(51.4000, 11.8660),
    LatLng(51.3920, 11.8450),

    // === Abschnitt 3: → Geiseltalsee (Nordufer) ===
    LatLng(51.3850, 11.8300),
    LatLng(51.3780, 11.8180),
    // Geiseltalsee Nordufer
    LatLng(51.3700, 11.8100),
    LatLng(51.3620, 11.8050),

    // === Abschnitt 4: Geiseltalsee → Mücheln ===
    LatLng(51.3540, 11.8020),
    LatLng(51.3450, 11.8000),
    LatLng(51.3350, 11.8020),
    LatLng(51.3250, 11.8050),
    LatLng(51.3150, 11.8070),
    // Mücheln (am See)
    LatLng(51.2944, 11.8087),

    // === Abschnitt 5: Mücheln → Steigra ===
    LatLng(51.2880, 11.7950),
    LatLng(51.2820, 11.7780),
    LatLng(51.2760, 11.7600),
    LatLng(51.2700, 11.7400),
    LatLng(51.2650, 11.7180),
    // Steigra
    LatLng(51.2600, 11.6950),

    // === Abschnitt 6: Steigra → Karsdorf ===
    LatLng(51.2580, 11.6700),
    LatLng(51.2600, 11.6450),
    // Karsdorf (am Unstrutradweg)
    LatLng(51.2650, 11.6200),

    // === Abschnitt 7: Karsdorf → Wangen/Nebra ===
    LatLng(51.2680, 11.5950),
    LatLng(51.2700, 11.5700),
    // Wangen (nahe Arche Nebra)
    LatLng(51.2714, 11.5450),

    // === Abschnitt 8: Nebra → durch Ziegelrodaer Forst ===
    LatLng(51.2800, 11.5300),
    LatLng(51.2900, 11.5100),
    LatLng(51.3000, 11.4900),
    LatLng(51.3100, 11.4700),
    LatLng(51.3200, 11.4520),

    // === Abschnitt 9: → Allstedt ===
    LatLng(51.3300, 11.4380),
    LatLng(51.3420, 11.4260),
    LatLng(51.3550, 11.4150),
    LatLng(51.3680, 11.4050),
    // Schloss Allstedt
    LatLng(51.3833, 11.3833),
  ],
  pois: const [
    RadwegPoi(
      name: 'Merseburg',
      coords: LatLng(51.4605, 11.9990),
      description: 'Startpunkt mit Dom und historischer Altstadt',
      icon: Icons.church,
    ),
    RadwegPoi(
      name: 'Geiseltalsee',
      coords: LatLng(51.3700, 11.8100),
      description: 'Größter künstlicher See Deutschlands (1.840 ha)',
      icon: Icons.water,
    ),
    RadwegPoi(
      name: 'Mücheln',
      coords: LatLng(51.2944, 11.8087),
      description: 'Stadt am Geiseltalsee mit Marina',
      icon: Icons.location_city,
    ),
    RadwegPoi(
      name: 'Wangen/Nebra',
      coords: LatLng(51.2714, 11.5450),
      description: 'Nahe dem Fundort der Himmelsscheibe',
      icon: Icons.stars,
    ),
    RadwegPoi(
      name: 'Schloss Allstedt',
      coords: LatLng(51.3833, 11.3833),
      description: 'Ziel: Historisches Schloss, Thomas-Müntzer-Stätte',
      icon: Icons.castle,
    ),
  ],
);
