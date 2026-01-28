import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Saale-Harz-Radweg - ~70km Fernradweg
/// Verbindet den Saale-Radwanderweg mit dem Harzrundweg
/// Nur der MSH-Abschnitt (Süßer See bis Wippra)
final saaleHarzRoute = RadwegRoute(
  id: 'saale_harz',
  name: 'Saale-Harz-Radweg',
  shortName: 'Saale-Harz',
  description: 'Vom Süßen See durch die Lutherstadt Eisleben '
      'und Mansfeld-Lutherstadt bis nach Wippra im Harz. '
      'Verbindet UNESCO-Welterbe mit Bergbaugeschichte.',
  category: RadwegCategory.fernradweg,
  lengthKm: 70,
  difficulty: 'Mittel',
  routeColor: const Color(0xFF2196F3), // Blau
  isLoop: false,
  elevationGain: 520,
  websiteUrl: 'https://www.outdooractive.com/de/route/fernradweg/saale-unstrut/radweg-saale-harz/1533378/',
  contactName: 'Fremdenverkehrsverein Lutherstadt Eisleben',
  contactPhone: '03475/602124',
  center: const LatLng(51.54, 11.50),
  overviewZoom: 10.5,
  routePoints: const [
    // Start: Süßer See (Seeburg)
    LatLng(51.4913, 11.6988),

    // Nordufer Süßer See
    LatLng(51.4950, 11.6800),
    LatLng(51.5000, 11.6600),
    LatLng(51.5050, 11.6400),

    // Unterrißdorf
    LatLng(51.5100, 11.6200),
    LatLng(51.5150, 11.6000),

    // Lutherstadt Eisleben
    LatLng(51.5271, 11.5499),

    // Helbra
    LatLng(51.5400, 11.5200),
    LatLng(51.5500, 11.5000),

    // Klostermansfeld
    LatLng(51.5600, 11.4800),
    LatLng(51.5700, 11.4700),

    // Mansfeld-Lutherstadt / Schloss Mansfeld
    LatLng(51.5938, 11.4576),

    // Gorenzen
    LatLng(51.5900, 11.4200),
    LatLng(51.5850, 11.3800),

    // Friesdorf
    LatLng(51.5800, 11.3400),
    LatLng(51.5780, 11.3200),

    // Wippra (Ende)
    LatLng(51.5735, 11.2755),
  ],
  pois: const [
    RadwegPoi(
      name: 'Schloss Seeburg',
      coords: LatLng(51.4913, 11.6988),
      description: 'Historisches Schloss am Süßen See',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Süßer See',
      coords: LatLng(51.4950, 11.6700),
      description: 'Größter natürlicher See Sachsen-Anhalts',
      icon: Icons.water,
    ),
    RadwegPoi(
      name: 'Luthers Geburtshaus',
      coords: LatLng(51.5271, 11.5499),
      description: 'UNESCO-Welterbe - Geburtsort Martin Luthers',
      icon: Icons.museum,
    ),
    RadwegPoi(
      name: 'Schloss Mansfeld',
      coords: LatLng(51.5938, 11.4576),
      description: 'Imposante Schlossanlage mit Blick über das Tal',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Traditionsbrauerei Wippra',
      coords: LatLng(51.5735, 11.2755),
      description: 'Historische Brauerei im Harz',
      icon: Icons.sports_bar,
    ),
  ],
);
