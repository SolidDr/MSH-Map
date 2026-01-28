import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Süßer See Rundweg - ~15km Rundweg um den Süßen See
/// Beliebte familienfreundliche Tour durchs Mansfelder Seegebiet
final suesserSeeRoute = RadwegRoute(
  id: 'suesser-see',
  name: 'Süßer See Rundweg',
  shortName: 'Süßer See',
  description: 'Malerischer Rundweg um den Süßen See im '
      'Mansfelder Seegebiet. Durchgängig asphaltiert, '
      'ideal für Familien mit Kindern.',
  category: RadwegCategory.rundweg,
  lengthKm: 15,
  difficulty: 'Leicht',
  routeColor: const Color(0xFF4FC3F7), // Seewasser-Blau
  isLoop: true,
  elevationGain: 80,
  websiteUrl: 'https://www.seegebiet-mansfelder-land.de/de/radrundweg.html',
  center: const LatLng(51.4800, 11.6850),
  overviewZoom: 13.0,
  routePoints: const [
    // === Start: Seeburg (Schloss) ===
    LatLng(51.4909, 11.7001),

    // === Abschnitt 1: Seeburg Richtung Süden am Ostufer ===
    LatLng(51.4880, 11.6980),
    LatLng(51.4850, 11.6960),
    LatLng(51.4820, 11.6940),
    LatLng(51.4790, 11.6920),

    // === Abschnitt 2: Südostufer ===
    LatLng(51.4760, 11.6890),
    LatLng(51.4730, 11.6870),
    LatLng(51.4700, 11.6860),

    // === Abschnitt 3: Aseleben (Südufer) ===
    LatLng(51.4750, 11.6800),
    // Aseleben
    LatLng(51.4780, 11.6750),
    LatLng(51.4790, 11.6700),

    // === Abschnitt 4: Westufer Richtung Lüttchendorf ===
    LatLng(51.4810, 11.6650),
    LatLng(51.4830, 11.6600),
    // Lüttchendorf
    LatLng(51.4850, 11.6580),

    // === Abschnitt 5: Wormsleben ===
    LatLng(51.4870, 11.6620),
    LatLng(51.4890, 11.6660),
    // Wormsleben
    LatLng(51.4910, 11.6700),

    // === Abschnitt 6: Nordwest am See ===
    LatLng(51.4930, 11.6750),
    LatLng(51.4940, 11.6800),
    LatLng(51.4950, 11.6850),

    // === Abschnitt 7: Zurück nach Seeburg ===
    LatLng(51.4940, 11.6900),
    LatLng(51.4930, 11.6950),
    LatLng(51.4920, 11.6980),

    // === Zurück zum Start ===
    LatLng(51.4909, 11.7001),
  ],
  pois: const [
    RadwegPoi(
      name: 'Schloss Seeburg',
      coords: LatLng(51.4909, 11.7001),
      description: 'Start/Ziel: Romantisches Schloss mit Cafe',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Hafen Seeburg',
      coords: LatLng(51.4880, 11.6980),
      description: 'Yachthafen mit Bootsverleih',
      icon: Icons.sailing,
    ),
    RadwegPoi(
      name: 'Aseleben',
      coords: LatLng(51.4780, 11.6750),
      description: 'Gasthof Zahn mit Bowlingbahn',
      icon: Icons.restaurant,
    ),
    RadwegPoi(
      name: 'Wormsleben',
      coords: LatLng(51.4910, 11.6700),
      description: 'Weinanbau und Obstplantagen',
      icon: Icons.wine_bar,
    ),
    RadwegPoi(
      name: 'Badestrand',
      coords: LatLng(51.4850, 11.6960),
      description: 'Öffentlicher Badestrand am Ostufer',
      icon: Icons.beach_access,
    ),
  ],
);
