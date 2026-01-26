import 'package:flutter/material.dart';
import '../domain/map_item.dart';
import '../../modules/_module_registry.dart';

class PoiBottomSheet extends StatelessWidget {

  const PoiBottomSheet({super.key, required this.item});
  final MapItem item;

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

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
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
