# MSH Map - Feedback Runde 3 - Bugfix Prompts

## 🎯 Übersicht

Dieses Paket enthält 5 Prompt-Blöcke zur Behebung der Probleme aus dem dritten Kunden-Feedback.

---

## Referenz-Dokument

Die Datei **methods_claude.md** beschreibt wie Daten erfasst und verarbeitet werden:
- OSM-Extraktion für Locations
- arzt-auskunft.de für Ärzte
- GPX-Tracks für Radwege
- Datenstrukturen (JSON, Dart)

**Bei allen Änderungen diese Methodik befolgen!**

---

## Die 5 Prompts

```
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 1: Fehlende Gesundheitsdaten ergänzen               │
│  ⏱️ 3-4 Stunden | 🔴 KRITISCH                                │
│  → Fehlende Ärzte & Apotheken (Michael Zastava, Kyffhäuser) │
│  → AEDs mit Ortsangaben versehen                            │
│  → Krankenhäuser vollständig?                               │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 2: Pin-Koordinaten korrigieren                      │
│  ⏱️ 2-3 Stunden | 🔴 KRITISCH                                │
│  → Dr. Anaja Ehrke - Pin falsch positioniert                │
│  → Alle Gesundheits-Pins systematisch prüfen                │
│  → Koordinaten-Validierungs-Script                          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 3: Radwege korrigieren                              │
│  ⏱️ 2-3 Stunden | 🔴 KRITISCH                                │
│  → Kupferspurenradweg KOMPLETT NEU (völlig falsch!)         │
│  → Alle anderen Radwege kontrollieren                       │
│  → GPX-Import / OSM-Daten nutzen                            │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 4: Karten-Features                                  │
│  ⏱️ 2 Stunden | 🟠 HOCH                                      │
│  → Trackpad-Zoom aktivieren (scroll wheel)                  │
│  → Zoom +/- Buttons hinzufügen                              │
│  → Kompass/Ausnorden Button hinzufügen                      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 5: Filter, UI & Daten-Sync                          │
│  ⏱️ 2 Stunden | 🟠 HOCH                                      │
│  → Default-Filter: NUR Radwege + Gesundheit                 │
│  → Krankenhäuser-Filter hinzufügen                          │
│  → Unterkategorien klickbar machen                          │
│  → Entdecken-Einträge ohne Pin fixen                        │
│  → "Touren" → "Rad/Wege" umbenennen                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Problemliste (Alle Punkte)

| # | Problem | Prompt | Status |
|---|---------|--------|--------|
| 1 | Filter-Bug (Standard: Radwege + Gesundheit) | 5 | ⬜ |
| 2 | Trackpad-Zoom geht nicht | 4 | ⬜ |
| 3 | Fehlende Ärzte (Michael Zastava) | 1 | ⬜ |
| 4 | Click-to-Zoom Button fehlt | 4 | ⬜ |
| 5 | Entdecken-Einträge ohne Karten-Pin | 5 | ⬜ |
| 6 | Falsche Arzt-Pins (Dr. Anaja Ehrke) | 2 | ⬜ |
| 7 | Fehlende Apotheken (Kyffhäuser) | 1 | ⬜ |
| 8 | AED ohne Ortsangaben | 1 | ⬜ |
| 9 | Krankenhäuser-Filter fehlt | 5 | ⬜ |
| 10 | Unterkategorien nicht klickbar | 5 | ⬜ |
| 11 | Mobile: "Touren" → "Rad/Wege" | 5 | ⬜ |
| 12 | Ausnorden-Button fehlt | 4 | ⬜ |
| 13 | Kupferspurenradweg völlig falsch | 3 | ⬜ |
| 14 | Andere Radwege kontrollieren | 3 | ⬜ |

---

## Dateien die angepasst werden

### Daten-Dateien
```
assets/data/health/
├── doctors.json          → Prompt 1, 2
├── pharmacies.json       → Prompt 1, 2
├── hospitals.json        → Prompt 1
├── aeds.json             → Prompt 1

assets/data/
├── locations.json        → Prompt 5 (Sync)
```

### Radweg-Dateien
```
lib/src/modules/radwege/data/routes/
├── kupferspuren_route.dart  → Prompt 3 (KOMPLETT NEU!)
├── [andere]_route.dart      → Prompt 3 (Prüfen)
```

### Code-Dateien
```
lib/src/modules/
├── map/
│   ├── map_screen.dart      → Prompt 4 (Zoom, Kompass)
│   └── map_options.dart     → Prompt 4 (Trackpad)
├── filter/
│   └── filter_state.dart    → Prompt 5 (Default)
├── health/
│   └── health_categories.dart → Prompt 5 (Krankenhäuser)
└── navigation/
    └── mobile_menu.dart     → Prompt 5 (Touren → Rad/Wege)
```

---

## Prioritäts-Reihenfolge

**Tag 1:**
1. ✅ Prompt 1: Fehlende Gesundheitsdaten (wichtig für Nutzer)
2. ✅ Prompt 2: Falsche Pins korrigieren (Vertrauen!)

**Tag 2:**
3. ✅ Prompt 3: Kupferspurenradweg neu (kritischer Fehler)

**Tag 3:**
4. ✅ Prompt 4: Karten-Features (UX Verbesserung)
5. ✅ Prompt 5: Filter & UI (kleinere Fixes)

---

## Qualitätssicherung

Nach JEDEM Prompt:

```
[ ] Änderungen getestet
[ ] Keine Regression (alte Features funktionieren noch)
[ ] Code committed mit aussagekräftiger Message
```

Nach ALLEN Prompts:

```
[ ] Vollständiger App-Test auf Desktop
[ ] Vollständiger App-Test auf Mobile
[ ] Alle 14 Punkte aus der Liste als erledigt markiert
```

---

## Zeitschätzung

| Prompt | Geschätzt |
|--------|-----------|
| 1 - Gesundheitsdaten | 3-4h |
| 2 - Koordinaten | 2-3h |
| 3 - Radwege | 2-3h |
| 4 - Karten-Features | 2h |
| 5 - Filter & UI | 2h |
| **Gesamt** | **11-14h** |

---

## Los geht's!

Starte mit **prompt_1_fehlende_gesundheitsdaten.md**

Die methods_claude.md gibt dir den Kontext wie die Daten strukturiert sind.

**Viel Erfolg! 💪**
