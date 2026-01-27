/// MSH Map - Bottom Content Card
///
/// Kompakte Infozeile am unteren Kartenrand:
/// - POI Counter
/// - Up Next Events
/// - Quick Action Chips
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';
import 'up_next_section.dart';

/// Quick Action Typen
enum QuickAction {
  discover(icon: Icons.explore, label: 'Entdecken', route: '/discover'),
  events(icon: Icons.celebration, label: 'Erleben', route: '/events'),
  mobility(icon: Icons.directions_bus, label: 'ÖPNV', route: '/mobility');

  const QuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

/// Bottom Content Card - 20% Viewport
///
/// Zeigt:
/// - POI Count
/// - Quick Actions
/// - Optional: Aktive Filter Badge
class BottomContentCard extends StatelessWidget {
  const BottomContentCard({
    required this.poiCount,
    super.key,
    this.activeFilters = 0,
    this.isLoading = false,
    this.onFilterTap,
  });

  final int poiCount;
  final int activeFilters;
  final bool isLoading;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(MshTheme.radiusXLarge), // 34px
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            _buildDragHandle(),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(
                0, // UpNextSection hat eigenes Padding
                0,
                0,
                MshSpacing.md, // 13px
              ),
              child: Column(
                children: [
                  // POI Counter Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
                    child: _buildPoiCounterRow(context),
                  ),

                  const SizedBox(height: MshSpacing.sm),

                  // Up Next Events
                  const UpNextSection(),

                  const SizedBox(height: MshSpacing.sm),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
                    child: _buildQuickActions(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: MshSpacing.dragHandleWidth, // 40px
        height: MshSpacing.dragHandle, // 5px
        margin: const EdgeInsets.symmetric(vertical: MshSpacing.sm), // 8px
        decoration: BoxDecoration(
          color: MshColors.textMuted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(MshSpacing.xs), // 5px
        ),
      ),
    );
  }

  Widget _buildPoiCounterRow(BuildContext context) {
    return Row(
      children: [
        // POI Counter
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.md, // 13px
            vertical: MshSpacing.sm, // 8px
          ),
          decoration: BoxDecoration(
            color: MshColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.place,
                size: 18,
                color: MshColors.primary,
              ),
              const SizedBox(width: MshSpacing.xs), // 5px
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MshColors.primary,
                  ),
                )
              else
                Text(
                  '$poiCount ${poiCount == 1 ? 'Ort' : 'Orte'}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: MshColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        ),

        const Spacer(),

        // Filter Badge (optional)
        if (activeFilters > 0)
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MshSpacing.sm, // 8px
                vertical: MshSpacing.xs, // 5px
              ),
              decoration: BoxDecoration(
                color: MshColors.engagementElevated.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                border: Border.all(
                  color: MshColors.engagementElevated.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 16,
                    color: MshColors.engagementElevated,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$activeFilters Filter',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: MshColors.engagementElevated,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: QuickAction.values
          .map((action) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: action != QuickAction.values.last
                        ? MshSpacing.sm
                        : 0, // 8px
                  ),
                  child: _QuickActionChip(action: action),
                ),
              ),)
          .toList(),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MshColors.background,
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: () => context.go(action.route),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm, // 8px
            vertical: MshSpacing.md, // 13px
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 18,
                color: MshColors.textSecondary,
              ),
              const SizedBox(width: MshSpacing.xs), // 5px
              Flexible(
                child: Text(
                  action.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: MshColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
