import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../domain/engagement_model.dart';

/// Filter-Leiste für Engagement-Typen
class EngagementFilterBar extends StatelessWidget {
  final EngagementType? selectedType;
  final void Function(EngagementType?) onTypeSelected;
  final Map<EngagementType, int>? counts;

  const EngagementFilterBar({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "Alle" Chip
          _EngagementFilterChip(
            label: 'Alle',
            emoji: '❤️',
            isSelected: selectedType == null,
            count: counts?.values.fold<int>(0, (a, b) => a + b),
            onTap: () => onTypeSelected(null),
          ),
          const SizedBox(width: 8),

          // Typ-Chips
          ...EngagementType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _EngagementFilterChip(
                label: type.label,
                emoji: type.emoji,
                color: type.color,
                isSelected: selectedType == type,
                count: counts?[type],
                onTap: () => onTypeSelected(type),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementFilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color? color;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _EngagementFilterChip({
    required this.label,
    required this.emoji,
    this.color,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? MshColors.engagementHeart;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : MshColors.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? chipColor : MshColors.engagementGold,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: chipColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : MshColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : chipColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? Colors.white : chipColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
