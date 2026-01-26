# 14 - UX Verbesserungen & Bugfixes

## Analyse der aktuellen Version

Basierend auf den Screenshots sehe ich:
- ✅ Karte funktioniert mit verschiedenen Marker-Kategorien
- ✅ Bottom-Sheet für Details mit Tags
- ✅ Suchleiste vorhanden
- ✅ "38 Orte" Anzeige
- ✅ Layer-Switcher (unten rechts)

**Bekannte Bugs:**
- ❌ About/Warum-Sektion nicht sichtbar
- ❌ Mausrad-Zoom funktioniert nicht
- ❌ Trackpad-Pinch funktioniert nicht
- ❌ Filter funktionieren nicht richtig
- ❌ Menü sollte Statusbar sein

---

## TEIL 1: BUGFIXES

### Bug 1: Mausrad & Pinch-Zoom

```dart
// In msh_map_view.dart - MapOptions erweitern:

MapOptions(
  initialCenter: ...,
  initialZoom: ...,
  minZoom: MapConfig.minZoom,
  maxZoom: MapConfig.maxZoom,
  
  // ═══ ZOOM FIXES ═══
  interactionOptions: const InteractionOptions(
    flags: InteractiveFlag.all,  // Aktiviert ALLE Interaktionen
    // Oder explizit:
    // flags: InteractiveFlag.drag | 
    //        InteractiveFlag.pinchZoom | 
    //        InteractiveFlag.scrollWheelZoom |
    //        InteractiveFlag.doubleTapZoom |
    //        InteractiveFlag.pinchMove,
  ),
),
```

**Für Flutter Web spezifisch:**
```html
<!-- In web/index.html - Scroll-Verhalten anpassen: -->
<style>
  html, body {
    overflow: hidden;  /* Verhindert Browser-Scroll */
    touch-action: none; /* Verhindert Browser-Gesten */
  }
</style>
```

**Oder in Dart für Web:**
```dart
// In main.dart für Web:
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  if (kIsWeb) {
    // Verhindert Browser-Zoom-Gesten
    document.body?.style.touchAction = 'none';
  }
  runApp(MyApp());
}
```

---

### Bug 2: Filter funktionieren nicht

```dart
// Problem: Filter-State wird nicht korrekt an die Map übergeben

// providers/filter_provider.dart
final activeFiltersProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

class FilterState {
  final Set<String> categories;
  final bool onlyFree;
  final bool onlyOutdoor;
  final double? maxDistance;
  
  const FilterState({
    this.categories = const {},
    this.onlyFree = false,
    this.onlyOutdoor = false,
    this.maxDistance,
  });
  
  FilterState copyWith({...}) => FilterState(...);
  
  bool matches(MapItem item) {
    // Kategorie-Filter
    if (categories.isNotEmpty && !categories.contains(item.category.name)) {
      return false;
    }
    
    // Kostenlos-Filter
    if (onlyFree && item.metadata['is_free'] != true) {
      return false;
    }
    
    // Outdoor-Filter
    if (onlyOutdoor && item.metadata['is_outdoor'] != true) {
      return false;
    }
    
    return true;
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());
  
  void toggleCategory(String category) {
    final newCategories = Set<String>.from(state.categories);
    if (newCategories.contains(category)) {
      newCategories.remove(category);
    } else {
      newCategories.add(category);
    }
    state = state.copyWith(categories: newCategories);
  }
  
  void clearAll() {
    state = const FilterState();
  }
}

// In der Map-Ansicht:
final filteredItemsProvider = Provider<List<MapItem>>((ref) {
  final allItems = ref.watch(allItemsProvider);
  final filters = ref.watch(activeFiltersProvider);
  
  return allItems.where((item) => filters.matches(item)).toList();
});
```

---

### Bug 3: About-Sektion nicht sichtbar

```dart
// Checkliste:

// 1. Route registriert?
// In app_router.dart:
GoRoute(
  path: '/about',
  builder: (context, state) => const AboutScreen(),
),

// 2. Import vorhanden?
import '../../features/about/presentation/about_screen.dart';

// 3. Navigation korrekt?
// Im Menü/Drawer:
ListTile(
  leading: Icon(Icons.info_outline),
  title: Text('Über MSH Map'),
  onTap: () {
    Navigator.of(context).pop(); // Drawer schließen ZUERST
    Future.delayed(Duration(milliseconds: 100), () {
      context.go('/about');
    });
  },
),

// 4. AboutScreen existiert und hat keine Fehler?
// Prüfe: flutter analyze
```

