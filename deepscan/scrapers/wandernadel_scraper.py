#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Harzer Wandernadel Scraper via Overpass API
Sammelt alle Stempelstellen der Harzer Wandernadel in der MSH-Region

WICHTIG: Genaue Positionen sind für Wanderer essentiell!
"""

import json
import time
from typing import List, Dict, Any
from pathlib import Path
import requests


class WandernadelScraper:
    """Spezialisierter Scraper für Harzer Wandernadel Stempelstellen aus OpenStreetMap"""

    # Gesamter Harz inkl. Südharz - wir filtern später für MSH
    BBOX_HARZ = {
        "south": 51.40,   # Südrand (Nordhausen, Stolberg)
        "west": 10.20,    # Westrand (Bad Harzburg)
        "north": 52.00,   # Nordrand (Wernigerode)
        "east": 11.50     # Ostrand (Quedlinburg, Thale, Mansfeld)
    }

    # MSH-Region für Filter
    BBOX_MSH = {
        "south": 51.30,   # Südharz (inkl. Stolberg, Rottleberode)
        "west": 10.80,    # Westgrenze
        "north": 51.75,   # Nordgrenze (Hettstedt)
        "east": 11.70     # Ostgrenze
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
            'User-Agent': 'MSH-Map-WandernadelScraper/1.0 (Educational Purpose; contact@kolan-systems.de)'
        })

    def build_overpass_query(self) -> str:
        """Erstellt Overpass Query für Harzer Wandernadel Stempelstellen"""
        bbox_str = f"{self.BBOX_HARZ['south']},{self.BBOX_HARZ['west']},{self.BBOX_HARZ['north']},{self.BBOX_HARZ['east']}"

        # HWN = Harzer Wandernadel
        # Die Stempelstellen haben spezifische Tags
        query = f"""
