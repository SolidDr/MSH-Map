/// MSH Map - Nutzungsbedingungen
///
/// Allgemeine Nutzungsbedingungen für MSH Map
library;

import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';

class NutzungsbedingungenScreen extends StatelessWidget {
  const NutzungsbedingungenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutzungsbedingungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(MshSpacing.lg),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(MshSpacing.md),
            decoration: BoxDecoration(
              color: MshColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
              border: Border.all(
                color: MshColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: MshColors.info,
                ),
                const SizedBox(width: MshSpacing.md),
                Expanded(
                  child: Text(
                    'Mit der Nutzung von MSH Map akzeptierst du diese Bedingungen.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MshColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: MshSpacing.xl),

          // Geltungsbereich
          _buildSection(
            context,
            title: '1. Geltungsbereich',
            content:
                'Diese Nutzungsbedingungen gelten für die Nutzung der Webanwendung '
                'MSH Map (msh-map.de), betrieben von KOLAN Systems.',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Leistungsbeschreibung
          _buildSection(
            context,
            title: '2. Leistungsbeschreibung',
            content:
                'MSH Map ist eine kostenlose Informationsplattform für den Landkreis '
                'Mansfeld-Südharz. Die App bietet:',
            children: [
              _buildBulletPoint(context, 'Interaktive Karte mit Points of Interest'),
              _buildBulletPoint(context, 'Informationen zu Ausflugszielen und Freizeitangeboten'),
              _buildBulletPoint(context, 'Veranstaltungshinweise'),
              _buildBulletPoint(context, 'Mobilitätsinformationen'),
            ],
          ),

          const SizedBox(height: MshSpacing.xl),

          // Keine Gewähr
          _buildSection(
            context,
            title: '3. Keine Gewähr',
            content:
                'Die Informationen auf MSH Map werden nach bestem Wissen zusammengestellt. '
                'Wir übernehmen jedoch keine Gewähr für:',
            children: [
              _buildBulletPoint(context, 'Richtigkeit der Angaben (Öffnungszeiten, Preise, etc.)'),
              _buildBulletPoint(context, 'Vollständigkeit der Informationen'),
              _buildBulletPoint(context, 'Aktualität der Daten'),
              _buildBulletPoint(context, 'Verfügbarkeit des Dienstes'),
            ],
          ),

          const SizedBox(height: MshSpacing.lg),

          Container(
            padding: const EdgeInsets.all(MshSpacing.md),
            decoration: BoxDecoration(
              color: MshColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: MshColors.warning,
                  size: 20,
                ),
                const SizedBox(width: MshSpacing.sm),
                Expanded(
                  child: Text(
                    'Bitte informiere dich vor einem Besuch immer direkt beim Anbieter '
                    'über aktuelle Öffnungszeiten und Preise.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MshColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: MshSpacing.xl),

          // Nutzungsrechte
          _buildSection(
            context,
            title: '4. Nutzungsrechte',
            content:
                'MSH Map darf kostenlos und ohne Registrierung genutzt werden. '
                'Die Nutzung erfolgt auf eigene Verantwortung.',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Externe Links
          _buildSection(
            context,
            title: '5. Externe Links',
            content:
                'MSH Map enthält Links zu externen Websites. Für deren Inhalte sind '
                'ausschließlich die jeweiligen Betreiber verantwortlich.',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Änderungen
          _buildSection(
            context,
            title: '6. Änderungen',
            content:
                'Wir behalten uns vor, diese Nutzungsbedingungen jederzeit zu ändern. '
                'Die weitere Nutzung nach Änderungen gilt als Zustimmung.',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Anwendbares Recht
          _buildSection(
            context,
            title: '7. Anwendbares Recht',
            content: 'Es gilt deutsches Recht.',
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

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: MshSpacing.xs),
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
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MshColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
