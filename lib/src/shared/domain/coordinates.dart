import 'package:latlong2/latlong.dart';

/// Immutable Value Object für GPS-Koordinaten.
class Coordinates {

  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  /// Factory für Firestore GeoPoint
  factory Coordinates.fromGeoPoint(dynamic geoPoint) {
    return Coordinates(
      latitude: geoPoint.latitude as double,
      longitude: geoPoint.longitude as double,
    );
  }
  final double latitude;
  final double longitude;

  /// Konvertierung zu flutter_map LatLng
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// Distanz zu anderem Punkt in Metern
  double distanceTo(Coordinates other) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, toLatLng(), other.toLatLng());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinates &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'Coordinates($latitude, $longitude)';
}
