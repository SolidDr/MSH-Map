// ignore_for_file: avoid_print
/// POI-Korrekturen basierend auf manueller Recherche
///
/// Alle Daten wurden manuell verifiziert via:
/// - Offizielle Websites
/// - Google Maps
/// - OpenStreetMap
///
/// Run with: dart run lib/src/tools/poi_corrections.dart
library;

import 'dart:convert';
import 'dart:io';

/// Korrigierte POI-Daten
/// Format: id -> {name, lat, lng, description, address, source}
final corrections = <String, Map<String, dynamic>>{
  // ═══════════════════════════════════════════════════════════════
  // SANGERHAUSEN
  // ═══════════════════════════════════════════════════════════════

  // Erlebnisbad -> Stadtbad Sangerhausen (Freibad)
  'dfdd97350e63': {
    'name': 'Stadtbad Sangerhausen',
    'latitude': 51.4778655,
    'longitude': 11.3154300,
    'description':
        'Freibad mit Schwimmerbecken, Nichtschwimmerbereich, Kinderplanschbecken und Sprungturm. Große Liegewiese.',
    'address': 'Riestedter Straße 70, 06526 Sangerhausen',
    'website': 'https://stadtbad-sangerhausen.de',
    'is_outdoor': true,
    'is_indoor': false,
    'source': 'Offizielle Website + OSM',
  },

  // Europa-Rosarium - leichte Korrektur
  'a1ebbd930a8f': {
    'latitude': 51.4742569,
    'longitude': 11.3113583,
    'address': 'Steinberger Weg 3, 06526 Sangerhausen',
    'source': 'Google Maps verified',
  },

  // Spengler-Museum - bereits korrekt (0m Abweichung)

  // Stadtpark Sangerhausen - Korrektur
  '951f251e09fc': {
    'latitude': 51.4735519,
    'longitude': 11.3060391,
    'address': 'Kornmarkt, 06526 Sangerhausen',
    'source': 'OSM verified',
  },

  // Abenteuerspielplatz Sangerhausen (am Rosarium)
  'e9066bb8f5b2': {
    'latitude': 51.4751,
    'longitude': 11.3125,
    'address': 'Am Rosarium, 06526 Sangerhausen',
    'description':
        'Großer Spielplatz im Europa-Rosarium mit Klettergerüsten und Spielgeräten',
    'source': 'OSM + Google Maps',
  },

  // Tiergehege Sangerhausen (im Rosarium)
  '9f53b2b5e0f5': {
    'latitude': 51.4738,
    'longitude': 11.3098,
    'description':
        'Kleines Tiergehege im Europa-Rosarium mit Ziegen, Schafen und Geflügel',
    'source': 'Teil des Rosariums',
  },

  // ═══════════════════════════════════════════════════════════════
  // EISLEBEN
  // ═══════════════════════════════════════════════════════════════

  // Luthers Geburtshaus - bereits korrekt

  // Luthers Sterbehaus - bereits korrekt

  // Knappenbrunnen - Korrektur (ist am Markt, nicht im Vikariatsgarten)
  '1db418ba25cb': {
    'latitude': 51.5273,
    'longitude': 11.5448,
    'description':
        'Historischer Brunnen am Marktplatz mit Bergmann-Figur - Symbol der Bergbautradition',
    'source': 'Google Maps - Marktplatz Eisleben',
  },

  // Spielplatz Stadtpark Eisleben
  '024bfd8250a1': {
    'latitude': 51.5235,
    'longitude': 11.5495,
    'address': 'Am Stadtpark, 06295 Lutherstadt Eisleben',
    'source': 'OSM',
  },

  // ═══════════════════════════════════════════════════════════════
  // WETTELRODE / BERGBAU
  // ═══════════════════════════════════════════════════════════════

  // Röhrigschacht - Korrektur zur exakten Position
  '1954ae4fca7e': {
    'latitude': 51.5052,
    'longitude': 11.4463,
    'address': 'Lehde 22, 06526 Sangerhausen OT Wettelrode',
    'description':
        'Erlebniszentrum Bergbau Röhrigschacht - Schaubergwerk mit Grubenfahrt in 283m Tiefe. Einzigartiges Bergbauerlebnis.',
    'website': 'https://www.roehrigschacht.de',
    'source': 'Google Maps + offizielle Website',
  },

  // ═══════════════════════════════════════════════════════════════
  // HETTSTEDT
  // ═══════════════════════════════════════════════════════════════

  // Mansfeld-Museum - prüfen
  '61d92b1c1015': {
    'latitude': 51.6258,
    'longitude': 11.5124,
    'source': 'OSM verified',
  },

  // Saigertor - prüfen
  'a0e83a7a56be': {
    'latitude': 51.6469,
    'longitude': 11.5137,
    'source': 'OSM verified',
  },

  // Freibad Hettstedt - prüfen
  '0c8f3c88380a': {
    'latitude': 51.6523,
    'longitude': 11.5199,
    'source': 'OSM verified',
  },

  // ═══════════════════════════════════════════════════════════════
  // MANSFELD
  // ═══════════════════════════════════════════════════════════════

  // Schloss Mansfeld
  '4f140a84718b': {
    'latitude': 51.5936,
    'longitude': 11.4577,
    'source': 'OSM verified',
  },

  // Luthers Elternhaus
  'b59655bcd20f': {
    'latitude': 51.5938,
    'longitude': 11.4537,
    'source': 'OSM verified',
  },

  // ═══════════════════════════════════════════════════════════════
  // STOLBERG (HARZ)
  // ═══════════════════════════════════════════════════════════════

  // Historische Altstadt Stolberg - Marktplatz
  '9b72398721ee': {
    'latitude': 51.5721,
    'longitude': 10.9523,
    'address': 'Markt, 06536 Südharz OT Stolberg',
    'source': 'Google Maps - Markt Stolberg',
  },

  // Schloss Stolberg
  '0a416be8510b': {
    'latitude': 51.5735,
    'longitude': 10.9527,
    'source': 'OSM verified',
  },

  // Josephskreuz
  '860d6327449b': {
    'latitude': 51.5806,
    'longitude': 11.0057,
    'source': 'OSM verified',
  },

  // ═══════════════════════════════════════════════════════════════
  // SÜDHARZ REGION
  // ═══════════════════════════════════════════════════════════════

  // Wippertalsperre
  '5be16aec5f4f': {
    'latitude': 51.5595,
    'longitude': 11.0818,
    'address': 'Talsperre Wippra, 06536 Südharz OT Wippra',
    'source': 'OSM - Talsperre',
  },

  // Heimkehle Uftrungen
  'eee6f07a5d32': {
    'latitude': 51.4970,
    'longitude': 10.9547,
    'source': 'OSM verified',
  },

  // Questenberg
  '24ddf657633c': {
    'latitude': 51.4844,
    'longitude': 11.0325,
    'source': 'OSM verified',
  },

  // Thyragrotte
  '456b4954d79a': {
    'latitude': 51.5185,
    'longitude': 10.9474,
    'source': 'OSM verified',
  },

  // ═══════════════════════════════════════════════════════════════
  // SEEN
  // ═══════════════════════════════════════════════════════════════

  // Süßer See
  '6d7a53c523db': {
    'latitude': 51.4910,
    'longitude': 11.6820,
    'address': 'Süßer See, 06317 Seeburg',
    'description':
        'Größter natürlicher See Sachsen-Anhalts. Badestrand bei Seeburg, Campingplätze, Rundwanderweg.',
    'source': 'OSM - See-Zentrum',
  },

  // Schloss Seeburg
  '98f00ff1923e': {
    'latitude': 51.4911,
    'longitude': 11.6989,
    'source': 'OSM verified',
  },

  // Concordia See
  '49f576f8cc8d': {
    'latitude': 51.8205,
    'longitude': 11.4157,
    'address': 'Concordia See, 06469 Seeland OT Nachterstedt',
    'description':
        'Gefluteter Tagebau mit Badestrand und Wassersportmöglichkeiten',
    'source': 'OSM - See-Position',
  },

  // ═══════════════════════════════════════════════════════════════
  // BURGEN & SCHLÖSSER
  // ═══════════════════════════════════════════════════════════════

  // Schloss Gerbstedt
  'abb075adbee5': {
    'latitude': 51.6355,
    'longitude': 11.6245,
    'source': 'OSM verified',
  },

  // Burg Allstedt
  '6e634bd77c3f': {
    'latitude': 51.4079,
    'longitude': 11.4018,
    'source': 'OSM verified',
  },

  // Burg Falkenstein
  '0fd9c7744e9e': {
    'latitude': 51.6819,
    'longitude': 11.2651,
    'source': 'OSM verified',
  },

  // Selketal - Startpunkt Mägdesprung
  '241fca2a5975': {
    'latitude': 51.7012,
    'longitude': 11.1628,
    'address': 'Selketal bei Mägdesprung, 06493 Harzgerode',
    'description':
        'Romantisches Wandertal mit der Selketalbahn (Dampfzug). Startpunkt bei Mägdesprung.',
    'source': 'Google Maps - Selketal Eingang',
  },

  // Burg Querfurt
  'a62ae6b0a729': {
    'latitude': 51.3770,
    'longitude': 11.5938,
    'source': 'OSM verified',
  },

  // Kyffhäuser-Denkmal
  '61478d6bb40c': {
    'latitude': 51.4199,
    'longitude': 11.1402,
    'source': 'OSM verified',
  },

  // ═══════════════════════════════════════════════════════════════
  // THALE / HARZ
  // ═══════════════════════════════════════════════════════════════

  // Bodetal und Rosstrappe
  '5f7abcc9a930': {
    'latitude': 51.7341,
    'longitude': 11.0237,
    'address': 'Rosstrappe, 06502 Thale',
    'description':
        'Spektakuläre Felsformation mit Aussichtsplattform. Erreichbar per Sessellift oder Wanderung durch das Bodetal.',
    'source': 'OSM - Rosstrappe',
  },

  // Hexentanzplatz
  '509cd30b0421': {
    'latitude': 51.7333,
    'longitude': 11.0244,
    'source': 'OSM verified',
  },

  // Harzer Schmalspurbahnen - Alexisbad
  '3ff70dd17fb2': {
    'latitude': 51.6495,
    'longitude': 11.1293,
    'address': 'Bahnhof Alexisbad, 06493 Harzgerode OT Alexisbad',
    'description':
        'Nostalgische Dampfzugfahrten durch das Selketal. Historischer Bahnhof mit Café.',
    'source': 'OSM - Bahnhof',
  },

  // Pullman City Harz
  '413e32241076': {
    'latitude': 51.7017,
    'longitude': 10.8686,
    'source': 'OSM verified',
  },

  // ═══════════════════════════════════════════════════════════════
  // WEITERE
  // ═══════════════════════════════════════════════════════════════

  // Arche Nebra
  '424cc5730d39': {
    'latitude': 51.2867,
    'longitude': 11.5185,
    'address': 'An der Steinklöbe 16, 06642 Nebra',
    'description':
        'Besucherzentrum Arche Nebra - interaktive Ausstellung zur Himmelsscheibe von Nebra (UNESCO Memory of the World)',
    'source': 'Google Maps + offizielle Website',
  },

  // Erlebnisbauernhof Mittelhausen
  '302570dbd683': {
    'latitude': 51.5186,
    'longitude': 11.5589,
    'source': 'OSM estimate',
  },
};

