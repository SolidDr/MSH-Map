# 07 - Phase E: Stubs & Cleanup

## Ziel
Platzhalter-Module für Events und Suche, finale Aufräumarbeiten.

---

## Schritt E1: Events-Modul Stub

Erstelle `lib/src/modules/events/domain/event.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../shared/domain/map_item.dart';
import '../../../shared/domain/coordinates.dart';

class Event implements MapItem {
  @override
  final String id;
  final String title;
  final String? description;
  final Coordinates location;
  final DateTime date;
  
  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.date,
  });
  
  @override
  Coordinates get coordinates => location;
  
  @override
  String get displayName => title;
  
  @override
  String? get subtitle => description;
  
  @override
  MapItemCategory get category => MapItemCategory.event;
  
  @override
  Color get markerColor => const Color(0xFF7B1FA2);
  
  @override
  String get moduleId => 'events';
  
  @override
  DateTime? get lastUpdated => date;
}
```

Erstelle `lib/src/modules/events/events_module.dart`:

```dart
import 'package:flutter/material.dart';
import '../../shared/domain/map_item.dart';
import '../../shared/domain/bounding_box.dart';
import '../_module_registry.dart';

/// Stub: Events-Modul (Implementierung später)
class EventsModule extends MshModule {
  @override
  String get moduleId => 'events';
  
  @override
  String get displayName => 'Events';
  
  @override
  IconData get icon => Icons.event;
  
  @override
  Color get primaryColor => const Color(0xFF7B1FA2);
  
  @override
  Future<void> initialize() async {}
  
  @override
  Future<void> dispose() async {}
  
  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return Stream.value([]); // Keine Daten
  }
  
  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) async {
    return []; // Keine Daten
  }
  
  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('Events - Coming Soon'),
        ],
      ),
    );
  }
}
```

**Checkpoint:** `✅ E1 - Events Stub erstellt`

---

## Schritt E2: Search-Modul Stub

Erstelle `lib/src/modules/search/domain/search_result.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../shared/domain/map_item.dart';
import '../../../shared/domain/coordinates.dart';

class SearchResult implements MapItem {
  @override
  final String id;
  final String title;
  final String? snippet;
  final Coordinates location;
  final String source;
  
  const SearchResult({
    required this.id,
    required this.title,
    this.snippet,
    required this.location,
    required this.source,
  });
  
  @override
  Coordinates get coordinates => location;
  
  @override
  String get displayName => title;
  
  @override
  String? get subtitle => snippet;
  
  @override
  MapItemCategory get category => MapItemCategory.search;
  
  @override
  Color get markerColor => const Color(0xFF1976D2);
  
  @override
  String get moduleId => 'search';
  
  @override
  DateTime? get lastUpdated => null;
}
```

Erstelle `lib/src/modules/search/search_module.dart`:

```dart
import 'package:flutter/material.dart';
import '../../shared/domain/map_item.dart';
import '../../shared/domain/bounding_box.dart';
import '../_module_registry.dart';

/// Stub: Such-Modul (Implementierung später)
class SearchModule extends MshModule {
  @override
  String get moduleId => 'search';
  
  @override
  String get displayName => 'Suche';
  
  @override
  IconData get icon => Icons.search;
  
  @override
  Color get primaryColor => const Color(0xFF1976D2);
  
  @override
  Future<void> initialize() async {}
  
  @override
  Future<void> dispose() async {}
  
  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return Stream.value([]);
  }
  
  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) async {
    return [];
  }
  
  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('Regionale Suche - Coming Soon'),
        ],
      ),
    );
  }
}
```

**Checkpoint:** `✅ E2 - Search Stub erstellt`

---

## Schritt E3: Module in main.dart registrieren (optional)

Falls gewünscht, können die Stubs schon registriert werden:

```dart
// In main.dart hinzufügen:
import 'src/modules/events/events_module.dart';
import 'src/modules/search/search_module.dart';

// In main() nach GastroModule:
ModuleRegistry.instance.register(EventsModule());
ModuleRegistry.instance.register(SearchModule());
```

**Checkpoint:** `✅ E3 - Stubs registriert (optional)`

---

## Schritt E4: pubspec.yaml aktualisieren

```yaml
name: msh_map
description: Regionale Plattform für Mansfeld-Südharz
version: 1.0.0+1

# Rest bleibt gleich...
```

**Checkpoint:** `✅ E4 - pubspec.yaml aktualisiert`

---

## Schritt E5: _deprecated dokumentieren

Erstelle `lib/_deprecated/README.md`:

```markdown
# Deprecated Code

Diese Dateien wurden bei der Migration zu MSH Map hierher verschoben.

## Inhalt
- `feed_old/` - Alter Feed-Code (jetzt in modules/gastro)
- `merchant_cockpit_old/` - Alter Cockpit-Code (jetzt in modules/gastro)
- `authentication_old/` - Alter Auth-Code (jetzt in features/auth)
- `common_widgets/` - Alte Widgets (jetzt in shared/widgets)

## Hinweis
Diese Dateien können gelöscht werden, sobald die Migration
vollständig getestet wurde (empfohlen: 2 Wochen warten).

Migrationsdatum: [DATUM EINTRAGEN]
```

**Checkpoint:** `✅ E5 - Deprecated dokumentiert`

---

## Schritt E6: Finale Validierung

```bash
# Analyse
flutter analyze

# Test-Run
flutter run

# Optional: Tests
flutter test
```

**Checkpoint:** `✅ E6 - Finale Validierung`

---

## Phase E Checkliste

```markdown
## PHASE E CHECKLIST:
- [ ] E1: EventsModule Stub erstellt
- [ ] E2: SearchModule Stub erstellt
- [ ] E3: Stubs registriert (optional)
- [ ] E4: pubspec.yaml aktualisiert
- [ ] E5: _deprecated README erstellt
- [ ] E6: `flutter analyze` = 0 errors
- [ ] E6: `flutter run` funktioniert
```

---

## 🎉 Migration abgeschlossen!

### Was funktioniert jetzt:
- ✅ Karte zeigt MSH-Region
- ✅ Layer-Switcher für Module
- ✅ Gastro-Modul mit Restaurants
- ✅ Bottom-Sheet für Details
- ✅ Modulare Architektur für Erweiterungen

### Nächste Schritte (nach Migration):
1. Events-Modul implementieren (Firestore Collection anlegen)
2. Such-Modul implementieren (SQL-Datenbank anbinden)
3. Filter-UI für Module
4. Offline-Caching
5. Push-Notifications für neue Angebote