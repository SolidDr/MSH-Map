// ignore_for_file: avoid_print
/// Sync korrigierte POI-Daten zu Firebase
///
/// Aktualisiert alle POI-Felder (Name, Beschreibung, Koordinaten, Adresse)
/// Run with: flutter run -t lib/src/tools/sync_pois_to_firebase.dart -d chrome
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';

/// Korrigierte POI-Daten (aus msh_data_seed.json nach Korrektur)
/// Format: id -> {alle zu aktualisierenden Felder}
const poiUpdates = <String, Map<String, dynamic>>{
  // ═══════════════════════════════════════════════════════════════
  // SANGERHAUSEN
  // ═══════════════════════════════════════════════════════════════
  'a1ebbd930a8f': {
    'name': 'Europa-Rosarium Sangerhausen',
    'latitude': 51.4742569,
    'longitude': 11.3113583,
    'address': 'Steinberger Weg 3, 06526 Sangerhausen',
    'description':
        'Größte Rosensammlung der Welt mit über 8.600 Rosensorten. Weitläufiger Park mit Spielplatz und Café.',
  },
  '6cde51fe78b6': {
    'name': 'Spengler-Museum Sangerhausen',
    'latitude': 51.478434,
    'longitude': 11.2942834,
    'address': 'Bahnhofstraße 33, 06526 Sangerhausen',
    'description':
        'Naturkunde- und Heimatmuseum mit Mammut-Skelett, Bergbau-Geschichte und Mineraliensammlung',
  },
  'dfdd97350e63': {
    'name': 'Stadtbad Sangerhausen',
    'latitude': 51.4778655,
    'longitude': 11.31543,
    'address': 'Riestedter Straße 70, 06526 Sangerhausen',
    'description':
        'Freibad mit Schwimmerbecken, Nichtschwimmerbereich, Kinderplanschbecken und Sprungturm. Große Liegewiese.',
    'website': 'https://stadtbad-sangerhausen.de',
  },
  '951f251e09fc': {
    'name': 'Stadtpark Sangerhausen',
    'latitude': 51.4735519,
    'longitude': 11.3060391,
    'address': 'Kornmarkt, 06526 Sangerhausen',
    'description':
        'Historischer Stadtpark mit altem Baumbestand, Teich und Spielplatz',
  },
  'e9066bb8f5b2': {
    'name': 'Abenteuerspielplatz Sangerhausen',
    'latitude': 51.4751,
    'longitude': 11.3125,
    'address': 'Am Rosarium, 06526 Sangerhausen',
    'description':
        'Großer Spielplatz im Europa-Rosarium mit Klettergerüsten und Spielgeräten',
  },
  '9f53b2b5e0f5': {
    'name': 'Tiergehege Sangerhausen',
    'latitude': 51.4738,
    'longitude': 11.3098,
    'description':
        'Kleines Tiergehege im Europa-Rosarium mit Ziegen, Schafen und Geflügel',
  },

  // ═══════════════════════════════════════════════════════════════
  // EISLEBEN
  // ═══════════════════════════════════════════════════════════════
  'e9369f00189b': {
    'name': 'Luthers Geburtshaus',
    'latitude': 51.52677,
    'longitude': 11.5501248,
    'address': 'Lutherstraße 15, 06295 Lutherstadt Eisleben',
    'description':
        'UNESCO-Weltkulturerbe - Geburtshaus Martin Luthers mit Museum zur Kindheit des Reformators',
  },
  '7b738ecffbb2': {
    'name': 'Luthers Sterbehaus',
    'latitude': 51.5280953,
    'longitude': 11.5443381,
    'address': 'Andreaskirchplatz 7, 06295 Lutherstadt Eisleben',
    'description':
        'UNESCO-Weltkulturerbe - Museum zum Leben und Sterben Martin Luthers',
  },
  '1db418ba25cb': {
    'name': 'Knappenbrunnen Eisleben',
    'latitude': 51.5273,
    'longitude': 11.5448,
    'address': 'Markt, 06295 Lutherstadt Eisleben',
    'description':
        'Historischer Brunnen am Marktplatz mit Bergmann-Figur - Symbol der Bergbautradition',
  },
  '024bfd8250a1': {
    'name': 'Spielplatz Stadtpark Eisleben',
    'latitude': 51.5235,
    'longitude': 11.5495,
    'address': 'Am Stadtpark, 06295 Lutherstadt Eisleben',
    'description': 'Moderner Spielplatz im Stadtpark mit verschiedenen Spielgeräten',
  },

  // ═══════════════════════════════════════════════════════════════
  // WETTELRODE / BERGBAU
  // ═══════════════════════════════════════════════════════════════
  '1954ae4fca7e': {
    'name': 'Bergbaumuseum Röhrigschacht',
    'latitude': 51.5052,
    'longitude': 11.4463,
    'address': 'Lehde 22, 06526 Sangerhausen OT Wettelrode',
    'description':
        'Erlebniszentrum Bergbau Röhrigschacht - Schaubergwerk mit Grubenfahrt in 283m Tiefe. Einzigartiges Bergbauerlebnis.',
    'website': 'https://www.roehrigschacht.de',
  },

  // ═══════════════════════════════════════════════════════════════
  // HETTSTEDT
  // ═══════════════════════════════════════════════════════════════
  '61d92b1c1015': {
    'name': 'Mansfeld-Museum Hettstedt',
    'latitude': 51.6258,
    'longitude': 11.5124,
    'address': 'Wilhelm-Stiehler-Straße 2, 06333 Hettstedt',
    'description':
        'Industrie- und Technikmuseum zur Kupferverarbeitung mit funktionsfähiger Dampfmaschine',
  },
  'a0e83a7a56be': {
    'name': 'Saigertor Hettstedt',
    'latitude': 51.6469,
    'longitude': 11.5137,
    'address': 'Saigertor, 06333 Hettstedt',
    'description':
        'Historisches Stadttor - letztes erhaltenes von ursprünglich vier Stadttoren',
  },
  '0c8f3c88380a': {
    'name': 'Freibad Hettstedt',
    'latitude': 51.6523,
    'longitude': 11.5199,
    'address': 'Badstraße, 06333 Hettstedt',
    'description': 'Freibad mit großzügiger Liegewiese und Kinderbereich',
  },

  // ═══════════════════════════════════════════════════════════════
  // MANSFELD
  // ═══════════════════════════════════════════════════════════════
  '4f140a84718b': {
    'name': 'Schloss Mansfeld',
    'latitude': 51.5936,
    'longitude': 11.4577,
    'address': 'Am Schloss 1, 06343 Mansfeld',
    'description':
        'Imposante Burganlage oberhalb von Mansfeld mit Jugendbildungsstätte und toller Aussicht',
  },
  'b59655bcd20f': {
    'name': 'Luthers Elternhaus Mansfeld',
    'latitude': 51.5938,
    'longitude': 11.4537,
    'address': 'Lutherstraße 26, 06343 Mansfeld',
    'description': 'Museum zur Kindheit und Jugend Martin Luthers in Mansfeld',
  },

  // ═══════════════════════════════════════════════════════════════
  // STOLBERG (HARZ)
  // ═══════════════════════════════════════════════════════════════
  '9b72398721ee': {
    'name': 'Historische Altstadt Stolberg',
    'latitude': 51.5721,
    'longitude': 10.9523,
    'address': 'Markt, 06536 Südharz OT Stolberg',
    'description':
        "Mittelalterliche Fachwerkstadt mit Schloss - 'Perle des Südharzes'. Komplett erhaltenes historisches Stadtbild.",
  },
  '0a416be8510b': {
    'name': 'Schloss Stolberg',
    'latitude': 51.5735,
    'longitude': 10.9527,
    'address': 'Schlossberg 1, 06536 Südharz OT Stolberg',
    'description':
        'Renaissance-Schloss hoch über der Fachwerkstadt mit Museum und Aussichtsturm',
  },
  '860d6327449b': {
    'name': 'Josephskreuz',
    'latitude': 51.5806,
    'longitude': 11.0057,
    'address': 'Auerberg, 06536 Südharz OT Stolberg',
    'description':
        'Größtes eisernes Doppelkreuz der Welt auf dem Großen Auerberg (580m). Aussichtsplattform mit Harz-Panorama.',
  },

  // ═══════════════════════════════════════════════════════════════
  // SÜDHARZ REGION
  // ═══════════════════════════════════════════════════════════════
  '5be16aec5f4f': {
    'name': 'Wippertalsperre',
    'latitude': 51.5595,
    'longitude': 11.0818,
    'address': 'Talsperre Wippra, 06536 Südharz OT Wippra',
    'description':
        'Talsperre mit Rundwanderweg (6km), Spielplatz, Gastronomie und Badestelle im Sommer',
  },
  'eee6f07a5d32': {
    'name': 'Heimkehle Uftrungen',
    'latitude': 51.497,
    'longitude': 10.9547,
    'address': 'Heimkehle 1, 06536 Südharz OT Uftrungen',
    'description':
        'Größte Gipshöhle Deutschlands mit unterirdischem See. Faszinierende Tropfsteinformationen.',
  },
  '24ddf657633c': {
    'name': 'Questenberg mit Queste',
    'latitude': 51.4844,
    'longitude': 11.0325,
    'address': '06536 Südharz OT Questenberg',
    'description':
        "Historisches Dorf mit der berühmten 'Queste' - einem 800 Jahre alten Osterbrauch. Wanderwege und Burgruine.",
  },
  '456b4954d79a': {
    'name': 'Thyragrotte Rottleberode',
    'latitude': 51.5185,
    'longitude': 10.9474,
    'address': 'Rottleberode, 06536 Südharz',
    'description':
        'Kleine aber feine Tropfsteinhöhle mit beeindruckenden Formationen',
  },

  // ═══════════════════════════════════════════════════════════════
  // SEEN
  // ═══════════════════════════════════════════════════════════════
  '6d7a53c523db': {
    'name': 'Süßer See',
    'latitude': 51.491,
    'longitude': 11.682,
    'address': 'Süßer See, 06317 Seeburg',
    'description':
        'Größter natürlicher See Sachsen-Anhalts. Badestrand bei Seeburg, Campingplätze, Rundwanderweg.',
  },
  '98f00ff1923e': {
    'name': 'Schloss Seeburg',
    'latitude': 51.4911,
    'longitude': 11.6989,
    'address': 'Schlossstraße, 06317 Seeburg',
    'description':
        'Romanisches Schloss am Süßen See mit Ausstellungen und Veranstaltungen',
  },
  '49f576f8cc8d': {
    'name': 'Concordia See',
    'latitude': 51.8205,
    'longitude': 11.4157,
    'address': 'Concordia See, 06469 Seeland OT Nachterstedt',
    'description':
        'Gefluteter Tagebau mit Badestrand und Wassersportmöglichkeiten',
  },

  // ═══════════════════════════════════════════════════════════════
  // BURGEN & SCHLÖSSER
  // ═══════════════════════════════════════════════════════════════
  'abb075adbee5': {
    'name': 'Schloss Gerbstedt',
    'latitude': 51.6355,
    'longitude': 11.6245,
    'address': 'Schlossplatz, 06347 Gerbstedt',
    'description': 'Historische Schlossanlage mit Park',
  },
  '6e634bd77c3f': {
    'name': 'Burg und Schloss Allstedt',
    'latitude': 51.4079,
    'longitude': 11.4018,
    'address': 'Schloss 8, 06542 Allstedt',
    'description':
        'Mittelalterliche Burg mit Schloss. Wirkungsstätte von Thomas Müntzer. Museum und Veranstaltungen.',
  },
  '0fd9c7744e9e': {
    'name': 'Burg Falkenstein',
    'latitude': 51.6819,
    'longitude': 11.2651,
    'address': 'Burg Falkenstein, 06543 Falkenstein/Harz',
    'description':
        'Besterhaltene Höhenburg des Harzes. Museum, Falknervorführungen, mittelalterliches Ambiente.',
  },
  '241fca2a5975': {
    'name': 'Selketal',
    'latitude': 51.7012,
    'longitude': 11.1628,
    'address': 'Selketal bei Mägdesprung, 06493 Harzgerode',
    'description':
        'Romantisches Wandertal mit der Selketalbahn (Dampfzug). Startpunkt bei Mägdesprung.',
  },
  'a62ae6b0a729': {
    'name': 'Burg Querfurt',
    'latitude': 51.377,
    'longitude': 11.5938,
    'address': 'Burg 1, 06268 Querfurt',
    'description':
        'Eine der größten und ältesten Burgen Deutschlands. Imposante Anlage mit Museum und Veranstaltungen.',
  },
  '61478d6bb40c': {
    'name': 'Kyffhäuser-Denkmal',
    'latitude': 51.4199,
    'longitude': 11.1402,
    'address': 'Kyffhäuser 2, 06537 Kelbra',
    'description':
        'Monumentales Kaiser-Wilhelm-Denkmal mit Barbarossa-Sage. Aussichtsturm und Burgruine.',
  },

  // ═══════════════════════════════════════════════════════════════
  // THALE / HARZ
  // ═══════════════════════════════════════════════════════════════
  '5f7abcc9a930': {
    'name': 'Bodetal und Rosstrappe',
    'latitude': 51.7341,
    'longitude': 11.0237,
    'address': 'Rosstrappe, 06502 Thale',
    'description':
        'Spektakuläre Felsformation mit Aussichtsplattform. Erreichbar per Sessellift oder Wanderung durch das Bodetal.',
  },
  '509cd30b0421': {
    'name': 'Hexentanzplatz Thale',
    'latitude': 51.7333,
    'longitude': 11.0244,
    'address': 'Hexentanzplatz, 06502 Thale',
    'description':
        'Mystischer Ort mit Seilbahn, Tierpark, Sommerrodelbahn und Hexen-Spielplatz',
  },
  '3ff70dd17fb2': {
    'name': 'Harzer Schmalspurbahnen - Selketalbahn',
    'latitude': 51.6495,
    'longitude': 11.1293,
    'address': 'Bahnhof Alexisbad, 06493 Harzgerode OT Alexisbad',
    'description':
        'Nostalgische Dampfzugfahrten durch das Selketal. Historischer Bahnhof mit Café.',
  },
  '413e32241076': {
    'name': 'Pullman City Harz',
    'latitude': 51.7017,
    'longitude': 10.8686,
    'address': 'Am Western Village 1, 38899 Hasselfelde',
    'description':
        'Western-Freizeitpark mit Shows, Fahrgeschäften und Übernachtungen im Wild-West-Stil',
  },

  // ═══════════════════════════════════════════════════════════════
  // WEITERE
  // ═══════════════════════════════════════════════════════════════
  '424cc5730d39': {
    'name': 'Arche Nebra',
    'latitude': 51.2867,
    'longitude': 11.5185,
    'address': 'An der Steinklöbe 16, 06642 Nebra',
    'description':
        'Besucherzentrum Arche Nebra - interaktive Ausstellung zur Himmelsscheibe von Nebra (UNESCO Memory of the World)',
  },
  '302570dbd683': {
    'name': 'Erlebnisbauernhof Mittelhausen',
    'latitude': 51.5186,
    'longitude': 11.5589,
    'address': 'Mittelhausen, 06295 Lutherstadt Eisleben',
    'description':
        'Bauernhof zum Anfassen - Tiere füttern, Reiten und Landwirtschaft erleben',
  },
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SyncPoisApp());
}

