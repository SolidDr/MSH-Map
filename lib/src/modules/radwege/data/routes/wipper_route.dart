import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Wipper-Radweg - ~35km Flussradweg
/// Begleitet die Wipper durch den Salzlandkreis
final wipperRoute = RadwegRoute(
  id: 'wipper',
  name: 'Wipper-Radweg',
  shortName: 'Wipper',
  description: 'Entlang der Wipper von Sandersleben nach Bernburg. '
      'Idyllische Flusslandschaft mit historischen Ortskernen.',
  category: RadwegCategory.flussradweg,
  lengthKm: 35.8,
  difficulty: 'Leicht',
  routeColor: const Color(0xFF00BCD4), // Cyan
  websiteUrl: 'https://www.komoot.com/de-de/smarttour/e1603960896/wipper-radweg-von-sandersleben-nach-bernburg',
  center: const LatLng(51.72, 11.58),
  overviewZoom: 10.5,
  routePoints: const [
    // Start: Sandersleben
    LatLng(51.6800, 11.4000),

    // Freckleben
    LatLng(51.6900, 11.4200),
    LatLng(51.7000, 11.4400),

    // Drohndorf
    LatLng(51.7100, 11.4600),
    LatLng(51.7150, 11.4800),

    // Mehringen
    LatLng(51.7200, 11.5000),
    LatLng(51.7250, 11.5200),

    // Groß Schierstedt
    LatLng(51.7300, 11.5400),
    LatLng(51.7350, 11.5600),

    // Klein Schierstedt
    LatLng(51.7400, 11.5800),

    // Giersleben
    LatLng(51.7450, 11.6000),
    LatLng(51.7500, 11.6200),

    // Warmsdorf
    LatLng(51.7550, 11.6400),
    LatLng(51.7600, 11.6600),

    // Osmarsleben
    LatLng(51.7650, 11.6800),
    LatLng(51.7700, 11.7000),

    // Bernburg (Ende, Anschluss Saale-Radweg)
    LatLng(51.7950, 11.7400),
  ],
  pois: const [
    RadwegPoi(
      name: 'Sandersleben',
      coords: LatLng(51.6800, 11.4000),
      description: 'Startpunkt mit historischem Ortskern',
      icon: Icons.flag,
    ),
    RadwegPoi(
      name: 'Wipperbrücke Mehringen',
      coords: LatLng(51.7200, 11.5000),
      description: 'Historische Flussüberquerung',
      icon: Icons.architecture,
    ),
    RadwegPoi(
      name: 'Warmsdorf',
      coords: LatLng(51.7550, 11.6400),
      description: 'Idyllisches Dorf an der Wipper',
      icon: Icons.home,
    ),
    RadwegPoi(
      name: 'Bernburg',
      coords: LatLng(51.7950, 11.7400),
      description: 'Ziel mit Schloss und Saale-Anschluss',
      icon: Icons.castle,
    ),
  ],
);
