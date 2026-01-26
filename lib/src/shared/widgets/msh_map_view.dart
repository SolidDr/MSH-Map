import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/map_item.dart';
import '../domain/coordinates.dart';
import '../../core/config/map_config.dart';
import 'map/fog_of_war_layer.dart';

class MshMapView extends ConsumerStatefulWidget {

  const MshMapView({
    super.key,
    required this.items,
    this.onMarkerTap,
    this.initialCenter,
    this.initialZoom,
    this.showFogOfWar = true,
  });
  final List<MapItem> items;
  final void Function(MapItem)? onMarkerTap;
  final Coordinates? initialCenter;
  final double? initialZoom;
  final bool showFogOfWar;

  @override
  ConsumerState<MshMapView> createState() => _MshMapViewState();
}

class _MshMapViewState extends ConsumerState<MshMapView> {
  late final MapController _mapController;
  MapItem? _hoveredItem;
  double _currentZoom = MapConfig.defaultZoom;

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
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter:
                widget.initialCenter?.toLatLng() ?? MapConfig.defaultCenter.toLatLng(),
            initialZoom: widget.initialZoom ?? MapConfig.defaultZoom,
            minZoom: MapConfig.minZoom,
            maxZoom: MapConfig.maxZoom,
            // Enable all interactions including pinch-to-zoom on trackpad
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onPositionChanged: (position, hasGesture) {
              if (_currentZoom != position.zoom) {
                setState(() {
                  _currentZoom = position.zoom ?? MapConfig.defaultZoom;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: MapConfig.tileUrlTemplate,
              userAgentPackageName: MapConfig.userAgent,
            ),

            // Fog of War (vor den Markern, damit Marker sichtbar bleiben)
            if (widget.showFogOfWar)
              AdaptiveFogOfWarLayer(
                currentZoom: _currentZoom,
                useDetailedBorder: _currentZoom > 12,
              ),

            MarkerLayer(
              markers: widget.items.map(_buildMarker).toList(),
            ),
          ],
        ),

        // Zoom Controls
        Positioned(
          right: 16,
          bottom: 16,
          child: _ZoomControls(controller: _mapController),
        ),

        // Hover Tooltip
        if (_hoveredItem != null)
          Positioned(
            left: 16,
            bottom: 16,
            child: _HoverTooltip(item: _hoveredItem!),
          ),
      ],
    );
  }

  Marker _buildMarker(MapItem item) {
    return Marker(
      point: item.coordinates.toLatLng(),
      width: 40,
      height: 40,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredItem = item),
        onExit: (_) => setState(() => _hoveredItem = null),
        child: GestureDetector(
          onTap: () => widget.onMarkerTap?.call(item),
          child: _MarkerIcon(
            category: item.category,
            color: item.markerColor,
          ),
        ),
      ),
    );
  }
}

// Zoom Controls Widget
class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.controller});

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final zoom = controller.camera.zoom;
              controller.move(controller.camera.center, zoom + 1);
            },
            tooltip: 'Hineinzoomen',
          ),
          const Divider(height: 1),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              final zoom = controller.camera.zoom;
              controller.move(controller.camera.center, zoom - 1);
            },
            tooltip: 'Herauszoomen',
          ),
        ],
      ),
    );
  }
}

// Hover Tooltip Widget
class _HoverTooltip extends StatelessWidget {
  const _HoverTooltip({required this.item});

  final MapItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.markerColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForCategory(item.category),
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(MapItemCategory c) => switch (c) {
        // Gastro
        MapItemCategory.restaurant => Icons.restaurant,
        MapItemCategory.cafe => Icons.coffee,
        MapItemCategory.imbiss => Icons.fastfood,
        MapItemCategory.bar => Icons.local_bar,
        // Events
        MapItemCategory.event => Icons.event,
        MapItemCategory.culture => Icons.museum,
        MapItemCategory.sport => Icons.sports,
        // Family
        MapItemCategory.playground => Icons.toys,
        MapItemCategory.museum => Icons.account_balance,
        MapItemCategory.nature => Icons.park,
        MapItemCategory.zoo => Icons.pets,
        MapItemCategory.castle => Icons.castle,
        MapItemCategory.pool => Icons.pool,
        MapItemCategory.indoor => Icons.house,
        MapItemCategory.farm => Icons.agriculture,
        MapItemCategory.adventure => Icons.terrain,
        // Other
        MapItemCategory.service => Icons.build,
        MapItemCategory.search => Icons.search,
        MapItemCategory.custom => Icons.place,
      };
}

class _MarkerIcon extends StatelessWidget {

  const _MarkerIcon({required this.category, required this.color});
  final MapItemCategory category;
  final Color color;

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
        // Gastro
        MapItemCategory.restaurant => Icons.restaurant,
        MapItemCategory.cafe => Icons.coffee,
        MapItemCategory.imbiss => Icons.fastfood,
        MapItemCategory.bar => Icons.local_bar,
        // Events
        MapItemCategory.event => Icons.event,
        MapItemCategory.culture => Icons.museum,
        MapItemCategory.sport => Icons.sports,
        // Family
        MapItemCategory.playground => Icons.toys,
        MapItemCategory.museum => Icons.account_balance,
        MapItemCategory.nature => Icons.park,
        MapItemCategory.zoo => Icons.pets,
        MapItemCategory.castle => Icons.castle,
        MapItemCategory.pool => Icons.pool,
        MapItemCategory.indoor => Icons.house,
        MapItemCategory.farm => Icons.agriculture,
        MapItemCategory.adventure => Icons.terrain,
        // Other
        MapItemCategory.service => Icons.build,
        MapItemCategory.search => Icons.search,
        MapItemCategory.custom => Icons.place,
      };
}
