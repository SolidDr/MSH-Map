/// MSH Map - Unified Bottom Sheet Component
///
/// Wiederverwendbares Bottom Sheet mit:
/// - Golden Ratio Proportionen (φ = 1.618)
/// - Fibonacci Spacing
/// - Konsistentes Design
library;

import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';

/// Größen-Presets basierend auf Golden Ratio
enum MshBottomSheetSize {
  /// Minimal - 20% der Viewport Höhe
  minimal(initialSize: 0.2, minSize: 0.08, maxSize: 0.4),

  /// Mittel - φ^-2 ≈ 38.2% (Golden Ratio Quadrat)
  medium(initialSize: 0.382, minSize: 0.2, maxSize: 0.6),

  /// Standard - φ^-1 ≈ 61.8% (Golden Ratio)
  standard(initialSize: MshSpacing.phiInverse, minSize: 0.2, maxSize: 1),

  /// Groß - 80% (fast Fullscreen)
  large(initialSize: 0.8, minSize: 0.4, maxSize: 1);

  const MshBottomSheetSize({
    required this.initialSize,
    required this.minSize,
    required this.maxSize,
  });

  final double initialSize;
  final double minSize;
  final double maxSize;
}

/// Unified Bottom Sheet Component
///
/// Verwendung:
/// ```dart
/// MshBottomSheet.show(
///   context: context,
///   title: 'Titel',
///   builder: (context) => YourContent(),
/// );
/// ```
class MshBottomSheet extends StatelessWidget {
  const MshBottomSheet({
    required this.builder, super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.size = MshBottomSheetSize.standard,
    this.showDragHandle = true,
    this.showDivider = true,
    this.padding,
  });

  final WidgetBuilder builder;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final MshBottomSheetSize size;
  final bool showDragHandle;
  final bool showDivider;
  final EdgeInsets? padding;

  /// Zeigt das Bottom Sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    MshBottomSheetSize size = MshBottomSheetSize.standard,
    bool showDragHandle = true,
    bool showDivider = true,
    EdgeInsets? padding,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (_) => MshBottomSheet(
        builder: builder,
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        size: size,
        showDragHandle: showDragHandle,
        showDivider: showDivider,
        padding: padding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: size.initialSize,
      minChildSize: size.minSize,
      maxChildSize: size.maxSize,
      snap: true,
      snapAnimationDuration: const Duration(milliseconds: 200),
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(MshTheme.radiusXLarge), // 34px (Fibonacci)
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              if (showDragHandle) _buildDragHandle(),

              // Header
              if (title != null || icon != null) _buildHeader(context),

              // Divider
              if (showDivider && (title != null || icon != null))
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MshSpacing.lg,
                  ),
                  child: Divider(height: 1),
                ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: padding ??
                      const EdgeInsets.symmetric(
                        horizontal: MshSpacing.lg, // 21px
                        vertical: MshSpacing.md, // 13px
                      ),
                  child: builder(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Drag Handle - basierend auf MshSpacing
  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: MshSpacing.dragHandleWidth, // 40px
        height: MshSpacing.dragHandle, // 5px (Fibonacci)
        margin: const EdgeInsets.symmetric(
          vertical: MshSpacing.md, // 13px
        ),
        decoration: BoxDecoration(
          color: MshColors.textMuted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(MshSpacing.xs), // 5px
        ),
      ),
    );
  }

  /// Header mit Icon und Titel
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        MshSpacing.lg, // 21px left
        showDragHandle ? 0 : MshSpacing.md, // 13px top (wenn kein Handle)
        MshSpacing.lg, // 21px right
        MshSpacing.md, // 13px bottom
      ),
      child: Row(
        children: [
          // Icon
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(MshSpacing.sm), // 8px
              decoration: BoxDecoration(
                color: (iconColor ?? MshColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  MshTheme.radiusSmall, // 8px
                ),
              ),
              child: Icon(
                icon,
                color: iconColor ?? MshColors.primary,
                size: 24,
              ),
            ),

          if (icon != null) const SizedBox(width: MshSpacing.md), // 13px

          // Titel & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: MshColors.textStrong,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: MshSpacing.xs), // 5px
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MshColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Schnelle Helper-Funktionen für häufige Verwendungsfälle
extension MshBottomSheetHelpers on BuildContext {
  /// Zeigt ein Bottom Sheet mit Titel
  Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    String? title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    MshBottomSheetSize size = MshBottomSheetSize.standard,
  }) {
    return MshBottomSheet.show<T>(
      context: this,
      builder: builder,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      size: size,
    );
  }

  /// Zeigt ein einfaches Bottom Sheet ohne Header
  Future<T?> showSimpleBottomSheet<T>({
    required WidgetBuilder builder,
    MshBottomSheetSize size = MshBottomSheetSize.standard,
    EdgeInsets? padding,
  }) {
    return MshBottomSheet.show<T>(
      context: this,
      builder: builder,
      size: size,
      showDivider: false,
      padding: padding,
    );
  }
}
