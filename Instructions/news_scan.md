# MSH Radar - News Scan Anleitung

Diese Anleitung beschreibt den Prozess für das wöchentliche Scannen von Neuigkeiten, Warnungen und Veranstaltungen im Landkreis Mansfeld-Südharz.

## Ziel

Aktualisierung der folgenden JSON-Dateien mit aktuellen Daten:
- `data/events/events_current.json` - Veranstaltungen (nächste 2 Wochen)
- `data/notices/notices_current.json` - Warnungen, Sperrungen, Öffnungszeiten

## Ablauf

### Schritt 1: Aktuelle Dateien lesen

```
Lies zuerst beide Dateien:
- data/events/events_current.json
- data/notices/notices_current.json
```

### Schritt 2: Web-Suche nach Veranstaltungen

Suche nach Veranstaltungen der nächsten 2 Wochen mit WebSearch:

**Suchbegriffe:**
- "Veranstaltungen Sangerhausen [aktuelles Datum]"
- "Veranstaltungen Eisleben [aktuelles Datum]"
- "Veranstaltungen Mansfeld-Südharz [aktuelles Datum]"
- "Events Stolberg Harz"
- "Hettstedt Veranstaltungen"

**Wichtige Quellen (mit WebFetch abrufen):**
- https://www.mansfeldsuedharz-tourismus.de/veranstaltungen/
- https://www.eisleben.eu (Veranstaltungskalender)
- https://sangerhausen.de (Veranstaltungen)
- https://www.theater-eisleben.de/spielplan/
- https://www.europa-rosarium.de

### Schritt 3: Web-Suche nach Warnungen & Sperrungen

**Suchbegriffe:**
- "Straßensperrung Mansfeld-Südharz"
- "Baustelle B180 B86 L151"
- "Vollsperrung Sangerhausen Eisleben"
- "Verkehrsmeldungen Landkreis MSH"

**Wichtige Quellen:**
- https://www.mansfeldsuedharz.de/baustellenservice
- Lokale Nachrichtenseiten

### Schritt 4: JSON-Dateien aktualisieren

---

## Datenstrukturen

### Events (events_current.json)

```json
{
  "meta": {
    "generated_at": "2026-01-30T10:00:00Z",
    "generated_by": "MSH Radar",
    "valid_from": "2026-01-30",
    "valid_until": "2026-02-13",
    "kw": 5
  },
  "stats": {
    "total_events": 12,
    "by_category": {
      "konzert": 0,
      "markt": 4,
      "theater": 0,
      "sport": 0,
      "kinder": 1,
      "fest": 0,
      "fuehrung": 4,
      "ausstellung": 1,
      "sonstiges": 2
    },
    "by_city": {
      "Sangerhausen": 5,
      "Lutherstadt Eisleben": 3,
      "Stolberg (Harz)": 4
    }
  },
  "events": [
    {
      "id": "evt_YYYYMMDD_NNN",
      "name": "Veranstaltungsname",
      "date": "2026-01-30",
      "date_end": "2026-02-01",
      "time_start": "14:00",
      "time_end": "17:00",
      "location_name": "Ort der Veranstaltung",
      "latitude": 51.4698,
      "longitude": 11.2978,
      "city": "Sangerhausen",
      "category": "kinder",
      "description": "Kurze Beschreibung",
      "price": "kostenlos",
      "source_url": "https://...",
      "tags": ["tag1", "tag2"],
      "image_url": "https://..."
    }
  ]
}
```

**Event-Kategorien:**
- `konzert` - Konzerte, Musik
- `markt` - Märkte, Wochenmärkte
- `theater` - Theater, Aufführungen
- `sport` - Sportveranstaltungen
- `kinder` - Kinderveranstaltungen, Familie
- `fest` - Feste, Festivals
- `fuehrung` - Führungen, Touren
- `ausstellung` - Ausstellungen, Museen
- `sonstiges` - Alles andere

