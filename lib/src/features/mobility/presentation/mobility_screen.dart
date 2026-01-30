/// MSH Map - Mobilität Screen
///
/// ÖPNV & Verkehr Hub mit Echtzeit-Daten von v6.db.transport.rest
/// - Haltestellen in der Nähe
/// - Echtzeit-Abfahrtszeiten
/// - Fahrplanauskunft
/// - Sharing-Angebote
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../application/transit_providers.dart'
    show
        LocationStatus,
        departuresAutoRefreshProvider,
        nearbyStopsProvider,
        refreshNearbyStops,
        searchLocationsProvider,
        transitLocationProvider;
import '../domain/departure.dart';
import '../domain/transit_stop.dart';

/// Mobilität Screen - ÖPNV & Verkehr mit Echtzeit-Daten
class MobilityScreen extends ConsumerStatefulWidget {
  const MobilityScreen({super.key});

  @override
  ConsumerState<MobilityScreen> createState() => _MobilityScreenState();
}

class _MobilityScreenState extends ConsumerState<MobilityScreen> {
  TransitStop? _fromLocation;
  TransitStop? _toLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          refreshNearbyStops(ref);
          // Warte kurz auf Refresh
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            const SliverAppBar(
              floating: true,
              title: Text('Mobilität'),
            ),

            // Schnellzugriff
            SliverToBoxAdapter(
              child: Padding(
                padding: MshSpacing.screenPadding,
                child: _buildQuickActions(context),
              ),
            ),

            // Haltestellen in der Nähe (Echtzeit)
            SliverToBoxAdapter(
              child: _NearbyStopsSection(),
            ),

