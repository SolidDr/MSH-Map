import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../../shared/widgets/powered_by_badge.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header mit Bild
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(AppStrings.navAbout),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MshColors.primary,
                      MshColors.primaryStrong,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(MshSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro
                  _buildSection(
                    context,
                    title: AppStrings.aboutTitle,
                    content: AppStrings.aboutIntro,
                  ),

                  const SizedBox(height: MshSpacing.lg),

                  // Motivation Cards
                  _buildMotivationCard(
                    context,
                    icon: Icons.family_restroom,
                    title: AppStrings.aboutFatherTitle,
                    content: AppStrings.aboutFatherText,
                    color: MshColors.categoryFamily,
                  ),

                  const SizedBox(height: MshSpacing.md),

                  _buildMotivationCard(
                    context,
                    icon: Icons.search,
                    title: AppStrings.aboutEfficiencyTitle,
                    content: AppStrings.aboutEfficiencyText,
                    color: MshColors.info,
                  ),

                  const SizedBox(height: MshSpacing.md),

                  _buildMotivationCard(
                    context,
                    icon: Icons.handshake,
                    title: AppStrings.aboutRegionTitle,
                    content: AppStrings.aboutRegionText,
                    color: MshColors.success,
                  ),

                  const SizedBox(height: MshSpacing.lg),

                  // Closing Statement
                  Container(
                    padding: const EdgeInsets.all(MshSpacing.md),
                    decoration: BoxDecoration(
                      color: MshColors.primarySubtle,
                      borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: MshColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: MshSpacing.sm),
                        Text(
                          AppStrings.aboutClosing,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: MshColors.primaryStrong,
                              ),
                        ),
                        const SizedBox(height: MshSpacing.sm),
                        Text(
                          AppStrings.aboutPersonal,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: MshColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: MshSpacing.xl),

                  // Powered by
                  const Center(child: PoweredByBadge()),

                  const SizedBox(height: MshSpacing.md),

                  // GitHub Link
                  const Center(child: _GitHubButton()),

                  const SizedBox(height: MshSpacing.lg),

                  // Version Info
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MshColors.textSecondary,
                          ),
                    ),
                  ),

                  const SizedBox(height: MshSpacing.lg),

                  // Impressum Link (dezent)
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/impressum'),
                      child: Text(
                        'Impressum',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MshColors.textMuted,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: MshSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: MshSpacing.sm),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: MshColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MshSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: MshSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: MshSpacing.md),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GitHubButton extends StatelessWidget {
  const _GitHubButton();

  Future<void> _launchGitHub() async {
    final uri = Uri.parse('https://github.com/SolidDr/MSH-Map');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launchGitHub,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.code,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            const Text(
              'Source Code auf GitHub',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              size: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
