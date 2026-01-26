import '../../shared/domain/coordinates.dart';
import '../../shared/domain/bounding_box.dart';

class MapConfig {
  MapConfig._();

  /// Zentrum MSH (Sangerhausen)
  static const defaultCenter = Coordinates(
    latitude: 51.4667,
    longitude: 11.3000,
  );

  static const double defaultZoom = 11;
  static const double minZoom = 8;
  static const double maxZoom = 18;

  /// MSH Bounding Box
  static const mshRegion = BoundingBox(
    northEast: Coordinates(latitude: 51.75, longitude: 11.85),
    southWest: Coordinates(latitude: 51.25, longitude: 10.75),
  );

  static const tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgent = 'de.msh.map';
}
