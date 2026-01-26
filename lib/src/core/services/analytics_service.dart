import 'dart:convert';
import 'package:flutter/services.dart';

/// Service für das Laden und Caching von Analytics-Daten
class AnalyticsService {
  static Map<String, dynamic>? _cachedData;

  /// Lädt Analytics-Daten aus Assets
  static Future<Map<String, dynamic>> loadAnalytics() async {
    if (_cachedData != null) return _cachedData!;

    final jsonString = await rootBundle.loadString('lib/assets/data/analytics.json');
    _cachedData = jsonDecode(jsonString) as Map<String, dynamic>;
    return _cachedData!;
  }

  /// Gibt gecachte Analytics zurück oder lädt sie neu
  static Future<Map<String, dynamic>> getAnalytics() async {
    return _cachedData ?? await loadAnalytics();
  }

  /// Cache zurücksetzen (z.B. bei Tests)
  static void clearCache() {
    _cachedData = null;
  }
}