            // Verbindungssuche
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(MshSpacing.lg),
                child: _buildConnectionSearch(context),
              ),
            ),

            // Sharing & Alternativen
            SliverToBoxAdapter(
              child: _buildSharingSection(context),
            ),

            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: MshSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.departure_board,
            label: 'Abfahrten',
            color: MshColors.info,
            onTap: _openInsaAbfahrten,
          ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.route,
            label: 'Verbindung',
            color: MshColors.primary,
            onTap: _openInsaVerbindung,
          ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.map_outlined,
            label: 'Liniennetz',
            color: MshColors.engagementNormal,
            onTap: _openInsaLiniennetz,
          ),
        ),
      ],
    );
  }

  // INSA Sachsen-Anhalt Links
  static const _insaAbfahrten = 'https://www.insa.de/fahrplan/abfahrtsmonitor';
  static const _insaVerbindung = 'https://www.insa.de/fahrplan/verbindungssuche';
  static const _insaLiniennetz = 'https://www.insa.de/fahrplan/liniennetzplaene';

  Future<void> _openInsaAbfahrten() async {
    final url = Uri.parse(_insaAbfahrten);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInsaVerbindung() async {
    final url = Uri.parse(_insaVerbindung);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInsaLiniennetz() async {
    final url = Uri.parse(_insaLiniennetz);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildConnectionSearch(BuildContext context) {
    final canSearch = _fromLocation != null && _toLocation != null;

    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.surface,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(color: MshColors.textMuted.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verbindung suchen',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: MshColors.textStrong,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: MshSpacing.md),
          _LocationInputWithAutocomplete(
            icon: Icons.trip_origin,
            hint: 'Von (Haltestelle oder Ort)',
            iconColor: MshColors.engagementNormal,
            onLocationSelected: (stop) => setState(() => _fromLocation = stop),
          ),
          const SizedBox(height: MshSpacing.sm),
          _LocationInputWithAutocomplete(
            icon: Icons.location_on,
            hint: 'Nach (Haltestelle oder Ort)',
            iconColor: MshColors.engagementCritical,
            onLocationSelected: (stop) => setState(() => _toLocation = stop),
          ),
          const SizedBox(height: MshSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canSearch ? _openGoogleMapsDirections : null,
              icon: const Icon(Icons.directions),
              label: const Text('Route in Google Maps'),
            ),
          ),
          if (!canSearch)
            Padding(
              padding: const EdgeInsets.only(top: MshSpacing.xs),
              child: Text(
                'Bitte Start und Ziel auswählen',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textMuted,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  /// Öffnet Google Maps mit der Route von Start zu Ziel
  Future<void> _openGoogleMapsDirections() async {
    if (_fromLocation == null || _toLocation == null) return;

    // Google Maps URL mit ÖPNV-Modus (dirflg=r)
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_fromLocation!.latitude},${_fromLocation!.longitude}'
      '&destination=${_toLocation!.latitude},${_toLocation!.longitude}'
      '&travelmode=transit',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Maps konnte nicht geöffnet werden'),
            ),
          );
        }
      }
    } on Exception catch (e) {
      debugPrint('Fehler beim Öffnen von Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Öffnen der Route'),
          ),
        );
      }
    }
  }

  Widget _buildSharingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
          child: Text(
            'Alternativen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: MshColors.textStrong,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: MshSpacing.md),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: MshSpacing.lg),
          child: Row(
            children: [
              _SharingCard(
                icon: Icons.directions_bike,
                label: 'Fahrrad',
                available: null,
                color: MshColors.engagementNormal,
              ),
              SizedBox(width: MshSpacing.sm),
              _SharingCard(
                icon: Icons.electric_scooter,
                label: 'E-Scooter',
                available: null,
                color: MshColors.primary,
              ),
              SizedBox(width: MshSpacing.sm),
              _SharingCard(
                icon: Icons.directions_car,
                label: 'Carsharing',
                available: null,
                color: MshColors.info,
              ),
              SizedBox(width: MshSpacing.sm),
              _SharingCard(
                icon: Icons.hail,
                label: 'Mitfahren',
                available: null,
                color: MshColors.engagementElevated,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NEARBY STOPS SECTION (mit Echtzeit-Daten)
// ═══════════════════════════════════════════════════════════════

class _NearbyStopsSection extends ConsumerWidget {
  void _showLocationHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Standort deaktiviert')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'So aktivierst du den Standort:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildHelpStep('1', 'Klicke auf das Schloss-Symbol in der Adressleiste'),
            _buildHelpStep('2', 'Wähle "Website-Einstellungen"'),
            _buildHelpStep('3', 'Erlaube den Standortzugriff'),
            _buildHelpStep('4', 'Lade die Seite neu'),
            const SizedBox(height: 12),
            const Text(
              'Alternativ zeigen wir dir Haltestellen im Zentrum von Mansfeld-Südharz.',
              style: TextStyle(
                color: MshColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: MshColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: MshColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopsAsync = ref.watch(nearbyStopsProvider);
    final locationAsync = ref.watch(transitLocationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
          child: Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: MshColors.textSecondary,
              ),
              const SizedBox(width: MshSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haltestellen in der Nähe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: MshColors.textStrong,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    // Zeige Hinweis wenn Fallback-Location verwendet wird
                    locationAsync.when(
                      data: (location) {
                        if (location.status == LocationStatus.fallbackLocation) {
                          return GestureDetector(
                            onTap: () => _showLocationHelpDialog(context),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 12,
                                  color: MshColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    location.errorMessage ?? 'Zeige Haltestellen im MSH-Zentrum',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: MshColors.warning,
                                          fontSize: 11,
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => refreshNearbyStops(ref),
                tooltip: 'Aktualisieren',
              ),
            ],
          ),
        ),
        const SizedBox(height: MshSpacing.md),
        stopsAsync.when(
          data: (stops) => _buildStopsList(context, stops),
          loading: _buildLoadingState,
          error: (error, _) => _buildErrorState(context, error, ref),
        ),
      ],
    );
  }

  Widget _buildStopsList(BuildContext context, List<TransitStop> stops) {
    if (stops.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: stops
          .map((stop) => _StopCardWithDepartures(stop: stop))
          .toList(),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(MshSpacing.xl),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: MshSpacing.md),
            Text('Suche Haltestellen...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MshSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.directions_bus,
              size: 48,
              color: MshColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: MshSpacing.md),
            const Text(
              'Keine Haltestellen in der Nähe',
              style: TextStyle(color: MshColors.textSecondary),
            ),
            const SizedBox(height: MshSpacing.sm),
            const Text(
              'Im Umkreis von 2km wurden keine ÖPNV-Haltestellen gefunden',
              style: TextStyle(
                color: MshColors.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(MshSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: MshColors.error,
            ),
            const SizedBox(height: MshSpacing.md),
            const Text(
              'Fehler beim Laden',
              style: TextStyle(color: MshColors.error),
            ),
            const SizedBox(height: MshSpacing.sm),
            Text(
              error.toString(),
              style: const TextStyle(
                color: MshColors.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MshSpacing.md),
            TextButton.icon(
              onPressed: () => refreshNearbyStops(ref),
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STOP CARD WITH LIVE DEPARTURES
// ═══════════════════════════════════════════════════════════════

class _StopCardWithDepartures extends ConsumerWidget {
  const _StopCardWithDepartures({required this.stop});

  final TransitStop stop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departuresAsync = ref.watch(departuresAutoRefreshProvider(stop.id));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MshSpacing.lg,
        vertical: MshSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(MshSpacing.md),
        decoration: BoxDecoration(
          color: MshColors.surface,
          borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
          border: Border.all(color: MshColors.textMuted.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name + Entfernung
            Row(
              children: [
                Expanded(
                  child: Text(
                    stop.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: MshColors.textStrong,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (stop.distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MshSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: MshColors.textMuted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(MshSpacing.xs),
                    ),
                    child: Text(
                      stop.distanceFormatted,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: MshColors.textSecondary,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: MshSpacing.sm),

            // Abfahrten
            departuresAsync.when(
              data: (departures) => _buildDepartures(context, departures),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: MshSpacing.sm),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: MshSpacing.sm),
                child: Text(
                  'Abfahrten konnten nicht geladen werden',
                  style: TextStyle(
                    color: MshColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartures(BuildContext context, List<Departure> departures) {
    if (departures.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: MshSpacing.sm),
        child: Text(
          'Keine Abfahrten in den nächsten 60 Minuten',
          style: TextStyle(
            color: MshColors.textMuted,
            fontSize: 12,
          ),
        ),
      );
    }

    // Zeige max 4 Abfahrten
    return Column(
      children: departures
          .take(4)
          .map((d) => _DepartureRow(departure: d))
          .toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DEPARTURE ROW (mit Echtzeit-Infos)
// ═══════════════════════════════════════════════════════════════

class _DepartureRow extends StatelessWidget {
  const _DepartureRow({required this.departure});

  final Departure departure;

  @override
  Widget build(BuildContext context) {
    final isCancelled = departure.cancelled ?? false;
    final minutes = departure.minutesUntilDeparture;

    return Padding(
      padding: const EdgeInsets.only(top: MshSpacing.xs),
      child: Row(
        children: [
          // Linien-Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: departure.line.color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  departure.line.icon,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 2),
                Text(
                  departure.line.shortName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: MshSpacing.sm),

          // Ziel
          Expanded(
            child: Text(
              departure.direction,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCancelled
                        ? MshColors.textMuted
                        : MshColors.textPrimary,
                    decoration:
                        isCancelled ? TextDecoration.lineThrough : null,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Verspätung (wenn > 0)
          if (departure.isDelayed && !isCancelled)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '+${departure.delayMinutes}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Zeit/Status
          if (isCancelled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ausfall',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              minutes == 0 ? 'jetzt' : '$minutes min',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: minutes <= 5
                        ? MshColors.engagementCritical
                        : MshColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm,
            vertical: MshSpacing.md,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: MshSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Autocomplete Location Input mit Haltestellensuche
class _LocationInputWithAutocomplete extends ConsumerStatefulWidget {
  const _LocationInputWithAutocomplete({
    required this.icon,
    required this.hint,
    required this.iconColor,
    required this.onLocationSelected,
  });

  final IconData icon;
  final String hint;
  final Color iconColor;
  final ValueChanged<TransitStop?> onLocationSelected;

  @override
  ConsumerState<_LocationInputWithAutocomplete> createState() =>
      _LocationInputWithAutocompleteState();
}

class _LocationInputWithAutocompleteState
    extends ConsumerState<_LocationInputWithAutocomplete> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus && mounted) {
          _removeOverlay();
        }
      });
    }
  }

  void _onTextChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < 2) {
      _removeOverlay();
      widget.onLocationSelected(null);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() => _currentQuery = query);
      _showOverlay();
    });
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => _SuggestionsOverlay(
        link: _layerLink,
        query: _currentQuery,
        onItemTap: _selectLocation,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectLocation(TransitStop stop) {
    _controller.text = stop.name;
    _removeOverlay();
    _focusNode.unfocus();
    widget.onLocationSelected(stop);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: MshColors.background,
          borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: MshColors.textMuted),
            prefixIcon: Icon(widget.icon, color: widget.iconColor, size: 20),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _controller.clear();
                      _removeOverlay();
                      widget.onLocationSelected(null);
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MshSpacing.sm,
              vertical: MshSpacing.sm,
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay für Autocomplete-Vorschläge
class _SuggestionsOverlay extends ConsumerWidget {
  const _SuggestionsOverlay({
    required this.link,
    required this.query,
    required this.onItemTap,
  });

  final LayerLink link;
  final String query;
  final ValueChanged<TransitStop> onItemTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(searchLocationsProvider(query));

    return Positioned(
      width: MediaQuery.of(context).size.width - (MshSpacing.lg * 4),
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: const Offset(0, 48),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
          color: MshColors.surface,
          child: suggestionsAsync.when(
            data: (stops) {
              if (stops.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(MshSpacing.md),
                  child: Text(
                    'Keine Ergebnisse gefunden',
                    style: TextStyle(color: MshColors.textMuted),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    return InkWell(
                      onTap: () => onItemTap(stop),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MshSpacing.md,
                          vertical: MshSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              stop.isStation
                                  ? Icons.train
                                  : Icons.directions_bus,
                              size: 18,
                              color: MshColors.primary,
                            ),
                            const SizedBox(width: MshSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stop.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (stop.distance != null)
                                    Text(
                                      stop.distanceFormatted,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: MshColors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(MshSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(MshSpacing.md),
              child: Text(
                'Fehler bei der Suche',
                style: TextStyle(color: MshColors.error),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SharingCard extends StatelessWidget {
  const _SharingCard({
    required this.icon,
    required this.label,
    required this.available,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int? available;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isComingSoon = available == null;

    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label - Demnächst in MSH verfügbar'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(MshSpacing.md),
        decoration: BoxDecoration(
          color: MshColors.surface,
          borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
          border: Border.all(color: MshColors.textMuted.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(MshSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isComingSoon ? 0.05 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isComingSoon ? color.withValues(alpha: 0.5) : color,
                size: 24,
              ),
            ),
            const SizedBox(height: MshSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isComingSoon
                        ? MshColors.textMuted
                        : MshColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 2),
            if (available != null)
              Text(
                '$available verfügbar',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MshColors.engagementNormal,
                    ),
              )
            else
              Text(
                'Demnächst',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MshColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
