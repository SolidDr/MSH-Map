# Prompt 5: Filter, UI-Fixes und Entdecken-Sync

## Probleme

| # | Problem | Bereich |
|---|---------|---------|
| 1 | Filter-Bug: Standard soll NUR Radwege + Gesundheit sein | Filter |
| 2 | Krankenhäuser-Filter fehlt unter "Gesundheit" | Filter |
| 3 | Unterkategorien haben kein "auf Karte anzeigen" | Navigation |
| 4 | Entdecken-Einträge haben keinen Pin auf Karte | Daten-Sync |
| 5 | Mobile: "Touren" → "Rad/Wege" umbenennen | UI |

---

## A: Default-Filter korrigieren

### Anforderung
Beim ersten Besuch der Seite sollen NUR zwei Filter aktiv sein:
- ✅ Radwege
- ✅ Gesundheit
- ❌ Alles andere AUS

### Implementation

```dart
// lib/src/modules/filter/filter_state.dart

class FilterState {
  // Default-Werte bei App-Start
  static FilterState getDefault() {
    return FilterState(
      // NUR diese beiden aktiv!
      activeCategories: {
        'radwege',
        'gesundheit',
      },
      
      // Alle anderen Filter deaktiviert
      showPOIs: false,
      showEvents: false,
      showGastro: false,
      showCulture: false,
      showNature: false,
      showSport: false,
      // ...
      
      // Radwege und Gesundheit explizit an
      showRadwege: true,
      showGesundheit: true,
    );
  }
}

// Bei App-Initialisierung
void initFilters() {
  // Prüfen ob User schon eigene Einstellungen hat
  final savedFilters = localStorage.get('userFilters');
  
  if (savedFilters == null) {
    // Erster Besuch → Default setzen
    setFilters(FilterState.getDefault());
  } else {
    // Gespeicherte Einstellungen laden
    setFilters(FilterState.fromJson(savedFilters));
  }
}
```

### Für Web (falls React/Vue/Vanilla JS)

```javascript
// filterState.js

const DEFAULT_FILTERS = {
  // NUR Radwege und Gesundheit aktiv
  radwege: true,
  gesundheit: true,
  
  // Alles andere aus
  gastronomie: false,
  kultur: false,
  freizeit: false,
  natur: false,
  bildung: false,
  shopping: false,
  events: false,
};

function initFilters() {
  const saved = localStorage.getItem('msh_map_filters');
  
  if (!saved) {
    // Erster Besuch
    return { ...DEFAULT_FILTERS };
  }
  
  try {
    return JSON.parse(saved);
  } catch {
    return { ...DEFAULT_FILTERS };
  }
}
```

---

## B: Krankenhäuser-Filter unter Gesundheit hinzufügen

### Aktuelle Struktur (vermutlich)

```
Gesundheit
├── Ärzte
├── Apotheken
├── Physiotherapie
├── AED
└── [Krankenhäuser fehlt!]
```

### Neue Struktur

```
Gesundheit
├── Krankenhäuser ← NEU!
├── Ärzte
├── Apotheken
├── Physiotherapie
├── AED
├── Pflegedienste
└── Sanitätshäuser
```

### Implementation

```dart
// lib/src/modules/health/health_categories.dart

enum HealthCategory {
  hospitals,      // ← NEU!
  doctors,
  pharmacies,
  physiotherapy,
  aed,
  careServices,
  medicalSupply,
}

const healthCategoryConfig = {
  HealthCategory.hospitals: CategoryConfig(
    id: 'hospitals',
    name: 'Krankenhäuser',
    icon: Icons.local_hospital,
    color: Colors.red,
    dataFile: 'health/hospitals.json',
    markerIcon: 'assets/markers/hospital.png',
  ),
  HealthCategory.doctors: CategoryConfig(
    id: 'doctors',
    name: 'Ärzte',
    icon: Icons.medical_services,
    // ...
  ),
  // ...
};
```

### UI für Filter-Auswahl

```dart
// In health_filter_widget.dart

ListView(
  children: [
    // NEU: Krankenhäuser als erste Option
    FilterToggle(
      label: 'Krankenhäuser',
      icon: Icons.local_hospital,
      isActive: filters.showHospitals,
      onToggle: (v) => setFilter('hospitals', v),
    ),
    
    FilterToggle(
      label: 'Ärzte',
      icon: Icons.medical_services,
      isActive: filters.showDoctors,
      onToggle: (v) => setFilter('doctors', v),
    ),
    
    // ... weitere
  ],
)
```

---

## C: Unterkategorien "Auf Karte anzeigen"

### Problem
Wenn man auf eine Unterkategorie wie "Gesundheit" oder "Sozial" klickt, passiert nichts.

### Lösung: Click-Handler implementieren

```dart
// Unterkategorie-Widget

class SubcategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String categoryId;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      
      // ← FEHLENDER CLICK-HANDLER!
      onTap: () => _showOnMap(context, categoryId),
    );
  }
  
  void _showOnMap(BuildContext context, String categoryId) {
    // 1. Filter auf diese Kategorie setzen
    final filterProvider = context.read<FilterProvider>();
    filterProvider.setOnlyCategory(categoryId);
    
    // 2. Zur Karte navigieren
    Navigator.pushNamed(context, '/map');
    
    // 3. Optional: Auf Bereich zoomen wo Einträge sind
    final bounds = calculateBoundsForCategory(categoryId);
    mapController.fitBounds(bounds);
  }
}
```

### Für Listen-Ansicht mit "Alle auf Karte" Button

