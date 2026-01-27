// ignore_for_file: avoid_print
/// POI-Verifizierungstool mit OSM Overpass API
///
/// Sucht echte POIs in der Region und vergleicht mit unseren Daten.
/// Run with: dart run lib/src/tools/verify_pois.dart
library;

import 'dart:convert';
import 'dart:io';

/// OSM Overpass API für präzise POI-Suche
class OverpassService {
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';
  final HttpClient _client = HttpClient();

  /// Sucht POIs in einem Radius um gegebene Koordinaten
  Future<List<OsmPoi>> searchNearby({
    required double lat,
    required double lng,
    required String type, // amenity, tourism, leisure, etc.
    required String value, // swimming_pool, museum, etc.
    int radius = 2000,
  }) async {
    final query = '''
[out:json][timeout:25];
(
  node["$type"="$value"](around:$radius,$lat,$lng);
  way["$type"="$value"](around:$radius,$lat,$lng);
  relation["$type"="$value"](around:$radius,$lat,$lng);
);
out center;
''';

    try {
      final request = await _client.postUrl(Uri.parse(_baseUrl));
      request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
      request.write('data=${Uri.encodeComponent(query)}');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        print('  OSM Error: ${response.statusCode}');
        return [];
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final elements = json['elements'] as List<dynamic>;

      return elements.map((e) {
        final tags = e['tags'] as Map<String, dynamic>? ?? {};
        double? elat, elng;

        if (e['type'] == 'node') {
          elat = (e['lat'] as num?)?.toDouble();
          elng = (e['lon'] as num?)?.toDouble();
        } else {
          // way/relation: center coordinates
          final center = e['center'] as Map<String, dynamic>?;
          elat = (center?['lat'] as num?)?.toDouble();
          elng = (center?['lon'] as num?)?.toDouble();
        }

        return OsmPoi(
          name: tags['name'] as String? ?? 'Unnamed',
          lat: elat ?? 0,
          lng: elng ?? 0,
          type: tags['$type'] as String? ?? value,
          address: _buildAddress(tags),
          osmId: e['id'].toString(),
        );
      }).toList();
    } on Exception catch (e) {
      print('  OSM Search failed: $e');
      return [];
    }
  }

  /// Direkte Suche nach Name
  Future<OsmPoi?> searchByName(String name, {String? city}) async {
    final searchName = name.replaceAll('"', '\\"');
    final cityFilter = city != null ? '["addr:city"~"$city",i]' : '';

    final query = '''
[out:json][timeout:25];
(
  node["name"~"$searchName",i]$cityFilter;
  way["name"~"$searchName",i]$cityFilter;
  relation["name"~"$searchName",i]$cityFilter;
);
out center;
''';

    try {
      final request = await _client.postUrl(Uri.parse(_baseUrl));
      request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
      request.write('data=${Uri.encodeComponent(query)}');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) return null;

      final json = jsonDecode(body) as Map<String, dynamic>;
      final elements = json['elements'] as List<dynamic>;

      if (elements.isEmpty) return null;

      // Bestes Match nehmen
      final e = elements.first;
      final tags = e['tags'] as Map<String, dynamic>? ?? {};
      double? lat, lng;

      if (e['type'] == 'node') {
        lat = (e['lat'] as num?)?.toDouble();
        lng = (e['lon'] as num?)?.toDouble();
      } else {
        final center = e['center'] as Map<String, dynamic>?;
        lat = (center?['lat'] as num?)?.toDouble();
        lng = (center?['lon'] as num?)?.toDouble();
      }

      return OsmPoi(
        name: tags['name'] as String? ?? name,
        lat: lat ?? 0,
        lng: lng ?? 0,
        type: _detectType(tags),
        address: _buildAddress(tags),
        osmId: e['id'].toString(),
      );
    } on Exception catch (e) {
      print('  Name search failed: $e');
      return null;
    }
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:street'] != null) {
      parts.add(tags['addr:street'] as String);
      if (tags['addr:housenumber'] != null) {
        parts.add(tags['addr:housenumber'] as String);
      }
    }
    if (tags['addr:postcode'] != null) {
      parts.add(tags['addr:postcode'] as String);
    }
    if (tags['addr:city'] != null) {
      parts.add(tags['addr:city'] as String);
    }
    return parts.join(', ');
  }

  String _detectType(Map<String, dynamic> tags) {
    if (tags['tourism'] != null) return 'tourism:${tags['tourism']}';
    if (tags['amenity'] != null) return 'amenity:${tags['amenity']}';
    if (tags['leisure'] != null) return 'leisure:${tags['leisure']}';
    if (tags['historic'] != null) return 'historic:${tags['historic']}';
    if (tags['natural'] != null) return 'natural:${tags['natural']}';
    return 'unknown';
  }

  void dispose() => _client.close();
}

