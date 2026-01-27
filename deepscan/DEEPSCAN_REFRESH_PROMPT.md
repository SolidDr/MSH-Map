# DeepScan Refresh Prompt

**Trigger:** `start deepsearch_refresh`

---

## Anweisung für Claude

Wenn der Benutzer "start deepsearch_refresh" sagt, führe folgende Schritte aus:

### Phase 1: Aktuelle Daten abrufen (OSM)

```bash
cd deepscan
python deepscan_main.py --source osm
```

**Hinweis:** Wikidata wird übersprungen (Artikel ändern sich selten). Bei Bedarf separat mit `--source wikidata` oder `--full` ausführen.

### Phase 2: Seed-Daten exportieren

```bash
python deepscan_main.py --seed
```

### Phase 3: Daten zusammenführen (Merge)

```bash
python merge_and_export.py
```

**Was passiert:**
- OSM-Daten werden mit Seed-Daten gemerged
- Nur Locations im MSH-Kerngebiet (Bounding Box 51.25-51.70°N, 10.80-11.80°E)
- Duplikate werden entfernt (50m Radius, gleiche Kategorie)
- Seed-Daten haben Priorität

**Outputs:**
- `output/merged/msh_merged_*.json` - Gemergte Daten
- `output/merged/msh_merged_*.geojson` - GeoJSON für Karten
- `output/merged/msh_firestore_merged_*.json` - Firestore-Format
- `assets/data/locations.json` - Flutter Assets

### Phase 4: Flutter Assets aktualisieren

```bash
# Gemergte Daten in Flutter-Assets kopieren
copy assets\data\locations.json lib\assets\data\locations.json
copy assets\data\msh_locations.geojson lib\assets\data\msh_seed_locations.geojson
```

### Phase 5: Flutter Web bauen

```bash
cd ..
flutter build web --release
```

### Phase 6: Deployment (Vercel)

```bash
git add -A
git commit -m "feat: DeepScan Refresh - [ANZAHL] Locations aktualisiert"
git push
```

### Phase 7: Verifizierung

```bash
# Nach 1-2 Minuten prüfen
curl -s "https://www.msh-map.de/assets/lib/assets/data/locations.json" | head -c 200
```

---

## Erwartete Ergebnisse

| Metrik | Typischer Wert |
|--------|----------------|
| OSM Locations (roh) | ~7000+ |
| Nach MSH-Filter | ~1700 |
| Nach Deduplizierung | ~1650-1700 |
| Seed Locations | 58 |
| **Gesamt gemerged** | **~1700-1750** |

---

## Optionale Parameter

### Nur bestimmte Schritte ausführen

- **Nur OSM aktualisieren:** `python deepscan_main.py --source osm`
- **Nur Seed exportieren:** `python deepscan_main.py --seed`
- **Nur Merge (ohne neuen Scan):** `python merge_and_export.py`
- **Vollständig inkl. Wikidata:** `python deepscan_main.py --full`

### Wikidata separat (bei Bedarf)

```bash
python deepscan_main.py --source wikidata
```

---

## Fehlerbehebung

### Wikidata Timeout
- Normal, da SPARQL-Queries lange dauern können
- Nicht kritisch - OSM-Daten sind ausreichend

### Keine OSM-Daten
- Overpass API evtl. überlastet
- Warten und erneut versuchen

### Flutter Build schlägt fehl
- `flutter clean && flutter pub get` ausführen
- Erneut bauen

---

## Datenquellen-Übersicht

| Quelle | Update-Frequenz | Priorität |
|--------|-----------------|-----------|
| **Seed-Daten** | Manuell kuratiert | Höchste |
| **OSM** | Live-Daten | Hoch |
| **Events** | Wöchentlich (KW) | Mittel |
| **Notices** | Bei Bedarf | Mittel |
| **Wikidata** | Selten (monatlich) | Niedrig |

---

## Zusammenfassung

**Kurzbefehl:** `start deepsearch_refresh`

**Ausführungszeit:** ~3-5 Minuten (ohne Wikidata)

**Ergebnis:** Aktualisierte Location-Daten live auf msh-map.de
