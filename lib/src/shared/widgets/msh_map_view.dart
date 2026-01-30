import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config/feature_flags.dart';
import '../../core/config/map_config.dart';
import '../../core/theme/msh_colors.dart';
import '../../features/analytics/application/popularity_providers.dart';
import '../../features/engagement/domain/engagement_model.dart';
import '../../features/engagement/presentation/engagement_detail_sheet.dart';
import '../../features/engagement/presentation/engagement_map_layer.dart';
import '../../modules/events/domain/notice.dart';
import '../../modules/radwege/data/radwege_repository.dart';
import '../../modules/radwege/domain/radweg_route.dart';
import '../domain/coordinates.dart';
import '../domain/map_item.dart';
import 'map/fog_of_war_layer.dart';

class MshMapView extends ConsumerStatefulWidget {

  const MshMapView({
    required this.items, super.key,
    this.onMarkerTap,
    this.initialCenter,
    this.initialZoom,
    this.showFogOfWar = true,
    this.mapController,
    this.notices = const [],
    this.onNoticeTap,
    this.onPositionChanged,
    this.onDoubleTap,
    this.showRadwege = false,
    this.onRadwegTap,
  });
  final List<MapItem> items;
  final void Function(MapItem)? onMarkerTap;
  final Coordinates? initialCenter;
  final double? initialZoom;
  final bool showFogOfWar;
  final MapController? mapController;
  final List<MshNotice> notices;
  final void Function(MshNotice)? onNoticeTap;
  final void Function(double latitude, double longitude, double zoom)? onPositionChanged;
  /// Callback für Doppeltipp auf die Karte (für Fullmap-Modus)
  final VoidCallback? onDoubleTap;
  /// Radwege auf der Karte anzeigen
  final bool showRadwege;
  /// Callback wenn ein Radweg angetippt wird
  final void Function(RadwegRoute)? onRadwegTap;

  @override
  ConsumerState<MshMapView> createState() => _MshMapViewState();
}

class _MshMapViewState extends ConsumerState<MshMapView> {
  late final MapController _mapController;
  MapItem? _hoveredItem;
  Offset? _mousePosition;
  double _currentZoom = MapConfig.defaultZoom;
  double _currentRotation = 0;
  final GlobalKey _stackKey = GlobalKey();

  // Performance: Schwellenwert für Animationen
  static const int _animationThreshold = 100; // Über 100 Marker → keine Animationen

