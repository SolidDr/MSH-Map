import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/map_config.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../features/analytics/data/usage_analytics_service.dart';
import '../../wanderwege/data/wanderwege_repository.dart';
import '../../wanderwege/domain/wanderweg_category.dart';
import '../../wanderwege/domain/wanderweg_route.dart';
import '../data/radwege_repository.dart';
import '../domain/radweg_category.dart';
import '../domain/radweg_route.dart';

/// Radeln & Wandern Screen mit Tab-Navigation
class RadwegeScreen extends StatefulWidget {
  const RadwegeScreen({super.key});

  @override
  State<RadwegeScreen> createState() => _RadwegeScreenState();
}

class _RadwegeScreenState extends State<RadwegeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    UsageAnalyticsService().trackModuleVisit('radwege');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MshColors.primary.withAlpha(220),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Radeln & Wandern'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.directions_bike),
              text: 'Radwege',
            ),
            Tab(
              icon: Icon(Icons.hiking),
              text: 'Wanderwege',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RadwegeTab(),
          _WanderwegeTab(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RADWEGE TAB
// ═══════════════════════════════════════════════════════════════

class _RadwegeTab extends StatefulWidget {
  const _RadwegeTab();

  @override
  State<_RadwegeTab> createState() => _RadwegeTabState();
}

class _RadwegeTabState extends State<_RadwegeTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  late AnimationController _animationController;

  final Set<String> _selectedRouteIds = {};
  RadwegRoute? _focusedRoute;
  bool _showInfoPanel = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Keine Radwege standardmäßig ausgewählt (leeres Set = alle anzeigen, wie bei Kategorien)
    // Wenn User einen auswählt, werden nur ausgewählte angezeigt
    _focusedRoute = RadwegeRepository.allRoutes.isNotEmpty
        ? RadwegeRepository.allRoutes.first
        : null;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<RadwegRoute> get _selectedRoutes {
    // Wie bei Kategorien: leeres Set = alle anzeigen
    if (_selectedRouteIds.isEmpty) {
      return RadwegeRepository.allRoutes;
    }
    return RadwegeRepository.allRoutes
        .where((r) => _selectedRouteIds.contains(r.id))
        .toList();
  }

  void _toggleRoute(RadwegRoute route) {
    setState(() {
      if (_selectedRouteIds.contains(route.id)) {
        _selectedRouteIds.remove(route.id);
        if (_focusedRoute?.id == route.id) {
          _focusedRoute = _selectedRoutes.isNotEmpty ? _selectedRoutes.first : null;
        }
      } else {
        _selectedRouteIds.add(route.id);
        _focusedRoute = route;
      }
    });

    if (_focusedRoute != null) {
      _mapController.move(_focusedRoute!.center, _focusedRoute!.overviewZoom);
    }
  }

  void _focusRoute(RadwegRoute route) {
    setState(() {
      _focusedRoute = route;
      if (!_selectedRouteIds.contains(route.id)) {
        _selectedRouteIds.add(route.id);
      }
    });
    _mapController.move(route.center, route.overviewZoom);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _focusedRoute?.center ?? MapConfig.defaultCenter.toLatLng(),
            initialZoom: _focusedRoute?.overviewZoom ?? MapConfig.defaultZoom,
            minZoom: MapConfig.minZoom,
            maxZoom: MapConfig.maxZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: MapConfig.tileUrlTemplate,
              userAgentPackageName: MapConfig.userAgent,
            ),
            PolylineLayer(
              polylines: _selectedRoutes.map((route) {
                return Polyline(
                  points: route.routePoints,
                  color: route.glowColor,
                  strokeWidth: 14,
                );
              }).toList(),
            ),
            PolylineLayer(
              polylines: _selectedRoutes.map((route) {
                final isFocused = route.id == _focusedRoute?.id;
                return Polyline(
                  points: route.routePoints,
                  color: route.routeColor,
                  strokeWidth: isFocused ? 5 : 3,
                );
              }).toList(),
            ),
            if (_focusedRoute != null)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return MarkerLayer(
                    markers: _buildAnimatedMarkers(_focusedRoute!, Icons.pedal_bike),
                  );
                },
              ),
            if (_focusedRoute != null)
              MarkerLayer(
                markers: _buildPoiMarkers(_focusedRoute!),
              ),
          ],
        ),
        Positioned(
          top: MshSpacing.sm,
          left: MshSpacing.sm,
          right: MshSpacing.sm,
          child: _RadwegeFilterChips(
            routes: RadwegeRepository.allRoutes,
            selectedIds: _selectedRouteIds,
            focusedId: _focusedRoute?.id,
            onToggle: _toggleRoute,
            onFocus: _focusRoute,
          ),
        ),
        if (_showInfoPanel && _focusedRoute != null)
          Positioned(
            left: MshSpacing.md,
            right: MshSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + MshSpacing.lg,
            child: _RadwegeInfoPanel(
              route: _focusedRoute!,
              onClose: () => setState(() => _showInfoPanel = false),
            ),
          ),
        Positioned(
          right: MshSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + MshSpacing.lg +
              (_showInfoPanel && _focusedRoute != null ? 220 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_showInfoPanel && _focusedRoute != null)
                FloatingActionButton.small(
                  heroTag: 'radwege_info',
                  onPressed: () => setState(() => _showInfoPanel = true),
                  backgroundColor: _focusedRoute!.routeColor,
                  child: const Icon(Icons.info_outline, color: Colors.white),
                ),
              if (_focusedRoute != null) ...[
                const SizedBox(height: MshSpacing.sm),
                FloatingActionButton(
                  heroTag: 'radwege_center',
                  onPressed: () => _mapController.move(
                    _focusedRoute!.center,
                    _focusedRoute!.overviewZoom,
                  ),
                  backgroundColor: _focusedRoute!.routeColor,
                  child: const Icon(Icons.center_focus_strong, color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Marker> _buildAnimatedMarkers(RadwegRoute route, IconData icon) {
    final markers = <Marker>[];
    final points = route.routePoints;

    const bikeConfigs = <(double, double, int)>[
      (0.0, 1.0, 1),
      (0.15, 0.7, -1),
      (0.33, 1.3, 1),
      (0.50, 0.85, -1),
      (0.67, 1.1, 1),
      (0.82, 0.6, -1),
    ];

    for (final (offset, speed, direction) in bikeConfigs) {
      var progress = (_animationController.value * speed + offset) % 1.0;
      if (direction < 0) progress = 1.0 - progress;

      final position = _getPositionOnRoute(points, progress);

      const trailCount = 6;
      for (var t = trailCount; t >= 0; t--) {
        final trailOffset = t * 0.012 * direction;
        var trailProgress = progress - trailOffset;
        if (trailProgress < 0) trailProgress += 1.0;
        if (trailProgress > 1) trailProgress -= 1.0;

        final trailPos = _getPositionOnRoute(points, trailProgress);
        final alpha = ((1.0 - t / trailCount) * 180).round().clamp(0, 255);
        final size = 8.0 + (1.0 - t / trailCount) * 10;

        markers.add(
          Marker(
            point: trailPos,
            width: size,
            height: size,
            child: Container(
              decoration: BoxDecoration(
                color: route.routeColor.withAlpha(alpha ~/ 2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: route.routeColor.withAlpha(alpha),
                    blurRadius: size * 1.5,
                    spreadRadius: size * 0.3,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      markers.add(
        Marker(
          point: position,
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: route.routeColor, width: 3),
              boxShadow: [
                BoxShadow(color: route.routeColor, blurRadius: 12, spreadRadius: 4),
                BoxShadow(color: route.routeColor.withAlpha(150), blurRadius: 25, spreadRadius: 8),
                BoxShadow(color: route.routeColor.withAlpha(60), blurRadius: 40, spreadRadius: 15),
              ],
            ),
            child: Icon(icon, size: 14, color: route.routeColor),
          ),
        ),
      );
    }

    return markers;
  }

  LatLng _getPositionOnRoute(List<LatLng> route, double progress) {
    if (route.isEmpty) return const LatLng(51.5, 11.3);
    if (route.length == 1) return route.first;

    var totalLength = 0.0;
    final segments = <double>[];

    for (var i = 0; i < route.length - 1; i++) {
      final dist = _distance(route[i], route[i + 1]);
      segments.add(dist);
      totalLength += dist;
    }

    final targetDistance = progress * totalLength;
    var accumulated = 0.0;

    for (var i = 0; i < segments.length; i++) {
      if (accumulated + segments[i] >= targetDistance) {
        final segmentProgress = (targetDistance - accumulated) / segments[i];
        return _interpolate(route[i], route[i + 1], segmentProgress);
      }
      accumulated += segments[i];
    }

    return route.last;
  }

  double _distance(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return math.sqrt(dx * dx + dy * dy);
  }

  LatLng _interpolate(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  List<Marker> _buildPoiMarkers(RadwegRoute route) {
    return route.pois.map((poi) {
      return Marker(
        point: poi.coords,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showPoiInfo(poi, route),
          child: Container(
            decoration: BoxDecoration(
              color: route.routeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(poi.icon, color: Colors.white, size: 20),
          ),
        ),
      );
    }).toList();
  }

  void _showPoiInfo(RadwegPoi poi, RadwegRoute route) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(poi.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poi.description),
            const SizedBox(height: 8),
            Text(
              route.name,
              style: TextStyle(
                color: route.routeColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WANDERWEGE TAB
// ═══════════════════════════════════════════════════════════════

class _WanderwegeTab extends StatefulWidget {
  const _WanderwegeTab();

  @override
  State<_WanderwegeTab> createState() => _WanderwegeTabState();
}

class _WanderwegeTabState extends State<_WanderwegeTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  late AnimationController _animationController;

  final Set<String> _selectedRouteIds = {};
  WanderwegRoute? _focusedRoute;
  bool _showInfoPanel = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Keine Wanderwege standardmäßig ausgewählt (leeres Set = alle anzeigen, wie bei Kategorien)
    // Wenn User einen auswählt, werden nur ausgewählte angezeigt
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // Etwas langsamer für Wanderer
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<WanderwegRoute> get _selectedRoutes {
    // Wie bei Kategorien: leeres Set = alle anzeigen
    if (_selectedRouteIds.isEmpty) {
      return WanderwegeRepository.allRoutes;
    }
    return WanderwegeRepository.allRoutes
        .where((r) => _selectedRouteIds.contains(r.id))
        .toList();
  }

  void _toggleRoute(WanderwegRoute route) {
    setState(() {
      if (_selectedRouteIds.contains(route.id)) {
        _selectedRouteIds.remove(route.id);
        if (_focusedRoute?.id == route.id) {
          _focusedRoute = _selectedRoutes.isNotEmpty ? _selectedRoutes.first : null;
        }
      } else {
        _selectedRouteIds.add(route.id);
        _focusedRoute = route;
      }
    });

    if (_focusedRoute != null) {
      _mapController.move(_focusedRoute!.center, _focusedRoute!.overviewZoom);
    }
  }

  void _focusRoute(WanderwegRoute route) {
    setState(() {
      _focusedRoute = route;
      if (!_selectedRouteIds.contains(route.id)) {
        _selectedRouteIds.add(route.id);
      }
    });
    _mapController.move(route.center, route.overviewZoom);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _focusedRoute?.center ?? MapConfig.defaultCenter.toLatLng(),
            initialZoom: _focusedRoute?.overviewZoom ?? MapConfig.defaultZoom,
            minZoom: MapConfig.minZoom,
            maxZoom: MapConfig.maxZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: MapConfig.tileUrlTemplate,
              userAgentPackageName: MapConfig.userAgent,
            ),
            PolylineLayer(
              polylines: _selectedRoutes.map((route) {
                return Polyline(
                  points: route.routePoints,
                  color: route.glowColor,
                  strokeWidth: 14,
                );
              }).toList(),
            ),
            PolylineLayer(
              polylines: _selectedRoutes.map((route) {
                final isFocused = route.id == _focusedRoute?.id;
                return Polyline(
                  points: route.routePoints,
                  color: route.routeColor,
                  strokeWidth: isFocused ? 5 : 3,
                );
              }).toList(),
            ),
            if (_focusedRoute != null)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return MarkerLayer(
                    markers: _buildAnimatedMarkers(_focusedRoute!),
                  );
                },
              ),
            if (_focusedRoute != null)
              MarkerLayer(
                markers: _buildPoiMarkers(_focusedRoute!),
              ),
          ],
        ),
        Positioned(
          top: MshSpacing.sm,
          left: MshSpacing.sm,
          right: MshSpacing.sm,
          child: _WanderwegeFilterChips(
            routes: WanderwegeRepository.allRoutes,
            selectedIds: _selectedRouteIds,
            focusedId: _focusedRoute?.id,
            onToggle: _toggleRoute,
            onFocus: _focusRoute,
          ),
        ),
        // Sicherheitshinweis
        if (_focusedRoute != null && _focusedRoute!.needsWarning)
          Positioned(
            top: 60,
            left: MshSpacing.md,
            right: MshSpacing.md,
            child: _SafetyWarningBanner(route: _focusedRoute!),
          ),
        if (_showInfoPanel && _focusedRoute != null)
          Positioned(
            left: MshSpacing.md,
            right: MshSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + MshSpacing.lg,
            child: _WanderwegeInfoPanel(
              route: _focusedRoute!,
              onClose: () => setState(() => _showInfoPanel = false),
            ),
          ),
        Positioned(
          right: MshSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + MshSpacing.lg +
              (_showInfoPanel && _focusedRoute != null ? 250 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_showInfoPanel && _focusedRoute != null)
                FloatingActionButton.small(
                  heroTag: 'wanderwege_info',
                  onPressed: () => setState(() => _showInfoPanel = true),
                  backgroundColor: _focusedRoute!.routeColor,
                  child: const Icon(Icons.info_outline, color: Colors.white),
                ),
              if (_focusedRoute != null) ...[
                const SizedBox(height: MshSpacing.sm),
                FloatingActionButton(
                  heroTag: 'wanderwege_center',
                  onPressed: () => _mapController.move(
                    _focusedRoute!.center,
                    _focusedRoute!.overviewZoom,
                  ),
                  backgroundColor: _focusedRoute!.routeColor,
                  child: const Icon(Icons.center_focus_strong, color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Marker> _buildAnimatedMarkers(WanderwegRoute route) {
    final markers = <Marker>[];
    final points = route.routePoints;

    // Weniger Wanderer als Radfahrer, dafür langsamer
    const hikerConfigs = <(double, double, int)>[
      (0.0, 0.8, 1),
      (0.25, 0.6, -1),
      (0.50, 0.9, 1),
      (0.75, 0.5, -1),
    ];

    for (final (offset, speed, direction) in hikerConfigs) {
      var progress = (_animationController.value * speed + offset) % 1.0;
      if (direction < 0) progress = 1.0 - progress;

      final position = _getPositionOnRoute(points, progress);

      const trailCount = 4;
      for (var t = trailCount; t >= 0; t--) {
        final trailOffset = t * 0.008 * direction;
        var trailProgress = progress - trailOffset;
        if (trailProgress < 0) trailProgress += 1.0;
        if (trailProgress > 1) trailProgress -= 1.0;

        final trailPos = _getPositionOnRoute(points, trailProgress);
        final alpha = ((1.0 - t / trailCount) * 150).round().clamp(0, 255);
        final size = 6.0 + (1.0 - t / trailCount) * 8;

        markers.add(
          Marker(
            point: trailPos,
            width: size,
            height: size,
            child: Container(
              decoration: BoxDecoration(
                color: route.routeColor.withAlpha(alpha ~/ 2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: route.routeColor.withAlpha(alpha),
                    blurRadius: size,
                    spreadRadius: size * 0.2,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      markers.add(
        Marker(
          point: position,
          width: 22,
          height: 22,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: route.routeColor, width: 2),
              boxShadow: [
                BoxShadow(color: route.routeColor, blurRadius: 8, spreadRadius: 2),
                BoxShadow(color: route.routeColor.withAlpha(100), blurRadius: 16, spreadRadius: 4),
              ],
            ),
            child: Icon(Icons.hiking, size: 12, color: route.routeColor),
          ),
        ),
      );
    }

    return markers;
  }

  LatLng _getPositionOnRoute(List<LatLng> route, double progress) {
    if (route.isEmpty) return const LatLng(51.5, 11.3);
    if (route.length == 1) return route.first;

    var totalLength = 0.0;
    final segments = <double>[];

    for (var i = 0; i < route.length - 1; i++) {
      final dist = _distance(route[i], route[i + 1]);
      segments.add(dist);
      totalLength += dist;
    }

    final targetDistance = progress * totalLength;
    var accumulated = 0.0;

    for (var i = 0; i < segments.length; i++) {
      if (accumulated + segments[i] >= targetDistance) {
        final segmentProgress = (targetDistance - accumulated) / segments[i];
        return _interpolate(route[i], route[i + 1], segmentProgress);
      }
      accumulated += segments[i];
    }

    return route.last;
  }

  double _distance(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return math.sqrt(dx * dx + dy * dy);
  }

  LatLng _interpolate(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  List<Marker> _buildPoiMarkers(WanderwegRoute route) {
    return route.pois.map((poi) {
      return Marker(
        point: poi.coords,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showPoiInfo(poi, route),
          child: Container(
            decoration: BoxDecoration(
              color: route.routeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(poi.icon, color: Colors.white, size: 20),
          ),
        ),
      );
    }).toList();
  }

  void _showPoiInfo(WanderwegPoi poi, WanderwegRoute route) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(poi.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poi.description),
            const SizedBox(height: 8),
            // Amenities
            if (poi.hasWater || poi.hasToilet || poi.hasParking || poi.hasGastro)
              Wrap(
                spacing: 8,
                children: [
                  if (poi.hasWater) const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                  if (poi.hasToilet) const Icon(Icons.wc, size: 16, color: Colors.grey),
                  if (poi.hasParking) const Icon(Icons.local_parking, size: 16, color: Colors.grey),
                  if (poi.hasGastro) const Icon(Icons.restaurant, size: 16, color: Colors.orange),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              route.name,
              style: TextStyle(
                color: route.routeColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SICHERHEITSHINWEIS BANNER
// ═══════════════════════════════════════════════════════════════

class _SafetyWarningBanner extends StatelessWidget {
  const _SafetyWarningBanner({required this.route});

  final WanderwegRoute route;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: route.status.color.withAlpha(240),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(route.status.icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              route.safetyWarning ?? route.status.warningText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
// RADWEGE FILTER CHIPS
// ═══════════════════════════════════════════════════════════════

class _RadwegeFilterChips extends StatelessWidget {
  const _RadwegeFilterChips({
    required this.routes,
    required this.selectedIds,
    required this.focusedId,
    required this.onToggle,
    required this.onFocus,
  });

  final List<RadwegRoute> routes;
  final Set<String> selectedIds;
  final String? focusedId;
  final ValueChanged<RadwegRoute> onToggle;
  final ValueChanged<RadwegRoute> onFocus;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: routes.map((route) {
          final isSelected = selectedIds.contains(route.id);
          final isFocused = route.id == focusedId;

          return Padding(
            padding: const EdgeInsets.only(right: MshSpacing.xs),
            child: GestureDetector(
              onDoubleTap: () => onFocus(route),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      route.category.icon,
                      size: 14,
                      color: isSelected ? Colors.white : route.routeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(route.shortName),
                    if (isFocused) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.visibility, size: 12, color: Colors.white),
                    ],
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => onToggle(route),
                selectedColor: route.routeColor,
                checkmarkColor: Colors.white,
                backgroundColor: Colors.white.withAlpha(230),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isFocused ? route.routeColor : Colors.transparent,
                  width: isFocused ? 2 : 0,
                ),
                elevation: 2,
                shadowColor: Colors.black26,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WANDERWEGE FILTER CHIPS
// ═══════════════════════════════════════════════════════════════

class _WanderwegeFilterChips extends StatelessWidget {
  const _WanderwegeFilterChips({
    required this.routes,
    required this.selectedIds,
    required this.focusedId,
    required this.onToggle,
    required this.onFocus,
  });

  final List<WanderwegRoute> routes;
  final Set<String> selectedIds;
  final String? focusedId;
  final ValueChanged<WanderwegRoute> onToggle;
  final ValueChanged<WanderwegRoute> onFocus;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: routes.map((route) {
          final isSelected = selectedIds.contains(route.id);
          final isFocused = route.id == focusedId;

          return Padding(
            padding: const EdgeInsets.only(right: MshSpacing.xs),
            child: GestureDetector(
              onDoubleTap: () => onFocus(route),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      route.category.icon,
                      size: 14,
                      color: isSelected ? Colors.white : route.routeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(route.shortName),
                    if (route.needsWarning) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.warning_amber,
                        size: 12,
                        color: isSelected ? Colors.white : Colors.orange,
                      ),
                    ],
                    if (isFocused) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.visibility, size: 12, color: Colors.white),
                    ],
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => onToggle(route),
                selectedColor: route.routeColor,
                checkmarkColor: Colors.white,
                backgroundColor: Colors.white.withAlpha(230),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isFocused ? route.routeColor : Colors.transparent,
                  width: isFocused ? 2 : 0,
                ),
                elevation: 2,
                shadowColor: Colors.black26,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RADWEGE INFO PANEL
// ═══════════════════════════════════════════════════════════════

class _RadwegeInfoPanel extends StatelessWidget {
  const _RadwegeInfoPanel({
    required this.route,
    required this.onClose,
  });

  final RadwegRoute route;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: route.routeColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.directions_bike, color: route.routeColor),
                ),
                const SizedBox(width: MshSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        route.category.label,
                        style: TextStyle(color: route.routeColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: MshSpacing.md),
            Row(
              children: [
                _StatChip(icon: Icons.straighten, label: '~${route.lengthKm.toInt()} km', color: route.routeColor),
                const SizedBox(width: MshSpacing.sm),
                _StatChip(icon: Icons.terrain, label: route.difficulty, color: route.routeColor),
                const SizedBox(width: MshSpacing.sm),
                _StatChip(icon: Icons.place, label: '${route.pois.length} Stationen', color: route.routeColor),
                if (route.isLoop) ...[
                  const SizedBox(width: MshSpacing.sm),
                  _StatChip(icon: Icons.loop, label: 'Rundweg', color: route.routeColor),
                ],
              ],
            ),
            const SizedBox(height: MshSpacing.md),
            Text(route.description, style: const TextStyle(fontSize: 13)),
            if (route.contactName != null || route.websiteUrl != null) ...[
              const Divider(height: MshSpacing.lg),
              Row(
                children: [
                  if (route.contactName != null) ...[
                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: MshSpacing.xs),
                    Expanded(
                      child: Text(
                        route.contactRole != null
                            ? '${route.contactName} (${route.contactRole})'
                            : route.contactName!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  if (route.websiteUrl != null)
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(route.websiteUrl!),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Mehr Infos'),
                      style: TextButton.styleFrom(
                        foregroundColor: route.routeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WANDERWEGE INFO PANEL
// ═══════════════════════════════════════════════════════════════

class _WanderwegeInfoPanel extends StatelessWidget {
  const _WanderwegeInfoPanel({
    required this.route,
    required this.onClose,
  });

  final WanderwegRoute route;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: route.routeColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.hiking, color: route.routeColor),
                ),
                const SizedBox(width: MshSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        route.category.label,
                        style: TextStyle(color: route.routeColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: MshSpacing.md),
            // Stats Row
            Wrap(
              spacing: MshSpacing.sm,
              runSpacing: MshSpacing.xs,
              children: [
                _StatChip(
                  icon: Icons.straighten,
                  label: '~${route.lengthKm.toInt()} km',
                  color: route.routeColor,
                ),
                _StatChip(
                  icon: route.difficulty.icon,
                  label: route.difficulty.label,
                  color: route.difficulty.color,
                ),
                if (route.estimatedHours != null)
                  _StatChip(
                    icon: Icons.schedule,
                    label: route.formattedDuration,
                    color: route.routeColor,
                  ),
                if (route.elevationGain != null)
                  _StatChip(
                    icon: Icons.trending_up,
                    label: route.formattedElevation,
                    color: route.routeColor,
                  ),
                _StatChip(
                  icon: Icons.place,
                  label: '${route.pois.length} POIs',
                  color: route.routeColor,
                ),
                if (route.isCircular)
                  _StatChip(
                    icon: Icons.loop,
                    label: 'Rundweg',
                    color: route.routeColor,
                  ),
              ],
            ),
            const SizedBox(height: MshSpacing.md),
            Text(route.description, style: const TextStyle(fontSize: 13)),
            if (route.seasonalInfo != null) ...[
              const SizedBox(height: MshSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      route.seasonalInfo!,
                      style: const TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ],
            if (route.websiteUrl != null) ...[
              const Divider(height: MshSpacing.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(route.websiteUrl!),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Mehr Infos'),
                  style: TextButton.styleFrom(
                    foregroundColor: route.routeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  const _StatChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
