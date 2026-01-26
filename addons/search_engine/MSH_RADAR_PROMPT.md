# MSH RADAR - Wöchentlicher Update-Scan

## START

Du führst jetzt den wöchentlichen MSH Radar Scan durch.

**Geschätzte Dauer:** 20-30 Minuten
**Der Nutzer macht Pause** - arbeite selbstständig und gründlich.

---

## SCHRITT 1: Projekt-Status prüfen (1 Min)

```bash
cd /pfad/zu/msh_map
git status
```

Prüfe:
- Welche KW haben wir?
- Wann war der letzte Scan? (check reports/ Ordner)

---

## SCHRITT 2: Veranstaltungen recherchieren (15 Min)

### Quellen durchsuchen

Öffne nacheinander diese Quellen und sammle Events für die **nächsten 14 Tage**:

#### 2.1 MZ Veranstaltungskalender
```
URL: https://www.mz.de/leben/veranstaltungen
Filter: Region Mansfeld-Südharz / Sangerhausen / Eisleben
```

#### 2.2 Sangerhausen.de
```
URL: https://www.sangerhausen.de
Suche: Veranstaltungen, Termine, Aktuelles
```

#### 2.3 Lutherstadt Eisleben
```
URL: https://www.eisleben.eu
URL: https://www.luthermuseen.de/veranstaltungen
```

#### 2.4 Südharz Tourismus
```
URL: https://www.suedharz-tourismus.de
Suche: Veranstaltungen, Events
```

#### 2.5 Harz Info
```
URL: https://www.harzinfo.de/erlebnisse/veranstaltungen
Filter: Mansfeld-Südharz
```

#### 2.6 Kyffhäuser Region
```
URL: https://www.kyffhaeuser-tourismus.de
```

### Für jedes Event erfasse:

```json
{
  "id": "evt_20250125_001",
  "name": "Name der Veranstaltung",
  "date": "2025-01-25",
  "time_start": "19:00",
  "time_end": "22:00",
  "location_name": "Veranstaltungsort",
  "latitude": 51.4698,
  "longitude": 11.2978,
  "city": "Sangerhausen",
  "category": "konzert",
  "description": "Kurzbeschreibung (max 200 Zeichen)",
  "price": "kostenlos",
  "source_url": "https://...",
  "tags": ["musik", "kultur"]
}
```

**Kategorien:**
- `konzert` - Musik, Konzerte
- `markt` - Wochenmärkte, Flohmärkte, Weihnachtsmärkte
- `theater` - Theater, Kabarett, Lesungen
- `sport` - Sportveranstaltungen
- `kinder` - Kinderveranstaltungen, Familien-Events
- `fest` - Volksfeste, Stadtfeste, Feiern
- `fuehrung` - Führungen, Wanderungen
- `ausstellung` - Ausstellungen, Museen
- `sonstiges` - Alles andere

**Koordinaten finden:**
- Google Maps: Rechtsklick → "Was ist hier?" → Koordinaten kopieren
- Oder: Bekannte Orte aus der locations-Datenbank verwenden

---

## SCHRITT 3: Hinweise & Meldungen prüfen (5 Min)

Suche nach:

### 3.1 Straßensperrungen
```
Suche: "[Stadt] Straßensperrung" oder "[Stadt] Baustelle"
Quellen: Gemeinde-Websites, MZ Lokalnachrichten
```

### 3.2 Sonderöffnungszeiten
```
Prüfe die Top-Orte:
- Europa-Rosarium (Winterpause? Sonderöffnung?)
- Lutherhäuser
- Kyffhäuser-Denkmal
- Museen
```

### 3.3 Wichtige Meldungen
```
Suche: "Sangerhausen aktuell", "Eisleben News"
Was ist relevant für Besucher?
```

### Erfasse als:

```json
{
  "id": "notice_001",
  "type": "sperrung|oeffnungszeit|warnung|info",
  "title": "Kurztitel",
  "description": "Details...",
  "affected_area": "Sangerhausen Zentrum",
  "valid_from": "2025-01-20",
  "valid_until": "2025-01-25",
  "severity": "info|warning|critical",
  "source_url": "https://..."
}
```

---

## SCHRITT 4: Daten zusammenführen (3 Min)

### 4.1 Events-Datei erstellen/aktualisieren

Erstelle `data/events/events_current.json`:

```json
{
  "meta": {
    "generated_at": "2025-01-20T10:30:00Z",
    "generated_by": "MSH Radar",
    "valid_from": "2025-01-20",
    "valid_until": "2025-02-03",
    "kw": 4
  },
  "stats": {
    "total_events": 23,
    "by_category": {
      "konzert": 5,
      "markt": 3,
      "theater": 2,
      "kinder": 4,
      "fuehrung": 3,
      "sonstiges": 6
    },
    "by_city": {
      "Sangerhausen": 8,
      "Lutherstadt Eisleben": 7,
      "Hettstedt": 3,
      "Sonstige": 5
    }
  },
  "events": [
    // Alle Events hier, sortiert nach Datum
  ]
}
```

