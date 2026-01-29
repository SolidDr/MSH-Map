# Methoden & Ansätze - Claude AI Dokumentation

Diese Dokumentation beschreibt die Methoden, Ansätze und Datenquellen, die bei der Entwicklung der MSH-Map App verwendet wurden.

---

## A. Pins/Locations - Lokalisierung und Platzierung

### Verwendete Datenquellen

| Quelle | Typ | Beschreibung |
|--------|-----|--------------|
| **OpenStreetMap (OSM)** | Primär | Öffentliche Geodatenbank mit POI-Daten |
| **Manuelle Erfassung** | Ergänzend | Lokale Recherche, Vor-Ort-Verifizierung |
| **Websites/Portale** | Ergänzend | Offizielle Websites der Einrichtungen |

### Methodik der Datenerfassung

1. **OSM-Extraktion**
   - Overpass API Abfragen für Region Mansfeld-Südharz
   - Bounding Box: `51.35-51.65 N, 10.95-11.55 E`
   - Kategorien: `amenity`, `tourism`, `leisure`, `shop`

2. **Datenbereinigung (DeepScan)**
   - Entfernung von Duplikaten
   - Validierung von Koordinaten
   - Fake-Check für unrealistische Einträge
   - Normalisierung von Adressen und Namen

3. **Anreicherung**
   - Öffnungszeiten aus OSM-Tags extrahiert
   - Kategoriezuordnung basierend auf OSM-Tags
   - Tags für Filterung (familienfreundlich, barrierefrei, etc.)

### Dateiformat

**locations.json** (1.567 Einträge):
```json
{
  "meta": {
    "generated_at": "2026-01-27T22:30:00Z",
    "source": "deepscan_cleaned",
    "count": 1567,
    "fake_check": "PASSED"
  },
  "data": [
    {
      "id": "europa-rosarium-sangerhausen",
      "name": "Europa-Rosarium",
      "displayName": "Europa-Rosarium Sangerhausen",
      "category": "nature",
      "latitude": 51.4731,
      "longitude": 11.2936,
      "city": "Sangerhausen",
      "address": "Steinberger Weg 3, 06526 Sangerhausen",
      "description": "Weltgrößte Rosensammlung...",
      "website": "https://www.europa-rosarium.de",
      "openingHours": "Mai-Okt: 9-18 Uhr",
      "tags": ["rose", "garten", "unesco", "familienfreundlich"]
    }
  ]
}
```

### Kategorien (20+)

- **Gastronomie**: restaurant, cafe, imbiss, bar
- **Kultur**: event, culture, museum, castle
- **Freizeit**: sport, playground, zoo, pool, adventure
- **Natur**: nature, farm
- **Bildung**: school, kindergarten, library
- **Indoor**: indoor

### Platzierung auf der Karte

- **Technologie**: flutter_map mit OpenStreetMap Tiles
- **Marker-Rendering**: Dynamische Marker basierend auf Kategorie
- **Clustering**: Automatische Gruppierung bei vielen Pins
- **Popularität**: Größere Marker für beliebte Orte (Analytics-basiert)

---

## B. Fahrradwege - Lokalisierung, Zeichnung und Platzierung

### Verwendete Datenquellen

| Quelle | Typ | Beschreibung |
|--------|-----|--------------|
| **OpenStreetMap (OSM)** | Primär | Relation-Daten für offizielle Radwege |
| **Offizielle Radweg-Portale** | Primär | Tourismus-Verbände, Landkreis-Seiten |
| **GPS-Tracks** | Ergänzend | GPX-Dateien von Radweg-Betreibern |
| **Manuelle Recherche** | Ergänzend | Kontaktdaten, Beschreibungen |

### Methodik der Routenerfassung

1. **OSM-Relation-Extraktion**
   - Overpass API: `relation["route"="bicycle"]` in Region MSH
   - Beispiel Salzstraßen-Radweg: 547 Koordinatenpunkte aus OSM

2. **Manuelle GPS-Punkt-Erfassung**
   - Für Routen ohne vollständige OSM-Daten
   - Orientierung an offiziellen Karten
   - Kupferspurenradweg: 45+ manuell erfasste Punkte

