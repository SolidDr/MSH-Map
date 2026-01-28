#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Wanderwege Scraper via Overpass API
Sammelt Wanderrouten in der MSH-Region (Mansfeld-Südharz)

WICHTIG:
- Prüft Sicherheit/Begehbarkeit so weit wie möglich
- Markiert ungeprüfte Wege entsprechend
"""

import json
import time
from typing import List, Dict, Any, Tuple
from pathlib import Path
import requests


class WanderwegeScraper:
    """Spezialisierter Scraper für Wanderwege aus OpenStreetMap"""

    # MSH-Region (erweitert für Grenzwege)
    BBOX_MSH = {
        "south": 51.30,
        "west": 10.70,
        "north": 51.80,
        "east": 11.80
    }

    # Overpass Server
    OVERPASS_URLS = [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter",
    ]
    REQUEST_TIMEOUT = 180

    # Bekannte Wanderwege in MSH (für Validierung)
    KNOWN_TRAILS = {
        "karstwanderweg": {
            "patterns": ["Karstwanderweg", "Karst", "karstwanderweg"],
            "verified": True,
            "category": "fernwanderweg",
            "difficulty": "mittel",
        },
        "selketal_stieg": {
            "patterns": ["Selketal-Stieg", "Selketalstieg", "Selketal"],
            "verified": True,
            "category": "fernwanderweg",
            "difficulty": "mittel",
        },
        "lutherweg": {
            "patterns": ["Lutherweg", "Luther-Weg", "luther"],
            "verified": True,
            "category": "themenwanderweg",
            "difficulty": "leicht",
        },
        "harzer_hexenstieg": {
            "patterns": ["Hexen-Stieg", "Hexenstieg", "Harzer Hexenstieg"],
            "verified": True,
            "category": "fernwanderweg",
            "difficulty": "mittel",
        },
        "himmelsscheibenweg": {
            "patterns": ["Himmelsscheibe", "Himmelscheibe", "Nebra"],
            "verified": True,
            "category": "themenwanderweg",
            "difficulty": "mittel",
        },
        "kyffhaeuser": {
            "patterns": ["Kyffhäuser", "Kyffhauser", "Barbarossa"],
            "verified": True,
            "category": "themenwanderweg",
            "difficulty": "mittel",
        },
    }

    def __init__(self, rate_limit: float = 2.0):
        self.rate_limit = rate_limit
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'MSH-Map-WanderwegeScraper/1.0 (Educational Purpose; contact@kolan-systems.de)'
        })

    def build_overpass_query(self) -> str:
        """Erstellt Overpass Query für Wanderwege"""
        bbox_str = f"{self.BBOX_MSH['south']},{self.BBOX_MSH['west']},{self.BBOX_MSH['north']},{self.BBOX_MSH['east']}"

        query = f"""
