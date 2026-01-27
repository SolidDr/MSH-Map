import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/filter_provider.dart';
import '../../core/theme/msh_colors.dart';

class AgeFilterRow extends ConsumerWidget {
  const AgeFilterRow({
    required this.ageCounts, super.key,
  });

  final Map<String, int> ageCounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);
    final selectedAges = filterState.activeFilterIds
        .where((id) => id.startsWith('age_'))
        .map((id) => id.replaceFirst('age_', ''))
        .toSet();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _AgeChip(
            age: '0-3',
            label: '0-3 Jahre',
            icon: Icons.child_care,
            count: ageCounts['0-3'] ?? 0,
            isSelected: selectedAges.contains('0-3'),
            onTap: () =>
                ref.read(filterProvider.notifier).toggleFilter('age_0-3'),
          ),
          const SizedBox(width: 8),
          _AgeChip(
            age: '3-6',
            label: '3-6 Jahre',
            icon: Icons.child_friendly,
            count: ageCounts['3-6'] ?? 0,
            isSelected: selectedAges.contains('3-6'),
            onTap: () =>
                ref.read(filterProvider.notifier).toggleFilter('age_3-6'),
          ),
          const SizedBox(width: 8),
          _AgeChip(
            age: '6-12',
            label: '6-12 Jahre',
            icon: Icons.school,
            count: ageCounts['6-12'] ?? 0,
            isSelected: selectedAges.contains('6-12'),
            onTap: () =>
                ref.read(filterProvider.notifier).toggleFilter('age_6-12'),
          ),
          const SizedBox(width: 8),
          _AgeChip(
            age: '12+',
            label: '12+ Jahre',
            icon: Icons.face,
            count: ageCounts['12+'] ?? 0,
            isSelected: selectedAges.contains('12+'),
            onTap: () =>
                ref.read(filterProvider.notifier).toggleFilter('age_12+'),
          ),
        ],
      ),
    );
  }
}

class _AgeChip extends StatelessWidget {
  const _AgeChip({
    required this.age,
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String age;
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white24
                    : MshColors.categoryFamily.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : MshColors.categoryFamily,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: Colors.white,
      selectedColor: MshColors.categoryFamily,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
