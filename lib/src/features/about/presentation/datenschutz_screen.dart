/// MSH Map - Datenschutzerklärung
///
/// Datenschutzhinweise gemäß DSGVO
library;

import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';

class DatenschutzScreen extends StatelessWidget {
  const DatenschutzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutz'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(MshSpacing.lg),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(MshSpacing.md),
            decoration: BoxDecoration(
              color: MshColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
              border: Border.all(
                color: MshColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user,
                  color: MshColors.success,
                ),
                const SizedBox(width: MshSpacing.md),
                Expanded(
                  child: Text(
                    'MSH Map wurde mit Fokus auf Datenschutz entwickelt.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MshColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: MshSpacing.xl),

          // Verantwortlicher
          _buildSection(
            context,
            title: '1. Verantwortlicher',
            content: '''
KOLAN Systems
Inh. Konstantin Lange
Hallesche Str. 35
06536 Südharz OT Roßla
E-Mail: lange@kolan-systems.de''',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Datenerhebung
          _buildSection(
            context,
            title: '2. Welche Daten wir erheben',
            content:
                'MSH Map erhebt so wenig Daten wie möglich. Konkret speichern wir:',
            children: [
              _buildBulletPoint(
                context,
                'Lokale Einstellungen',
                'Ob du das Intro gesehen hast, wird lokal in deinem Browser gespeichert (LocalStorage).',
              ),
              _buildBulletPoint(
                context,
                'Anonyme Statistiken',
                'Wir zählen, wie oft bestimmte Orte angesehen werden. Diese Zählung erfolgt anonym ohne Bezug zu deiner Person.',
              ),
            ],
          ),

          const SizedBox(height: MshSpacing.xl),

          // Was wir NICHT erheben
          _buildSection(
            context,
            title: '3. Was wir NICHT erheben',
            children: [
              _buildCheckItem(context, 'Keine Cookies zu Tracking-Zwecken'),
              _buildCheckItem(context, 'Kein Google Analytics'),
              _buildCheckItem(context, 'Kein Facebook Pixel'),
              _buildCheckItem(context, 'Keine Weitergabe an Dritte'),
              _buildCheckItem(context, 'Keine Profilbildung'),
            ],
          ),

          const SizedBox(height: MshSpacing.xl),

          // Standortdaten
          _buildSection(
            context,
            title: '4. Standortdaten',
            content:
                'Wenn du der App Zugriff auf deinen Standort gewährst, wird dieser ausschließlich '
                'lokal verwendet, um die Karte auf deinen Standort zu zentrieren. '
                'Dein Standort wird nicht an unsere Server übertragen.',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Externe Dienste
          _buildSection(
            context,
            title: '5. Externe Dienste',
            children: [
              _buildBulletPoint(
                context,
                'OpenStreetMap',
                'Für die Kartendarstellung nutzen wir OpenStreetMap-Tiles. '
                    'Dabei wird deine IP-Adresse an die OSM-Server übertragen. '
                    'Datenschutzhinweise: openstreetmap.org/copyright',
              ),
              _buildBulletPoint(
                context,
                'Firebase (Google)',
                'Die POI-Daten werden in Firebase/Firestore gespeichert. '
                    'Bei der Nutzung wird deine IP-Adresse an Google übertragen. '
                    'Datenschutzhinweise: firebase.google.com/support/privacy',
              ),
            ],
          ),

          const SizedBox(height: MshSpacing.xl),

          // Deine Rechte
          _buildSection(
            context,
            title: '6. Deine Rechte',
            content:
                'Da wir keine personenbezogenen Daten speichern, gibt es in der Regel keine Daten, '
                'auf die du Auskunft verlangen könntest. Falls du Fragen hast, kontaktiere uns gerne.',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Änderungen
          _buildSection(
            context,
            title: '7. Änderungen',
            content:
                'Wir behalten uns vor, diese Datenschutzerklärung anzupassen, um sie an geänderte '
                'Rechtslagen oder Änderungen der App anzupassen.',
          ),

          const SizedBox(height: MshSpacing.lg),

          // Stand
          Text(
            'Stand: Januar 2026',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MshColors.textMuted,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: MshSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    String? content,
    List<Widget>? children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: MshColors.textStrong,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshSpacing.sm),
        if (content != null)
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MshColors.textPrimary,
                  height: 1.6,
                ),
          ),
        if (children != null) ...children,
      ],
    );
  }

  Widget _buildBulletPoint(BuildContext context, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(top: MshSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: MshColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: MshSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: MshColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MshColors.textSecondary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: MshSpacing.xs),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: MshColors.success,
            size: 20,
          ),
          const SizedBox(width: MshSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MshColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
