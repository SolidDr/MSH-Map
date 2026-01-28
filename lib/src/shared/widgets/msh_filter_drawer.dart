/// MSH Map - Filter Drawer Component
///
/// Hierarchischer Filter-Drawer mit:
/// - Gruppierte Sektionen (max 3-5 pro Gruppe)
/// - Kollabierbare Bereiche
/// - Golden Ratio Proportionen
/// - Progressive Disclosure
library;

import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';

/// Filter-Gruppe für hierarchische Organisation
class MshFilterGroup {
  const MshFilterGroup({
    required this.id,
    required this.title,
    required this.filters,
    this.icon,
    this.isExpanded = false,
    this.maxVisible = 5,
  });

  final String id;
  final String title;
  final List<MshFilterItem> filters;
  final IconData? icon;
  final bool isExpanded;
  final int maxVisible; // Max items bevor "Mehr anzeigen"
}

/// Einzelner Filter-Eintrag
class MshFilterItem {
  const MshFilterItem({
    required this.id,
    required this.label,
    this.icon,
    this.color,
    this.count,
    this.isSelected = false,
    this.children,
  });

  final String id;
  final String label;
  final IconData? icon;
  final Color? color;
  final int? count;
  final bool isSelected;
  final List<MshFilterItem>? children; // Für verschachtelte Filter

  MshFilterItem copyWith({bool? isSelected}) {
    return MshFilterItem(
      id: id,
      label: label,
      icon: icon,
      color: color,
      count: count,
      isSelected: isSelected ?? this.isSelected,
      children: children,
    );
  }
}

/// Hierarchischer Filter-Drawer
///
/// Verwendung:
/// ```dart
/// MshFilterDrawer(
///   groups: [
///     MshFilterGroup(
///       id: 'category',
///       title: 'Kategorien',
///       icon: Icons.category,
///       filters: [...],
///     ),
///   ],
///   onFilterChanged: (groupId, filterId, selected) => ...,
/// )
/// ```
class MshFilterDrawer extends StatefulWidget {
  const MshFilterDrawer({
    required this.groups,
    required this.onFilterChanged,
    super.key,
    this.title,
    this.onClearAll,
    this.selectedCount = 0,
  });

  final List<MshFilterGroup> groups;
  final void Function(String groupId, String filterId, bool selected)
      onFilterChanged;
  final String? title;
  final VoidCallback? onClearAll;
  final int selectedCount;

  @override
  State<MshFilterDrawer> createState() => _MshFilterDrawerState();
}

class _MshFilterDrawerState extends State<MshFilterDrawer> {
  late Map<String, bool> _expandedGroups;
  late Map<String, bool> _showAllFilters;

