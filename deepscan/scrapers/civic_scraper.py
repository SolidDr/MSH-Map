#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Civic Scraper via Overpass API
Sammelt Behörden, Jugendzentren, Soziale Einrichtungen aus OSM für MSH-Region
"""

import json
import time
from typing import List, Dict, Any, Optional
from pathlib import Path
import requests


class CivicScraper:
    """Scraper für öffentliche/soziale Einrichtungen aus OpenStreetMap"""

    # MSH-Kerngebiet Bounding Box (identisch mit health_scraper)
    BBOX = {
        "south": 51.25,   # Südharz
        "west": 10.80,    # Westgrenze
        "north": 51.70,   # Nordgrenze (Halle-Nähe)
        "east": 11.80     # Ostgrenze (Richtung Halle)
    }

    # Overpass Server
    OVERPASS_URLS = [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter",
        "https://maps.mail.ru/osm/tools/overpass/api/interpreter",
    ]
    REQUEST_TIMEOUT = 120

    # OSM Civic Tags
    CIVIC_TAGS = {
        # Behörden/Ämter
        ("amenity", "townhall"): "townhall",
        ("office", "government"): "government_office",
        ("office", "administrative"): "government_office",
        ("amenity", "public_building"): "government_office",
        ("office", "register"): "government_office",  # Standesamt etc.

        # Jugendzentren
        ("amenity", "community_centre"): "community_centre",
        ("leisure", "youth_centre"): "youth_centre",
        ("amenity", "youth_centre"): "youth_centre",
        ("social_facility", "youth_centre"): "youth_centre",

        # Soziale Einrichtungen (Seniorentreffs, Beratungsstellen)
        ("amenity", "social_facility"): "social_facility",
        ("social_facility", "group_home"): "social_facility",
        ("social_facility", "assisted_living"): "social_facility",
        ("social_facility", "day_care"): "social_facility",
        ("amenity", "social_centre"): "social_facility",
    }

    # Unterkategorien für social_facility
    SOCIAL_FACILITY_TYPES = {
        "senior": "senior_meeting",      # Seniorentreff
        "youth": "youth_centre",         # wird zu youth_centre
        "homeless": "social_facility",
        "disabled": "social_facility",
        "refugee": "social_facility",
    }

    def __init__(self, rate_limit: float = 2.0):
        self.rate_limit = rate_limit
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MSH-Map-CivicScraper/1.0 (Educational Purpose; contact@kolan-systems.de)'
        })

    def build_overpass_query(self) -> str:
        """Erstellt Overpass Query für alle Civic-Tags"""
        bbox_str = f"{self.BBOX['south']},{self.BBOX['west']},{self.BBOX['north']},{self.BBOX['east']}"

        tag_queries = []
        for (key, value) in self.CIVIC_TAGS.keys():
            tag_queries.append(f'  node["{key}"="{value}"]({bbox_str});')
            tag_queries.append(f'  way["{key}"="{value}"]({bbox_str});')

        query = f"""
