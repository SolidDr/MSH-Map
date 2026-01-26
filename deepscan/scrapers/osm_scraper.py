#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OpenStreetMap Scraper via Overpass API
Sammelt POIs aus der erweiterten MSH-Region
"""

import json
import time
from typing import List, Dict, Any
import requests


class OSMScraper:
    """Scraper für OpenStreetMap Daten via Overpass API"""

    # Erweiterte Bounding Box (+20km um MSH)
    BBOX = {
        "south": 51.07,  # Nordhausen
        "west": 10.50,   # Bad Sachsa
        "north": 51.93,  # Halle-Umland
        "east": 12.10    # Halle
    }

    OVERPASS_URL = "https://overpass-api.de/api/interpreter"
    REQUEST_TIMEOUT = 180  # 3 Minuten für große Abfragen

    # OSM Tags → MSH Categories Mapping
    TAG_MAPPING = {
        # Spielplätze
        ("leisure", "playground"): "playground",

        # Schwimmbäder
        ("leisure", "swimming_pool"): "pool",
        ("leisure", "swimming_area"): "pool",
        ("amenity", "swimming_pool"): "pool",

        # Natur & Parks
        ("leisure", "park"): "nature",
        ("leisure", "garden"): "nature",
        ("natural", "peak"): "nature",
        ("natural", "waterfall"): "nature",

        # Museen
        ("tourism", "museum"): "museum",
        ("amenity", "arts_centre"): "museum",

        # Kultur
        ("historic", "castle"): "castle",
        ("historic", "ruins"): "castle",
        ("historic", "monument"): "culture",
        ("tourism", "attraction"): "culture",

        # Gastro
        ("amenity", "restaurant"): "restaurant",
        ("amenity", "cafe"): "cafe",
        ("amenity", "fast_food"): "imbiss",
        ("amenity", "biergarten"): "restaurant",

        # Sport & Freizeit
        ("leisure", "sports_centre"): "sport",
        ("sport", "climbing"): "adventure",
        ("leisure", "adventure_park"): "adventure",

        # Zoo & Tiere
        ("tourism", "zoo"): "zoo",
        ("tourism", "animal_park"): "farm",

        # Indoor
        ("leisure", "indoor_play"): "indoor",
        ("amenity", "cinema"): "indoor",
    }

    def __init__(self, rate_limit: float = 2.0):
        """
        Args:
            rate_limit: Sekunden zwischen Requests (Overpass empfiehlt >1s)
        """
        self.rate_limit = rate_limit
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MSH-Map-Scraper/2.0 (Educational Purpose; contact@kolan-systems.de)'
        })

    def build_overpass_query(self) -> str:
        """Erstellt Overpass QL Query für alle relevanten POI-Typen"""

        bbox_str = f"{self.BBOX['south']},{self.BBOX['west']},{self.BBOX['north']},{self.BBOX['east']}"

        # Sammle alle OSM Tags
        tag_queries = []
        for (key, value), _ in self.TAG_MAPPING.items():
            tag_queries.append(f'  node["{key}"="{value}"]({bbox_str});')
            tag_queries.append(f'  way["{key}"="{value}"]({bbox_str});')

        query = f"""
