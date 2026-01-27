/// Geocoding-Tool für POI-Koordinaten
/// Verwendet Nominatim (OpenStreetMap) für exakte Koordinaten
///
/// Ausführung: dart run lib/src/tools/geocode_pois.dart
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Nominatim API für Geocoding
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  // Rate limit: 1 request per second
  DateTime? _lastRequest;

  final http.Client _client = http.Client();

  /// Geocode an address to coordinates
  Future<(double lat, double lng)?> geocode(String query) async {
    // Respect rate limit
    await _respectRateLimit();

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '1',
        'countrycodes': 'de',
      },
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'MSH-Map-App/1.0 (geocoding POIs)',
        },
      );

      if (response.statusCode != 200) {
        print('  Error: HTTP ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as List;
      if (data.isEmpty) {
        return null;
      }

      final result = data.first as Map<String, dynamic>;
      final lat = double.tryParse(result['lat']?.toString() ?? '');
      final lng = double.tryParse(result['lon']?.toString() ?? '');

      if (lat == null || lng == null) return null;

      return (lat, lng);
    } catch (e) {
      print('  Error: $e');
      return null;
    }
  }

  Future<void> _respectRateLimit() async {
    if (_lastRequest != null) {
      final elapsed = DateTime.now().difference(_lastRequest!);
      if (elapsed.inMilliseconds < 1100) {
        await Future<void>.delayed(Duration(milliseconds: 1100 - elapsed.inMilliseconds));
      }
    }
    _lastRequest = DateTime.now();
  }

  void dispose() => _client.close();
}

Future<void> main() async {
  print('=== POI Geocoding Tool ===\n');

  // Load current seed data
  final seedFile = File('msh_data_seed.json');
  if (!seedFile.existsSync()) {
    print('Error: msh_data_seed.json not found!');
    exit(1);
  }

  final content = await seedFile.readAsString();
  final seedData = jsonDecode(content) as Map<String, dynamic>;
  final pois = seedData['data'] as List;

  print('Found ${pois.length} POIs to geocode\n');

  final nominatim = NominatimService();
  var updated = 0;
  var failed = 0;

  for (var i = 0; i < pois.length; i++) {
    final poi = pois[i] as Map<String, dynamic>;
    final name = poi['name'] as String;
    final address = poi['address'] as String? ?? '';
    final city = poi['city'] as String? ?? '';

    print('[${i + 1}/${pois.length}] $name');

    // Build search queries (try multiple approaches)
    final queries = <String>[
      // 1. Name + City (most specific for landmarks)
      '$name, $city, Germany',
      // 2. Full address
      if (address.isNotEmpty) '$address, Germany',
      // 3. Name only
      '$name, Sachsen-Anhalt, Germany',
    ];

    (double, double)? coords;
    String? usedQuery;

    for (final query in queries) {
      coords = await nominatim.geocode(query);
      if (coords != null) {
        usedQuery = query;
        break;
      }
    }

    if (coords != null) {
      final oldLat = poi['latitude'] as num;
      final oldLng = poi['longitude'] as num;

      // Calculate distance from old to new coords (rough approximation)
      final latDiff = (coords.$1 - oldLat.toDouble()).abs();
      final lngDiff = (coords.$2 - oldLng.toDouble()).abs();
      final distanceKm = ((latDiff * 111) + (lngDiff * 71)) / 2; // rough km

      poi['latitude'] = coords.$1;
      poi['longitude'] = coords.$2;
      poi['geocoded_at'] = DateTime.now().toIso8601String();
      poi['geocode_query'] = usedQuery;

      if (distanceKm > 0.1) {
        print('  ✓ Updated: ${oldLat.toStringAsFixed(4)}, ${oldLng.toStringAsFixed(4)}');
        print('         → ${coords.$1.toStringAsFixed(4)}, ${coords.$2.toStringAsFixed(4)}');
        print('    (~${distanceKm.toStringAsFixed(1)} km difference)');
      } else {
        print('  ✓ Verified (no significant change)');
      }
      updated++;
    } else {
      print('  ✗ Could not geocode - keeping original coordinates');
      failed++;
    }
  }

  // Save updated data
  seedData['meta']['geocoded_at'] = DateTime.now().toIso8601String();
  seedData['meta']['geocoded_count'] = updated;

  final output = const JsonEncoder.withIndent('  ').convert(seedData);
  await seedFile.writeAsString(output);

  print('\n=== Summary ===');
  print('Updated: $updated');
  print('Failed: $failed');
  print('\nSeed file updated: msh_data_seed.json');

  nominatim.dispose();
}