---

### Bug 4: Menü als Statusbar/Navigation

Siehe TEIL 2, Feature 5: Responsive Shell

---

## TEIL 2: NEUE FEATURES

### Feature 1: Begrüßungsbildschirm (ohne Cookies!)

```dart
// lib/src/shared/widgets/welcome_overlay.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeOverlay extends StatefulWidget {
  final Widget child;
  
  const WelcomeOverlay({super.key, required this.child});
  
  @override
  State<WelcomeOverlay> createState() => _WelcomeOverlayState();
}

class _WelcomeOverlayState extends State<WelcomeOverlay> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showOverlay = true;
  bool _isLoading = true;
  
  // LocalStorage Key (NICHT Cookie!)
  static const _storageKey = 'msh_welcome_seen_v1';
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _checkIfSeen();
  }
  
  Future<void> _checkIfSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_storageKey) ?? false;
    setState(() {
      _showOverlay = !seen;
      _isLoading = false;
    });
  }
  
  Future<void> _dismiss() async {
    _controller.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, true);
    setState(() => _showOverlay = false);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.child; // Oder Splash-Screen
    }
    
    return Stack(
      children: [
        widget.child,
        
        if (_showOverlay)
          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(_fadeAnimation),
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && 
                    details.primaryVelocity!.abs() > 100) {
                  _dismiss();
                }
              },
              child: _WelcomeContent(onStart: _dismiss),
            ),
          ),
      ],
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  final VoidCallback onStart;
  
  const _WelcomeContent({required this.onStart});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF0000000),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MshColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.map,
                    size: 64,
                    color: MshColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Titel
                Text(
                  'Willkommen bei',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MSH Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mansfeld-Südharz entdecken',
                  style: TextStyle(
                    color: MshColors.primary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Features
                _FeatureItem(
                  icon: Icons.family_restroom,
                  title: 'Familienausflüge',
                  desc: 'Spielplätze, Museen, Natur',
                ),
                _FeatureItem(
                  icon: Icons.restaurant,
                  title: 'Gastronomie',
                  desc: 'Restaurants, Cafés, Imbisse',
                ),
                _FeatureItem(
                  icon: Icons.storefront,
                  title: 'Regionaler Flohmarkt',
                  desc: 'Kaufen & Verkaufen ohne Versand',
                ),
                _FeatureItem(
                  icon: Icons.cookie_outlined,
                  title: 'Privatsphäre-freundlich',
                  desc: 'Keine Tracking-Cookies',
                  highlight: true,
                ),
                
                const SizedBox(height: 40),
                
                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MshColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Karte öffnen',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Tippen oder wischen zum Starten',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool highlight;
  
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
    this.highlight = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight 
            ? MshColors.success.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: highlight 
            ? Border.all(color: MshColors.success.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: highlight ? MshColors.success : MshColors.primary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white60,
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
```

---

### Feature 2: Popularitäts-basierte Marker (DSGVO-konform)

```dart
// Konzept: Anonyme View-Counts in Firestore, KEINE User-Identifikation

// lib/src/core/services/popularity_service.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class PopularityService {
  final FirebaseFirestore _firestore;
  
  PopularityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Erhöht anonymen View-Count
  /// Keine User-ID, keine IP, kein Tracking!
  Future<void> recordView(String locationId) async {
    try {
      await _firestore.collection('locations').doc(locationId).update({
        'stats.viewCount': FieldValue.increment(1),
        'stats.lastViewed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Fail silently - Statistik ist nicht kritisch
      debugPrint('PopularityService.recordView failed: $e');
    }
  }
  
  /// Berechnet Marker-Größe (32-52px)
  double calculateMarkerSize({
    required int viewCount,
    required int clickCount,
    int maxViews = 500,  // Obergrenze für Normalisierung
  }) {
    const minSize = 32.0;
    const maxSize = 52.0;
    
    // Gewichtete Kombination
    final score = (viewCount * 0.3) + (clickCount * 0.7);
    
    // Logarithmische Skalierung (damit neue Orte auch sichtbar sind)
    final normalized = (log(score + 1) / log(maxViews + 1)).clamp(0.0, 1.0);
    
    return minSize + (normalized * (maxSize - minSize));
  }
  
  /// Bestimmt ob "Beliebt" Badge angezeigt wird
  bool isPopular({required int viewCount, required int clickCount}) {
    return viewCount > 50 || clickCount > 10;
  }
}

// In Firestore-Dokument:
// locations/{id}
//   stats:
//     viewCount: 42
//     clickCount: 15
//     lastViewed: Timestamp
```

