import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'shared/widgets/health_filter_row.dart';
import 'shared/widgets/msh_map_view.dart';
import 'shared/widgets/poi_bottom_sheet.dart';
import 'shared/widgets/poi_list_view.dart';
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

  // Fullmap Modus - blendet alles außer Suche+Filter aus
  bool _isFullMapMode = false;

  // Listenansicht Modus - Alternative zur Karte für Senioren
  bool _isListViewMode = false;

  // Radwege auf der Karte anzeigen (Standard: AN)
  bool _showRadwege = true;

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
      final newPosition = _sheetController.size;
      // Nur updaten wenn sich die Position signifikant geändert hat (>1%)
      // Dies verhindert unnötige Rebuilds während des Draggings
      if ((newPosition - _sheetPosition).abs() > 0.01) {
        setState(() {
          _sheetPosition = newPosition;
        });
      }
    }
  }

  /// Fullmap-Modus umschalten (Doppeltipp auf Karte)
  void _toggleFullMapMode() {
    setState(() {
      _isFullMapMode = !_isFullMapMode;
      // Im Fullmap-Modus das Bottom Sheet minimieren
      if (_isFullMapMode && _sheetController.isAttached) {
        _sheetController.animateTo(
          _minSheetSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Feedback-Sheet anzeigen ("Fehlt dir was?")
  void _showFeedbackSheet(BuildContext context) {
    final center = _mapController.camera.center;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeedbackSheet(
        latitude: center.latitude,
        longitude: center.longitude,
      ),
    );
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
      debugPrint('📦 Loading items from ${ModuleRegistry.instance.active.length} modules');
      for (final module in ModuleRegistry.instance.active) {
        final items = await module.getItemsInRegion(MapConfig.mshRegion);
        debugPrint('  → ${module.moduleId}: ${items.length} items');
        allItems.addAll(items);
      }
      debugPrint('📦 Total loaded: ${allItems.length} items');

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
    debugPrint('🔍 _calculateCategoryCounts: ${_items.length} total items');
    for (final item in _items) {
      final categoryName = item.category.name;
      counts[categoryName] = (counts[categoryName] ?? 0) + 1;

      // Spezielle Zählung für moduleId-basierte Filter (z.B. health)
      final moduleId = item.moduleId;
      if (moduleId == 'health') {
        counts['health'] = (counts['health'] ?? 0) + 1;
      }

      // Bildung: school, kindergarten, library → education
      if (categoryName == 'school' ||
          categoryName == 'kindergarten' ||
          categoryName == 'library') {
        counts['education'] = (counts['education'] ?? 0) + 1;
      }

      // Civic: government, youthCentre, socialFacility → civic
      if (categoryName == 'government' ||
          categoryName == 'youthCentre' ||
          categoryName == 'socialFacility') {
        counts['civic'] = (counts['civic'] ?? 0) + 1;
      }
    }
    debugPrint('📊 Category counts: health=${counts['health']}, civic=${counts['civic']}, pool=${counts['pool']}');
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

  /// Prüft ob der Health-Filter angezeigt werden soll
  bool _shouldShowHealthFilter(FilterState filterState) {
    return filterState.categories.contains('health');
  }

  /// Berechnet die Anzahl pro Health-Kategorie
  Map<String, int> _calculateHealthCategoryCounts() {
    final counts = <String, int>{};
    for (final item in _items.where((i) => i.moduleId == 'health')) {
      final cat = item.metadata['healthCategory'] as String?;
      if (cat != null) {
        counts[cat] = (counts[cat] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Berechnet die Anzahl pro Facharzt-Spezialisierung
  Map<String, int> _calculateSpecializationCounts() {
    final counts = <String, int>{};
    for (final item in _items.where((i) =>
        i.moduleId == 'health' &&
        i.metadata['healthCategory'] == 'doctor',)) {
      final spec = item.metadata['specialization'] as String?;
      if (spec != null) {
        counts[spec] = (counts[spec] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Header für die Listenansicht mit Toggle-Button
  Widget _buildListViewHeader(BuildContext context, int itemCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        MshSpacing.lg,
        MshSpacing.md,
        MshSpacing.lg,
        MshSpacing.sm,
      ),
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
      child: Row(
        children: [
          // Icon und Titel
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MshColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.list,
              color: MshColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: MshSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Listenansicht',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: MshColors.textStrong,
                      ),
                ),
                Text(
                  '$itemCount ${itemCount == 1 ? 'Ort' : 'Orte'} gefunden',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MshColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Toggle zur Karte
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _isListViewMode = false;
              });
            },
            icon: const Icon(Icons.map, size: 18),
            label: const Text('Karte'),
            style: FilledButton.styleFrom(
              backgroundColor: MshColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: MshSpacing.md,
                vertical: MshSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterProvider);
    final filteredItems = _items.where(filterState.matches).toList();
    final activeFilterCount = filterState.categories.length;

    // Get active notices for map markers
    final noticesAsync = ref.watch(activeNoticesProvider);
    final notices = noticesAsync.value ?? <MshNotice>[];
    // Filter to only critical and warning notices with locations
    final importantNotices = notices
        .where((n) =>
            (n.severity == NoticeSeverity.critical ||
                n.severity == NoticeSeverity.warning) &&
            n.latitude != null &&
            n.longitude != null,)
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
          // MAP oder LISTE - Volle Größe im Hintergrund
          // ═══════════════════════════════════════════════════════════
          Positioned.fill(
            child: _isListViewMode
                // Listenansicht für Senioren
                ? Container(
                    color: MshColors.surface,
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Header mit Toggle zurück zur Karte
                          _buildListViewHeader(context, filteredItems.length),
                          // Liste
                          Expanded(
                            child: PoiListView(
                              items: filteredItems,
                              onItemTap: (item) {
                                PoiBottomSheet.show(context, item);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // Kartenansicht (Standard)
                : _viewportLoaded
                    ? MshMapView(
                        items: filteredItems,
                        onMarkerTap: (item) => PoiBottomSheet.show(context, item),
                        mapController: _mapController,
                        notices: importantNotices,
                        onNoticeTap: (notice) {
                          _flyTo(LatLng(notice.latitude!, notice.longitude!), 16);
                        },
                        initialCenter: _savedLatitude != null && _savedLongitude != null
                            ? Coordinates(
                                latitude: _savedLatitude!,
                                longitude: _savedLongitude!,
                              )
                            : null,
                        initialZoom: _savedZoom,
                        onPositionChanged: _saveViewport,
                        onDoubleTap: _toggleFullMapMode,
                        showRadwege: _showRadwege,
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
                    // Notice Banner (ausblenden im Fullmap-Modus)
                    if (FeatureFlags.enableNoticesBanner && !_isFullMapMode)
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
                        noticeOpacity > 0 &&
                        !_isFullMapMode)
                      const SizedBox(height: MshSpacing.xs),

                    // Suchleiste - immer sichtbar
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

                    // Category Quick Filter - immer sichtbar
                    CategoryQuickFilter(
                      selectedCategories: filterState.categories,
                      onCategoryToggle: (category) {
                        ref.read(filterProvider.notifier).toggleCategory(category);
                      },
                      categoryCounts: _calculateCategoryCounts(),
                      radwegeActive: _showRadwege,
                      onRadwegeToggle: () {
                        setState(() => _showRadwege = !_showRadwege);
                      },
                    ),

                    // Age Filter (ausblenden im Fullmap-Modus)
                    if (_shouldShowAgeFilter(filterState) && !_isFullMapMode)
                      AgeFilterRow(
                        ageCounts: _calculateAgeCounts(),
                      ),

                    // Health Filter (wenn Gesundheit ausgewählt)
                    if (_shouldShowHealthFilter(filterState) && !_isFullMapMode)
                      HealthFilterRow(
                        categoryCounts: _calculateHealthCategoryCounts(),
                        specializationCounts: _calculateSpecializationCounts(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // "Fehlt dir was?" Button (ausblenden im Fullmap-Modus)
          if (!_isFullMapMode)
            Positioned(
              bottom: MediaQuery.of(context).size.height * _sheetPosition + 16,
              right: MshSpacing.lg,
              child: _FeedbackButton(
                onPressed: () => _showFeedbackSheet(context),
              ),
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

          // Error Banner (ausblenden im Fullmap-Modus)
          if (_error != null && !_isFullMapMode)
            Positioned(
              bottom: MediaQuery.of(context).size.height * _sheetPosition + 20,
              left: MshSpacing.lg,
              right: MshSpacing.lg,
              child: _ErrorBanner(error: _error!),
            ),

          // ═══════════════════════════════════════════════════════════
          // DRAGGABLE BOTTOM SHEET - Google Maps Style
          // (ausblenden im Fullmap-Modus)
          // ═══════════════════════════════════════════════════════════
          if (!_isFullMapMode)
            DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _midSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            snap: true,
            snapSizes: const [_minSheetSize, _midSheetSize, _maxSheetSize],
            snapAnimationDuration: const Duration(milliseconds: 200),
            builder: (context, scrollController) {
              return _DraggableBottomContent(
                scrollController: scrollController,
                poiCount: filteredItems.length,
                activeFilters: activeFilterCount,
                isLoading: _isLoading,
                isMinimized: _sheetPosition < (_minSheetSize + 0.02),
                isExpanded: _sheetPosition > (_midSheetSize + 0.1),
                onFilterTap: () {
                  ref.read(filterProvider.notifier).clearAll();
                },
                onListViewTap: () {
                  setState(() {
                    _isListViewMode = true;
                  });
                },
              );
            },
          ),

          // ═══════════════════════════════════════════════════════════
          // FULLMAP-MODUS EXIT BUTTON
          // ═══════════════════════════════════════════════════════════
          if (_isFullMapMode)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + MshSpacing.lg,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: MshColors.surface,
                  borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
                  elevation: 4,
                  child: InkWell(
                    onTap: _toggleFullMapMode,
                    borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MshSpacing.lg,
                        vertical: MshSpacing.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fullscreen_exit,
                            size: 20,
                            color: MshColors.textSecondary,
                          ),
                          const SizedBox(width: MshSpacing.xs),
                          Text(
                            'Vollbild beenden',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: MshColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
    required this.isExpanded,
    this.onFilterTap,
    this.onListViewTap,
  });

  final ScrollController scrollController;
  final int poiCount;
  final int activeFilters;
  final bool isLoading;
  final bool isMinimized;
  final VoidCallback? onListViewTap;
  final bool isExpanded;
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
      child: CustomScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          // Drag Handle - immer sichtbar (non-scrolling header)
          SliverToBoxAdapter(child: _buildDragHandle()),

          // POI Counter Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
              child: _buildPoiCounterRow(context),
            ),
          ),

          // Weitere Inhalte nur wenn nicht minimiert
          if (!isMinimized) ...[
            const SliverToBoxAdapter(child: SizedBox(height: MshSpacing.sm)),

            // Up Next Events - mehr anzeigen wenn expanded
            SliverToBoxAdapter(child: UpNextSection(isExpanded: isExpanded)),

            const SliverToBoxAdapter(child: SizedBox(height: MshSpacing.sm)),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
                child: _buildQuickActions(context),
              ),
            ),

            // Extra Padding für SafeArea
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + MshSpacing.md,
              ),
            ),
          ],
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

        const SizedBox(width: MshSpacing.sm),

        // Liste-Button für Senioren
        GestureDetector(
          onTap: onListViewTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MshSpacing.sm,
              vertical: MshSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: MshColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
              border: Border.all(
                color: MshColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.list,
                  size: 16,
                  color: MshColors.info,
                ),
                const SizedBox(width: 4),
                Text(
                  'Liste',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: MshColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
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
              ),)
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

// ═══════════════════════════════════════════════════════════════
// FEEDBACK BUTTON ("Fehlt dir was?")
// ═══════════════════════════════════════════════════════════════

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MshColors.surface,
      borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.md,
            vertical: MshSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_location_alt_outlined,
                size: 20,
                color: MshColors.primary,
              ),
              const SizedBox(width: MshSpacing.xs),
              Text(
                'Fehlt was?',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: MshColors.textPrimary,
                      fontWeight: FontWeight.w500,
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
// FEEDBACK SHEET
// ═══════════════════════════════════════════════════════════════

class _FeedbackSheet extends StatelessWidget {
  const _FeedbackSheet({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MshTheme.radiusXLarge),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        MshSpacing.lg,
        MshSpacing.md,
        MshSpacing.lg,
        MediaQuery.of(context).padding.bottom + MshSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: MshSpacing.dragHandleWidth,
            height: MshSpacing.dragHandle,
            margin: const EdgeInsets.only(bottom: MshSpacing.md),
            decoration: BoxDecoration(
              color: MshColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(MshSpacing.xs),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MshSpacing.sm),
                decoration: BoxDecoration(
                  color: MshColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.add_location_alt,
                  color: MshColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: MshSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fehlt dir was?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: MshColors.textPrimary,
                          ),
                    ),
                    Text(
                      'Hilf uns, die Karte zu verbessern!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MshColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: MshSpacing.lg),

          // Feedback Options
          _FeedbackOption(
            icon: Icons.restaurant,
            title: 'Restaurant / Café fehlt',
            subtitle: 'Ein Lokal ist nicht auf der Karte',
            onTap: () => _sendFeedback(context, 'restaurant'),
          ),
          const SizedBox(height: MshSpacing.sm),
          _FeedbackOption(
            icon: Icons.child_care,
            title: 'Familienausflugsziel fehlt',
            subtitle: 'Spielplatz, Museum, Zoo, etc.',
            onTap: () => _sendFeedback(context, 'family'),
          ),
          const SizedBox(height: MshSpacing.sm),
          _FeedbackOption(
            icon: Icons.event,
            title: 'Veranstaltung melden',
            subtitle: 'Ein Event ist nicht gelistet',
            onTap: () => _sendFeedback(context, 'event'),
          ),
          const SizedBox(height: MshSpacing.sm),
          _FeedbackOption(
            icon: Icons.error_outline,
            title: 'Fehler melden',
            subtitle: 'Falsche Infos oder geschlossene Orte',
            onTap: () => _sendFeedback(context, 'error'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFeedback(BuildContext context, String type) async {
    Navigator.pop(context);

    // Kategorie-spezifische Betreff und Text
    final (subject, intro) = switch (type) {
      'restaurant' => (
        'Restaurant/Café fehlt auf der Karte',
        'Ich möchte ein Restaurant oder Café melden, das auf der Karte fehlt.',
      ),
      'family' => (
        'Familienausflugsziel fehlt',
        'Ich möchte ein Ausflugsziel für Familien melden (Spielplatz, Museum, Zoo, etc.).',
      ),
      'event' => (
        'Veranstaltung melden',
        'Ich möchte eine Veranstaltung melden, die nicht gelistet ist.',
      ),
      'error' => (
        'Fehler melden - Falsche Infos',
        'Ich möchte einen Fehler oder falsche Informationen melden.',
      ),
      _ => ('Feedback zur MSH Map', 'Ich habe Feedback zur MSH Map.'),
    };

    final body = '''
$intro

Kategorie: ${_categoryLabel(type)}

Ungefährer Standort:
- Koordinaten: ${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}
- Google Maps: https://maps.google.com/?q=$latitude,$longitude

Name des Ortes:
[Bitte ausfüllen]

Beschreibung:
[Bitte ausfüllen]

---
Gesendet über MSH Map App
''';

    final mailtoUri = Uri(
      scheme: 'mailto',
      path: 'feedback@kolan-system.de',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('E-Mail-App konnte nicht geöffnet werden'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _categoryLabel(String type) => switch (type) {
    'restaurant' => 'Restaurant / Café',
    'family' => 'Familienausflugsziel',
    'event' => 'Veranstaltung',
    'error' => 'Fehler melden',
    _ => 'Sonstiges',
  };
}

class _FeedbackOption extends StatelessWidget {
  const _FeedbackOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MshColors.background,
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: MshColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: MshColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: MshSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: MshColors.textPrimary,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MshColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: MshColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
