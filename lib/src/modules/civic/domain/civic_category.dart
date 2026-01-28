import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';

/// Kategorie der öffentlichen/sozialen Einrichtung
enum CivicCategory {
  government('Behörde', Icons.account_balance, MshColors.categoryGovernment),
  youthCentre('Jugendzentrum', Icons.group, MshColors.categoryYouthCentre),
  socialFacility('Soziale Einrichtung', Icons.volunteer_activism, MshColors.categorySocialFacility);

  const CivicCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Konvertiert JSON type zu CivicCategory
  static CivicCategory fromString(String? type) {
    if (type == null) return CivicCategory.socialFacility;

    const typeMap = {
      'townhall': CivicCategory.government,
      'government_office': CivicCategory.government,
      'government': CivicCategory.government,
      'youth_centre': CivicCategory.youthCentre,
      'community_centre': CivicCategory.youthCentre,
      'social_facility': CivicCategory.socialFacility,
      'senior_meeting': CivicCategory.socialFacility,
    };

    return typeMap[type] ?? CivicCategory.socialFacility;
  }
}

/// Zielgruppe der Einrichtung
enum TargetAudience {
  all('Alle'),
  youth('Jugend'),
  seniors('Senioren');

  const TargetAudience(this.label);

  final String label;

  static TargetAudience fromString(String? value) {
    if (value == null) return TargetAudience.all;
    return switch (value.toLowerCase()) {
      'jugend' || 'youth' => TargetAudience.youth,
      'senioren' || 'seniors' => TargetAudience.seniors,
      _ => TargetAudience.all,
    };
  }
}
