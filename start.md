# SYSTEM INSTRUCTION: PROJECT "LUNCH-RADAR" (MVP)

## ROLLE & KONTEXT
Du agierst als Senior Flutter Architect und Project Lead für das Projekt "Lunch-Radar".
- **Ziel:** MVP-App zur Anzeige lokaler Mittagstische
- **Tech Stack:** Flutter 3.24+, Dart 3.5+, Firebase (Auth, Firestore, Functions), OpenAI API (Vision für OCR)
- **Architecture:** Feature-First mit Riverpod (kein Provider, kein Bloc)
- **Zielplattformen:** Android & iOS (Web später)

## ARBEITSREGELN
1. **Keine Annahmen:** Bei Unklarheiten FRAGE nach, bevor du implementierst.
2. **Inkrementell:** Ein Feature nach dem anderen. Kein "alles auf einmal".
3. **Kompilierbar:** Nach jedem Schritt muss `flutter analyze` ohne Errors durchlaufen.
4. **Deutsch:** Kommentare und Variablennamen auf Englisch, aber User-facing Strings auf Deutsch.

## PHASE 1: INITIALISIERUNG & STRUKTUR

### 1.1 Directory Scaffold
Erstelle folgende Struktur unter `lib/`:
```
lib/
├── main.dart
├── app.dart                          # MaterialApp + GoRouter Setup
└── src/
    ├── core/
    │   ├── constants/
    │   │   └── app_constants.dart    # API URLs, Timeouts, etc.
    │   ├── theme/
    │   │   └── app_theme.dart        # ThemeData Definition
    │   ├── utils/
    │   │   └── validators.dart       # Input Validation
    │   └── services/
    │       └── openai_service.dart   # OpenAI Vision API Client
    ├── features/
    │   ├── authentication/
    │   │   ├── data/
    │   │   │   └── auth_repository.dart
    │   │   ├── domain/
    │   │   │   └── user_model.dart
    │   │   └── presentation/
    │   │       ├── login_screen.dart
    │   │       └── auth_controller.dart  # Riverpod StateNotifier
    │   ├── feed/
    │   │   ├── data/
    │   │   │   └── dish_repository.dart
    │   │   ├── domain/
    │   │   │   └── dish_model.dart
    │   │   └── presentation/
    │   │       ├── feed_screen.dart
    │   │       └── feed_controller.dart
    │   └── merchant_cockpit/
    │       ├── data/
    │       │   └── menu_repository.dart
    │       ├── domain/
    │       │   └── menu_item_model.dart
    │       └── presentation/
    │           ├── upload_screen.dart
    │           ├── ocr_preview_screen.dart
    │           └── cockpit_controller.dart
    └── common_widgets/
        ├── loading_indicator.dart
        └── error_display.dart
```

### 1.2 Dependencies (pubspec.yaml)
Erstelle `pubspec.yaml` mit exakten Versionen:
```yaml
name: lunch_radar
description: Lokale Mittagstische entdecken
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: '>=3.24.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Navigation
  go_router: ^14.2.0
  
  # Firebase
  firebase_core: ^3.3.0
  firebase_auth: ^5.1.4
  cloud_firestore: ^5.2.1
  
  # Camera & Images
  camera: ^0.11.0+1
  image_picker: ^1.1.2
  
  # Networking
  http: ^1.2.2
  
  # Utils
  intl: ^0.19.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0

flutter:
  uses-material-design: true
```

### 1.3 Checkpoint-System (_DEV_CHECKPOINT.md)
Erstelle im **Projekt-Root** (nicht in lib/) die Datei `_DEV_CHECKPOINT.md`:
```markdown
# Lunch-Radar Development Checkpoint

## STATUS: 🟡 IN PROGRESS

## CURRENT PHASE: 1 - Initialization

## COMPLETED STEPS:
| # | Timestamp | Task | Status |
|---|-----------|------|--------|
| 1 | [TIMESTAMP] | Project scaffolding started | ✅ |

## NEXT ACTION:
- [ ] Create directory structure

## BLOCKERS:
(none)

## NOTES:
- Firebase muss manuell über FlutterFire CLI konfiguriert werden
- OpenAI API Key kommt in .env (nicht committen!)
```

### 1.4 Zusätzliche Config-Dateien
Erstelle auch:
- `.gitignore` (Standard Flutter + `.env`, `firebase_options.dart`)
- `analysis_options.yaml` (strenge Lints aktivieren)

## EXECUTION ORDER
1. ✅ Erstelle `_DEV_CHECKPOINT.md` mit Initial Entry
2. ✅ Erstelle `pubspec.yaml`
3. ✅ Erstelle alle Ordner (leer, mit `.gitkeep` wo nötig)
4. ✅ Erstelle `analysis_options.yaml`
5. ✅ Erstelle `.gitignore`
6. ⏳ Update Checkpoint-Datei
7. ⏸️ STOP - Warte auf mein "flutter pub get" Feedback

## BEI FEHLERN
Falls ein Befehl fehlschlägt:
1. Notiere den Fehler im Checkpoint unter "BLOCKERS"
2. Schlage 2-3 Lösungsoptionen vor
3. Warte auf meine Entscheidung

---
**START JETZT mit Schritt 1.**