#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MSH DeepScan - Merge & Export
Führt OSM- und Seed-Daten zusammen und exportiert für Firestore und Flutter
"""

import json
import sys
import io
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any
import math

# UTF-8 für stdout
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

class MergeAndExport:
    """Merged Datenquellen und exportiert für verschiedene Ziele"""

    def __init__(self):
        self.base_path = Path(__file__).parent
        self.output_path = self.base_path / "output"
        self.seed_file = self.base_path / "msh_data_seed.json"
        self.flutter_assets = self.base_path.parent / "assets" / "data"

        # MSH Bounding Box (Kerngebiet)
        self.MSH_BBOX = {
            "south": 51.25,  # Enger gefasst für MSH
            "west": 10.80,
            "north": 51.70,
            "east": 11.80
        }

    def load_osm_data(self) -> List[Dict[str, Any]]:
        """Lädt neueste OSM-Daten"""
        raw_path = self.output_path / "raw"
        osm_files = sorted(raw_path.glob("osm_*.json"), reverse=True)

        if not osm_files:
            print("⚠️  Keine OSM-Daten gefunden")
            return []

        latest_osm = osm_files[0]
        print(f"📦 Lade OSM-Daten: {latest_osm.name}")

        with open(latest_osm, 'r', encoding='utf-8') as f:
            data = json.load(f)

        locations = data.get('data', [])
        print(f"   → {len(locations)} Locations")
        return locations

    def load_seed_data(self) -> List[Dict[str, Any]]:
        """Lädt Seed-Daten"""
        if not self.seed_file.exists():
            print("⚠️  Keine Seed-Daten gefunden")
            return []

        print(f"📦 Lade Seed-Daten: {self.seed_file.name}")

        with open(self.seed_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        locations = data.get('data', [])
        print(f"   → {len(locations)} Locations")
        return locations

    def is_in_msh(self, lat: float, lon: float) -> bool:
        """Prüft ob Koordinaten im MSH-Kerngebiet liegen"""
        return (self.MSH_BBOX['south'] <= lat <= self.MSH_BBOX['north'] and
                self.MSH_BBOX['west'] <= lon <= self.MSH_BBOX['east'])

    def deduplicate_by_location(self, locations: List[Dict], threshold_meters: float = 50) -> List[Dict]:
        """Entfernt Duplikate basierend auf Nähe"""

        def haversine_distance(lat1, lon1, lat2, lon2):
            """Berechnet Distanz in Metern"""
            R = 6371000  # Erdradius in Metern
            phi1 = math.radians(lat1)
            phi2 = math.radians(lat2)
            delta_phi = math.radians(lat2 - lat1)
            delta_lambda = math.radians(lon2 - lon1)

            a = math.sin(delta_phi/2)**2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda/2)**2
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))

            return R * c

        unique = []
        for loc in locations:
            lat = loc.get('latitude')
            lon = loc.get('longitude')

            if not lat or not lon:
                continue

            is_duplicate = False
            for existing in unique:
                ex_lat = existing.get('latitude')
                ex_lon = existing.get('longitude')

                if ex_lat and ex_lon:
                    dist = haversine_distance(lat, lon, ex_lat, ex_lon)
                    if dist < threshold_meters:
                        # Gleiche Kategorie = Duplikat
                        if loc.get('category') == existing.get('category'):
                            is_duplicate = True
                            break

            if not is_duplicate:
                unique.append(loc)

        return unique

    def merge_data(self, osm_data: List[Dict], seed_data: List[Dict]) -> List[Dict]:
        """Merged OSM und Seed-Daten (Seed hat Priorität)"""

        print("\n🔀 Merge OSM + Seed Daten...")

        # Seed-Daten haben Priorität - erst hinzufügen
        merged = list(seed_data)
        seed_ids = {loc.get('id') for loc in seed_data}

        # OSM-Daten hinzufügen (nur MSH-Kerngebiet, keine Duplikate)
        osm_in_msh = []
        for loc in osm_data:
            lat = loc.get('latitude')
            lon = loc.get('longitude')

            if lat and lon and self.is_in_msh(lat, lon):
                if loc.get('id') not in seed_ids:
                    osm_in_msh.append(loc)

        print(f"   OSM im MSH-Kerngebiet: {len(osm_in_msh)}")

        # Deduplizieren
        osm_deduplicated = self.deduplicate_by_location(osm_in_msh)
        print(f"   Nach Deduplizierung: {len(osm_deduplicated)}")

        merged.extend(osm_deduplicated)

        print(f"✅ Gesamt: {len(merged)} Locations")
        return merged

    def export_firestore_format(self, locations: List[Dict], output_file: Path) -> None:
        """Exportiert für Firestore"""
        print(f"🔥 Exportiere Firestore-Format...")

        firestore_data = {
            "locations": {},
            "meta": {
                "generated_at": datetime.now().isoformat(),
                "total_count": len(locations),
                "sources": ["seed", "openstreetmap"]
            }
        }

        for loc in locations:
            loc_id = loc.get('id', '')
            if not loc_id:
                continue

            firestore_data["locations"][loc_id] = {
                "name": loc.get('name', ''),
                "displayName": loc.get('displayName', loc.get('name', '')),
                "category": loc.get('category', 'other'),
                "coordinates": {
                    "latitude": loc.get('latitude'),
                    "longitude": loc.get('longitude')
                },
                "city": loc.get('city', ''),
                "address": loc.get('address', ''),
                "description": loc.get('description', ''),
                "website": loc.get('website', ''),
                "phone": loc.get('phone', ''),
                "openingHours": loc.get('openingHours', ''),
                "tags": loc.get('tags', []),
                "source": loc.get('source', 'unknown'),
                "createdAt": datetime.now().isoformat()
            }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(firestore_data, f, ensure_ascii=False, indent=2)

        print(f"✅ Gespeichert: {output_file}")

    def export_geojson(self, locations: List[Dict], output_file: Path) -> None:
        """Exportiert als GeoJSON"""
        print(f"🗺️  Exportiere GeoJSON...")

        features = []
        for loc in locations:
            lat = loc.get('latitude')
            lon = loc.get('longitude')

            if not lat or not lon:
                continue

            feature = {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [lon, lat]
                },
                "properties": {
                    key: value for key, value in loc.items()
                    if key not in ['latitude', 'longitude']
                }
            }
            features.append(feature)

        geojson = {
            "type": "FeatureCollection",
            "features": features,
            "meta": {
                "generated_at": datetime.now().isoformat(),
                "count": len(features)
            }
        }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(geojson, f, ensure_ascii=False, indent=2)

        print(f"✅ Gespeichert: {output_file}")

    def export_flutter_assets(self, locations: List[Dict]) -> None:
        """Exportiert für Flutter Assets"""
        print(f"\n📱 Exportiere Flutter Assets...")

        # Assets-Ordner erstellen
        self.flutter_assets.mkdir(parents=True, exist_ok=True)

        # locations.json
        locations_file = self.flutter_assets / "locations.json"
        locations_data = {
            "meta": {
                "generated_at": datetime.now().isoformat(),
                "count": len(locations)
            },
            "locations": locations
        }

        with open(locations_file, 'w', encoding='utf-8') as f:
            json.dump(locations_data, f, ensure_ascii=False, indent=2)

        print(f"✅ {locations_file}")

        # GeoJSON für Karte
        geojson_file = self.flutter_assets / "msh_locations.geojson"
        self.export_geojson(locations, geojson_file)

    def generate_stats(self, locations: List[Dict]) -> Dict[str, Any]:
        """Generiert Statistiken"""

        categories = {}
        cities = {}
        sources = {}

        for loc in locations:
            cat = loc.get('category', 'other')
            categories[cat] = categories.get(cat, 0) + 1

            city = loc.get('city', 'Unbekannt') or 'Unbekannt'
            cities[city] = cities.get(city, 0) + 1

            source = loc.get('source', 'unknown')
            sources[source] = sources.get(source, 0) + 1

        return {
            "total": len(locations),
            "by_category": dict(sorted(categories.items(), key=lambda x: x[1], reverse=True)),
            "by_city": dict(sorted(cities.items(), key=lambda x: x[1], reverse=True)[:20]),
            "by_source": sources
        }

    def print_summary(self, stats: Dict[str, Any]) -> None:
        """Gibt Zusammenfassung aus"""
        print("\n" + "="*60)
        print("📊 MERGE ZUSAMMENFASSUNG")
        print("="*60)

        print(f"\n📍 Gesamt: {stats['total']} Locations")

        print(f"\n📦 Nach Quelle:")
        for source, count in stats['by_source'].items():
            print(f"   • {source}: {count}")

        print(f"\n🏆 Top-10 Kategorien:")
        for i, (cat, count) in enumerate(list(stats['by_category'].items())[:10], 1):
            print(f"   {i}. {cat}: {count}")

        print(f"\n🏙️  Top-10 Städte:")
        for i, (city, count) in enumerate(list(stats['by_city'].items())[:10], 1):
            print(f"   {i}. {city}: {count}")

        print("\n" + "="*60)

    def run(self):
        """Hauptmethode"""
        print("\n🚀 MSH DeepScan - Merge & Export\n")

        # Daten laden
        osm_data = self.load_osm_data()
        seed_data = self.load_seed_data()

        if not osm_data and not seed_data:
            print("❌ Keine Daten zum Mergen!")
            return

        # Mergen
        merged = self.merge_data(osm_data, seed_data)

        # Timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        # Exports
        merged_path = self.output_path / "merged"
        merged_path.mkdir(exist_ok=True)

        # JSON
        json_file = merged_path / f"msh_merged_{timestamp}.json"
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump({"meta": {"generated_at": datetime.now().isoformat()}, "data": merged},
                     f, ensure_ascii=False, indent=2)
        print(f"✅ JSON: {json_file}")

        # GeoJSON
        geojson_file = merged_path / f"msh_merged_{timestamp}.geojson"
        self.export_geojson(merged, geojson_file)

        # Firestore
        firestore_file = merged_path / f"msh_firestore_merged_{timestamp}.json"
        self.export_firestore_format(merged, firestore_file)

        # Flutter Assets
        self.export_flutter_assets(merged)

        # Statistiken
        stats = self.generate_stats(merged)

        # Analytics
        analytics_path = self.output_path / "analytics"
        analytics_path.mkdir(exist_ok=True)
        analytics_file = analytics_path / f"merged_stats_{timestamp}.json"
        with open(analytics_file, 'w', encoding='utf-8') as f:
            json.dump(stats, f, ensure_ascii=False, indent=2)
        print(f"✅ Analytics: {analytics_file}")

        # Zusammenfassung
        self.print_summary(stats)

        print(f"\n✅ Alle Exports erfolgreich!")
        print(f"📁 Output: {self.output_path}")


if __name__ == "__main__":
    merger = MergeAndExport()
    merger.run()
