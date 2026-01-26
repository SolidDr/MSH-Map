import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/data/msh_border_data.dart';

/// Fog of War Layer - Zeigt nebeligen Rand außerhalb der MSH-Region
///
/// Technische Umsetzung:
/// - Äußeres Polygon (outerBounds) deckt großen Bereich ab
/// - Inneres Polygon (mshBorder) wird als "Loch" ausgeschnitten
/// - Ergebnis: Alles außer MSH ist nebelig
class FogOfWarLayer extends StatelessWidget {
  const FogOfWarLayer({
    super.key,
    this.useDetailedBorder = false,
    this.fogColor = const Color(0xDD1a1a2e),
    this.opacity = 1.0,
  });

  /// Ob detailliertes Polygon verwendet werden soll (30 statt 15 Punkte)
  final bool useDetailedBorder;

  /// Farbe des Nebels (Standard: Dunkel-Blau/Lila)
  final Color fogColor;

  /// Opazität (0.0 = transparent, 1.0 = voll sichtbar)
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();

    final border = useDetailedBorder
        ? MshBorderData.mshBorderDetailed
        : MshBorderData.mshBorderSimplified;

    return Opacity(
      opacity: opacity,
      child: PolygonLayer(
        polygons: [
          Polygon(
            points: MshBorderData.outerBounds,
            holePointsList: [border],
            color: fogColor,
            borderColor: Colors.transparent,
            borderStrokeWidth: 0,
          ),
        ],
      ),
    );
  }
}

/// Adaptiver Fog Layer - Passt Transparenz an Zoom-Level an
///
/// Je näher man heranzoomt, desto transparenter wird der Nebel.
/// Bei Zoom > 13 verschwindet der Nebel schrittweise.
class AdaptiveFogOfWarLayer extends StatelessWidget {
  const AdaptiveFogOfWarLayer({
    required this.currentZoom,
    super.key,
    this.useDetailedBorder = false,
    this.fogColor = const Color(0xDD1a1a2e),
    this.fadeStartZoom = 13.0,
    this.fadeRate = 0.15,
  });

  /// Aktueller Zoom-Level der Karte
  final double currentZoom;

  /// Ob detailliertes Polygon verwendet werden soll
  final bool useDetailedBorder;

  /// Farbe des Nebels
  final Color fogColor;

  /// Bei welchem Zoom beginnt der Nebel zu verblassen
  final double fadeStartZoom;

  /// Wie schnell der Nebel verblasst (pro Zoom-Level)
  final double fadeRate;

  @override
  Widget build(BuildContext context) {
    // Berechne Opazität basierend auf Zoom
    final opacity = currentZoom > fadeStartZoom
        ? (1.0 - (currentZoom - fadeStartZoom) * fadeRate).clamp(0.0, 1.0)
        : 1.0;

    return FogOfWarLayer(
      useDetailedBorder: useDetailedBorder,
      fogColor: fogColor,
      opacity: opacity,
    );
  }
}

/// Fog of War Varianten - Verschiedene visuelle Stile
class FogVariants {
  FogVariants._();

  /// Standard - Dunkles Lila/Blau
  static const Color dark = Color(0xDD1a1a2e);

  /// Nebelig - Grauer Nebel
  static const Color foggy = Color(0xBB8899aa);

  /// Sepia - Alte Karte Stil
  static const Color sepia = Color(0xAAd4c5a9);

  /// Mystisch - Tiefes Violett
  static const Color mystic = Color(0xBB2d1b4e);

  /// Dunkelgrün - Wald-Thema
  static const Color forest = Color(0xCC1a3a2e);

  /// Transparent - Leichter Effekt
  static const Color light = Color(0x66000000);
}
