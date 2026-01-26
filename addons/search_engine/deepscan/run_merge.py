"""
MSH DeepScan - Daten-Merge Script

Führt die Zusammenführung aller Datenquellen durch:
- Seed-Daten (msh_complete_*.json)
- OSM-Daten (osm_*.json)
- Wikidata-Daten (wikidata_*.json)
"""

import json
from pathlib import Path
from datetime import datetime
import sys
import os
import io

# Windows Console UTF-8 Support
if os.name == 'nt':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# Füge Parent-Dir zu sys.path für Import hinzu
sys.path.insert(0, str(Path(__file__).parent))

from enrichment_engine import LocationEnricher


def find_latest_file(directory: Path, pattern: str) -> Path | None:
    """Findet die neueste Datei basierend auf Pattern"""
    files = list(directory.glob(pattern))
    if not files:
        return None
    return max(files, key=lambda f: f.stat().st_mtime)


def load_locations_from_file(file_path: Path, source_name: str) -> list[dict]:
    """Lädt Locations aus einer JSON-Datei"""
    if not file_path or not file_path.exists():
        return []

    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    locations = data.get('data', [])

    # Markiere Quelle
    for loc in locations:
        if 'source' not in loc or loc['source'] == 'openstreetmap':
            loc['source'] = source_name

    return locations


def main():
    print("\n" + "="*70)
    print("🎯 MSH DeepScan - Daten-Merge & Deduplizierung")
    print("="*70 + "\n")

    # Finde das Hauptverzeichnis mit deepscan/output
    base_dir = Path(__file__).parent.parent.parent.parent / 'deepscan'
    output_dir = base_dir / 'output'

    # Falls nicht gefunden, versuche alternatives Layout (addons/search_engine/deepscan)
    if not output_dir.exists():
        base_dir = Path(__file__).parent.parent.parent / 'deepscan'
        output_dir = base_dir / 'output'

    # Falls immer noch nicht gefunden, verwende relatives Pfad vom aktuellen Script
    if not output_dir.exists():
        print(f"⚠️  Verwende relatives Pfad von Script-Location")
        # Wir sind in addons/search_engine/deepscan, Daten sind in Lunch-Radar/deepscan
        base_dir = Path(__file__).parent.parent.parent.parent / 'deepscan'
        output_dir = base_dir / 'output'

    print(f"📁 Suchpfad: {output_dir.absolute()}\n")

    # 1. Finde neueste Dateien
    print("📂 Suche Datenquellen...\n")

    seed_file = find_latest_file(output_dir / 'merged', 'msh_complete_*.json')
    osm_file = find_latest_file(output_dir / 'raw', 'osm_*.json')
    wikidata_file = find_latest_file(output_dir / 'raw', 'wikidata_*.json')

    sources = [
        ('seed', seed_file),
        ('osm', osm_file),
        ('wikidata', wikidata_file),
    ]

    # 2. Lade Daten
    all_locations = []
    source_stats = {}

    for source_name, file_path in sources:
        if file_path:
            locations = load_locations_from_file(file_path, source_name)
            all_locations.extend(locations)
            source_stats[source_name] = len(locations)
            print(f"   ✓ {source_name:10s}: {len(locations):5d} Locations")
            print(f"     Datei: {file_path.name}")
        else:
            print(f"   ⚠ {source_name:10s}: Keine Datei gefunden")
            source_stats[source_name] = 0

    print(f"\n📊 Gesamt: {len(all_locations)} Locations vor Merge\n")

    if not all_locations:
        print("❌ Keine Daten zum Mergen gefunden!")
        return

    # 3. Deduplizierung
    enricher = LocationEnricher()
    unique_locations, duplicate_info = enricher.deduplicate_locations(
        all_locations,
        min_score=0.70
    )

    # 4. Statistiken
    from collections import defaultdict

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
        if city:  # Nur zählen wenn nicht leer
            cities[city] += 1

        if isinstance(loc.get('sources'), list) and len(loc.get('sources', [])) > 1:
            multi_source += 1

    print(f"Multi-Source Locations: {multi_source} ({multi_source/len(unique_locations)*100:.1f}%)\n")

    print("Top 10 Kategorien:")
    for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {cat:15s}: {count:4d}")

    print(f"\nTop 10 Städte:")
    for city, count in sorted(cities.items(), key=lambda x: x[1], reverse=True)[:10]:
        if city:  # Nur anzeigen wenn nicht leer
            print(f"  {city:20s}: {count:4d}")

    # 5. Speichere Ergebnisse
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
                'version': '2.0',
                'total_locations': len(unique_locations),
                'source_stats': source_stats,
                'duplicates_removed': enricher.stats['duplicates_found'],
                'merge_stats': {
                    'exact_matches': enricher.stats['exact_matches'],
                    'close_matches': enricher.stats['close_matches'],
                    'near_matches': enricher.stats['near_matches'],
                }
            },
            'data': unique_locations
        }, f, ensure_ascii=False, indent=2)

    print(f"\n💾 Gespeichert:")
    print(f"   JSON: {output_json.name}")
    print(f"   Pfad: {output_json}")

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
    print(f"   Pfad: {output_geojson}")

    # Duplikat-Info
    if duplicate_info:
        dup_file = merged_dir / f'msh_duplicates_{timestamp}.json'
        with open(dup_file, 'w', encoding='utf-8') as f:
            json.dump({
                'meta': {
                    'created_at': datetime.now().isoformat(),
                    'total_groups': len(duplicate_info),
                    'total_duplicates': enricher.stats['duplicates_found'],
                },
                'groups': duplicate_info
            }, f, ensure_ascii=False, indent=2)
        print(f"   Duplicates: {dup_file.name}")
        print(f"   Pfad: {dup_file}")

    # Qualitäts-Report
    quality_report = {
        'meta': {
            'created_at': datetime.now().isoformat(),
            'total_locations': len(unique_locations),
        },
        'source_distribution': source_stats,
        'category_distribution': dict(sorted(categories.items(), key=lambda x: x[1], reverse=True)),
        'city_distribution': dict(sorted(cities.items(), key=lambda x: x[1], reverse=True)[:20]),
        'quality_metrics': {
            'multi_source_count': multi_source,
            'multi_source_percentage': round(multi_source / len(unique_locations) * 100, 2),
            'duplicates_removed': enricher.stats['duplicates_found'],
            'deduplication_rate': round(enricher.stats['duplicates_found'] / len(all_locations) * 100, 2) if all_locations else 0,
        },
        'match_breakdown': {
            'exact_matches': enricher.stats['exact_matches'],
            'close_matches': enricher.stats['close_matches'],
            'near_matches': enricher.stats['near_matches'],
        }
    }

    report_file = output_dir / 'analytics' / f'merge_report_{timestamp}.json'
    report_file.parent.mkdir(exist_ok=True)

    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(quality_report, f, ensure_ascii=False, indent=2)

    print(f"   Report: {report_file.name}")
    print(f"   Pfad: {report_file}")

    print("\n✅ Merge abgeschlossen!\n")

    # Zusammenfassung
    print("="*70)
    print("📊 ZUSAMMENFASSUNG")
    print("="*70 + "\n")
    print(f"Verarbeitete Locations:  {len(all_locations):,}")
    print(f"Eindeutige Locations:    {len(unique_locations):,}")
    print(f"Deduplizierungsrate:     {quality_report['quality_metrics']['deduplication_rate']:.1f}%")
    print(f"Multi-Source Locations:  {multi_source:,} ({quality_report['quality_metrics']['multi_source_percentage']:.1f}%)")
    print()


if __name__ == '__main__':
    main()
