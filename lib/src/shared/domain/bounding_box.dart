import 'coordinates.dart';

/// Rechteckiger Bereich für Geo-Queries.
class BoundingBox {

  const BoundingBox({
    required this.northEast,
    required this.southWest,
  });
  final Coordinates northEast;
  final Coordinates southWest;

  /// Prüft ob Punkt innerhalb liegt
  bool contains(Coordinates point) {
    return point.latitude <= northEast.latitude &&
        point.latitude >= southWest.latitude &&
        point.longitude <= northEast.longitude &&
        point.longitude >= southWest.longitude;
  }

  /// Zentrum der Box
  Coordinates get center => Coordinates(
        latitude: (northEast.latitude + southWest.latitude) / 2,
        longitude: (northEast.longitude + southWest.longitude) / 2,
      );

  /// Erweitert die Box um Faktor
  BoundingBox expand(double factor) {
    final latDiff =
        (northEast.latitude - southWest.latitude) * (factor - 1) / 2;
    final lngDiff =
        (northEast.longitude - southWest.longitude) * (factor - 1) / 2;
    return BoundingBox(
      northEast: Coordinates(
        latitude: northEast.latitude + latDiff,
        longitude: northEast.longitude + lngDiff,
      ),
      southWest: Coordinates(
        latitude: southWest.latitude - latDiff,
        longitude: southWest.longitude - lngDiff,
      ),
    );
  }
}
