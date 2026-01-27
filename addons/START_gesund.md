# MSH Map Analytics - Bugfix-Plan

## Übersicht der Testergebnisse

| # | Problem | Priorität | Status | Prompt-Datei |
|---|---------|-----------|--------|--------------|
| 1 | Familie/Gastro Filter funktionieren nicht | 🔴 Kritisch | ❌ | `prompt_1_filter_fix.md` |
| 2 | Suchfunktion ohne Auto-Vervollständigung | 🔴 Kritisch | ❌ | `prompt_2_search_autocomplete.md` |
| 3 | Bewertungen nicht sichtbar | 🔴 Kritisch | ❌ | `prompt_3_bewertungen.md` |
| 4 | Heatmap-Visualisierung fehlt | 🟡 Mittel | ⚠️ | `prompt_4_heatmap.md` |
| 5 | UI/UX Polish (Mobile Menü + Warnung) | 🟢 Niedrig | ⚠️ | `prompt_5_ui_polish.md` |
| 6 | **NEU:** Gesundheit & Fitness Addon | 🟡 Feature | 🆕 | `prompt_6_gesundheit_addon.md` |

---

## Reihenfolge der Bearbeitung

```
START
  │
  ├─► Prompt 1: Familie/Gastro Filter
  │      └─► Teste Filter auf Mobile + Desktop
  │
  ├─► Prompt 2: Such-Autocomplete  
  │      └─► Teste Dropdown + Keyboard-Navigation
  │
  ├─► Prompt 3: Bewertungen
  │      └─► Teste Anzeige in Ort-Details
  │
  ├─► Prompt 4: Heatmap
  │      └─► Teste Layer-Toggle + Visualisierung
  │
  └─► Prompt 5: UI/UX Polish
         └─► Teste Mobile Menü + Warnung-Position
  │
FERTIG → Finaler Test aller Funktionen
```

---

## Vor dem Start

### Checkliste für Claude Code:
- [ ] Projekt-Ordner identifiziert
- [ ] Bestehende Dateistruktur verstanden
- [ ] Datenbank/API-Struktur bekannt
- [ ] Kann lokaler Dev-Server gestartet werden?

### Wichtige Fragen vorab:
1. Wo liegen die Filter-Komponenten? (für Prompt 1)
2. Welche Datenbank wird genutzt? (für Prompt 2 + 3)
3. Existieren Bewertungs-Daten bereits? (für Prompt 3)
4. Welche Map-Library wird verwendet? (für Prompt 4)

---

## Arbeitsweise pro Prompt

1. **Lies den Prompt komplett**
2. **Analysiere den bestehenden Code** - nicht blind drauflos
3. **Erstelle kurzen Plan** bevor du änderst
4. **Implementiere schrittweise** mit Tests
5. **Dokumentiere Änderungen** kurz am Ende

---

## Nach Abschluss aller Prompts

Führe einen vollständigen Regressionstest durch:
- [ ] Alle ✅ Features funktionieren noch
- [ ] Alle ❌ Features sind jetzt ✅
- [ ] Mobile + Desktop getestet
- [ ] Keine neuen Fehler eingeführt

---

## Dateien in diesem Paket

```
/bugfix-prompts/
├── START.md                        ← Diese Datei (Übersicht)
├── prompt_1_filter_fix.md          ← Familie/Gastro Filter
├── prompt_2_search_autocomplete.md ← Such-Autocomplete
├── prompt_3_bewertungen.md         ← Bewertungen anzeigen
├── prompt_4_heatmap.md             ← Heatmap-Visualisierung
├── prompt_5_ui_polish.md           ← UI/UX Verbesserungen
└── prompt_6_gesundheit_addon.md    ← Gesundheit & Fitness (NEU)
```

---

**Starte mit:** `prompt_1_filter_fix.md`
