# MSH DeepScan System

Umfassendes Datensammlung- und Analyse-System für die Region Mansfeld-Südharz.

## Übersicht

Das DeepScan System besteht aus drei Hauptkomponenten:

1. **Python DeepScan Engine** - Datensammlung und Export
2. **Firebase Cloud Functions** - Automatische Analyse und Aggregation
3. **Flutter Integration** - Visualisierung in der MSH Map App

## 1. Python DeepScan Engine

### Installation

```bash
cd deepscan
pip install -r requirements.txt
```

### Verwendung

#### Seed-Daten exportieren (58 verifizierte MSH-Orte)

```bash
python deepscan_main.py --seed
```

**Generiert:**
- `output/merged/msh_complete_*.json` - Vollständige Daten im JSON-Format
- `output/merged/msh_complete_*.geojson` - GeoJSON für Karten
- `output/merged/msh_firestore_*.json` - Firestore-kompatibles Format
- `output/analytics/report_*.json` - Statistiken als JSON
- `output/analytics/report_*.md` - Lesbarer Markdown-Report

### Ausgabe-Struktur

```
deepscan/
├── msh_data_seed.json          # 58 verifizierte Orte
├── deepscan_main.py            # Haupt-Engine
├── requirements.txt
└── output/
    ├── raw/                    # Rohdaten (zukünftig)
    ├── enriched/               # Angereicherte Daten (zukünftig)
    ├── merged/                 # Zusammengeführte Exports
    └── analytics/              # Analysen und Reports
```

## 2. Firebase Cloud Functions

### Setup

```bash
cd functions
npm install
```

### Verfügbare Functions

#### Scheduled Functions (Automatisch)

- **updateDailyStats** - Läuft täglich um 3 Uhr nachts
  - Berechnet Region-Overview
  - Aktualisiert Stadt-Statistiken
  - Erkennt Infrastruktur-Lücken
  - Generiert Insights

- **updateWeeklyReport** - Läuft sonntags um 6 Uhr
  - Wöchentlicher Zusammenfassungs-Report

#### Firestore Triggers (Automatisch)

- **onLocationCreated** - Bei neuer Location
- **onLocationUpdated** - Bei Location-Änderung
- **onLocationDeleted** - Bei Location-Löschung

#### HTTP Functions (Manuell)

- **recalculateAll** - Neuberechnung aller Statistiken
  ```bash
  curl https://[REGION]-[PROJECT].cloudfunctions.net/recalculateAll
  ```

### Deployment

```bash
cd functions
npm run build
firebase deploy --only functions
```

### Entwicklung & Testing

```bash
# TypeScript kompilieren
npm run build

# Functions Emulator starten
npm run serve

# Logs ansehen
npm run logs
```

## 3. Firestore Datenstruktur

### Collections

```
firestore/
├── locations/              # Einzelne Orte
│   └── {locationId}/
│       ├── name
│       ├── displayName
│       ├── category
│       ├── coordinates {lat, lng}
│       ├── city
│       ├── description
│       └── ...
│
├── analytics/              # Aggregierte Analysen
│   ├── region_overview/
│   │   ├── totalLocations
│   │   ├── totalCities
│   │   └── categoryTotals
│   │
│   ├── city_stats/cities/{cityId}/
│   │   ├── locationCount
│   │   ├── categoryDistribution
│   │   ├── coverageScore
│   │   └── familyScore
│   │
│   ├── gaps/items/{gapId}/
│   │   ├── gapType
│   │   ├── severity
│   │   ├── description
│   │   └── recommendation
│   │
│   └── insights/items/{insightId}/
│       ├── type
│       ├── title
│       └── description
```

## 4. Daten in Firestore importieren

### Manuelle Import-Methode

```python
import json
import firebase_admin
from firebase_admin import firestore

# Initialisieren
firebase_admin.initialize_app()
db = firestore.client()

# Firestore-Format laden
with open('deepscan/output/merged/msh_firestore_[TIMESTAMP].json') as f:
    data = json.load(f)

# Batch-Import
batch = db.batch()
for location_id, location_data in data['locations'].items():
    doc_ref = db.collection('locations').document(location_id)
    batch.set(doc_ref, location_data)

batch.commit()
print(f"Imported {len(data['locations'])} locations")
```

### Via Firebase CLI (Alternative)

```bash
firebase firestore:delete --all-collections
firebase firestore:import deepscan/output/merged/
```

## 5. Workflow

### Vollständiger Workflow

1. **Seed-Daten exportieren**
   ```bash
   cd deepscan
   python deepscan_main.py --seed
   ```

2. **Daten in Firestore importieren**
   ```python
   # siehe Abschnitt 4
   ```

3. **Cloud Functions deployen**
   ```bash
   cd functions
   npm run build
   firebase deploy --only functions
   ```