  // Performance: Debounce für Hover-Updates
  DateTime _lastHoverUpdate = DateTime.now();
  static const Duration _hoverDebounce = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
  }

  @override
  void dispose() {
    if (widget.mapController == null) {
      _mapController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Beliebte POIs laden für goldenen Glow-Effekt
    final popularPois = ref.watch(popularPoisProvider).value ?? {};

    return Stack(
      key: _stackKey,
      children: [
        // Listener für Trackpad Pinch-to-Zoom (Web)
        // Verwendet onPointerPanZoomStart/Update für echte Trackpad-Pinch-Gesten
        // und onPointerSignal für Scroll-Wheel-Events (auch Trackpad-Scroll)
        Listener(
          onPointerPanZoomUpdate: (event) {
            // Echte Trackpad-Pinch-Geste (zwei Finger zusammen/auseinander)
            if (event.scale != 1.0) {
              final currentZoom = _mapController.camera.zoom;
              // Logarithmische Skalierung für natürlicheres Zoomen
              final zoomDelta = (event.scale - 1.0) * 2.0;
              final newZoom = (currentZoom + zoomDelta).clamp(
                MapConfig.minZoom,
                MapConfig.maxZoom,
              );
              _mapController.move(_mapController.camera.center, newZoom);
            }
          },
          onPointerSignal: (event) {
            // Scroll-Wheel und Trackpad-Scroll (zwei Finger scrollen)
            if (event is PointerScrollEvent) {
              final currentZoom = _mapController.camera.zoom;
              // scrollDelta.dy: negativ = nach oben scrollen = reinzoomen
              final zoomDelta = -event.scrollDelta.dy * 0.002;
              final newZoom = (currentZoom + zoomDelta).clamp(
                MapConfig.minZoom,
                MapConfig.maxZoom,
              );
              _mapController.move(_mapController.camera.center, newZoom);
            }
          },
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  widget.initialCenter?.toLatLng() ?? MapConfig.defaultCenter.toLatLng(),
              initialZoom: widget.initialZoom ?? MapConfig.defaultZoom,
              minZoom: MapConfig.minZoom,
              maxZoom: MapConfig.maxZoom,
              interactionOptions: const InteractionOptions(
                pinchZoomThreshold: 0.1,      // Niedrigerer Threshold für sensitiveres Pinch
                pinchMoveThreshold: 20,       // Bewegungsschwelle für Pinch-to-pan
                rotationThreshold: 50,
                enableMultiFingerGestureRace: true,
              ),
              onPositionChanged: (position, hasGesture) {
                final newZoom = position.zoom ?? MapConfig.defaultZoom;
                final newRotation = _mapController.camera.rotation;
                if (_currentZoom != newZoom || _currentRotation != newRotation) {
                  setState(() {
                    _currentZoom = newZoom;
                    _currentRotation = newRotation;
                  });
                }
                if (hasGesture) {
                  widget.onPositionChanged?.call(
                    position.center.latitude,
                    position.center.longitude,
                    position.zoom,
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapConfig.tileUrlTemplate,
                userAgentPackageName: MapConfig.userAgent,
              ),
              if (widget.showFogOfWar && FeatureFlags.enableFogOfWar)
                AdaptiveFogOfWarLayer(
                  currentZoom: _currentZoom,
                  useDetailedBorder: _currentZoom > 12,
                ),
              // Radwege-Polylines (Glow-Effekt)
              if (widget.showRadwege)
                PolylineLayer(
                  polylines: RadwegeRepository.allRoutes.map((route) {
                    return Polyline(
                      points: route.routePoints,
                      color: route.glowColor,
                      strokeWidth: 12,
                    );
                  }).toList(),
                ),
              // Radwege-Polylines (Hauptlinie)
              if (widget.showRadwege)
                PolylineLayer(
                  polylines: RadwegeRepository.allRoutes.map((route) {
                    return Polyline(
                      points: route.routePoints,
                      color: route.routeColor,
                      strokeWidth: 4,
                    );
                  }).toList(),
                ),
              // Performance: Marker-Clustering bei vielen Markern
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 80,
                  disableClusteringAtZoom: 16, // Bei hohem Zoom keine Cluster
                  animationsOptions: const AnimationsOptions(
                    zoom: Duration(milliseconds: 200),
                    fitBound: Duration(milliseconds: 200),
                    spiderfy: Duration(milliseconds: 200),
                  ),
                  markers: widget.items
                      .map((item) => _buildMarker(
                            item,
                            popularPois[item.id] ?? 0.0,
                            disableAnimations: widget.items.length > _animationThreshold,
                          ))
                      .toList(),
                  builder: (context, markers) {
                    // Cluster-Marker Widget
                    return Container(
                      decoration: BoxDecoration(
                        color: MshColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Polylines für Straßensperrungen (vor Markern, damit Marker oben liegen)
              if (widget.notices.any((n) => n.hasRoute))
                PolylineLayer(
                  polylines: widget.notices
                      .where((n) => n.hasRoute)
                      .map(_buildNoticePolyline)
                      .toList(),
                ),
              if (widget.notices.isNotEmpty)
                MarkerLayer(
                  markers: widget.notices
                      .where((n) => n.latitude != null && n.longitude != null)
                      .map(_buildNoticeMarker)
                      .toList(),
                ),
              if (FeatureFlags.enableEngagementOnMap)
                EngagementMapLayer(
                  onPlaceTap: _showEngagementSheet,
                ),
            ],
          ),
        ), // Listener

        // Map Controls (Zoom + Kompass)
        Positioned(
          right: 16,
          bottom: 16,
          child: _MapControls(
            controller: _mapController,
            currentRotation: _currentRotation,
          ),
        ),

        // Hover Tooltip
        if (_hoveredItem != null && _mousePosition != null)
          Positioned(
            left: _mousePosition!.dx + 10,
            top: _mousePosition!.dy + 10,
            child: _HoverTooltip(item: _hoveredItem!),
          ),
      ],
    );
  }

  Marker _buildMarker(MapItem item, double popularityScore, {required bool disableAnimations}) {
    final isPopular = popularityScore > 0;
    // Beliebte POIs bekommen größere Marker für bessere Sichtbarkeit
    final markerSize = isPopular ? 48.0 : 40.0;

    return Marker(
      point: item.coordinates.toLatLng(),
      width: markerSize,
      height: markerSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredItem = item),
        onExit: (_) => setState(() {
          _hoveredItem = null;
          _mousePosition = null;
        }),
        onHover: (event) {
          // Performance: Debounce hover updates
          final now = DateTime.now();
          if (now.difference(_lastHoverUpdate) < _hoverDebounce) return;
          _lastHoverUpdate = now;

          final stackBox =
              _stackKey.currentContext?.findRenderObject() as RenderBox?;
          if (stackBox != null) {
            final localPos = stackBox.globalToLocal(event.position);
            setState(() => _mousePosition = localPos);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onMarkerTap?.call(item),
          child: isPopular
              ? _PopularMarkerIcon(
                  category: item.category,
                  color: item.markerColor,
                  opacity: item.markerOpacity,
                  popularityScore: popularityScore,
                  disableAnimation: disableAnimations,
                )
              : _MarkerIcon(
                  category: item.category,
                  color: item.markerColor,
                  opacity: item.markerOpacity,
                ),
        ),
      ),
    );
  }

  Polyline _buildNoticePolyline(MshNotice notice) {
    return Polyline(
      points: notice.routeCoordinates!,
      strokeWidth: 6,
      color: notice.color.withValues(alpha: 0.8),
      borderColor: Colors.white,
      borderStrokeWidth: 2,
      // flutter_map 8.x: isDotted ersetzt durch pattern
      pattern: notice.severity == NoticeSeverity.warning
          ? const StrokePattern.dotted()
          : const StrokePattern.solid(),
    );
  }

  Marker _buildNoticeMarker(MshNotice notice) {
    return Marker(
      point: LatLng(notice.latitude!, notice.longitude!),
      width: 48,
      height: 48,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onNoticeTap?.call(notice),
        child: _NoticeMarkerIcon(notice: notice),
      ),
    );
  }

  void _showEngagementSheet(EngagementPlace place) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EngagementDetailSheet(place: place),
    );
  }
}

