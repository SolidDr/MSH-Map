"""
MSH DeepScan - Datenanreicherung und Duplikat-Erkennung

Funktionen:
1. Duplikat-Erkennung über mehrere Quellen (OSM, Wikidata, Seed)
2. Geocoding (Adressen → Koordinaten)
3. Reverse Geocoding (Koordinaten → Ortsname)
4. Kategorisierungs-Verbesserung
5. Metadaten-Anreicherung
"""

import json
import math
from typing import List, Dict, Tuple, Optional, Set
from pathlib import Path
from collections import defaultdict
from datetime import datetime

# Fuzzy String Matching
try:
    from rapidfuzz import fuzz, process
    FUZZY_AVAILABLE = True
except ImportError:
    try:
        from fuzzywuzzy import fuzz, process
        FUZZY_AVAILABLE = True
    except ImportError:
        FUZZY_AVAILABLE = False
        print("⚠️  Warnung: rapidfuzz/fuzzywuzzy nicht installiert. String-Matching limitiert.")


class LocationEnricher:
    """
    Anreicherung und Deduplizierung von Location-Daten
    """

    # Distanz-Schwellwerte (in Metern)
    DISTANCE_EXACT = 50       # < 50m = sehr wahrscheinlich Duplikat
    DISTANCE_CLOSE = 150      # < 150m = wahrscheinlich Duplikat (mit Name-Match)
    DISTANCE_NEAR = 500       # < 500m = möglicherweise Duplikat (nur mit hohem Name-Match)

    # Fuzzy-Match Schwellwerte (0-100)
    FUZZY_HIGH = 90           # >= 90 = sehr gute Übereinstimmung
    FUZZY_MEDIUM = 75         # >= 75 = gute Übereinstimmung
    FUZZY_LOW = 60            # >= 60 = mögliche Übereinstimmung

    # Prioritäten für Metadaten (höher = bevorzugt)
    SOURCE_PRIORITY = {
        'seed': 3,       # Manuell kuratiert = höchste Qualität
        'wikidata': 2,   # Strukturierte Daten
        'osm': 1         # Community-Daten
    }

    def __init__(self):
        self.stats = {
            'total_input': 0,
            'duplicates_found': 0,
            'merged_locations': 0,
            'exact_matches': 0,
            'close_matches': 0,
            'near_matches': 0,
        }

    def haversine_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """
        Berechnet die Distanz zwischen zwei Koordinaten in Metern (Haversine-Formel)
        """
        R = 6371000  # Erdradius in Metern

        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)

        a = math.sin(delta_phi / 2) ** 2 + \
            math.cos(phi1) * math.cos(phi2) * \
            math.sin(delta_lambda / 2) ** 2

        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

        return R * c

    def normalize_name(self, name: str) -> str:
        """
        Normalisiert Namen für besseren Vergleich
        """
        if not name:
            return ""

        # Lowercase
        normalized = name.lower()

        # Entferne häufige Suffixe/Präfixe
        remove_words = [
            'museum', 'schloss', 'burg', 'spielplatz', 'bad', 'freibad',
            'schwimmbad', 'tierpark', 'zoo', 'park', 'kirche', 'ruine',
            'the', 'der', 'die', 'das'
        ]

        for word in remove_words:
            normalized = normalized.replace(word, '').strip()

        # Entferne Sonderzeichen
        normalized = ''.join(c for c in normalized if c.isalnum() or c.isspace())

        # Multiple spaces zu single space
        normalized = ' '.join(normalized.split())

        return normalized

    def calculate_match_score(self, loc1: Dict, loc2: Dict) -> Tuple[float, str]:
        """
        Berechnet einen Match-Score zwischen zwei Locations

        Returns:
            (score: float, reason: str)
            score: 0.0 - 1.0 (0 = kein Match, 1 = perfektes Match)
        """
        # 1. Distanz-Check
        distance = self.haversine_distance(
            loc1['latitude'], loc1['longitude'],
            loc2['latitude'], loc2['longitude']
        )

        # Zu weit entfernt = kein Match
        if distance > self.DISTANCE_NEAR:
            return 0.0, f"zu_weit ({distance:.0f}m)"

        # 2. Name-Match (wenn verfügbar)
        name1 = self.normalize_name(loc1.get('name', ''))
        name2 = self.normalize_name(loc2.get('name', ''))

        fuzzy_score = 0
        if name1 and name2 and FUZZY_AVAILABLE:
            fuzzy_score = fuzz.ratio(name1, name2)

        # 3. Kombinierter Score
        if distance < self.DISTANCE_EXACT:
            # < 50m = sehr wahrscheinlich Duplikat
            base_score = 0.9
            if fuzzy_score >= self.FUZZY_MEDIUM:
                return 1.0, f"exact_match ({distance:.0f}m, name:{fuzzy_score}%)"
            return base_score, f"exact_location ({distance:.0f}m)"

        elif distance < self.DISTANCE_CLOSE:
            # < 150m = wahrscheinlich Duplikat, wenn Namen ähnlich
            if fuzzy_score >= self.FUZZY_HIGH:
                return 0.95, f"close_match_high ({distance:.0f}m, name:{fuzzy_score}%)"
            elif fuzzy_score >= self.FUZZY_MEDIUM:
                return 0.85, f"close_match_medium ({distance:.0f}m, name:{fuzzy_score}%)"
            elif fuzzy_score >= self.FUZZY_LOW:
                return 0.70, f"close_match_low ({distance:.0f}m, name:{fuzzy_score}%)"
            else:
                return 0.0, f"close_no_name_match ({distance:.0f}m, name:{fuzzy_score}%)"

        else:  # < 500m
            # < 500m = möglicherweise Duplikat, nur bei sehr guter Name-Übereinstimmung
            if fuzzy_score >= self.FUZZY_HIGH:
                return 0.80, f"near_match ({distance:.0f}m, name:{fuzzy_score}%)"
            else:
                return 0.0, f"near_no_name_match ({distance:.0f}m, name:{fuzzy_score}%)"

    def merge_location_data(self, locations: List[Dict]) -> Dict:
        """
        Merged mehrere Locations zu einer einzigen, bevorzugt hochwertige Quellen

        Priorität: seed > wikidata > osm
        """
        if not locations:
            return {}

        # Sortiere nach Priorität (höchste zuerst)
        sorted_locs = sorted(
            locations,
            key=lambda x: self.SOURCE_PRIORITY.get(x.get('source', 'unknown'), 0),
            reverse=True
        )

        # Base = höchste Priorität
        merged = sorted_locs[0].copy()

        # Sammle alle IDs und Quellen
        merged['original_ids'] = []
        merged['sources'] = []

        for loc in sorted_locs:
            merged['original_ids'].append(loc.get('id', 'unknown'))
            source = loc.get('source', 'unknown')
            if source not in merged['sources']:
                merged['sources'].append(source)

        # Ergänze fehlende Felder aus niedrigeren Prioritäten
        for loc in sorted_locs[1:]:
            for key, value in loc.items():
                # Ergänze nur wenn:
                # 1. Feld fehlt in merged ODER
                # 2. Feld ist None/leer in merged UND value ist vorhanden
                if key not in merged or merged[key] in [None, '', []]:
                    merged[key] = value

        # Neue ID basierend auf Quellen
        if len(merged['sources']) > 1:
            merged['id'] = f"merged_{merged['original_ids'][0]}"

        return merged

    def deduplicate_locations(self, locations: List[Dict],
                             min_score: float = 0.70) -> Tuple[List[Dict], List[Dict]]:
        """
        Findet und merged Duplikate in einer Location-Liste

        Args:
            locations: Liste von Location-Dicts
            min_score: Minimaler Match-Score (0.0 - 1.0) für Duplikat-Erkennung

        Returns:
            (unique_locations, duplicate_info)
        """
        if not locations:
            return [], []

        self.stats['total_input'] = len(locations)

        print(f"\n🔍 Duplikat-Erkennung: {len(locations)} Locations")
        print(f"   Min-Score: {min_score}")
        print(f"   Fuzzy-Matching: {'✓' if FUZZY_AVAILABLE else '✗ (deaktiviert)'}\n")

        # Clustere nach groben Koordinaten (0.01° ≈ 1km)
        # Reduziert Vergleiche von O(n²) auf O(n*k) wo k << n
        grid = defaultdict(list)
        for loc in locations:
            lat_grid = round(loc['latitude'] * 100)  # 0.01° Raster
            lon_grid = round(loc['longitude'] * 100)
            grid[(lat_grid, lon_grid)].append(loc)

        print(f"📐 Grid-Clustering: {len(grid)} Zellen\n")

        # Duplikat-Gruppen
        duplicate_groups = []
        processed = set()

        # Durchsuche jede Grid-Zelle + Nachbarn
        for (lat_grid, lon_grid), cell_locs in grid.items():
            for loc in cell_locs:
                loc_id = id(loc)  # Python object ID für Tracking

                if loc_id in processed:
                    continue

                # Finde Matches in aktueller und benachbarten Zellen
                candidates = []
                for dlat in [-1, 0, 1]:
                    for dlon in [-1, 0, 1]:
                        neighbor_key = (lat_grid + dlat, lon_grid + dlon)
                        candidates.extend(grid.get(neighbor_key, []))

                # Finde Duplikate
                group = [loc]
                for candidate in candidates:
                    if id(candidate) == loc_id or id(candidate) in processed:
                        continue

                    score, reason = self.calculate_match_score(loc, candidate)

                    if score >= min_score:
                        group.append(candidate)
                        processed.add(id(candidate))

                        # Statistiken
                        if 'exact' in reason:
                            self.stats['exact_matches'] += 1
                        elif 'close' in reason:
                            self.stats['close_matches'] += 1
                        elif 'near' in reason:
                            self.stats['near_matches'] += 1

                processed.add(loc_id)

                if len(group) > 1:
                    duplicate_groups.append(group)
                    self.stats['duplicates_found'] += len(group) - 1

        # Merge Duplikate
        print(f"🔗 Gefundene Duplikat-Gruppen: {len(duplicate_groups)}")

        unique_locations = []
        duplicate_info = []

        # Erstelle Set aller gemergten IDs
        all_merged_ids = set()
        for group in duplicate_groups:
            for loc in group:
                all_merged_ids.add(id(loc))

        # Merge Gruppen
        for group in duplicate_groups:
            merged = self.merge_location_data(group)
            unique_locations.append(merged)
            self.stats['merged_locations'] += 1

            duplicate_info.append({
                'merged_id': merged.get('id'),
                'merged_name': merged.get('name'),
                'sources': merged.get('sources', []),
                'original_count': len(group),
                'original_ids': merged.get('original_ids', [])
            })

        # Füge nicht-duplizierte Locations hinzu
        for loc in locations:
            if id(loc) not in all_merged_ids:
                unique_locations.append(loc)

        print(f"✅ Ergebnis: {len(unique_locations)} eindeutige Locations")
        print(f"   Duplikate entfernt: {self.stats['duplicates_found']}")
        print(f"   Exact Matches: {self.stats['exact_matches']}")
        print(f"   Close Matches: {self.stats['close_matches']}")
        print(f"   Near Matches: {self.stats['near_matches']}\n")

        return unique_locations, duplicate_info


