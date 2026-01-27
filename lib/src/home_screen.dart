import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'core/config/feature_flags.dart';
import 'core/config/map_config.dart';
import 'core/providers/filter_provider.dart';
import 'core/theme/msh_colors.dart';
import 'core/theme/msh_spacing.dart';
import 'core/theme/msh_theme.dart';
import 'modules/_module_registry.dart';
import 'modules/events/data/events_providers.dart';
import 'modules/events/domain/notice.dart';
import 'modules/events/presentation/widgets/notice_banner.dart';
import 'shared/domain/map_item.dart';
import 'shared/widgets/age_filter_row.dart';
import 'shared/widgets/bottom_content_card.dart';
import 'shared/widgets/category_quick_filter.dart';
import 'shared/widgets/layer_switcher.dart';
import 'shared/widgets/msh_map_view.dart';
import 'shared/widgets/poi_bottom_sheet.dart';
import 'shared/widgets/search_autocomplete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.targetLatitude,
    this.targetLongitude,
    this.targetPoiId,
  });

  /// Optional target coordinates for navigation from other screens
  final double? targetLatitude;
  final double? targetLongitude;
  final String? targetPoiId;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<MapItem> _items = [];
  bool _isLoading = true;
  String? _error;
  late final MapController _mapController;
  AnimationController? _flyToController;
  bool _hasNavigatedToTarget = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadItems();
  }

  @override
  void dispose() {
    _flyToController?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Animated flyTo - smooth pan and zoom to target location
  void _flyTo(LatLng target, double targetZoom) {
    _flyToController?.dispose();
    _flyToController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final startCenter = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;

    final latTween = Tween<double>(
      begin: startCenter.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: startCenter.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(
      begin: startZoom,
      end: targetZoom,
    );

    final animation = CurvedAnimation(
      parent: _flyToController!,
      curve: Curves.easeInOutCubic,
    );

    _flyToController!.addListener(() {
      _mapController.move(
        LatLng(
          latTween.evaluate(animation),
          lngTween.evaluate(animation),
        ),
        zoomTween.evaluate(animation),
      );
    });

    _flyToController!.forward();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allItems = <MapItem>[];
      for (final module in ModuleRegistry.instance.active) {
        final items = await module.getItemsInRegion(MapConfig.mshRegion);
        allItems.addAll(items);
      }

      setState(() {
        _items = allItems;
        _isLoading = false;
      });

      // Navigate to target POI if specified
      _navigateToTargetIfNeeded();
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Navigate to target POI if coordinates were passed via route
  void _navigateToTargetIfNeeded() {
    if (_hasNavigatedToTarget) return;

    final lat = widget.targetLatitude;
    final lng = widget.targetLongitude;
    final poiId = widget.targetPoiId;

    if (lat != null && lng != null) {
      _hasNavigatedToTarget = true;

      // Wait for the map to be ready, then fly to target
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _flyTo(LatLng(lat, lng), 16);

        // If a POI ID was provided, open its detail sheet
        if (poiId != null) {
          final targetItem = _items.where((item) => item.id == poiId).firstOrNull;
          if (targetItem != null) {
            // Small delay to let the map animation start first
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                PoiBottomSheet.show(context, targetItem);
              }
            });
          }
        }
      });
    }
  }

  /// Berechnet die Anzahl der Items pro Kategorie
  Map<String, int> _calculateCategoryCounts() {
    final counts = <String, int>{};
    for (final item in _items) {
      final categoryName = item.category.name;
      counts[categoryName] = (counts[categoryName] ?? 0) + 1;
    }
    return counts;
  }

  /// Berechnet die Anzahl der Items pro Altersgruppe
  Map<String, int> _calculateAgeCounts() {
    final counts = <String, int>{
      '0-3': 0,
      '3-6': 0,
      '6-12': 0,
      '12+': 0,
    };

    for (final item in _items) {
      // Nur Family-Items haben Altersangaben
      if (item.moduleId == 'family') {
        final ageRange = item.metadata['ageRange'] as String?;
        if (ageRange != null && ageRange != 'alle') {
          // Prüfe Überlappung mit jeder Altersgruppe
          for (final age in counts.keys) {
            if (_rangesOverlap(ageRange, age)) {
              counts[age] = counts[age]! + 1;
            }
          }
        } else if (ageRange == 'alle') {
          // "alle" zählt zu jeder Gruppe
          for (final age in counts.keys) {
            counts[age] = counts[age]! + 1;
          }
        }
      }
    }

    return counts;
  }

  /// Prüft ob zwei Altersbereiche sich überschneiden
  bool _rangesOverlap(String range1, String range2) {
    if (range1 == 'alle' || range2 == 'alle') return true;

    final parsed1 = _parseAgeRange(range1);
    final parsed2 = _parseAgeRange(range2);

    if (parsed1 == null || parsed2 == null) return false;

    // Überlappung wenn: min1 <= max2 && min2 <= max1
    return parsed1.$1 <= parsed2.$2 && parsed2.$1 <= parsed1.$2;
  }

  /// Parst einen Altersbereich-String zu (min, max)
  (int, int)? _parseAgeRange(String range) {
    if (range == 'alle') return null;
    if (range.endsWith('+')) {
      final min = int.tryParse(range.replaceAll('+', ''));
      return min != null ? (min, 999) : null;
    }
    final parts = range.split('-');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]);
      final max = int.tryParse(parts[1]);
      return (min != null && max != null) ? (min, max) : null;
    }
    return null;
  }

  /// Prüft ob der Altersfilter angezeigt werden soll
  bool _shouldShowAgeFilter(FilterState filterState) {
    // Zeige Altersfilter nur wenn:
    // - Keine Kategorie ausgewählt ist (alle Items) ODER
    // - Family-Kategorien ausgewählt sind
    if (filterState.categories.isEmpty) return true;

    const familyCategories = {
      'playground',
      'museum',
      'nature',
      'zoo',
      'castle',
      'pool',
      'indoor',
      'farm',
      'adventure',
    };

    return filterState.categories.any(familyCategories.contains);
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterProvider);
    final filteredItems = _items.where(filterState.matches).toList();
    final activeFilterCount = filterState.categories.length;

    // Get active notices for map markers
    final noticesAsync = ref.watch(activeNoticesProvider);
    final notices = noticesAsync.valueOrNull ?? <MshNotice>[];
    // Filter to only critical and warning notices with locations
    final importantNotices = notices
        .where((n) =>
            (n.severity == NoticeSeverity.critical ||
                n.severity == NoticeSeverity.warning) &&
            n.latitude != null &&
            n.longitude != null)
        .toList();

    return Scaffold(
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════
          // MAP AREA - 80% des Viewports
          // ═══════════════════════════════════════════════════════════
          Expanded(
            flex: 4, // 80%
            child: Stack(
              children: [
                // Karte
                MshMapView(
                  items: filteredItems,
                  onMarkerTap: (item) => PoiBottomSheet.show(context, item),
                  mapController: _mapController,
                  notices: importantNotices,
                  onNoticeTap: (notice) {
                    // Show notice details when marker is tapped
                    _flyTo(LatLng(notice.latitude!, notice.longitude!), 16);
                  },
                ),

                // Top Overlay Container - verhindert Überlappungen
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MshSpacing.lg,
                        vertical: MshSpacing.sm,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Notice Banner (oben)
                          if (FeatureFlags.enableNoticesBanner)
                            NoticeBanner(
                              onNoticeLocationTap: (latitude, longitude) {
                                // Animated flyTo when banner is clicked
                                _flyTo(LatLng(latitude, longitude), 16);
                              },
                            ),

                          // Abstand zwischen Banner und Suchleiste
                          if (FeatureFlags.enableNoticesBanner && FeatureFlags.enableSearch)
                            const SizedBox(height: MshSpacing.xs),

                          // Suchleiste mit Autocomplete
                          if (FeatureFlags.enableSearch)
                            SearchAutocomplete(
                              items: _items,
                              onItemSelected: (item) {
                                // Karte zum ausgewählten Item bewegen
                                _mapController.move(
                                  LatLng(
                                    item.coordinates.latitude,
                                    item.coordinates.longitude,
                                  ),
                                  16, // Zoom-Level
                                );
                                // Bottom Sheet mit Details öffnen
                                PoiBottomSheet.show(context, item);
                              },
                            ),

                          // Category Quick Filter
                          CategoryQuickFilter(
                            selectedCategories: filterState.categories,
                            onCategoryToggle: (category) {
                              ref.read(filterProvider.notifier).toggleCategory(category);
                            },
                            categoryCounts: _calculateCategoryCounts(),
                          ),

                          // Age Filter (nur bei Family-Kategorien)
                          if (_shouldShowAgeFilter(filterState))
                            AgeFilterRow(
                              ageCounts: _calculateAgeCounts(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Layer Switcher (rechts, über den Zoom Controls)
                if (FeatureFlags.enableLayerSwitcher)
                  Positioned(
                    bottom: 100, // Über den Zoom Controls in MshMapView
                    right: MshSpacing.lg,
                    child: LayerSwitcher(onLayerChanged: _loadItems),
                  ),

                // Loading Overlay
                if (_isLoading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: MshColors.primary,
                        ),
                      ),
                    ),
                  ),

                // Error Banner
                if (_error != null)
                  Positioned(
                    bottom: MshSpacing.lg,
                    left: MshSpacing.lg,
                    right: MshSpacing.lg,
                    child: _ErrorBanner(error: _error!),
                  ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // BOTTOM CONTENT - 20% des Viewports
          // ═══════════════════════════════════════════════════════════
          BottomContentCard(
            poiCount: filteredItems.length,
            activeFilters: activeFilterCount,
            isLoading: _isLoading,
            onFilterTap: () {
              // Filter zurücksetzen
              ref.read(filterProvider.notifier).clearAll();
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ERROR BANNER
// ═══════════════════════════════════════════════════════════════

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(
          color: MshColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: MshColors.error,
            size: 20,
          ),
          const SizedBox(width: MshSpacing.sm),
          Expanded(
            child: Text(
              'Fehler: $error',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MshColors.error,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