### 4.2 Hinweise-Datei erstellen/aktualisieren

Erstelle `data/notices/notices_current.json`:

```json
{
  "meta": {
    "generated_at": "2025-01-20T10:30:00Z",
    "kw": 4
  },
  "notices": [
    // Alle aktiven Hinweise
  ]
}
```

---

## SCHRITT 5: Report erstellen (2 Min)

Erstelle `reports/RADAR_REPORT_[DATUM].md`:

```markdown
# 📡 MSH Radar Report - KW XX/2025

**Scan durchgeführt:** [Datum, Uhrzeit]
**Zeitraum:** [Start] bis [Ende]

---

## 📊 Zusammenfassung

| Metrik | Wert |
|--------|------|
| Events gefunden | XX |
| Hinweise aktiv | XX |
| Neue Events seit letzter Woche | XX |

---

## 🌟 Highlights diese Woche

1. **[Top Event]** - [Datum], [Ort]
2. **[Top Event]** - [Datum], [Ort]
3. **[Top Event]** - [Datum], [Ort]

---

## 📅 Veranstaltungen

### Samstag, XX.01.

| Zeit | Event | Ort | Kat |
|------|-------|-----|-----|
| 10:00 | Wochenmarkt | Marktplatz Sangerhausen | markt |
| 19:00 | Konzert XY | Mammuthalle | konzert |

### Sonntag, XX.01.

| Zeit | Event | Ort | Kat |
|------|-------|-----|-----|
| ... | ... | ... | ... |

[Weitere Tage...]

---

## ⚠️ Aktive Hinweise

| Typ | Titel | Gültig bis |
|-----|-------|------------|
| 🚧 | B86 Teilsperrung | 25.01. |
| ℹ️ | Rosarium Winteröffnung | 28.02. |

---

## 📝 Notizen

- [Besonderheiten, Beobachtungen]
- [Was hat sich geändert seit letzter Woche?]

---

## 🔗 Quellen

- MZ Veranstaltungen
- sangerhausen.de
- eisleben.eu
- suedharz-tourismus.de
- harzinfo.de

---

*Generiert von MSH Radar*
```

---

## SCHRITT 6: Zusammenfassung zeigen

Zeige dem Nutzer:

```
═══════════════════════════════════════════════════════════════
   📡 MSH RADAR SCAN ABGESCHLOSSEN
═══════════════════════════════════════════════════════════════

📊 ERGEBNISSE

   Veranstaltungen gefunden:  XX
   ├── Diese Woche:           XX
   └── Nächste Woche:         XX

   Aktive Hinweise:           XX
   ├── Kritisch:              XX
   └── Info:                  XX

📅 ZEITRAUM
   Von: [Datum]
   Bis: [Datum]

📁 DATEIEN AKTUALISIERT
   ✓ data/events/events_current.json
   ✓ data/notices/notices_current.json
   ✓ reports/RADAR_REPORT_[DATUM].md

═══════════════════════════════════════════════════════════════

🔍 BITTE PRÜFEN:

   1. Öffne reports/RADAR_REPORT_[DATUM].md
   2. Sind die Events korrekt?
   3. Keine Duplikate?
   4. Koordinaten plausibel?

   Wenn alles okay:
   → Antworte mit "Freigabe!"

   Bei Problemen:
   → Beschreibe was korrigiert werden soll

═══════════════════════════════════════════════════════════════
```

---

## NACH "Freigabe!"

Wenn der Nutzer "Freigabe!" sagt:

```bash
# 1. Build erstellen
flutter build web --release --web-renderer canvaskit

# 2. Bestätigen
echo "✅ Build fertig in build/web/"
echo ""
echo "Zum Deployen führe aus:"
echo "  cd build/web"
echo "  vercel --prod"
```

---

## REGELN

1. **Nur öffentliche Quellen** - Kein Login erforderlich
2. **robots.txt respektieren** - Bei Blockade überspringen
3. **Keine Personendaten** - Nur Event-Infos
4. **Qualität vor Quantität** - Lieber 15 gute Events als 50 unsichere
5. **Immer Quelle angeben** - source_url pflegen
6. **Bei Unsicherheit fragen** - Nicht raten

---

## WENN ETWAS NICHT FUNKTIONIERT

Falls eine Quelle nicht erreichbar ist:
- Notiere es im Report
- Mache mit anderen Quellen weiter
- Informiere den Nutzer am Ende

Falls zu wenige Events gefunden:
- Erweitere Suchradius
- Prüfe alternative Suchbegriffe
- Notiere im Report

---

**STARTE JETZT MIT SCHRITT 1!**
