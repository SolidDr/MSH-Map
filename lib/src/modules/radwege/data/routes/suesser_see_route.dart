import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Süßer See Rundweg - ~15km Rundweg um den Süßen See
/// Beliebte familienfreundliche Tour durchs Mansfelder Seegebiet
const suesserSeeRoute = RadwegRoute(
  id: 'suesser-see',
  name: 'Süßer See Rundweg',
  shortName: 'Süßer See',
  description: 'Malerischer Rundweg um den Süßen See im '
      'Mansfelder Seegebiet. Durchgängig asphaltiert, '
      'ideal für Familien mit Kindern.',
  category: RadwegCategory.rundweg,
  lengthKm: 15,
  difficulty: 'Leicht',
  routeColor: Color(0xFF4FC3F7), // Seewasser-Blau
  isLoop: true,
  elevationGain: 80,
  websiteUrl: 'https://www.seegebiet-mansfelder-land.de/de/radrundweg.html',
  center: LatLng(51.4920, 11.6750),
  overviewZoom: 13.5,
  routePoints: [
    // === Start: Seeburg (Schloss auf Halbinsel am Ostufer) ===
    LatLng(51.4912, 11.7005),

    // === Südufer: Seeburg → Aseleben (gegen Uhrzeigersinn) ===
    LatLng(51.4900, 11.6990),
    LatLng(51.4885, 11.6970),
    LatLng(51.4870, 11.6945),
    LatLng(51.4860, 11.6920),
    LatLng(51.4855, 11.6890),
    LatLng(51.4852, 11.6860),
    LatLng(51.4850, 11.6830),
    LatLng(51.4848, 11.6800),
    LatLng(51.4850, 11.6770),
    LatLng(51.4855, 11.6740),
    // Aseleben (Südufer Mitte)
    LatLng(51.4858, 11.6710),
    LatLng(51.4862, 11.6680),
    LatLng(51.4868, 11.6650),
    LatLng(51.4875, 11.6620),
    LatLng(51.4882, 11.6590),

    // === Westufer: Aseleben → Lüttchendorf ===
    LatLng(51.4890, 11.6565),
    LatLng(51.4898, 11.6545),
    // Lüttchendorf (Westufer)
    LatLng(51.4910, 11.6530),
    LatLng(51.4925, 11.6525),
    LatLng(51.4940, 11.6530),

    // === Nordwestufer: Lüttchendorf → Wormsleben ===
    LatLng(51.4955, 11.6545),
    LatLng(51.4968, 11.6565),
    // Wormsleben (Nordwestufer, Weinberge)
    LatLng(51.4980, 11.6590),
    LatLng(51.4990, 11.6620),
    LatLng(51.4998, 11.6655),

    // === Nordufer: Wormsleben → Seeburg ===
    LatLng(51.5005, 11.6695),
    LatLng(51.5008, 11.6740),
    LatLng(51.5008, 11.6790),
    LatLng(51.5005, 11.6840),
    LatLng(51.4998, 11.6885),
    LatLng(51.4988, 11.6920),
    LatLng(51.4975, 11.6950),
    LatLng(51.4960, 11.6975),
    LatLng(51.4942, 11.6992),
    LatLng(51.4925, 11.7002),

    // === Zurück zum Schloss Seeburg ===
    LatLng(51.4912, 11.7005),
  ],
  pois: [
    RadwegPoi(
      name: 'Schloss Seeburg',
      coords: LatLng(51.4912, 11.7005),
      description: 'Start/Ziel: Romantisches Schloss mit Cafe',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'Hafen Seeburg',
      coords: LatLng(51.4900, 11.6990),
      description: 'Yachthafen mit Bootsverleih',
      icon: Icons.sailing,
    ),
    RadwegPoi(
      name: 'Aseleben',
      coords: LatLng(51.4858, 11.6710),
      description: 'Gasthof Zahn mit Bowlingbahn',
      icon: Icons.restaurant,
    ),
    RadwegPoi(
      name: 'Lüttchendorf',
      coords: LatLng(51.4910, 11.6530),
      description: 'Kleines Dorf am Westufer',
      icon: Icons.home,
    ),
    RadwegPoi(
      name: 'Wormsleben',
      coords: LatLng(51.4980, 11.6590),
      description: 'Weinanbau und Obstplantagen am Nordufer',
      icon: Icons.wine_bar,
    ),
  ],
);
