// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../../../firebase_options.dart';

/// One-time script to import seed data into Firestore.
///
/// Run with: flutter run -t lib/src/tools/seed_import.dart
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

  print('Found ${data.length} items to import...');
  print('');

  // Collection for family activities / POIs
  final collection = firestore.collection('pois');

  var imported = 0;
  var skipped = 0;

  for (final item in data) {
    final itemData = item as Map<String, dynamic>;
    final id = itemData['id'] as String;
    final name = itemData['name'] as String;

    // Check if already exists
    final existing = await collection.doc(id).get();
    if (existing.exists) {
      print('SKIP: $name (already exists)');
      skipped++;
      continue;
    }

    // Prepare Firestore document
    final doc = <String, dynamic>{
      'name': itemData['name'],
      'description': itemData['description'],
      'category': itemData['category'],
      'address': itemData['address'],
      'city': itemData['city'],
      'location': GeoPoint(
        (itemData['latitude'] as num).toDouble(),
        (itemData['longitude'] as num).toDouble(),
      ),
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

    // Remove null values
    doc.removeWhere((key, value) => value == null);

    await collection.doc(id).set(doc);
    print('OK: $name');
    imported++;
  }

  print('');
  print('============================');
  print('Import complete!');
  print('Imported: $imported');
  print('Skipped: $skipped');
  print('============================');

  exit(0);
}