[out:json][timeout:{self.REQUEST_TIMEOUT}];
(
{chr(10).join(tag_queries)}
);
out center tags;
"""
        return query

    def fetch_civic_data(self) -> Dict[str, Any]:
        """Holt Civic-Daten von Overpass API"""

        print(f"[CIVIC] Frage Overpass API nach öffentlichen Einrichtungen ab...")
        print(f"   Bounding Box: {self.BBOX}")

        query = self.build_overpass_query()

        for url in self.OVERPASS_URLS:
            try:
                print(f"   Versuche {url.split('/')[2]}...")
                response = self.session.post(
                    url,
                    data={"data": query},
                    timeout=self.REQUEST_TIMEOUT
                )
                response.raise_for_status()

                data = response.json()
                elements = data.get('elements', [])
                print(f"   [OK] {len(elements)} Elemente gefunden")
                return data

            except requests.exceptions.Timeout:
                print(f"   [TIMEOUT] bei {url.split('/')[2]}")
                continue
            except requests.exceptions.RequestException as e:
                print(f"   [ERROR] {type(e).__name__}")
                continue

        print("   [WARN] Alle Server fehlgeschlagen")
        return {"elements": []}

    def extract_coordinates(self, element: Dict[str, Any]) -> tuple:
        """Extrahiert Koordinaten aus OSM Element"""
        if element['type'] == 'node':
            return (element.get('lat'), element.get('lon'))
        elif element['type'] == 'way' and 'center' in element:
            return (element['center'].get('lat'), element['center'].get('lon'))
        return (None, None)

    def map_category(self, tags: Dict[str, str]) -> str:
        """Mappt OSM Tags zu Civic-Kategorie"""
        for (key, value), category in self.CIVIC_TAGS.items():
            if tags.get(key) == value:
                # Spezialfall: social_facility Unterkategorien
                if category == "social_facility":
                    sf_type = tags.get("social_facility", "")
                    for keyword, subcat in self.SOCIAL_FACILITY_TYPES.items():
                        if keyword in sf_type.lower():
                            return subcat
                return category
        return "other_civic"

    def is_youth_related(self, tags: Dict[str, str]) -> bool:
        """Prüft ob Einrichtung jugendrelevant ist"""
        name = tags.get('name', '').lower()
        description = tags.get('description', '').lower()

        youth_keywords = ['jugend', 'youth', 'juz', 'jugendzentrum', 'jugendclub',
                         'jugendtreff', 'teenager', 'skate', 'bmx']

        for keyword in youth_keywords:
            if keyword in name or keyword in description:
                return True
        return False

    def is_senior_related(self, tags: Dict[str, str]) -> bool:
        """Prüft ob Einrichtung seniorenrelevant ist"""
        name = tags.get('name', '').lower()
        description = tags.get('description', '').lower()

        senior_keywords = ['senior', 'senioren', 'älter', 'rentner', 'pension',
                          'begegnungsstätte', 'tagespflege', 'altenhilfe']

        for keyword in senior_keywords:
            if keyword in name or keyword in description:
                return True
        return False

    def parse_civic_elements(self, osm_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Konvertiert OSM Elemente zu Civic Location Format"""

        locations = []
        seen_ids = set()

        for element in osm_data.get('elements', []):
            tags = element.get('tags', {})

            # Basis-Infos
            name = tags.get('name')
            if not name:
                continue

            lat, lon = self.extract_coordinates(element)
            if not lat or not lon:
                continue

            # Duplikate vermeiden
            osm_id = f"osm-{element['type']}-{element['id']}"
            if osm_id in seen_ids:
                continue
            seen_ids.add(osm_id)

            # Kategorie bestimmen
            category = self.map_category(tags)

            # Community Centre: Unterscheide Jugend vs. Senioren vs. Allgemein
            if category == "community_centre":
                if self.is_youth_related(tags):
                    category = "youth_centre"
                elif self.is_senior_related(tags):
                    category = "senior_meeting"

            # Stadt aus PLZ/Adresse bestimmen
            city = tags.get('addr:city', '')
            postal_code = tags.get('addr:postcode', '')

            if not city:
                city = self._estimate_city(lat, lon)

            location = {
                "id": osm_id,
                "type": category,
                "name": name,
                "street": tags.get('addr:street', '') + (' ' + tags.get('addr:housenumber', '') if tags.get('addr:housenumber') else ''),
                "postalCode": postal_code,
                "city": city,
                "latitude": lat,
                "longitude": lon,
                "phone": tags.get('phone', tags.get('contact:phone', '')),
                "phoneFormatted": self._format_phone(tags.get('phone', tags.get('contact:phone', ''))),
                "website": tags.get('website', tags.get('contact:website', '')),
                "email": tags.get('email', tags.get('contact:email', '')),
                "openingHours": tags.get('opening_hours', ''),
                "description": tags.get('description', ''),

                # Barrierefreiheit
                "isBarrierFree": tags.get('wheelchair') == 'yes',
                "hasParking": tags.get('parking') in ['yes', 'surface', 'underground'],

                # Zielgruppe
                "targetAudience": self._determine_audience(category, tags),

                # Quelle
                "source": "openstreetmap",
                "sourceId": f"{element['type']}/{element['id']}",
            }

            # Operator (z.B. "Landkreis MSH", "Stadt Sangerhausen")
            if tags.get('operator'):
                location["operator"] = tags['operator']

            # Leere Werte entfernen
            location = {k: v for k, v in location.items() if v}

            locations.append(location)

        return locations

    def _determine_audience(self, category: str, tags: Dict[str, str]) -> str:
        """Bestimmt Zielgruppe der Einrichtung"""
        if category in ['youth_centre']:
            return 'jugend'
        if category in ['senior_meeting']:
            return 'senioren'
        if category in ['townhall', 'government_office']:
            return 'alle'
        return 'alle'

    def _estimate_city(self, lat: float, lon: float) -> str:
        """Schätzt Stadt basierend auf Koordinaten"""
        # Sangerhausen-Bereich
        if 51.45 <= lat <= 51.50 and 11.25 <= lon <= 11.35:
            return "Sangerhausen"
        # Eisleben-Bereich
        if 51.50 <= lat <= 51.55 and 11.50 <= lon <= 11.60:
            return "Lutherstadt Eisleben"
        # Hettstedt-Bereich
        if 51.60 <= lat <= 51.68 and 11.45 <= lon <= 11.55:
            return "Hettstedt"
        # Südharz-Bereich (Roßla, Stolberg)
        if 51.40 <= lat <= 51.50 and 10.90 <= lon <= 11.15:
            return "Südharz"
        # Allstedt-Bereich
        if 51.38 <= lat <= 51.45 and 11.35 <= lon <= 11.45:
            return "Allstedt"
        # Gerbstedt-Bereich
        if 51.60 <= lat <= 51.68 and 11.60 <= lon <= 11.70:
            return "Gerbstedt"
        return "Mansfeld-Südharz"

    def _format_phone(self, phone: str) -> str:
        """Formatiert Telefonnummer für Anzeige"""
        if not phone:
            return ""
        phone = phone.replace('+49', '0').replace(' ', '').replace('-', '').replace('/', '')
        if len(phone) >= 10:
            return f"{phone[:5]} / {phone[5:7]} {phone[7:9]} {phone[9:]}"
        return phone

    def scrape(self) -> List[Dict[str, Any]]:
        """Hauptmethode: Scraped Civic-Einrichtungen"""

        print("\n" + "="*60)
        print("[CIVIC] Civic Scraper für MSH-Region")
        print("   Kategorien: Behörden, Jugendzentren, Soziale Einrichtungen")
        print("="*60)

        time.sleep(self.rate_limit)

        # Daten holen
        osm_data = self.fetch_civic_data()

        # Parsen
        locations = self.parse_civic_elements(osm_data)

        print(f"\n[OK] {len(locations)} Civic-Locations gefunden")

        # Statistik nach Kategorie
        categories = {}
        for loc in locations:
            cat = loc.get('type', 'unknown')
            categories[cat] = categories.get(cat, 0) + 1

        print("\n[STATS] Kategorie-Verteilung:")
        for cat, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
            print(f"   - {cat}: {count}")

        # Statistik nach Stadt
        cities = {}
        for loc in locations:
            city = loc.get('city', 'Unbekannt')
            cities[city] = cities.get(city, 0) + 1

        print("\n[STATS] Nach Stadt:")
        for city, count in sorted(cities.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"   - {city}: {count}")

        return locations

    def export_by_category(self, locations: List[Dict[str, Any]], output_dir: Path):
        """Exportiert Locations nach Kategorie getrennt"""

        output_dir.mkdir(parents=True, exist_ok=True)

        # Nach Kategorie gruppieren
        by_category = {}
        for loc in locations:
            cat = loc.get('type', 'other')
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(loc)

        # Mapping zu Dateinamen
        file_mapping = {
            'townhall': 'townhalls_osm.json',
            'government_office': 'government_offices_osm.json',
            'youth_centre': 'youth_centres_osm.json',
            'community_centre': 'community_centres_osm.json',
            'social_facility': 'social_facilities_osm.json',
            'senior_meeting': 'senior_meetings_osm.json',
        }

        for category, items in by_category.items():
            filename = file_mapping.get(category, f'{category}_osm.json')
            filepath = output_dir / filename

            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump({
                    "meta": {
                        "source": "openstreetmap",
                        "scraped_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                        "category": category,
                        "count": len(items),
                        "region": "Mansfeld-Südharz"
                    },
                    "data": items
                }, f, ensure_ascii=False, indent=2)

            print(f"   [SAVED] {filename}: {len(items)} Einträge")


