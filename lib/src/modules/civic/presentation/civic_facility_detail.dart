import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../../shared/widgets/transport_buttons.dart';
import '../domain/civic_category.dart';
import '../domain/civic_facility.dart';

/// Detail-Ansicht für öffentliche/soziale Einrichtungen
class CivicFacilityDetailContent extends StatelessWidget {
  const CivicFacilityDetailContent({
    required this.facility,
    super.key,
  });

  final CivicFacility facility;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategorie-Badge
          _CategoryBadge(category: facility.civicCategory),

          const SizedBox(height: MshSpacing.md),

          // Name
          Text(
            facility.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MshColors.textStrong,
                ),
          ),

          // Beschreibung
          if (facility.description != null && facility.description!.isNotEmpty) ...[
            const SizedBox(height: MshSpacing.sm),
            Text(
              facility.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MshColors.textSecondary,
                  ),
            ),
          ],

          // Betreiber
          if (facility.operator != null) ...[
            const SizedBox(height: MshSpacing.sm),
            Text(
              facility.operator!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MshColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],

          const SizedBox(height: MshSpacing.lg),

          // TELEFON-BUTTON
          if (facility.phone != null) _LargePhoneButton(facility: facility),

          const SizedBox(height: MshSpacing.md),

          // Route-Button
          _LargeActionButton(
            icon: Icons.directions,
            label: 'Route anzeigen',
            color: MshColors.primary,
            onTap: () => _openMaps(context),
          ),

          const Divider(height: MshSpacing.xl),

          // Adresse
          if (facility.fullAddress.isNotEmpty)
            _InfoSection(
              icon: Icons.location_on,
              title: 'Adresse',
              content: facility.fullAddress,
            ),

          // Öffnungszeiten mit Geöffnet/Geschlossen Badge
          if (facility.openingHours != null && facility.openingHours!.isNotEmpty) ...[
            const SizedBox(height: MshSpacing.md),
            _OpeningHoursSection(facility: facility),
          ],

          const Divider(height: MshSpacing.xl),

          // Badges (Barrierefreiheit, Zielgruppe)
          _AccessibilitySection(facility: facility),

          const Divider(height: MshSpacing.xl),

          // ÖPNV / Anreise
          TransportButtons(
            latitude: facility.coordinates.latitude,
            longitude: facility.coordinates.longitude,
            placeName: facility.name,
          ),

          // Weitere Kontaktmöglichkeiten
          if (facility.email != null || facility.website != null) ...[
            const Divider(height: MshSpacing.xl),
            _ContactSection(facility: facility),
          ],

          const SizedBox(height: MshSpacing.xl),
        ],
      ),
    );
  }

  void _openMaps(BuildContext context) {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${facility.coordinates.latitude},${facility.coordinates.longitude}',
    );
    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

// ═══════════════════════════════════════════════════════════════
// KOMPONENTEN
// ═══════════════════════════════════════════════════════════════

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final CivicCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MshSpacing.md,
        vertical: MshSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
        border: Border.all(color: category.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, color: category.color, size: 20),
          const SizedBox(width: MshSpacing.sm),
          Text(
            category.label,
            style: TextStyle(
              color: category.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LargePhoneButton extends StatelessWidget {
  const _LargePhoneButton({required this.facility});

  final CivicFacility facility;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: facility.civicCategory.color,
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse('tel:${facility.phone}')),
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.lg,
            vertical: MshSpacing.md + 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, color: Colors.white, size: 28),
              const SizedBox(width: MshSpacing.md),
              Text(
                facility.phoneFormatted ?? facility.phone!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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

class _LargeActionButton extends StatelessWidget {
  const _LargeActionButton({
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.lg,
            vertical: MshSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: MshSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: MshColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Öffnungszeiten-Sektion mit Geöffnet/Geschlossen Badge
class _OpeningHoursSection extends StatelessWidget {
  const _OpeningHoursSection({required this.facility});

  final CivicFacility facility;

  @override
  Widget build(BuildContext context) {
    final isOpen = facility.isOpenNow;
    final todayHours = facility.todayHours;

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
        // Heute-Zeiten hervorheben
        if (todayHours != null) ...[
          Container(
            padding: const EdgeInsets.all(MshSpacing.sm),
            decoration: BoxDecoration(
              color: MshColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
            ),
            child: Row(
              children: [
                const Icon(Icons.today, size: 16, color: MshColors.primary),
                const SizedBox(width: MshSpacing.xs),
                Text(
                  'Heute: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: MshColors.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    todayHours,
                    style: TextStyle(color: MshColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: MshSpacing.sm),
        ],
        // Vollständige Öffnungszeiten
        Text(
          facility.openingHours!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MshColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _AccessibilitySection extends StatelessWidget {
  const _AccessibilitySection({required this.facility});

  final CivicFacility facility;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    // Zielgruppe
    if (facility.isYouthRelevant) {
      badges.add(const _Badge(icon: Icons.people, label: 'Für Jugendliche'));
    }
    if (facility.isSeniorRelevant) {
      badges.add(const _Badge(icon: Icons.elderly, label: 'Für Senioren'));
    }

    // Barrierefreiheit
    if (facility.isBarrierFree) {
      badges.add(const _Badge(icon: Icons.accessible, label: 'Barrierefrei'));
    }
    if (facility.hasParking) {
      badges.add(const _Badge(icon: Icons.local_parking, label: 'Parkplätze'));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: MshSpacing.sm,
      runSpacing: MshSpacing.sm,
      children: badges,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MshColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: MshColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: MshColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.facility});

  final CivicFacility facility;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontakt',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: MshSpacing.md),
        if (facility.email != null)
          _ContactRow(
            icon: Icons.email,
            label: facility.email!,
            onTap: () => launchUrl(Uri.parse('mailto:${facility.email}')),
          ),
        if (facility.website != null)
          _ContactRow(
            icon: Icons.language,
            label: 'Website öffnen',
            onTap: () => launchUrl(
              Uri.parse(facility.website!),
              mode: LaunchMode.externalApplication,
            ),
          ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MshSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: MshColors.primary, size: 20),
            const SizedBox(width: MshSpacing.md),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: MshColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: MshColors.textMuted),
          ],
        ),
      ),
    );
  }
}
