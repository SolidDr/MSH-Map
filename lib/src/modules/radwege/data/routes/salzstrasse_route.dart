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
  routeColor: const Color(0xFFE8E8E8), // Salzweiß/Grau
  isLoop: false,
  elevationGain: 480,
  websiteUrl: 'https://www.fluss-radwege.de/salzstrassen-radweg/',
  center: const LatLng(51.38, 11.68),
  overviewZoom: 10.0,
  routePoints: const [
    // === Start: Merseburg (Dom) ===
    LatLng(51.4600, 11.9985),

    // === Abschnitt 1: Merseburg Richtung Süden ===
    LatLng(51.4500, 11.9800),
    LatLng(51.4400, 11.9600),
    LatLng(51.4300, 11.9400),

    // === Abschnitt 2: Zum Geiseltalsee ===
    LatLng(51.4200, 11.9200),
    LatLng(51.4100, 11.9000),
    LatLng(51.4000, 11.8800),
    LatLng(51.3900, 11.8600),

    // === Abschnitt 3: Geiseltalsee Südufer ===
    LatLng(51.3800, 11.8400),
    LatLng(51.3700, 11.8200),
    // Geiseltalsee (größter künstlicher See Deutschlands)
    LatLng(51.3550, 11.8100),

    // === Abschnitt 4: Mücheln ===
    LatLng(51.3400, 11.8000),
    // Mücheln
    LatLng(51.2944, 11.8087),

    // === Abschnitt 5: Richtung Steigra - Karsdorf ===
    LatLng(51.2800, 11.7800),
    LatLng(51.2700, 11.7500),
    LatLng(51.2600, 11.7200),
    // Steigra
    LatLng(51.2550, 11.6900),

    // === Abschnitt 6: Karsdorf - Wangen ===
    LatLng(51.2600, 11.6600),
    // Karsdorf
    LatLng(51.2680, 11.6300),
    LatLng(51.2720, 11.6000),
    // Wangen (bei Nebra)
    LatLng(51.2760, 11.5700),

    // === Abschnitt 7: Nebra und Mittelberg ===
    LatLng(51.2780, 11.5500),
    // Nebra
    LatLng(51.2713, 11.5448),

    // === Abschnitt 8: Durch Ziegelrodaer Forst ===
    LatLng(51.2900, 11.5200),
    LatLng(51.3100, 11.4900),
    LatLng(51.3300, 11.4600),

    // === Abschnitt 9: Allstedt ===
    LatLng(51.3500, 11.4400),
    LatLng(51.3700, 11.4200),
    // Schloss Allstedt
    LatLng(51.4034, 11.3925),
  ],
  pois: const [
    RadwegPoi(
      name: 'Merseburg',
      coords: LatLng(51.4600, 11.9985),
      description: 'Startpunkt mit Dom und historischer Altstadt',
      icon: Icons.church,
    ),
    RadwegPoi(
      name: 'Geiseltalsee',
      coords: LatLng(51.3550, 11.8100),
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
      name: 'Nebra',
      coords: LatLng(51.2713, 11.5448),
      description: 'Nahe dem Fundort der Himmelsscheibe',
      icon: Icons.stars,
    ),
    RadwegPoi(
      name: 'Schloss Allstedt',
      coords: LatLng(51.4034, 11.3925),
      description: 'Ziel: Historisches Schloss, Thomas-Müntzer-Stätte',
      icon: Icons.castle,
    ),
  ],
);