class OsmPoi {
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String address;
  final String osmId;

  OsmPoi({
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.address,
    required this.osmId,
  });
}

/// Mapping: unsere Kategorie -> OSM Tags
const categoryToOsm = {
  'pool': [
    ('leisure', 'swimming_pool'),
    ('amenity', 'swimming_pool'),
    ('leisure', 'water_park'),
  ],
  'museum': [
    ('tourism', 'museum'),
    ('amenity', 'museum'),
  ],
  'castle': [
    ('historic', 'castle'),
    ('tourism', 'attraction'),
    ('historic', 'monument'),
  ],
  'nature': [
    ('leisure', 'park'),
    ('leisure', 'nature_reserve'),
    ('natural', 'peak'),
    ('tourism', 'viewpoint'),
  ],
  'adventure': [
    ('tourism', 'theme_park'),
    ('leisure', 'amusement_arcade'),
    ('tourism', 'attraction'),
  ],
  'playground': [
    ('leisure', 'playground'),
  ],
  'zoo': [
    ('tourism', 'zoo'),
    ('leisure', 'wildlife_park'),
  ],
  'farm': [
    ('tourism', 'attraction'),
    ('landuse', 'farmyard'),
  ],
};

Future<void> main() async {
  final osm = OverpassService();

  // JSON laden
  final file = File('msh_data_seed.json');
  if (!file.existsSync()) {
    print('ERROR: msh_data_seed.json not found!');
    exit(1);
  }

  final jsonString = await file.readAsString();
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  final pois = json['data'] as List<dynamic>;

  print('╔══════════════════════════════════════════════════════════════╗');
  print('║              POI VERIFICATION TOOL                          ║');
  print('╠══════════════════════════════════════════════════════════════╣');
  print('║  Vergleicht unsere POIs mit OpenStreetMap-Daten             ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('');
  print('Found ${pois.length} POIs to verify...');
  print('');

  final results = <Map<String, dynamic>>[];
  var verified = 0;
  var issues = 0;
  var notFound = 0;

  for (var i = 0; i < pois.length; i++) {
    final poi = pois[i] as Map<String, dynamic>;
    final name = poi['name'] as String;
    final currentLat = (poi['latitude'] as num).toDouble();
    final currentLng = (poi['longitude'] as num).toDouble();
    final category = poi['category'] as String;

    print('[${ (i + 1).toString().padLeft(2)}/${pois.length}] $name');

    // 1. Direkte Namenssuche
    var osmPoi = await osm.searchByName(name);

    // 2. Wenn nicht gefunden, in der Nähe suchen
    if (osmPoi == null && categoryToOsm.containsKey(category)) {
      final osmTags = categoryToOsm[category]!;
      for (final (type, value) in osmTags) {
        final nearby = await osm.searchNearby(
          lat: currentLat,
          lng: currentLng,
          type: type,
          value: value,
          radius: 1000,
        );

        if (nearby.isNotEmpty) {
          // Nächstgelegenen finden
          nearby.sort((a, b) {
            final distA = _distance(currentLat, currentLng, a.lat, a.lng);
            final distB = _distance(currentLat, currentLng, b.lat, b.lng);
            return distA.compareTo(distB);
          });
          osmPoi = nearby.first;
          break;
        }
      }
    }

    if (osmPoi != null && osmPoi.lat != 0) {
      final distance = _distance(currentLat, currentLng, osmPoi.lat, osmPoi.lng);
      final distanceStr = distance < 1000
          ? '${distance.round()}m'
          : '${(distance / 1000).toStringAsFixed(1)}km';

      if (distance < 100) {
        print('  ✓ VERIFIED (${distanceStr} Abweichung)');
        print('    OSM: ${osmPoi.name}');
        verified++;
        results.add({
          'id': poi['id'],
          'name': name,
          'status': 'verified',
          'distance': distance,
          'osm_name': osmPoi.name,
          'osm_lat': osmPoi.lat,
          'osm_lng': osmPoi.lng,
          'current_lat': currentLat,
          'current_lng': currentLng,
        });
      } else {
        print('  ⚠ ISSUE: $distanceStr Abweichung!');
        print('    Aktuell: $currentLat, $currentLng');
        print('    OSM:     ${osmPoi.lat}, ${osmPoi.lng} (${osmPoi.name})');
        issues++;
        results.add({
          'id': poi['id'],
          'name': name,
          'status': 'issue',
          'distance': distance,
          'osm_name': osmPoi.name,
          'osm_lat': osmPoi.lat,
          'osm_lng': osmPoi.lng,
          'osm_address': osmPoi.address,
          'current_lat': currentLat,
          'current_lng': currentLng,
        });
      }
    } else {
      print('  ✗ NOT FOUND in OSM');
      notFound++;
      results.add({
        'id': poi['id'],
        'name': name,
        'status': 'not_found',
        'current_lat': currentLat,
        'current_lng': currentLng,
      });
    }

    // Rate limit
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  print('');
  print('════════════════════════════════════════════════════════════════');
  print('SUMMARY');
  print('════════════════════════════════════════════════════════════════');
  print('Verified:  $verified');
  print('Issues:    $issues');
  print('Not Found: $notFound');
  print('');

  // Ergebnisse speichern
  final outputFile = File('poi_verification_results.json');
  await outputFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'verified_at': DateTime.now().toIso8601String(),
      'summary': {
        'verified': verified,
        'issues': issues,
        'not_found': notFound,
      },
      'results': results,
    }),
  );
  print('Results saved to: poi_verification_results.json');

  // Issues anzeigen
  if (issues > 0) {
    print('');
    print('════════════════════════════════════════════════════════════════');
    print('POIs WITH ISSUES (need manual review):');
    print('════════════════════════════════════════════════════════════════');
    for (final r in results.where((r) => r['status'] == 'issue')) {
      final dist = r['distance'] as double;
      print('');
      print('${r['name']}');
      print('  Current: ${r['current_lat']}, ${r['current_lng']}');
      print('  OSM:     ${r['osm_lat']}, ${r['osm_lng']}');
      print('  → ${dist < 1000 ? '${dist.round()}m' : '${(dist / 1000).toStringAsFixed(1)}km'} difference');
    }
  }

  osm.dispose();
  exit(0);
}