**Im Marker-Widget:**
```dart
Widget _buildMarker(MapItem item, PopularityStats stats) {
  final size = _popularityService.calculateMarkerSize(
    viewCount: stats.viewCount,
    clickCount: stats.clickCount,
  );
  
  return Stack(
    clipBehavior: Clip.none,
    children: [
      // Haupt-Marker
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: item.markerColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: item.markerColor.withOpacity(0.4),
              blurRadius: size / 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          _iconFor(item.category),
          color: Colors.white,
          size: size * 0.55,
        ),
      ),
      
      // "Beliebt" Badge
      if (_popularityService.isPopular(
        viewCount: stats.viewCount, 
        clickCount: stats.clickCount,
      ))
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star, size: 10, color: Colors.white),
          ),
        ),
    ],
  );
}
```

---

### Feature 3: Kategorie-Schnellleiste

```dart
// lib/src/shared/widgets/category_quick_filter.dart

class CategoryQuickFilter extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final Map<String, int> categoryCounts; // Anzahl pro Kategorie
  
  const CategoryQuickFilter({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.categoryCounts = const {},
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _CategoryChip(
            label: 'Alle',
            icon: Icons.apps,
            count: categoryCounts.values.fold(0, (a, b) => a + b),
            isSelected: selectedCategory == null,
            onTap: () => onCategoryChanged(null),
          ),
          ..._categories.map((cat) => _CategoryChip(
            label: cat.label,
            icon: cat.icon,
            color: cat.color,
            count: categoryCounts[cat.id] ?? 0,
            isSelected: selectedCategory == cat.id,
            onTap: () => onCategoryChanged(
              selectedCategory == cat.id ? null : cat.id,
            ),
          )),
        ],
      ),
    );
  }
  
  static const _categories = [
    (id: 'playground', label: 'Spielplätze', icon: Icons.toys, color: Color(0xFF10B981)),
    (id: 'museum', label: 'Museen', icon: Icons.museum, color: Color(0xFF8B5CF6)),
    (id: 'nature', label: 'Natur', icon: Icons.park, color: Color(0xFF22C55E)),
    (id: 'pool', label: 'Baden', icon: Icons.pool, color: Color(0xFF06B6D4)),
    (id: 'castle', label: 'Burgen', icon: Icons.castle, color: Color(0xFFEC4899)),
    (id: 'gastro', label: 'Essen', icon: Icons.restaurant, color: Color(0xFFEF4444)),
  ];
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.label,
    required this.icon,
    this.color,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? MshColors.primary;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? chipColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? chipColor : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : chipColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : MshColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.3) 
                          : chipColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : chipColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### Feature 4: NO-COOKIE Badge

```dart
// lib/src/shared/widgets/privacy_badge.dart

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPrivacySheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: MshColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MshColors.success.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍪', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
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
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
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
                Icon(Icons.verified_user, color: MshColors.success, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Deine Privatsphäre',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _PrivacyPoint(
              icon: Icons.cookie_outlined,
              iconColor: MshColors.success,
              title: 'Keine Tracking-Cookies',
              desc: 'Wir setzen keine Cookies, die dein Verhalten verfolgen.',
            ),
            _PrivacyPoint(
              icon: Icons.analytics_outlined,
              iconColor: MshColors.success,
              title: 'Keine Analyse-Dienste',
              desc: 'Kein Google Analytics, kein Facebook Pixel, keine Tracker.',
            ),
            _PrivacyPoint(
              icon: Icons.visibility_off_outlined,
              iconColor: MshColors.success,
              title: 'Anonyme Statistiken',
              desc: 'Wir zählen nur, wie oft Orte angesehen werden – ohne dich zu identifizieren.',
            ),
            _PrivacyPoint(
              icon: Icons.storage_outlined,
              iconColor: MshColors.info,
              title: 'Minimale lokale Speicherung',
              desc: 'Nur ob du das Intro gesehen hast, wird lokal gespeichert.',
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/privacy');
                },
                child: const Text('Datenschutzerklärung lesen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  
  const _PrivacyPoint({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });
  
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
                Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
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
```

---

### Feature 5: Responsive Navigation Shell

```dart
// lib/src/app_shell.dart

import 'package:flutter/material.dart';

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
        onDestinationSelected: onIndexChanged,
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
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Flohmarkt',
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
            onDestinationSelected: onIndexChanged,
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
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: Text('Flohmarkt'),
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
                        child: Icon(Icons.map, color: MshColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
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
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    children: [
                      _SidebarItem(
                        icon: Icons.map,
                        label: 'Karte',
                        isSelected: selectedIndex == 0,
                        onTap: () => onIndexChanged(0),
                      ),
                      _SidebarItem(
                        icon: Icons.family_restroom,
                        label: 'Familienaktivitäten',
                        isSelected: selectedIndex == 1,
                        onTap: () => onIndexChanged(1),
                      ),
                      _SidebarItem(
                        icon: Icons.storefront,
                        label: 'Flohmarkt',
                        isSelected: selectedIndex == 2,
                        onTap: () => onIndexChanged(2),
                        badge: 'Neu',
                      ),
                      _SidebarItem(
                        icon: Icons.event,
                        label: 'Events',
                        isSelected: selectedIndex == 3,
                        onTap: () => onIndexChanged(3),
                        badge: 'Bald',
                        disabled: true,
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Divider(),
                      ),
                      
                      _SidebarItem(
                        icon: Icons.info_outline,
                        label: 'Über MSH Map',
                        onTap: () => context.go('/about'),
                      ),
                      _SidebarItem(
                        icon: Icons.feedback_outlined,
                        label: 'Feedback geben',
                        onTap: () => context.go('/feedback'),
                      ),
                    ],
                  ),
                ),
                
                // Footer
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const PrivacyBadge(),
                      const SizedBox(height: 12),
                      const PoweredByBadge(compact: true),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badge == 'Neu' 
                          ? MshColors.primary 
                          : MshColors.textSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        color: badge == 'Neu' ? Colors.white : MshColors.textSecondary,
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
```

---

## TEIL 3: ERWEITERTE DATENQUELLEN

### Zusätzliche Scraping-Quellen

```python
# Ergänzung zu msh_scraper.py SOURCES Liste:

