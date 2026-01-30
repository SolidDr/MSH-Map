/// MSH Map - Profil Screen
///
/// Benutzerprofil & Einstellungen:
/// - Account-Verwaltung
/// - App-Einstellungen
/// - Über die App
/// - Datenschutz
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/msh_colors.dart';
import '../../../core/theme/msh_spacing.dart';
import '../../../core/theme/msh_theme.dart';
import '../../../shared/widgets/powered_by_badge.dart';

/// Profil Screen - Einstellungen & Account
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Zähler für Version-Taps (8 Taps für Admin-Zugang)
  int _versionTapCount = 0;
  DateTime? _lastTapTime;

  /// Zeigt "Coming Soon" Snackbar
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Demnächst verfügbar'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Öffnet externe URL
  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link konnte nicht geöffnet werden')),
        );
      }
    }
  }

  /// Bestätigungsdialog für Daten löschen
  void _confirmDeleteData(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daten löschen?'),
        content: const Text(
          'Möchtest du wirklich alle lokalen Daten löschen? '
          'Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lokale Daten wurden gelöscht'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: MshColors.error),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          const SliverAppBar(
            floating: true,
            title: Text('Profil'),
          ),

          // Account Section
          SliverToBoxAdapter(
            child: _buildAccountSection(context),
          ),

          // Settings Groups
          SliverToBoxAdapter(
            child: _buildSettingsGroup(
              context,
              title: 'App-Einstellungen',
              items: [
                _SettingsItem(
                  icon: Icons.accessibility_new,
                  label: 'Barrierefreiheit',
                  onTap: () => context.push('/accessibility'),
                ),
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  label: 'Benachrichtigungen',
                  onTap: () => _showComingSoon(context, 'Benachrichtigungen'),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSettingsGroup(
              context,
              title: 'Daten & Datenschutz',
              items: [
                _SettingsItem(
                  icon: Icons.location_on_outlined,
                  label: 'Standort-Einstellungen',
                  onTap: () => _showComingSoon(context, 'Standort-Einstellungen'),
                ),
                _SettingsItem(
                  icon: Icons.history,
                  label: 'Suchverlauf',
                  onTap: () => _showComingSoon(context, 'Suchverlauf verwalten'),
                ),
                _SettingsItem(
                  icon: Icons.delete_outline,
                  label: 'Daten löschen',
                  onTap: () => _confirmDeleteData(context),
                  isDestructive: true,
                  tooltip: 'Diese Daten sind nur lokal auf deinem Gerät '
                      'gespeichert und werden nicht an externe Server übertragen.',
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: _buildSettingsGroup(
              context,
              title: 'Über',
              items: [
                _SettingsItem(
                  icon: Icons.info_outline,
                  label: 'Über MSH Map',
                  onTap: () => context.push('/about'),
                ),
                _SettingsItem(
                  icon: Icons.description_outlined,
                  label: 'Nutzungsbedingungen',
                  onTap: () => context.push('/nutzungsbedingungen'),
                ),
                _SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Datenschutzerklärung',
                  onTap: () => context.push('/datenschutz'),
                ),
                _SettingsItem(
                  icon: Icons.feedback_outlined,
                  label: 'Feedback geben',
                  onTap: () => _openUrl(
                    context,
                    'mailto:feedback@msh-map.de?subject=MSH%20Map%20Feedback',
                  ),
                ),
              ],
            ),
          ),

          // Version Info
          SliverToBoxAdapter(
            child: _buildVersionInfo(context),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: MshSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    // TODO: Echten Auth-Status prüfen
    const isLoggedIn = false;

    return Padding(
      padding: const EdgeInsets.all(MshSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(MshSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MshColors.primary.withValues(alpha: 0.15),
              MshColors.primaryLight.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
          border: Border.all(
            color: MshColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: isLoggedIn
            ? _buildLoggedInAccount(context)
            : _buildGuestAccount(context),
      ),
    );
  }

  Widget _buildGuestAccount(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: MshSpacing.xxl, // 55px
          height: MshSpacing.xxl, // 55px
          decoration: BoxDecoration(
            color: MshColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline,
            color: MshColors.primary,
            size: 28,
          ),
        ),

        const SizedBox(width: MshSpacing.md),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gast',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: MshColors.textStrong,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Login-Funktion kommt bald',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),

        // Coming Soon Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MshSpacing.sm,
            vertical: MshSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: MshColors.textMuted.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(MshTheme.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule,
                size: 14,
                color: MshColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Bald',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MshColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInAccount(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: MshSpacing.xxl,
          height: MshSpacing.xxl,
          decoration: const BoxDecoration(
            color: MshColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'ML',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),

        const SizedBox(width: MshSpacing.md),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Max Muster',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: MshColors.textStrong,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'max.muster@example.de',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),

        // Edit Button
        IconButton(
          onPressed: () => _showComingSoon(context, 'Profil bearbeiten'),
          icon: const Icon(Icons.edit_outlined),
          color: MshColors.primary,
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MshSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: MshSpacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: MshColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: MshSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: MshColors.surface,
              borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
              border: Border.all(
                color: MshColors.textMuted.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i < items.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MshSpacing.lg),
      child: Center(
        child: Column(
          children: [
            // Powered by KOLAN Tensor Badge
            const Padding(
              padding: EdgeInsets.only(bottom: MshSpacing.md),
              child: PoweredByBadge(),
            ),
            Text(
              'MSH Map',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MshColors.textMuted,
                  ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => _onVersionTap(context),
              child: Text(
                'Version 2.5.2',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MshColors.textMuted,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Verarbeitet Taps auf die Versionsnummer
  void _onVersionTap(BuildContext context) {
    final now = DateTime.now();

    // Reset wenn mehr als 3 Sekunden seit letztem Tap
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inSeconds > 3) {
      _versionTapCount = 0;
    }

    _lastTapTime = now;
    _versionTapCount++;

    // Bei 8 Taps: Passwort-Dialog anzeigen
    if (_versionTapCount >= 8) {
      _versionTapCount = 0;
      _showAdminPasswordDialog(context);
    }
  }

  /// Zeigt den Passwort-Dialog für Admin-Zugang
  void _showAdminPasswordDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: MshColors.primary),
            SizedBox(width: MshSpacing.sm),
            Text('Admin-Zugang'),
          ],
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Passwort',
            hintText: 'Admin-Passwort eingeben',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          onSubmitted: (value) {
            Navigator.pop(dialogContext);
            _validateAdminPassword(context, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _validateAdminPassword(context, controller.text);
            },
            child: const Text('Anmelden'),
          ),
        ],
      ),
    );
  }

  /// Prüft das Admin-Passwort und navigiert zum Dashboard
  void _validateAdminPassword(BuildContext context, String password) {
    // Passwort: KredaMSH2023#+
    if (password == 'KredaMSH2023#+') {
      context.push('/admin?key=$password');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falsches Passwort'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: MshColors.error,
        ),
      );
    }
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final bool isDestructive;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? MshColors.error : MshColors.textPrimary;

    final content = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MshSpacing.md,
          vertical: MshSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive ? MshColors.error : MshColors.textSecondary,
            ),
            const SizedBox(width: MshSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                    ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MshColors.textMuted,
                    ),
              ),
            const SizedBox(width: MshSpacing.xs),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: MshColors.textMuted,
            ),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        preferBelow: false,
        child: content,
      );
    }

    return content;
  }
}