[out:json][timeout:{self.REQUEST_TIMEOUT}];
(
  // Harzer Wandernadel Stempelstellen - mit HWN-spezifischen Tags
  node["hwn:stamp_number"]({bbox_str});
  node["hwn:stamp"]({bbox_str});
  node["ref:hwn"]({bbox_str});

  // Stempelkästen mit stamp-Information
  node["tourism"="information"]["information"="stamp"]({bbox_str});

  // Sammler-bezogene Stempel
  node["amenity"="stamp_box"]({bbox_str});

  // Nach Name suchen
  node["name"~"[Ww]andernadel|[Ss]tempelstelle|HWN"]({bbox_str});

  // Harzer Hexenstieg Stempel
  node["ref:hexenstieg"]({bbox_str});
);
out body;
"""
        return query

    def is_in_msh_region(self, lat: float, lon: float) -> bool:
        """Prüft ob Koordinaten in MSH-Region liegen"""
        return (self.BBOX_MSH['south'] <= lat <= self.BBOX_MSH['north'] and
                self.BBOX_MSH['west'] <= lon <= self.BBOX_MSH['east'])

    def fetch_wandernadel_data(self) -> Dict[str, Any]:
        """Holt Wandernadel-Daten von Overpass API"""

        print(f"[WANDERNADEL] Frage Overpass API nach Stempelstellen ab...")
        print(f"   Bounding Box (Harz): {self.BBOX_HARZ}")
        print(f"   Filter für MSH: {self.BBOX_MSH}")

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
                print(f"   [OK] {len(elements)} Stempelstellen gefunden")
                return data

            except requests.exceptions.Timeout:
                print(f"   [TIMEOUT] bei {url.split('/')[2]}")
                continue
            except requests.exceptions.RequestException as e:
                print(f"   [ERROR] {type(e).__name__}")
                continue

        print("   [WARN] Alle Server fehlgeschlagen")
        return {"elements": []}

    def parse_stamp_number(self, tags: Dict[str, str]) -> str:
        """Extrahiert die Stempelnummer"""
        # Verschiedene Formate prüfen
        number = tags.get('hwn:stamp_number', '')
        if not number:
            number = tags.get('hwn:stamp', '')
        if not number:
            number = tags.get('ref:hwn', '')
        if not number:
            number = tags.get('ref', '')
        return number

    def parse_wandernadel_elements(self, osm_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Konvertiert OSM Elemente zu Wandernadel Stempelstellen Format"""

        stamps = []
        seen_ids = set()

        elements = osm_data.get('elements', [])

        for element in elements:
            if element['type'] != 'node':
                continue

            tags = element.get('tags', {})

            lat = element.get('lat')
            lon = element.get('lon')
            if not lat or not lon:
                continue

            # Duplikate vermeiden
            osm_id = f"hwn-{element['id']}"
            if osm_id in seen_ids:
                continue
            seen_ids.add(osm_id)

            # Stempelnummer
            stamp_number = self.parse_stamp_number(tags)

            # Name generieren
            name = tags.get('name', '')
            if not name and stamp_number:
                name = f"Stempelstelle {stamp_number}"
            elif not name:
                name = "Harzer Wandernadel Stempel"

            # Beschreibung
            description = tags.get('description', '')
            if not description and stamp_number:
                description = f"Stempelstelle Nr. {stamp_number} der Harzer Wandernadel"

            # Höhe
            elevation = tags.get('ele', '')
            if elevation:
                try:
                    elevation = f"{int(float(elevation))} m"
                except ValueError:
                    pass

            # Stadt schätzen
            city = tags.get('addr:city', self._estimate_city(lat, lon))

            stamp = {
                "id": osm_id,
                "type": "hikingStamp",
                "name": name,
                "description": description,

                # Präzise Koordinaten (WICHTIG für Wanderer!)
                "latitude": lat,
                "longitude": lon,

                # Stempel-spezifisch
                "stampNumber": stamp_number,
                "stampSeries": "Harzer Wandernadel",

                # Adresse
                "city": city,
                "elevation": elevation,

                # Zusätzliche Infos
                "operator": tags.get('operator', 'Harzer Wandernadel'),
                "website": tags.get('website', 'https://www.harzer-wandernadel.de'),

                # Öffnungszeiten (Stempelkästen sind meist 24/7)
                "openingHours": tags.get('opening_hours', '24/7'),
                "is24h": '24/7' in tags.get('opening_hours', '24/7'),

                # Zugänglichkeit
                "isBarrierFree": tags.get('wheelchair') == 'yes',

                # Quelle
                "source": "openstreetmap",
                "sourceId": f"node/{element['id']}",
                "osmUrl": f"https://www.openstreetmap.org/node/{element['id']}",
            }

            # Leere Werte entfernen
            stamp = {k: v for k, v in stamp.items() if v is not None and v != ''}

            stamps.append(stamp)

        return stamps

    def _estimate_city(self, lat: float, lon: float) -> str:
        """Schätzt Stadt/Region basierend auf Koordinaten"""
        # Südharz
        if lat <= 51.55 and lon <= 11.20:
            if 51.40 <= lat <= 51.50 and 10.90 <= lon <= 11.05:
                return "Stolberg (Harz)"
            if lat <= 51.45:
                return "Südharz"
            return "Nordharz"

        # Sangerhausen-Region
        if 51.45 <= lat <= 51.55 and 11.20 <= lon <= 11.40:
            return "Sangerhausen"

        # Kyffhäuser
        if lat <= 51.45 and lon >= 11.00:
            return "Kyffhäuser"

        # Eisleben-Region
        if 51.50 <= lat <= 51.60 and 11.45 <= lon <= 11.65:
            return "Lutherstadt Eisleben"

        # Hettstedt-Region
        if lat >= 51.60:
            return "Hettstedt"

        return "Mansfeld-Südharz"

    def scrape(self) -> List[Dict[str, Any]]:
        """Hauptmethode: Scraped Wandernadel-Stempelstellen"""

        print("\n" + "="*60)
        print("[WANDERNADEL] Harzer Wandernadel Scraper fuer MSH-Region")
        print("="*60)
        print("[INFO] Genaue Positionen sind für Wanderer essentiell!")

        time.sleep(self.rate_limit)

        # Daten holen
        osm_data = self.fetch_wandernadel_data()

        # Parsen
        stamps = self.parse_wandernadel_elements(osm_data)

        # Nach Stempelnummer sortieren
        stamps.sort(key=lambda x: x.get('stampNumber', 'ZZZ'))

        print(f"\n[OK] {len(stamps)} Stempelstellen gefunden")

        # Statistik nach Region
        regions = {}
        for stamp in stamps:
            city = stamp.get('city', 'Unbekannt')
            regions[city] = regions.get(city, 0) + 1

        print("\n[STATS] Nach Region:")
        for city, count in sorted(regions.items(), key=lambda x: x[1], reverse=True):
            print(f"   - {city}: {count}")

        # Stempelnummern ausgeben
        numbers = [s.get('stampNumber', '?') for s in stamps if s.get('stampNumber')]
        if numbers:
            print(f"\n[INFO] Stempelnummern: {', '.join(sorted(numbers)[:20])}{'...' if len(numbers) > 20 else ''}")

        return stamps


def main():
    """Hauptfunktion"""
    scraper = WandernadelScraper()
    stamps = scraper.scrape()

    # Output-Verzeichnis
    output_dir = Path(__file__).parent.parent / "output" / "outdoor"
    output_dir.mkdir(parents=True, exist_ok=True)

    # Export
    output_file = output_dir / "wandernadel_osm.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "openstreetmap",
                "scraped_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "bbox": scraper.BBOX_HARZ,
                "count": len(stamps),
                "info": "Harzer Wandernadel Stempelstellen"
            },
            "data": stamps
        }, f, ensure_ascii=False, indent=2)

    print(f"\n[SAVED] Gespeichert: {output_file}")

    # Für Flutter-App auch als assets exportieren
    flutter_assets = Path(__file__).parent.parent.parent / "assets" / "data" / "outdoor"
    flutter_assets.mkdir(parents=True, exist_ok=True)

    flutter_file = flutter_assets / "wandernadel.json"
    with open(flutter_file, 'w', encoding='utf-8') as f:
        json.dump(stamps, f, ensure_ascii=False, indent=2)

    print(f"[SAVED] Flutter-Assets: {flutter_file}")

    print("\n" + "="*60)
    print("[OK] Wandernadel Scraping abgeschlossen!")
    print("="*60)


if __name__ == "__main__":
    main()
