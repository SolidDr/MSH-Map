#!/usr/bin/env python3
"""
Notice Koordinaten-Validator

Validiert die Koordinaten in notices_current.json:
1. Prüft ob alle Koordinaten im Landkreis MSH Bounding Box liegen
2. Prüft ob Koordinaten plausibel sind (nicht 0, nicht vertauscht)
3. Optional: Schlägt Korrekturen vor mittels Nominatim Geocoding

Verwendung:
    python validate_notices.py                    # Nur validieren
    python validate_notices.py --fix              # Versuche Koordinaten zu korrigieren
    python validate_notices.py --verbose          # Detaillierte Ausgabe
"""

import json
import sys
import argparse
from pathlib import Path
from typing import Optional, Tuple
import urllib.request
import urllib.parse
import time

# Bounding Box für Landkreis Mansfeld-Südharz (großzügig)
MSH_BOUNDS = {
    "min_lat": 51.35,   # Südgrenze (Kyffhäuser)
    "max_lat": 51.75,   # Nordgrenze (nördlich von Hettstedt)
    "min_lon": 10.90,   # Westgrenze
    "max_lon": 11.80    # Ostgrenze (Saale)
}

# Bekannte Orte im Landkreis MSH für Plausibilitätsprüfung
KNOWN_LOCATIONS = {
    "Sangerhausen": (51.4733, 11.2973),
    "Eisleben": (51.5275, 11.5500),
    "Hettstedt": (51.6449, 11.5112),
    "Mansfeld": (51.5933, 11.4500),
    "Kyffhäuser": (51.4135, 11.1096),
    "Walbeck": (51.6667, 11.4667),
    "Quenstedt": (51.7200, 11.4500),
    "Freist": (51.6000, 11.7000),
    "Neckendorf": (51.5050, 11.5250),
    "Wolferode": (51.5100, 11.5150),
}

def is_in_msh_bounds(lat: float, lon: float) -> bool:
    """Prüft ob Koordinaten in MSH Bounding Box liegen"""
    return (MSH_BOUNDS["min_lat"] <= lat <= MSH_BOUNDS["max_lat"] and
            MSH_BOUNDS["min_lon"] <= lon <= MSH_BOUNDS["max_lon"])

def validate_coordinate_format(lat: float, lon: float) -> Tuple[bool, str]:
    """Prüft ob Koordinaten plausibel formatiert sind"""
    # Vertauschte Koordinaten erkennen (Longitude als Latitude)
    if 10 <= lat <= 12 and 51 <= lon <= 52:
        return False, "Koordinaten vermutlich vertauscht (lat/lon)"

    # Null-Koordinaten
    if lat == 0 or lon == 0:
        return False, "Null-Koordinaten gefunden"

    # Plausibilität für Deutschland (grob)
    if not (47 <= lat <= 55 and 5 <= lon <= 15):
        return False, "Koordinaten außerhalb Deutschlands"

    return True, "OK"

def geocode_address(address: str) -> Optional[Tuple[float, float]]:
    """Geocodiert eine Adresse via Nominatim (OSM)"""
    try:
        # Rate limiting respektieren
        time.sleep(1)

        query = urllib.parse.urlencode({
            "q": f"{address}, Mansfeld-Südharz, Sachsen-Anhalt, Deutschland",
            "format": "json",
            "limit": 1
        })
        url = f"https://nominatim.openstreetmap.org/search?{query}"

        req = urllib.request.Request(url, headers={
            "User-Agent": "MSH-Map-Notice-Validator/1.0"
        })

        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            if data:
                return float(data[0]["lat"]), float(data[0]["lon"])
    except Exception as e:
        print(f"  Geocoding-Fehler für '{address}': {e}")

    return None

def find_nearest_known_location(lat: float, lon: float) -> Tuple[str, float]:
    """Findet den nächsten bekannten Ort und berechnet Distanz"""
    from math import radians, sin, cos, sqrt, atan2

    def haversine(lat1, lon1, lat2, lon2):
        R = 6371  # Erdradius in km
        dlat = radians(lat2 - lat1)
        dlon = radians(lon2 - lon1)
        a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2)**2
        c = 2 * atan2(sqrt(a), sqrt(1-a))
        return R * c

    nearest = None
    min_dist = float('inf')

    for name, (known_lat, known_lon) in KNOWN_LOCATIONS.items():
        dist = haversine(lat, lon, known_lat, known_lon)
        if dist < min_dist:
            min_dist = dist
            nearest = name

    return nearest, min_dist