[out:json][timeout:{self.REQUEST_TIMEOUT}];
(
{''.join(tag_queries)}
);
out center tags;
"""
        return query

    def fetch_osm_data(self) -> Dict[str, Any]:
        """Führt Overpass Query aus und gibt Rohdaten zurück"""

        query = self.build_overpass_query()

        print(f"🌍 Frage Overpass API ab...")
        print(f"   Bounding Box: {self.BBOX}")
        print(f"   Timeout: {self.REQUEST_TIMEOUT}s")

        try:
            response = self.session.post(
                self.OVERPASS_URL,
                data={"data": query},
                timeout=self.REQUEST_TIMEOUT
            )
            response.raise_for_status()

            data = response.json()
            element_count = len(data.get('elements', []))
            print(f"✅ {element_count} OSM-Elemente gefunden")

            return data

        except requests.exceptions.Timeout:
            print(f"⏱️  Timeout nach {self.REQUEST_TIMEOUT}s - Query zu groß?")
            return {"elements": []}
        except requests.exceptions.RequestException as e:
            print(f"❌ Fehler bei Overpass API: {e}")
            return {"elements": []}

    def map_category(self, tags: Dict[str, str]) -> str:
        """Mappt OSM Tags zu MSH Kategorie"""

        for (key, value), category in self.TAG_MAPPING.items():
            if tags.get(key) == value:
                return category

        return "other"

    def extract_coordinates(self, element: Dict[str, Any]) -> tuple:
        """Extrahiert Koordinaten aus OSM Element (Node oder Way)"""

        if element['type'] == 'node':
            return (element.get('lat'), element.get('lon'))
        elif element['type'] == 'way' and 'center' in element:
            # Ways haben ein 'center' Property wenn 'out center' verwendet wird
            return (element['center'].get('lat'), element['center'].get('lon'))
        else:
            return (None, None)

    def parse_osm_elements(self, osm_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Konvertiert OSM Elemente zu MSH Location Format"""

        locations = []

        for element in osm_data.get('elements', []):
            tags = element.get('tags', {})

            # Basis-Infos extrahieren
            name = tags.get('name')
            if not name:
                continue  # Überspringe Orte ohne Namen

            lat, lon = self.extract_coordinates(element)
            if not lat or not lon:
                continue

            # Kategorie bestimmen
            category = self.map_category(tags)

            # ID generieren
            osm_id = f"osm-{element['type']}-{element['id']}"

            # Location-Objekt erstellen
            location = {
                "id": osm_id,
                "name": name,
                "displayName": name,
                "category": category,
                "latitude": lat,
                "longitude": lon,
                "source": "openstreetmap",
                "sourceId": f"{element['type']}/{element['id']}",

                # Optionale Felder
                "address": tags.get('addr:street', ''),
                "city": tags.get('addr:city', ''),
                "website": tags.get('website', tags.get('contact:website', '')),
                "phone": tags.get('phone', tags.get('contact:phone', '')),
                "openingHours": tags.get('opening_hours', ''),
                "description": tags.get('description', ''),

                # Tags
                "tags": [
                    tags.get('tourism', ''),
                    tags.get('leisure', ''),
                    tags.get('amenity', ''),
                ],

                # Accessibility
                "accessibility": self._parse_accessibility(tags),
                "parking": tags.get('parking') in ['yes', 'surface', 'underground'],
            }

            # Leere Tags entfernen
            location['tags'] = [t for t in location['tags'] if t]

            locations.append(location)

        return locations

    def _parse_accessibility(self, tags: Dict[str, str]) -> str:
        """Parst Barrierefreiheit aus OSM Tags"""

        wheelchair = tags.get('wheelchair', '')
        if wheelchair == 'yes':
            return 'rollstuhlgerecht'
        elif wheelchair == 'limited':
            return 'teilweise'
        elif wheelchair == 'no':
            return 'nicht rollstuhlgerecht'
        else:
            return ''

    def scrape(self) -> List[Dict[str, Any]]:
        """Hauptmethode: Scraped OSM und gibt Locations zurück"""

        print("\n" + "="*60)
        print("🌍 OpenStreetMap Scraper")
        print("="*60)

        # Rate Limiting
        time.sleep(self.rate_limit)

        # OSM Daten holen
        osm_data = self.fetch_osm_data()

        # Parsen
        locations = self.parse_osm_elements(osm_data)

        print(f"\n✅ {len(locations)} Locations erfolgreich geparst")

        # Kategorie-Statistik
        categories = {}
        for loc in locations:
            cat = loc['category']
            categories[cat] = categories.get(cat, 0) + 1

        print("\n📊 Kategorie-Verteilung:")
        for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
            print(f"   • {cat}: {count}")

        return locations


def main():
    """Test-Funktion"""
    scraper = OSMScraper()
    locations = scraper.scrape()

    # Als JSON speichern
    output_file = "output/raw/osm_data.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "openstreetmap",
                "scraped_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "bbox": scraper.BBOX
            },
            "data": locations
        }, f, ensure_ascii=False, indent=2)

    print(f"\n💾 Gespeichert: {output_file}")


if __name__ == "__main__":
    main()
