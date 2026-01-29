import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/powered_by_badge.dart';
import '../../shared/widgets/privacy_badge.dart';
import '../theme/msh_colors.dart';

class AppShell extends StatefulWidget {

  const AppShell({required this.child, super.key});
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Behandelt ESC-Tastendruck für Zurück-Navigation
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _handleEscapeKey();
    }
  }

  /// ESC-Handler mit Prioritäten
  void _handleEscapeKey() {
    final router = GoRouter.of(context);

    // Priorität 1: Zurück navigieren wenn möglich
    if (router.canPop()) {
      router.pop();
      return;
    }

    // Priorität 2: Zur Startseite wenn nicht schon dort
    final location = GoRouterState.of(context).uri.path;
    if (location != '/') {
      router.go('/');
      setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget shell;

    // Mobile: Bottom Navigation
    if (width < 600) {
      shell = _MobileShell(
        selectedIndex: _selectedIndex,
        onIndexChanged: (i) => setState(() => _selectedIndex = i),
        child: widget.child,
      );
    }
    // Tablet: Navigation Rail
    else if (width < 1200) {
      shell = _TabletShell(
        selectedIndex: _selectedIndex,
        onIndexChanged: (i) => setState(() => _selectedIndex = i),
        child: widget.child,
      );
    }
    // Desktop: Sidebar
    else {
      shell = _DesktopShell(
        selectedIndex: _selectedIndex,
        onIndexChanged: (i) => setState(() => _selectedIndex = i),
        child: widget.child,
      );
    }

    // ESC-Taste für Zurück-Navigation (global)
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: shell,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MOBILE SHELL - Hamburger-Menü statt überfüllter Bottom-Bar
// ═══════════════════════════════════════════════════════════════

class _MobileShell extends StatefulWidget {
  const _MobileShell({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget child;

  @override
  State<_MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<_MobileShell>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
        _animationController.reverse();
      });
    }
  }

  void _onItemTap(int index) {
    widget.onIndexChanged(index);
    _navigateToIndex(context, index);
    _closeMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          GestureDetector(
            onTap: _closeMenu,
            child: widget.child,
          ),

          // Top Bar mit Hamburger-Menü
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header mit Menü-Button
                  Container(
                    height: 56,
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: MshColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Menü-Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _toggleMenu,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  _isMenuOpen ? Icons.close : Icons.menu,
                                  key: ValueKey(_isMenuOpen),
                                  color: MshColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // App Title / Current Page
                        Expanded(
                          child: Text(
                            _getPageTitle(widget.selectedIndex),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: MshColors.textPrimary,
                            ),
                          ),
                        ),

                        // Logo
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: MshColors.primarySubtle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.map,
                            color: MshColors.primary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 4),
                      ],
                    ),
                  ),

                  // Dropdown-Menü (animiert)
                  SizeTransition(
                    sizeFactor: _animation,
                    axisAlignment: -1,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      decoration: BoxDecoration(
                        color: MshColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildMenuGrid(),
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

  Widget _buildMenuGrid() {
    const items = [
      (Icons.map, 'Karte', 0),
      (Icons.explore, 'Entdecken', 1),
      (Icons.celebration, 'Events', 2),
      (Icons.directions_bus, 'ÖPNV', 3),
      (Icons.local_hospital, 'Gesundheit', 4),
      (Icons.volunteer_activism, 'Soziales', 5),
      (Icons.nightlife, 'Ausgehen', 6),
      (Icons.directions_bike, 'Radwege', 7),
      (Icons.person, 'Profil', 8),
    ];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          final isSelected = widget.selectedIndex == item.$3;
          return _MobileMenuItem(
            icon: item.$1,
            label: item.$2,
            isSelected: isSelected,
            onTap: () => _onItemTap(item.$3),
          );
        }).toList(),
      ),
    );
  }

  String _getPageTitle(int index) {
    const titles = [
      'Karte',
      'Entdecken',
      'Events',
      'Mobilität',
      'Gesundheit',
      'Soziales',
      'Nachtleben',
      'Radwege',
      'Profil',
    ];
    return index < titles.length ? titles[index] : 'MSH Map';
  }
}

class _MobileMenuItem extends StatelessWidget {
  const _MobileMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? MshColors.primarySubtle : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? MshColors.primary : MshColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? MshColors.primary : MshColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TABLET SHELL
// ═══════════════════════════════════════════════════════════════

class _TabletShell extends StatelessWidget {

  const _TabletShell({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget child;

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
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: Text('Entdecken'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.celebration_outlined),
                selectedIcon: Icon(Icons.celebration),
                label: Text('Erleben'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_bus_outlined),
                selectedIcon: Icon(Icons.directions_bus),
                label: Text('Mobilität'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_hospital_outlined),
                selectedIcon: Icon(Icons.local_hospital),
                label: Text('Gesundheit'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.volunteer_activism_outlined),
                selectedIcon: Icon(Icons.volunteer_activism),
                label: Text('Soziales'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.nightlife_outlined),
                selectedIcon: Icon(Icons.nightlife),
                label: Text('Ausgehen'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_bike_outlined),
                selectedIcon: Icon(Icons.directions_bike),
                label: Text('Radwege'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profil'),
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

  const _DesktopShell({
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.child,
  });
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget child;

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
                          color: MshColors.primarySubtle,
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
                        icon: Icons.explore,
                        label: 'Entdecken',
                        isSelected: selectedIndex == 1,
                        onTap: () {
                          onIndexChanged(1);
                          context.go('/discover');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.celebration,
                        label: 'Erleben',
                        isSelected: selectedIndex == 2,
                        onTap: () {
                          onIndexChanged(2);
                          context.go('/events');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.directions_bus,
                        label: 'Mobilität',
                        isSelected: selectedIndex == 3,
                        onTap: () {
                          onIndexChanged(3);
                          context.go('/mobility');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.local_hospital,
                        label: 'Gesundheit',
                        isSelected: selectedIndex == 4,
                        onTap: () {
                          onIndexChanged(4);
                          context.go('/health');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.volunteer_activism,
                        label: 'Soziales',
                        isSelected: selectedIndex == 5,
                        onTap: () {
                          onIndexChanged(5);
                          context.go('/soziales');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.nightlife,
                        label: 'Nachtleben',
                        isSelected: selectedIndex == 6,
                        onTap: () {
                          onIndexChanged(6);
                          context.go('/nightlife');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.directions,
                        label: 'Radeln & Wandern',
                        isSelected: selectedIndex == 7,
                        onTap: () {
                          onIndexChanged(7);
                          context.go('/radwege');
                        },
                      ),
                      _SidebarItem(
                        icon: Icons.person,
                        label: 'Profil',
                        isSelected: selectedIndex == 8,
                        onTap: () {
                          onIndexChanged(8);
                          context.go('/profile');
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

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.badge,
    this.disabled = false,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Material(
        color: isSelected ? MshColors.primarySubtle : Colors.transparent,
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
    case 1:
      context.go('/discover');
    case 2:
      context.go('/events');
    case 3:
      context.go('/mobility');
    case 4:
      context.go('/health');
    case 5:
      context.go('/soziales');
    case 6:
      context.go('/nightlife');
    case 7:
      context.go('/radwege');
    case 8:
      context.go('/profile');
  }
}
