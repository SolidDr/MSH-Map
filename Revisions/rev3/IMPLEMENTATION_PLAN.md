# MSH Map - Implementierungsplan Nutzerfeedback Rev3

**Erstellt:** 2026-01-30
**Basierend auf:** nutzer_feedback2.md
**Gesamtbewertung:** 3.7/5 (12-30 J.) | 4.0/5 (30-80+ J.)

---

## Übersicht nach Priorität

| Priorität | Feature | Aufwand | Impact |
|-----------|---------|---------|--------|
| 🔴 Hoch | Auto-Complete Suche | Mittel | Hoch |
| 🔴 Hoch | Teilen-Funktion Events | Gering | Hoch |
| 🔴 Hoch | Telefonnummern klickbar (Übersicht) | Gering | Hoch |
| 🟠 Mittel | Deutsche Begriffe | Gering | Mittel |
| 🟠 Mittel | Barrierefreiheit-Hinweis Startseite | Gering | Mittel |
| 🟠 Mittel | Druckansicht | Mittel | Mittel |
| 🟠 Mittel | Scroll-Indikatoren Filter | Gering | Gering |
| 🟢 Niedrig | ÖPNV bei Events | Mittel | Mittel |
| 🟢 Niedrig | Standort-Erklärung verbessern | Gering | Gering |

---

## 🔴 Hohe Priorität

### 1. Auto-Complete Suche

**Problem:** Suche zeigt keine Vorschläge während der Eingabe

**Aktueller Stand:**
- Suche in `discover_screen.dart` (Zeile 90-100)
- Sucht in Namen, Untertiteln, Städten, Adressen
- Kein Autocomplete, keine Live-Vorschläge

**Lösung:**
```dart
// Neue Datei: lib/src/shared/widgets/search_autocomplete.dart

class SearchAutocomplete extends StatefulWidget {
  final List<MapItem> allItems;
  final Function(MapItem) onSelected;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<MapItem>(
      optionsBuilder: (TextEditingValue value) {
        if (value.text.length < 2) return [];
        return _filterItems(value.text);
      },
      displayStringForOption: (item) => item.displayName,
      optionsViewBuilder: (context, onSelected, options) {
        // Custom dropdown mit Icons und Kategorien
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Orte, Kategorien, Adressen...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => controller.clear(),
            ),
          ),
        );
      },
    );
  }
}
```

**Dateien zu ändern:**
- `lib/src/features/discover/presentation/discover_screen.dart`
- Neu: `lib/src/shared/widgets/search_autocomplete.dart`

**Aufwand:** ~2h

---

### 2. Teilen-Funktion für Events

**Problem:** Keine Möglichkeit Events zu teilen (WhatsApp, SMS, etc.)

**Aktueller Stand:**
- `AppStrings.actionShare = 'Teilen'` existiert (Zeile 115)
- Nicht implementiert in UI

**Lösung:**
```dart
// In engagement_detail_sheet.dart - Neuer Button in CTA-Row

// Dependency: share_plus (bereits in pubspec.yaml!)

import 'package:share_plus/share_plus.dart';

// Button hinzufügen nach "Navigation" Button (ca. Zeile 440)
OutlinedButton.icon(
  onPressed: () => _shareEvent(event),
  icon: const Icon(Icons.share, size: 18),
  label: const Text('Teilen'),
),

// Neue Methode
Future<void> _shareEvent(EngagementPlace event) async {
  final text = '''
${event.title}
📅 ${_formatDate(event.date)}
📍 ${event.locationName}

🔗 Mehr auf MSH Map:
https://msh-map.de/events/${event.id}
''';

  await Share.share(text, subject: event.title);
}
```

**Dateien zu ändern:**
- `lib/src/features/engagement/presentation/engagement_detail_sheet.dart`

**Aufwand:** ~30min

---

### 3. Telefonnummern in Übersichtslisten klickbar

**Problem:** Bei Ärzten/Apotheken nicht direkt klickbar in Übersicht

**Aktueller Stand:**
- `poi_list_view.dart` hat bereits Phone-Button (Zeile 234-257)
- Funktioniert für einzelne POIs
- Nicht überall sichtbar (z.B. Ärzte-Liste)

**Lösung:**
Prüfen wo Phone-Button fehlt und aktivieren:

```dart
// In poi_list_view.dart - showPhoneButton Parameter prüfen
// Standardmäßig true setzen wenn phone != null

Widget build(BuildContext context) {
  return ListTile(
    // ... existing code
    trailing: item.phone != null
      ? IconButton(
          icon: Icon(Icons.phone, color: Colors.green),
          onPressed: () => _callNumber(item.phone!),
        )
      : null,
  );
}
```

**Dateien zu prüfen:**
- `lib/src/modules/health/presentation/health_screen.dart`
- `lib/src/modules/civic/presentation/behoerden_screen.dart`

**Aufwand:** ~1h

---

## 🟠 Mittlere Priorität

### 4. Deutsche Begriffe statt Englisch

**Problem:** "Events" und "Profil" sind englisch

**Lösung:**
```dart
// In lib/src/core/constants/app_strings.dart

// Zeile 32 ändern:
static const String navEvents = 'Veranstaltungen';  // war: 'Events'

// In app_shell.dart - "Profil" zu "Einstellungen" ändern
// Mehrere Stellen (Desktop, Tablet, Mobile Navigation)
label: 'Einstellungen',  // war: 'Profil'
```

**Dateien zu ändern:**
- `lib/src/core/constants/app_strings.dart`
- `lib/src/core/shell/app_shell.dart`

**Aufwand:** ~15min

---

### 5. Barrierefreiheit-Hinweis auf Startseite

**Problem:** Accessibility-Einstellungen versteckt im Profil