// Map Controls Widget (Zoom + Kompass)
class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.controller,
    required this.currentRotation,
  });

  final MapController controller;
  final double currentRotation;

  @override
  Widget build(BuildContext context) {
    final isRotated = currentRotation.abs() > 0.5; // Mehr als 0.5° gedreht

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kompass-Button (nur wenn Karte gedreht ist)
        if (isRotated) ...[
          _CompassButton(
            rotation: currentRotation,
            onPressed: () => controller.rotate(0),
          ),
          const SizedBox(height: 8),
        ],
        // Zoom-Buttons
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final zoom = controller.camera.zoom;
                  final newZoom = (zoom + 1).clamp(MapConfig.minZoom, MapConfig.maxZoom);
                  controller.move(controller.camera.center, newZoom);
                },
                tooltip: 'Hineinzoomen',
              ),
              const Divider(height: 1),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final zoom = controller.camera.zoom;
                  final newZoom = (zoom - 1).clamp(MapConfig.minZoom, MapConfig.maxZoom);
                  controller.move(controller.camera.center, newZoom);
                },
                tooltip: 'Herauszoomen',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Kompass-Button Widget
class _CompassButton extends StatelessWidget {
  const _CompassButton({
    required this.rotation,
    required this.onPressed,
  });

  final double rotation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: -rotation * (3.14159265359 / 180), // Grad zu Radiant
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Norden-Pfeil (rot)
                Positioned(
                  top: 8,
                  child: Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Süden-Pfeil (grau)
                Positioned(
                  bottom: 8,
                  child: Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Mittelpunkt
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54, width: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        item.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isOpenNow != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.isOpenNow!
                              ? MshColors.success.withValues(alpha: 0.15)
                              : MshColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.isOpenNow! ? 'Offen' : 'Zu',
                          style: TextStyle(
                            color: item.isOpenNow!
                                ? MshColors.success
                                : MshColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
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
          ),
        ],
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
        MapItemCategory.playground => Icons.child_care,
        MapItemCategory.museum => Icons.account_balance,
        MapItemCategory.nature => Icons.park,
        MapItemCategory.zoo => Icons.pets,
        MapItemCategory.castle => Icons.castle,
        MapItemCategory.pool => Icons.pool,
        MapItemCategory.indoor => Icons.house,
        MapItemCategory.farm => Icons.agriculture,
        MapItemCategory.adventure => Icons.terrain,
        // Bildung
        MapItemCategory.school => Icons.school,
        MapItemCategory.kindergarten => Icons.child_care,
        MapItemCategory.library => Icons.local_library,
        // Outdoor / Wandern
        MapItemCategory.hikingStamp => Icons.hiking,
        // Civic
        MapItemCategory.government => Icons.account_balance,
        MapItemCategory.youthCentre => Icons.group,
        MapItemCategory.socialFacility => Icons.volunteer_activism,
        // Gesundheit
        MapItemCategory.doctor => Icons.medical_services,
        MapItemCategory.pharmacy => Icons.local_pharmacy,
        MapItemCategory.hospital => Icons.local_hospital,
        MapItemCategory.physiotherapy => Icons.spa,
        MapItemCategory.fitness => Icons.fitness_center,
        MapItemCategory.careService => Icons.elderly,
        MapItemCategory.defibrillator => Icons.favorite,
        // Nachtleben
        MapItemCategory.pub => Icons.sports_bar,
        MapItemCategory.cocktailbar => Icons.wine_bar,
        MapItemCategory.club => Icons.nightlife,
        // Other
        MapItemCategory.service => Icons.build,
        MapItemCategory.search => Icons.search,
        MapItemCategory.custom => Icons.place,
      };
}

