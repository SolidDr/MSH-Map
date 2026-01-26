# 04 - Phase B: Map Widgets

## Ziel
Zentrale Kartenansicht und UI-Komponenten erstellen.

---

## Schritt B1: Dependencies hinzufügen

In `pubspec.yaml` unter `dependencies:` hinzufügen:

```yaml
  # Karten
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  geolocator: ^11.0.0
```

Dann ausführen:
```bash
flutter pub get
```

**Checkpoint:** `✅ B1 - Dependencies installiert`

---

## Schritt B2: MshMapView erstellen

Erstelle `lib/src/shared/widgets/msh_map_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/map_item.dart';
import '../domain/coordinates.dart';
import '../../core/config/map_config.dart';

class MshMapView extends ConsumerStatefulWidget {
  final List<MapItem> items;
  final void Function(MapItem)? onMarkerTap;
  final Coordinates? initialCenter;
  final double? initialZoom;
  
  const MshMapView({
    super.key,
    required this.items,
    this.onMarkerTap,
    this.initialCenter,
    this.initialZoom,
  });
  
  @override
  ConsumerState<MshMapView> createState() => _MshMapViewState();
}

class _MshMapViewState extends ConsumerState<MshMapView> {
  late final MapController _mapController;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }
  
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter?.toLatLng() ?? 
            MapConfig.defaultCenter.toLatLng(),
        initialZoom: widget.initialZoom ?? MapConfig.defaultZoom,
        minZoom: MapConfig.minZoom,
        maxZoom: MapConfig.maxZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: MapConfig.tileUrlTemplate,
          userAgentPackageName: MapConfig.userAgent,
        ),
        MarkerLayer(
          markers: widget.items.map(_buildMarker).toList(),
        ),
      ],
    );
  }
  
  Marker _buildMarker(MapItem item) {
    return Marker(
      point: item.coordinates.toLatLng(),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => widget.onMarkerTap?.call(item),
        child: _MarkerIcon(
          category: item.category,
          color: item.markerColor,
        ),
      ),
    );
  }
}

class _MarkerIcon extends StatelessWidget {
  final MapItemCategory category;
  final Color color;
  
  const _MarkerIcon({required this.category, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(_iconFor(category), color: Colors.white, size: 24),
    );
  }
  
  IconData _iconFor(MapItemCategory c) => switch (c) {
    MapItemCategory.restaurant => Icons.restaurant,
    MapItemCategory.cafe => Icons.coffee,
    MapItemCategory.imbiss => Icons.fastfood,
    MapItemCategory.bar => Icons.local_bar,
    MapItemCategory.event => Icons.event,
    MapItemCategory.culture => Icons.museum,
    MapItemCategory.sport => Icons.sports,
    MapItemCategory.nature => Icons.park,
    MapItemCategory.service => Icons.build,
    MapItemCategory.search => Icons.search,
    MapItemCategory.custom => Icons.place,
  };
}

// Extension für Koordinaten
extension CoordinatesToLatLng on Coordinates {
  LatLng toLatLng() => LatLng(latitude, longitude);
}
```

**Checkpoint:** `✅ B2 - MshMapView erstellt`

---

## Schritt B3: LayerSwitcher erstellen

Erstelle `lib/src/shared/widgets/layer_switcher.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../modules/_module_registry.dart';

class LayerSwitcher extends ConsumerStatefulWidget {
  final VoidCallback? onLayerChanged;
  
  const LayerSwitcher({super.key, this.onLayerChanged});
  
  @override
  ConsumerState<LayerSwitcher> createState() => _LayerSwitcherState();
}

class _LayerSwitcherState extends ConsumerState<LayerSwitcher> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    final modules = ModuleRegistry.instance.all;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded) ...[
          for (final module in modules)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ModuleButton(
                module: module,
                isActive: ModuleRegistry.instance.active.contains(module),
                onToggle: () {
                  setState(() {
                    final active = ModuleRegistry.instance.active.contains(module);
                    ModuleRegistry.instance.setActive(module.moduleId, !active);
                  });
                  widget.onLayerChanged?.call();
                },
              ),
            ),
        ],
        FloatingActionButton(
          heroTag: 'layer_switcher_main',
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.layers),
          ),
        ),
      ],
    );
  }
}

class _ModuleButton extends StatelessWidget {
  final MshModule module;
  final bool isActive;
  final VoidCallback onToggle;
  
  const _ModuleButton({
    required this.module,
    required this.isActive,
    required this.onToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: module.displayName,
      child: FloatingActionButton.small(
        heroTag: 'module_${module.moduleId}',
        backgroundColor: isActive ? module.primaryColor : Colors.grey,
        onPressed: onToggle,
        child: Icon(module.icon, color: Colors.white),
      ),
    );
  }
}
```

**Checkpoint:** `✅ B3 - LayerSwitcher erstellt`

---

## Schritt B4: PoiBottomSheet erstellen

Erstelle `lib/src/shared/widgets/poi_bottom_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import '../domain/map_item.dart';
import '../../modules/_module_registry.dart';

class PoiBottomSheet extends StatelessWidget {
  final MapItem item;
  
  const PoiBottomSheet({super.key, required this.item});
  
  static void show(BuildContext context, MapItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PoiBottomSheet(item: item),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final module = ModuleRegistry.instance.getById(item.moduleId);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.markerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.place, color: item.markerColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.displayName,
                              style: Theme.of(context).textTheme.titleLarge),
                          if (item.subtitle != null)
                            Text(item.subtitle!,
                                style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                // Modul-Detail
                if (module != null)
                  module.buildDetailView(context, item)
                else
                  const Text('Keine Details verfügbar'),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

**Checkpoint:** `✅ B4 - PoiBottomSheet erstellt`

---

## Schritt B5: Alte Widgets verschieben

```bash
# Falls vorhanden, kopieren (nicht löschen!)
cp lib/src/common_widgets/*.dart lib/src/shared/widgets/ 2>/dev/null || true

# Alt-Ordner nach _deprecated
mv lib/src/common_widgets lib/_deprecated/ 2>/dev/null || true
```

**Checkpoint:** `✅ B5 - Widgets migriert`

---

## Schritt B6: Validierung

```bash
flutter analyze
```

---

## Phase B Checkliste

```markdown
## PHASE B CHECKLIST:
- [ ] B1: Dependencies in pubspec.yaml
- [ ] B1: flutter pub get erfolgreich
- [ ] B2: msh_map_view.dart kompiliert
- [ ] B3: layer_switcher.dart kompiliert
- [ ] B4: poi_bottom_sheet.dart kompiliert
- [ ] B5: Alte Widgets verschoben
- [ ] B6: `flutter analyze` = 0 errors
```

**WEITER MIT:** `05_PHASE_C_GASTRO_MODULE.md`