import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/msh_colors.dart';
import '../../../../core/theme/msh_spacing.dart';
import '../../../../core/theme/msh_theme.dart';

/// Prominenter Notfall-Bereich für schnellen Zugriff auf Notfallnummern
/// Optimiert für Senioren mit großen Touch-Targets und hohem Kontrast
class EmergencySection extends StatelessWidget {
  const EmergencySection({
    super.key,
    this.onEmergencyPharmacyTap,
  });

  final VoidCallback? onEmergencyPharmacyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MshColors.emergencyRed, width: 2),
        borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: MshColors.emergencyRed.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(MshSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MshColors.emergencyRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: MshSpacing.sm),
              Text(
                'Notfall',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MshColors.emergencyRed,
                    ),
              ),
            ],
          ),

          const SizedBox(height: MshSpacing.md),

          // Emergency Buttons
          Wrap(
            spacing: MshSpacing.sm,
            runSpacing: MshSpacing.sm,
            children: [
              _EmergencyButton(
                number: '112',
                label: 'Notruf',
                sublabel: 'Rettungsdienst, Feuerwehr',
                color: MshColors.emergencyRed,
                icon: Icons.local_hospital,
                onTap: () => _callNumber('112'),
              ),
              _EmergencyButton(
                number: '116 117',
                label: 'Ärztlicher Bereitschaftsdienst',
                sublabel: 'Außerhalb der Praxiszeiten',
                color: MshColors.emergencyBlue,
                icon: Icons.medical_services,
                onTap: () => _callNumber('116117'),
              ),
              _EmergencyButton(
                label: 'Notdienst-Apotheke',
                sublabel: 'Apotheke mit Notdienst finden',
                color: MshColors.emergencyGreen,
                icon: Icons.local_pharmacy,
                onTap: onEmergencyPharmacyTap,
              ),
              _EmergencyButton(
                number: '0800 111 0 111',
                label: 'Telefonseelsorge',
                sublabel: 'Kostenlos, 24/7, anonym',
                color: MshColors.emergencyPurple,
                icon: Icons.psychology,
                onTap: () => _callNumber('08001110111'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({
    required this.label,
    required this.color,
    required this.icon,
    this.number,
    this.sublabel,
    this.onTap,
  });

  final String? number;
  final String label;
  final String? sublabel;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 100,
            minHeight: 80, // Große Touch-Targets für Senioren
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.md,
            vertical: MshSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  if (number != null) ...[
                    const SizedBox(width: MshSpacing.sm),
                    Text(
                      number!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Große Schrift für Senioren
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sublabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  sublabel!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Kompakte Version des Notfall-Bereichs für die Schnellauswahl
class EmergencyQuickAccess extends StatelessWidget {
  const EmergencyQuickAccess({
    super.key,
    this.onEmergencyPharmacyTap,
  });

  final VoidCallback? onEmergencyPharmacyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactEmergencyButton(
            number: '112',
            label: 'Notruf',
            color: MshColors.emergencyRed,
            onTap: () => _callNumber('112'),
          ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: _CompactEmergencyButton(
            number: '116117',
            label: 'Bereitschaft',
            color: MshColors.emergencyBlue,
            onTap: () => _callNumber('116117'),
          ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: _CompactEmergencyButton(
            icon: Icons.local_pharmacy,
            label: 'Apotheke',
            color: MshColors.emergencyGreen,
            onTap: onEmergencyPharmacyTap,
          ),
        ),
        const SizedBox(width: MshSpacing.sm),
        Expanded(
          child: _CompactEmergencyButton(
            icon: Icons.psychology,
            label: 'Seelsorge',
            color: MshColors.emergencyPurple,
            onTap: () => _callNumber('08001110111'),
          ),
        ),
      ],
    );
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _CompactEmergencyButton extends StatelessWidget {
  const _CompactEmergencyButton({
    required this.label,
    required this.color,
    this.number,
    this.icon,
    this.onTap,
  });

  final String? number;
  final IconData? icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm,
            vertical: MshSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (number != null)
                Text(
                  number!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
