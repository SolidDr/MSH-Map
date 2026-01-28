import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';

/// Kategorie des Nachtleben-Venues
enum NightlifeCategory {
  pub('Pub', Icons.sports_bar, MshColors.categoryNightlife),
  bar('Bar', Icons.local_bar, MshColors.categoryNightlife),
  cocktailbar('Cocktailbar', Icons.wine_bar, MshColors.categoryNightlife),
  club('Club/Disco', Icons.nightlife, MshColors.categoryNightlife);

  const NightlifeCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Konvertiert JSON type zu NightlifeCategory
  static NightlifeCategory fromString(String? type) {
    if (type == null) return NightlifeCategory.bar;

    const typeMap = {
      'pub': NightlifeCategory.pub,
      'bar': NightlifeCategory.bar,
      'cocktailbar': NightlifeCategory.cocktailbar,
      'club': NightlifeCategory.club,
      'disco': NightlifeCategory.club,
      'nightclub': NightlifeCategory.club,
    };

    return typeMap[type.toLowerCase()] ?? NightlifeCategory.bar;
  }
}
