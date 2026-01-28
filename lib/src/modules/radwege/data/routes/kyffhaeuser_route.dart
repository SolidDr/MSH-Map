import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/radweg_category.dart';
import '../../domain/radweg_route.dart';

/// Kyffhäuser-Radweg - ~36km Rundweg
/// Umrundet das Kyffhäusergebirge
/// Grenzgebiet MSH/Thüringen
const kyffhaeuserRoute = RadwegRoute(
  id: 'kyffhaeuser',
  name: 'Kyffhäuser-Radweg',
  shortName: 'Kyffhäuser',
  description: 'Rund um das Kyffhäusergebirge: '
      'Von Bad Frankenhausen über die Barbarossahöhle, '
      'den Stausee Kelbra und die Königspfalz Tilleda.',
  category: RadwegCategory.rundweg,
  lengthKm: 36,
  difficulty: 'Mittel',
  routeColor: const Color(0xFF795548), // Braun
  isLoop: true,
  elevationGain: 380,
  websiteUrl: 'https://bad-frankenhausen.de/kur-tourismus/freizeit-kultur/freizeitangebote/wandern-radfahren/kyffhaeuser-radweg/',
  center: const LatLng(51.40, 11.10),
  overviewZoom: 11.5,
  routePoints: const [
    // Start: Kelbra
    LatLng(51.4362, 11.0401),

    // Richtung Süden nach Steinthaleben
    LatLng(51.4250, 11.0500),
    LatLng(51.4150, 11.0600),

    // Barbarossahöhle bei Rottleben
    LatLng(51.3950, 11.0700),
    LatLng(51.3850, 11.0800),

    // Rottleben
    LatLng(51.3800, 11.0900),

    // Bad Frankenhausen
    LatLng(51.3550, 11.1000),

    // Udersleben
    LatLng(51.3650, 11.1200),
    LatLng(51.3750, 11.1300),

    // Ichstedt
    LatLng(51.3900, 11.1400),
    LatLng(51.4000, 11.1350),

    // Tilleda mit Königspfalz
    LatLng(51.4150, 11.1200),

    // Sittendorf
    LatLng(51.4250, 11.1000),
    LatLng(51.4300, 11.0800),

    // Zurück nach Kelbra
    LatLng(51.4350, 11.0600),
    LatLng(51.4362, 11.0401),
  ],
  pois: const [
    RadwegPoi(
      name: 'Stausee Kelbra',
      coords: LatLng(51.4400, 11.0300),
      description: 'Vogelschutzgebiet und Naherholungsgebiet',
      icon: Icons.water,
    ),
    RadwegPoi(
      name: 'Barbarossahöhle',
      coords: LatLng(51.3850, 11.0800),
      description: 'Einzigartige Anhydrit-Schauhöhle',
      icon: Icons.terrain,
    ),
    RadwegPoi(
      name: 'Panorama Museum',
      coords: LatLng(51.3600, 11.1050),
      description: 'Bad Frankenhausen - Monumentalgemälde',
      icon: Icons.museum,
    ),
    RadwegPoi(
      name: 'Königspfalz Tilleda',
      coords: LatLng(51.4150, 11.1200),
      description: 'Einzige vollständig ausgegrabene Pfalz Deutschlands',
      icon: Icons.account_balance,
    ),
    RadwegPoi(
      name: 'Kyffhäuserdenkmal',
      coords: LatLng(51.4100, 11.0950),
      description: 'Monumentales Denkmal für Kaiser Wilhelm I.',
      icon: Icons.location_city,
    ),
  ],
);
