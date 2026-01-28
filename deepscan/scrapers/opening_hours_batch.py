#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Opening Hours Batch Scraper
Holt ALLE Öffnungszeiten aus MSH in einer Abfrage und matched mit bestehenden POIs.
"""

import json
import os
import time
from typing import Dict, List, Any
from math import radians, sin, cos, sqrt, atan2
import requests


class OpeningHoursBatch:
    """Batch-Scraper für Öffnungszeiten"""

    OVERPASS_URL = "https://overpass-api.de/api/interpreter"

    # MSH Bounding Box
    BBOX = {
        "south": 51.25,
        "west": 10.80,
        "north": 51.70,
        "east": 11.80
    }

    MATCH_RADIUS = 100  # Meter für POI-Matching

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MSH-Map-OpeningHours/1.0 (Educational; contact@kolan-systems.de)'
        })

    def haversine(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Distanz in Metern"""
        R = 6371000
        lat1_rad, lat2_rad = radians(lat1), radians(lat2)
        delta_lat = radians(lat2 - lat1)
        delta_lon = radians(lon2 - lon1)
        a = sin(delta_lat/2)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_lon/2)**2
        return R * 2 * atan2(sqrt(a), sqrt(1-a))

    def fetch_all_opening_hours(self) -> List[Dict]:
        """Holt ALLE POIs mit Öffnungszeiten aus MSH in einer Abfrage"""

        bbox = f"{self.BBOX['south']},{self.BBOX['west']},{self.BBOX['north']},{self.BBOX['east']}"

        query = f"""
[out:json][timeout:180];
(
  node["opening_hours"]({bbox});
  way["opening_hours"]({bbox});
);
out center tags;
"""

        print("Fetching ALL opening hours from OSM (single request)...")
        print(f"Bounding Box: {self.BBOX}")

        try:
            response = self.session.post(
                self.OVERPASS_URL,
                data={"data": query},
                timeout=180
            )
            response.raise_for_status()
            data = response.json()

            elements = data.get('elements', [])
            print(f"Found {len(elements)} POIs with opening_hours in OSM")

            # Parse zu einfacherem Format
            results = []
            for elem in elements:
                tags = elem.get('tags', {})

                # Koordinaten
                if elem['type'] == 'node':
                    lat, lon = elem.get('lat'), elem.get('lon')
                elif 'center' in elem:
                    lat, lon = elem['center'].get('lat'), elem['center'].get('lon')
                else:
                    continue

                if not lat or not lon:
                    continue

                results.append({
                    'name': tags.get('name', ''),
                    'lat': lat,
                    'lon': lon,
                    'opening_hours': tags.get('opening_hours', ''),
                    'amenity': tags.get('amenity', ''),
                    'shop': tags.get('shop', ''),
                    'healthcare': tags.get('healthcare', ''),
                })

            return results

        except Exception as e:
            print(f"Error: {e}")
            return []

    def match_and_enrich(self, osm_data: List[Dict], filepath: str) -> Dict:
        """Matched OSM-Daten mit einer JSON-Datei und reichert an"""

        if not os.path.exists(filepath):
            return {'error': 'file_not_found'}

        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # Datenstruktur
        if isinstance(data, dict) and 'data' in data:
            items = data['data']
            wrapper = data
        else:
            items = data if isinstance(data, list) else [data]
            wrapper = None

        enriched = 0
        already_has = 0

        for item in items:
            # Hat bereits Öffnungszeiten?
            existing = item.get('openingHours') or item.get('opening_hours') or item.get('openingHoursRaw')
            if existing and str(existing).strip():
                already_has += 1
                continue

            # Koordinaten
            lat = item.get('latitude') or item.get('lat')
            lon = item.get('longitude') or item.get('lon')
            name = item.get('name', '').lower()

            if not lat or not lon:
                continue

            # Suche besten Match in OSM-Daten
            best_match = None
            best_distance = float('inf')

            for osm in osm_data:
                dist = self.haversine(lat, lon, osm['lat'], osm['lon'])

                if dist > self.MATCH_RADIUS:
                    continue

                # Name-Bonus
                osm_name = osm.get('name', '').lower()
                if osm_name and name:
                    if osm_name in name or name in osm_name:
                        dist *= 0.5  # Halbiere Distanz bei Name-Match

                if dist < best_distance:
                    best_distance = dist
                    best_match = osm

            if best_match:
                hours = best_match.get('opening_hours')
                if hours:
                    if 'openingHours' in item or 'opening_hours' not in item:
                        item['openingHours'] = hours
                    else:
                        item['opening_hours'] = hours
                    enriched += 1

        # Speichern
        if enriched > 0:
            output_data = wrapper if wrapper else items
            if wrapper:
                wrapper['data'] = items

            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(output_data, f, ensure_ascii=False, indent=2)

        return {
            'total': len(items),
            'enriched': enriched,
            'already_has': already_has,
            'missing': len(items) - enriched - already_has
        }

    def run(self):
        """Hauptmethode"""

        base_path = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'data')

        files = [
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
        print("OPENING HOURS BATCH ENRICHER")
        print("="*60)

        # 1. Hole alle OSM-Daten mit Öffnungszeiten
        osm_data = self.fetch_all_opening_hours()

        if not osm_data:
            print("No OSM data fetched. Aborting.")
            return

        # 2. Matche mit jeder Datei
        total_enriched = 0

        print("\n" + "-"*60)
        print("Matching with local files...")
        print("-"*60)

        for filepath in files:
            filename = os.path.basename(filepath)

            if not os.path.exists(filepath):
                print(f"  {filename:30} [SKIP - not found]")
                continue

            result = self.match_and_enrich(osm_data, filepath)

            if 'error' in result:
                print(f"  {filename:30} [ERROR]")
            else:
                total_enriched += result['enriched']
                print(f"  {filename:30} +{result['enriched']:3} new (had: {result['already_has']}, missing: {result['missing']})")

        print("\n" + "="*60)
        print(f"DONE - {total_enriched} opening hours added")
        print("="*60)


if __name__ == "__main__":
    batch = OpeningHoursBatch()
    batch.run()
