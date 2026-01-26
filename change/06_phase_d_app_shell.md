# 06 - Phase D: App Shell

## Ziel
Auth verschieben, HomeScreen mit Karte erstellen, App zusammenführen.

---

## Schritt D1: Auth verschieben

```bash
# Auth-Dateien in neuen Ordner kopieren
cp -r lib/src/features/authentication/* lib/src/features/auth/ 2>/dev/null || true

# Alten Ordner markieren
mv lib/src/features/authentication lib/_deprecated/authentication_old 2>/dev/null || true
```

**WICHTIG:** Import-Pfade in den kopierten Dateien anpassen!

**Checkpoint:** `✅ D1 - Auth verschoben`

---

## Schritt D2: HomeScreen erstellen

Erstelle `lib/src/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/widgets/msh_map_view.dart';
import 'shared/widgets/layer_switcher.dart';
import 'shared/widgets/poi_bottom_sheet.dart';
import 'shared/domain/map_item.dart';
import 'modules/_module_registry.dart';
import 'core/config/map_config.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<MapItem> _items = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final allItems = <MapItem>[];
      for (final module in ModuleRegistry.instance.active) {
        final items = await module.getItemsInRegion(MapConfig.mshRegion);
        allItems.addAll(items);
      }
      
      setState(() {
        _items = allItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Karte
          MshMapView(
            items: _items,
            onMarkerTap: (item) => PoiBottomSheet.show(context, item),
          ),
          
          // Suchleiste
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _SearchBar(onTap: () {
              // TODO: Zur Suchseite navigieren
            }),
          ),
          
          // Loading
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          
          // Error
          if (_error != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Fehler: $_error'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: LayerSwitcher(onLayerChanged: _loadItems),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  
  const _SearchBar({required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'In MSH suchen...',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Checkpoint:** `✅ D2 - HomeScreen erstellt`

---

## Schritt D3: Router aktualisieren

Erstelle/Aktualisiere `lib/src/core/router/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';
import '../../home_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../modules/_module_registry.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Modul-Routes dynamisch sammeln
    ...ModuleRegistry.instance.collectAllRoutes(),
  ],
);
```

**Hinweis:** Falls `LoginScreen` noch nicht existiert oder andere Imports fehlen, temporär auskommentieren.

**Checkpoint:** `✅ D3 - Router aktualisiert`

---

## Schritt D4: app.dart aktualisieren

Aktualisiere `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/router/app_router.dart';

class MshMapApp extends StatelessWidget {
  const MshMapApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'MSH Map',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE53935)),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

**Checkpoint:** `✅ D4 - app.dart aktualisiert`

---

## Schritt D5: main.dart aktualisieren

Aktualisiere `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'src/modules/_module_registry.dart';
import 'src/modules/gastro/gastro_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Module registrieren
  ModuleRegistry.instance.register(GastroModule());
  
  // Module initialisieren
  await ModuleRegistry.instance.initializeAll();
  
  runApp(const MshMapApp());
}
```

**Checkpoint:** `✅ D5 - main.dart aktualisiert`

---

## Schritt D6: Validierung & Test

```bash
flutter analyze
flutter run
```

**Erwartetes Ergebnis:**
- App startet ohne Crash
- Karte zeigt MSH-Region
- Layer-Switcher ist sichtbar

**Checkpoint:** `✅ D6 - App läuft`

---

## Phase D Checkliste

```markdown
## PHASE D CHECKLIST:
- [ ] D1: Auth nach features/auth verschoben
- [ ] D2: HomeScreen erstellt
- [ ] D3: Router aktualisiert
- [ ] D4: app.dart aktualisiert
- [ ] D5: main.dart mit Modul-Registrierung
- [ ] D6: `flutter analyze` = 0 errors
- [ ] D6: `flutter run` startet ohne Crash
- [ ] D6: Karte wird angezeigt
```

**WEITER MIT:** `07_PHASE_E_CLEANUP.md`