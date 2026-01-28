#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AED (Defibrillator) Scraper via Overpass API
Sammelt AED-Standorte aus OpenStreetMap für MSH-Region

WICHTIG: Genaue Positionen sind bei AEDs lebensrettend!
"""

import json
import time
from typing import List, Dict, Any
from pathlib import Path
import requests


class AEDScraper:
    """Spezialisierter Scraper für Defibrillatoren (AEDs) aus OpenStreetMap"""

    # MSH-Region + erweiterter Bereich (AEDs sind selten, größeres Gebiet)
    BBOX = {
        "south": 51.20,   # Südharz erweitert
        "west": 10.60,    # Westgrenze erweitert
        "north": 51.75,   # Nordgrenze (Richtung Halle)
        "east": 12.00     # Ostgrenze erweitert
    }

    # Overpass Server
    OVERPASS_URLS = [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter",
        "https://maps.mail.ru/osm/tools/overpass/api/interpreter",
    ]
    REQUEST_TIMEOUT = 120

    def __init__(self, rate_limit: float = 2.0):
        self.rate_limit = rate_limit
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MSH-Map-AEDScraper/1.0 (Educational Purpose; contact@kolan-systems.de)'
        })

    def build_overpass_query(self) -> str:
        """Erstellt Overpass Query speziell für AEDs"""
        bbox_str = f"{self.BBOX['south']},{self.BBOX['west']},{self.BBOX['north']},{self.BBOX['east']}"

        # AED-spezifische Tags
        query = f"""
