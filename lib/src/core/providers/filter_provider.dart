import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/domain/map_item.dart';

// ═══════════════════════════════════════════════════════════════
// HILFSFUNKTIONEN FÜR ALTERSFILTER
// ═══════════════════════════════════════════════════════════════

/// Parst einen Altersbereich-String zu (min, max)
/// Beispiele: "6-12" → (6, 12), "12+" → (12, 999), "alle" → null
(int, int)? _parseAgeRange(String range) {
  if (range == 'alle') return null; // "alle" = kein Filter
  if (range.endsWith('+')) {
    final min = int.tryParse(range.replaceAll('+', ''));
    return min != null ? (min, 999) : null;
  }
  final parts = range.split('-');
  if (parts.length == 2) {
    final min = int.tryParse(parts[0]);
    final max = int.tryParse(parts[1]);
    return (min != null && max != null) ? (min, max) : null;
  }
  return null;
}

/// Prüft ob zwei Altersbereiche sich überschneiden
/// Verwendet half-open intervals [min, max) für exakte Gruppierung
/// Beispiel: "3-12" überschneidet sich mit "6-12" → true
/// Aber: "0-3" und "3-6" überschneiden sich NICHT (grenzen nur aneinander)
bool _rangesOverlap(String range1, String range2) {
  if (range1 == 'alle' || range2 == 'alle') return true;

  final parsed1 = _parseAgeRange(range1);
  final parsed2 = _parseAgeRange(range2);

  if (parsed1 == null || parsed2 == null) return false;

  // Half-open intervals: [min1, max1) overlaps [min2, max2) wenn min1 < max2 && min2 < max1
  return parsed1.$1 < parsed2.$2 && parsed2.$1 < parsed1.$2;
}

// ═══════════════════════════════════════════════════════════════
// KATEGORIE-GRUPPEN
// ═══════════════════════════════════════════════════════════════

/// Gruppen von Kategorien für zusammengefasste Filter
const Map<String, Set<String>> categoryGroups = {
  // "Natur" umfasst alle Natur-Unterkategorien
  'nature': {'nature', 'viewpoint', 'waterfall', 'cave'},
  // "Essen" umfasst alle Gastro-Kategorien
  'restaurant': {
    'restaurant',
    'cafe',
    'imbiss',
    'biergarten',
    'pub',
    'bar',
    'eiscafe',
    'baeckerei',
    'fleischerei',
    'konditorei',
    'feinkost',
    'hofladen',
  },
  // "Bildung" umfasst Schulen, Kitas, Bibliotheken
  'education': {'school', 'kindergarten', 'library'},
  // "Civic/Service" umfasst Behörden, Jugendzentren, Soziales
  'civic': {'government', 'youthCentre', 'socialFacility'},
};

/// Filter-Kategorien die über moduleId statt category matchen
const Set<String> moduleIdFilters = {'health'};

/// Prüft ob eine Kategorie zum Filter passt (inkl. Gruppen)
bool _categoryMatchesFilter(String itemCategory, String filterCategory) {
  // Direkte Übereinstimmung
  if (itemCategory == filterCategory) return true;

  // Gruppen-Übereinstimmung: Filter ist Gruppe, Item ist Member
  final group = categoryGroups[filterCategory];
  if (group != null && group.contains(itemCategory)) return true;

  return false;
}

/// Prüft ob ein Item zum Filter passt (inkl. moduleId-Filter)
bool _itemMatchesFilter(MapItem item, String filterCategory) {
  // ModuleId-Filter (z.B. 'health' matched moduleId 'health')
  if (moduleIdFilters.contains(filterCategory)) {
    return item.moduleId == filterCategory;
  }

  // Standard Kategorie-Filter
  return _categoryMatchesFilter(item.category.name, filterCategory);
}

// ═══════════════════════════════════════════════════════════════
// FILTER STATE
// ═══════════════════════════════════════════════════════════════

/// Filter State
class FilterState {

  const FilterState({
    this.categories = const {},
    this.activeFilterIds = const {},
  });
  final Set<String> categories;
  final Set<String> activeFilterIds;

  FilterState copyWith({
    Set<String>? categories,
    Set<String>? activeFilterIds,
  }) {
    return FilterState(
      categories: categories ?? this.categories,
      activeFilterIds: activeFilterIds ?? this.activeFilterIds,
    );
  }

