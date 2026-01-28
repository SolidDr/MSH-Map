# MSH Map - Kunden-Review Bugfix

## 🚨 WICHTIG - LESEN BEVOR DU ANFÄNGST

> **Es dürfen KEINE Dummy-, Mockup- oder Fake-Daten in der Anwendung sein!**
> 
> Besonders bei Gesundheitsdaten (Ärzte, Apotheken, AEDs, Warnstellen) ist 100% Genauigkeit PFLICHT.
> Diese Informationen können lebensrettend sein!

---

## Übersicht der Probleme

### 🔴 KRITISCH - Falsche/Fake Daten
| Problem | Prompt |
|---------|--------|
| "Lochness" Dummy-Eintrag | Prompt 1 |
| "Sus Pup" existiert nicht mehr | Prompt 1 |
| Mammut Apotheke - falscher Pin | Prompt 2 |
| Barbarossa Apotheke - falscher Pin | Prompt 2 |
| Tierheim - falscher Pin | Prompt 2 |
| Tafel - falscher Pin | Prompt 2 |
| Behörden komplett falsch (nicht MSH) | Prompt 3 |
| Viele tote Website-Links | Prompt 3 |

### 🟠 HOCH - Funktionen kaputt
| Problem | Prompt |
|---------|--------|
| Altersfilter funktioniert nicht | Prompt 4 |
| Suche unter Entdecken inaktiv | Prompt 4 |
| Schwimmhallen unter Fitness (falsch) | Prompt 4 |
| Kategorie Bauernhof leer | Prompt 4 |
| Harzer Wandernadel nicht auswählbar | Prompt 4 |

### 🟡 MITTEL - UI/UX Probleme
| Problem | Prompt |
|---------|--------|
| Warnbanner zu groß | Prompt 5 |
| Mobile: Untere Symbolleiste weg | Prompt 5 |
| Entdecken nicht sortiert | Prompt 4 |
| Radweg Disclaimer fehlt | Prompt 4 |
| Standardeinstellung Filter falsch | Prompt 4 |

---

## 6 Prompts - Reihenfolge

```
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 1: Dummy/Fake-Daten ENTFERNEN                       │
│  ⏱️ 2-3 Stunden | 🔴 KRITISCH                                │
│  → Lochness, Sus Pup, alle Fake-Daten finden und löschen   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 2: Geodaten KORRIGIEREN                             │
│  ⏱️ 2-3 Stunden | 🔴 KRITISCH                                │
│  → Apotheken-Pins, Tierheim, Tafel korrigieren             │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 3: Behörden NEU + Dead Links                        │
│  ⏱️ 4-5 Stunden | 🔴 KRITISCH                                │
│  → Alle falschen Behörden raus, MSH-Behörden rein          │
│  → Alle toten Links finden und entfernen                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 4: Kategorien & Filter                              │
│  ⏱️ 2-3 Stunden | 🟠 HOCH                                    │
│  → Schwimmen/Sport, Bauernhof, Wandernadel                 │
│  → Altersfilter, Standardeinstellung, Sortierung           │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 5: UI/UX Fixes                                      │
│  ⏱️ 2-3 Stunden | 🟡 MITTEL                                  │
│  → Warnbanner verkleinern                                  │
│  → Mobile Menü umbauen                                     │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PROMPT 6: QUALITÄTSSICHERUNG                               │
│  ⏱️ 3-4 Stunden | 🔴 PFLICHT                                 │
│  → Vollständiger Audit ALLER Daten                         │
│  → Automatische + Manuelle Prüfung                         │
│  → Sign-Off vor Release                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Dateien in diesem Ordner

| Datei | Beschreibung |
|-------|--------------|
| `ANALYSE.md` | Detaillierte Fehler-Analyse |
| `prompt_1_dummy_daten_entfernen.md` | Alle Fake-Daten finden & löschen |
| `prompt_2_geodaten_korrigieren.md` | Falsche Pins korrigieren |
| `prompt_3_behoerden_links.md` | Behörden neu + Dead Links |
| `prompt_4_kategorien_filter.md` | Kategorien & Filter fixen |
| `prompt_5_ui_ux.md` | Warnbanner & Mobile Menü |
| `prompt_6_qualitaetssicherung.md` | Finaler Audit & Sign-Off |

---

## Arbeitsweise

### Für jeden Prompt:

1. **Prompt-Datei öffnen** und komplett lesen
2. **Analyse durchführen** wie beschrieben
3. **Änderungen implementieren**
4. **Testen** nach jedem Fix
5. **Checkliste abhaken**
6. **Dokumentieren** was geändert wurde
7. **Commit** mit aussagekräftiger Message

### Git Workflow

```bash
# Vor Start: Feature-Branch erstellen
git checkout -b fix/customer-review-v2

# Nach jedem Prompt: Commit
git add .
git commit -m "fix: Prompt X - [Beschreibung]"

# Am Ende: PR erstellen
git push origin fix/customer-review-v2
```

---

## Erfolgskriterien

Nach Abschluss ALLER Prompts muss gelten:

```
✅ 0 Dummy-Einträge (Lochness, etc.)
✅ 0 nicht existierende Orte (Sus Pup, etc.)
✅ 0 falsche Pin-Positionen (Apotheken, etc.)
✅ 0 nicht-MSH Behörden
✅ 0 tote Links
✅ Alle Filter funktionieren
✅ Alle Kategorien korrekt zugeordnet
✅ Warnbanner kompakt
✅ Mobile Menü neu strukturiert
✅ Automatischer Audit besteht
```

---

## Zeitschätzung

| Prompt | Geschätzt | Tatsächlich |
|--------|-----------|-------------|
| 1 - Dummy-Daten | 2-3h | _____ |
| 2 - Geodaten | 2-3h | _____ |
| 3 - Behörden/Links | 4-5h | _____ |
| 4 - Kategorien/Filter | 2-3h | _____ |
| 5 - UI/UX | 2-3h | _____ |
| 6 - QA | 3-4h | _____ |
| **GESAMT** | **15-21h** | _____ |

---

## ⚠️ Wichtige Hinweise

1. **Reihenfolge einhalten!** Prompt 1-3 sind Voraussetzung für alles andere.

2. **Nicht überspringen!** Auch wenn etwas trivial erscheint.

3. **Immer verifizieren!** Google Maps, offizielle Websites, etc.

4. **Bei Unsicherheit: LÖSCHEN!** Lieber später mit verifizierten Daten ergänzen.

5. **Prompt 6 ist PFLICHT!** Ohne bestandenen Audit kein Release.

---

## Los geht's!

Öffne jetzt `prompt_1_dummy_daten_entfernen.md` und starte mit der Säuberung.

**Viel Erfolg! 💪**
