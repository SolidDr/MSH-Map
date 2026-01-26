# 05 - Phase C: Gastro Module

## Ziel
Bestehende Lunch-Radar Logik in das Gastro-Modul überführen.

---

## Schritt C1: Restaurant Model erstellen

Erstelle `lib/src/modules/gastro/domain/restaurant.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/domain/map_item.dart';
import '../../../shared/domain/coordinates.dart';

enum RestaurantType { restaurant, cafe, imbiss, bar }

class Restaurant implements MapItem {
  @override
  final String id;
  
  final String name;
  final String? description;
  final Coordinates location;
  final RestaurantType type;
  final String? address;
  final String? phone;
  final String? website;
  final List<String> openingHours;
  final DateTime? lastMenuUpdate;
  final String? todaySpecial;
  final double? todayPrice;
  
  const Restaurant({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    required this.type,
    this.address,
    this.phone,
    this.website,
    this.openingHours = const [],
    this.lastMenuUpdate,
    this.todaySpecial,
    this.todayPrice,
  });
  
  // ═══ MapItem Implementation ═══
  
  @override
  Coordinates get coordinates => location;
  
  @override
  String get displayName => name;
  
  @override
  String? get subtitle => todaySpecial != null && todayPrice != null
      ? 'Heute: $todaySpecial – ${todayPrice!.toStringAsFixed(2)} €'
      : description;
  
  @override
  MapItemCategory get category => switch (type) {
    RestaurantType.restaurant => MapItemCategory.restaurant,
    RestaurantType.cafe => MapItemCategory.cafe,
    RestaurantType.imbiss => MapItemCategory.imbiss,
    RestaurantType.bar => MapItemCategory.bar,
  };
  
  @override
  Color get markerColor => const Color(0xFFE53935);
  
  @override
  String get moduleId => 'gastro';
  
  @override
  DateTime? get lastUpdated => lastMenuUpdate;
  
  @override
  Map<String, dynamic> get metadata => {
    'address': address,
    'phone': phone,
    'website': website,
    'openingHours': openingHours,
  };
  
  // ═══ Firestore ═══
  
  factory Restaurant.fromFirestore(String id, Map<String, dynamic> data) {
    final geoPoint = data['location'] as GeoPoint?;
    return Restaurant(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      location: geoPoint != null
          ? Coordinates(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
          : const Coordinates(latitude: 0, longitude: 0),
      type: RestaurantType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => RestaurantType.restaurant,
      ),
      address: data['address'],
      phone: data['phone'],
      website: data['website'],
      openingHours: List<String>.from(data['openingHours'] ?? []),
      lastMenuUpdate: (data['lastMenuUpdate'] as Timestamp?)?.toDate(),
      todaySpecial: data['todaySpecial'],
      todayPrice: (data['todayPrice'] as num?)?.toDouble(),
    );
  }
  
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'location': GeoPoint(location.latitude, location.longitude),
    'type': type.name,
    'address': address,
    'phone': phone,
    'website': website,
    'openingHours': openingHours,
    'lastMenuUpdate': lastMenuUpdate != null ? Timestamp.fromDate(lastMenuUpdate!) : null,
    'todaySpecial': todaySpecial,
    'todayPrice': todayPrice,
  };
}
```

**Checkpoint:** `✅ C1 - Restaurant Model erstellt`

---

## Schritt C2: Gastro Repository erstellen

Erstelle `lib/src/modules/gastro/data/gastro_repository.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/domain/bounding_box.dart';
import '../domain/restaurant.dart';

class GastroRepository {
  final FirebaseFirestore _firestore;
  
  GastroRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('restaurants');
  
  /// Stream von Restaurants in Region
  Stream<List<Restaurant>> watchRestaurantsInRegion(BoundingBox region) {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Restaurant.fromFirestore(doc.id, doc.data()))
          .where((r) => region.contains(r.coordinates))
          .toList();
    });
  }
  
  /// Einmalige Abfrage
  Future<List<Restaurant>> getRestaurantsInRegion(BoundingBox region) async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Restaurant.fromFirestore(doc.id, doc.data()))
        .where((r) => region.contains(r.coordinates))
        .toList();
  }
  
  /// Restaurant nach ID
  Future<Restaurant?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Restaurant.fromFirestore(doc.id, doc.data()!);
  }
  
  /// Tagesmenü aktualisieren
  Future<void> updateTodayMenu(String id, String special, double price) async {
    await _collection.doc(id).update({
      'todaySpecial': special,
      'todayPrice': price,
      'lastMenuUpdate': FieldValue.serverTimestamp(),
    });
  }
}
```

**Checkpoint:** `✅ C2 - Gastro Repository erstellt`

---

## Schritt C3: Restaurant Detail Widget

Erstelle `lib/src/modules/gastro/presentation/restaurant_detail.dart`:

