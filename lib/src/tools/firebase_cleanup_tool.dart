// ignore_for_file: avoid_print
/// Firebase Firestore Cleanup Tool
///
/// Entfernt alle nicht-verifizierten Locations aus Firebase Firestore.
/// Run with: flutter run -t lib/src/tools/firebase_cleanup_tool.dart -d chrome
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../firebase_options.dart';

/// Bekannte Fake-IDs (aus fake_checker.py)
const knownFakes = <String>[
  'kinderland-indoor',
  'cafe-rosenduft',
  'kletterwald-questenberg',
  'fussballgolf-questenberg',
  'erlebnisbauernhof-stolberg',
  'naturbad-questenberg',
  'minigolf-sangerhausen',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FirebaseCleanupApp());
}

class FirebaseCleanupApp extends StatelessWidget {
  const FirebaseCleanupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Cleanup Tool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Firestore Cleanup'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const CleanupScreen(),
      ),
    );
  }
}

class CleanupScreen extends StatefulWidget {
  const CleanupScreen({super.key});

  @override
  State<CleanupScreen> createState() => _CleanupScreenState();
}

class _CleanupScreenState extends State<CleanupScreen> {
  final _log = <String>[];
  var _running = false;
  var _deleted = 0;
  var _kept = 0;
  Set<String> _validIds = {};

  @override
  void initState() {
    super.initState();
    _loadValidIds();
  }

  Future<void> _loadValidIds() async {
    try {
      final jsonString =
          await rootBundle.loadString('lib/assets/data/locations.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>;

      _validIds = data.map((e) => (e as Map<String, dynamic>)['id'] as String).toSet();

      _addLog('[OK] ${_validIds.length} verifizierte Location-IDs geladen');
    } on Exception catch (e) {
      _addLog('[X] Fehler beim Laden: $e');
    }
  }

  Future<void> _runCleanup() async {
    setState(() {
      _running = true;
      _log.clear();
      _deleted = 0;
      _kept = 0;
    });

    _addLog('================================================');
    _addLog('FIREBASE FIRESTORE CLEANUP');
    _addLog('================================================');
    _addLog('');

    await _cleanupCollection('locations');
    await _cleanupCollection('pois');

    _addLog('');
    _addLog('================================================');
    _addLog('ERGEBNIS');
    _addLog('================================================');
    _addLog('Behalten: $_kept');
    _addLog('Geloescht: $_deleted');
    _addLog('================================================');
    _addLog('[OK] Firebase Cleanup abgeschlossen!');

    setState(() => _running = false);
  }

  Future<void> _cleanupCollection(String collectionName) async {
    _addLog('[>] Bereinige Collection: $collectionName');

    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection(collectionName).get();
    _addLog('    ${snapshot.size} Dokumente gefunden');

    var localDeleted = 0;
    var localKept = 0;

    for (final doc in snapshot.docs) {
      final id = doc.id;
      final data = doc.data();
      final name = data['name'] as String? ?? id;

      // Pruefen ob Fake oder nicht in valider Liste
      final isFake = knownFakes.contains(id);
      final isValid = _validIds.contains(id);

      // Auch pruefen nach source: 'unknown' ohne OSM/Wikidata Verification
      final source = data['source'] as String? ?? '';
      final sourceId = data['sourceId'] as String? ?? '';
      final hasNoSource = source.isEmpty || source == 'unknown';
      final hasNoSourceId = sourceId.isEmpty;

      // Nur loeschen wenn: Fake ODER (nicht valid UND keine Quelle)
      if (isFake) {
        _addLog('    [DEL] $name (FAKE)');
        await doc.reference.delete();
        localDeleted++;
        _deleted++;
      } else if (!isValid && hasNoSource && hasNoSourceId) {
        _addLog('    [DEL] $name (no source)');
        await doc.reference.delete();
        localDeleted++;
        _deleted++;
      } else {
        localKept++;
        _kept++;
      }
    }

    _addLog('    [OK] $localKept behalten, $localDeleted geloescht');
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
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'ACHTUNG: Firestore Cleanup',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dieses Tool entfernt alle nicht-verifizierten Locations '
                    'und bekannte Fake-Eintraege aus Firebase Firestore.\n\n'
                    'Es werden ALLE Eintraege geloescht, die:\n'
                    '- In der Fake-Liste stehen\n'
                    '- Keine gueltige OSM/Wikidata-Quelle haben\n'
                    '- Nicht in der bereinigten locations.json sind',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Verifizierte IDs geladen: ${_validIds.length}'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _running || _validIds.isEmpty ? null : _runCleanup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
                : const Icon(Icons.delete_sweep),
            label: Text(_running ? 'Cleaning...' : 'Start Cleanup'),
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
                  if (line.startsWith('[OK]')) color = Colors.greenAccent;
                  if (line.startsWith('[DEL]') || line.contains('[DEL]')) {
                    color = Colors.redAccent;
                  }
                  if (line.startsWith('[X]')) color = Colors.redAccent;
                  if (line.startsWith('[>]')) color = Colors.cyanAccent;
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