def main():
    """Hauptfunktion"""
    scraper = CivicScraper()
    locations = scraper.scrape()

    # Output-Verzeichnis
    output_dir = Path(__file__).parent.parent / "output" / "civic"
    output_dir.mkdir(parents=True, exist_ok=True)

    # Gesamtexport
    output_file = output_dir / "civic_all_osm.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "openstreetmap",
                "scraped_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "bbox": scraper.BBOX,
                "count": len(locations)
            },
            "data": locations
        }, f, ensure_ascii=False, indent=2)

    print(f"\n[SAVED] Gespeichert: {output_file}")

    # Nach Kategorie exportieren
    print("\n[EXPORT] Exportiere nach Kategorie:")
    scraper.export_by_category(locations, output_dir)

    # Assets-Verzeichnis vorbereiten
    assets_dir = Path(__file__).parent.parent.parent / "assets" / "data" / "civic"
    assets_dir.mkdir(parents=True, exist_ok=True)

    # Zusammengefasste Dateien für Flutter erstellen
    # Behörden (townhall + government_office)
    behoerden = [l for l in locations if l.get('type') in ['townhall', 'government_office']]
    with open(assets_dir / "government.json", 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "openstreetmap",
                "created_at": time.strftime("%Y-%m-%d"),
                "version": "1.0",
                "region": "Mansfeld-Südharz",
                "total_count": len(behoerden)
            },
            "data": behoerden
        }, f, ensure_ascii=False, indent=2)
    print(f"\n[ASSETS] government.json: {len(behoerden)} Behörden")

    # Jugendzentren
    jugend = [l for l in locations if l.get('type') in ['youth_centre', 'community_centre']
              and l.get('targetAudience') in ['jugend', 'alle']]
    with open(assets_dir / "youth_centres.json", 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "openstreetmap",
                "created_at": time.strftime("%Y-%m-%d"),
                "version": "1.0",
                "region": "Mansfeld-Südharz",
                "total_count": len(jugend)
            },
            "data": jugend
        }, f, ensure_ascii=False, indent=2)
    print(f"[ASSETS] youth_centres.json: {len(jugend)} Jugendzentren")

    # Soziale Einrichtungen (inkl. Seniorentreffs)
    sozial = [l for l in locations if l.get('type') in ['social_facility', 'senior_meeting']]
    with open(assets_dir / "social_facilities.json", 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "openstreetmap",
                "created_at": time.strftime("%Y-%m-%d"),
                "version": "1.0",
                "region": "Mansfeld-Südharz",
                "total_count": len(sozial)
            },
            "data": sozial
        }, f, ensure_ascii=False, indent=2)
    print(f"[ASSETS] social_facilities.json: {len(sozial)} Soziale Einrichtungen")

    print("\n" + "="*60)
    print("[OK] Civic Scraping abgeschlossen!")
    print("="*60)
    print("\nNächste Schritte:")
    print("   1. Daten prüfen in: assets/data/civic/")
    print("   2. pubspec.yaml um Assets erweitern")
    print("   3. CivicRepository in Flutter erstellen")


if __name__ == "__main__":
    main()
