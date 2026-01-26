import 'package:latlong2/latlong.dart';

/// Polygon-Daten für die Mansfeld-Südharz Region
class MshBorderData {
  MshBorderData._();

  /// Vereinfachtes Polygon (15 Punkte) - Schnelle Performance
  static const List<LatLng> mshBorderSimplified = [
    // Start Nordwesten, im Uhrzeigersinn
    LatLng(51.68, 11.02), // NW - bei Berga
    LatLng(51.70, 11.18), // N - bei Blankenheim
    LatLng(51.68, 11.35), // N - bei Gonna
    LatLng(51.66, 11.52), // NE - bei Wimmelburg
    LatLng(51.60, 11.68), // E - bei Hettstedt
    LatLng(51.52, 11.75), // E - bei Gerbstedt
    LatLng(51.42, 11.70), // SE - bei Querfurt Rand
    LatLng(51.32, 11.55), // S - bei Roßla
    LatLng(51.30, 11.35), // S - bei Kelbra
    LatLng(51.33, 11.15), // SW - bei Uftrungen
    LatLng(51.40, 11.00), // W - bei Stolberg
    LatLng(51.50, 10.95), // W - bei Rottleberode
    LatLng(51.58, 10.98), // NW - bei Hayn
    LatLng(51.68, 11.02), // Zurück zum Start
  ];

  /// Detailliertes Polygon (30 Punkte) - Genauere Grenze
  static const List<LatLng> mshBorderDetailed = [
    // Nordwesten (Südharz)
    LatLng(51.6850, 11.0150), // Hayn
    LatLng(51.6720, 11.0580), // Stolberg Nord
    LatLng(51.6950, 11.1200), // Schwenda
    LatLng(51.7050, 11.1800), // Breitenstein
    LatLng(51.6900, 11.2300), // Harzgerode Rand

    // Norden
    LatLng(51.6800, 11.2900), // Stangerode
    LatLng(51.6700, 11.3500), // Wippra
    LatLng(51.6600, 11.4200), // Mansfeld
    LatLng(51.6500, 11.4800), // Klostermansfeld

    // Nordosten (Hettstedt Bereich)
    LatLng(51.6450, 11.5300), // Hettstedt
    LatLng(51.6200, 11.5800), // Gerbstedt Nord
    LatLng(51.5800, 11.6500), // Friedeburg
    LatLng(51.5400, 11.7200), // Gerbstedt Ost

    // Osten (Eisleben Bereich)
    LatLng(51.5000, 11.7400), // Wimmelburg
    LatLng(51.4600, 11.7000), // Volkstedt
    LatLng(51.4200, 11.6500), // Röblingen

    // Südosten
    LatLng(51.3800, 11.5800), // Allstedt
    LatLng(51.3400, 11.5200), // Mittelhausen
    LatLng(51.3100, 11.4500), // Riestedt

    // Süden (Sangerhausen Bereich)
    LatLng(51.2950, 11.3800), // Roßla
    LatLng(51.3000, 11.3000), // Sangerhausen Süd
    LatLng(51.3200, 11.2200), // Oberröblingen
    LatLng(51.3400, 11.1500), // Kelbra

    // Südwesten (Kyffhäuser Rand)
    LatLng(51.3600, 11.0800), // Uftrungen
    LatLng(51.4000, 11.0200), // Bennungen

    // Westen (Südharz)
    LatLng(51.4400, 10.9800), // Rottleberode
    LatLng(51.5000, 10.9500), // Stolberg West
    LatLng(51.5600, 10.9600), // Hainrode
    LatLng(51.6200, 10.9800), // Straßberg

    // Zurück zum Start
    LatLng(51.6850, 11.0150),
  ];

  /// Äußere Grenzen für Fog of War (weit außerhalb MSH)
  static const List<LatLng> outerBounds = [
    LatLng(53.0, 9.0), // NW - Weit im Norden
    LatLng(53.0, 14.0), // NE
    LatLng(50.0, 14.0), // SE
    LatLng(50.0, 9.0), // SW
    LatLng(53.0, 9.0), // Zurück zum Start
  ];

  /// Geografisches Zentrum von MSH
  static const LatLng mshCenter = LatLng(51.50, 11.35);

  /// Ungefährer Radius des Landkreises (in km)
  static const double mshRadiusKm = 35.0;

  /// Wichtige Orte als Referenzpunkte
  static const Map<String, LatLng> landmarks = {
    'Sangerhausen': LatLng(51.4667, 11.3000),
    'Eisleben': LatLng(51.5275, 11.5481),
    'Hettstedt': LatLng(51.6500, 11.5000),
    'Mansfeld': LatLng(51.5972, 11.4528),
    'Allstedt': LatLng(51.4014, 11.3856),
    'Stolberg': LatLng(51.5739, 10.9494),
    'Kelbra': LatLng(51.4333, 11.0333),
    'Gerbstedt': LatLng(51.6333, 11.6333),
    'Süßer See': LatLng(51.4833, 11.6167),
    'Europa-Rosarium': LatLng(51.4725, 11.2983),
    'Kyffhäuser': LatLng(51.4142, 11.1003),
  };
}
