import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/analytics/presentation/analytics_dashboard_screen.dart';
import 'shared/widgets/msh_map_view.dart';
import 'shared/widgets/layer_switcher.dart';
import 'shared/widgets/poi_bottom_sheet.dart';
import 'shared/widgets/category_quick_filter.dart';
import 'shared/domain/map_item.dart';
import 'modules/_module_registry.dart';
import 'modules/events/presentation/widgets/notice_banner.dart';
import 'modules/events/presentation/widgets/upcoming_events_widget.dart';
import 'core/config/map_config.dart';
import 'core/providers/filter_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<MapItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
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
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showEventsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  const Text(
                    'Events in MSH',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: UpcomingEventsWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterProvider);

    // Apply filters to items
    final filteredItems = _items.where((item) => filterState.matches(item)).toList();

    // Count items per category
    final categoryCounts = <String, int>{};
    for (final item in _items) {
      final categoryKey = item.category.name;
      categoryCounts[categoryKey] = (categoryCounts[categoryKey] ?? 0) + 1;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Karte
          MshMapView(
            items: filteredItems,
            onMarkerTap: (item) => PoiBottomSheet.show(context, item),
          ),

          // Notice Banner (at top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: const NoticeBanner(),
          ),

          // Suchleiste
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 16,
            right: 16,
            child: _SearchBar(
              onTap: () {
                // TODO: Zur Suchseite navigieren
              },
            ),
          ),

          // Category Quick Filter
          if (!_isLoading && _items.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 132,
              left: 0,
              right: 0,
              child: CategoryQuickFilter(
                selectedCategories: filterState.categories,
                onCategoryToggle: (category) {
                  ref.read(filterProvider.notifier).toggleCategory(category);
                },
                categoryCounts: categoryCounts,
              ),
            ),

          // POI Counter & Analytics Button
          if (!_isLoading && _items.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 188,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PoiCounter(count: filteredItems.length),
                  _AnalyticsButton(
                    onTap: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const AnalyticsDashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          // Upcoming Events (bottom sheet trigger)
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'events',
              onPressed: () => _showEventsSheet(context),
              backgroundColor: Colors.deepPurple,
              icon: const Icon(Icons.event, color: Colors.white),
              label: const Text(
                'Events',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Loading
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          // Error
          if (_error != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Fehler: $_error'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accessibility Button
          FloatingActionButton.small(
            heroTag: 'accessibility',
            onPressed: () => context.push('/accessibility'),
            backgroundColor: Colors.purple,
            tooltip: 'Barrierefreiheit',
            child: const Icon(Icons.accessibility_new, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          // Suggest Location Button
          FloatingActionButton(
            heroTag: 'suggest',
            onPressed: () => context.push('/suggest-location'),
            backgroundColor: Colors.green,
            tooltip: 'Fehlt etwas?',
            child: const Icon(Icons.add_location_alt, color: Colors.white),
          ),
          const SizedBox(height: 12),
          LayerSwitcher(onLayerChanged: _loadItems),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {

  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'In MSH suchen...',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PoiCounter extends StatelessWidget {
  const _PoiCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              '$count ${count == 1 ? 'Ort' : 'Orte'}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsButton extends StatelessWidget {
  const _AnalyticsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.blueAccent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.analytics, size: 18, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
