import 'package:flutter/material.dart';

import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../domain/restaurant.dart';

class RestaurantDetailContent extends StatelessWidget {
  const RestaurantDetailContent({required this.restaurant, super.key});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tagesangebot oder Lunch-Radar Hinweis
        if (restaurant.todaySpecial != null) ...[
          const _SectionTitle('Tagesangebot'),
          _InfoCard(
            icon: Icons.restaurant_menu,
            title: restaurant.todaySpecial!,
            subtitle: restaurant.todayPrice != null
                ? '${restaurant.todayPrice!.toStringAsFixed(2)} €'
                : null,
          ),
          const SizedBox(height: 16),
        ] else ...[
          const _LunchRadarHint(),
          const SizedBox(height: 16),
        ],
        if (restaurant.address != null) ...[
          const _SectionTitle('Adresse'),
          _InfoCard(icon: Icons.location_on, title: restaurant.address!),
          const SizedBox(height: 16),
        ],
        if (restaurant.phone != null) ...[
          const _SectionTitle('Kontakt'),
          _InfoCard(icon: Icons.phone, title: restaurant.phone!),
          const SizedBox(height: 16),
        ],
        if (restaurant.openingHours.isNotEmpty) ...[
          const _SectionTitle('Öffnungszeiten'),
          ...restaurant.openingHours.map(
            (h) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(h),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {

  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
      ),
    );
  }
}

/// Hinweis auf kommendes Lunch-Radar Feature
class _LunchRadarHint extends StatelessWidget {
  const _LunchRadarHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: MshColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(
          color: MshColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MshSpacing.sm),
                decoration: BoxDecoration(
                  color: MshColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: MshColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: MshSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Lunch-Radar',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: MshColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: MshSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: MshColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'BALD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tägliche Mittagsangebote direkt vom Restaurant',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MshColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MshSpacing.sm),
          // Zusatzinfo für Gastronomen
          Container(
            padding: const EdgeInsets.all(MshSpacing.sm),
            decoration: BoxDecoration(
              color: MshColors.surface,
              borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: MshColors.textMuted,
                ),
                const SizedBox(width: MshSpacing.xs),
                Expanded(
                  child: Text(
                    'Gastronomen können ihre Speisekarte per Foto hochladen – automatische Erkennung durch KOLAN Tensor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MshColors.textMuted,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
