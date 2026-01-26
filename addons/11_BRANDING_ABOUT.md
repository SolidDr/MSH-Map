# 11 - Branding & About Section

## "Powered by KOLAN Systems" Badge

### Widget Code

```dart
// lib/src/shared/widgets/powered_by_badge.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/msh_colors.dart';

/// "Powered by KOLAN Systems" Badge
/// Klickbar, verlinkt auf kolan-systems.de
class PoweredByBadge extends StatelessWidget {
  final bool compact;
  final Color? textColor;
  
  const PoweredByBadge({
    super.key,
    this.compact = false,
    this.textColor,
  });
  
  static const String _url = 'https://kolan-systems.de';
  
  Future<void> _launchUrl() async {
    final uri = Uri.parse(_url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final color = textColor ?? MshColors.textSecondary;
    
    if (compact) {
      return _buildCompact(color);
    }
    return _buildFull(color);
  }
  
  Widget _buildCompact(Color color) {
    return InkWell(
      onTap: _launchUrl,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, size: 14, color: MshColors.primary),
            const SizedBox(width: 4),
            Text(
              'KOLAN Systems',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFull(Color color) {
    return InkWell(
      onTap: _launchUrl,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: MshColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MshColors.surfaceVariant),
          boxShadow: [
            BoxShadow(
              color: MshColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MshColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.bolt,
                size: 18,
                color: MshColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Powered by',
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'KOLAN Systems',
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Inh. Konstantin Lange',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              size: 14,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Verwendung in der App

**Im Menü/Drawer:**
```dart
Drawer(
  child: Column(
    children: [
      // ... Menü-Items ...
      const Spacer(),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(16),
        child: PoweredByBadge(),
      ),
    ],
  ),
)
```

**In der Map (unten rechts):**
```dart
Stack(
  children: [
    MshMapView(...),
    Positioned(
      bottom: 16,
      right: 16,
      child: PoweredByBadge(compact: true),
    ),
  ],
)
```

---

## "Über MSH Map" - About Screen

```dart
// lib/src/features/about/presentation/about_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/msh_colors.dart';
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
              title: const Text('Über MSH Map'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MshColors.primary,
                      MshColors.primaryDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(MshTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro
                  _buildSection(
                    context,
                    title: 'Warum MSH Map?',
                    content: 'Diese Plattform ist nicht entstanden, um mich '
                        'selbst darzustellen, sondern aus einem ganz konkreten '
                        'Bedarf heraus, den ich hier in der Region täglich erlebe.',
                  ),
                  
                  const SizedBox(height: MshTheme.spacingLg),
                  
                  // Motivation Cards
                  _buildMotivationCard(
                    context,
                    icon: Icons.family_restroom,
                    title: 'Der Blick als Familienvater',
                    content: 'Als Vater kenne ich die Herausforderung nur zu gut: '
                        'Man möchte am Wochenende etwas mit den Kindern unternehmen, '
                        'findet aber kaum gebündelte Informationen. Oft sind Angebote '
                        'versteckt, Webseiten veraltet oder man ist auf Mundpropaganda '
                        'angewiesen. Die MSH Map soll diese Lücke schließen und '
                        'Familien das Leben erleichtern.',
                    color: MshColors.categoryFamily,
                  ),
                  
                  const SizedBox(height: MshTheme.spacingMd),
                  
                  _buildMotivationCard(
                    context,
                    icon: Icons.search,
                    title: 'Effizienz statt Suchen',
                    content: 'Herkömmliche Suchmaschinen und lokale Zeitungen '
                        'liefern oft nur fragmentierte Ergebnisse. Mein Ziel war '
                        'es, einen zentralen Ort zu schaffen – eine „Single Source '
                        'of Truth" – an dem man nicht lange suchen muss, sondern '
                        'sofort findet, was die Region zu bieten hat.',
                    color: MshColors.info,
                  ),
                  
                  const SizedBox(height: MshTheme.spacingMd),
                  
                  _buildMotivationCard(
                    context,
                    icon: Icons.handshake,
                    title: 'Stärkung der Region',
                    content: 'Ich bin überzeugt, dass unsere Region viel mehr zu '
                        'bieten hat, als oft sichtbar ist. Ich wünsche mir, dass '
                        'wir uns besser vernetzen, lokale Stärken sichtbar machen '
                        'und Mansfeld-Südharz durch digitale Zusammenarbeit wieder '
                        'an Strahlkraft gewinnt.',
                    color: MshColors.success,
                  ),
                  
                  const SizedBox(height: MshTheme.spacingLg),
                  
                  // Closing Statement
                  Container(
                    padding: const EdgeInsets.all(MshTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: MshColors.primarySurface,
                      borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: MshColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: MshTheme.spacingSm),
                        Text(
                          'Es geht darum, das Potenzial unserer Heimat voll '
                          'auszuschöpfen und durch smarte Vernetzung das Leben '
                          'und Arbeiten hier attraktiver zu gestalten.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: MshColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: MshTheme.spacingSm),
                        Text(
                          '– Auch wenn ich hier nicht aufgewachsen bin, '
                          'ist es doch meine Heimat.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: MshColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: MshTheme.spacingXl),
                  
                  // Powered by
                  const Center(child: PoweredByBadge()),
                  
                  const SizedBox(height: MshTheme.spacingLg),
                  
                  // Version Info
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MshColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: MshTheme.spacingMd),
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
        const SizedBox(height: MshTheme.spacingSm),
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
        padding: const EdgeInsets.all(MshTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(MshTheme.radiusMedium),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: MshTheme.spacingMd),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: MshTheme.spacingMd),
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
```

---

## Menü mit About-Link

```dart
// lib/src/shared/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_theme.dart';
import 'powered_by_badge.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MshColors.primary,
                  MshColors.primaryDark,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: MshTheme.spacingSm),
                Text(
                  'MSH Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Mansfeld-Südharz entdecken',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _MenuItem(
                  icon: Icons.explore,
                  title: 'Entdecken',
                  onTap: () => context.go('/'),
                ),
                _MenuItem(
                  icon: Icons.family_restroom,
                  title: 'Familienaktivitäten',
                  onTap: () => context.go('/family'),
                ),
                _MenuItem(
                  icon: Icons.restaurant,
                  title: 'Gastronomie',
                  onTap: () => context.go('/gastro'),
                ),
                _MenuItem(
                  icon: Icons.event,
                  title: 'Events',
                  onTap: () => context.go('/events'),
                  badge: 'Bald',
                ),
                
                const Divider(),
                
                _MenuItem(
                  icon: Icons.add_location_alt,
                  title: 'Ort vorschlagen',
                  onTap: () => context.go('/suggest'),
                ),
                _MenuItem(
                  icon: Icons.feedback,
                  title: 'Feedback',
                  onTap: () => context.go('/feedback'),
                ),
                
                const Divider(),
                
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'Über MSH Map',
                  onTap: () => context.go('/about'),
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Datenschutz',
                  onTap: () => context.go('/privacy'),
                ),
              ],
            ),
          ),
          
          // Footer
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(MshTheme.spacingMd),
            child: const PoweredByBadge(),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? badge;
  
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: MshColors.textSecondary),
      title: Text(title),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MshColors.primarySurface,
                borderRadius: BorderRadius.circular(MshTheme.radiusRound),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 11,
                  color: MshColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
```

---

## Dependencies hinzufügen

```yaml
# In pubspec.yaml:
dependencies:
  url_launcher: ^6.2.0  # Für externe Links
```

---

## Route hinzufügen

```dart
// In app_router.dart:
GoRoute(
  path: '/about',
  builder: (context, state) => const AboutScreen(),
),
```
