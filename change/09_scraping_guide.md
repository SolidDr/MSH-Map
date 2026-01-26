# 09 - Data Scraping Guide

## Übersicht

Das Scraping-System sammelt Daten für die MSH Map mit **Fokus auf Familienaktivitäten**.

**Priorität der Daten:**
1. 🎯 **Familienaktivitäten** (Spielplätze, Museen, Natur) - ERSTE Punkte auf der Karte
2. 🍽️ Gastronomie (später via Gastro-Modul)
3. 📅 Events (später via Events-Modul)

---

## Dateien

```
scraping/
├── msh_scraper.py          # Haupt-Scraper
├── requirements.txt        # Python Dependencies
└── output/
    ├── msh_seed_data.json  # Manuell gepflegte Basisdaten
    └── msh_scraped.json    # Gescrapte Daten
```

---

## Installation

```bash
# Virtual Environment erstellen
python -m venv venv
source venv/bin/activate  # Linux/Mac
# oder: venv\Scripts\activate  # Windows

# Dependencies installieren
pip install requests beautifulsoup4
```

---

## Verwendung

### 1. Seed-Daten erstellen (Empfohlen als Start)

```bash
python msh_scraper.py --seed
```

Erstellt `msh_data_seed.json` mit **bekannten, verifizierten Orten**:
- Rosarium Sangerhausen
- Luthers Geburtshaus
- Süßer See
- Wippertalsperre
- Schloss Mansfeld
- etc.

**Diese Daten sind sofort nutzbar für die App!**

### 2. Web-Scraping durchführen

```bash
python msh_scraper.py --scrape
```

Scrapt konfigurierte Quellen. **Achtung:** 
- Respektiert robots.txt
- 1.5s Pause zwischen Requests
- Ergebnisse müssen manuell geprüft werden

### 3. Beides

```bash
python msh_scraper.py --all --output msh_family
```

---

## Datenformat

```json
{
  "meta": {
    "created_at": "2025-01-26T...",
    "item_count": 15
  },
  "data": [
    {
      "id": "a1b2c3d4e5f6",
      "name": "Rosarium Sangerhausen",
      "category": "nature",
      "description": "Europa-Rosarium...",
      "latitude": 51.4725,
      "longitude": 11.2983,
      "city": "Sangerhausen",
      "age_range": "alle",
      "is_free": false,
      "is_outdoor": true,
      "is_indoor": false,
      "tags": ["park", "blumen", "familienfreundlich"],
      "activity_type": "park",
      "source_url": "https://...",
      "scraped_at": "2025-01-26T..."
    }
  ]
}
```

---

## Kategorien

| Kategorie | Beschreibung | Keywords |
|-----------|--------------|----------|
| `playground` | Spielplätze | spielplatz, kinderspielplatz |
| `museum` | Museen & Ausstellungen | museum, ausstellung, bergbau |
| `nature` | Natur & Parks | wanderweg, park, see, wald |
| `zoo` | Tierparks | tierpark, zoo, wildgehege |
| `indoor` | Indoor-Aktivitäten | indoorspielplatz, kletterhalle |
| `pool` | Schwimmbäder & Seen | schwimmbad, freibad, badesee |
| `castle` | Burgen & Schlösser | burg, schloss, ruine |
| `farm` | Bauernhöfe | bauernhof, reiterhof |
| `adventure` | Abenteuer | kletterpark, sommerrodelbahn |

---

## Neue Quellen hinzufügen

In `msh_scraper.py` unter `SOURCES`:

```python
SOURCES = [
    # ... bestehende ...
    {
        'name': 'Neue Quelle',
        'base_url': 'https://example.com',
        'paths': ['/familie', '/kinder'],
        'enabled': True  # Auf False setzen zum Deaktivieren
    },
]
```

**Wichtig:** Jede neue Quelle benötigt möglicherweise angepasste Parsing-Logik!

---

## Manuelle Orte hinzufügen

In `KNOWN_LOCATIONS` am Ende der Datei:

```python
KNOWN_LOCATIONS = [
    # ... bestehende ...
    {
        "name": "Neuer Spielplatz",
        "category": "playground",
        "description": "Toller Spielplatz mit...",
        "address": "Musterstraße 1, 06526 Sangerhausen",
        "latitude": 51.4700,   # Aus Google Maps
        "longitude": 11.3000,
        "city": "Sangerhausen",
        "age_range": "3-12",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["spielplatz", "klettern", "schaukel"],
        "activity_type": "playground"
    },
]
```

---

## Daten in Firestore importieren

Nach dem Scraping können die Daten in Firestore importiert werden:

```python
# firebase_import.py (separates Script)
import json
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate('serviceAccount.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

with open('msh_data_seed.json', 'r') as f:
    data = json.load(f)

for item in data['data']:
    # Koordinaten als GeoPoint
    if item.get('latitude') and item.get('longitude'):
        item['location'] = firestore.GeoPoint(
            item['latitude'], 
            item['longitude']
        )
    
    db.collection('family_activities').document(item['id']).set(item)
    print(f"Imported: {item['name']}")
```

---

## Ethik & Compliance

✅ **Was wir tun:**
- robots.txt respektieren
- Rate-Limiting (1.5s zwischen Requests)
- Ehrlicher User-Agent mit Kontakt
- Nur öffentliche Daten

❌ **Was wir NICHT tun:**
- Login-Bereiche scrapen
- Rate-Limits umgehen
- Personenbezogene Daten sammeln
- Urheberrechtlich geschützte Inhalte kopieren

---

## Troubleshooting

**"Keine Daten gefunden"**
- Prüfe ob die Quell-Website ihr HTML geändert hat
- CSS-Selektoren in `scrape_source()` anpassen

**"robots.txt blockiert"**
- Respektiere die Entscheidung des Seitenbetreibers
- Kontaktiere den Betreiber für eine Ausnahme

**"Koordinaten fehlen"**
- Manuell über Google Maps ermitteln
- Oder Geocoding-API verwenden (z.B. Nominatim)