[out:json][timeout:{self.REQUEST_TIMEOUT}];
(
  node["emergency"="defibrillator"]({bbox_str});
  node["amenity"="defibrillator"]({bbox_str});
  node["healthcare"="defibrillator"]({bbox_str});
  way["emergency"="defibrillator"]({bbox_str});
  way["amenity"="defibrillator"]({bbox_str});
);
out center tags;
"""
        return query

    def fetch_aed_data(self) -> Dict[str, Any]:
        """Holt AED-Daten von Overpass API"""

        print(f"[AED] Frage Overpass API nach Defibrillatoren ab...")
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
                print(f"   [OK] {len(elements)} AEDs gefunden")
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
        """Extrahiert präzise Koordinaten aus OSM Element"""
        if element['type'] == 'node':
            return (element.get('lat'), element.get('lon'))
        elif element['type'] == 'way' and 'center' in element:
            return (element['center'].get('lat'), element['center'].get('lon'))
        return (None, None)

    def parse_access_type(self, tags: Dict[str, str]) -> Dict[str, Any]:
        """Parst Zugangsinformationen des AED"""
        access = tags.get('access', 'unknown')
        defibrillator_access = tags.get('defibrillator:access', access)

        # Öffentlich zugänglich?
        is_public = defibrillator_access in ['yes', 'public', 'permissive']

        # Nur für Kunden/Personal?
        is_customers = defibrillator_access in ['customers', 'private', 'no']

        # 24/7 verfügbar?
        opening_hours = tags.get('opening_hours', '')
        is_24_7 = opening_hours == '24/7' or '24/7' in opening_hours

        return {
            "accessType": defibrillator_access,
            "isPublic": is_public,
            "isCustomersOnly": is_customers,
            "is24h": is_24_7,
            "openingHours": opening_hours
        }

    def parse_location_type(self, tags: Dict[str, str]) -> Dict[str, Any]:
        """Parst Standort-Typ (indoor/outdoor)"""
        indoor = tags.get('indoor', '')
        location = tags.get('defibrillator:location', tags.get('location', ''))

        is_indoor = indoor == 'yes' or 'indoor' in location.lower() or 'innen' in location.lower()
        is_outdoor = indoor == 'no' or 'outdoor' in location.lower() or 'außen' in location.lower()

        return {
            "isIndoor": is_indoor,
            "isOutdoor": is_outdoor or (not is_indoor),
            "locationDescription": location if location else ("Innenbereich" if is_indoor else "Außenbereich")
        }

    def parse_aed_elements(self, osm_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Konvertiert OSM Elemente zu AED Location Format"""

        aeds = []
        seen_ids = set()

        for element in osm_data.get('elements', []):
            tags = element.get('tags', {})

            lat, lon = self.extract_coordinates(element)
            if not lat or not lon:
                continue

            # Duplikate vermeiden
            osm_id = f"aed-{element['type']}-{element['id']}"
            if osm_id in seen_ids:
                continue
            seen_ids.add(osm_id)

            # Name generieren
            name = tags.get('name', '')
            operator = tags.get('operator', '')
            description = tags.get('description', tags.get('defibrillator:location', ''))

            # Sinnvollen Namen erstellen
            if not name:
                if operator:
                    name = f"AED bei {operator}"
                elif description:
                    name = f"AED - {description[:50]}"
                else:
                    name = "Defibrillator (AED)"

            # Zugangs- und Standortinformationen
            access_info = self.parse_access_type(tags)
            location_info = self.parse_location_type(tags)

            # Adresse
            street = tags.get('addr:street', '')
            housenumber = tags.get('addr:housenumber', '')
            address = f"{street} {housenumber}".strip() if street else ''

            city = tags.get('addr:city', self._estimate_city(lat, lon))
            postal_code = tags.get('addr:postcode', '')

            aed = {
                "id": osm_id,
                "type": "defibrillator",
                "name": name,
                "description": description,

                # Präzise Koordinaten (WICHTIG!)
                "latitude": lat,
                "longitude": lon,

                # Adresse
                "street": address,
                "postalCode": postal_code,
                "city": city,

                # Zugangsinformationen
                "accessType": access_info["accessType"],
                "isPublic": access_info["isPublic"],
                "isCustomersOnly": access_info["isCustomersOnly"],
                "is24h": access_info["is24h"],
                "openingHours": access_info["openingHours"],

                # Standort
                "isIndoor": location_info["isIndoor"],
                "isOutdoor": location_info["isOutdoor"],
                "locationDescription": location_info["locationDescription"],

                # Betreiber
                "operator": operator,

                # Zusätzliche OSM-Infos
                "phone": tags.get('phone', tags.get('emergency:phone', '')),
                "level": tags.get('level', ''),  # Stockwerk

                # Quelle
                "source": "openstreetmap",
                "sourceId": f"{element['type']}/{element['id']}",
                "osmUrl": f"https://www.openstreetmap.org/{element['type']}/{element['id']}",
            }

            # Leere Werte entfernen
            aed = {k: v for k, v in aed.items() if v is not None and v != ''}

            aeds.append(aed)

        return aeds

    def _estimate_city(self, lat: float, lon: float) -> str:
        """Schätzt Stadt basierend auf Koordinaten"""
        # Sangerhausen
        if 51.45 <= lat <= 51.50 and 11.25 <= lon <= 11.35:
            return "Sangerhausen"
        # Eisleben
        if 51.50 <= lat <= 51.55 and 11.50 <= lon <= 11.60:
            return "Lutherstadt Eisleben"
        # Hettstedt
        if 51.60 <= lat <= 51.68 and 11.45 <= lon <= 11.55:
            return "Hettstedt"
        # Südharz (Roßla, Stolberg)
        if 51.40 <= lat <= 51.50 and 10.90 <= lon <= 11.15:
            return "Südharz"
        # Allstedt
        if 51.38 <= lat <= 51.45 and 11.35 <= lon <= 11.45:
            return "Allstedt"
        # Querfurt
        if 51.35 <= lat <= 51.42 and 11.55 <= lon <= 11.65:
            return "Querfurt"
        # Halle-Region
        if lat >= 51.45 and lon >= 11.90:
            return "Halle (Saale)"
        return "Mansfeld-Südharz"

    def scrape(self) -> List[Dict[str, Any]]:
        """Hauptmethode: Scraped AED-Standorte"""

        print("\n" + "="*60)
        print("[AED] Defibrillator Scraper fuer MSH-Region")
        print("="*60)
        print("[INFO] Genaue Positionen sind bei AEDs lebensrettend!")

        time.sleep(self.rate_limit)

        # Daten holen
        osm_data = self.fetch_aed_data()

        # Parsen
        aeds = self.parse_aed_elements(osm_data)

        print(f"\n[OK] {len(aeds)} AED-Standorte gefunden")

        # Statistik nach Zugang
        access_stats = {"public": 0, "restricted": 0, "unknown": 0}
        h24_count = 0

        for aed in aeds:
            if aed.get('isPublic'):
                access_stats["public"] += 1
            elif aed.get('isCustomersOnly'):
                access_stats["restricted"] += 1
            else:
                access_stats["unknown"] += 1
            if aed.get('is24h'):
                h24_count += 1

        print("\n[STATS] Zugangs-Verteilung:")
        print(f"   - Öffentlich zugänglich: {access_stats['public']}")
        print(f"   - Eingeschränkter Zugang: {access_stats['restricted']}")
        print(f"   - Unbekannt: {access_stats['unknown']}")
        print(f"   - 24/7 verfügbar: {h24_count}")

        # Statistik nach Stadt
        cities = {}
        for aed in aeds:
            city = aed.get('city', 'Unbekannt')
            cities[city] = cities.get(city, 0) + 1

        print("\n[STATS] Nach Stadt:")
        for city, count in sorted(cities.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"   - {city}: {count}")

        return aeds


def main():
    """Hauptfunktion"""
    scraper = AEDScraper()
    aeds = scraper.scrape()

    # Output-Verzeichnis
    output_dir = Path(__file__).parent.parent / "output" / "health"
    output_dir.mkdir(parents=True, exist_ok=True)

    # Export
    output_file = output_dir / "defibrillators_osm.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "openstreetmap",
                "scraped_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "bbox": scraper.BBOX,
                "count": len(aeds),
                "info": "AED-Standorte (Defibrillatoren) für Notfälle"
            },
            "data": aeds
        }, f, ensure_ascii=False, indent=2)

    print(f"\n[SAVED] Gespeichert: {output_file}")

    # Für Flutter-App auch als assets exportieren
    flutter_assets = Path(__file__).parent.parent.parent / "lib" / "assets" / "data" / "health"
    flutter_assets.mkdir(parents=True, exist_ok=True)

    flutter_file = flutter_assets / "aeds.json"
    with open(flutter_file, 'w', encoding='utf-8') as f:
        json.dump(aeds, f, ensure_ascii=False, indent=2)

    print(f"[SAVED] Flutter-Assets: {flutter_file}")

    print("\n" + "="*60)
    print("[OK] AED Scraping abgeschlossen!")
    print("="*60)
    print("\n[WICHTIG] AED-Positionen unbedingt verifizieren!")
    print("   Bei Defibrillatoren ist die genaue Position lebensrettend!")


if __name__ == "__main__":
    main()
