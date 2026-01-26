import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/widgets/msh_map_view.dart';
import 'shared/widgets/layer_switcher.dart';
import 'shared/widgets/poi_bottom_sheet.dart';
import 'shared/domain/map_item.dart';
import 'modules/_module_registry.dart';
import 'core/config/map_config.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Karte
          MshMapView(
            items: _items,
            onMarkerTap: (item) => PoiBottomSheet.show(context, item),
          ),

          // Suchleiste
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _SearchBar(
              onTap: () {
                // TODO: Zur Suchseite navigieren
              },
            ),
          ),

          // POI Counter
          if (!_isLoading && _items.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              child: _PoiCounter(count: _items.length),
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
      floatingActionButton: LayerSwitcher(onLayerChanged: _loadItems),
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
