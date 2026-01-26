# PROMPT: MSH DeepScan Ausführung

## Für Claude Code / Entwickler

Du führst das MSH DeepScan System aus, um umfassende regionale Daten zu sammeln und zu analysieren.

---

## SCHNELLSTART

### 1. Seed-Daten (SOFORT, ohne Internet)
```bash
cd deepscan
python 20_DEEPSCAN_MAIN.py --seed
```
Erstellt ~20 verifizierte Orte aus der Region.

### 2. Vollständiger Scan (EMPFOHLEN)
```bash
python 20_DEEPSCAN_MAIN.py --full
```
Führt aus:
- Scraping aller Quellen (OSM, Wikipedia, Tourismus, etc.)
- Datenanreicherung (Geocoding, Duplikat-Erkennung)
- Regionale Analyse (Gaps, Insights, Empfehlungen)

### 3. Einzelne Quelle testen
```bash
python 20_DEEPSCAN_MAIN.py --source openstreetmap
```

---

## VERFÜGBARE QUELLEN

| Quelle | Daten | Requests |
|--------|-------|----------|
| `openstreetmap` | POIs aus OSM (Overpass API) | ~10-20 |
| `spielplatztreff` | Spielplätze | ~10-15 |
| `wikidata` | Sehenswürdigkeiten, Kultur | ~5 |
| `harzinfo` | Tourismus, Ausflugsziele | ~10 |
| `events` | Veranstaltungen | ~5-10 |
| `gemeinden` | Offizielle Gemeindeinfos | ~10-20 |

---

## OUTPUT-STRUKTUR

```
output/
├── raw/                          # Rohdaten pro Quelle
│   ├── openstreetmap_*.json
│   ├── spielplatztreff_*.json
│   └── ...
│
├── enriched/                     # Angereicherte Daten
│   └── ...
│
├── merged/                       # Zusammengeführt
│   ├── msh_complete_*.json       # Alle Daten
│   └── msh_complete_*.geojson    # Für Karten
│
└── analytics/                    # Analysen
    ├── report_*.json
    └── report_*.md               # Lesbarer Bericht
```

---

## ANALYSE-OUTPUT

Der Report enthält:

### 1. Kategorie-Verteilung
Wie viele Orte pro Kategorie (playground, museum, etc.)

### 2. Städte-Statistik
- Anzahl Orte pro Stadt
- Coverage-Score (wie gut ist die Stadt abgedeckt)
- Top-Kategorien

### 3. Erkannte Lücken
- **Playground Deserts**: Gebiete ohne Spielplatz in 3km
- **Missing Pools**: Städte ohne Schwimmbad in 15km
- **Culture Gaps**: Fehlende Museen

### 4. Insights
Automatisch generierte Erkenntnisse wie:
- "Nur 1.5 Spielplätze pro 10.000 Einwohner"
- "Beste Abdeckung: Sangerhausen (78%)"

### 5. Empfehlungen
- "🔴 PRIORITÄT: Hettstedt hat keinen Spielplatz in 4km"
- "📍 Mehr museum-Einträge sammeln (aktuell: 3)"

---

## ERWEITERTER SUCHBEREICH

Das System sucht nicht nur in MSH, sondern +20km darüber hinaus:

```
┌─────────────────────────────────────────┐
│               NORD (51.93°)             │
│                                         │
│  Nordhausen    │    MANSFELD-SÜDHARZ    │
│                │                        │
│                │    Sangerhausen        │
│  WEST ────────┼──────────────────EAST  │
│ (10.50°)       │    Eisleben            │
│                │                        │
│  Kyffhäuser   │    Hettstedt           │
│               │                        │
│               SÜD (51.07°)              │
└─────────────────────────────────────────┘
```

Damit erfasst:
- Kompletter Südharz
- Kyffhäuser-Region
- Teile von Nordhausen
- Teile von Halle/Saalekreis

---

## ETHIK & COMPLIANCE

✅ Das System respektiert:
- robots.txt aller Websites
- Rate-Limiting (1.5s zwischen Requests)
- Nur öffentliche Daten
- Keine personenbezogenen Informationen
- Keine Login-geschützten Bereiche

❌ NICHT SCRAPEN:
- Private Daten
- Paywalls
- Urheberrechtlich geschützte Inhalte

---

## DATEN IN FIREBASE IMPORTIEREN

Nach dem Scan können die Daten in Firestore importiert werden:

```python
import json
import firebase_admin
from firebase_admin import firestore

# Initialisieren
firebase_admin.initialize_app()
db = firestore.client()

# Daten laden
with open('output/merged/msh_complete_*.json') as f:
    data = json.load(f)

# Importieren
batch = db.batch()
for item in data['data']:
    doc_ref = db.collection('locations').document(item['id'])
    batch.set(doc_ref, item)
    
batch.commit()
print(f"Imported {len(data['data'])} locations")
```

---

## TROUBLESHOOTING

### Import-Fehler
```bash
pip install requests beautifulsoup4
```

### Timeout bei OSM
Die Overpass API kann langsam sein. Erhöhe `REQUEST_TIMEOUT` in der Engine.

### Keine Daten gefunden
Starte mit `--seed` für sofort verfügbare Testdaten.

### Geocoding-Limit
Nominatim hat ein Limit von 1 Request/Sekunde. Das System hält das ein.

---

## WORKFLOW FÜR MAXIMALE DATENQUALITÄT

1. **Seed-Daten generieren**
   ```bash
   python 20_DEEPSCAN_MAIN.py --seed
   ```

2. **OpenStreetMap scrapen** (größte Quelle)
   ```bash
   python 20_DEEPSCAN_MAIN.py --source openstreetmap
   ```

3. **Weitere Quellen hinzufügen**
   ```bash
   python 20_DEEPSCAN_MAIN.py --scrape
   ```

4. **Daten anreichern**
   ```bash
   python 20_DEEPSCAN_MAIN.py --enrich
   ```

5. **Analyse durchführen**
   ```bash
   python 20_DEEPSCAN_MAIN.py --analyze
   ```

6. **Report prüfen**
   ```bash
   cat output/analytics/report_*.md
   ```

7. **GeoJSON in Karte laden**
   Importiere `output/merged/*.geojson` in die MSH Map

---

## ERWEITERUNG

### Neue Quelle hinzufügen

```python
# In deepscan_sources.py:

@ScraperRegistry.register
class MeineQuelleScraper(BaseScraper):
    
    @property
    def source_name(self) -> str:
        return "meine_quelle"
    
    @property
    def source_url(self) -> str:
        return "https://example.com"
    
    def scrape(self) -> List[Location]:
        locations = []
        # Implementierung...
        return locations
```

Der Scraper wird automatisch beim nächsten `--full` oder `--scrape` ausgeführt.

---

## UNTERSTÜTZUNG DER REGION

Die gesammelten Daten können verwendet werden für:

1. **Familien**: Ausflugsziele finden
2. **Tourismus**: Vollständige POI-Datenbank
3. **Regionalplanung**: Lücken erkennen
4. **Wirtschaftsförderung**: Infrastruktur-Analyse
5. **Vereine/Gemeinden**: Eigene Angebote sichtbar machen

Das Ziel ist eine "Single Source of Truth" für die Region Mansfeld-Südharz!
