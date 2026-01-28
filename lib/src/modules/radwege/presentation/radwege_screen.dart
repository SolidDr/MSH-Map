import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/map_config.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../features/analytics/data/usage_analytics_service.dart';
import '../data/radwege_repository.dart';
import '../domain/radweg_category.dart';
import '../domain/radweg_route.dart';

/// Radwege-Screen mit Filterfunktionen
class RadwegeScreen extends StatefulWidget {
  const RadwegeScreen({super.key});

  @override
  State<RadwegeScreen> createState() => _RadwegeScreenState();
}

class _RadwegeScreenState extends State<RadwegeScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _animationController;

  /// Ausgewählte Radwege (IDs)
  final Set<String> _selectedRouteIds = {};

  /// Ausgewählter Radweg für Detail-Ansicht
  RadwegRoute? _focusedRoute;

  /// Info-Panel anzeigen
  bool _showInfoPanel = true;

  @override
  void initState() {
    super.initState();
    UsageAnalyticsService().trackModuleVisit('radwege');

    // Standardmäßig Kupferspuren-Radweg auswählen
    _selectedRouteIds.add('kupferspuren');
    _focusedRoute = RadwegeRepository.byId('kupferspuren');

    // Animation für fahrende Punkte
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

    // Karte auf fokussierten Radweg zentrieren
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: (_focusedRoute?.routeColor ?? MshColors.primary).withAlpha(220),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Radwege'),
        actions: [
          IconButton(
            icon: Icon(_showInfoPanel ? Icons.info : Icons.info_outline),
            onPressed: () => setState(() => _showInfoPanel = !_showInfoPanel),
            tooltip: 'Info',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Karte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _focusedRoute?.center ?? MapConfig.defaultCenter.toLatLng(),
              initialZoom: _focusedRoute?.overviewZoom ?? MapConfig.defaultZoom,
              minZoom: MapConfig.minZoom,
              maxZoom: MapConfig.maxZoom,
            ),
            children: [
              // Tile Layer
              TileLayer(
                urlTemplate: MapConfig.tileUrlTemplate,
                userAgentPackageName: MapConfig.userAgent,
              ),

              // Glow-Effekte für alle ausgewählten Routen
              PolylineLayer(
                polylines: _selectedRoutes.map((route) {
                  return Polyline(
                    points: route.routePoints,
                    color: route.glowColor,
                    strokeWidth: 14,
                  );
                }).toList(),
              ),

              // Hauptlinien für alle ausgewählten Routen
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

              // Animierte Punkte nur für fokussierten Radweg
              if (_focusedRoute != null)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return MarkerLayer(
                      markers: _buildAnimatedMarkers(_focusedRoute!),
                    );
                  },
                ),

              // POI Marker für fokussierten Radweg
              if (_focusedRoute != null)
                MarkerLayer(
                  markers: _buildPoiMarkers(_focusedRoute!),
                ),
            ],
          ),

          // Filter-Chips oben
          Positioned(
            top: MediaQuery.of(context).padding.top + 56 + MshSpacing.sm,
            left: MshSpacing.sm,
            right: MshSpacing.sm,
            child: _RouteFilterChips(
              routes: RadwegeRepository.allRoutes,
              selectedIds: _selectedRouteIds,
              focusedId: _focusedRoute?.id,
              onToggle: _toggleRoute,
              onFocus: _focusRoute,
            ),
          ),

          // Info-Panel
          if (_showInfoPanel && _focusedRoute != null)
            Positioned(
              left: MshSpacing.md,
              right: MshSpacing.md,
              bottom: MediaQuery.of(context).padding.bottom + MshSpacing.lg,
              child: _RouteInfoPanel(
                route: _focusedRoute!,
                onClose: () => setState(() => _showInfoPanel = false),
              ),
            ),
        ],
      ),
      floatingActionButton: _focusedRoute != null
          ? FloatingActionButton(
              onPressed: () => _mapController.move(
                _focusedRoute!.center,
                _focusedRoute!.overviewZoom,
              ),
              backgroundColor: _focusedRoute!.routeColor,
              child: const Icon(Icons.center_focus_strong, color: Colors.white),
            )
          : null,
    );
  }

  /// Erstellt animierte "Fahrrad"-Punkte entlang der Route
  /// Mit Glow-Effekten und Spuren - jeder Radweg in seiner eigenen Farbe
  List<Marker> _buildAnimatedMarkers(RadwegRoute route) {
    final markers = <Marker>[];
    final points = route.routePoints;

    // Fahrrad-Konfigurationen: (offset, speed, direction)
    // direction: 1 = vorwärts, -1 = rückwärts
    const bikeConfigs = <(double, double, int)>[
      (0.0, 1.0, 1),    // Fahrrad 1: normal, vorwärts
      (0.15, 0.7, -1),  // Fahrrad 2: langsamer, rückwärts
      (0.33, 1.3, 1),   // Fahrrad 3: schneller, vorwärts
      (0.50, 0.85, -1), // Fahrrad 4: etwas langsamer, rückwärts
      (0.67, 1.1, 1),   // Fahrrad 5: etwas schneller, vorwärts
      (0.82, 0.6, -1),  // Fahrrad 6: langsam, rückwärts
    ];

    for (final (offset, speed, direction) in bikeConfigs) {
      // Progress berechnen mit Geschwindigkeit und Richtung
      var progress = (_animationController.value * speed + offset) % 1.0;
      if (direction < 0) progress = 1.0 - progress;

      final position = _getPositionOnRoute(points, progress);

      // Trail-Effekt (mehrere verblassende Punkte)
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

      // Hauptpunkt mit intensivem Glow
      markers.add(
        Marker(
          point: position,
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: route.routeColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: route.routeColor,
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: route.routeColor.withAlpha(150),
                  blurRadius: 25,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: route.routeColor.withAlpha(60),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: Icon(
              Icons.pedal_bike,
              size: 14,
              color: route.routeColor,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  /// Berechnet Position auf der Route basierend auf Fortschritt (0.0 - 1.0)
  LatLng _getPositionOnRoute(List<LatLng> route, double progress) {
    if (route.isEmpty) return const LatLng(51.5, 11.3);
    if (route.length == 1) return route.first;

    // Gesamtlänge schätzen
    var totalLength = 0.0;
    final segments = <double>[];

    for (var i = 0; i < route.length - 1; i++) {
      final dist = _distance(route[i], route[i + 1]);
      segments.add(dist);
      totalLength += dist;
    }

    // Position finden
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

  /// POI Marker entlang der Route
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
            child: Icon(
              poi.icon,
              color: Colors.white,
              size: 20,
            ),
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
// FILTER CHIPS
// ═══════════════════════════════════════════════════════════════

class _RouteFilterChips extends StatelessWidget {
  const _RouteFilterChips({
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
// INFO PANEL
// ═══════════════════════════════════════════════════════════════

class _RouteInfoPanel extends StatelessWidget {
  const _RouteInfoPanel({
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: route.routeColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_bike,
                    color: route.routeColor,
                  ),
                ),
                const SizedBox(width: MshSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        route.category.label,
                        style: TextStyle(
                          color: route.routeColor,
                          fontSize: 12,
                        ),
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

            // Stats
            Row(
              children: [
                _StatChip(
                  icon: Icons.straighten,
                  label: '~${route.lengthKm.toInt()} km',
                  color: route.routeColor,
                ),
                const SizedBox(width: MshSpacing.sm),
                _StatChip(
                  icon: Icons.terrain,
                  label: route.difficulty,
                  color: route.routeColor,
                ),
                const SizedBox(width: MshSpacing.sm),
                _StatChip(
                  icon: Icons.place,
                  label: '${route.pois.length} Stationen',
                  color: route.routeColor,
                ),
                if (route.isLoop) ...[
                  const SizedBox(width: MshSpacing.sm),
                  _StatChip(
                    icon: Icons.loop,
                    label: 'Rundweg',
                    color: route.routeColor,
                  ),
                ],
              ],
            ),

            const SizedBox(height: MshSpacing.md),

            // Beschreibung
            Text(
              route.description,
              style: const TextStyle(fontSize: 13),
            ),

            if (route.contactName != null || route.websiteUrl != null) ...[
              const Divider(height: MshSpacing.lg),

              // Kontakt/Website
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
