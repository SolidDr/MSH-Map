# 03 - Phase A: Infrastructure

## Ziel
Neue Ordnerstruktur + Kern-Interfaces erstellen, OHNE bestehenden Code zu brechen.

---

## Schritt A1: Ordner anlegen

```bash
# Führe diese Befehle aus:
mkdir -p lib/src/core/config
mkdir -p lib/src/core/router
mkdir -p lib/src/shared/domain
mkdir -p lib/src/shared/data
mkdir -p lib/src/shared/widgets
mkdir -p lib/src/modules/gastro/domain
mkdir -p lib/src/modules/gastro/data
mkdir -p lib/src/modules/gastro/presentation/menu_upload
mkdir -p lib/src/modules/gastro/providers
mkdir -p lib/src/modules/events/domain
mkdir -p lib/src/modules/search/domain
mkdir -p lib/src/features/auth/data
mkdir -p lib/src/features/auth/domain
mkdir -p lib/src/features/auth/presentation
mkdir -p lib/_deprecated
```

**Checkpoint:** `✅ A1 - Ordnerstruktur erstellt`

---

## Schritt A2: Shared Domain erstellen

Erstelle diese 3 Dateien (Code aus `02_CORE_INTERFACES.md`):

1. `lib/src/shared/domain/coordinates.dart`
2. `lib/src/shared/domain/bounding_box.dart`
3. `lib/src/shared/domain/map_item.dart`

**Checkpoint:** `✅ A2 - Shared Domain erstellt`

---

## Schritt A3: Module Registry erstellen

Erstelle `lib/src/modules/_module_registry.dart`
(Code aus `02_CORE_INTERFACES.md`, Abschnitt 2.4)

**Checkpoint:** `✅ A3 - Module Registry erstellt`

---

## Schritt A4: Map Config erstellen

Erstelle `lib/src/core/config/map_config.dart`
(Code aus `02_CORE_INTERFACES.md`, Abschnitt 2.5)

**Checkpoint:** `✅ A4 - Map Config erstellt`

---

## Schritt A5: Validierung

```bash
flutter analyze
```

**Erwartetes Ergebnis:** 0 errors (warnings sind OK)

**Checkpoint:** `✅ A5 - Phase A validiert`

---

## Phase A Checkliste

```markdown
## PHASE A CHECKLIST:
- [ ] A1: Ordnerstruktur existiert
- [ ] A2: coordinates.dart kompiliert
- [ ] A2: bounding_box.dart kompiliert
- [ ] A2: map_item.dart kompiliert
- [ ] A3: _module_registry.dart kompiliert
- [ ] A4: map_config.dart kompiliert
- [ ] A5: `flutter analyze` = 0 errors
- [ ] Alte Dateien UNVERÄNDERT
```

---

## Bei Fehlern

1. Fehler in Checkpoint dokumentieren
2. Import-Pfade prüfen
3. Auf Anweisung warten

**WEITER MIT:** `04_PHASE_B_MAP_WIDGETS.md`