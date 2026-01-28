#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Opening Hours Enricher
Reichert bestehende POI-Daten mit Öffnungszeiten aus OSM an.
"""

import json
import os
import time
from typing import Dict, List, Any, Optional
from math import radians, sin, cos, sqrt, atan2
import requests


class OpeningHoursEnricher:
    """Reichert POIs mit Öffnungszeiten aus OSM an"""

    OVERPASS_URL = "https://overpass-api.de/api/interpreter"
    SEARCH_RADIUS = 50  # Meter - Suchradius um POI
    REQUEST_TIMEOUT = 30

    def __init__(self, rate_limit: float = 1.0):
        self.rate_limit = rate_limit
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MSH-Map-OpeningHours/1.0 (Educational; contact@kolan-systems.de)'
        })
        self.stats = {
            'total': 0,
            'enriched': 0,
            'already_has': 0,
            'not_found': 0,
            'errors': 0
        }

    def haversine_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Berechnet Distanz zwischen zwei Koordinaten in Metern"""
        R = 6371000  # Erdradius in Metern

        lat1_rad = radians(lat1)
        lat2_rad = radians(lat2)
        delta_lat = radians(lat2 - lat1)
        delta_lon = radians(lon2 - lon1)

        a = sin(delta_lat/2)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_lon/2)**2
        c = 2 * atan2(sqrt(a), sqrt(1-a))

        return R * c

    def query_osm_opening_hours(self, lat: float, lon: float, name: str) -> Optional[str]:
        """Fragt OSM nach Öffnungszeiten für einen Standort"""

        query = f"""
[out:json][timeout:{self.REQUEST_TIMEOUT}];
(
  node(around:{self.SEARCH_RADIUS},{lat},{lon})["opening_hours"];
  way(around:{self.SEARCH_RADIUS},{lat},{lon})["opening_hours"];
);
out tags;
"""

        try:
            response = self.session.post(
                self.OVERPASS_URL,
                data={"data": query},
                timeout=self.REQUEST_TIMEOUT
            )
            response.raise_for_status()
            data = response.json()

            elements = data.get('elements', [])
            if not elements:
                return None

            # Suche nach bestem Match (Name-Matching)
            name_lower = name.lower()

            for elem in elements:
                tags = elem.get('tags', {})
                elem_name = tags.get('name', '').lower()

                # Exakter oder Teil-Match
                if elem_name and (elem_name in name_lower or name_lower in elem_name):
                    return tags.get('opening_hours')

            # Kein Name-Match, nimm ersten Treffer
            return elements[0].get('tags', {}).get('opening_hours')

        except Exception as e:
            print(f"    [ERROR] OSM Query: {e}")
            return None

    def enrich_file(self, filepath: str, dry_run: bool = False) -> Dict[str, Any]:
        """Reichert eine JSON-Datei mit Öffnungszeiten an"""

        print(f"\n{'='*60}")
        print(f"Processing: {filepath}")
        print(f"{'='*60}")

        if not os.path.exists(filepath):
            print(f"[SKIP] File not found")
            return {'error': 'file_not_found'}

        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # Datenstruktur erkennen
        if isinstance(data, dict) and 'data' in data:
            items = data['data']
            wrapper = data
        elif isinstance(data, list):
            items = data
            wrapper = None
        else:
            items = [data]
            wrapper = None

        enriched_count = 0
        already_has_count = 0
        not_found_count = 0

        for i, item in enumerate(items):
            name = item.get('name', 'Unknown')

            # Koordinaten finden
            lat = item.get('latitude') or item.get('lat')
            lon = item.get('longitude') or item.get('lon')

            if not lat or not lon:
                print(f"  [{i+1}/{len(items)}] {name[:30]:30} - NO COORDS")
                continue

            # Hat bereits Öffnungszeiten?
            existing = (
                item.get('openingHours') or
                item.get('opening_hours') or
                item.get('openingHoursRaw')
            )

            if existing and str(existing).strip():
                already_has_count += 1
                continue

            # OSM abfragen
            print(f"  [{i+1}/{len(items)}] {name[:30]:30}", end=" ", flush=True)

            if not dry_run:
                time.sleep(self.rate_limit)
                hours = self.query_osm_opening_hours(lat, lon, name)
            else:
                hours = None

            if hours:
                # Öffnungszeiten gefunden
                if 'openingHours' in item or 'opening_hours' not in item:
                    item['openingHours'] = hours
                else:
                    item['opening_hours'] = hours

                enriched_count += 1
                print(f"[FOUND] {hours[:40]}...")
            else:
                not_found_count += 1
                print(f"[NOT FOUND]")

        # Statistiken aktualisieren
        self.stats['total'] += len(items)
        self.stats['enriched'] += enriched_count
        self.stats['already_has'] += already_has_count
        self.stats['not_found'] += not_found_count

        # Speichern
        if not dry_run and enriched_count > 0:
            output_data = wrapper if wrapper else items
            if wrapper:
                wrapper['data'] = items

            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(output_data, f, ensure_ascii=False, indent=2)

            print(f"\n[SAVED] {enriched_count} new opening hours added")

        return {
            'total': len(items),
            'enriched': enriched_count,
            'already_has': already_has_count,
            'not_found': not_found_count
        }

    def enrich_all(self, base_path: str = None, dry_run: bool = False):
        """Reichert alle relevanten JSON-Dateien an"""

        if base_path is None:
            base_path = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'data')

        files_to_process = [
            os.path.join(base_path, 'health', 'doctors.json'),
            os.path.join(base_path, 'health', 'pharmacies.json'),
            os.path.join(base_path, 'health', 'hospitals.json'),
            os.path.join(base_path, 'health', 'physiotherapy.json'),
            os.path.join(base_path, 'health', 'care_services.json'),
            os.path.join(base_path, 'civic', 'government.json'),
            os.path.join(base_path, 'civic', 'youth_centres.json'),
            os.path.join(base_path, 'civic', 'social_facilities.json'),
            os.path.join(base_path, 'nightlife', 'venues.json'),
        ]

        print("\n" + "="*60)
        print("OPENING HOURS ENRICHER")
        print("="*60)
        print(f"Mode: {'DRY RUN' if dry_run else 'LIVE'}")
        print(f"Files to process: {len(files_to_process)}")

        results = {}

        for filepath in files_to_process:
            if os.path.exists(filepath):
                results[filepath] = self.enrich_file(filepath, dry_run)

        # Zusammenfassung
        print("\n" + "="*60)
        print("SUMMARY")
        print("="*60)
        print(f"Total POIs processed:    {self.stats['total']}")
        print(f"Already had hours:       {self.stats['already_has']}")
        print(f"Newly enriched:          {self.stats['enriched']}")
        print(f"Not found in OSM:        {self.stats['not_found']}")
        print(f"Errors:                  {self.stats['errors']}")

        return results


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Enrich POIs with opening hours from OSM')
    parser.add_argument('--dry-run', action='store_true', help='Only show what would be done')
    parser.add_argument('--file', type=str, help='Process single file')
    parser.add_argument('--rate-limit', type=float, default=1.0, help='Seconds between requests')
    args = parser.parse_args()

    enricher = OpeningHoursEnricher(rate_limit=args.rate_limit)

    if args.file:
        enricher.enrich_file(args.file, dry_run=args.dry_run)
    else:
        enricher.enrich_all(dry_run=args.dry_run)


if __name__ == "__main__":
    main()
