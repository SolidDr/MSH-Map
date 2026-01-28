// ignore_for_file: avoid_print
/// Web-kompatibles Update-Script für POI-Koordinaten
///
/// Run with: flutter run -t lib/src/tools/update_coords_web.dart -d chrome
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';

/// Koordinaten-Updates aus msh_data_seed.json (geocodiert via Nominatim)
const coordUpdates = <String, (double, double)>{
  'a1ebbd930a8f': (51.4744, 11.3113), // Europa-Rosarium Sangerhausen
  '6cde51fe78b6': (51.4784, 11.2943), // Spengler-Museum Sangerhausen
  'dfdd97350e63': (51.4537, 11.3025), // Erlebnisbad Sangerhausen
  '951f251e09fc': (51.4715, 11.3055), // Stadtpark Sangerhausen
  'e9369f00189b': (51.5268, 11.5501), // Luthers Geburtshaus
  '7b738ecffbb2': (51.5281, 11.5443), // Luthers Sterbehaus
  '1db418ba25cb': (51.5285, 11.5427), // Knappenbrunnen Eisleben
  '1954ae4fca7e': (51.5189, 11.4308), // Bergbaumuseum Röhrigschacht
  '61d92b1c1015': (51.6258, 11.5124), // Mansfeld-Museum Hettstedt
  'a0e83a7a56be': (51.6469, 11.5137), // Saigertor Hettstedt
  '0c8f3c88380a': (51.6523, 11.5199), // Freibad Hettstedt
  '4f140a84718b': (51.5936, 11.4577), // Schloss Mansfeld
  'b59655bcd20f': (51.5938, 11.4537), // Luthers Elternhaus Mansfeld
  '9b72398721ee': (51.5734, 10.9519), // Historische Altstadt Stolberg
  '0a416be8510b': (51.5748, 10.9544), // Schloss Stolberg
  '860d6327449b': (51.5806, 11.0057), // Josephskreuz
  '5be16aec5f4f': (51.5603, 11.0833), // Wippertalsperre
  'eee6f07a5d32': (51.4970, 10.9547), // Heimkehle Uftrungen
  '24ddf657633c': (51.4844, 11.0325), // Questenberg mit Queste
  '456b4954d79a': (51.5185, 10.9474), // Thyragrotte Rottleberode
  '6d7a53c523db': (51.4963, 11.6734), // Süßer See
  '98f00ff1923e': (51.4911, 11.6989), // Schloss Seeburg
  '49f576f8cc8d': (51.8358, 11.4027), // Concordia See
  'abb075adbee5': (51.6355, 11.6245), // Schloss Gerbstedt
  '6e634bd77c3f': (51.4079, 11.4018), // Burg und Schloss Allstedt
  '0fd9c7744e9e': (51.6819, 11.2651), // Burg Falkenstein
  '241fca2a5975': (51.6875, 11.2735), // Selketal
  'a62ae6b0a729': (51.3770, 11.5938), // Burg Querfurt
  '61478d6bb40c': (51.4199, 11.1402), // Kyffhäuser-Denkmal
  '5f7abcc9a930': (51.7341, 11.0398), // Bodetal und Rosstrappe
  '509cd30b0421': (51.7333, 11.0244), // Hexentanzplatz Thale
  '3ff70dd17fb2': (51.6408, 11.1267), // Harzer Schmalspurbahnen
  '413e32241076': (51.7017, 10.8686), // Pullman City Harz
  'e9066bb8f5b2': (51.4759, 11.3189), // Abenteuerspielplatz Sangerhausen
  '024bfd8250a1': (51.5222, 11.5491), // Spielplatz Stadtpark Eisleben
  '424cc5730d39': (51.2717, 11.5309), // Arche Nebra
  '9f53b2b5e0f5': (51.4744, 11.3113), // Tiergehege Sangerhausen
  '302570dbd683': (51.5186, 11.5589), // Erlebnisbauernhof Mittelhausen
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CoordUpdateApp());
}

class CoordUpdateApp extends StatelessWidget {
  const CoordUpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('POI Koordinaten Update')),
        body: const CoordUpdateScreen(),
      ),
    );
  }
}

class CoordUpdateScreen extends StatefulWidget {
  const CoordUpdateScreen({super.key});

  @override
  State<CoordUpdateScreen> createState() => _CoordUpdateScreenState();
}

class _CoordUpdateScreenState extends State<CoordUpdateScreen> {
  final _log = <String>[];
  var _running = false;
  var _updated = 0;
  var _failed = 0;

  Future<void> _runUpdate() async {
    setState(() {
      _running = true;
      _log.clear();
      _updated = 0;
      _failed = 0;
    });

    _addLog('Starting coordinate update...');
    _addLog('Found ${coordUpdates.length} POIs to update');
    _addLog('');

    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('pois');

    for (final entry in coordUpdates.entries) {
      final id = entry.key;
      final coords = entry.value;

      try {
        final doc = await collection.doc(id).get();

        if (doc.exists) {
          await collection.doc(id).update({
            'location': GeoPoint(coords.$1, coords.$2),
            'updated_at': FieldValue.serverTimestamp(),
          });
          _addLog('✓ Updated: ${doc.data()?['name'] ?? id}');
          _updated++;
        } else {
          _addLog('⚠ Not found: $id');
          _failed++;
        }
      } on Exception catch (e) {
        _addLog('✗ Error $id: $e');
        _failed++;
      }
    }

    _addLog('');
    _addLog('=== Complete ===');
    _addLog('Updated: $_updated');
    _addLog('Failed: $_failed');

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
          ElevatedButton.icon(
            onPressed: _running ? null : _runUpdate,
            icon: _running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload),
            label: Text(_running ? 'Updating...' : 'Start Update'),
          ),
          const SizedBox(height: 16),
          Text(
            'Log:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (context, index) => Text(
                  _log[index],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
