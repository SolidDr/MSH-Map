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

### Phase 3.5: FAKE-CHECK (KRITISCH!)

```bash
cd tools
python fake_checker.py --remove-suspicious --save-cleaned ../output/merged/msh_firestore_CLEANED.json
```

**WICHTIG:** Dieser Schritt ist MANDATORY! Er verhindert, dass:
- Halluzinierte Daten in die Produktion gelangen
- Fake-Aerzte, Anlaufstellen, etc. angezeigt werden
- Nicht-verifizierte Eintraege live gehen

**Was passiert:**
- Prueft alle Eintraege auf verifizierte Quellen (OSM/Wikidata)
- Entfernt bekannte Fake-Eintraege (Blacklist)
- Entfernt verdaechtige Eintraege ohne Quelle
- Erstellt bereinigte Datei

**Bei Fehler (Exit Code 1 oder 2):**
- STOPP! Nicht weitermachen!
- Report pruefen: `output/analytics/fake_check_report.json`
- Verdaechtige Eintraege manuell verifizieren oder entfernen

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
| Seed Locations (VERIFIZIERT) | 13 |
| Nach Fake-Check | ~1550-1600 |
| **Gesamt sauber** | **~1550-1600** |

**WICHTIG:** Seed-Daten enthalten NUR verifizierte Eintraege mit `verifiable_url`!

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

### Notices (Straßensperrungen, Warnungen) aktualisieren

```bash
cd scrapers
python notice_scraper.py --merge
```

**Was passiert:**
- Scrapt mansfeldsuedharz.de/baustellenservice
- Scrapt sangerhausen.de Bekanntmachungen
- Scrapt eisleben.eu Bekanntmachungen
- Scrapt lokale Blogs (Welbsleben, etc.)
- Generiert Route-Koordinaten für Polyline-Darstellung
- Merged mit bestehenden manuellen Notices

**Output:**
- `data/notices/notices_scraped.json` - Neue Notices

**Danach:** Manuelle Prüfung der notices_scraped.json und Übernahme in notices_current.json

```bash
# Koordinaten validieren
cd ../tools
python validate_notices.py --verbose
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

| Quelle | Update-Frequenz | Priorität | Vertrauenswuerdig |
|--------|-----------------|-----------|-------------------|
| **OSM** | Live-Daten | Hoechste | JA (automatisch) |
| **Wikidata** | Selten (monatlich) | Hoch | JA (automatisch) |
| **Seed-Daten (VERIFIZIERT)** | Manuell kuratiert | Mittel | JA (mit URL) |
| **Events** | Woechentlich (KW) | Mittel | Manuell pruefen |
| **Notices** | Bei Bedarf | Mittel | Manuell pruefen |

**NIEMALS** ungepruefte Daten aus anderen Quellen hinzufuegen!

---

## Zusammenfassung

**Kurzbefehl:** `start deepsearch_refresh`

**Ausführungszeit:** ~3-5 Minuten (ohne Wikidata)

**Ergebnis:** Aktualisierte Location-Daten live auf msh-map.de
