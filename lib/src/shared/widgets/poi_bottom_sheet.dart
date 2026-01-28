import 'dart:js_interop';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';
import '../../modules/_module_registry.dart';
import '../domain/map_item.dart';

class PoiBottomSheet extends StatelessWidget {

  const PoiBottomSheet({required this.item, super.key});
  final MapItem item;

  /// Maximale Breite für Desktop/Web - verhindert zu breite Sheets
  static const double _maxWidth = 600;

  /// Druckt die aktuelle Seite (nur Web)
  static void _printPage() {
    if (kIsWeb) {
      web.window.print();
    }
  }

  static void show(BuildContext context, MapItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PoiBottomSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final module = ModuleRegistry.instance.getById(item.moduleId);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Adaptive Größen basierend auf Bildschirmhöhe
    // Kleine Bildschirme (<700px): mehr Platz nötig
    // Große Bildschirme (>900px): weniger Initialplatz, da mehr Inhalt sichtbar
    final double initialSize;
    final double minSize;
    final double maxSize;

    if (screenHeight < 700) {
      // Kleine Viewports (Mobile Landscape, kleine Fenster)
      initialSize = 0.75;
      minSize = 0.3;
      maxSize = 0.95;
    } else if (screenHeight < 900) {
      // Mittlere Viewports (Tablets, kleine Desktops)
      initialSize = 0.65;
      minSize = 0.25;
      maxSize = 0.92;
    } else {
      // Große Viewports (Desktop)
      initialSize = 0.6;
      minSize = 0.2;
      maxSize = 0.9;
    }

    // Zentrierung für breite Bildschirme
    final isWideScreen = screenWidth > _maxWidth + 100;

    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: [minSize, initialSize, maxSize],
      snapAnimationDuration: const Duration(milliseconds: 200),
      expand: false,
      builder: (context, scrollController) {
        final sheet = Container(
          constraints: BoxConstraints(
            maxWidth: isWideScreen ? _maxWidth : double.infinity,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(MshTheme.radiusXLarge),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
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
                            color: item.markerColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.place, color: item.markerColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.displayName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (item.subtitle != null)
                                Text(
                                  item.subtitle!,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                        // Drucken-Button (nur Web)
                        if (kIsWeb)
                          IconButton(
                            onPressed: () => _printPage(),
                            icon: const Icon(Icons.print),
                            tooltip: 'Drucken',
                            style: IconButton.styleFrom(
                              backgroundColor: MshColors.info.withValues(alpha: 0.1),
                              foregroundColor: MshColors.info,
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
                  ]),
                ),
              ),
            ],
          ),
        );

        // Bei breiten Bildschirmen zentrieren
        if (isWideScreen) {
          return Center(child: sheet);
        }
        return sheet;
      },
    );
  }
}
