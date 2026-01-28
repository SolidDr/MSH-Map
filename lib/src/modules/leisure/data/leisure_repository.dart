import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/pool.dart';

/// Repository für Freizeit-Einrichtungen (Schwimmbäder, etc.)
class LeisureRepository {
  List<Pool>? _cachedPools;

  /// Lädt alle Schwimmbäder aus den Assets
  Future<List<Pool>> loadPools() async {
    if (_cachedPools != null) return _cachedPools!;

    final pools = <Pool>[];

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/leisure/pools.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final poolList = data['data'] as List<dynamic>;

      for (final json in poolList) {
        try {
          pools.add(Pool.fromJson(json as Map<String, dynamic>));
        } on FormatException {
          // Skip invalid entries
        }
      }
    } on Exception {
      // File not found or parse error
    }

    _cachedPools = pools;
    return pools;
  }

  /// Cache leeren
  void clearCache() {
    _cachedPools = null;
  }
}
