import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/config/feature_flags.dart';
import '../application/engagement_provider.dart';
import '../domain/engagement_model.dart';
import 'engagement_marker.dart';

/// Map-Layer für Engagement-Orte
/// Zeigt EngagementMarker auf der Karte
class EngagementMapLayer extends ConsumerWidget {
  final void Function(EngagementPlace)? onPlaceTap;

  const EngagementMapLayer({super.key, this.onPlaceTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enableEngagementOnMap) {
      return const SizedBox.shrink();
    }

    final placesAsync = ref.watch(engagementPlacesProvider);

    return placesAsync.when(
      data: (places) => MarkerLayer(
        markers: places
            .map((place) => Marker(
                  point: LatLng(place.latitude, place.longitude),
                  width: 56,
                  height: 64,
                  child: EngagementMarker(
                    type: place.type,
                    urgency: place.maxUrgency,
                    adoptableCount:
                        place.adoptableCount > 0 ? place.adoptableCount : null,
                    onTap: () => onPlaceTap?.call(place),
                  ),
                ))
            .toList(),
      ),
      loading: () => const MarkerLayer(markers: []),
      error: (_, __) => const MarkerLayer(markers: []),
    );
  }
}
