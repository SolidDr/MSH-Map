// ignore_for_file: avoid_print
/// Update-Script für POI-Koordinaten in Firestore
///
/// Aktualisiert nur die Koordinaten aller existierenden POIs
/// Run with: flutter run -t lib/src/tools/update_poi_coords.dart
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../../../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // Load JSON file
  final file = File('msh_data_seed.json');
  if (!file.existsSync()) {
    print('ERROR: msh_data_seed.json not found!');
    print('Make sure you run this from the project root directory.');
    exit(1);
  }

  final jsonString = await file.readAsString();
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  final data = json['data'] as List<dynamic>;

  print('=== POI Coordinates Update Tool ===');
  print('');
  print('Found ${data.length} POIs to update...');
  print('');

  final collection = firestore.collection('pois');

  var updated = 0;
  var created = 0;
  var failed = 0;

  for (final item in data) {
    final itemData = item as Map<String, dynamic>;
    final id = itemData['id'] as String;
    final name = itemData['name'] as String;
    final lat = (itemData['latitude'] as num).toDouble();
    final lng = (itemData['longitude'] as num).toDouble();

    try {
      final existing = await collection.doc(id).get();

      if (existing.exists) {
        // Update only location
        await collection.doc(id).update({
          'location': GeoPoint(lat, lng),
          'updated_at': FieldValue.serverTimestamp(),
        });
        print('✓ Updated: $name');
        print('  → $lat, $lng');
        updated++;
      } else {
        // Create new document if it doesn't exist
        final doc = <String, dynamic>{
          'name': itemData['name'],
          'description': itemData['description'],
          'category': itemData['category'],
          'address': itemData['address'],
          'city': itemData['city'],
          'location': GeoPoint(lat, lng),
          'tags': itemData['tags'] ?? <String>[],
          'website': itemData['website'],
          'is_free': itemData['is_free'] ?? false,
          'is_indoor': itemData['is_indoor'] ?? false,
          'is_outdoor': itemData['is_outdoor'] ?? true,
          'is_barrier_free': itemData['is_barrier_free'] ?? false,
          'age_range': itemData['age_range'] ?? 'alle',
          'activity_type': itemData['activity_type'],
          'opening_hours': itemData['opening_hours'],
          'price_info': itemData['price_info'],
          'contact_phone': itemData['contact_phone'],
          'contact_email': itemData['contact_email'],
          'facilities': itemData['facilities'] ?? <String>[],
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        doc.removeWhere((key, value) => value == null);

        await collection.doc(id).set(doc);
        print('✓ Created: $name');
        print('  → $lat, $lng');
        created++;
      }
    } on Exception catch (e) {
      print('✗ Failed: $name - $e');
      failed++;
    }
  }

  print('');
  print('============================');
  print('Update complete!');
  print('Updated: $updated');
  print('Created: $created');
  print('Failed: $failed');
  print('============================');

  exit(0);
}