class _MarkerIcon extends StatelessWidget {

  const _MarkerIcon({
    required this.category,
    required this.color,
    this.opacity = 1.0,
  });
  final MapItemCategory category;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand sorgt dafür, dass die volle Marker-Fläche tappbar ist
    return SizedBox.expand(
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(_iconFor(category), color: Colors.white, size: 20),
          ),
        ),
      ),
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
        MapItemCategory.playground => Icons.child_care,
        MapItemCategory.museum => Icons.account_balance,
        MapItemCategory.nature => Icons.park,
        MapItemCategory.zoo => Icons.pets,
        MapItemCategory.castle => Icons.castle,
        MapItemCategory.pool => Icons.pool,
        MapItemCategory.indoor => Icons.house,
        MapItemCategory.farm => Icons.agriculture,
        MapItemCategory.adventure => Icons.terrain,
        // Bildung
        MapItemCategory.school => Icons.school,
        MapItemCategory.kindergarten => Icons.child_care,
        MapItemCategory.library => Icons.local_library,
        // Outdoor / Wandern
        MapItemCategory.hikingStamp => Icons.hiking,
        // Civic
        MapItemCategory.government => Icons.account_balance,
        MapItemCategory.youthCentre => Icons.group,
        MapItemCategory.socialFacility => Icons.volunteer_activism,
        // Gesundheit
        MapItemCategory.doctor => Icons.medical_services,
        MapItemCategory.pharmacy => Icons.local_pharmacy,
        MapItemCategory.hospital => Icons.local_hospital,
        MapItemCategory.physiotherapy => Icons.spa,
        MapItemCategory.fitness => Icons.fitness_center,
        MapItemCategory.careService => Icons.elderly,
        MapItemCategory.defibrillator => Icons.favorite,
        // Nachtleben
        MapItemCategory.pub => Icons.sports_bar,
        MapItemCategory.cocktailbar => Icons.wine_bar,
        MapItemCategory.club => Icons.nightlife,
        // Other
        MapItemCategory.service => Icons.build,
        MapItemCategory.search => Icons.search,
        MapItemCategory.custom => Icons.place,
      };
}

/// Marker mit goldenem Glow für beliebte POIs
/// Performance: Animation kann deaktiviert werden bei vielen Markern
class _PopularMarkerIcon extends StatefulWidget {
  const _PopularMarkerIcon({
    required this.category,
    required this.color,
    required this.popularityScore,
    this.opacity = 1.0,
    this.disableAnimation = false,
  });

