# 15 - MSH DeepScan System

## Vision

Ein umfassendes Daten-Sammel- und Analyse-System für die Region Mansfeld-Südharz + 20km Umkreis.

**Ziel:** Die vollständigste, aktuellste und nützlichste Datensammlung für Familien, Einheimische und Besucher.

---

## Erweiterter Suchradius

```
Standard MSH Bounding Box:
  Nord:  51.75°N
  Süd:   51.25°N  
  West:  10.75°E
  Ost:   11.85°E

Extended Bounding Box (+20km):
  Nord:  51.93°N  (bis Halle-Umland)
  Süd:   51.07°N  (bis Nordhausen)
  West:  10.50°E  (bis Bad Sachsa)
  Ost:   12.10°E  (bis Halle)
  
Damit erfasst:
  - Südharz komplett
  - Kyffhäuser
  - Teile Saalekreis
  - Nordhausen
  - Sangerhausen, Eisleben, Hettstedt (Kern)
```

---

## System-Architektur

```
msh_deepscan/
├── 15_DEEPSCAN_OVERVIEW.md      # Diese Datei
├── 16_DEEPSCAN_ENGINE.py        # Kern-Engine
├── 17_DEEPSCAN_SOURCES.py       # Alle Datenquellen
├── 18_DEEPSCAN_ENRICHMENT.py    # Datenanreicherung
├── 19_DEEPSCAN_ANALYTICS.py     # Regionale Analyse
├── 20_PROMPT_DEEPSCAN.md        # Claude Code Prompt
│
└── output/
    ├── raw/                     # Rohdaten pro Quelle
    ├── enriched/                # Angereicherte Daten
    ├── merged/                  # Zusammengeführt
    └── analytics/               # Analysen & Reports
```

---

## Daten-Kategorien

### 1. FAMILIE & FREIZEIT
- Spielplätze (öffentlich, indoor)
- Schwimmbäder, Badeseen
- Tierparks, Streichelzoos
- Freizeitparks, Kletterparks
- Minigolf, Bowling
- Kinos, Theater

### 2. NATUR & OUTDOOR
- Wanderwege (mit Länge, Schwierigkeit)
- Radwege
- Aussichtspunkte
- Naturschutzgebiete
- Seen, Talsperren
- Wälder, Parks

### 3. KULTUR & GESCHICHTE
- Museen
- Burgen, Schlösser, Ruinen
- Kirchen, Klöster
- Denkmäler
- UNESCO-Stätten
- Bergbau-Erbe

### 4. GASTRONOMIE
- Restaurants
- Cafés
- Imbisse
- Biergärten
- Hofläden

### 5. EVENTS & MÄRKTE
- Wochenmärkte
- Flohmärkte
- Feste, Veranstaltungen
- Weihnachtsmärkte

### 6. INFRASTRUKTUR (für Analyse)
- Öffentliche WCs
- Parkplätze
- E-Ladesäulen
- ÖPNV-Haltestellen
- Ärzte, Apotheken

### 7. WIRTSCHAFT & ARBEIT (Analyse)
- Unternehmen
- Gewerbegebiete
- Coworking Spaces
- Handwerker

---

## Datenquellen-Übersicht

### Tier 1: Hochwertige Quellen
| Quelle | Typ | Daten |
|--------|-----|-------|
| OpenStreetMap | API | POIs, Wege, Infrastruktur |
| Wikipedia/Wikidata | API | Kulturelle Infos |
| Gemeinde-Websites | Scrape | Offizielle Infos |
| Tourismus-Portale | Scrape | Ausflugsziele |

### Tier 2: Spezialisierte Quellen
| Quelle | Typ | Daten |
|--------|-----|-------|
| Spielplatztreff | Scrape | Spielplätze |
| Komoot | API | Wanderwege |
| Outdooractive | API | Outdoor-Aktivitäten |
| Tripadvisor | Scrape | Bewertungen |

### Tier 3: Offizielle Daten
| Quelle | Typ | Daten |
|--------|-----|-------|
| Statistisches Landesamt | Download | Bevölkerung, Wirtschaft |
| Geoportal SA | API | Geodaten |
| Denkmalliste | PDF | Kulturdenkmäler |

---

## Datenanreicherung

### Automatisch
1. **Geocoding** - Adressen → Koordinaten
2. **Reverse Geocoding** - Koordinaten → Ortsname
3. **Kategorisierung** - ML-basierte Zuordnung
4. **Duplikat-Erkennung** - Fuzzy Matching
5. **Öffnungszeiten-Parsing** - Strukturierung

### Manuell (Priorisiert)
1. Fehlende Fotos ergänzen
2. Beschreibungen verbessern
3. Altersempfehlungen hinzufügen
4. Barrierefreiheit prüfen

---

## Regionale Analyse-Möglichkeiten

### Für Familien
- "Weiße Flecken" bei Spielplätzen
- Entfernung zum nächsten Schwimmbad
- Familienfreundlichste Gemeinden

### Für Tourismus
- Meistbesuchte Sehenswürdigkeiten
- Unterversorgte Bereiche
- Saisonale Muster

### Für Regionalentwicklung
- Infrastruktur-Lücken
- Wirtschaftliche Cluster
- Demographische Trends

---

## Ethik & Compliance

✅ **Erlaubt:**
- Öffentlich zugängliche Daten
- OpenData-Portale
- APIs mit Nutzungsbedingungen
- Offizielle Statistiken

❌ **Nicht erlaubt:**
- Private Daten
- Login-geschützte Bereiche
- Personenbezogene Informationen
- Urheberrechtlich geschützte Inhalte

### robots.txt Respekt
Jede Quelle wird auf robots.txt geprüft.
Bei Verbot → Alternative suchen oder manuell.

---

## Output-Formate

### JSON (Primär)
```json
{
  "meta": {
    "source": "spielplatztreff",
    "scraped_at": "2025-01-26T...",
    "version": "1.0"
  },
  "data": [...]
}
```

### GeoJSON (für Karten)
```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {"type": "Point", "coordinates": [11.3, 51.47]},
      "properties": {...}
    }
  ]
}
```

### CSV (für Analyse)
Für Import in Excel, Pandas, etc.

---

## Nächste Schritte

1. **16_DEEPSCAN_ENGINE.py** - Basis-Engine
2. **17_DEEPSCAN_SOURCES.py** - Alle Quellen
3. **18_DEEPSCAN_ENRICHMENT.py** - Anreicherung
4. **19_DEEPSCAN_ANALYTICS.py** - Analyse
5. **20_PROMPT_DEEPSCAN.md** - Ausführungs-Prompt