EXTENDED_SOURCES = [
    # ═══ SPIELPLÄTZE ═══
    {
        'name': 'Spielplatztreff',
        'base_url': 'https://www.spielplatztreff.de',
        'search_pattern': '/spielplaetze/{city}',
        'cities': ['sangerhausen', 'eisleben', 'hettstedt', 'mansfeld'],
        'enabled': True
    },
    
    # ═══ SCHWIMMBÄDER ═══
    {
        'name': 'Baeder Portal',
        'base_url': 'https://www.baederportal.com',
        'paths': ['/sachsen-anhalt/mansfeld-suedharz'],
        'enabled': True
    },
    
    # ═══ MUSEEN ═══
    {
        'name': 'Museumsverband SA',
        'base_url': 'https://www.mv-sachsen-anhalt.de',
        'paths': ['/museen/landkreis/mansfeld-suedharz'],
        'enabled': True
    },
    
    # ═══ BURGEN & SCHLÖSSER ═══
    {
        'name': 'Burgenarchiv',
        'base_url': 'https://www.burgen.de',
        'paths': ['/sachsen-anhalt'],
        'filter_region': 'mansfeld',
        'enabled': True
    },
    
    # ═══ WANDERWEGE ═══
    {
        'name': 'Outdooractive',
        'base_url': 'https://www.outdooractive.com',
        'paths': ['/de/wanderungen/mansfeld-suedharz'],
        'enabled': False  # Braucht API-Key
    },
    
    # ═══ GASTRONOMIE ═══
    {
        'name': 'Tripadvisor',
        'base_url': 'https://www.tripadvisor.de',
        'paths': ['/Restaurants-g187406-Saxony_Anhalt.html'],
        'filter_region': 'mansfeld',
        'enabled': False  # Anti-Scraping
    },
    
    # ═══ EVENTS ═══
    {
        'name': 'MZ Veranstaltungen',
        'base_url': 'https://www.mz.de',
        'paths': ['/veranstaltungen/sangerhausen', '/veranstaltungen/eisleben'],
        'enabled': True
    },
]

