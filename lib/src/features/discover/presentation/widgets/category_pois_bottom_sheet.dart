import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/domain/filter_groups.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_spacing.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../../../shared/domain/map_item.dart';

/// Bottom Sheet showing POIs in a specific category
/// When a POI is tapped, navigates to map with focus on that location
class CategoryPoisBottomSheet extends StatelessWidget {
  const CategoryPoisBottomSheet({
    required this.category,
    required this.items,
    super.key,
  });

  final FilterCategory category;
  final List<MapItem> items;

  static void show(
    BuildContext context, {
    required FilterCategory category,
    required List<MapItem> items,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPoisBottomSheet(
        category: category,
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(MshSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: MshSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.label,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${items.length} Orte gefunden',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: MshColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // POI List
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: MshSpacing.md,
                          vertical: MshSpacing.sm,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: MshSpacing.xs),
                        itemBuilder: (context, index) => _PoiListTile(
                          item: items[index],
                          onTap: () => _navigateToPoiOnMap(context, items[index]),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 64,
            color: MshColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: MshSpacing.md),
          Text(
            'Keine Orte in dieser Kategorie',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: MshColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToPoiOnMap(BuildContext context, MapItem item) {
    // Close the bottom sheet
    Navigator.pop(context);

    // Navigate to map with the item's coordinates as query params
    // The home screen will handle the navigation to the marker
    context.go(
      '/?lat=${item.coordinates.latitude}&lng=${item.coordinates.longitude}&id=${item.id}',
    );
  }
}

/// Individual POI tile in the list
class _PoiListTile extends StatelessWidget {
  const _PoiListTile({
    required this.item,
    required this.onTap,
  });

  final MapItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(MshSpacing.md),
          decoration: BoxDecoration(
            color: MshColors.surface,
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
            border: Border.all(
              color: MshColors.textMuted.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.markerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                ),
                child: Icon(
                  _iconForCategory(item.category),
                  color: item.markerColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: MshSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MshColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Show address if available
                    if (item.metadata['address'] != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 12,
                            color: MshColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.metadata['address'] as String,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: MshColors.textMuted,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.chevron_right,
                color: MshColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(MapItemCategory c) => switch (c) {
        MapItemCategory.restaurant => Icons.restaurant,
        MapItemCategory.cafe => Icons.coffee,
        MapItemCategory.imbiss => Icons.fastfood,
        MapItemCategory.bar => Icons.local_bar,
        MapItemCategory.event => Icons.event,
        MapItemCategory.culture => Icons.museum,
        MapItemCategory.sport => Icons.sports,
        MapItemCategory.playground => Icons.toys,
        MapItemCategory.museum => Icons.account_balance,
        MapItemCategory.nature => Icons.park,
        MapItemCategory.zoo => Icons.pets,
        MapItemCategory.castle => Icons.castle,
        MapItemCategory.pool => Icons.pool,
        MapItemCategory.indoor => Icons.house,
        MapItemCategory.farm => Icons.agriculture,
        MapItemCategory.adventure => Icons.terrain,
        MapItemCategory.service => Icons.build,
        MapItemCategory.search => Icons.search,
        MapItemCategory.custom => Icons.place,
      };
}
