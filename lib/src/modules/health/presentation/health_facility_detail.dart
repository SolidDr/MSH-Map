import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../../shared/widgets/transport_buttons.dart';
import '../domain/health_category.dart';
import '../domain/health_facility.dart';

/// Detail-Ansicht für Gesundheitseinrichtungen
/// Optimiert für Senioren: Große Schrift, große Buttons, hoher Kontrast
class HealthFacilityDetailContent extends StatelessWidget {
  const HealthFacilityDetailContent({
    required this.facility,
    super.key,
  });

  final HealthFacility facility;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MshSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategorie-Badge
          _CategoryBadge(
            category: facility.healthCategory,
            specialization: facility.specialization,
          ),

          const SizedBox(height: MshSpacing.md),

          // Name (große Schrift für Senioren)
          Text(
            facility.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MshColors.textStrong,
                ),
          ),

          // Fachrichtung falls vorhanden
          if (facility.specialization != null) ...[
            const SizedBox(height: MshSpacing.xs),
            Text(
              facility.specialization!.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: facility.healthCategory.color,
                  ),
            ),
          ],

          const SizedBox(height: MshSpacing.lg),

          // GROSSER TELEFON-BUTTON (prominenteste Aktion für Senioren)
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

          // Öffnungszeiten (Map-Format)
          if (facility.openingHours != null) ...[
            const SizedBox(height: MshSpacing.md),
            _OpeningHoursSection(facility: facility),
          ],

          // Öffnungszeiten (String-Format aus OSM)
          if (facility.openingHoursRaw != null && facility.openingHours == null) ...[
            const SizedBox(height: MshSpacing.md),
            _OpeningHoursRawSection(facility: facility),
          ],

          // Sprechstunde ohne Termin
          if (facility.walkInHours != null) ...[
            const SizedBox(height: MshSpacing.md),
            _InfoSection(
              icon: Icons.schedule,
              title: 'Sprechstunde ohne Termin',
              content: facility.walkInHours!,
            ),
          ],

          const Divider(height: MshSpacing.xl),

          // Barrierefreiheit & Services
          _AccessibilitySection(facility: facility),

          // Notdienst-Info für Apotheken
          if (facility.emergencyService != null) ...[
            const SizedBox(height: MshSpacing.md),
            _EmergencyServiceSection(facility: facility),
          ],

          // Fitness-Angebote
          if (facility.fitnessOffers.isNotEmpty) ...[
            const Divider(height: MshSpacing.xl),
            _FitnessOffersSection(facility: facility),
          ],

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
  const _CategoryBadge({
    required this.category,
    this.specialization,
  });

  final HealthCategory category;
  final DoctorSpecialization? specialization;

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

/// Großer Telefon-Button für Senioren
class _LargePhoneButton extends StatelessWidget {
  const _LargePhoneButton({required this.facility});

  final HealthFacility facility;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MshColors.categoryHealth,
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
              const Icon(
                Icons.phone,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: MshSpacing.md),
              Text(
                facility.phoneFormatted ?? facility.phone!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Große Schrift für Senioren!
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

class _OpeningHoursSection extends StatelessWidget {
  const _OpeningHoursSection({required this.facility});

  final HealthFacility facility;

  @override
  Widget build(BuildContext context) {
    final isOpen = facility.isOpenNow;

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
        _buildOpeningHoursTable(context),
      ],
    );
  }

