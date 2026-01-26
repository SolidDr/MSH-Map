import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// Beispiel: "3-12" überschneidet sich mit "6-12" → true
bool _rangesOverlap(String range1, String range2) {
  if (range1 == 'alle' || range2 == 'alle') return true;

  final parsed1 = _parseAgeRange(range1);
  final parsed2 = _parseAgeRange(range2);

  if (parsed1 == null || parsed2 == null) return false;

  // Überlappung wenn: min1 <= max2 && min2 <= max1
  return parsed1.$1 <= parsed2.$2 && parsed2.$1 <= parsed1.$2;
}

// ═══════════════════════════════════════════════════════════════
// FILTER STATE
// ═══════════════════════════════════════════════════════════════

/// Filter State
class FilterState {
  final Set<String> categories;
  final Set<String> activeFilterIds;

  const FilterState({
    this.categories = const {},
    this.activeFilterIds = const {},
  });

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
    // Kategorie-Filter
    if (categories.isNotEmpty &&
        !categories.contains(item.category.name)) {
      return false;
    }

    // Altersfilter
    final ageFilters = activeFilterIds
        .where((id) => id.startsWith('age_'))
        .map((id) => id.replaceFirst('age_', ''))
        .toSet();

    if (ageFilters.isNotEmpty) {
      final ageRange = item.metadata['ageRange'] as String?;
      if (ageRange != null) {
        // "alle" passt immer
        if (ageRange == 'alle') return true;

        // Prüfe Überlappung mit ausgewählten Altersfiltern
        final matches = ageFilters.any((filter) => _rangesOverlap(ageRange, filter));
        if (!matches) return false;
      }
    }

    return true;
  }

  bool get hasActiveFilters =>
      categories.isNotEmpty || activeFilterIds.isNotEmpty;
}

/// Filter Notifier
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void toggleCategory(String category) {
    final newCategories = Set<String>.from(state.categories);
    if (newCategories.contains(category)) {
      newCategories.remove(category);
    } else {
      newCategories.add(category);
    }
    state = state.copyWith(categories: newCategories);
  }

  void setCategories(Set<String> categories) {
    state = state.copyWith(categories: categories);
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
  }
}

/// Provider
final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