# Manuelle Erweiterung der KNOWN_LOCATIONS
KNOWN_LOCATIONS_EXTENDED = [
    # ═══ SPIELPLÄTZE ═══
    {
        "name": "Abenteuerspielplatz Rosengarten",
        "category": "playground",
        "description": "Großer Spielplatz mit Kletterpyramide, Seilbahn und Wasserspielbereich",
        "address": "Rosengarten, 06526 Sangerhausen",
        "latitude": 51.4712,
        "longitude": 11.3045,
        "city": "Sangerhausen",
        "age_range": "3-12",
        "is_free": True,
        "is_outdoor": True,
        "facilities": ["wc", "parking", "picnic"],
        "tags": ["klettern", "seilbahn", "wasser", "groß"]
    },
    
    # ═══ SCHWIMMBÄDER ═══
    {
        "name": "Erlebnisbad Sangerhausen",
        "category": "pool",
        "description": "Freibad mit Rutschen, Sprungturm und Kinderbereich",
        "address": "Badstraße 1, 06526 Sangerhausen",
        "latitude": 51.4689,
        "longitude": 11.2934,
        "city": "Sangerhausen",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "facilities": ["wc", "parking", "changing_table", "cafe"],
        "tags": ["baden", "schwimmen", "rutschen", "sommer"],
        "price_info": "Erwachsene 4€, Kinder 2.50€"
    },
    
    # ═══ WEITERE MUSEEN ═══
    {
        "name": "Spengler-Museum",
        "category": "museum",
        "description": "Naturkunde- und Heimatmuseum mit Mammut-Skelett",
        "address": "Bahnhofstraße 33, 06526 Sangerhausen",
        "latitude": 51.4701,
        "longitude": 11.2956,
        "city": "Sangerhausen",
        "age_range": "6-12",
        "is_free": False,
        "is_indoor": True,
        "tags": ["mammut", "naturkunde", "geschichte", "fossilien"]
    },
    
    # ═══ WEITERE NATUR ═══
    {
        "name": "Numburg bei Kelbra",
        "category": "nature",
        "description": "Aussichtspunkt mit Wanderwegen und Blick über den Kyffhäuser",
        "address": "Bei Kelbra",
        "latitude": 51.4234,
        "longitude": 11.0567,
        "city": "Kelbra",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["wandern", "aussicht", "kyffhäuser"]
    },
    
    # ═══ BAUERNHÖFE ═══
    {
        "name": "Erlebnisbauernhof Beyernaumburg",
        "category": "farm",
        "description": "Bauernhof zum Anfassen mit Streicheltieren",
        "address": "Beyernaumburg",
        "latitude": 51.4567,
        "longitude": 11.4234,
        "city": "Allstedt",
        "age_range": "0-6",
        "is_free": False,
        "is_outdoor": True,
        "facilities": ["parking", "wc"],
        "tags": ["tiere", "bauernhof", "streicheln", "landwirtschaft"]
    },
]
```

---

## TEIL 4: IMPLEMENTIERUNGS-REIHENFOLGE

### Sprint 1: Bugfixes (1-2 Tage)
1. [x] Mausrad-Zoom fixen
2. [x] Trackpad-Pinch fixen  
3. [ ] Filter-Logik reparieren
4. [ ] About-Route debuggen

### Sprint 2: Quick Wins (2-3 Tage)
5. [ ] Welcome-Overlay implementieren
6. [ ] Kategorie-Schnellfilter
7. [ ] Privacy-Badge

### Sprint 3: Navigation (3-4 Tage)
8. [ ] Responsive Shell implementieren
9. [ ] Mobile: Bottom Navigation
10. [ ] Tablet: Rail
11. [ ] Desktop: Sidebar

### Sprint 4: Engagement (2-3 Tage)
12. [ ] PopularityService
13. [ ] Dynamische Marker-Größen
14. [ ] "Beliebt"-Badges

### Sprint 5: Daten (ongoing)
15. [ ] Erweiterte Scraping-Quellen
16. [ ] Mehr manuelle Orte
17. [ ] Geocoding für fehlende Koordinaten

---

## PROMPT FÜR CLAUDE CODE

```
Ich möchte die MSH Map verbessern.

BUGS (HÖCHSTE PRIORITÄT):
1. Mausrad-Zoom funktioniert nicht (Web)
2. Trackpad-Pinch funktioniert nicht
3. Filter blenden Marker nicht korrekt aus
4. About-Seite (/about) wird nicht angezeigt

Lies 14_UX_IMPROVEMENTS.md und beginne mit Bug 1.
Zeige mir den relevanten Code und den Fix.
Warte nach jedem Fix auf meine Bestätigung.
```
