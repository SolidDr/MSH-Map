import 'package:flutter/material.dart';

/// Kategorien für Wanderwege
enum WanderwegCategory {
  /// Fernwanderwege (> 50km, mehrtägig)
  fernwanderweg,

  /// Rundwanderwege (Tagestouren)
  rundwanderweg,

  /// Themenwanderwege (historisch/kulturell)
  themenwanderweg,

  /// Naturerlebnis-Wege
  naturerlebnis,

  /// Familientouren (kinderwagen-geeignet)
  familientour,
}

extension WanderwegCategoryExtension on WanderwegCategory {
  String get label {
    switch (this) {
      case WanderwegCategory.fernwanderweg:
        return 'Fernwanderweg';
      case WanderwegCategory.rundwanderweg:
        return 'Rundwanderweg';
      case WanderwegCategory.themenwanderweg:
        return 'Themenwanderweg';
      case WanderwegCategory.naturerlebnis:
        return 'Naturerlebnis';
      case WanderwegCategory.familientour:
        return 'Familientour';
    }
  }

  IconData get icon {
    switch (this) {
      case WanderwegCategory.fernwanderweg:
        return Icons.route;
      case WanderwegCategory.rundwanderweg:
        return Icons.loop;
      case WanderwegCategory.themenwanderweg:
        return Icons.museum;
      case WanderwegCategory.naturerlebnis:
        return Icons.forest;
      case WanderwegCategory.familientour:
        return Icons.family_restroom;
    }
  }

  Color get color {
    switch (this) {
      case WanderwegCategory.fernwanderweg:
        return const Color(0xFF1B5E20); // Dunkelgrün
      case WanderwegCategory.rundwanderweg:
        return const Color(0xFF4CAF50); // Grün
      case WanderwegCategory.themenwanderweg:
        return const Color(0xFF8D6E63); // Braun
      case WanderwegCategory.naturerlebnis:
        return const Color(0xFF2E7D32); // Waldgrün
      case WanderwegCategory.familientour:
        return const Color(0xFF81C784); // Mintgrün
    }
  }
}
