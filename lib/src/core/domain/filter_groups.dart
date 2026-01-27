/// MSH Map - Filter-Gruppen Definition
///
/// Definiert die hierarchischen Filter-Gruppen für den Entdecken-Screen
/// basierend auf dem Golden Ratio Prinzip: max 3-5 Items pro Gruppe
library;

import 'package:flutter/material.dart';
import '../../shared/domain/map_item.dart';
import '../theme/msh_colors.dart';

/// Filter-Kategorie mit Metadaten
class FilterCategory {
  const FilterCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.mapCategories,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final List<MapItemCategory> mapCategories;
}

/// Filter-Gruppe (max 5 Kategorien pro Gruppe)
class FilterGroup {
  const FilterGroup({
    required this.id,
    required this.title,
    required this.icon,
    required this.categories,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<FilterCategory> categories;
}

/// Vordefinierte Filter-Gruppen
class FilterGroups {
  FilterGroups._();

  // ═══════════════════════════════════════════════════════════════
  // GASTRONOMIE (4 Kategorien)
  // ═══════════════════════════════════════════════════════════════
  static const gastroGroup = FilterGroup(
    id: 'gastro',
    title: 'Gastronomie',
    icon: Icons.restaurant,
    categories: [
      FilterCategory(
        id: 'restaurant',
        label: 'Restaurants',
        icon: Icons.restaurant,
        color: MshColors.primary,
        mapCategories: [MapItemCategory.restaurant],
      ),
      FilterCategory(
        id: 'cafe',
        label: 'Cafés',
        icon: Icons.local_cafe,
        color: MshColors.primaryLight,
        mapCategories: [MapItemCategory.cafe],
      ),
      FilterCategory(
        id: 'imbiss',
        label: 'Imbiss',
        icon: Icons.fastfood,
        color: MshColors.engagementElevated,
        mapCategories: [MapItemCategory.imbiss],
      ),
      FilterCategory(
        id: 'bar',
        label: 'Bars',
        icon: Icons.local_bar,
        color: MshColors.engagementUrgent,
        mapCategories: [MapItemCategory.bar],
      ),
    ],
  );

  // ═══════════════════════════════════════════════════════════════
  // FAMILIE & FREIZEIT (5 Kategorien - Maximum)
  // ═══════════════════════════════════════════════════════════════
  static const familyGroup = FilterGroup(
    id: 'family',
    title: 'Familie & Freizeit',
    icon: Icons.family_restroom,
    categories: [
      FilterCategory(
        id: 'playground',
        label: 'Spielplätze',
        icon: Icons.child_friendly,
        color: MshColors.info,
        mapCategories: [MapItemCategory.playground],
      ),
      FilterCategory(
        id: 'nature',
        label: 'Natur & Parks',
        icon: Icons.park,
        color: MshColors.success,
        mapCategories: [MapItemCategory.nature],
      ),
      FilterCategory(
        id: 'pool',
        label: 'Schwimmbäder',
        icon: Icons.pool,
        color: MshColors.info,
        mapCategories: [MapItemCategory.pool],
      ),
      FilterCategory(
        id: 'museum',
        label: 'Museen',
        icon: Icons.museum,
        color: MshColors.engagementElevated,
        mapCategories: [MapItemCategory.museum],
      ),
      FilterCategory(
        id: 'adventure',
        label: 'Erlebnis',
        icon: Icons.attractions,
        color: MshColors.engagementUrgent,
        mapCategories: [
          MapItemCategory.adventure,
          MapItemCategory.zoo,
          MapItemCategory.farm,
          MapItemCategory.castle,
        ],
      ),
    ],
  );

  // ═══════════════════════════════════════════════════════════════
  // KULTUR & EVENTS (3 Kategorien)
  // ═══════════════════════════════════════════════════════════════
  static const cultureGroup = FilterGroup(
    id: 'culture',
    title: 'Kultur & Events',
    icon: Icons.theater_comedy,
    categories: [
      FilterCategory(
        id: 'event',
        label: 'Veranstaltungen',
        icon: Icons.event,
        color: MshColors.engagementCritical,
        mapCategories: [MapItemCategory.event],
      ),
      FilterCategory(
        id: 'culture',
        label: 'Kultur',
        icon: Icons.palette,
        color: MshColors.primaryStrong,
        mapCategories: [MapItemCategory.culture],
      ),
      FilterCategory(
        id: 'sport',
        label: 'Sport',
        icon: Icons.sports_soccer,
        color: MshColors.success,
        mapCategories: [MapItemCategory.sport],
      ),
    ],
  );

  // ═══════════════════════════════════════════════════════════════
  // SERVICES (3 Kategorien)
  // ═══════════════════════════════════════════════════════════════
  static const serviceGroup = FilterGroup(
    id: 'service',
    title: 'Services & Hilfe',
    icon: Icons.support_agent,
    categories: [
      FilterCategory(
        id: 'indoor',
        label: 'Indoor',
        icon: Icons.home,
        color: MshColors.info,
        mapCategories: [MapItemCategory.indoor],
      ),
      FilterCategory(
        id: 'service',
        label: 'Dienstleistungen',
        icon: Icons.miscellaneous_services,
        color: MshColors.textSecondary,
        mapCategories: [MapItemCategory.service],
      ),
      FilterCategory(
        id: 'other',
        label: 'Sonstiges',
        icon: Icons.more_horiz,
        color: MshColors.textMuted,
        mapCategories: [MapItemCategory.custom, MapItemCategory.search],
      ),
    ],
  );

  /// Alle Filter-Gruppen
  static const List<FilterGroup> all = [
    gastroGroup,
    familyGroup,
    cultureGroup,
    serviceGroup,
  ];

  /// Flache Liste aller Kategorien
  static List<FilterCategory> get allCategories {
    return all.expand((group) => group.categories).toList();
  }

  /// Finde Kategorie by ID
  static FilterCategory? findCategory(String id) {
    for (final group in all) {
      for (final cat in group.categories) {
        if (cat.id == id) return cat;
      }
    }
    return null;
  }
}
