import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'shared/domain/coordinates.dart';
import 'shared/domain/map_item.dart';
import 'shared/widgets/age_filter_row.dart';
import 'shared/widgets/category_quick_filter.dart';
import 'shared/widgets/layer_switcher.dart';
import 'shared/widgets/msh_map_view.dart';
import 'shared/widgets/poi_bottom_sheet.dart';
import 'shared/widgets/search_autocomplete.dart';
import 'shared/widgets/up_next_section.dart';

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

  // Draggable Sheet Controller
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _sheetPosition = 0.25; // Start bei 25%

  // Sheet Snap Points
  static const double _minSheetSize = 0.08; // Nur Drag Handle
  static const double _midSheetSize = 0.25; // Standard (wie jetzt)
  static const double _maxSheetSize = 0.65; // Erweitert

  // Gespeicherte Kartenposition
  double? _savedLatitude;
  double? _savedLongitude;
  double? _savedZoom;
  bool _viewportLoaded = false;

  // SharedPreferences Keys
  static const _keyLatitude = 'map_last_latitude';
  static const _keyLongitude = 'map_last_longitude';
  static const _keyZoom = 'map_last_zoom';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _sheetController.addListener(_onSheetPositionChanged);
    _loadSavedViewport();
    _loadItems();
  }

  /// Lädt die gespeicherte Kartenposition
  Future<void> _loadSavedViewport() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedLatitude = prefs.getDouble(_keyLatitude);
      _savedLongitude = prefs.getDouble(_keyLongitude);
      _savedZoom = prefs.getDouble(_keyZoom);
      _viewportLoaded = true;
    });
  }

  /// Speichert die aktuelle Kartenposition (debounced)
  DateTime? _lastSaveTime;
  void _saveViewport(double latitude, double longitude, double zoom) {
    // Debounce: Speichere maximal alle 500ms
    final now = DateTime.now();
    if (_lastSaveTime != null &&
        now.difference(_lastSaveTime!).inMilliseconds < 500) {
      return;
    }
    _lastSaveTime = now;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble(_keyLatitude, latitude);
      prefs.setDouble(_keyLongitude, longitude);
      prefs.setDouble(_keyZoom, zoom);
    });
  }

  void _onSheetPositionChanged() {
    if (_sheetController.isAttached) {
      setState(() {
        _sheetPosition = _sheetController.size;
      });
    }
  }

  @override
  void dispose() {
    _flyToController?.dispose();
    _mapController.dispose();
    _sheetController.removeListener(_onSheetPositionChanged);
    _sheetController.dispose();
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

      // Spezielle Zählung für moduleId-basierte Filter (z.B. health)
      final moduleId = item.moduleId;
      if (moduleId == 'health') {
        counts['health'] = (counts['health'] ?? 0) + 1;
      }
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
  /// Verwendet half-open intervals [min, max) für exakte Gruppierung
  bool _rangesOverlap(String range1, String range2) {
    if (range1 == 'alle' || range2 == 'alle') return true;

    final parsed1 = _parseAgeRange(range1);
    final parsed2 = _parseAgeRange(range2);

    if (parsed1 == null || parsed2 == null) return false;

    // Half-open intervals: [min1, max1) overlaps [min2, max2) wenn min1 < max2 && min2 < max1
    // Damit überlappen "0-3" und "3-6" NICHT (sie grenzen nur aneinander)
    return parsed1.$1 < parsed2.$2 && parsed2.$1 < parsed1.$2;
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

    // Notice Banner Opacity basierend auf Sheet Position
    // Ausblenden wenn Sheet minimiert wird (unter 15%)
    final noticeOpacity = ((_sheetPosition - _minSheetSize) /
            (_midSheetSize - _minSheetSize))
        .clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════
          // MAP - Volle Größe im Hintergrund
          // ═══════════════════════════════════════════════════════════
          Positioned.fill(
            child: _viewportLoaded
                ? MshMapView(
                    items: filteredItems,
                    onMarkerTap: (item) => PoiBottomSheet.show(context, item),
                    mapController: _mapController,
                    notices: importantNotices,
                    onNoticeTap: (notice) {
                      _flyTo(LatLng(notice.latitude!, notice.longitude!), 16);
                    },
                    // Gespeicherte Position wiederherstellen
                    initialCenter: _savedLatitude != null && _savedLongitude != null
                        ? Coordinates(
                            latitude: _savedLatitude!,
                            longitude: _savedLongitude!,
                          )
                        : null,
                    initialZoom: _savedZoom,
                    // Position speichern bei Änderung
                    onPositionChanged: _saveViewport,
                  )
                : const SizedBox.shrink(),
          ),

          // ═══════════════════════════════════════════════════════════
          // TOP OVERLAY - Suche, Filter, Notices
          // ═══════════════════════════════════════════════════════════
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
                    // Notice Banner (mit Fade-Animation)
                    if (FeatureFlags.enableNoticesBanner)
                      AnimatedOpacity(
                        opacity: noticeOpacity,
                        duration: const Duration(milliseconds: 150),
                        child: noticeOpacity > 0
                            ? NoticeBanner(
                                onNoticeLocationTap: (latitude, longitude) {
                                  _flyTo(LatLng(latitude, longitude), 16);
                                },
                              )
                            : const SizedBox.shrink(),
                      ),

                    // Abstand
                    if (FeatureFlags.enableNoticesBanner &&
                        FeatureFlags.enableSearch &&
                        noticeOpacity > 0)
                      const SizedBox(height: MshSpacing.xs),

                    // Suchleiste
                    if (FeatureFlags.enableSearch)
                      SearchAutocomplete(
                        items: _items,
                        onItemSelected: (item) {
                          _mapController.move(
                            LatLng(
                              item.coordinates.latitude,
                              item.coordinates.longitude,
                            ),
                            16,
                          );
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

                    // Age Filter
                    if (_shouldShowAgeFilter(filterState))
                      AgeFilterRow(
                        ageCounts: _calculateAgeCounts(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Layer Switcher
          if (FeatureFlags.enableLayerSwitcher)
            Positioned(
              bottom: MediaQuery.of(context).size.height * _sheetPosition + 60,
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
              bottom: MediaQuery.of(context).size.height * _sheetPosition + 20,
              left: MshSpacing.lg,
              right: MshSpacing.lg,
              child: _ErrorBanner(error: _error!),
            ),

          // ═══════════════════════════════════════════════════════════
          // DRAGGABLE BOTTOM SHEET - Google Maps Style
          // ═══════════════════════════════════════════════════════════
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _midSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            snap: true,
            snapSizes: const [_minSheetSize, _midSheetSize, _maxSheetSize],
            builder: (context, scrollController) {
              return _DraggableBottomContent(
                scrollController: scrollController,
                poiCount: filteredItems.length,
                activeFilters: activeFilterCount,
                isLoading: _isLoading,
                isMinimized: _sheetPosition < (_minSheetSize + 0.02),
                onFilterTap: () {
                  ref.read(filterProvider.notifier).clearAll();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DRAGGABLE BOTTOM CONTENT
// ═══════════════════════════════════════════════════════════════

class _DraggableBottomContent extends StatelessWidget {
  const _DraggableBottomContent({
    required this.scrollController,
    required this.poiCount,
    required this.activeFilters,
    required this.isLoading,
    required this.isMinimized,
    this.onFilterTap,
  });

  final ScrollController scrollController;
  final int poiCount;
  final int activeFilters;
  final bool isLoading;
  final bool isMinimized;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(MshTheme.radiusXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle - immer sichtbar
          _buildDragHandle(),

          // Content - scrollbar
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                // POI Counter Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
                  child: _buildPoiCounterRow(context),
                ),

                // Weitere Inhalte nur wenn nicht minimiert
                if (!isMinimized) ...[
                  const SizedBox(height: MshSpacing.sm),

                  // Up Next Events
                  const UpNextSection(),

                  const SizedBox(height: MshSpacing.sm),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
                    child: _buildQuickActions(context),
                  ),

                  // Extra Padding für SafeArea
                  SizedBox(height: MediaQuery.of(context).padding.bottom + MshSpacing.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: MshSpacing.dragHandleWidth,
        height: MshSpacing.dragHandle,
        margin: const EdgeInsets.symmetric(vertical: MshSpacing.sm),
        decoration: BoxDecoration(
          color: MshColors.textMuted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(MshSpacing.xs),
        ),
      ),
    );
  }

  Widget _buildPoiCounterRow(BuildContext context) {
    return Row(
      children: [
        // POI Counter
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.md,
            vertical: MshSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: MshColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.place,
                size: 18,
                color: MshColors.primary,
              ),
              const SizedBox(width: MshSpacing.xs),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MshColors.primary,
                  ),
                )
              else
                Text(
                  '$poiCount ${poiCount == 1 ? 'Ort' : 'Orte'}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: MshColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        ),

        const Spacer(),

        // Filter Badge
        if (activeFilters > 0)
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MshSpacing.sm,
                vertical: MshSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: MshColors.engagementElevated.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                border: Border.all(
                  color: MshColors.engagementElevated.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 16,
                    color: MshColors.engagementElevated,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$activeFilters Filter',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: MshColors.engagementElevated,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const actions = [
      (Icons.explore, 'Entdecken', '/discover'),
      (Icons.celebration, 'Erleben', '/events'),
      (Icons.directions_bus, 'ÖPNV', '/mobility'),
    ];

    return Row(
      children: actions
          .map((action) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: action != actions.last ? MshSpacing.sm : 0,
                  ),
                  child: _QuickActionButton(
                    icon: action.$1,
                    label: action.$2,
                    route: action.$3,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MshColors.background,
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm,
            vertical: MshSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: MshColors.textSecondary,
              ),
              const SizedBox(width: MshSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: MshColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
