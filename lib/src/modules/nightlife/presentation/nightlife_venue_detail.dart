import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../domain/nightlife_venue.dart';

/// Detail-Inhalt für NightlifeVenue im BottomSheet
class NightlifeVenueDetailContent extends StatelessWidget {
  const NightlifeVenueDetailContent({super.key, required this.venue});

  final NightlifeVenue venue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategorie-Badge + Open/Closed Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: MshColors.categoryNightlife.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      venue.nightlifeCategory.icon,
                      size: 16,
                      color: MshColors.categoryNightlife,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      venue.nightlifeCategory.label,
                      style: TextStyle(
                        color: MshColors.categoryNightlife,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (venue.openingHours != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: venue.isOpenNow ? MshColors.success : MshColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    venue.isOpenNow ? 'Geöffnet' : 'Geschlossen',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: MshSpacing.lg),

          // Adresse
          if (venue.fullAddress.isNotEmpty)
            _InfoSection(
              icon: Icons.location_on,
              title: 'Adresse',
              content: venue.fullAddress,
            ),

          // Öffnungszeiten
          if (venue.openingHours != null && venue.openingHours!.isNotEmpty) ...[
            const SizedBox(height: MshSpacing.md),
            _OpeningHoursSection(venue: venue),
          ],

          // Beschreibung
          if (venue.description != null && venue.description!.isNotEmpty) ...[
            const SizedBox(height: MshSpacing.md),
            _InfoSection(
              icon: Icons.info_outline,
              title: 'Beschreibung',
              content: venue.description!,
            ),
          ],

          const Divider(height: MshSpacing.xl),

          // Features
          _FeaturesSection(venue: venue),

          const Divider(height: MshSpacing.xl),

          // Kontakt-Buttons
          _ContactSection(venue: venue),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: MshColors.textSecondary, size: 20),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: MshColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpeningHoursSection extends StatelessWidget {
  const _OpeningHoursSection({required this.venue});

  final NightlifeVenue venue;

  @override
  Widget build(BuildContext context) {
    final isOpen = venue.isOpenNow;
    final todayHours = venue.todayHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, color: MshColors.textSecondary, size: 20),
            const SizedBox(width: MshSpacing.sm),
            Text(
              'Öffnungszeiten',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: MshColors.textSecondary,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOpen ? MshColors.success : MshColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOpen ? 'Geöffnet' : 'Geschlossen',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: MshSpacing.sm),
        if (todayHours != null) ...[
          Container(
            padding: const EdgeInsets.all(MshSpacing.sm),
            decoration: BoxDecoration(
              color: MshColors.categoryNightlife.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(Icons.today, size: 16, color: MshColors.categoryNightlife),
                const SizedBox(width: MshSpacing.xs),
                Text(
                  'Heute: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: MshColors.categoryNightlife,
                  ),
                ),
                Expanded(
                  child: Text(
                    todayHours,
                    style: const TextStyle(color: MshColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: MshSpacing.sm),
        ],
        Text(
          venue.openingHours!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MshColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.venue});

  final NightlifeVenue venue;

  @override
  Widget build(BuildContext context) {
    final features = <Widget>[];

    if (venue.hasFood) {
      features.add(_FeatureBadge(
        icon: Icons.restaurant,
        label: 'Essen verfügbar',
        color: MshColors.success,
      ));
    }

    if (venue.hasLiveMusic) {
      features.add(_FeatureBadge(
        icon: Icons.music_note,
        label: 'Live-Musik',
        color: MshColors.categoryNightlife,
      ));
    }

    if (features.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: MshSpacing.sm,
      runSpacing: MshSpacing.sm,
      children: features,
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.venue});

  final NightlifeVenue venue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontakt',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshSpacing.md),

        // Telefon
        if (venue.phone != null)
          _ContactButton(
            icon: Icons.phone,
            label: venue.phoneFormatted ?? venue.phone!,
            onTap: () => launchUrl(Uri.parse('tel:${venue.phone}')),
          ),

        // Website
        if (venue.website != null) ...[
          const SizedBox(height: MshSpacing.sm),
          _ContactButton(
            icon: Icons.language,
            label: 'Website öffnen',
            onTap: () => launchUrl(
              Uri.parse(venue.website!),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],

        // Navigation
        const SizedBox(height: MshSpacing.sm),
        _ContactButton(
          icon: Icons.directions,
          label: 'Route planen',
          color: MshColors.categoryNightlife,
          onTap: () => launchUrl(
            Uri.parse(
              'https://www.google.com/maps/dir/?api=1&destination=${venue.latitude},${venue.longitude}',
            ),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? MshColors.primary;

    return Material(
      color: buttonColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: buttonColor, size: 20),
              const SizedBox(width: MshSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: buttonColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: MshColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
