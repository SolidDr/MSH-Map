import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/accessibility_provider.dart';
import '../../../core/providers/theme_provider.dart';

/// Accessibility Settings Screen
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barrierefreiheit'),
        actions: [
          // Reset Button
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Zurücksetzen?'),
                  content: const Text(
                    'Möchtest du alle Einstellungen auf Standard zurücksetzen?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Abbrechen'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Zurücksetzen'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(accessibilityProvider.notifier).resetToDefaults();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Einstellungen zurückgesetzt'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Zurücksetzen',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          _SectionHeader(
            icon: Icons.palette,
            title: 'Design',
            subtitle: 'Aussehen der App anpassen',
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                // Light/Dark Mode
                _ThemeOption(
                  title: 'Hell',
                  icon: Icons.light_mode,
                  isSelected: themeMode == AppThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setAppThemeMode(AppThemeMode.light),
                ),
                const Divider(height: 1),
                _ThemeOption(
                  title: 'Dunkel',
                  icon: Icons.dark_mode,
                  isSelected: themeMode == AppThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setAppThemeMode(AppThemeMode.dark),
                ),
                const Divider(height: 1),
                _ThemeOption(
                  title: 'System',
                  icon: Icons.auto_awesome,
                  isSelected: themeMode == AppThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setAppThemeMode(AppThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // High Contrast
          SwitchListTile(
            value: settings.highContrast,
            onChanged: (value) =>
                ref.read(accessibilityProvider.notifier).setHighContrast(value),
            title: const Text('Hoher Kontrast'),
            subtitle: const Text('Erhöht Lesbarkeit durch starke Kontraste'),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.contrast),
            ),
          ),
          const SizedBox(height: 24),

          // Text Section
          _SectionHeader(
            icon: Icons.text_fields,
            title: 'Text',
            subtitle: 'Textgröße und Schriftart',
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Textgröße',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${(settings.textScale * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: settings.textScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 14,
                    label: '${(settings.textScale * 100).round()}%',
                    onChanged: (value) => ref
                        .read(accessibilityProvider.notifier)
                        .setTextScale(value),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vorschau: Das ist ein Beispieltext',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: settings.getScaledFontSize(16),
                          fontWeight: settings.getTextWeight(FontWeight.normal),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            value: settings.boldText,
            onChanged: (value) =>
                ref.read(accessibilityProvider.notifier).setBoldText(value),
            title: const Text('Fette Schrift'),
            subtitle: const Text('Text wird fetter dargestellt'),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.format_bold),
            ),
          ),
          const SizedBox(height: 24),

          // Interaction Section
          _SectionHeader(
            icon: Icons.touch_app,
            title: 'Interaktion',
            subtitle: 'Buttons und Animationen',
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            value: settings.largeButtons,
            onChanged: (value) =>
                ref.read(accessibilityProvider.notifier).setLargeButtons(value),
            title: const Text('Größere Buttons'),
            subtitle: const Text('Buttons werden um 30% größer'),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_button),
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            value: settings.reduceAnimations,
            onChanged: (value) => ref
                .read(accessibilityProvider.notifier)
                .setReduceAnimations(value),
            title: const Text('Animationen reduzieren'),
            subtitle: const Text('Weniger Bewegungen für bessere Fokussierung'),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.animation),
            ),
          ),
          const SizedBox(height: 24),

          // Info
          Card(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Diese Einstellungen gelten app-weit und werden gespeichert.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Header Widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Theme Option Widget
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : null,
      onTap: onTap,
    );
  }
}