def validate_notices(notices_path: Path, fix: bool = False, verbose: bool = False) -> bool:
    """Validiert alle Notices und gibt Ergebnis zurück"""

    if not notices_path.exists():
        print(f"Fehler: {notices_path} nicht gefunden")
        return False

    with open(notices_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    notices = data.get("notices", [])
    errors = []
    warnings = []
    fixed = []

    print(f"\n{'='*60}")
    print(f"Validiere {len(notices)} Notices")
    print(f"{'='*60}\n")

    for notice in notices:
        notice_id = notice.get("id", "???")
        title = notice.get("title", "???")
        lat = notice.get("latitude")
        lon = notice.get("longitude")
        affected_area = notice.get("affected_area", "")

        if verbose:
            print(f"Prüfe: {notice_id} - {title}")

        # Pflichtfelder prüfen
        if lat is None or lon is None:
            errors.append(f"{notice_id}: Keine Koordinaten angegeben")
            continue

        # Format prüfen
        is_valid, msg = validate_coordinate_format(lat, lon)
        if not is_valid:
            errors.append(f"{notice_id}: {msg} (lat={lat}, lon={lon})")
            continue

        # MSH Bounds prüfen
        if not is_in_msh_bounds(lat, lon):
            nearest, dist = find_nearest_known_location(lat, lon)
            errors.append(f"{notice_id}: Außerhalb MSH (lat={lat}, lon={lon})")
            errors.append(f"          Nächster bekannter Ort: {nearest} ({dist:.1f} km entfernt)")

            if fix:
                # Versuche Geocoding
                new_coords = geocode_address(affected_area)
                if new_coords and is_in_msh_bounds(*new_coords):
                    notice["latitude"] = round(new_coords[0], 4)
                    notice["longitude"] = round(new_coords[1], 4)
                    fixed.append(f"{notice_id}: Korrigiert zu {new_coords}")
            continue

        # Distanz-Warnung wenn weit von bekannten Orten
        nearest, dist = find_nearest_known_location(lat, lon)
        if dist > 15:
            warnings.append(f"{notice_id}: {dist:.1f} km von {nearest} entfernt - bitte prüfen")

        if verbose:
            print(f"  OK - Nächster Ort: {nearest} ({dist:.1f} km)")

    # Ergebnis ausgeben
    print(f"\n{'='*60}")
    print("ERGEBNIS")
    print(f"{'='*60}")

    if errors:
        print(f"\n{len(errors)} FEHLER:")
        for err in errors:
            print(f"  {err}")

    if warnings:
        print(f"\n{len(warnings)} WARNUNGEN:")
        for warn in warnings:
            print(f"  {warn}")

    if fixed:
        print(f"\n{len(fixed)} KORREKTUREN:")
        for fix_msg in fixed:
            print(f"  {fix_msg}")

        # Speichern
        data["meta"]["last_verification"] = time.strftime("%Y-%m-%d")
        data["meta"]["coordinates_verified"] = True
        with open(notices_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"\nÄnderungen gespeichert in {notices_path}")

    if not errors and not warnings:
        print("\n Alle Koordinaten sind korrekt!")

    print(f"\n{'='*60}\n")

    return len(errors) == 0

def main():
    parser = argparse.ArgumentParser(description="Validiert Notice-Koordinaten")
    parser.add_argument("--fix", action="store_true", help="Versuche Koordinaten zu korrigieren")
    parser.add_argument("--verbose", "-v", action="store_true", help="Detaillierte Ausgabe")
    parser.add_argument("--file", type=str, help="Pfad zur notices JSON Datei")
    args = parser.parse_args()

    # Standard-Pfad
    script_dir = Path(__file__).parent.parent.parent
    notices_path = script_dir / "data" / "notices" / "notices_current.json"

    if args.file:
        notices_path = Path(args.file)

    success = validate_notices(notices_path, fix=args.fix, verbose=args.verbose)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
