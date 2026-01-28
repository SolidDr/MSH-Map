import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_spacing.dart';
import '../../../../core/theme/msh_theme.dart';
import '../../../../shared/widgets/msh_bottom_sheet.dart';
import '../../data/health_repository.dart';
import '../../domain/health_facility.dart';

/// Provider für Notdienst-Apotheken
final emergencyPharmaciesProvider =
    FutureProvider.autoDispose<List<HealthFacility>>((ref) async {
  final repository = HealthRepository();
  await repository.loadFromAssets();
  return repository.getEmergencyPharmacies();
});

/// Modal zum Anzeigen der Notdienst-Apotheken
/// Optimiert für Senioren mit großen Buttons und klarer Darstellung
class EmergencyPharmacyModal extends ConsumerWidget {
  const EmergencyPharmacyModal({
    super.key,
    this.onNavigate,
  });

  final void Function(HealthFacility pharmacy)? onNavigate;

  static Future<void> show(
    BuildContext context, {
    void Function(HealthFacility pharmacy)? onNavigate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmergencyPharmacyModal(onNavigate: onNavigate),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmaciesAsync = ref.watch(emergencyPharmaciesProvider);

    return MshBottomSheet(
      title: 'Notdienst-Apotheken',
      icon: Icons.local_pharmacy,
      iconColor: MshColors.emergencyGreen,
      builder: (context) => pharmaciesAsync.when(
        data: (pharmacies) => _buildContent(context, pharmacies),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(MshSpacing.xl),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => _buildError(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<HealthFacility> pharmacies) {
    if (pharmacies.isEmpty) {
      return _buildNoPharmacies(context);
    }

    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d. MMMM', 'de_DE');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info-Banner
        Container(
          padding: const EdgeInsets.all(MshSpacing.md),
          decoration: BoxDecoration(
            color: MshColors.emergencyGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
            border: Border.all(
              color: MshColors.emergencyGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: MshColors.emergencyGreen,
                size: 20,
              ),
              const SizedBox(width: MshSpacing.sm),
              Expanded(
                child: Text(
                  'Notdienst-Apotheken für ${dateFormat.format(now)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MshColors.emergencyGreen,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: MshSpacing.md),

        // Apotheken-Liste
        ...pharmacies.map((pharmacy) => Padding(
              padding: const EdgeInsets.only(bottom: MshSpacing.md),
              child: _PharmacyCard(
                pharmacy: pharmacy,
                onNavigate: onNavigate != null
                    ? () {
                        Navigator.pop(context);
                        onNavigate!(pharmacy);
                      }
                    : null,
              ),
            ),),

        const SizedBox(height: MshSpacing.sm),

        // Hinweis
        Text(
          'Tipp: Rufen Sie vor dem Besuch an, um die Verfügbarkeit zu prüfen.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: MshColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }

  Widget _buildNoPharmacies(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MshSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off,
            size: 48,
            color: MshColors.textSecondary,
          ),
          const SizedBox(height: MshSpacing.md),
          Text(
            'Keine Notdienst-Apotheken gefunden',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: MshColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MshSpacing.sm),
          Text(
            'Bitte versuchen Sie es später erneut oder rufen Sie die 116117 an.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MshColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MshSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: MshColors.error,
          ),
          const SizedBox(height: MshSpacing.md),
          Text(
            'Fehler beim Laden',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: MshColors.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MshSpacing.sm),
          Text(
            'Bitte prüfen Sie Ihre Internetverbindung.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MshColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PharmacyCard extends StatelessWidget {
  const _PharmacyCard({
    required this.pharmacy,
    this.onNavigate,
  });

  final HealthFacility pharmacy;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        border: Border.all(
          color: MshColors.emergencyGreen,
          width: 2,
        ),
        boxShadow: MshColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(MshSpacing.md),
            decoration: BoxDecoration(
              color: MshColors.emergencyGreen.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(MshTheme.radiusMedium - 2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MshColors.emergencyGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_pharmacy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: MshSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (pharmacy.emergencyService?.dutyHours != null)
                        Text(
                          'Notdienst: ${pharmacy.emergencyService!.dutyHours}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: MshColors.emergencyGreen,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(MshSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adresse
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.place,
                      size: 18,
                      color: MshColors.textSecondary,
                    ),
                    const SizedBox(width: MshSpacing.sm),
                    Expanded(
                      child: Text(
                        pharmacy.fullAddress,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15, // Etwas größer für Senioren
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: MshSpacing.md),

                // Aktions-Buttons
                Row(
                  children: [
                    // Anrufen Button (prominent)
                    if (pharmacy.phone != null)
                      Expanded(
                        flex: 2,
                        child: _LargeActionButton(
                          icon: Icons.phone,
                          label: pharmacy.phoneFormatted ?? pharmacy.phone!,
                          color: MshColors.emergencyGreen,
                          onTap: () => _callPharmacy(pharmacy.phone!),
                        ),
                      ),

                    if (pharmacy.phone != null && onNavigate != null)
                      const SizedBox(width: MshSpacing.sm),

                    // Route Button
                    if (onNavigate != null)
                      Expanded(
                        child: _LargeActionButton(
                          icon: Icons.directions,
                          label: 'Route',
                          color: MshColors.primary,
                          outlined: true,
                          onTap: onNavigate,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callPharmacy(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _LargeActionButton extends StatelessWidget {
  const _LargeActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.outlined = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.white : color,
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.md,
            vertical: MshSpacing.sm + 4,
          ),
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
                  border: Border.all(color: color, width: 2),
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: outlined ? color : Colors.white,
              ),
              const SizedBox(width: MshSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: outlined ? color : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
