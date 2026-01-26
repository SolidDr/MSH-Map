# PROMPT 2: Altersgerechte Empfehlungen

## Kontext

Du arbeitest am MSH Map Projekt. Das Feature-Flag System ist bereits implementiert.
`FeatureFlags.enableAgeFilter` ist auf `true` gesetzt.

## Deine Aufgabe

Implementiere einen Altersfilter, der Orte nach Kinder-Altersgruppen filtert.

## Anforderungen

1. Nutzer kann Altersgruppen auswählen (Mehrfachauswahl möglich)
2. Karte zeigt nur passende Orte
3. Orte haben ein `ageRange` Feld (z.B. "3-12")
4. Filter ist als Chip-Leiste über der Karte

## Schritt 1: Altersgruppen-Enum erstellen

Erstelle `lib/src/features/age_filter/domain/age_group.dart`:

```dart
/// Altersgruppen für Kinder
enum AgeGroup {
  baby(0, 2, 'Baby', '0-2 Jahre', '👶'),
  toddler(3, 5, 'Kleinkind', '3-5 Jahre', '🧒'),
  child(6, 11, 'Kind', '6-11 Jahre', '👦'),
  teen(12, 17, 'Teenager', '12-17 Jahre', '🧑'),
  all(0, 99, 'Alle', 'Alle Altersgruppen', '👨‍👩‍👧‍👦');

  final int minAge;
  final int maxAge;
  final String label;
  final String description;
  final String emoji;

  const AgeGroup(this.minAge, this.maxAge, this.label, this.description, this.emoji);

  /// Prüft ob ein Altersbereich zu dieser Gruppe passt
  /// ageRange Format: "3-12" oder "0+" oder "alle"
  bool matchesAgeRange(String? ageRange) {
    if (this == AgeGroup.all) return true;
    if (ageRange == null || ageRange.isEmpty) return true;
    if (ageRange.toLowerCase() == 'alle') return true;
    
    // Format: "3-12"
    if (ageRange.contains('-')) {
      final parts = ageRange.split('-');
      if (parts.length == 2) {
        final rangeMin = int.tryParse(parts[0].trim()) ?? 0;
        final rangeMax = int.tryParse(parts[1].trim()) ?? 99;
        // Überschneidung prüfen
        return !(maxAge < rangeMin || minAge > rangeMax);
      }
    }
    
    // Format: "6+"
    if (ageRange.endsWith('+')) {
      final rangeMin = int.tryParse(ageRange.replaceAll('+', '').trim()) ?? 0;
      return maxAge >= rangeMin;
    }
    
    // Einzelne Zahl
    final singleAge = int.tryParse(ageRange.trim());
    if (singleAge != null) {
      return singleAge >= minAge && singleAge <= maxAge;
    }
    
    return true; // Im Zweifel anzeigen
  }
}
```

## Schritt 2: Altersfilter Provider

Erstelle `lib/src/features/age_filter/application/age_filter_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/age_group.dart';

/// Aktuell ausgewählte Altersgruppen
final selectedAgeGroupsProvider = StateProvider<Set<AgeGroup>>((ref) {
  return {AgeGroup.all}; // Standard: Alle
});

/// Prüft ob ein Ort zu den ausgewählten Altersgruppen passt
final ageFilterProvider = Provider.family<bool, String?>((ref, ageRange) {
  final selectedGroups = ref.watch(selectedAgeGroupsProvider);
  
  // Wenn "Alle" ausgewählt, immer true
  if (selectedGroups.contains(AgeGroup.all)) return true;
  if (selectedGroups.isEmpty) return true;
  
  // Prüfen ob mindestens eine Gruppe passt
  return selectedGroups.any((group) => group.matchesAgeRange(ageRange));
});
```

## Schritt 3: Altersfilter Chips Widget

