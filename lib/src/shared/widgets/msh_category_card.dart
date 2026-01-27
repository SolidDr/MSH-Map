/// MSH Map - Category Card Component
///
/// Wiederverwendbare Kategorie-Karte mit:
/// - Golden Ratio Proportionen (Breite:Höhe ≈ 1.618:1)
/// - Fibonacci Spacing
/// - Aktivzustand mit visueller Hierarchie
library;

import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';

/// Größen-Varianten für Category Cards
enum MshCategoryCardSize {
  /// Klein - für kompakte Listen (48x48 Icon)
  small(iconSize: 24, minHeight: 64),

  /// Mittel - Standard (40x40 Icon)
  medium(iconSize: 32, minHeight: 89), // 55 * φ ≈ 89

  /// Groß - für prominente Darstellung (48x48 Icon)
  large(iconSize: 48, minHeight: 144); // 89 * φ ≈ 144

  const MshCategoryCardSize({
    required this.iconSize,
    required this.minHeight,
  });

  final double iconSize;
  final double minHeight;
}

/// Category Card für Filterung und Navigation
///
/// Verwendung:
/// ```dart
/// MshCategoryCard(
///   icon: Icons.restaurant,
///   label: 'Essen',
///   color: MshColors.primary,
///   isSelected: true,
///   onTap: () => ...,
/// )
/// ```
class MshCategoryCard extends StatelessWidget {
  const MshCategoryCard({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.color,
    this.count,
    this.isSelected = false,
    this.size = MshCategoryCardSize.medium,
    this.showBadge = false,
    this.badgeColor,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final int? count;
  final bool isSelected;
  final MshCategoryCardSize size;
  final bool showBadge;
  final Color? badgeColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? MshColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium), // 13px
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(
            minHeight: size.minHeight,
          ),
          padding: EdgeInsets.all(
            size == MshCategoryCardSize.small
                ? MshSpacing.sm // 8px
                : MshSpacing.md, // 13px
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.15)
                : MshColors.surface,
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
            border: Border.all(
              color: isSelected
                  ? effectiveColor
                  : MshColors.textMuted.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: effectiveColor.withValues(alpha: 0.2),
                      blurRadius: MshSpacing.sm, // 8px
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon mit optionalem Badge
              _buildIcon(effectiveColor),

              SizedBox(
                height: size == MshCategoryCardSize.small
                    ? MshSpacing.xs // 5px
                    : MshSpacing.sm, // 8px
              ),

              // Label
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? effectiveColor
                          : MshColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Subtitle (optional)
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MshColors.textMuted,
                        fontSize: 10,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Count Badge (optional)
              if (count != null) ...[
                const SizedBox(height: MshSpacing.xs), // 5px
                _buildCountBadge(context, effectiveColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color effectiveColor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(
            size == MshCategoryCardSize.small
                ? MshSpacing.xs // 5px
                : MshSpacing.sm, // 8px
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.2)
                : effectiveColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: size.iconSize,
            color: isSelected ? effectiveColor : effectiveColor.withValues(alpha: 0.8),
          ),
        ),

        // Badge Indicator
        if (showBadge)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: badgeColor ?? MshColors.engagementCritical,
                shape: BoxShape.circle,
                border: Border.all(
                  color: MshColors.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCountBadge(BuildContext context, Color effectiveColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MshSpacing.sm, // 8px
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? effectiveColor.withValues(alpha: 0.2)
            : MshColors.textMuted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MshSpacing.sm), // 8px
      ),
      child: Text(
        count.toString(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isSelected ? effectiveColor : MshColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// Horizontale scrollbare Liste von Category Cards
class MshCategoryCardRow extends StatelessWidget {
  const MshCategoryCardRow({
    required this.children,
    super.key,
    this.padding,
    this.spacing,
  });

  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: MshSpacing.lg, // 21px
          ),
      child: Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              SizedBox(width: spacing ?? MshSpacing.sm), // 8px
          ],
        ],
      ),
    );
  }
}

/// Grid-Layout für Category Cards mit Golden Ratio Aspektverhältnis
class MshCategoryCardGrid extends StatelessWidget {
  const MshCategoryCardGrid({
    required this.children,
    super.key,
    this.crossAxisCount = 4,
    this.padding,
  });

  final List<Widget> children;
  final int crossAxisCount;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? MshSpacing.screenPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: MshSpacing.sm, // 8px
        crossAxisSpacing: MshSpacing.sm, // 8px
        childAspectRatio: MshSpacing.phiInverse, // 0.618 (höher als breit)
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
