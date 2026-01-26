import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/domain/map_item.dart';

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
