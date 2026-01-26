import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_theme.dart';
import '../utils/transport_helper.dart';

/// Widget that displays public transport buttons for getting to a location
class TransportButtons extends StatelessWidget {
  const TransportButtons({
    required this.latitude,
    required this.longitude,
    this.placeName,
    super.key,
  });

  final double latitude;
  final double longitude;
  final String? placeName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anreise',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshTheme.spacingSm),
        Row(
          children: [
            Expanded(
              child: _TransportButton(
                icon: Icons.directions_transit,
                label: 'ÖPNV',
                color: MshColors.info,
                onTap: () async {
                  final success = await TransportHelper.openPublicTransitDirections(
                    latitude: latitude,
                    longitude: longitude,
                    placeName: placeName,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Konnte Karten-App nicht öffnen'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: MshTheme.spacingSm),
            Expanded(
              child: _TransportButton(
                icon: Icons.directions,
                label: 'Navigation',
                color: MshColors.primary,
                onTap: () async {
                  final success = await TransportHelper.openDirections(
                    latitude: latitude,
                    longitude: longitude,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Konnte Karten-App nicht öffnen'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({
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
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: MshTheme.spacingMd,
          vertical: MshTheme.spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
        ),
      ),
    );
  }
}