4. **Initiale Berechnung triggern**
   ```bash
   curl https://[REGION]-[PROJECT].cloudfunctions.net/recalculateAll
   ```

5. **Ergebnisse prüfen**
   - Firestore Console öffnen
   - `analytics` Collection ansehen
   - Statistiken, Gaps und Insights prüfen

## 6. Statistiken & Analysen

### Region Overview
- Gesamtzahl Orte
- Anzahl Städte
- Kategorie-Verteilung

### Stadt-Statistiken
- Orte pro Stadt
- Coverage Score (Infrastruktur-Abdeckung)
- Family Score (Familienfreundlichkeit)
- Durchschnitts-Bewertung

### Gap Detection
- **Playground Deserts** - Gebiete ohne Spielplatz im Umkreis von 3km
- **Missing Pools** - Städte ohne Schwimmbad in 15km
- **Culture Gaps** - Fehlende Museen
- **Restaurant Gaps** - Fehlende Gastronomie

### Insights
- **Achievements** - Erfolge (z.B. "Gute Spielplatz-Versorgung")
- **Gaps** - Lücken (z.B. "Spielplatz-Abdeckung verbesserungswürdig")
- **Trends** - Entwicklungen (z.B. "nature ist die stärkste Kategorie")
- **Recommendations** - Empfehlungen (z.B. "Mehr museum-Daten sammeln")

## 7. Kategorie-System

### Verfügbare Kategorien

| Kategorie | Beschreibung | Beispiele |
|-----------|--------------|-----------|
| `nature` | Natur & Outdoor | Wanderwege, Parks, Aussichtspunkte |
| `museum` | Museen | Bergbaumuseum, Heimatmuseum |
| `playground` | Spielplätze | Öffentliche Spielplätze |
| `culture` | Kultur & Geschichte | Altstadt, Denkmäler, Kirchen |
| `restaurant` | Restaurants | Gasthöfe, Restaurants |
| `cafe` | Cafés | Cafés, Bäckereien |
| `imbiss` | Imbisse | Schnellimbisse |
| `pool` | Schwimmbäder | Freibäder, Hallenbäder |
| `castle` | Burgen & Schlösser | Burgruinen, Schlösser |
| `zoo` | Tierparks | Zoos, Tierparks |
| `event` | Events | Feste, Märkte |
| `indoor` | Indoor-Aktivitäten | Kino, Bowling |
| `sport` | Sport | Minigolf, Skatepark |
| `farm` | Bauernhöfe | Erlebnisbauernhöfe |
| `adventure` | Abenteuer | Kletterwald, Hochseilgarten |

## 8. Troubleshooting

### Python Engine

**Problem:** Import-Fehler
```bash
pip install -r requirements.txt
```

**Problem:** Encoding-Fehler (Windows)
- UTF-8 ist bereits konfiguriert, sollte funktionieren

### Cloud Functions

**Problem:** Functions deployen nicht
```bash
firebase login
firebase use --add  # Projekt auswählen
```

**Problem:** TypeScript-Fehler
```bash
npm run build
# Fehler im Output beheben
```

**Problem:** Functions laufen nicht
```bash
firebase functions:log --only [functionName]
```

## 9. Erweiterung

### Neue Seed-Daten hinzufügen

Bearbeite `msh_data_seed.json`:

```json
{
  "id": "unique-id",
  "name": "Name",
  "displayName": "Anzeigename",
  "category": "category",
  "latitude": 51.4667,
  "longitude": 11.3000,
  "city": "Stadt",
  "description": "Beschreibung",
  ...
}
```

### Neue Kategorie hinzufügen

1. Kategorie in `msh_data_seed.json` verwenden
2. MIN_PER_10K in `functions/src/analytics/aggregation.ts` anpassen
3. Flutter: Icon-Mapping in MapItem aktualisieren

## 10. Nächste Schritte

### Python Engine erweitern
- [ ] OpenStreetMap Scraper
- [ ] Wikipedia/Wikidata Integration
- [ ] Tourismus-Portale scrapen
- [ ] Automatische Geocoding

### Cloud Functions erweitern
- [ ] Wöchentlicher Report mit Vergleichen
- [ ] Popularity-Scoring basierend auf Views
- [ ] Trend-Analyse über Zeit
- [ ] Email-Benachrichtigungen für kritische Gaps

### Flutter Integration
- [ ] Dashboard-Screen mit Statistiken
- [ ] Gap-Visualisierung auf Karte
- [ ] Insight-Cards im Feed
- [ ] Familien-Score pro Stadt anzeigen

## Support

Bei Fragen oder Problemen:
- Cloud Functions Logs: `firebase functions:log`
- Python Engine: `python deepscan_main.py --help`
- Firestore Console: https://console.firebase.google.com
