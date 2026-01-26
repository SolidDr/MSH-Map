import 'package:url_launcher/url_launcher.dart';

/// Helper class for public transport integration
class TransportHelper {
  /// Opens Google Maps with public transit directions to the given coordinates
  static Future<bool> openPublicTransitDirections({
    required double latitude,
    required double longitude,
    String? placeName,
  }) async {
    // Google Maps URL with public transit mode
    // travelmode=transit tells Google Maps to use public transportation
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude'
      '&travelmode=transit',
    );

    if (await canLaunchUrl(url)) {
      return launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Opens HVV (Hamburg Public Transport) app/website with directions
  /// Only relevant for Hamburg region
  static Future<bool> openHVVDirections({
    required double latitude,
    required double longitude,
    String? placeName,
  }) async {
    // HVV Geofox API URL (opens in browser or app if installed)
    final name = placeName != null ? Uri.encodeComponent(placeName) : '';
    final url = Uri.parse(
      'https://www.hvv.de/de/fahrplaene/fahrplanauskunft'
      '?to=$latitude,$longitude${name.isNotEmpty ? '&toName=$name' : ''}',
    );

    if (await canLaunchUrl(url)) {
      return launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Opens general directions in the default maps app
  static Future<bool> openDirections({
    required double latitude,
    required double longitude,
  }) async {
    // Universal geo: URI scheme - works on most platforms
    final url = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');

    if (await canLaunchUrl(url)) {
      return launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to Google Maps web
      return openPublicTransitDirections(
        latitude: latitude,
        longitude: longitude,
      );
    }
  }
}