[out:json][timeout:{self.REQUEST_TIMEOUT}];
(
  // Wanderrouten (Relations)
  relation["route"="hiking"]({bbox_str});
  relation["route"="foot"]({bbox_str});

  // Fernwanderwege
  relation["network"~"lwn|rwn|nwn"]({bbox_str});

  // Bekannte Wege nach Name
  relation["name"~"Karstwanderweg|Selketal|Lutherweg|Himmelsscheibe|Hexenstieg|Kyffhäuser|Josephskreuz|Stolberg|Thyra"]({bbox_str});

  // Wanderwege mit ref
  relation["ref"~"E11|X|H|KW"]({bbox_str});
);
out body geom;
"""
        return query

    def fetch_trail_data(self) -> Dict[str, Any]:
        """Holt Wanderweg-Daten von Overpass API"""

        print(f"[WANDERWEGE] Frage Overpass API nach Wanderwegen ab...")
        print(f"   Bounding Box: {self.BBOX_MSH}")

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
                print(f"   [ERROR] {type(e).__name__}: {e}")
                continue

        print("   [WARN] Alle Server fehlgeschlagen")
        return {"elements": []}

    def extract_route_points(self, element: Dict[str, Any]) -> List[Tuple[float, float]]:
        """Extrahiert GPS-Punkte aus Relation-Geometrie"""
        points = []

        # Direkte Geometrie in members
        members = element.get('members', [])
        for member in members:
            if member.get('type') == 'way':
                geometry = member.get('geometry', [])
                for point in geometry:
                    if 'lat' in point and 'lon' in point:
                        points.append((point['lat'], point['lon']))

        # Falls keine Geometrie, bounds als Fallback
        if not points and 'bounds' in element:
            bounds = element['bounds']
            center_lat = (bounds['minlat'] + bounds['maxlat']) / 2
            center_lon = (bounds['minlon'] + bounds['maxlon']) / 2
            points.append((center_lat, center_lon))

        return points

    def calculate_route_length(self, points: List[Tuple[float, float]]) -> float:
        """Berechnet ungefähre Routenlänge in km"""
        if len(points) < 2:
            return 0.0

        total = 0.0
        for i in range(len(points) - 1):
            lat1, lon1 = points[i]
            lat2, lon2 = points[i + 1]
            # Vereinfachte Haversine-Formel
            import math
            R = 6371  # Erdradius in km
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
            c = 2 * math.asin(math.sqrt(a))
            total += R * c

        return round(total, 1)

    def identify_known_trail(self, name: str) -> Tuple[str, Dict[str, Any]]:
        """Identifiziert bekannten Wanderweg anhand des Namens"""
        name_lower = name.lower()

        for trail_id, info in self.KNOWN_TRAILS.items():
            for pattern in info['patterns']:
                if pattern.lower() in name_lower:
                    return trail_id, info

        return None, {}

    def assess_trail_safety(self, tags: Dict[str, str], known_info: Dict[str, Any]) -> Dict[str, Any]:
        """Bewertet Sicherheit/Begehbarkeit des Weges"""

        # Bekannte Wege sind verifiziert
        if known_info.get('verified'):
            return {
                "status": "verified",
                "warning": None,
                "seasonal": None,
            }

        # Prüfe Tags für Hinweise
        surface = tags.get('surface', '')
        trail_visibility = tags.get('trail_visibility', '')
        sac_scale = tags.get('sac_scale', '')

        warning = None
        status = "unverified"

        # Warnungen basierend auf Eigenschaften
        if sac_scale in ['demanding_alpine_hiking', 'alpine_hiking', 'difficult_alpine_hiking']:
            warning = "Alpiner Weg - nur für erfahrene Wanderer!"
            status = "caution"
        elif trail_visibility in ['no', 'horrible', 'bad']:
            warning = "Schlecht sichtbarer Pfad - GPS empfohlen"
            status = "caution"
        elif surface in ['rock', 'scree', 'gravel']:
            warning = "Steiniger Untergrund - festes Schuhwerk erforderlich"

        return {
            "status": status,
            "warning": warning,
            "seasonal": tags.get('seasonal') or tags.get('access:conditional'),
        }

    def parse_trail_elements(self, osm_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Konvertiert OSM Elemente zu Wanderweg-Format"""

        trails = []
        seen_ids = set()

        elements = osm_data.get('elements', [])

        for element in elements:
            if element['type'] != 'relation':
                continue

            tags = element.get('tags', {})

            # Name ist erforderlich
            name = tags.get('name', '')
            if not name:
                continue

            # Duplikate vermeiden
            osm_id = f"trail-{element['id']}"
            if osm_id in seen_ids:
                continue
            seen_ids.add(osm_id)

            # Bekannten Weg identifizieren
            known_id, known_info = self.identify_known_trail(name)

            # GPS-Punkte extrahieren
            points = self.extract_route_points(element)
            if not points:
                print(f"   [SKIP] Keine Geometrie: {name}")
                continue

            # Länge berechnen oder aus Tags
            length_km = 0.0
            if tags.get('distance'):
                try:
                    # Format: "12 km" oder "12.5"
                    dist_str = tags['distance'].replace('km', '').replace(' ', '').replace(',', '.')
                    length_km = float(dist_str)
                except ValueError:
                    pass

            if not length_km:
                length_km = self.calculate_route_length(points)

            # Schwierigkeit
            difficulty = "leicht"
            sac_scale = tags.get('sac_scale', '')
            if sac_scale:
                if 'hiking' in sac_scale:
                    difficulty = "leicht"
                elif 'mountain' in sac_scale:
                    difficulty = "mittel"
                elif 'alpine' in sac_scale:
                    difficulty = "schwer"
            elif known_info.get('difficulty'):
                difficulty = known_info['difficulty']

            # Kategorie
            category = "rundwanderweg"
            network = tags.get('network', '')
            if known_info.get('category'):
                category = known_info['category']
            elif network in ['lwn', 'nwn']:
                category = "fernwanderweg"
            elif 'rund' in name.lower() or 'loop' in tags.get('roundtrip', '').lower():
                category = "rundwanderweg"

            # Höhenmeter
            elevation_gain = None
            if tags.get('ascent'):
                try:
                    elevation_gain = int(float(tags['ascent'].replace('m', '').replace(' ', '')))
                except ValueError:
                    pass

            # Sicherheitsbewertung
            safety = self.assess_trail_safety(tags, known_info)

            # Zentrum berechnen
            center_lat = sum(p[0] for p in points) / len(points)
            center_lon = sum(p[1] for p in points) / len(points)

            # Route vereinfachen (max 500 Punkte)
            if len(points) > 500:
                step = len(points) // 500
                points = points[::step]

            trail = {
                "id": known_id or osm_id,
                "name": name,
                "shortName": tags.get('short_name', name.split()[0] if len(name.split()) > 1 else name[:10]),
                "description": tags.get('description', f"Wanderweg: {name}"),

                "category": category,
                "difficulty": difficulty,
                "lengthKm": length_km,

                "isCircular": tags.get('roundtrip') == 'yes' or 'rund' in name.lower(),
                "elevationGain": elevation_gain,

                # Koordinaten
                "center": {"lat": center_lat, "lon": center_lon},
                "routePoints": [{"lat": p[0], "lon": p[1]} for p in points],

                # Sicherheit
                "status": safety["status"],
                "safetyWarning": safety["warning"],
                "seasonalInfo": safety["seasonal"],

                # Zusatzinfos
                "website": tags.get('website', tags.get('url', '')),
                "operator": tags.get('operator', ''),
                "ref": tags.get('ref', ''),

                # Quelle
                "source": "openstreetmap",
                "osmId": element['id'],
                "osmUrl": f"https://www.openstreetmap.org/relation/{element['id']}",
            }

            # Leere Werte entfernen
            trail = {k: v for k, v in trail.items() if v is not None and v != '' and v != []}

            trails.append(trail)

        return trails

    def scrape(self) -> List[Dict[str, Any]]:
        """Hauptmethode: Scraped Wanderwege"""

        print("\n" + "="*60)
        print("[WANDERWEGE] Wanderwege Scraper fuer MSH-Region")
        print("="*60)
        print("[INFO] Pruefe Sicherheit/Begehbarkeit so weit moeglich")
        print("[WARN] Ungepruefte Wege werden entsprechend markiert!")

        time.sleep(self.rate_limit)

        # Daten holen
        osm_data = self.fetch_trail_data()

        # Parsen
        trails = self.parse_trail_elements(osm_data)

        # Nach Länge sortieren
        trails.sort(key=lambda x: x.get('lengthKm', 0), reverse=True)

        print(f"\n[OK] {len(trails)} Wanderwege gefunden")

        # Statistik
        by_category = {}
        by_status = {}
        for trail in trails:
            cat = trail.get('category', 'unbekannt')
            by_category[cat] = by_category.get(cat, 0) + 1

            status = trail.get('status', 'unverified')
            by_status[status] = by_status.get(status, 0) + 1

        print("\n[STATS] Nach Kategorie:")
        for cat, count in sorted(by_category.items(), key=lambda x: x[1], reverse=True):
            print(f"   - {cat}: {count}")

        print("\n[STATS] Nach Status:")
        for status, count in sorted(by_status.items()):
            marker = "[OK]" if status == "verified" else "[!]" if status == "caution" else "[?]"
            print(f"   - {marker} {status}: {count}")

        # Top 10 nach Länge
        print("\n[TOP 10] Längste Wanderwege:")
        for trail in trails[:10]:
            print(f"   - {trail['name']}: {trail.get('lengthKm', '?')} km ({trail.get('status', '?')})")

        return trails


