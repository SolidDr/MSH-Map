/// MSH Map - Entdecken Screen
///
/// Zentraler Hub für:
/// - POI-Kategorien nach Gruppen (max 5 pro Gruppe)
/// - Schnellfilter mit Riverpod
/// - Navigation zur Karte mit aktivem Filter
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/map_config.dart';
import '../../../core/domain/filter_groups.dart';
import '../../../core/providers/filter_provider.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../../modules/_module_registry.dart';
import '../../../shared/domain/map_item.dart';
import '../../../shared/widgets/msh_category_card.dart';
import 'widgets/category_pois_bottom_sheet.dart';

/// Entdecken Screen - Kategorien & Filter Hub
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  List<MapItem> _allItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      final allItems = <MapItem>[];
      for (final module in ModuleRegistry.instance.active) {
        final items = await module.getItemsInRegion(MapConfig.mshRegion);
        allItems.addAll(items);
      }

      setState(() {
        _allItems = allItems;
        _isLoading = false;
      });
    } on Exception {
      setState(() => _isLoading = false);
    }
  }

  /// Berechnet die Anzahl der POIs pro FilterCategory
  int _countForCategory(FilterCategory category) {
    return _getItemsForCategory(category).length;
  }

  /// Gibt alle Items für eine FilterCategory zurück
  List<MapItem> _getItemsForCategory(FilterCategory category) {
    return _allItems.where((item) {
      return category.mapCategories.contains(item.category);
    }).toList();
  }

  /// Zeigt die POI-Liste für eine Kategorie
  void _showCategoryPois(FilterCategory category) {
    final items = _getItemsForCategory(category);
    CategoryPoisBottomSheet.show(
      context,
      category: category,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterProvider);
    final hasActiveFilters = filterState.hasActiveFilters;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: const Text('Entdecken'),
            actions: [
              // Filter Badge
              if (hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.only(right: MshSpacing.sm),
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(filterProvider.notifier).clearAll();
                    },
                    icon: const Icon(Icons.filter_alt_off, size: 18),
                    label: Text('${filterState.categories.length}'),
                    style: TextButton.styleFrom(
                      foregroundColor: MshColors.engagementCritical,
                    ),
                  ),
                ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: MshSpacing.screenPadding,
              child: _buildSearchBar(context),
            ),
          ),

          // Loading
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: MshColors.primary),
              ),
            ),

          // Filter Gruppen
          if (!_isLoading) ...[
            // Aktive Filter Anzeige
            if (hasActiveFilters)
              SliverToBoxAdapter(
                child: _buildActiveFiltersSection(context, filterState),
              ),

            // Alle Gruppen
            for (final group in FilterGroups.all)
              SliverToBoxAdapter(
                child: _buildFilterGroup(context, group),
              ),

            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: MshSpacing.xxl),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(
          color: MshColors.textMuted.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Orte, Kategorien, Adressen...',
          hintStyle: const TextStyle(color: MshColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: MshColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.md,
            vertical: MshSpacing.md,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildActiveFiltersSection(BuildContext context, FilterState filterState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MshSpacing.lg,
        MshSpacing.md,
        MshSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(MshSpacing.md),
        decoration: BoxDecoration(
          color: MshColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
          border: Border.all(
            color: MshColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.filter_list,
              color: MshColors.primary,
              size: 20,
            ),
            const SizedBox(width: MshSpacing.sm),
            Expanded(
              child: Text(
                '${filterState.categories.length} Filter aktiv',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: MshColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('Zur Karte'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: MshSpacing.md,
                  vertical: MshSpacing.xs,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterGroup(BuildContext context, FilterGroup group) {
    final filterState = ref.watch(filterProvider);

    return Padding(
      padding: const EdgeInsets.only(top: MshSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
            child: Row(
              children: [
                Icon(group.icon, size: 20, color: MshColors.textSecondary),
                const SizedBox(width: MshSpacing.sm),
                Text(
                  group.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: MshColors.textStrong,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                // Gruppenzähler
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MshSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: MshColors.textMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(MshSpacing.sm),
                  ),
                  child: Text(
                    '${_countGroupTotal(group)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: MshColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: MshSpacing.sm),

          // Category Cards (Horizontal Scroll)
          MshCategoryCardRow(
            children: group.categories.map((category) {
              final count = _countForCategory(category);
              final isSelected = _isCategorySelected(category, filterState);

              return SizedBox(
                width: 100,
                child: MshCategoryCard(
                  icon: category.icon,
                  label: category.label,
                  color: category.color,
                  count: count,
                  isSelected: isSelected,
                  size: MshCategoryCardSize.medium,
                  onTap: () => _showCategoryPois(category),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int _countGroupTotal(FilterGroup group) {
    var total = 0;
    for (final category in group.categories) {
      total += _countForCategory(category);
    }
    return total;
  }

  bool _isCategorySelected(FilterCategory category, FilterState filterState) {
    return category.mapCategories.any(
      (mapCat) => filterState.categories.contains(mapCat.name),
    );
  }
}
