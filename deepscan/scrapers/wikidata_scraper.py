#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Wikidata Scraper via SPARQL
Sammelt kulturelle Sehenswürdigkeiten und historische Orte
"""

import json
import time
from typing import List, Dict, Any
import requests


class WikidataScraper:
    """Scraper für Wikidata über SPARQL Endpoint"""

    SPARQL_ENDPOINT = "https://query.wikidata.org/sparql"

    # Erweiterte Bounding Box (+20km um MSH)
    BBOX = {
        "south": 51.07,
        "west": 10.50,
        "north": 51.93,
        "east": 12.10
    }

    # Wikidata Classes → MSH Categories
    WIKIDATA_MAPPING = {
        "Q23413": "castle",      # Burg
        "Q16560": "castle",      # Palast/Schloss
        "Q91122": "castle",      # Ruine
        "Q33506": "museum",      # Museum
        "Q207694": "culture",    # Kunstmuseum
        "Q34627": "culture",     # Synagoge
        "Q16970": "culture",     # Kirche
        "Q44539": "culture",     # Tempel
        "Q162875": "culture",    # Denkmal
        "Q4989906": "culture",   # Monument
        "Q82117": "nature",      # Naturschutzgebiet
        "Q191992": "nature",     # Nationalpark
    }

    def __init__(self, rate_limit: float = 1.5):
        """
        Args:
            rate_limit: Sekunden zwischen Requests
        """
        self.rate_limit = rate_limit
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MSH-Map-Scraper/2.0 (Educational; contact@kolan-systems.de)',
            'Accept': 'application/sparql-results+json'
        })

    def build_sparql_query(self) -> str:
        """Erstellt SPARQL Query für kulturelle POIs in der Region"""

        # Alle relevanten Wikidata Classes
        classes = " ".join([f"wd:{qid}" for qid in self.WIKIDATA_MAPPING.keys()])

        query = f"""
SELECT DISTINCT ?item ?itemLabel ?itemDescription ?coord ?class ?classLabel ?image ?website
WHERE {{
  VALUES ?class {{ {classes} }}
  ?item wdt:P31 ?class.
  ?item wdt:P625 ?coord.

  # Bounding Box Filter
  FILTER(
    ?coord >= "Point({self.BBOX['west']} {self.BBOX['south']})"^^geo:wktLiteral &&
    ?coord <= "Point({self.BBOX['east']} {self.BBOX['north']})"^^geo:wktLiteral
  )

  # Optionale Felder
  OPTIONAL {{ ?item wdt:P18 ?image. }}
  OPTIONAL {{ ?item wdt:P856 ?website. }}

  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "de,en". }}
}}
LIMIT 500
"""
        return query

    def fetch_wikidata(self) -> Dict[str, Any]:
        """Führt SPARQL Query aus"""

        query = self.build_sparql_query()

        print(f"📚 Frage Wikidata SPARQL Endpoint ab...")
        print(f"   Bounding Box: {self.BBOX}")

        try:
            response = self.session.get(
                self.SPARQL_ENDPOINT,
                params={'query': query, 'format': 'json'},
                timeout=60
            )
            response.raise_for_status()

            data = response.json()
            results = data.get('results', {}).get('bindings', [])

            print(f"✅ {len(results)} Wikidata-Einträge gefunden")
            return data

        except requests.exceptions.RequestException as e:
            print(f"❌ Fehler bei Wikidata: {e}")
            return {"results": {"bindings": []}}

    def parse_wkt_point(self, wkt: str) -> tuple:
        """
        Parst WKT Point String zu (lat, lon)
        Format: "Point(11.2936 51.4731)"
        """
        try:
            coords_str = wkt.replace("Point(", "").replace(")", "")
            lon, lat = map(float, coords_str.split())
            return (lat, lon)
        except Exception:
            return (None, None)

    def map_category(self, wikidata_class: str) -> str:
        """Mappt Wikidata Class QID zu MSH Kategorie"""
        # Extract QID from URI (e.g., "http://www.wikidata.org/entity/Q23413" -> "Q23413")
        qid = wikidata_class.split('/')[-1]
        return self.WIKIDATA_MAPPING.get(qid, "culture")

    def parse_wikidata_results(self, data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Konvertiert Wikidata Results zu MSH Location Format"""

        locations = []
        bindings = data.get('results', {}).get('bindings', [])

        for item in bindings:
            # Basis-Infos
            item_id = item['item']['value'].split('/')[-1]  # QID
            name = item.get('itemLabel', {}).get('value', '')
            description = item.get('itemDescription', {}).get('value', '')

            if not name or name == item_id:
                continue  # Überspringe wenn kein Name vorhanden

            # Koordinaten
            coord_wkt = item.get('coord', {}).get('value', '')
            lat, lon = self.parse_wkt_point(coord_wkt)
            if not lat or not lon:
                continue

            # Kategorie
            wikidata_class = item.get('class', {}).get('value', '')
            category = self.map_category(wikidata_class)

            # Location-Objekt
            location = {
                "id": f"wikidata-{item_id}",
                "name": name,
                "displayName": name,
                "category": category,
                "latitude": lat,
                "longitude": lon,
                "description": description,
                "source": "wikidata",
                "sourceId": item_id,

                # Wikidata-Links
                "website": item.get('website', {}).get('value', ''),
                "wikidataUrl": item['item']['value'],

                # Optionale Felder
                "image": item.get('image', {}).get('value', ''),

                "tags": ["wikidata", category],
            }

            locations.append(location)

        return locations

    def scrape(self) -> List[Dict[str, Any]]:
        """Hauptmethode: Scraped Wikidata und gibt Locations zurück"""

        print("\n" + "="*60)
        print("📚 Wikidata Scraper")
        print("="*60)

        # Rate Limiting
        time.sleep(self.rate_limit)

        # Wikidata abfragen
        wikidata = self.fetch_wikidata()

        # Parsen
        locations = self.parse_wikidata_results(wikidata)

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
    scraper = WikidataScraper()
    locations = scraper.scrape()

    # Als JSON speichern
    output_file = "output/raw/wikidata_data.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "wikidata",
                "scraped_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "bbox": scraper.BBOX
            },
            "data": locations
        }, f, ensure_ascii=False, indent=2)

    print(f"\n💾 Gespeichert: {output_file}")


if __name__ == "__main__":
    main()
