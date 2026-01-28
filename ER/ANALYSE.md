# MSH Map - Kunden-Review Bugfix Analyse

## 🚨 KRITISCHE WARNUNG

> **Es dürfen KEINE Dummy-, Mockup- oder Fake-Daten mehr in der Anwendung sein!**
> 
> Besonders bei: Ärzten, Apotheken, AEDs und Warnstellen.
> Diese Informationen können lebensrettend sein - 100% Genauigkeit ist Pflicht!

---

## Situationsanalyse

### Kategorisierung der gefundenen Fehler

| Kategorie | Anzahl | Kritikalität |
|-----------|--------|--------------|
| 🔴 **Falsche Geodaten** (Pins am falschen Ort) | 3 | KRITISCH |
| 🔴 **Dummy/Fake-Daten** | 2+ | KRITISCH |
| 🔴 **Falsche Behörden-Daten** | 1 (komplett) | KRITISCH |
| 🟠 **Tote Links** | Viele | HOCH |
| 🟠 **Nicht existierende Orte** | 2 | HOCH |
| 🟠 **Falsche Kategorisierung** | 3 | HOCH |
| 🟡 **UI/UX Probleme** | 5 | MITTEL |
| 🟡 **Fehlende Features** | 3 | MITTEL |

---

## Detaillierte Fehler-Liste

### 🔴 KRITISCH - Sofort beheben

| # | Problem | Details | Risiko |
|---|---------|---------|--------|
| K1 | **Mammut Apotheke - falscher Pin** | Wird an völlig falschem Ort angezeigt | Gesundheitsgefahr |
| K2 | **Barbarossa Apotheke - falscher Pin** | Pin-Position falsch | Gesundheitsgefahr |
| K3 | **Tierheim/Tafel - falscher Pin** | Pin falsch, "aufblinken" Problem | Falsche Info |
| K4 | **Lochness Eintrag** | DUMMY-Daten noch vorhanden! | Vertrauensverlust |
| K5 | **Sus Pup** | Existiert nicht mehr, noch gelistet | Falsche Info |
| K6 | **Behörden komplett falsch** | MSH-Behörden fehlen, fremde Landkreise drin | Komplett falsch |

### 🟠 HOCH - Diese Woche

| # | Problem | Details |
|---|---------|---------|
| H1 | **Website-Links tot** | Viele Dead-End Links |
| H2 | **Schwimmhallen unter Fitness** | Sollte unter "Sport" oder "Schwimmen" |
| H3 | **Kategorie Bauernhof leer** | Keine Einträge vorhanden |
| H4 | **Altersfilter Familie/Kinder** | Funktioniert nicht, keine Ergebnisse |
| H5 | **Suche unter Entdecken inaktiv** | Suchfunktion deaktiviert |

### 🟡 MITTEL - Nächste Woche

| # | Problem | Details |
|---|---------|---------|
| M1 | **Entdecken nicht sortiert** | Alphabetisch + nach Orten sortieren |
| M2 | **Radweg Disclaimer fehlt** | "Vorhanden" vs "Geplant" anzeigen |
| M3 | **Harzer Wandernadel** | Muss als Kategorie auswählbar sein |
| M4 | **Warnbanner zu groß** | Auf 1/3 reduzieren |
| M5 | **Standardeinstellung Filter** | Nur Radwege an, Rest aus |
| M6 | **Mobile: Untere Symbolleiste** | Entfernen, in Suchleiste integrieren |

---

## Lösungsplan - 6 Prompt-Blöcke

```
PHASE 1: Daten-Säuberung (Prompt 1-2)
├── Prompt 1: Dummy/Fake-Daten entfernen (ENDGÜLTIG)
└── Prompt 2: Geodaten korrigieren (Apotheken, Pins)

PHASE 2: Daten-Korrektur (Prompt 3)
└── Prompt 3: Behörden komplett neu + Links prüfen

PHASE 3: Kategorien & Filter (Prompt 4)
└── Prompt 4: Kategorien bereinigen + Filter fixen

PHASE 4: UI/UX Fixes (Prompt 5)
└── Prompt 5: Warnbanner, Mobile UI, Sortierung

PHASE 5: Qualitätssicherung (Prompt 6)
└── Prompt 6: Vollständiger Daten-Audit + Verifizierung
```

---

## Betroffene Datensätze zur Prüfung

### Apotheken (100% Genauigkeit erforderlich)
- [ ] Mammut Apotheke - Koordinaten prüfen
- [ ] Barbarossa Apotheke - Koordinaten prüfen
- [ ] ALLE anderen Apotheken verifizieren

### Behörden (Komplett neu erstellen)
**ENTFERNEN (gehören nicht zu MSH):**
- Bad Frankenhausen
- Uhrbach
- Harzgerode
- Kyffhäuser
- Nordhausen
- Artern
- Sondershausen
- Osleben

**HINZUFÜGEN (MSH-Behörden):**
- Gemeinde Südharz
- Stadt Sangerhausen
- Stadt Eisleben
- Stadt Hettstedt
- Stadt Mansfeld
- Landkreis Mansfeld-Südharz
- [Alle weiteren MSH-Gemeinden]

### Zu löschende Einträge
- [ ] "Lochness" - DUMMY
- [ ] "Sus Pup" - Existiert nicht mehr

---

## Zeitschätzung

| Phase | Prompt | Geschätzte Zeit |
|-------|--------|-----------------|
| 1 | Dummy-Daten Säuberung | 2-3 Stunden |
| 1 | Geodaten Korrektur | 2-3 Stunden |
| 2 | Behörden + Links | 4-5 Stunden |
| 3 | Kategorien + Filter | 2-3 Stunden |
| 4 | UI/UX Fixes | 2-3 Stunden |
| 5 | Qualitätssicherung | 3-4 Stunden |
| **Gesamt** | | **15-21 Stunden** |

---

## Erfolgskriterien

Nach Abschluss MUSS gelten:

- [ ] 0 Dummy-Daten in der gesamten Anwendung
- [ ] 0 Mockup-Einträge
- [ ] 0 falsche Pin-Positionen bei Apotheken/Ärzten/AEDs
- [ ] 0 tote Website-Links
- [ ] Nur MSH-Behörden in der Liste
- [ ] Alle Filter funktionieren korrekt
- [ ] Jeder Eintrag ist verifiziert