  final MapItemCategory category;
  final Color color;
  final double opacity;
  final double popularityScore; // 0.5-1.0, höher = beliebter
  final bool disableAnimation; // Performance: Bei vielen Markern deaktivieren

  @override
  State<_PopularMarkerIcon> createState() => _PopularMarkerIconState();
}

class _PopularMarkerIconState extends State<_PopularMarkerIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Performance: Animation nur erstellen wenn nicht deaktiviert
    if (!widget.disableAnimation) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      )..repeat(reverse: true);

      _glowAnimation = Tween<double>(begin: 0.4, end: 1).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Performance: Statischer Marker ohne Animation
    if (widget.disableAnimation) {
      return _buildStaticMarker();
    }

    // Glow-Intensität basiert auf Popularity-Score
    final baseGlowIntensity = widget.popularityScore * 0.6;

    // SizedBox.expand sorgt dafür, dass die volle Marker-Fläche tappbar ist
    return SizedBox.expand(
      child: Center(
        child: AnimatedBuilder(
          animation: _glowAnimation!,
          builder: (context, child) {
            final glowIntensity = baseGlowIntensity * _glowAnimation!.value;

            return Opacity(
              opacity: widget.opacity,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Performance: Nur ein BoxShadow statt 3
                    BoxShadow(
                      color: MshColors.popularityGold.withValues(alpha: glowIntensity),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: _buildMarkerCore(),
        ),
      ),
    );
  }

  /// Statischer Marker ohne Animation (Performance-Modus)
  Widget _buildStaticMarker() {
    // SizedBox.expand sorgt dafür, dass die volle Marker-Fläche tappbar ist
    return SizedBox.expand(
      child: Center(
        child: Opacity(
          opacity: widget.opacity,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: MshColors.popularityGold,
                  width: 2.5,
                ),
              ),
              child: Icon(
                _iconFor(widget.category),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Kern des Markers (für AnimatedBuilder child)
  Widget _buildMarkerCore() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: MshColors.popularityGold,
          width: 2.5,
        ),
      ),
      child: Icon(
        _iconFor(widget.category),
        color: Colors.white,
        size: 20,
      ),
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
        MapItemCategory.playground => Icons.child_care,
        MapItemCategory.museum => Icons.account_balance,
        MapItemCategory.nature => Icons.park,
        MapItemCategory.zoo => Icons.pets,
        MapItemCategory.castle => Icons.castle,
        MapItemCategory.pool => Icons.pool,
        MapItemCategory.indoor => Icons.house,
        MapItemCategory.farm => Icons.agriculture,
        MapItemCategory.adventure => Icons.terrain,
        // Bildung
        MapItemCategory.school => Icons.school,
        MapItemCategory.kindergarten => Icons.child_care,
        MapItemCategory.library => Icons.local_library,
        // Outdoor / Wandern
        MapItemCategory.hikingStamp => Icons.hiking,
        // Civic
        MapItemCategory.government => Icons.account_balance,
        MapItemCategory.youthCentre => Icons.group,
        MapItemCategory.socialFacility => Icons.volunteer_activism,
        // Gesundheit
        MapItemCategory.doctor => Icons.medical_services,
        MapItemCategory.pharmacy => Icons.local_pharmacy,
        MapItemCategory.hospital => Icons.local_hospital,
        MapItemCategory.physiotherapy => Icons.spa,
        MapItemCategory.fitness => Icons.fitness_center,
        MapItemCategory.careService => Icons.elderly,
        MapItemCategory.defibrillator => Icons.favorite,
        // Nachtleben
        MapItemCategory.pub => Icons.sports_bar,
        MapItemCategory.cocktailbar => Icons.wine_bar,
        MapItemCategory.club => Icons.nightlife,
        // Other
        MapItemCategory.service => Icons.build,
        MapItemCategory.search => Icons.search,
        MapItemCategory.custom => Icons.place,
      };
}

/// Notice/Warning Marker with pulsing animation
class _NoticeMarkerIcon extends StatefulWidget {
  const _NoticeMarkerIcon({required this.notice});

  final MshNotice notice;

  @override
  State<_NoticeMarkerIcon> createState() => _NoticeMarkerIconState();
}

class _NoticeMarkerIconState extends State<_NoticeMarkerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.notice.color;
    final icon = widget.notice.icon;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
