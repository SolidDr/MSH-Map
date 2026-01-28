import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Erlebnistour Straße der Romanik - ~32km Rundweg
/// Führt durch die südwestliche Region Sangerhausens
const romanikRoute = RadwegRoute(
  id: 'romanik',
  name: 'Erlebnistour Straße der Romanik',
  shortName: 'Romanik',
  description: 'Romanik und Romantik erleben: '
      'Von Sangerhausen durch die Goldene Aue '
      'zu romanischen Kirchen und historischen Burgen.',
  category: RadwegCategory.themenweg,
  lengthKm: 32.6,
  difficulty: 'Leicht',
  routeColor: const Color(0xFF8D6E63), // Braun/Sandstein
  isLoop: true,
  elevationGain: 291,
  websiteUrl: 'https://www.outdooractive.com/de/route/radtour/harz/erlebnistour-strasse-der-romanik/9660811/',
  center: const LatLng(51.44, 11.36),
  overviewZoom: 11.5,
  routePoints: const [
    // Start: Europa-Rosarium Sangerhausen
    LatLng(51.4737, 11.3096),

    // Richtung Westen nach Othal
    LatLng(51.4720, 11.3000),
    LatLng(51.4700, 11.2900),

    // Südwest Richtung Beyernaumburg
    LatLng(51.4760, 11.3953),

    // Burg Beyernaumburg
    LatLng(51.4760, 11.3956),

    // Weiter nach Süden
    LatLng(51.4680, 11.4000),
    LatLng(51.4600, 11.4100),
    LatLng(51.4500, 11.4150),

    // St. Cyriakus
    LatLng(51.4682, 11.4264),

    // Richtung Allstedt
    LatLng(51.4400, 11.4200),
    LatLng(51.4300, 11.4100),
    LatLng(51.4200, 11.4000),

    // Schloss Allstedt
    LatLng(51.4078, 11.4012),

    // St. Johannes Baptist
    LatLng(51.4045, 11.3836),

    // Zurück nach Norden
    LatLng(51.4100, 11.3700),
    LatLng(51.4200, 11.3600),
    LatLng(51.4300, 11.3500),
    LatLng(51.4400, 11.3400),
    LatLng(51.4500, 11.3300),
    LatLng(51.4600, 11.3200),

    // Zurück zum Start
    LatLng(51.4737, 11.3096),
  ],
  pois: const [
    RadwegPoi(
      name: 'Europa-Rosarium Sangerhausen',
      coords: LatLng(51.4737, 11.3096),
      description: 'Start und Ziel der Tour',
      icon: Icons.local_florist,
    ),
    RadwegPoi(
      name: 'Burg Beyernaumburg',
      coords: LatLng(51.4760, 11.3956),
      description: 'Historische Burganlage aus dem 12. Jahrhundert',
      icon: Icons.castle,
    ),
    RadwegPoi(
      name: 'St. Cyriakus',
      coords: LatLng(51.4682, 11.4264),
      description: 'Romanische Kirche an der Straße der Romanik',
      icon: Icons.church,
    ),
    RadwegPoi(
      name: 'Schloss Allstedt',
      coords: LatLng(51.4078, 11.4012),
      description: 'Königspfalz und Kaiserpfalz der Ottonen',
      icon: Icons.museum,
    ),
    RadwegPoi(
      name: 'St. Johannes Baptist',
      coords: LatLng(51.4045, 11.3836),
      description: 'Romanische Kirche in Allstedt',
      icon: Icons.church,
    ),
  ],
);
