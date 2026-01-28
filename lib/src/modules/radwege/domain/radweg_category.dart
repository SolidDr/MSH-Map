import 'package:flutter/material.dart';

/// Kategorien für Radwege
enum RadwegCategory {
  /// Fernradwege (überregional, > 50km)
  fernradweg,

  /// Regionale Rundwege (< 50km)
  rundweg,

  /// Themenradwege (z.B. Industriekultur, Romanik)
  themenweg,

  /// Flussradwege
  flussradweg,
}

extension RadwegCategoryExtension on RadwegCategory {
  String get label {
    switch (this) {
      case RadwegCategory.fernradweg:
        return 'Fernradweg';
      case RadwegCategory.rundweg:
        return 'Rundweg';
      case RadwegCategory.themenweg:
        return 'Themenweg';
      case RadwegCategory.flussradweg:
        return 'Flussradweg';
    }
  }

  IconData get icon {
    switch (this) {
      case RadwegCategory.fernradweg:
        return Icons.route;
      case RadwegCategory.rundweg:
        return Icons.loop;
      case RadwegCategory.themenweg:
        return Icons.museum;
      case RadwegCategory.flussradweg:
        return Icons.water;
    }
  }

  Color get color {
    switch (this) {
      case RadwegCategory.fernradweg:
        return const Color(0xFF2196F3); // Blau
      case RadwegCategory.rundweg:
        return const Color(0xFF4CAF50); // Grün
      case RadwegCategory.themenweg:
        return const Color(0xFFB87333); // Kupfer
      case RadwegCategory.flussradweg:
        return const Color(0xFF00BCD4); // Cyan
    }
  }
}