def merge_all_sources(output_dir: Path) -> None:
    """
    Merged alle Datenquellen (Seed, OSM, Wikidata) und entfernt Duplikate
    """
    print("\n" + "="*70)
    print("🎯 MSH DeepScan - Daten-Merge & Deduplizierung")
    print("="*70 + "\n")

    enricher = LocationEnricher()

    # 1. Lade alle Quellen
    all_locations = []
    source_stats = {}

    sources = [
        ('seed', output_dir / 'raw' / 'seed_locations.json'),
        ('osm', output_dir / 'raw' / 'osm_locations.json'),
        ('wikidata', output_dir / 'raw' / 'wikidata_locations.json'),
    ]

    print("📥 Lade Datenquellen:\n")

    for source_name, source_path in sources:
        if source_path.exists():
            with open(source_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                locations = data.get('data', [])

                # Markiere Quelle
                for loc in locations:
                    loc['source'] = source_name

                all_locations.extend(locations)
                source_stats[source_name] = len(locations)
                print(f"   ✓ {source_name:10s}: {len(locations):5d} Locations")
        else:
            print(f"   ⚠ {source_name:10s}: Datei nicht gefunden")
            source_stats[source_name] = 0

    print(f"\n📊 Gesamt: {len(all_locations)} Locations\n")

    if not all_locations:
        print("❌ Keine Daten zum Mergen gefunden!")
        return

    # 2. Deduplizierung
    unique_locations, duplicate_info = enricher.deduplicate_locations(
        all_locations,
        min_score=0.70
    )

    # 3. Statistiken
    print("\n" + "="*70)
    print("📈 MERGE-STATISTIKEN")
    print("="*70 + "\n")

    print(f"Input:")
    for source_name, count in source_stats.items():
        print(f"  {source_name:10s}: {count:5d}")
    print(f"  {'TOTAL':10s}: {len(all_locations):5d}\n")

    print(f"Output:")
    print(f"  Eindeutige Locations: {len(unique_locations)}")
    print(f"  Duplikate entfernt:   {enricher.stats['duplicates_found']}")
    print(f"  Merged Groups:        {len(duplicate_info)}\n")

    # Kategorie-Verteilung
    categories = defaultdict(int)
    cities = defaultdict(int)
    multi_source = 0

    for loc in unique_locations:
        cat = loc.get('category', 'other')
        categories[cat] += 1

        city = loc.get('city', 'Unbekannt')
        cities[city] += 1

        if len(loc.get('sources', [])) > 1:
            multi_source += 1

    print(f"Multi-Source Locations: {multi_source} ({multi_source/len(unique_locations)*100:.1f}%)\n")

    print("Top Kategorien:")
    for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {cat:15s}: {count:4d}")

    print(f"\nTop Städte:")
    for city, count in sorted(cities.items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {city:20s}: {count:4d}")

    # 4. Speichere Ergebnisse
    merged_dir = output_dir / 'merged'
    merged_dir.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

    # JSON
    output_json = merged_dir / f'msh_merged_{timestamp}.json'
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump({
            'meta': {
                'created_at': datetime.now().isoformat(),
                'source': 'MSH DeepScan Merged',
                'version': '1.0',
                'total_locations': len(unique_locations),
                'source_stats': source_stats,
                'duplicates_removed': enricher.stats['duplicates_found'],
            },
            'data': unique_locations
        }, f, ensure_ascii=False, indent=2)

    print(f"\n💾 Gespeichert:")
    print(f"   JSON: {output_json.name}")

    # GeoJSON
    output_geojson = merged_dir / f'msh_merged_{timestamp}.geojson'
    features = []

    for loc in unique_locations:
        features.append({
            'type': 'Feature',
            'geometry': {
                'type': 'Point',
                'coordinates': [loc['longitude'], loc['latitude']]
            },
            'properties': {k: v for k, v in loc.items() if k not in ['latitude', 'longitude']}
        })

    with open(output_geojson, 'w', encoding='utf-8') as f:
        json.dump({
            'type': 'FeatureCollection',
            'metadata': {
                'created_at': datetime.now().isoformat(),
                'total_locations': len(unique_locations),
            },
            'features': features
        }, f, ensure_ascii=False, indent=2)

    print(f"   GeoJSON: {output_geojson.name}")

    # Duplikat-Info
    if duplicate_info:
        dup_file = merged_dir / f'duplicates_{timestamp}.json'
        with open(dup_file, 'w', encoding='utf-8') as f:
            json.dump({
                'total_groups': len(duplicate_info),
                'total_duplicates': enricher.stats['duplicates_found'],
                'groups': duplicate_info
            }, f, ensure_ascii=False, indent=2)
        print(f"   Duplicates: {dup_file.name}")

    print("\n✅ Merge abgeschlossen!\n")


if __name__ == '__main__':
    # Beispiel-Aufruf
    from pathlib import Path

    base_dir = Path(__file__).parent
    output_dir = base_dir / 'output'

    merge_all_sources(output_dir)