**Lösung:**
Banner im Welcome-Overlay oder Discover-Screen:

```dart
// In welcome_overlay.dart oder discover_screen.dart

Widget _buildAccessibilityHint() {
  return Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: ListTile(
      leading: Icon(Icons.accessibility_new),
      title: Text('Barrierefreiheit'),
      subtitle: Text('Schriftgröße, Kontrast & mehr anpassen'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.push('/accessibility'),
    ),
  );
}
```

**Alternative:** Icon in der AppBar dauerhaft sichtbar

**Aufwand:** ~30min

---

### 6. Druckansicht für Informationen

**Problem:** Ältere Nutzer wollen Infos ausdrucken

**Lösung:**
```dart
// Dependency: printing (für PDF/Drucken)

// In Detail-Sheets einen Print-Button hinzufügen
IconButton(
  icon: Icon(Icons.print),
  tooltip: 'Drucken',
  onPressed: () => _printDetails(),
),

Future<void> _printDetails() async {
  await Printing.layoutPdf(
    onLayout: (format) => _buildPdf(format),
  );
}
```

**Neue Dependency:**
```yaml
# pubspec.yaml
dependencies:
  printing: ^5.12.0
```

**Aufwand:** ~3h (inkl. PDF-Layout)

---

### 7. Scroll-Indikatoren bei Filtern

**Problem:** Nicht erkennbar dass mehr Filter-Optionen existieren

**Lösung:**
```dart
// In category_quick_filter.dart

// Gradient-Overlay am rechten Rand hinzufügen
Stack(
  children: [
    ListView(
      scrollDirection: Axis.horizontal,
      // ... existing chips
    ),
    // Gradient-Fade am rechten Rand
    Positioned(
      right: 0,
      child: IgnorePointer(
        child: Container(
          width: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0),
                Colors.white,
              ],
            ),
          ),
        ),
      ),
    ),
  ],
)

// Optional: Scroll-Pfeil der verschwindet wenn am Ende
```

**Dateien zu ändern:**
- `lib/src/shared/widgets/category_quick_filter.dart`

**Aufwand:** ~45min

---

## 🟢 Niedrige Priorität

### 8. ÖPNV-Verbindung bei Events

**Problem:** Keine direkte Integration "Wie komme ich zum Konzert?"

**Lösung:**
Button in Event-Details der zur Mobility-Suche führt:

```dart
// In engagement_detail_sheet.dart

OutlinedButton.icon(
  onPressed: () {
    // Zur Mobility-Screen navigieren mit Ziel vorausgefüllt
    context.push('/mobility', extra: {
      'destination': LatLng(event.latitude, event.longitude),
      'destinationName': event.locationName,
    });
  },
  icon: Icon(Icons.directions_bus),
  label: Text('ÖPNV-Verbindung'),
),
```

**Aufwand:** ~1h

---

### 9. Standort-Erklärung verbessern

**Problem:** Meldung "Standortzugriff verweigert" nicht hilfreich

**Lösung:**
```dart
// Besserer Dialog mit Anleitung

void _showLocationDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.location_off, color: Colors.orange),
          SizedBox(width: 8),
          Text('Standort deaktiviert'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('So aktivierst du den Standort:'),
          SizedBox(height: 12),
          Text('1. Öffne die Browser-Einstellungen'),
          Text('2. Gehe zu "Website-Berechtigungen"'),
          Text('3. Erlaube Standortzugriff für msh-map.de'),
          SizedBox(height: 12),
          Text('Oder nutze die manuelle Ortssuche.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Verstanden'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            // Zur Ortssuche navigieren
          },
          child: Text('Ort manuell wählen'),
        ),
      ],
    ),
  );
}
```

**Aufwand:** ~30min

---

## Nicht im Scope (später)

Diese Punkte wurden im Feedback genannt, sind aber komplexer:

| Feature | Grund für Verschiebung |
|---------|----------------------|
| Login/Favoriten | Bereits geplant, eigenes Projekt |
| Öffnungszeiten ergänzen | Daten-Qualität, manueller Aufwand |
| Mehr Jugendzentren | Recherche nötig |
| Bewertungsfunktion | Backend-Infrastruktur nötig |
| Fitness-Einträge | Daten-Ergänzung |

---

## Implementierungs-Reihenfolge

### Sprint 1 (Quick Wins)
1. ✅ Deutsche Begriffe (~15min)
2. ✅ Teilen-Funktion Events (~30min)
3. ✅ Scroll-Indikatoren Filter (~45min)

### Sprint 2 (User Experience)
4. Auto-Complete Suche (~2h)
5. Barrierefreiheit-Hinweis (~30min)
6. Telefonnummern prüfen (~1h)

### Sprint 3 (Erweitert)
7. Standort-Erklärung (~30min)
8. ÖPNV bei Events (~1h)
9. Druckansicht (~3h)

---

## Geschätzter Gesamtaufwand

| Sprint | Zeit |
|--------|------|
| Sprint 1 | ~1.5h |
| Sprint 2 | ~3.5h |
| Sprint 3 | ~4.5h |
| **Gesamt** | **~9.5h** |

---

## Validierung nach Implementierung

- [ ] Suche: Autocomplete zeigt Vorschläge ab 2 Zeichen
- [ ] Events: Teilen-Button funktioniert (WhatsApp, SMS, etc.)
- [ ] Navigation: "Veranstaltungen" statt "Events"
- [ ] Navigation: "Einstellungen" statt "Profil"
- [ ] Filter: Scroll-Hinweis sichtbar
- [ ] Barrierefreiheit: Auf Startseite erwähnt
- [ ] Telefon: In allen Listen klickbar
- [ ] Standort: Hilfreiche Erklärung bei Ablehnung