```dart
// category_list_screen.dart

Scaffold(
  appBar: AppBar(
    title: Text(categoryName),
    actions: [
      // "Auf Karte anzeigen" Button
      IconButton(
        icon: Icon(Icons.map),
        tooltip: 'Alle auf Karte anzeigen',
        onPressed: () => _showAllOnMap(),
      ),
    ],
  ),
  body: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return LocationTile(
        location: items[index],
        onTap: () => _showSingleOnMap(items[index]),
      );
    },
  ),
)
```

---

## D: Entdecken-Einträge ohne Pin auf Karte (SYNC-PROBLEM!)

### Problem
Einträge sind unter "Entdecken" sichtbar, aber haben keinen Pin auf der Karte.

### Ursache (wahrscheinlich)
Die Daten für "Entdecken" und die Karte kommen aus verschiedenen Quellen, die nicht synchronisiert sind.

### Diagnose-Script

```javascript
// scripts/check-data-sync.js

const discoverItems = require('./data/discover.json');
const locations = require('./data/locations.json');

// Finde Einträge die in Discover aber nicht in Locations sind
const missingInLocations = discoverItems.filter(item => {
  return !locations.data.some(loc => 
    loc.id === item.id ||
    loc.name === item.name
  );
});

console.log(`❌ ${missingInLocations.length} Einträge ohne Karten-Pin:`);
missingInLocations.forEach(item => {
  console.log(`  - ${item.name} (${item.category})`);
});
```

### Lösung A: Einheitliche Datenquelle

```dart
// ALLE Daten aus locations.json laden
// Entdecken filtert nur anders

class DataRepository {
  List<Location> _allLocations = [];
  
  // Für Karte
  List<Location> getMapLocations(Filters filters) {
    return _allLocations.where((l) => matchesFilters(l, filters)).toList();
  }
  
  // Für Entdecken - gleiche Daten, andere Darstellung!
  List<Location> getDiscoverLocations(String category) {
    return _allLocations.where((l) => l.category == category).toList();
  }
}
```

### Lösung B: Fehlende Locations ergänzen

```javascript
// Für jeden Discover-Eintrag ohne Location:
// → Koordinaten ermitteln und in locations.json einfügen

missingInLocations.forEach(async (item) => {
  // Koordinaten per Nominatim ermitteln
  const coords = await geocode(item.address);
  
  if (coords) {
    const newLocation = {
      id: item.id,
      name: item.name,
      category: item.category,
      latitude: coords.lat,
      longitude: coords.lng,
      address: item.address,
      // ...weitere Felder
    };
    
    locations.data.push(newLocation);
  }
});

// Speichern
fs.writeFileSync('./data/locations.json', JSON.stringify(locations, null, 2));
```

### Lösung C: Navigation mit ID-Lookup

```dart
// Wenn User auf Entdecken-Eintrag klickt:

void onDiscoverItemTap(DiscoverItem item) {
  // Finde zugehörige Location
  final location = locationRepository.findById(item.id) ??
                   locationRepository.findByName(item.name);
  
  if (location != null) {
    // Zur Karte mit diesem Pin
    navigateToMapWithFocus(location);
  } else {
    // FEHLER: Kein Pin gefunden!
    showWarning('Dieser Ort ist noch nicht auf der Karte verfügbar.');
    
    // Für Entwickler loggen
    logger.error('Missing location for discover item: ${item.id}');
  }
}
```

---

## E: Mobile "Touren" → "Rad/Wege" umbenennen

### Aufgabe
Im Mobile-Menü soll "Touren" in "Rad/Wege" umbenannt werden.

### Suchen & Ersetzen

```bash
# Finde alle Vorkommen von "Touren"
grep -r "Touren" --include="*.dart" --include="*.json" lib/
grep -r '"Touren"' --include="*.dart" --include="*.json" lib/
grep -r "'Touren'" --include="*.dart" --include="*.json" lib/
```

### Änderung

```dart
// VORHER:
const mobileMenuItems = [
  MenuItem(label: 'Karte', ...),
  MenuItem(label: 'Entdecken', ...),
  MenuItem(label: 'Touren', ...),  // ← FALSCH
  MenuItem(label: 'Gesundheit', ...),
];

// NACHHER:
const mobileMenuItems = [
  MenuItem(label: 'Karte', ...),
  MenuItem(label: 'Entdecken', ...),
  MenuItem(label: 'Rad/Wege', ...),  // ← RICHTIG
  MenuItem(label: 'Gesundheit', ...),
];
```

### Lokalisierung (falls i18n vorhanden)

```json
// de.json
{
  "menu": {
    "map": "Karte",
    "discover": "Entdecken",
    "cycling": "Rad/Wege",  // Geändert von "Touren"
    "health": "Gesundheit"
  }
}
```

---

## Checkliste

```
FILTER:
[ ] Default-Filter: Nur Radwege + Gesundheit aktiv
[ ] Getestet: Erster Besuch zeigt nur diese Filter
[ ] Krankenhäuser-Filter unter Gesundheit hinzugefügt
[ ] Filter-Icon und Text für Krankenhäuser

NAVIGATION:
[ ] Unterkategorien haben Click-Handler
[ ] Klick öffnet Karte mit Filter
[ ] "Auf Karte anzeigen" funktioniert

DATEN-SYNC:
[ ] check-data-sync.js ausgeführt
[ ] Liste fehlender Pins erstellt
[ ] Fehlende Locations ergänzt ODER
[ ] Einheitliche Datenquelle implementiert
[ ] Alle Entdecken-Einträge haben Pins

UI:
[ ] "Touren" → "Rad/Wege" umbenannt
[ ] Auf Mobile getestet
```

---

## Deliverables

1. **Aktualisierte Filter-Defaults**
2. **Krankenhäuser-Kategorie** in health_categories
3. **Click-Handler** für Unterkategorien
4. **Daten-Sync Report:** Liste synchronisierter Einträge
5. **UI-Update:** "Rad/Wege" statt "Touren"
