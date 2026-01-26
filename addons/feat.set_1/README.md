# MSH Map - Claude Code Prompts

## Übersicht

Diese Prompts sind für Claude Code in VS Code. Führe sie **nacheinander** aus.
Jeder Prompt baut auf dem vorherigen auf.

---

## Prompt-Reihenfolge

| # | Datei | Feature | Aufwand |
|---|-------|---------|---------|
| 1 | `PROMPT_01_FEATURE_FLAGS.md` | Feature-Flag System | 30 Min |
| 2 | `PROMPT_02_AGE_FILTER.md` | Altersgerechte Empfehlungen | 1-2 Std |
| 3 | `PROMPT_03_WEATHER.md` | Wetter-Integration (Open-Meteo) | 1 Std |
| 4 | `PROMPT_04_EVENTS.md` | Events auf Karte + Widget | 2 Std |
| 5 | `PROMPT_05_OEPNV_REPORT.md` | ÖPNV-Links + Problem melden | 1 Std |

**Gesamtaufwand:** ~6-8 Stunden (kann über mehrere Tage verteilt werden)

---

## So verwendest du die Prompts

### Schritt 1: Projekt öffnen
```bash
code /pfad/zu/msh_map
```

### Schritt 2: Claude Code starten
- In VS Code: Claude Code Extension öffnen
- Oder: Terminal → `claude`

### Schritt 3: Prompt einfügen
- Öffne `PROMPT_01_FEATURE_FLAGS.md`
- Kopiere den gesamten Inhalt
- Füge in Claude Code ein
- Warte bis Claude fertig ist

### Schritt 4: Testen
- App starten: `flutter run -d chrome`
- Feature testen
- Bei Problemen: Claude fragen

### Schritt 5: Nächster Prompt
- Weiter mit `PROMPT_02_AGE_FILTER.md`
- Und so weiter...

---

## Was jeder Prompt macht

### PROMPT 1: Feature-Flags
```
Erstellt:
├── lib/src/core/config/feature_flags.dart
├── lib/src/shared/widgets/feature_flag_wrapper.dart
└── README zur Verwendung

Ergebnis: Features können ein/ausgeschaltet werden
```

### PROMPT 2: Altersfilter
```
Erstellt:
├── lib/src/features/age_filter/domain/age_group.dart
├── lib/src/features/age_filter/application/age_filter_provider.dart
└── lib/src/features/age_filter/presentation/age_filter_chips.dart

Ergebnis: Chips über der Karte filtern nach Kinder-Alter
```

### PROMPT 3: Wetter
```
Erstellt:
├── lib/src/features/weather/domain/weather_model.dart
├── lib/src/features/weather/data/weather_repository.dart
├── lib/src/features/weather/application/weather_provider.dart
├── lib/src/features/weather/presentation/weather_widget.dart
└── lib/src/features/weather/presentation/weather_badge.dart

Ergebnis: Aktuelles Wetter + Indoor/Outdoor Empfehlung
```

### PROMPT 4: Events
```
Erstellt:
├── lib/src/features/events/domain/event_model.dart
├── lib/src/features/events/data/event_repository.dart
├── lib/src/features/events/application/event_provider.dart
├── lib/src/features/events/presentation/event_map_layer.dart
├── lib/src/features/events/presentation/upcoming_events_widget.dart
└── assets/data/events/events_current.json

Ergebnis: Events auf Karte + "Diese Woche" Widget
```

### PROMPT 5: ÖPNV + Problem melden
```
Erstellt:
├── lib/src/shared/widgets/public_transport_button.dart
├── lib/src/features/feedback/domain/issue_type.dart
└── lib/src/features/feedback/presentation/report_issue_sheet.dart

Ergebnis: ÖPNV-Link bei Orten + Anonymes Problem-Melden
```

---

## Nach allen Prompts

Deine App hat dann:

```
✅ Feature-Flag System (alles ein/ausschaltbar)
✅ Altersfilter (👶 0-2, 🧒 3-5, 👦 6-11, 🧑 12+)
✅ Wetter-Widget (Open-Meteo, DSGVO-konform)
✅ Indoor/Outdoor Empfehlung
✅ Events auf der Karte (farbige Marker)
✅ "Diese Woche" Events-Widget
✅ ÖPNV-Links (zu INSA)
✅ Problem melden (anonym per E-Mail)
```

---

## Abhängigkeiten

Diese Packages werden benötigt (die Prompts fügen sie hinzu):

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.4.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  http: ^1.1.0
  url_launcher: ^6.2.0
  flutter_map: ^6.0.0
  latlong2: ^0.9.0

dev_dependencies:
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  build_runner: ^2.4.0
```

Nach Änderungen an Models:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Tipps

### Bei Fehlern
- Lies die Fehlermeldung genau
- Kopiere sie zu Claude Code
- Claude kann meist selbst fixen

### Bei Unklarheiten
- Frag Claude: "Was macht dieser Code?"
- Oder: "Wie teste ich das?"

### Zum Testen
```bash
# Web
flutter run -d chrome --web-port=8080

# Analyzer
flutter analyze

# Tests (falls vorhanden)
flutter test
```

### Feature deaktivieren
```dart
// In feature_flags.dart:
static const bool enableWeather = false;  // ← Ausschalten
```

---

## Nächste Schritte (später)

Nach V1.1 kannst du weitere Prompts für V1.2 erstellen:

- PROMPT_06: Offline-Karten
- PROMPT_07: Naturschutzgebiete Layer
- PROMPT_08: E-Ladesäulen
- PROMPT_09: Prognose "Wird es voll?"

---

## Hilfe

Bei Problemen:
1. Claude Code fragen
2. Flutter Docs: https://docs.flutter.dev
3. Riverpod Docs: https://riverpod.dev

---

**Viel Erfolg! 🚀**
