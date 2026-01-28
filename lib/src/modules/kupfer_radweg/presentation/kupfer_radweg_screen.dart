import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/map_config.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../features/analytics/data/usage_analytics_service.dart';
import '../data/kupfer_route_data.dart';

/// Kupferspurenradweg - Vollbild-Karte mit Route
class KupferRadwegScreen extends StatefulWidget {
  const KupferRadwegScreen({super.key});

  @override
  State<KupferRadwegScreen> createState() => _KupferRadwegScreenState();
}

class _KupferRadwegScreenState extends State<KupferRadwegScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _animationController;
  bool _showInfoPanel = true;

  @override
  void initState() {
    super.initState();
    UsageAnalyticsService().trackModuleVisit('kupfer_radweg');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: KupferRouteData.kupferColor.withAlpha(220),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Kupferspurenradweg'),
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
            options: const MapOptions(
              initialCenter: KupferRouteData.center,
              initialZoom: KupferRouteData.overviewZoom,
              minZoom: MapConfig.minZoom,
              maxZoom: MapConfig.maxZoom,
            ),
            children: [
              // Tile Layer
              TileLayer(
                urlTemplate: MapConfig.tileUrlTemplate,
                userAgentPackageName: MapConfig.userAgent,
              ),

              // Glow-Effekt (breitere, transparente Linie)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: KupferRouteData.mainRoute,
                    color: KupferRouteData.kupferGlow,
                    strokeWidth: 14,
                  ),
                ],
              ),

              // Hauptroute
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: KupferRouteData.mainRoute,
                    color: KupferRouteData.kupferColor,
                    strokeWidth: 5,
                  ),
                ],
              ),

              // Animierte Punkte
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return MarkerLayer(
                    markers: _buildAnimatedMarkers(),
                  );
                },
              ),

              // POI Marker
              MarkerLayer(
                markers: _buildPoiMarkers(),
              ),
            ],
          ),

          // Info-Panel
          if (_showInfoPanel)
            Positioned(
              left: MshSpacing.md,
              right: MshSpacing.md,
              bottom: MediaQuery.of(context).padding.bottom + MshSpacing.lg,
              child: _InfoPanel(
                onClose: () => setState(() => _showInfoPanel = false),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerRoute,
        backgroundColor: KupferRouteData.kupferColor,
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
      ),
    );
  }

  void _centerRoute() {
    _mapController.move(
      KupferRouteData.center,
      KupferRouteData.overviewZoom,
    );
  }

  /// Erstellt animierte "Fahrrad"-Punkte entlang der Route
  List<Marker> _buildAnimatedMarkers() {
    final markers = <Marker>[];
    final route = KupferRouteData.mainRoute;
    const numBikes = 5;

    for (var i = 0; i < numBikes; i++) {
      final offset = i / numBikes;
      final progress = (_animationController.value + offset) % 1.0;

      // Position auf der Route berechnen
      final position = _getPositionOnRoute(route, progress);

      markers.add(
        Marker(
          point: position,
          width: 16,
          height: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: KupferRouteData.kupferColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: KupferRouteData.kupferColor.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  /// Berechnet Position auf der Route basierend auf Fortschritt (0.0 - 1.0)
  LatLng _getPositionOnRoute(List<LatLng> route, double progress) {
    if (route.isEmpty) return KupferRouteData.center;
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
        final segmentProgress =
            (targetDistance - accumulated) / segments[i];
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
  List<Marker> _buildPoiMarkers() {
    return KupferRouteData.pois.map((poi) {
      return Marker(
        point: poi.coords,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showPoiInfo(poi),
          child: Container(
            decoration: BoxDecoration(
              color: KupferRouteData.kupferColor,
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

  void _showPoiInfo(KupferPoi poi) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(poi.name),
        content: Text(poi.description),
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

/// Info-Panel mit Route-Details
class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.onClose});

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
                    color: KupferRouteData.kupferColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_bike,
                    color: KupferRouteData.kupferColor,
                  ),
                ),
                const SizedBox(width: MshSpacing.sm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kupferspurenradweg',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Bergbau & Industriekultur erleben',
                        style: TextStyle(
                          color: Colors.grey,
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
                  label: '~${KupferRouteData.totalLengthKm.toInt()} km',
                ),
                const SizedBox(width: MshSpacing.sm),
                const _StatChip(
                  icon: Icons.terrain,
                  label: 'Leicht',
                ),
                const SizedBox(width: MshSpacing.sm),
                _StatChip(
                  icon: Icons.place,
                  label: '${KupferRouteData.pois.length} Stationen',
                ),
              ],
            ),

            const SizedBox(height: MshSpacing.md),

            // Beschreibung
            const Text(
              '800 Jahre Bergbaugeschichte auf einem Radweg: '
              'Entlang an Halden, Schächten und Kupferspuren '
              'durch Mansfeld-Südharz.',
              style: TextStyle(fontSize: 13),
            ),

            const Divider(height: MshSpacing.lg),

            // Kontakt
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: MshSpacing.xs),
                const Expanded(
                  child: Text(
                    '${KupferRouteData.contactName} (${KupferRouteData.contactRole})',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(KupferRouteData.websiteSeg),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Kontakt'),
                  style: TextButton.styleFrom(
                    foregroundColor: KupferRouteData.kupferColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: MshSpacing.sm),

            // Website Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(KupferRouteData.websiteSeg),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Mehr Infos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KupferRouteData.kupferColor,
                  side: const BorderSide(color: KupferRouteData.kupferColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: KupferRouteData.kupferColor.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: KupferRouteData.kupferColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: KupferRouteData.kupferColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
