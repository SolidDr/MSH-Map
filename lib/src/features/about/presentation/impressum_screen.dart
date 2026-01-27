/// MSH Map - Impressum
///
/// Rechtliche Angaben gemäß § 5 TMG
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressum'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(MshSpacing.lg),
        children: [
          // Angaben gemäß § 5 TMG
          _buildSection(
            context,
            title: 'Angaben gemäß § 5 TMG',
            content: '''KOLAN Systems
Inh. Konstantin Lange
Hallesche Str. 35
06536 Südharz OT Roßla''',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Kontakt
          _buildSection(
            context,
            title: 'Kontakt',
            child: InkWell(
              onTap: () => _launchEmail('lange@kolan-systems.de'),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: MshColors.primary,
                  ),
                  const SizedBox(width: MshSpacing.sm),
                  Text(
                    'lange@kolan-systems.de',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MshColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: MshSpacing.xl),

          // Umsatzsteuer-ID
          _buildSection(
            context,
            title: 'Umsatzsteuer-ID',
            content:
                'Umsatzsteuer-Identifikationsnummer gemäß § 27 a Umsatzsteuergesetz:\nIn Bearbeitung',
          ),

          const SizedBox(height: MshSpacing.xl),

          // Verantwortlich für den Inhalt
          _buildSection(
            context,
            title: 'Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV',
            content: '''Konstantin Lange
Hallesche Str. 35
06536 Südharz OT Roßla''',
          ),

          const SizedBox(height: MshSpacing.xxl),

          // Haftungsausschluss Header
          Container(
            padding: const EdgeInsets.all(MshSpacing.md),
            decoration: BoxDecoration(
              color: MshColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.gavel,
                  color: MshColors.textSecondary,
                ),
                const SizedBox(width: MshSpacing.md),
                Text(
                  'Haftungsausschluss',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: MshColors.textStrong,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: MshSpacing.lg),

          // Haftung für Inhalte
          _buildLegalSection(
            context,
            title: 'Haftung für Inhalte',
            content:
                'Die Inhalte unserer Seiten wurden mit größter Sorgfalt erstellt. '
                'Für die Richtigkeit, Vollständigkeit und Aktualität der Inhalte '
                'können wir jedoch keine Gewähr übernehmen. Als Diensteanbieter '
                'sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte auf diesen Seiten '
                'nach den allgemeinen Gesetzen verantwortlich.',
          ),

          const SizedBox(height: MshSpacing.lg),

          // Haftung für Links
          _buildLegalSection(
            context,
            title: 'Haftung für Links',
            content:
                'Unser Angebot enthält Links zu externen Webseiten Dritter, auf deren '
                'Inhalte wir keinen Einfluss haben. Deshalb können wir für diese fremden '
                'Inhalte auch keine Gewähr übernehmen. Für die Inhalte der verlinkten '
                'Seiten ist stets der jeweilige Anbieter oder Betreiber der Seiten '
                'verantwortlich.',
          ),

          const SizedBox(height: MshSpacing.lg),

          // Urheberrecht
          _buildLegalSection(
            context,
            title: 'Urheberrecht',
            content:
                'Die durch die Seitenbetreiber erstellten Inhalte und Werke auf diesen '
                'Seiten unterliegen dem deutschen Urheberrecht. Die Vervielfältigung, '
                'Bearbeitung, Verbreitung und jede Art der Verwertung außerhalb der '
                'Grenzen des Urheberrechtes bedürfen der schriftlichen Zustimmung des '
                'jeweiligen Autors bzw. Erstellers.',
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
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: MshColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshSpacing.sm),
        if (content != null)
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MshColors.textPrimary,
                  height: 1.5,
                ),
          ),
        if (child != null) child,
      ],
    );
  }

  Widget _buildLegalSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: MshColors.textStrong,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: MshSpacing.xs),
        Text(
          content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: MshColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
