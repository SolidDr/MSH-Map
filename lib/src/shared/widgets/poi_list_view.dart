import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';
import '../domain/map_item.dart';

/// Listenansicht für POIs - optimiert für Senioren
/// Zeigt Name, Kategorie, Adresse und Telefon direkt an
class PoiListView extends StatelessWidget {
  const PoiListView({
    super.key,
    required this.items,
    required this.onItemTap,
    this.scrollController,
  });

  final List<MapItem> items;
  final ValueChanged<MapItem> onItemTap;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: MshColors.textMuted,
              ),
              const SizedBox(height: MshSpacing.md),
              Text(
                'Keine Orte gefunden',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: MshColors.textSecondary,
                    ),
              ),
              const SizedBox(height: MshSpacing.xs),
              Text(
                'Versuche einen anderen Filter',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MshColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: MshSpacing.md,
        vertical: MshSpacing.sm,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: MshSpacing.xs),
      itemBuilder: (context, index) => _PoiListTile(
        item: items[index],
        onTap: () => onItemTap(items[index]),
      ),
    );
  }
}

/// Einzelner Listeneintrag - große Touch-Targets für Senioren
class _PoiListTile extends StatelessWidget {
  const _PoiListTile({
    required this.item,
    required this.onTap,
  });

  final MapItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final phone = item.metadata['phone'] as String?;
    final address = item.metadata['address'] as String?;
    final city = item.metadata['city'] as String?;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(MshSpacing.md),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.markerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                ),
                child: Icon(
                  _iconForCategory(item.category),
                  color: item.markerColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: MshSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      item.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: MshColors.textStrong,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtitle (Kategorie)
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: item.markerColor,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Address
                    if (address != null || city != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: MshColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address ?? city ?? '',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: MshColors.textSecondary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Phone Button (direkt anrufbar)
              if (phone != null) ...[
                const SizedBox(width: MshSpacing.sm),
                _PhoneButton(phone: phone),
              ],

              // Chevron
              const SizedBox(width: MshSpacing.xs),
              Icon(
                Icons.chevron_right,
                color: MshColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(MapItemCategory c) => switch (c) {
        MapItemCategory.restaurant => Icons.restaurant,
        MapItemCategory.cafe => Icons.coffee,
        MapItemCategory.imbiss => Icons.fastfood,
        MapItemCategory.bar => Icons.local_bar,
        MapItemCategory.event => Icons.event,
        MapItemCategory.culture => Icons.museum,
        MapItemCategory.sport => Icons.sports,
        MapItemCategory.playground => Icons.child_care,
        MapItemCategory.museum => Icons.account_balance,
        MapItemCategory.nature => Icons.park,
        MapItemCategory.zoo => Icons.pets,
        MapItemCategory.castle => Icons.castle,
        MapItemCategory.pool => Icons.pool,
        MapItemCategory.indoor => Icons.house,
        MapItemCategory.farm => Icons.agriculture,
        MapItemCategory.adventure => Icons.terrain,
        MapItemCategory.school => Icons.school,
        MapItemCategory.kindergarten => Icons.child_care,
        MapItemCategory.library => Icons.local_library,
        MapItemCategory.government => Icons.account_balance,
        MapItemCategory.youthCentre => Icons.group,
        MapItemCategory.socialFacility => Icons.volunteer_activism,
        MapItemCategory.doctor => Icons.medical_services,
        MapItemCategory.pharmacy => Icons.local_pharmacy,
        MapItemCategory.hospital => Icons.local_hospital,
        MapItemCategory.physiotherapy => Icons.spa,
        MapItemCategory.fitness => Icons.fitness_center,
        MapItemCategory.careService => Icons.elderly,
        MapItemCategory.service => Icons.build,
        MapItemCategory.search => Icons.search,
        MapItemCategory.custom => Icons.place,
      };
}

/// Telefon-Button - direkt anklickbar für schnellen Anruf
class _PhoneButton extends StatelessWidget {
  const _PhoneButton({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MshColors.success,
      borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
      child: InkWell(
        onTap: () => _callNumber(phone),
        borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.phone,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Future<void> _callNumber(String number) async {
    // Clean phone number
    final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
