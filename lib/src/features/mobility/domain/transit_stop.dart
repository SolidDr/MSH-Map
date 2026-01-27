/// Transit Stop Model für ÖPNV-Haltestellen
/// Datenquelle: v6.db.transport.rest API
library;

/// Haltestelle/Station im ÖPNV-Netz
class TransitStop {
  const TransitStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.products,
  });

  /// Eindeutige ID der Haltestelle (z.B. "8010159")
  final String id;

  /// Name der Haltestelle (z.B. "Halle (Saale) Hbf")
  final String name;

  /// Geografische Breite
  final double latitude;

  /// Geografische Länge
  final double longitude;

  /// Entfernung in Metern (nur bei nearby-Abfragen)
  final int? distance;

  /// Verfügbare Verkehrsmittel an dieser Haltestelle
  final TransitProducts? products;

  /// Formatierte Entfernung für Anzeige
  String get distanceFormatted {
    if (distance == null) return '';
    if (distance! < 1000) return '${distance}m';
    return '${(distance! / 1000).toStringAsFixed(1)}km';
  }

  /// Prüft ob es eine Bahnstation ist (Zug/S-Bahn)
  bool get isStation {
    if (products == null) return false;
    return products!.hasFernverkehr || products!.hasNahverkehr;
  }

  factory TransitStop.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;

    return TransitStop(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unbekannte Haltestelle',
      latitude: _parseDouble(location?['latitude'] ?? json['latitude']),
      longitude: _parseDouble(location?['longitude'] ?? json['longitude']),
      distance: json['distance'] as int?,
      products: json['products'] != null
          ? TransitProducts.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        if (distance != null) 'distance': distance,
        if (products != null) 'products': products!.toJson(),
      };
}

/// Verfügbare Verkehrsmittel an einer Haltestelle
class TransitProducts {
  const TransitProducts({
    this.nationalExpress = false,
    this.national = false,
    this.regionalExpress = false,
    this.regional = false,
    this.suburban = false,
    this.bus = false,
    this.ferry = false,
    this.subway = false,
    this.tram = false,
    this.taxi = false,
  });

  final bool nationalExpress; // ICE
  final bool national; // IC/EC
  final bool regionalExpress; // RE
  final bool regional; // RB
  final bool suburban; // S-Bahn
  final bool bus;
  final bool ferry;
  final bool subway; // U-Bahn
  final bool tram; // Straßenbahn
  final bool taxi;

  /// Prüft ob Fernverkehr verfügbar ist
  bool get hasFernverkehr => nationalExpress || national;

  /// Prüft ob Nahverkehr verfügbar ist
  bool get hasNahverkehr => regionalExpress || regional || suburban;

  /// Prüft ob Bus verfügbar ist
  bool get hasBus => bus;

  factory TransitProducts.fromJson(Map<String, dynamic> json) {
    return TransitProducts(
      nationalExpress: json['nationalExpress'] as bool? ?? false,
      national: json['national'] as bool? ?? false,
      regionalExpress: json['regionalExpress'] as bool? ?? false,
      regional: json['regional'] as bool? ?? false,
      suburban: json['suburban'] as bool? ?? false,
      bus: json['bus'] as bool? ?? false,
      ferry: json['ferry'] as bool? ?? false,
      subway: json['subway'] as bool? ?? false,
      tram: json['tram'] as bool? ?? false,
      taxi: json['taxi'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'nationalExpress': nationalExpress,
        'national': national,
        'regionalExpress': regionalExpress,
        'regional': regional,
        'suburban': suburban,
        'bus': bus,
        'ferry': ferry,
        'subway': subway,
        'tram': tram,
        'taxi': taxi,
      };
}