  bool matches(MapItem item) {
    // Kategorie-Filter (mit Gruppen-Support und moduleId-Filter)
    if (categories.isNotEmpty) {
      final matchesAny = categories.any(
        (filterCat) => _itemMatchesFilter(item, filterCat),
      );
      if (!matchesAny) return false;
    }

    // Altersfilter
    final ageFilters = activeFilterIds
        .where((id) => id.startsWith('age_'))
        .map((id) => id.replaceFirst('age_', ''))
        .toSet();

    if (ageFilters.isNotEmpty) {
      final ageRange = item.metadata['ageRange'] as String?;

      // Items ohne ageRange werden als "für alle Altersgruppen" behandelt
      // (z.B. Spielplätze ohne spezifische Altersangabe)
      if (ageRange == null || ageRange == 'alle') return true;

      // Prüfe Überlappung mit ausgewählten Altersfiltern
      final matches = ageFilters.any((filter) => _rangesOverlap(ageRange, filter));
      if (!matches) return false;
    }

    // Health-Filter (Kategorie und Fachrichtung)
    final healthFilters = activeFilterIds
        .where((id) => id.startsWith('health_'))
        .map((id) => id.replaceFirst('health_', ''))
        .toSet();

    if (healthFilters.isNotEmpty && item.moduleId == 'health') {
      // Kategorie-Filter (doctor, pharmacy, fitness)
      final categoryFilters = healthFilters
          .where((f) => !f.startsWith('spec_'))
          .toSet();

      // Fachrichtungs-Filter (spec_allgemein, spec_kardio, etc.)
      final specFilters = healthFilters
          .where((f) => f.startsWith('spec_'))
          .map((f) => f.replaceFirst('spec_', ''))
          .toSet();

      final itemHealthCategory = item.metadata['healthCategory'] as String?;
      final itemSpecialization = item.metadata['specialization'] as String?;

      // Wenn Kategorie-Filter aktiv: prüfe ob Item passt
      if (categoryFilters.isNotEmpty) {
        if (itemHealthCategory == null || !categoryFilters.contains(itemHealthCategory)) {
          // Ausnahme: Wenn Fachrichtungs-Filter aktiv und Item ist Arzt
          if (specFilters.isEmpty || itemHealthCategory != 'doctor') {
            return false;
          }
        }
      }

      // Wenn Fachrichtungs-Filter aktiv: prüfe ob Arzt mit passender Fachrichtung
      if (specFilters.isNotEmpty) {
        if (itemHealthCategory != 'doctor') return false;
        if (itemSpecialization == null || !specFilters.contains(itemSpecialization)) {
          return false;
        }
      }
    }

    return true;
  }

  bool get hasActiveFilters =>
      categories.isNotEmpty || activeFilterIds.isNotEmpty;
}

/// Filter Notifier mit Persistierung
class FilterNotifier extends StateNotifier<FilterState> {

  // Starteinstellung: Leeres Set = alle Kategorien sichtbar
  FilterNotifier() : super(const FilterState()) {
    _loadSavedFilters();
  }
  // SharedPreferences Keys
  static const _keyCategoriesFilter = 'map_filter_categories';

  /// Lädt gespeicherte Filter aus SharedPreferences
  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getStringList(_keyCategoriesFilter);

    if (savedCategories != null) {
      state = state.copyWith(categories: savedCategories.toSet());
    }
    // Wenn nichts gespeichert ist, bleibt das leere Set (alle sichtbar)
  }

  /// Speichert aktuelle Filter in SharedPreferences
  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCategoriesFilter, state.categories.toList());
  }

  void toggleCategory(String category) {
    final newCategories = Set<String>.from(state.categories);
    if (newCategories.contains(category)) {
      newCategories.remove(category);
    } else {
      newCategories.add(category);
    }
    state = state.copyWith(categories: newCategories);
    _saveFilters();
  }

  void setCategories(Set<String> categories) {
    state = state.copyWith(categories: categories);
    _saveFilters();
  }

  void toggleFilter(String filterId) {
    final newFilters = Set<String>.from(state.activeFilterIds);
    if (newFilters.contains(filterId)) {
      newFilters.remove(filterId);
    } else {
      newFilters.add(filterId);
    }
    state = state.copyWith(activeFilterIds: newFilters);
  }

  void clearAll() {
    state = const FilterState();
    _saveFilters();
  }
}

/// Provider
final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