3. **POI-Integration**
   - Sehenswürdigkeiten entlang der Route
   - Start-/Endpunkte
   - Rastplätze, Einkehrmöglichkeiten

### Datenstruktur (Dart-Code)

```dart
class RadwegRoute {
  final String id;                    // 'kupferspuren'
  final String name;                  // Vollständiger Name
  final String description;
  final RadwegCategory category;      // fernradweg, rundweg, themenweg, flussradweg
  final double lengthKm;              // z.B. 48 km
  final String difficulty;            // 'Leicht', 'Mittel', 'Schwer'
  final Color routeColor;             // Farbe auf Karte
  final List<LatLng> routePoints;     // GPS-Koordinaten der Route
  final List<RadwegPoi> pois;         // Sehenswürdigkeiten
  final int? elevationGain;           // Höhenmeter
  final String? websiteUrl;           // Offizielle Website
  final String? contactName;          // Ansprechpartner
  final String? contactPhone;
  final String? contactEmail;
}
```

### Verfügbare Radwege (9 Routen)

| Name | Länge | Kategorie | Koordinaten-Quelle |
|------|-------|-----------|-------------------|
| Kupferspurenradweg | 48 km | Themenweg | Manuell (45+ Punkte) |
| Romanik-Radweg | 156 km | Fernradweg | OSM + manuell |
| Saale-Harz-Radweg | 140 km | Fernradweg | OSM |
| Kyffhäuser-Radweg | 103 km | Rundweg | OSM + manuell |
| Wipper-Radweg | 118 km | Flussradweg | OSM |
| Himmelsscheiben-Radweg | 75 km | Themenweg | Manuell |
| Salzstraßen-Radweg | 90 km | Themenweg | OSM (547 Punkte) |
| Süßer-See-Radweg | 67 km | Rundweg | OSM |
| Lutherweg-Radweg | 103 km | Themenweg | OSM + manuell |

### Zeichnung auf der Karte

- **Technologie**: flutter_map PolylineLayer
- **Rendering**: Farbcodierte Linien pro Route
- **Interaktion**: Tap auf Route zeigt Details
- **Animation**: Animierte Linienführung beim Fokussieren

---

## C. Ärzte & Einrichtungen - Datenerhebung

### Verwendete Datenquellen

| Quelle | Typ | Beschreibung |
|--------|-----|--------------|
| **OpenStreetMap (OSM)** | Primär | Standorte mit `amenity=doctors`, `pharmacy`, etc. |
| **arzt-auskunft.de** | Primär | Offizielle Arztdatenbank mit Fachrichtungen |
| **Gelbe Seiten** | Ergänzend | Telefonnummern, Adressen |
| **Krankenkassen-Listen** | Ergänzend | Kassenärztliche Zulassung |
| **Manuelle Recherche** | Verifizierung | Websites, Anrufe |

### Methodik der Datenerfassung

1. **OSM-Extraktion**
   ```
   amenity=doctors
   amenity=pharmacy
   amenity=hospital
   amenity=dentist
   healthcare=physiotherapist
   ```

2. **arzt-auskunft.de Abgleich**
   - Fachrichtung (Spezialisierung)
   - Kassenärztliche Zulassung
   - Sprechzeiten

3. **Manuelle Verifizierung**
   - Telefonische Erreichbarkeit prüfen
   - Websites validieren
   - Öffnungszeiten aktualisieren
   - **Status**: 13 von 114 Ärzten verifiziert

4. **Datenmerging**
   - OSM liefert: Koordinaten, Adresse, Basis-Öffnungszeiten
   - arzt-auskunft.de liefert: Fachrichtung, Versicherung
   - Manuell: Verifizierung, Hausbesuche, Barrierefreiheit

### Dateiformat