```dart
import 'package:flutter/material.dart';
import '../domain/restaurant.dart';

class RestaurantDetailContent extends StatelessWidget {
  final Restaurant restaurant;
  
  const RestaurantDetailContent({super.key, required this.restaurant});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (restaurant.todaySpecial != null) ...[
          _SectionTitle('Tagesangebot'),
          _InfoCard(
            icon: Icons.restaurant_menu,
            title: restaurant.todaySpecial!,
            subtitle: restaurant.todayPrice != null
                ? '${restaurant.todayPrice!.toStringAsFixed(2)} €'
                : null,
          ),
          const SizedBox(height: 16),
        ],
        if (restaurant.address != null) ...[
          _SectionTitle('Adresse'),
          _InfoCard(icon: Icons.location_on, title: restaurant.address!),
          const SizedBox(height: 16),
        ],
        if (restaurant.phone != null) ...[
          _SectionTitle('Kontakt'),
          _InfoCard(icon: Icons.phone, title: restaurant.phone!),
          const SizedBox(height: 16),
        ],
        if (restaurant.openingHours.isNotEmpty) ...[
          _SectionTitle('Öffnungszeiten'),
          ...restaurant.openingHours.map((h) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(h),
          )),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  
  const _InfoCard({required this.icon, required this.title, this.subtitle});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
      ),
    );
  }
}
```

**Checkpoint:** `✅ C3 - Restaurant Detail erstellt`

---

## Schritt C4: GastroModule erstellen

Erstelle `lib/src/modules/gastro/gastro_module.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/domain/map_item.dart';
import '../../shared/domain/bounding_box.dart';
import '../_module_registry.dart';
import 'data/gastro_repository.dart';
import 'domain/restaurant.dart';
import 'presentation/restaurant_detail.dart';

class GastroModule extends MshModule {
  final GastroRepository _repository;
  
  GastroModule({GastroRepository? repository})
      : _repository = repository ?? GastroRepository();
  
  @override
  String get moduleId => 'gastro';
  
  @override
  String get displayName => 'Gastronomie';
  
  @override
  IconData get icon => Icons.restaurant;
  
  @override
  Color get primaryColor => const Color(0xFFE53935);
  
  @override
  Future<void> initialize() async {
    // Optional: Initiale Daten laden
  }
  
  @override
  Future<void> dispose() async {}
  
  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return _repository.watchRestaurantsInRegion(region);
  }
  
  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) {
    return _repository.getRestaurantsInRegion(region);
  }
  
  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is Restaurant) {
      return RestaurantDetailContent(restaurant: item);
    }
    return const Text('Unbekannter Typ');
  }
  
  @override
  List<FilterOption> get filterOptions => [
    FilterOption(
      id: 'has_menu',
      label: 'Mit Tagesangebot',
      icon: Icons.today,
      predicate: (item) => item is Restaurant && item.todaySpecial != null,
    ),
    FilterOption(
      id: 'type_imbiss',
      label: 'Nur Imbiss',
      icon: Icons.fastfood,
      predicate: (item) => item is Restaurant && item.type == RestaurantType.imbiss,
    ),
  ];
}
```

**Checkpoint:** `✅ C4 - GastroModule erstellt`

---

## Schritt C5: Bestehende Dateien migrieren

```bash
# Dish Model kopieren und anpassen
cp lib/src/features/feed/domain/dish_model.dart \
   lib/src/modules/gastro/domain/dish.dart 2>/dev/null || true

# Menu Model kopieren
cp lib/src/features/merchant_cockpit/domain/menu_item_model.dart \
   lib/src/modules/gastro/domain/menu.dart 2>/dev/null || true

# Upload Screens kopieren
cp lib/src/features/merchant_cockpit/presentation/upload_screen.dart \
   lib/src/modules/gastro/presentation/menu_upload/ 2>/dev/null || true
   
cp lib/src/features/merchant_cockpit/presentation/ocr_preview_screen.dart \
   lib/src/modules/gastro/presentation/menu_upload/ocr_preview.dart 2>/dev/null || true
```

**WICHTIG:** Nach dem Kopieren die Import-Pfade in den kopierten Dateien anpassen!

**Checkpoint:** `✅ C5 - Dateien migriert`

---

## Schritt C6: Alte Ordner nach _deprecated

```bash
mv lib/src/features/feed lib/_deprecated/feed_old 2>/dev/null || true
mv lib/src/features/merchant_cockpit lib/_deprecated/merchant_cockpit_old 2>/dev/null || true
```

**Checkpoint:** `✅ C6 - Alte Ordner deprecated`

---

## Phase C Checkliste

```markdown
## PHASE C CHECKLIST:
- [ ] C1: restaurant.dart implementiert MapItem
- [ ] C2: gastro_repository.dart erstellt
- [ ] C3: restaurant_detail.dart erstellt
- [ ] C4: gastro_module.dart erstellt
- [ ] C5: Alte Dateien kopiert & Imports angepasst
- [ ] C6: Alte Ordner in _deprecated
- [ ] `flutter analyze` = 0 errors
```

**WEITER MIT:** `06_PHASE_D_APP_SHELL.md`