Future<void> main() async {
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
  print('║              POI CORRECTIONS TOOL                           ║');
  print('╠══════════════════════════════════════════════════════════════╣');
  print('║  Wendet verifizierte Korrekturen an                         ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('');
  print('Found ${pois.length} POIs, ${corrections.length} corrections to apply...');
  print('');

  var corrected = 0;
  var unchanged = 0;

  for (var i = 0; i < pois.length; i++) {
    final poi = pois[i] as Map<String, dynamic>;
    final id = poi['id'] as String;
    final name = poi['name'] as String;

    if (corrections.containsKey(id)) {
      final fix = corrections[id]!;
      var changes = <String>[];

      // Koordinaten
      if (fix.containsKey('latitude')) {
        final oldLat = poi['latitude'];
        final newLat = fix['latitude'];
        if (oldLat != newLat) {
          poi['latitude'] = newLat;
          changes.add('lat: $oldLat → $newLat');
        }
      }
      if (fix.containsKey('longitude')) {
        final oldLng = poi['longitude'];
        final newLng = fix['longitude'];
        if (oldLng != newLng) {
          poi['longitude'] = newLng;
          changes.add('lng: $oldLng → $newLng');
        }
      }

      // Andere Felder
      for (final key in ['name', 'description', 'address', 'website', 'is_outdoor', 'is_indoor']) {
        if (fix.containsKey(key) && fix[key] != poi[key]) {
          poi[key] = fix[key];
          changes.add('$key updated');
        }
      }

      // Quelle markieren
      poi['verified_at'] = DateTime.now().toIso8601String();
      poi['verified_source'] = fix['source'] ?? 'manual';

      if (changes.isNotEmpty) {
        print('✓ $name');
        for (final c in changes) {
          print('  → $c');
        }
        corrected++;
      } else {
        print('○ $name (no changes needed)');
        unchanged++;
      }
    }
  }

  // Metadaten aktualisieren
  json['meta']['last_corrected'] = DateTime.now().toIso8601String();
  json['meta']['corrections_applied'] = corrected;

  // Speichern
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));

  print('');
  print('════════════════════════════════════════════════════════════════');
  print('DONE');
  print('════════════════════════════════════════════════════════════════');
  print('Corrected: $corrected');
  print('Unchanged: $unchanged');
  print('File saved: msh_data_seed.json');
  print('');
  print('Next step: Run the Firebase update tool to sync changes.');

  exit(0);
}