def main():
    """Hauptfunktion"""
    scraper = WanderwegeScraper()
    trails = scraper.scrape()

    # Output-Verzeichnis
    output_dir = Path(__file__).parent.parent / "output" / "outdoor"
    output_dir.mkdir(parents=True, exist_ok=True)

    # Export
    output_file = output_dir / "wanderwege_osm.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            "meta": {
                "source": "openstreetmap",
                "scraped_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "bbox": scraper.BBOX_MSH,
                "count": len(trails),
                "info": "Wanderwege in MSH-Region"
            },
            "data": trails
        }, f, ensure_ascii=False, indent=2)

    print(f"\n[SAVED] Gespeichert: {output_file}")

    # Für Flutter-App auch als assets exportieren (nur Dart-kompatibel)
    flutter_dir = Path(__file__).parent.parent.parent / "lib" / "assets" / "data" / "outdoor"
    flutter_dir.mkdir(parents=True, exist_ok=True)

    # Vereinfachtes Format für Flutter
    flutter_trails = []
    for trail in trails:
        flutter_trails.append({
            "id": trail.get('id'),
            "name": trail.get('name'),
            "shortName": trail.get('shortName'),
            "description": trail.get('description'),
            "category": trail.get('category'),
            "difficulty": trail.get('difficulty'),
            "lengthKm": trail.get('lengthKm'),
            "isCircular": trail.get('isCircular', False),
            "elevationGain": trail.get('elevationGain'),
            "status": trail.get('status'),
            "safetyWarning": trail.get('safetyWarning'),
            "seasonalInfo": trail.get('seasonalInfo'),
            "website": trail.get('website'),
            "center": trail.get('center'),
            "routePoints": trail.get('routePoints', []),
        })

    flutter_file = flutter_dir / "wanderwege.json"
    with open(flutter_file, 'w', encoding='utf-8') as f:
        json.dump(flutter_trails, f, ensure_ascii=False, indent=2)

    print(f"[SAVED] Flutter-Assets: {flutter_file}")

    print("\n" + "="*60)
    print("[OK] Wanderwege Scraping abgeschlossen!")
    print("="*60)

    # Warnungen ausgeben
    unverified = [t for t in trails if t.get('status') != 'verified']
    if unverified:
        print(f"\n[WARNUNG] {len(unverified)} Wege sind NICHT verifiziert!")
        print("   Diese muessen vor Veroeffentlichung manuell geprueft werden!")


if __name__ == "__main__":
    main()
