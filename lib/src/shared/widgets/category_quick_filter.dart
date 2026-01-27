import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';

class CategoryQuickFilter extends StatelessWidget {

  const CategoryQuickFilter({
    super.key,
    required this.selectedCategories,
    required this.onCategoryToggle,
    this.categoryCounts = const {},
  });
  final Set<String> selectedCategories;
  final ValueChanged<String> onCategoryToggle;
  final Map<String, int> categoryCounts;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _CategoryChip(
            label: 'Alle',
            icon: Icons.apps,
            count: categoryCounts.values.fold(0, (a, b) => a + b),
            isSelected: selectedCategories.isEmpty,
            onTap: () {
              // Clear all by toggling all selected categories
              for (final cat in selectedCategories.toList()) {
                onCategoryToggle(cat);
              }
            },
          ),
          ..._categories.map((cat) => _CategoryChip(
                label: cat.label,
                icon: cat.icon,
                color: cat.color,
                count: categoryCounts[cat.id] ?? 0,
                isSelected: selectedCategories.contains(cat.id),
                onTap: () => onCategoryToggle(cat.id),
              ),),
        ],
      ),
    );
  }

  static const _categories = [
    (
      id: 'playground',
      label: 'Spielplätze',
      icon: Icons.child_care,
      color: MshColors.categoryPlayground
    ),
    (
      id: 'health',
      label: 'Gesundheit',
      icon: Icons.medical_services,
      color: MshColors.categoryHealth
    ),
    (
      id: 'museum',
      label: 'Museen',
      icon: Icons.museum,
      color: MshColors.categoryMuseum
    ),
    (
      id: 'nature',
      label: 'Natur',
      icon: Icons.park,
      color: MshColors.categoryNature
    ),
    (
      id: 'pool',
      label: 'Baden',
      icon: Icons.pool,
      color: MshColors.categoryPool
    ),
    (
      id: 'castle',
      label: 'Burgen',
      icon: Icons.castle,
      color: MshColors.categoryCastle
    ),
    (id: 'zoo', label: 'Zoo', icon: Icons.pets, color: MshColors.categoryZoo),
    (
      id: 'farm',
      label: 'Bauernhof',
      icon: Icons.agriculture,
      color: MshColors.categoryFarm
    ),
    (
      id: 'restaurant',
      label: 'Essen',
      icon: Icons.restaurant,
      color: MshColors.categoryGastro
    ),
    (
      id: 'education',
      label: 'Bildung',
      icon: Icons.school,
      color: MshColors.categoryEducation
    ),
  ];
}

class _CategoryChip extends StatelessWidget {

  const _CategoryChip({
    required this.label,
    required this.icon,
    this.color,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color? color;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? MshColors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? chipColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? chipColor : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : chipColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : MshColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.3)
                          : chipColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : chipColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