Erstelle `lib/src/features/age_filter/presentation/age_filter_chips.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/age_filter_provider.dart';
import '../domain/age_group.dart';
import '../../../core/config/feature_flags.dart';

class AgeFilterChips extends ConsumerWidget {
  const AgeFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Feature-Flag Check
    if (!FeatureFlags.enableAgeFilter) {
      return const SizedBox.shrink();
    }
    
    final selectedGroups = ref.watch(selectedAgeGroupsProvider);
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // "Alle" Chip
          _AgeChip(
            group: AgeGroup.all,
            isSelected: selectedGroups.contains(AgeGroup.all),
            onSelected: (selected) {
              if (selected) {
                ref.read(selectedAgeGroupsProvider.notifier).state = {AgeGroup.all};
              }
            },
          ),
          const SizedBox(width: 8),
          
          // Trennlinie
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 8),
          
          // Altersgruppen-Chips (ohne "all")
          ...AgeGroup.values
              .where((g) => g != AgeGroup.all)
              .map((group) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _AgeChip(
                      group: group,
                      isSelected: selectedGroups.contains(group),
                      onSelected: (selected) {
                        final current = Set<AgeGroup>.from(selectedGroups);
                        
                        // "Alle" entfernen wenn spezifische Gruppe gewählt
                        current.remove(AgeGroup.all);
                        
                        if (selected) {
                          current.add(group);
                        } else {
                          current.remove(group);
                        }
                        
                        // Wenn nichts mehr ausgewählt, zurück zu "Alle"
                        if (current.isEmpty) {
                          current.add(AgeGroup.all);
                        }
                        
                        ref.read(selectedAgeGroupsProvider.notifier).state = current;
                      },
                    ),
                  )),
        ],
      ),
    );
  }
}

class _AgeChip extends StatelessWidget {
  final AgeGroup group;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _AgeChip({
    required this.group,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(group.emoji),
          const SizedBox(width: 4),
          Text(group.label),
        ],
      ),
      tooltip: group.description,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
```

## Schritt 4: In Karten-Filter integrieren

Aktualisiere den Location-Filter (z.B. `filtered_locations_provider.dart`):

```dart
import '../age_filter/application/age_filter_provider.dart';

final filteredLocationsProvider = Provider<List<Location>>((ref) {
  final allLocations = ref.watch(locationsProvider).valueOrNull ?? [];
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedAgeGroups = ref.watch(selectedAgeGroupsProvider);
  
  return allLocations.where((location) {
    // Kategorie-Filter
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      if (location.category != selectedCategory) return false;
    }
    
    // Alters-Filter
    if (!selectedAgeGroups.contains(AgeGroup.all)) {
      final matchesAge = selectedAgeGroups.any(
        (group) => group.matchesAgeRange(location.ageRange)
      );
      if (!matchesAge) return false;
    }
    
    return true;
  }).toList();
});
```

## Schritt 5: Widget in Map-Screen einbauen

In deinem Map-Screen, füge die Chips über der Karte ein:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Altersfilter Chips (nur wenn Feature aktiv)
        if (FeatureFlags.enableAgeFilter)
          const AgeFilterChips(),
        
        // Karte
        Expanded(
          child: MshMapView(),
        ),
      ],
    ),
  );
}
```

## Schritt 6: Mock-Daten erweitern

Stelle sicher dass die Mock-Locations ein `ageRange` Feld haben:

```dart
// In mock_data.dart, bei jedem Ort:
{
  'id': 'mock_001',
  'name': 'Spielplatz Rosengarten',
  'category': 'playground',
  'ageRange': '3-12',  // ← Dieses Feld
  // ...
},
{
  'id': 'mock_010',
  'name': 'Europa-Rosarium',
  'category': 'nature',
  'ageRange': 'alle',  // Für alle geeignet
  // ...
},
{
  'id': 'mock_011',
  'name': 'Spengler-Museum',
  'category': 'museum',
  'ageRange': '6+',  // Ab 6 Jahren
  // ...
},
```

## Schritt 7: Location Model erweitern

Falls noch nicht vorhanden, füge `ageRange` zum Location Model hinzu:

```dart
@freezed
class Location with _$Location {
  const factory Location({
    required String id,
    required String name,
    // ... andere Felder
    String? ageRange,  // ← Hinzufügen
  }) = _Location;
}
```

## Abschluss

Nach Fertigstellung:
- [ ] AgeGroup Enum mit 5 Gruppen erstellt
- [ ] Provider für Filter-State implementiert
- [ ] Chip-Widget mit Mehrfachauswahl
- [ ] In Map integriert
- [ ] Mock-Daten haben ageRange
- [ ] Filter funktioniert: Chips auswählen → Marker werden gefiltert
- [ ] "Alle" setzt Filter zurück

Teste durch:
1. App starten
2. "Kind (6-11)" auswählen
3. Nur passende Orte sollten sichtbar sein
4. "Alle" auswählen → Alle Orte wieder da

Zeige mir eine Zusammenfassung.