/// Haversine distance in meters
double _distance(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0; // Earth radius in meters
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = _sin(dLat / 2) * _sin(dLat / 2) +
      _cos(_toRad(lat1)) * _cos(_toRad(lat2)) * _sin(dLon / 2) * _sin(dLon / 2);
  final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
  return r * c;
}

double _toRad(double deg) => deg * 3.141592653589793 / 180;
double _sin(double x) => _taylor(x, true);
double _cos(double x) => _taylor(x, false);
double _sqrt(double x) {
  if (x <= 0) return 0;
  var guess = x / 2;
  for (var i = 0; i < 20; i++) {
    guess = (guess + x / guess) / 2;
  }
  return guess;
}
double _atan2(double y, double x) {
  if (x > 0) return _atan(y / x);
  if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
  if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
  if (x == 0 && y > 0) return 3.141592653589793 / 2;
  if (x == 0 && y < 0) return -3.141592653589793 / 2;
  return 0;
}
double _atan(double x) {
  var result = 0.0;
  var term = x;
  for (var n = 0; n < 50; n++) {
    result += term / (2 * n + 1) * (n % 2 == 0 ? 1 : -1);
    term *= x * x;
    if (term.abs() < 1e-15) break;
  }
  return result;
}
double _taylor(double x, bool isSin) {
  // Normalize to [-pi, pi]
  while (x > 3.141592653589793) x -= 2 * 3.141592653589793;
  while (x < -3.141592653589793) x += 2 * 3.141592653589793;

  var result = isSin ? x : 1.0;
  var term = isSin ? x : 1.0;

  for (var n = 1; n < 20; n++) {
    final exp = isSin ? 2 * n + 1 : 2 * n;
    term *= -x * x / ((exp - 1) * exp);
    result += term;
  }
  return result;
}
