import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../features/analytics/data/usage_analytics_service.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../shared/widgets/msh_bottom_sheet.dart';
import '../data/nightlife_repository.dart';
import '../domain/nightlife_category.dart';
import '../domain/nightlife_venue.dart';
import 'nightlife_venue_detail.dart';

class NightlifeScreen extends StatefulWidget {
  const NightlifeScreen({super.key});

  @override
  State<NightlifeScreen> createState() => _NightlifeScreenState();
}

class _NightlifeScreenState extends State<NightlifeScreen> {
  final _repository = NightlifeRepository();
  List<NightlifeVenue> _venues = [];
  bool _isLoading = true;
  NightlifeCategory? _selectedCategory;
  bool _showOpenOnly = false;

  @override
  void initState() {
    super.initState();
    UsageAnalyticsService().trackModuleVisit('nightlife');
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() => _isLoading = true);
    final venues = await _repository.loadFromAssets();
    setState(() {
      _venues = venues;
      _isLoading = false;
    });
  }

  List<NightlifeVenue> get _filteredVenues {
    var result = _venues;

    if (_selectedCategory != null) {
      result = result
          .where((v) => v.nightlifeCategory == _selectedCategory)
          .toList();
    }

    if (_showOpenOnly) {
      result = result.where((v) => v.isOpenNow).toList();
    }

    return result;
  }

  void _showVenueDetail(NightlifeVenue venue) {
    MshBottomSheet.show(
      context: context,
      title: venue.name,
      builder: (context) => NightlifeVenueDetailContent(venue: venue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nachtleben'),
        backgroundColor: MshColors.categoryNightlife,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter-Chips
          _buildFilterSection(),

          // Venues Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVenues.isEmpty
                    ? _buildEmptyState()
                    : _buildVenuesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategorie-Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Alle',
                  icon: Icons.nightlife,
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...NightlifeCategory.values.map(
                  (cat) => _FilterChip(
                    label: cat.label,
                    icon: cat.icon,
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: MshSpacing.sm),

          // "Jetzt geöffnet" Toggle
          Row(
            children: [
              Switch(
                value: _showOpenOnly,
                onChanged: (v) => setState(() => _showOpenOnly = v),
                activeColor: MshColors.categoryNightlife,
              ),
              const SizedBox(width: MshSpacing.xs),
              Text(
                'Nur geöffnete anzeigen',
                style: TextStyle(
                  color: _showOpenOnly
                      ? MshColors.categoryNightlife
                      : MshColors.textSecondary,
                  fontWeight:
                      _showOpenOnly ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredVenues.length} Ergebnisse',
                style: TextStyle(
                  color: MshColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nightlife,
            size: 64,
            color: MshColors.textMuted,
          ),
          const SizedBox(height: MshSpacing.md),
          Text(
            _showOpenOnly
                ? 'Aktuell keine Venues geöffnet'
                : 'Keine Venues gefunden',
            style: TextStyle(
              fontSize: 16,
              color: MshColors.textSecondary,
            ),
          ),
          if (_showOpenOnly) ...[
            const SizedBox(height: MshSpacing.sm),
            TextButton(
              onPressed: () => setState(() => _showOpenOnly = false),
              child: const Text('Alle anzeigen'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVenuesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(MshSpacing.md),
      itemCount: _filteredVenues.length,
      itemBuilder: (context, index) {
        final venue = _filteredVenues[index];
        return _VenueCard(
          venue: venue,
          onTap: () => _showVenueDetail(venue),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: MshSpacing.sm),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : MshColors.categoryNightlife,
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: MshColors.categoryNightlife,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : MshColors.textPrimary,
        ),
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({
    required this.venue,
    required this.onTap,
  });

  final NightlifeVenue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOpen = venue.isOpenNow;
    final todayHours = venue.todayHours;

    return Card(
      margin: const EdgeInsets.only(bottom: MshSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.md),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: MshColors.categoryNightlife.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  venue.nightlifeCategory.icon,
                  color: MshColors.categoryNightlife,
                ),
              ),

              const SizedBox(width: MshSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            venue.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Open/Closed Badge
                        if (venue.openingHours != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isOpen ? MshColors.success : MshColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isOpen ? 'Offen' : 'Zu',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      venue.nightlifeCategory.label,
                      style: TextStyle(
                        color: MshColors.categoryNightlife,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (venue.city != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        venue.city!,
                        style: TextStyle(
                          color: MshColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (todayHours != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: MshColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Heute: $todayHours',
                            style: TextStyle(
                              color: MshColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: MshColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
