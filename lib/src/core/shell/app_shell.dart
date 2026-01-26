import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/msh_colors.dart';
import '../../shared/widgets/powered_by_badge.dart';
import '../../shared/widgets/privacy_badge.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Mobile: Bottom Navigation
    if (width < 600) {
      return _MobileShell(
        selectedIndex: _selectedIndex,
        onIndexChanged: (i) => setState(() => _selectedIndex = i),
        child: widget.child,
      );
    }

    // Tablet: Navigation Rail
    if (width < 1200) {
      return _TabletShell(
        selectedIndex: _selectedIndex,
        onIndexChanged: (i) => setState(() => _selectedIndex = i),
        child: widget.child,
      );
    }

    // Desktop: Sidebar
    return _DesktopShell(
      selectedIndex: _selectedIndex,
      onIndexChanged: (i) => setState(() => _selectedIndex = i),
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MOBILE SHELL
// ═══════════════════════════════════════════════════════════════

class _MobileShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget child;

  const _MobileShell({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          onIndexChanged(index);
          _navigateToIndex(context, index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Karte',
          ),
          NavigationDestination(
            icon: Icon(Icons.family_restroom_outlined),
            selectedIcon: Icon(Icons.family_restroom),
            label: 'Familie',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Gastro',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Mehr',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TABLET SHELL
// ═══════════════════════════════════════════════════════════════

class _TabletShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget child;

  const _TabletShell({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              onIndexChanged(index);
              _navigateToIndex(context, index);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: MshColors.surface,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: Text('Karte'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.family_restroom_outlined),
                selectedIcon: Icon(Icons.family_restroom),
                label: Text('Familie'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_outlined),
                selectedIcon: Icon(Icons.restaurant),
                label: Text('Gastro'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.more_horiz),
                label: Text('Mehr'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DESKTOP SHELL
// ═══════════════════════════════════════════════════════════════

class _DesktopShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget child;

  const _DesktopShell({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: MshColors.surface,
            child: Column(
              children: [
                // Logo Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MshColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.map, color: MshColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MSH Map',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Mansfeld-Südharz',
                            style: TextStyle(
                              fontSize: 12,
                              color: MshColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    children: [
                      _SidebarItem(
                        icon: Icons.map,
                        label: 'Karte',
                        isSelected: selectedIndex == 0,
                        onTap: () {
                          onIndexChanged(0);
                          context.go('/');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.family_restroom,
                        label: 'Familienaktivitäten',
                        isSelected: selectedIndex == 1,
                        onTap: () {
                          onIndexChanged(1);
                          context.go('/');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.restaurant,
                        label: 'Gastronomie',
                        isSelected: selectedIndex == 2,
                        onTap: () {
                          onIndexChanged(2);
                          context.go('/');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.event,
                        label: 'Events',
                        isSelected: selectedIndex == 3,
                        onTap: () {
                          onIndexChanged(3);
                          context.go('/events');
                        },
                      ),

                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Divider(),
                      ),

                      _SidebarItem(
                        icon: Icons.info_outline,
                        label: 'Über MSH Map',
                        onTap: () => context.go('/about'),
                      ),
                      _SidebarItem(
                        icon: Icons.login,
                        label: 'Anmelden',
                        onTap: () => context.go('/login'),
                      ),
                    ],
                  ),
                ),

                // Footer
                const Divider(height: 1),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PrivacyBadge(),
                      SizedBox(height: 12),
                      PoweredByBadge(compact: true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1),

          // Main Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final bool disabled;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
    this.badge,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Material(
        color: isSelected ? MshColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? MshColors.primary : MshColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? MshColors.primary : MshColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badge == 'Neu'
                          ? MshColors.primary
                          : MshColors.textSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        color: badge == 'Neu'
                            ? Colors.white
                            : MshColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to navigate based on index
void _navigateToIndex(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/');
      break;
    case 1:
      context.go('/');
      break;
    case 2:
      context.go('/');
      break;
    case 3:
      context.go('/about');
      break;
  }
}