  Widget _buildOpeningHoursTable(BuildContext context) {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final dayNames = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
    final today = DateTime.now().weekday - 1;

    return Column(
      children: List.generate(7, (index) {
        final dayData = facility.openingHours![days[index]] as Map<String, dynamic>?;
        final isToday = index == today;

        String hours = 'Geschlossen';
        if (dayData != null) {
          hours = '${dayData['from']} - ${dayData['to']}';
          if (dayData['afternoon'] != null) {
            final pm = dayData['afternoon'] as Map<String, dynamic>;
            hours += ', ${pm['from']} - ${pm['to']}';
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: isToday
              ? BoxDecoration(
                  color: MshColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  dayNames[index],
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    color: MshColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  hours,
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    color: dayData == null ? MshColors.textMuted : MshColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Öffnungszeiten-Sektion für OSM String-Format mit Geöffnet/Geschlossen Badge
class _OpeningHoursRawSection extends StatelessWidget {
  const _OpeningHoursRawSection({required this.facility});

  final HealthFacility facility;

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
                Text(
                  todayHours,
                  style: TextStyle(color: MshColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: MshSpacing.sm),
        ],
        // Vollständige Öffnungszeiten
        Text(
          facility.openingHoursRaw!,
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

  final HealthFacility facility;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    if (facility.isBarrierFree) {
      badges.add(_Badge(icon: Icons.accessible, label: 'Barrierefrei'));
    }
    if (facility.hasHouseCalls) {
      badges.add(_Badge(icon: Icons.home, label: 'Hausbesuche'));
    }
    if (facility.hasParking) {
      badges.add(_Badge(icon: Icons.local_parking, label: 'Parkplätze'));
    }
    if (facility.hasDelivery) {
      badges.add(_Badge(icon: Icons.delivery_dining, label: 'Lieferservice'));
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
            style: TextStyle(
              fontSize: 13,
              color: MshColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyServiceSection extends StatelessWidget {
  const _EmergencyServiceSection({required this.facility});

  final HealthFacility facility;

  @override
  Widget build(BuildContext context) {
    final service = facility.emergencyService!;
    final isOnDuty = service.isCurrentlyOnDuty;

    return Container(
      padding: const EdgeInsets.all(MshSpacing.md),
      decoration: BoxDecoration(
        color: isOnDuty
            ? MshColors.emergencyGreen.withValues(alpha: 0.1)
            : MshColors.surfaceVariant,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(
          color: isOnDuty ? MshColors.emergencyGreen : Colors.transparent,
          width: isOnDuty ? 2 : 0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_pharmacy,
                color: isOnDuty ? MshColors.emergencyGreen : MshColors.textSecondary,
              ),
              const SizedBox(width: MshSpacing.sm),
              Text(
                'Notdienst',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isOnDuty ? MshColors.emergencyGreen : MshColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isOnDuty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MshColors.emergencyGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'JETZT AKTIV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (service.dutyHours != null) ...[
            const SizedBox(height: MshSpacing.sm),
            Text(
              'Notdienst-Zeiten: ${service.dutyHours}',
              style: TextStyle(color: MshColors.textSecondary),
            ),
          ],
          if (service.nextDutyDate != null && !isOnDuty) ...[
            const SizedBox(height: MshSpacing.sm),
            Text(
              'Nächster Notdienst: ${_formatDate(service.nextDutyDate!)}',
              style: TextStyle(color: MshColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return '${weekdays[date.weekday - 1]}, ${date.day}.${date.month}.${date.year}';
  }
}

class _FitnessOffersSection extends StatelessWidget {
  const _FitnessOffersSection({required this.facility});

  final HealthFacility facility;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.fitness_center, color: MshColors.categoryFitnessSenior),
            const SizedBox(width: MshSpacing.sm),
            Text(
              'Angebote',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: MshSpacing.md),
        ...facility.fitnessOffers.map((offer) => Container(
              margin: const EdgeInsets.only(bottom: MshSpacing.sm),
              padding: const EdgeInsets.all(MshSpacing.md),
              decoration: BoxDecoration(
                color: MshColors.surfaceVariant,
                borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${offer.day}, ${offer.time}',
                    style: TextStyle(color: MshColors.textSecondary),
                  ),
                  if (offer.location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      offer.location!,
                      style: TextStyle(color: MshColors.textSecondary),
                    ),
                  ],
                  if (offer.cost != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      offer.cost!,
                      style: TextStyle(
                        color: MshColors.categoryHealth,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            )),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.facility});

  final HealthFacility facility;

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
                style: TextStyle(
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
