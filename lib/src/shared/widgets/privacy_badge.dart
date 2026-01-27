import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/msh_colors.dart';

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPrivacySheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: MshColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MshColors.success.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍪', style: TextStyle(fontSize: 12)),
            SizedBox(width: 4),
            Text(
              '✕ Keine Cookies',
              style: TextStyle(
                fontSize: 11,
                color: MshColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user, color: MshColors.success, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Deine Privatsphäre',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _PrivacyPoint(
              icon: Icons.cookie_outlined,
              iconColor: MshColors.success,
              title: 'Keine Tracking-Cookies',
              desc: 'Wir setzen keine Cookies, die dein Verhalten verfolgen.',
            ),
            const _PrivacyPoint(
              icon: Icons.analytics_outlined,
              iconColor: MshColors.success,
              title: 'Keine Analyse-Dienste',
              desc:
                  'Kein Google Analytics, kein Facebook Pixel, keine Tracker.',
            ),
            const _PrivacyPoint(
              icon: Icons.visibility_off_outlined,
              iconColor: MshColors.success,
              title: 'Anonyme Statistiken',
              desc:
                  'Wir zählen nur, wie oft Orte angesehen werden – ohne dich zu identifizieren.',
            ),
            const _PrivacyPoint(
              icon: Icons.storage_outlined,
              iconColor: MshColors.info,
              title: 'Minimale lokale Speicherung',
              desc: 'Nur ob du das Intro gesehen hast, wird lokal gespeichert.',
            ),
            const _PrivacyPoint(
              icon: Icons.map_outlined,
              iconColor: MshColors.info,
              title: 'OpenStreetMap',
              desc:
                  'Für die Kartenanzeige nutzen wir OpenStreetMap. Details: openstreetmap.org/copyright',
            ),
            const _PrivacyPoint(
              icon: Icons.location_on_outlined,
              iconColor: MshColors.info,
              title: 'Standort',
              desc:
                  'Dein Standort wird nur lokal zur Kartenzentrierung genutzt und nicht übertragen.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/about');
                },
                child: const Text('Mehr über MSH Map'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {

  const _PrivacyPoint({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600),),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: MshColors.textSecondary,
                    fontSize: 13,
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