**doctors.json** (114 Einträge):
```json
{
  "meta": {
    "source": "openstreetmap, arzt-auskunft.de, manual",
    "created_at": "2026-01-28",
    "version": "3.0",
    "region": "Mansfeld-Suedharz",
    "total_count": 114,
    "verified_count": 13
  },
  "data": [
    {
      "id": "arzt_sg_097",
      "type": "doctor",
      "name": "Dr. med. Max Mustermann",
      "latitude": 51.4723489,
      "longitude": 11.2949833,
      "street": "Kylische Straße 33",
      "postalCode": "06526",
      "city": "Sangerhausen",
      "phone": "+49 3464 123456",
      "specialization": "allgemein",
      "openingHours": "Mo-Fr 08:30-18:30; Sa 08:30-14:00",
      "isBarrierFree": true,
      "hasHouseCalls": true,
      "acceptsPublicInsurance": true,
      "acceptsPrivateInsurance": true,
      "languages": ["Deutsch"],
      "verified": true,
      "source": "openstreetmap"
    }
  ]
}
```

### Kategorien & Dateien

| Datei | Anzahl | Beschreibung |
|-------|--------|--------------|
| `doctors.json` | 114 | Ärzte aller Fachrichtungen |
| `pharmacies.json` | 55 | Apotheken inkl. Notdienst |
| `hospitals.json` | ~10 | Krankenhäuser & Kliniken |
| `physiotherapy.json` | ~30 | Physiotherapie-Praxen |
| `fitness.json` | ~15 | Fitnessstudios |
| `care_services.json` | ~25 | Pflegedienste |
| `medical_supply.json` | ~20 | Sanitätshäuser |
| `aeds.json` | ~50 | Defibrillatoren (AED) |

### Arzt-Fachrichtungen

- Allgemeinmedizin
- Innere Medizin
- Kardiologie
- Orthopädie
- Neurologie
- Augenheilkunde
- HNO
- Dermatologie
- Urologie
- Gynäkologie
- Zahnmedizin
- Kinderheilkunde
- Psychiatrie/Psychotherapie

---

## Technische Umsetzung

### Architektur

```
assets/data/
├── locations.json           # POIs (1.567)
├── msh_locations.geojson    # Alternative GeoJSON
└── health/
    ├── doctors.json         # Ärzte (114)
    ├── pharmacies.json      # Apotheken (55)
    ├── hospitals.json
    ├── physiotherapy.json
    ├── fitness.json
    ├── care_services.json
    ├── medical_supply.json
    └── aeds.json

lib/src/modules/
├── radwege/data/routes/     # Radwege als Dart-Code
│   ├── kupferspuren_route.dart
│   ├── romanik_route.dart
│   └── ...
└── health/data/
    └── health_repository.dart
```

### Lademechanismen

1. **Locations**: `rootBundle.loadString()` → JSON-Parse → Cache
2. **Radwege**: Compile-Zeit (const Dart-Objekte)
3. **Health**: Lazy-Loading bei Modulaufruf → Cache

### Keine externen APIs

Alle Daten sind lokal in der App gespeichert. Es gibt keine Abhängigkeit von:
- Google Maps API
- Here Maps
- Externe Datenbanken
- Live-Abrufe

**Vorteile:**
- Offline-fähig
- Keine API-Kosten
- Schnelle Ladezeiten
- Datenschutz (keine Tracking-APIs)

---

## Qualitätssicherung

### Verifizierungsstatus

| Datenkategorie | Verifiziert | Gesamt | Quote |
|----------------|-------------|--------|-------|
| Ärzte | 13 | 114 | 11% |
| Apotheken | ~30 | 55 | ~55% |
| Locations | ~200 | 1.567 | ~13% |
| Radwege | 9 | 9 | 100% |

### Datenaktualität

- **Locations**: Letzte Aktualisierung 2026-01-27
- **Health**: Version 3.0, Stand 2026-01-28
- **Radwege**: Manuell gepflegt, kontinuierlich

### Bekannte Einschränkungen

1. **Öffnungszeiten**: Nicht alle Einträge haben vollständige Zeiten
2. **Telefonnummern**: Teilweise veraltet
3. **Koordinaten-Genauigkeit**: OSM-Daten ±10m
4. **Beschreibungen**: Nicht alle POIs haben Beschreibungen

---

*Erstellt von Claude AI (Opus 4.5) - Januar 2026*
