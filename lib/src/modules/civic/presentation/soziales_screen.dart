/// MSH Map - Soziales Screen
///
/// Eigenständiger Screen für soziale Einrichtungen
/// Behörden, Jugendzentren, Soziale Einrichtungen, Seniorentreffs
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../../features/analytics/data/usage_analytics_service.dart';
import '../data/civic_repository.dart';
import '../domain/civic_category.dart';
import '../domain/civic_facility.dart';
import 'civic_facility_detail.dart';

/// Provider für Civic Repository
final civicRepositoryProvider = Provider((ref) => CivicRepository());

/// Provider für alle sozialen Einrichtungen
final civicFacilitiesProvider = FutureProvider<List<CivicFacility>>((ref) async {
  final repo = ref.watch(civicRepositoryProvider);
  return repo.loadFromAssets();
});

/// Soziales Screen mit Kategorie-Filtern
class SozialesScreen extends ConsumerStatefulWidget {
  const SozialesScreen({super.key});

  @override
  ConsumerState<SozialesScreen> createState() => _SozialesScreenState();
}

class _SozialesScreenState extends ConsumerState<SozialesScreen> {
  CivicCategory? _selectedCategory;
  TargetAudience? _selectedAudience;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    UsageAnalyticsService().trackModuleVisit('civic');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facilitiesAsync = ref.watch(civicFacilitiesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: const Text('Soziales'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
                tooltip: 'Info',
              ),
            ],
          ),

          // Info-Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(MshSpacing.lg),
              child: _InfoBanner(),
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

          // Zielgruppen-Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                MshSpacing.lg,
                0,
                MshSpacing.lg,
                MshSpacing.lg,
              ),
              child: _buildAudienceFilter(),
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
        hintText: 'Einrichtung suchen...',
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
      style: const TextStyle(fontSize: 16),
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
          icon: Icons.apps,
          color: MshColors.categorySocialFacility,
          isSelected: _selectedCategory == null,
          onTap: () => setState(() => _selectedCategory = null),
        ),
        _CategoryChip(
          label: 'Behörden',
          icon: Icons.account_balance,
          color: MshColors.categoryGovernment,
          isSelected: _selectedCategory == CivicCategory.government,
          onTap: () => setState(() => _selectedCategory = CivicCategory.government),
        ),
        _CategoryChip(
          label: 'Jugendzentren',
          icon: Icons.group,
          color: MshColors.categoryYouthCentre,
          isSelected: _selectedCategory == CivicCategory.youthCentre,
          onTap: () => setState(() => _selectedCategory = CivicCategory.youthCentre),
        ),
        _CategoryChip(
          label: 'Soziales',
          icon: Icons.volunteer_activism,
          color: MshColors.categorySocialFacility,
          isSelected: _selectedCategory == CivicCategory.socialFacility,
          onTap: () => setState(() => _selectedCategory = CivicCategory.socialFacility),
        ),
      ],
    );
  }

  Widget _buildAudienceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zielgruppe',
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
            _AudienceChip(
              label: 'Alle',
              isSelected: _selectedAudience == null,
              onTap: () => setState(() => _selectedAudience = null),
            ),
            _AudienceChip(
              label: 'Jugend',
              icon: Icons.people,
              isSelected: _selectedAudience == TargetAudience.youth,
              onTap: () => setState(() => _selectedAudience = TargetAudience.youth),
            ),
            _AudienceChip(
              label: 'Senioren',
              icon: Icons.elderly,
              isSelected: _selectedAudience == TargetAudience.seniors,
              onTap: () => setState(() => _selectedAudience = TargetAudience.seniors),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilitiesList(List<CivicFacility> facilities) {
    // Filtern
    final filtered = facilities.where((f) {
      // Kategorie-Filter
      if (_selectedCategory != null && f.civicCategory != _selectedCategory) {
        return false;
      }
      // Zielgruppen-Filter
      if (_selectedAudience != null) {
        if (_selectedAudience == TargetAudience.youth && !f.isYouthRelevant) {
          return false;
        }
        if (_selectedAudience == TargetAudience.seniors && !f.isSeniorRelevant) {
          return false;
        }
      }
      // Such-Filter
      if (_searchQuery.isNotEmpty) {
        return f.name.toLowerCase().contains(_searchQuery) ||
            f.fullAddress.toLowerCase().contains(_searchQuery) ||
            (f.description?.toLowerCase().contains(_searchQuery) ?? false);
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
                  'Versuche einen anderen Suchbegriff oder Filter',
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

  void _showFacilityDetail(CivicFacility facility) {
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
            child: CivicFacilityDetailContent(facility: facility),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soziales in MSH'),
        content: const Text(
          'Hier findest du soziale Einrichtungen im Landkreis Mansfeld-Südharz:\n\n'
          '• Behörden und Rathäuser\n'
          '• Jugendzentren und Gemeindezentren\n'
          '• Soziale Einrichtungen und Beratungsstellen\n'
          '• Seniorentreffs\n\n'
          'Nutze die Filter, um gezielt nach Einrichtungen für bestimmte Zielgruppen zu suchen.',
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

// ═══════════════════════════════════════════════════════════════
// KOMPONENTEN
// ═══════════════════════════════════════════════════════════════

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.categorySocialFacility.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(
          color: MshColors.categorySocialFacility.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.volunteer_activism,
            color: MshColors.categorySocialFacility,
            size: 32,
          ),
          SizedBox(width: MshSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soziale Angebote',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MshColors.categorySocialFacility,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Behörden, Jugendzentren, Beratung & mehr',
                  style: TextStyle(
                    color: MshColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : MshColors.surface,
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

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
    required this.label,
    required this.isSelected, required this.onTap, this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? MshColors.primary : MshColors.surface,
      borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm,
            vertical: MshSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : MshColors.textSecondary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.onTap,
  });

  final CivicFacility facility;
  final VoidCallback onTap;

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
                  color: facility.civicCategory.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                ),
                child: Icon(
                  facility.civicCategory.icon,
                  color: facility.civicCategory.color,
                  size: 28,
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
                    const SizedBox(height: 2),
                    Text(
                      facility.civicCategory.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: facility.civicCategory.color,
                          ),
                    ),
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

              // Badges & Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (facility.isYouthRelevant)
                    const _SmallBadge(
                      icon: Icons.people,
                      label: 'Jugend',
                      color: MshColors.categoryYouthCentre,
                    ),
                  if (facility.isSeniorRelevant)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: _SmallBadge(
                        icon: Icons.elderly,
                        label: 'Senioren',
                        color: MshColors.categorySocialFacility,
                      ),
                    ),
                  const SizedBox(height: MshSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Telefon-Button (klickbar)
                      if (facility.phone != null)
                        IconButton(
                          icon: const Icon(
                            Icons.phone,
                            color: MshColors.success,
                            size: 22,
                          ),
                          tooltip: 'Anrufen',
                          onPressed: () => _callPhone(facility.phone!),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      const Icon(
                        Icons.chevron_right,
                        color: MshColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