  @override
  void initState() {
    super.initState();
    _expandedGroups = {
      for (final group in widget.groups) group.id: group.isExpanded,
    };
    _showAllFilters = {
      for (final group in widget.groups) group.id: false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildHeader(context),

        const Divider(height: 1),

        // Filter Groups
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: MshSpacing.md, // 13px
            ),
            itemCount: widget.groups.length,
            itemBuilder: (context, index) {
              return _buildFilterGroup(context, widget.groups[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MshSpacing.lg), // 21px
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? 'Filter',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: MshColors.textStrong,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (widget.selectedCount > 0) ...[
                  const SizedBox(height: MshSpacing.xs), // 5px
                  Text(
                    '${widget.selectedCount} ausgewählt',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MshColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.selectedCount > 0 && widget.onClearAll != null)
            TextButton.icon(
              onPressed: widget.onClearAll,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Zurücksetzen'),
              style: TextButton.styleFrom(
                foregroundColor: MshColors.textSecondary,
                textStyle: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterGroup(BuildContext context, MshFilterGroup group) {
    final isExpanded = _expandedGroups[group.id] ?? false;
    final showAll = _showAllFilters[group.id] ?? false;
    final visibleFilters = showAll
        ? group.filters
        : group.filters.take(group.maxVisible).toList();
    final hasMoreFilters = group.filters.length > group.maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Group Header (collapsible)
        InkWell(
          onTap: () {
            setState(() {
              _expandedGroups[group.id] = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MshSpacing.lg, // 21px
              vertical: MshSpacing.md, // 13px
            ),
            child: Row(
              children: [
                if (group.icon != null) ...[
                  Icon(
                    group.icon,
                    size: 20,
                    color: MshColors.textSecondary,
                  ),
                  const SizedBox(width: MshSpacing.sm), // 8px
                ],
                Expanded(
                  child: Text(
                    group.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: MshColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                // Selected count for group
                _buildGroupSelectedCount(context, group),
                const SizedBox(width: MshSpacing.sm), // 8px
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: MshColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Filter Items
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              // Filter Items
              for (final filter in visibleFilters)
                _buildFilterItem(context, group.id, filter),

              // "Show More" Button
              if (hasMoreFilters && !showAll)
                _buildShowMoreButton(context, group.id, group.filters.length),

              // "Show Less" Button
              if (hasMoreFilters && showAll)
                _buildShowLessButton(context, group.id),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildGroupSelectedCount(BuildContext context, MshFilterGroup group) {
    final selectedCount = group.filters.where((f) => f.isSelected).length;
    if (selectedCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MshSpacing.sm, // 8px
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: MshColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MshSpacing.sm), // 8px
      ),
      child: Text(
        selectedCount.toString(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: MshColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildFilterItem(
      BuildContext context, String groupId, MshFilterItem filter,) {
    return InkWell(
      onTap: () => widget.onFilterChanged(groupId, filter.id, !filter.isSelected),
      child: Padding(
        padding: const EdgeInsets.only(
          left: MshSpacing.xl, // 34px (indent)
          right: MshSpacing.lg, // 21px
          top: MshSpacing.sm, // 8px
          bottom: MshSpacing.sm, // 8px
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: filter.isSelected
                    ? (filter.color ?? MshColors.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: filter.isSelected
                      ? (filter.color ?? MshColors.primary)
                      : MshColors.textMuted,
                  width: 2,
                ),
              ),
              child: filter.isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: MshSpacing.md), // 13px

            // Icon (optional)
            if (filter.icon != null) ...[
              Icon(
                filter.icon,
                size: 18,
                color: filter.color ?? MshColors.textSecondary,
              ),
              const SizedBox(width: MshSpacing.sm), // 8px
            ],

            // Label
            Expanded(
              child: Text(
                filter.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: filter.isSelected
                          ? MshColors.textStrong
                          : MshColors.textPrimary,
                      fontWeight:
                          filter.isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
              ),
            ),

            // Count (optional)
            if (filter.count != null)
              Text(
                filter.count.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textMuted,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowMoreButton(
      BuildContext context, String groupId, int totalCount,) {
    final remaining = totalCount - (widget.groups
            .firstWhere((g) => g.id == groupId)
            .maxVisible);

    return TextButton(
      onPressed: () {
        setState(() {
          _showAllFilters[groupId] = true;
        });
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: MshSpacing.xl, // 34px
          vertical: MshSpacing.sm, // 8px
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+$remaining weitere anzeigen',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: MshColors.primary,
                ),
          ),
          const SizedBox(width: MshSpacing.xs), // 5px
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }

  Widget _buildShowLessButton(BuildContext context, String groupId) {
    return TextButton(
      onPressed: () {
        setState(() {
          _showAllFilters[groupId] = false;
        });
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: MshSpacing.xl, // 34px
          vertical: MshSpacing.sm, // 8px
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Weniger anzeigen',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: MshColors.textSecondary,
                ),
          ),
          const SizedBox(width: MshSpacing.xs), // 5px
          const Icon(Icons.expand_less, size: 18),
        ],
      ),
    );
  }
}
