#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Health Scraper via Overpass API
Sammelt Ärzte, Apotheken, Krankenhäuser, Physiotherapeuten aus OSM für MSH-Region
"""

import json
import time
from typing import List, Dict, Any, Optional
from pathlib import Path
import requests


class HealthScraper:
    """Scraper für Gesundheitseinrichtungen aus OpenStreetMap"""

    # MSH-Kerngebiet Bounding Box
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

    # OSM Health Tags
    HEALTH_TAGS = {
        # Ärzte
        ("amenity", "doctors"): "doctor",
        ("amenity", "clinic"): "doctor",
        ("healthcare", "doctor"): "doctor",
        ("healthcare", "physician"): "doctor",

        # Apotheken
        ("amenity", "pharmacy"): "pharmacy",
        ("healthcare", "pharmacy"): "pharmacy",

        # Krankenhäuser
        ("amenity", "hospital"): "hospital",
        ("healthcare", "hospital"): "hospital",

        # Physiotherapie
        ("healthcare", "physiotherapist"): "physiotherapy",
        ("amenity", "physiotherapy"): "physiotherapy",

        # Zahnarzt
        ("amenity", "dentist"): "doctor",
        ("healthcare", "dentist"): "doctor",

        # Sonstige Gesundheit
        ("healthcare", "centre"): "doctor",
        ("healthcare", "clinic"): "doctor",
        ("healthcare", "laboratory"): "other_health",
        ("healthcare", "rehabilitation"): "hospital",

        # Pflegeeinrichtungen
        ("amenity", "nursing_home"): "care_service",
        ("healthcare", "nursing_home"): "care_service",
        ("social_facility", "nursing_home"): "care_service",

        # Sanitätshaus
        ("shop", "medical_supply"): "medical_supply",
        ("shop", "hearing_aids"): "medical_supply",
        ("shop", "optician"): "medical_supply",
    }

    # Spezialisierung aus OSM Tags
    SPECIALIZATION_MAP = {
        # healthcare:speciality Tags
        "general": "allgemein",
        "internal": "innere",
        "cardiology": "kardio",
        "orthopaedics": "ortho",
        "neurology": "neuro",
        "ophthalmology": "augen",
        "otolaryngology": "hno",
        "dermatology": "haut",
        "urology": "uro",
        "gynaecology": "gyn",
        "dentistry": "zahn",
        "paediatrics": "kinder",
        "psychiatry": "psycho",
        "psychology": "psycho",

        # Weitere mappings
        "family": "allgemein",
        "gp": "allgemein",
    }

    def __init__(self, rate_limit: float = 2.0):
        self.rate_limit = rate_limit
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MSH-Map-HealthScraper/1.0 (Educational Purpose; contact@kolan-systems.de)'
        })

    def build_overpass_query(self) -> str:
        """Erstellt Overpass Query für alle Health-Tags"""
        bbox_str = f"{self.BBOX['south']},{self.BBOX['west']},{self.BBOX['north']},{self.BBOX['east']}"

        tag_queries = []
        for (key, value) in self.HEALTH_TAGS.keys():
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

    def fetch_health_data(self) -> Dict[str, Any]:
        """Holt Health-Daten von Overpass API"""

        print(f"[HEALTH] Frage Overpass API nach Gesundheitseinrichtungen ab...")
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
        """Mappt OSM Tags zu Health-Kategorie"""
        for (key, value), category in self.HEALTH_TAGS.items():
            if tags.get(key) == value:
                return category
        return "other_health"

    def extract_specialization(self, tags: Dict[str, str]) -> Optional[str]:
        """Extrahiert Fachrichtung aus OSM Tags"""

        # healthcare:speciality Tag prüfen
        speciality = tags.get('healthcare:speciality', '')
        for osm_spec, msh_spec in self.SPECIALIZATION_MAP.items():
            if osm_spec in speciality.lower():
                return msh_spec

        # Zahnarzt erkennen
        if tags.get('amenity') == 'dentist' or tags.get('healthcare') == 'dentist':
            return 'zahn'

        # Name-basierte Erkennung
        name = tags.get('name', '').lower()
        if 'zahnarzt' in name or 'dental' in name:
            return 'zahn'
        if 'hno' in name or 'hals-nasen' in name:
            return 'hno'
        if 'augen' in name or 'ophthalmolog' in name:
            return 'augen'
        if 'orthop' in name:
            return 'ortho'
        if 'kinder' in name or 'pädia' in name:
            return 'kinder'
        if 'frauen' in name or 'gynäko' in name:
            return 'gyn'
        if 'haut' in name or 'dermato' in name:
            return 'haut'
        if 'neuro' in name:
            return 'neuro'
        if 'kardio' in name or 'herz' in name:
            return 'kardio'
        if 'innere' in name or 'intern' in name:
            return 'innere'
        if 'psychi' in name or 'psycho' in name:
            return 'psycho'
        if 'uro' in name:
            return 'uro'

        return None

    def parse_health_elements(self, osm_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Konvertiert OSM Elemente zu Health Location Format"""

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

            # Kategorie und Spezialisierung
            category = self.map_category(tags)
            specialization = self.extract_specialization(tags) if category == 'doctor' else None

            # Stadt aus PLZ/Adresse bestimmen
            city = tags.get('addr:city', '')
            postal_code = tags.get('addr:postcode', '')

            # Stadtname für MSH-Region
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
                "openingHours": tags.get('opening_hours', ''),

                # Health-spezifisch
                "isBarrierFree": tags.get('wheelchair') == 'yes',
                "hasParking": tags.get('parking') in ['yes', 'surface', 'underground'],
                "languages": ["Deutsch"],  # Default
                "acceptsPublicInsurance": True,  # Default für Deutschland
                "acceptsPrivateInsurance": True,

                # Quelle
                "source": "openstreetmap",
                "sourceId": f"{element['type']}/{element['id']}",
                "osmTags": {k: v for k, v in tags.items() if k.startswith('healthcare') or k.startswith('amenity')},
            }

            # Spezialisierung nur für Ärzte
            if specialization:
                location["specialization"] = specialization

            # Notaufnahme für Krankenhäuser
            if category == 'hospital':
                location["hasEmergency"] = tags.get('emergency') == 'yes'

            # Leere Werte entfernen
            location = {k: v for k, v in location.items() if v}

            locations.append(location)

        return locations

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
        # Entferne +49 und formatiere
        phone = phone.replace('+49', '0').replace(' ', '').replace('-', '').replace('/', '')
        if len(phone) >= 10:
            # Format: 03464 / 12 34 56
            return f"{phone[:5]} / {phone[5:7]} {phone[7:9]} {phone[9:]}"
        return phone

    def scrape(self) -> List[Dict[str, Any]]:
        """Hauptmethode: Scraped Health-Einrichtungen"""

        print("\n" + "="*60)
        print("[HEALTH] Health Scraper fuer MSH-Region")
        print("="*60)

        time.sleep(self.rate_limit)

        # Daten holen
        osm_data = self.fetch_health_data()

        # Parsen
        locations = self.parse_health_elements(osm_data)

        print(f"\n[OK] {len(locations)} Health-Locations gefunden")

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
            'doctor': 'doctors_osm.json',
            'pharmacy': 'pharmacies_osm.json',
            'hospital': 'hospitals_osm.json',
            'physiotherapy': 'physiotherapy_osm.json',
            'care_service': 'care_services_osm.json',
            'medical_supply': 'medical_supply_osm.json',
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

            print(f"   [SAVED] {filename}: {len(items)} Eintraege")


def main():
    """Hauptfunktion"""
    scraper = HealthScraper()
    locations = scraper.scrape()

    # Output-Verzeichnis
    output_dir = Path(__file__).parent.parent / "output" / "health"
    output_dir.mkdir(parents=True, exist_ok=True)

    # Gesamtexport
    output_file = output_dir / "health_all_osm.json"
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

    print("\n" + "="*60)
    print("[OK] Health Scraping abgeschlossen!")
    print("="*60)
    print("\n[WICHTIG] Die OSM-Daten mit manuellen Daten abgleichen!")
    print("   Manuelle Daten: assets/data/health/")
    print("   OSM-Daten:      deepscan/output/health/")


if __name__ == "__main__":
    main()