class SyncPoisApp extends StatelessWidget {
  const SyncPoisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POI Sync Tool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('POI Firebase Sync'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const SyncScreen(),
      ),
    );
  }
}

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final _log = <String>[];
  var _running = false;
  var _updated = 0;
  var _created = 0;
  var _failed = 0;

  Future<void> _runSync() async {
    setState(() {
      _running = true;
      _log.clear();
      _updated = 0;
      _created = 0;
      _failed = 0;
    });

    _addLog('Starting POI sync to Firebase...');
    _addLog('Found ${poiUpdates.length} POIs to sync');
    _addLog('');

    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('pois');

    for (final entry in poiUpdates.entries) {
      final id = entry.key;
      final data = entry.value;
      final name = data['name'] as String;

      try {
        final doc = await collection.doc(id).get();

        // Update-Daten vorbereiten
        final updateData = <String, dynamic>{
          'location': GeoPoint(
            data['latitude'] as double,
            data['longitude'] as double,
          ),
          'updated_at': FieldValue.serverTimestamp(),
        };

        // Weitere Felder hinzufügen
        if (data.containsKey('name')) updateData['name'] = data['name'];
        if (data.containsKey('description')) {
          updateData['description'] = data['description'];
        }
        if (data.containsKey('address')) updateData['address'] = data['address'];
        if (data.containsKey('website')) updateData['website'] = data['website'];

        if (doc.exists) {
          await collection.doc(id).update(updateData);
          _addLog('✓ Updated: $name');
          _updated++;
        } else {
          // Neues Dokument erstellen
          updateData['created_at'] = FieldValue.serverTimestamp();
          await collection.doc(id).set(updateData);
          _addLog('+ Created: $name');
          _created++;
        }
      } on Exception catch (e) {
        _addLog('✗ Failed: $name - $e');
        _failed++;
      }
    }

    _addLog('');
    _addLog('════════════════════════════════════════');
    _addLog('SYNC COMPLETE');
    _addLog('════════════════════════════════════════');
    _addLog('Updated: $_updated');
    _addLog('Created: $_created');
    _addLog('Failed:  $_failed');

    setState(() => _running = false);
  }

  void _addLog(String message) {
    setState(() => _log.add(message));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'POI Sync Tool',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dieses Tool synchronisiert alle korrigierten POI-Daten '
                    '(Name, Beschreibung, Adresse, Koordinaten) nach Firebase.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _running ? null : _runSync,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: _running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_upload),
            label: Text(_running ? 'Syncing...' : 'Start Sync'),
          ),
          const SizedBox(height: 16),
          Text(
            'Log:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (context, index) {
                  final line = _log[index];
                  Color color = Colors.grey.shade300;
                  if (line.startsWith('✓')) color = Colors.greenAccent;
                  if (line.startsWith('+')) color = Colors.cyanAccent;
                  if (line.startsWith('✗')) color = Colors.redAccent;
                  if (line.contains('════')) color = Colors.amber;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
