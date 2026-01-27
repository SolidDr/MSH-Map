/// Manuelles Geocoding für fehlende POIs
/// Verwendet spezifischere Suchanfragen
///
/// Ausführung: dart run lib/src/tools/fix_missing_pois.dart
library;

import 'dart:convert';
import 'dart:io';

/// Manuelle Koordinaten-Korrekturen basierend auf OSM-Recherche
final manualFixes = <String, (double, double, String)>{
  // Name -> (lat, lng, source)
  'Stadtpark Sangerhausen': (
    51.4715,
    11.3055,
    'OSM: Stadtpark Sangerhausen',
  ),
  'Bergbaumuseum Röhrigschacht': (
    51.5189,
    11.4308,
    'OSM: Röhrig-Schacht Wettelrode',
  ),
  'Historische Altstadt Stolberg': (
    51.5734,
    10.9519,
    'OSM: Stolberg (Harz) Markt',
  ),
  'Wippertalsperre': (
    51.5603,
    11.0833,
    'OSM: Wippertalsperre bei Wippra',
  ),
  'Questenberg mit Queste': (
    51.4844,
    11.0325,
    'OSM: Questenberg (Südharz)',
  ),
  'Harzer Schmalspurbahnen - Selketalbahn': (
    51.6408,
    11.1267,
    'OSM: Bahnhof Alexisbad',
  ),
  'Tiergehege Sangerhausen': (
    51.4744,
    11.3113,
    'Near Europa-Rosarium (commonly nearby)',
  ),
  'Erlebnisbauernhof Mittelhausen': (
    51.5186,
    11.5589,
    'OSM: Mittelhausen bei Eisleben',
  ),
};

Future<void> main() async {
  print('=== Manual POI Fix Tool ===\n');

  // Load current seed data
  final seedFile = File('msh_data_seed.json');
  if (!seedFile.existsSync()) {
    print('Error: msh_data_seed.json not found!');
    exit(1);
  }

  final content = await seedFile.readAsString();
  final seedData = jsonDecode(content) as Map<String, dynamic>;
  final pois = seedData['data'] as List;

  var fixed = 0;

  for (final poi in pois) {
    final name = poi['name'] as String;

    if (manualFixes.containsKey(name)) {
      final fix = manualFixes[name]!;
      final oldLat = poi['latitude'] as num;
      final oldLng = poi['longitude'] as num;

      poi['latitude'] = fix.$1;
      poi['longitude'] = fix.$2;
      poi['geocoded_at'] = DateTime.now().toIso8601String();
      poi['geocode_source'] = fix.$3;

      print('✓ Fixed: $name');
      print('  Old: ${oldLat.toStringAsFixed(4)}, ${oldLng.toStringAsFixed(4)}');
      print('  New: ${fix.$1.toStringAsFixed(4)}, ${fix.$2.toStringAsFixed(4)}');
      print('  Source: ${fix.$3}');
      print('');
      fixed++;
    }
  }

  // Update metadata
  (seedData['meta'] as Map<String, dynamic>)['manually_fixed_count'] = fixed;
  (seedData['meta'] as Map<String, dynamic>)['last_updated'] = DateTime.now().toIso8601String();

  // Save
  final output = const JsonEncoder.withIndent('  ').convert(seedData);
  await seedFile.writeAsString(output);

  print('=== Summary ===');
  print('Manually fixed: $fixed POIs');
  print('Seed file updated: msh_data_seed.json');
}
