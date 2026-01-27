import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/filter_provider.dart';
import '../../core/theme/msh_colors.dart';
import '../../modules/health/domain/health_category.dart';

/// Filter-Zeile für Gesundheits-Kategorien und Fachärzte
class HealthFilterRow extends ConsumerWidget {
  const HealthFilterRow({
    required this.categoryCounts,
    required this.specializationCounts,
    super.key,
  });

  /// Anzahl pro HealthCategory (doctor, pharmacy, etc.)
  final Map<String, int> categoryCounts;

  /// Anzahl pro DoctorSpecialization (allgemein, kardio, etc.)
  final Map<String, int> specializationCounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);
    final selectedHealthFilters = filterState.activeFilterIds
        .where((id) => id.startsWith('health_'))
        .map((id) => id.replaceFirst('health_', ''))
        .toSet();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Alle (kein Filter)
          _HealthChip(
            id: 'alle',
            label: 'Alle',
            icon: Icons.medical_services,
            count: categoryCounts.values.fold(0, (a, b) => a + b),
            isSelected: selectedHealthFilters.isEmpty,
            onTap: () {
              // Alle Health-Filter entfernen
              final notifier = ref.read(filterProvider.notifier);
              for (final id in filterState.activeFilterIds
                  .where((id) => id.startsWith('health_'))
                  .toList()) {
                notifier.toggleFilter(id);
              }
            },
          ),
          const SizedBox(width: 8),

          // Haupt-Kategorien
          _HealthChip(
            id: 'doctor',
            label: 'Ärzte',
            icon: HealthCategory.doctor.icon,
            color: HealthCategory.doctor.color,
            count: categoryCounts['doctor'] ?? 0,
            isSelected: selectedHealthFilters.contains('doctor'),
            onTap: () => ref
                .read(filterProvider.notifier)
                .toggleFilter('health_doctor'),
          ),
          const SizedBox(width: 8),
          _HealthChip(
            id: 'pharmacy',
            label: 'Apotheken',
            icon: HealthCategory.pharmacy.icon,
            color: HealthCategory.pharmacy.color,
            count: categoryCounts['pharmacy'] ?? 0,
            isSelected: selectedHealthFilters.contains('pharmacy'),
            onTap: () => ref
                .read(filterProvider.notifier)
                .toggleFilter('health_pharmacy'),
          ),
          const SizedBox(width: 8),
          _HealthChip(
            id: 'fitness',
            label: 'Fitness',
            icon: HealthCategory.fitness.icon,
            color: HealthCategory.fitness.color,
            count: categoryCounts['fitness'] ?? 0,
            isSelected: selectedHealthFilters.contains('fitness'),
            onTap: () => ref
                .read(filterProvider.notifier)
                .toggleFilter('health_fitness'),
          ),

          // Divider
          const SizedBox(width: 16),
          const VerticalDivider(width: 1, indent: 12, endIndent: 12),
          const SizedBox(width: 16),

          // Fachärzte (nur wenn es Ärzte gibt)
          if (specializationCounts.isNotEmpty) ...[
            for (final spec in DoctorSpecialization.values)
              if ((specializationCounts[spec.name] ?? 0) > 0) ...[
                _HealthChip(
                  id: 'spec_${spec.name}',
                  label: spec.label,
                  icon: _iconForSpecialization(spec),
                  color: MshColors.categoryDoctor,
                  count: specializationCounts[spec.name] ?? 0,
                  isSelected: selectedHealthFilters.contains('spec_${spec.name}'),
                  onTap: () => ref
                      .read(filterProvider.notifier)
                      .toggleFilter('health_spec_${spec.name}'),
                ),
                const SizedBox(width: 8),
              ],
          ],
        ],
      ),
    );
  }

  IconData _iconForSpecialization(DoctorSpecialization spec) {
    return switch (spec) {
      DoctorSpecialization.allgemein => Icons.person,
      DoctorSpecialization.innere => Icons.favorite,
      DoctorSpecialization.kardio => Icons.monitor_heart,
      DoctorSpecialization.ortho => Icons.accessibility_new,
      DoctorSpecialization.neuro => Icons.psychology,
      DoctorSpecialization.augen => Icons.visibility,
      DoctorSpecialization.hno => Icons.hearing,
      DoctorSpecialization.haut => Icons.face,
      DoctorSpecialization.uro => Icons.water_drop,
      DoctorSpecialization.gyn => Icons.pregnant_woman,
      DoctorSpecialization.zahn => Icons.sentiment_very_satisfied,
      DoctorSpecialization.kinder => Icons.child_care,
      DoctorSpecialization.psycho => Icons.self_improvement,
    };
  }
}

class _HealthChip extends StatelessWidget {
  const _HealthChip({
    required this.id,
    required this.label,
    required this.icon,
    this.color,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color? color;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? MshColors.categoryHealth;

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : chipColor),
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
                    : chipColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: Colors.white,
      selectedColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