**Wichtige Städte im Landkreis:**
- Sangerhausen (Kreisstadt)
- Lutherstadt Eisleben
- Hettstedt
- Stolberg (Harz)
- Mansfeld
- Gerbstedt
- Arnstein
- Südharz (Gemeinde)

### Notices (notices_current.json)

```json
{
  "meta": {
    "generated_at": "2026-01-30T10:00:00Z",
    "kw": 5,
    "coordinates_verified": true,
    "last_verification": "2026-01-30"
  },
  "notices": [
    {
      "id": "notice_NNN",
      "type": "sperrung",
      "title": "B 180 Vollsperrung",
      "description": "Vollsperrung wegen Bauarbeiten. Umleitung über...",
      "affected_area": "B 180 (Walbeck - Quenstedt)",
      "valid_from": "2025-03-03",
      "valid_until": "2026-06-17",
      "time_start": "08:00",
      "time_end": "17:00",
      "severity": "critical",
      "source_url": "https://...",
      "source_urls": ["https://...", "https://..."],
      "latitude": 51.7220,
      "longitude": 11.4450,
      "route_coordinates": [
        [51.7480, 11.4490],
        [51.7380, 11.4465]
      ]
    }
  ]
}
```

**Notice-Typen:**
- `sperrung` - Straßensperrungen, Vollsperrungen
- `baustelle` - Baustellen mit Einschränkungen
- `oeffnungszeit` - Sonderöffnungszeiten (Museen, Attraktionen)
- `warnung` - Allgemeine Warnungen
- `info` - Informationen

**Severity-Stufen:**
- `critical` - Rot, hohe Priorität (Vollsperrungen)
- `warning` - Orange, mittlere Priorität (Einschränkungen)
- `info` - Blau, Information (Öffnungszeiten)

---

## Koordinaten

**Zentrale Koordinaten für häufige Orte:**

| Ort | Latitude | Longitude |
|-----|----------|-----------|
| Sangerhausen Markt | 51.4698 | 11.2978 |
| Lutherstadt Eisleben Markt | 51.5256 | 11.5490 |
| Stolberg Markt | 51.5742 | 11.0567 |
| Hettstedt Markt | 51.6421 | 11.5029 |
| Europa Rosarium | 51.4734 | 11.2987 |
| Schloss Stolberg | 51.5742 | 11.0567 |
| Spengler Museum | 51.4698 | 11.2978 |
| Kyffhäuser Denkmal | 51.4135 | 11.1096 |

---

## Regelmäßige Events (wiederkehrend eintragen)

**Wöchentlich:**
- Wochenmarkt Sangerhausen: Di + Fr, 07:00-14:00, Marktplatz
- Wochenmarkt Eisleben: Mi + Sa, 07:00-13:00, Markt

**Regelmäßige Führungen:**
- Schloss Stolberg: Abendführung Fr 20:00, Stadtführung Sa 10:00
- Lutherhäuser Eisleben: Di-So 10:00-17:00

---

## Nach dem Update

1. **Validierung:** Prüfe dass JSON valide ist
2. **Stats aktualisieren:** Zähle Events nach Kategorie und Stadt
3. **Meta aktualisieren:** `generated_at`, `valid_from`, `valid_until`, `kw`
4. **Abgelaufene Einträge:** Entferne Events/Notices deren `valid_until` < heute

---

## Deployment

Nach dem Update werden die Änderungen automatisch deployed:

1. `git add data/events/ data/notices/`
2. `git commit -m "data: MSH Radar Update KW [X]"`
3. `git push`

GitHub Actions baut automatisch → Vercel deployed automatisch.

---

## Checkliste

- [ ] events_current.json gelesen
- [ ] notices_current.json gelesen
- [ ] Veranstaltungen der nächsten 2 Wochen gesucht
- [ ] Aktuelle Sperrungen/Baustellen gesucht
- [ ] Abgelaufene Einträge entfernt
- [ ] Neue Einträge hinzugefügt
- [ ] Meta-Daten aktualisiert
- [ ] Stats neu berechnet
- [ ] JSON validiert
- [ ] Änderungen committed und gepusht
