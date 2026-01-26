import 'dart:convert';
import 'package:flutter/services.dart';

/// Schneller Test zum Laden der Analytics-Daten
/// Run mit: dart run lib/src/tools/test_analytics_loading.dart
Future<void> main() async {
  print('\n🧪 Testing Analytics Assets Loading...\n');

  try {
    // Load analytics.json
    print('📂 Loading analytics.json...');
    final analyticsJson = await rootBundle.loadString('lib/assets/data/analytics.json');
    final analytics = jsonDecode(analyticsJson) as Map<String, dynamic>;

    final overview = analytics['overview'] as Map<String, dynamic>;
    final topCategories = analytics['top_categories'] as List<dynamic>;
    final topCities = analytics['top_cities'] as List<dynamic>;

    print('✅ Analytics loaded successfully!\n');
    print('📊 Overview:');
    print('   • Locations: ${overview['total_locations']}');
    print('   • Cities: ${overview['total_cities']}');
    print('   • Categories: ${overview['total_categories']}\n');

    print('🏆 Top 5 Categories:');
    for (var i = 0; i < 5 && i < topCategories.length; i++) {
      final item = topCategories[i] as List<dynamic>;
      print('   ${i + 1}. ${item[0]} (${item[1]})');
    }

    print('\n🏙️ Top 5 Cities:');
    for (var i = 0; i < 5 && i < topCities.length; i++) {
      final item = topCities[i] as List<dynamic>;
      print('   ${i + 1}. ${item[0]} (${item[1]})');
    }

    // Load locations.json
    print('\n📍 Loading locations.json...');
    final locationsJson = await rootBundle.loadString('lib/assets/data/locations.json');
    final locations = jsonDecode(locationsJson) as Map<String, dynamic>;

    print('✅ Locations loaded successfully!');
    print('   • Total: ${locations.length} location entries\n');

    // Show first location
    if (locations.isNotEmpty) {
      final firstKey = locations.keys.first;
      final firstLocation = locations[firstKey] as Map<String, dynamic>;
      print('📍 Sample Location:');
      print('   • ID: $firstKey');
      print('   • Name: ${firstLocation['name']}');
      print('   • City: ${firstLocation['city']}');
      print('   • Category: ${firstLocation['category']}\n');
    }

    print('✨ All tests passed!\n');
  } catch (e) {
    print('❌ Error: $e\n');
    rethrow;
  }
}
