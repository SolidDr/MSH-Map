/// MSH Map - Gesundheit Screen
///
/// Eigenständiger Screen für Gesundheit & Notfall-Informationen
/// Optimiert für ältere Nutzer mit großen Touch-Targets
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/msh_colors.dart';
import '../../../features/analytics/data/usage_analytics_service.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../data/health_repository.dart';
import '../domain/health_category.dart';
import '../domain/health_facility.dart';
import 'health_facility_detail.dart';
import 'widgets/emergency_pharmacy_modal.dart';
import 'widgets/emergency_section.dart';

/// Provider für Health Repository
final healthRepositoryProvider = Provider((ref) => HealthRepository());

/// Provider für alle Gesundheitseinrichtungen
final healthFacilitiesProvider = FutureProvider<List<HealthFacility>>((ref) async {
  final repo = ref.watch(healthRepositoryProvider);
  return repo.loadFromAssets();
});

/// Gesundheit Screen mit Notfall-Bereich und Ärzte-Suche
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  HealthCategory? _selectedCategory;
  DoctorSpecialization? _selectedSpecialization;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    UsageAnalyticsService().trackModuleVisit('health');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facilitiesAsync = ref.watch(healthFacilitiesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: const Text('Gesundheit'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
                tooltip: 'Info',
              ),
            ],
          ),

          // Notfall-Bereich (immer oben, prominente)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(MshSpacing.lg),
              child: EmergencySection(
                onEmergencyPharmacyTap: () => _showEmergencyPharmacy(context),
              ),
            ),
          ),

          // Suchleiste
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
              child: _buildSearchBar(),
            ),
          ),

          // Kategorie-Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(MshSpacing.lg),
              child: _buildCategoryFilter(),
            ),
          ),

          // Facharzt-Filter (nur bei Ärzte-Kategorie)
          if (_selectedCategory == HealthCategory.doctor)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  MshSpacing.lg,
                  0,
                  MshSpacing.lg,
                  MshSpacing.lg,
                ),
                child: _buildSpecializationFilter(),
              ),
            ),

          // Einrichtungen Liste
          facilitiesAsync.when(
            data: _buildFacilitiesList,
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(MshSpacing.xxl),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: _buildErrorState(error.toString()),
            ),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: MshSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Arzt, Apotheke oder Einrichtung suchen...',
        hintStyle: const TextStyle(color: MshColors.textMuted),
        prefixIcon: const Icon(Icons.search, color: MshColors.textSecondary),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: MshColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MshSpacing.md,
          vertical: MshSpacing.md,
        ),
      ),
      style: const TextStyle(fontSize: 16), // Größere Schrift für Senioren
      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: MshSpacing.sm,
      runSpacing: MshSpacing.sm,
      children: [
        _CategoryChip(
          label: 'Alle',
          icon: Icons.medical_services,
          isSelected: _selectedCategory == null,
          onTap: () => setState(() {
            _selectedCategory = null;
            _selectedSpecialization = null;
          }),
        ),
        _CategoryChip(
          label: 'Ärzte',
          icon: Icons.person,
          isSelected: _selectedCategory == HealthCategory.doctor,
          onTap: () => setState(() {
            _selectedCategory = HealthCategory.doctor;
            // Spezialisierung behalten wenn schon auf Ärzte
          }),
        ),
        _CategoryChip(
          label: 'Apotheken',
          icon: Icons.local_pharmacy,
          isSelected: _selectedCategory == HealthCategory.pharmacy,
          onTap: () => setState(() {
            _selectedCategory = HealthCategory.pharmacy;
            _selectedSpecialization = null;
          }),
        ),
        _CategoryChip(
          label: 'Fitness',
          icon: Icons.fitness_center,
          isSelected: _selectedCategory == HealthCategory.fitness,
          onTap: () => setState(() {
            _selectedCategory = HealthCategory.fitness;
            _selectedSpecialization = null;
          }),
        ),
        _CategoryChip(
          label: 'Defibrillatoren',
          icon: Icons.favorite,
          isSelected: _selectedCategory == HealthCategory.defibrillator,
          onTap: () => setState(() {
            _selectedCategory = HealthCategory.defibrillator;
            _selectedSpecialization = null;
          }),
          color: MshColors.categoryDefibrillator,
        ),
      ],
    );
  }

  Widget _buildSpecializationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fachrichtung',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: MshColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshSpacing.sm),
        Wrap(
          spacing: MshSpacing.xs,
          runSpacing: MshSpacing.xs,
          children: [
            _SpecializationChip(
              label: 'Alle Ärzte',
              isSelected: _selectedSpecialization == null,
              onTap: () => setState(() => _selectedSpecialization = null),
            ),
            ...DoctorSpecialization.values.map(
              (spec) => _SpecializationChip(
                label: spec.label,
                isSelected: _selectedSpecialization == spec,
                onTap: () => setState(() => _selectedSpecialization = spec),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilitiesList(List<HealthFacility> facilities) {
    // Filtern
    final filtered = facilities.where((f) {
      // Kategorie-Filter
      if (_selectedCategory != null && f.healthCategory != _selectedCategory) {
        return false;
      }
      // Spezialisierungs-Filter (nur bei Ärzten)
      if (_selectedCategory == HealthCategory.doctor &&
          _selectedSpecialization != null &&
          f.specialization != _selectedSpecialization) {
        return false;
      }
      // Such-Filter
      if (_searchQuery.isNotEmpty) {
        return f.name.toLowerCase().contains(_searchQuery) ||
            (f.specialization?.label.toLowerCase().contains(_searchQuery) ?? false) ||
            f.fullAddress.toLowerCase().contains(_searchQuery);
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(MshSpacing.xxl),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: MshColors.textMuted,
                ),
                const SizedBox(height: MshSpacing.md),
                Text(
                  'Keine Einrichtungen gefunden',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: MshColors.textSecondary,
                      ),
                ),
                const SizedBox(height: MshSpacing.sm),
                Text(
                  'Versuche einen anderen Suchbegriff',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MshColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _FacilityCard(
            facility: filtered[index],
            onTap: () => _showFacilityDetail(filtered[index]),
          ),
          childCount: filtered.length,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.xxl),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: MshColors.error,
            ),
            const SizedBox(height: MshSpacing.md),
            Text(
              'Fehler beim Laden',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MshSpacing.sm),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MshColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyPharmacy(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmergencyPharmacyModal(),
    );
  }

  void _showFacilityDetail(HealthFacility facility) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(MshTheme.radiusXLarge),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(MshSpacing.lg),
            child: HealthFacilityDetailContent(facility: facility),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gesundheit in MSH'),
        content: const Text(
          'Hier findest du Ärzte, Apotheken und Gesundheitseinrichtungen '
          'im Landkreis Mansfeld-Südharz.\n\n'
          'Im Notfall-Bereich oben findest du wichtige Notfallnummern '
          'und den aktuellen Apotheken-Notdienst.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? MshColors.categoryHealth;
    return Material(
      color: isSelected ? chipColor : MshColors.surface,
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.md,
            vertical: MshSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : MshColors.textSecondary,
              ),
              const SizedBox(width: MshSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : MshColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecializationChip extends StatelessWidget {
  const _SpecializationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? MshColors.categoryDoctor
          : MshColors.surface,
      borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm,
            vertical: MshSpacing.xs,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : MshColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.onTap,
  });

  final HealthFacility facility;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: MshSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.md),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(MshSpacing.sm),
                decoration: BoxDecoration(
                  color: MshColors.categoryHealth.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                ),
                child: Icon(
                  _iconForCategory(facility.healthCategory),
                  color: MshColors.categoryHealth,
                  size: 28, // Größeres Icon für bessere Sichtbarkeit
                ),
              ),

              const SizedBox(width: MshSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (facility.specialization != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        facility.specialization!.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: MshColors.textSecondary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      facility.fullAddress,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MshColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),

              // Status Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (facility.isOpenNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: MshColors.engagementNormal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Geöffnet',
                        style: TextStyle(
                          color: MshColors.engagementNormal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: MshSpacing.xs),
                  const Icon(
                    Icons.chevron_right,
                    color: MshColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(HealthCategory category) {
    return switch (category) {
      HealthCategory.doctor => Icons.person,
      HealthCategory.pharmacy => Icons.local_pharmacy,
      HealthCategory.hospital => Icons.local_hospital,
      HealthCategory.physiotherapy => Icons.spa,
      HealthCategory.fitness => Icons.fitness_center,
      HealthCategory.careService => Icons.elderly,
      HealthCategory.medicalSupply => Icons.medical_information,
      HealthCategory.defibrillator => Icons.favorite,
    };
  }
}
