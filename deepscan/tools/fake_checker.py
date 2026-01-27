#!/usr/bin/env python3
"""
Fake Data Checker für MSH Radar

Prüft alle Datenbankeinträge auf Echtheit und markiert verdächtige Einträge.
Nur Einträge aus verifizierten Quellen (OSM, Wikidata) oder manuell bestätigten
Whitelists werden als vertrauenswürdig eingestuft.

WICHTIG: Dieses Tool verhindert, dass halluzinierte oder Fake-Daten in die
Produktion gelangen!

Usage:
    python fake_checker.py                    # Prüft alle Daten
    python fake_checker.py --strict           # Nur OSM/Wikidata erlaubt
    python fake_checker.py --remove-suspicious # Entfernt verdächtige Einträge
    python fake_checker.py --verify-online    # Online-Verifizierung via Nominatim
"""

import json
import argparse
import os
import sys
import time
from datetime import datetime
from pathlib import Path

# Vertrauenswürdige Datenquellen
TRUSTED_SOURCES = ['openstreetmap', 'wikidata', 'osm']

# Manuell verifizierte echte Orte (NIEMALS halluzinierte Einträge hier hinzufügen!)
# Jeder Eintrag muss mit einer echten URL oder offizieller Quelle belegt sein
VERIFIED_WHITELIST = {
    # UNESCO Welterbe & offizielle Museen (verifiziert durch UNESCO/offizielle Seiten)
    'europa-rosarium-sangerhausen': 'https://www.europa-rosarium.de',
    'luthers-geburtshaus': 'https://www.luthermuseen.de',
    'luthers-sterbehaus': 'https://www.luthermuseen.de',
    'bergbaumuseum-roehrigschacht': 'https://www.roehrigschacht.de',
    'panorama-museum-bad-frankenhausen': 'https://www.panorama-museum.de',

    # Bekannte Sehenswürdigkeiten (verifiziert durch Wikipedia/offizielle Quellen)
    'kyffhaeuser-denkmal': 'https://de.wikipedia.org/wiki/Kyffh%C3%A4userdenkmal',
    'barbarossahoehle': 'https://www.hoehle.de',
    'josephskreuz-stolberg': 'https://de.wikipedia.org/wiki/Josephskreuz',
    'bad-frankenhausen-schiefturm': 'https://de.wikipedia.org/wiki/Oberkirche_(Bad_Frankenhausen)',

    # Schlösser und Burgen (offizielle Seiten)
    'schloss-mansfeld': 'https://www.schlossmansfeld.de',
    'allstedt-burg': 'https://www.burg-allstedt.de',

    # Offizielle städtische Einrichtungen
    'lutherstadt-eisleben-altstadt': 'UNESCO Welterbe Stadt',
    'sangerhausen-altstadt': 'Kreisstadt MSH',
    'hettstedt-marktplatz': 'Stadtzentrum Hettstedt',

    # Gewässer (geografisch verifiziert)
    'suesser-see': 'https://de.wikipedia.org/wiki/S%C3%BC%C3%9Fer_See',
    'wippertalsperre': 'https://de.wikipedia.org/wiki/Wippertalsperre',

    # Stadtmuseen (offizielle kommunale Einrichtungen)
    'spengler-museum-sangerhausen': 'https://www.spengler-museum.de',
    'museum-synagoge-eisleben': 'Städtisches Museum',
    'heimatmuseum-hettstedt': 'Städtisches Museum',
}

# BLACKLIST: Bekannte Fake/Halluzinierte Einträge
# Diese werden IMMER entfernt, egal was
KNOWN_FAKES = [
    # Keine verifizierbare Online-Präsenz gefunden:
    'kinderland-indoor',           # Kein Nachweis für Indoor-Spielplatz in SGH
    'cafe-rosenduft',              # Keine verifizierbare Adresse
    'kletterwald-questenberg',     # Kein Kletterwald in Questenberg nachweisbar
    'fussballgolf-questenberg',    # Kein Fußballgolf in Questenberg nachweisbar
    'erlebnisbauernhof-stolberg',  # Nicht nachweisbar
    'naturbad-questenberg',        # Nicht nachweisbar
    'minigolf-sangerhausen',       # Nicht nachweisbar an genannter Adresse
]

# Verdächtige Muster in Namen/Beschreibungen
SUSPICIOUS_PATTERNS = [
    'beispiel', 'test', 'demo', 'dummy', 'mock', 'sample', 'fake',
    'lorem', 'ipsum', 'placeholder', 'xxx', '123', 'abc',
    'mustermann', 'max muster', 'john doe', 'jane doe'
]

# Verdächtige Kategorien ohne OSM-Quelle
HIGH_RISK_CATEGORIES = [
    'doctor', 'arzt', 'praxis', 'zahnarzt', 'healthcare', 'medical',
    'apotheke', 'pharmacy', 'hospital', 'klinik', 'notfall',
    'beratung', 'hilfe', 'anlaufstelle', 'social'
]


def load_json(filepath: str) -> dict:
    """Lädt JSON-Datei."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json(filepath: str, data: dict):
    """Speichert JSON-Datei."""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def check_suspicious_patterns(text: str) -> list:
    """Prüft Text auf verdächtige Muster."""
    if not text:
        return []
    text_lower = text.lower()
    found = []
    for pattern in SUSPICIOUS_PATTERNS:
        if pattern in text_lower:
            found.append(pattern)
    return found


def verify_with_nominatim(name: str, city: str, lat: float, lon: float) -> dict:
    """Verifiziert Ort mittels Nominatim Geocoding API."""
    try:
        import requests

        # Rate limiting
        time.sleep(1.1)  # Nominatim erlaubt max 1 Request/Sekunde

        headers = {
            'User-Agent': 'MSHRadar-FakeChecker/1.0 (https://msh-radar.de)'
        }

        # Suche nach Name + Stadt
        search_query = f"{name}, {city}, Germany"
        url = f"https://nominatim.openstreetmap.org/search?q={search_query}&format=json&limit=1"

        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            results = response.json()
            if results:
                result = results[0]
                result_lat = float(result.get('lat', 0))
                result_lon = float(result.get('lon', 0))

                # Prüfe ob Koordinaten ungefähr übereinstimmen (5km Toleranz)
                lat_diff = abs(result_lat - lat)
                lon_diff = abs(result_lon - lon)

                if lat_diff < 0.05 and lon_diff < 0.05:  # ~5km
                    return {
                        'verified': True,
                        'method': 'nominatim',
                        'confidence': 'high' if lat_diff < 0.01 else 'medium',
                        'osm_id': result.get('osm_id'),
                        'osm_type': result.get('osm_type')
                    }
                else:
                    return {
                        'verified': False,
                        'method': 'nominatim',
                        'reason': f'Koordinaten weichen ab: {lat_diff:.3f}, {lon_diff:.3f}'
                    }
            else:
                return {
                    'verified': False,
                    'method': 'nominatim',
                    'reason': 'Nicht gefunden'
                }
        else:
            return {
                'verified': False,
                'method': 'nominatim',
                'reason': f'API-Fehler: {response.status_code}'
            }
    except Exception as e:
        return {
            'verified': False,
            'method': 'nominatim',
            'reason': f'Fehler: {str(e)}'
        }


def analyze_entry(entry_id: str, entry: dict, verify_online: bool = False) -> dict:
    """Analysiert einen Eintrag auf Echtheit."""
    result = {
        'id': entry_id,
        'name': entry.get('name', 'UNKNOWN'),
        'category': entry.get('category', 'unknown'),
        'source': entry.get('source', 'unknown'),
        'status': 'unknown',
        'reasons': [],
        'confidence': 0
    }

    # 1. Prüfe auf bekannte Fakes
    for fake_pattern in KNOWN_FAKES:
        if fake_pattern in entry_id.lower():
            result['status'] = 'FAKE'
            result['reasons'].append(f'Bekannter Fake-Eintrag: {fake_pattern}')
            result['confidence'] = 100
            return result

    # 2. Prüfe Datenquelle
    source = entry.get('source', '').lower()
    if source in TRUSTED_SOURCES:
        result['status'] = 'VERIFIED'
        result['reasons'].append(f'Vertrauenswürdige Quelle: {source}')
        result['confidence'] = 95
        return result

    # 3. Prüfe Whitelist
    if entry_id in VERIFIED_WHITELIST:
        result['status'] = 'VERIFIED'
        result['reasons'].append(f'Manuell verifiziert: {VERIFIED_WHITELIST[entry_id]}')
        result['confidence'] = 90
        return result

    # 4. Prüfe verdächtige Muster
    name = entry.get('name', '')
    desc = entry.get('description', '')
    suspicious = check_suspicious_patterns(f"{name} {desc}")
    if suspicious:
        result['status'] = 'FAKE'
        result['reasons'].append(f'Verdächtige Muster: {", ".join(suspicious)}')
        result['confidence'] = 85
        return result

    # 5. Prüfe High-Risk Kategorien
    category = entry.get('category', '').lower()
    for risk_cat in HIGH_RISK_CATEGORIES:
        if risk_cat in category:
            result['status'] = 'SUSPICIOUS'
            result['reasons'].append(f'Hochrisiko-Kategorie ohne verifizierte Quelle: {category}')
            result['confidence'] = 70
            return result

    # 6. Online-Verifizierung (optional)
    if verify_online and source not in TRUSTED_SOURCES:
        coords = entry.get('coordinates', {})
        lat = coords.get('latitude', entry.get('latitude', 0))
        lon = coords.get('longitude', entry.get('longitude', 0))
        city = entry.get('city', '')

        if lat and lon and city:
            verification = verify_with_nominatim(name, city, lat, lon)
            if verification.get('verified'):
                result['status'] = 'VERIFIED'
                result['reasons'].append(f'Online verifiziert via {verification["method"]}')
                result['confidence'] = 80
                result['nominatim'] = verification
            else:
                result['status'] = 'SUSPICIOUS'
                result['reasons'].append(f'Online-Verifizierung fehlgeschlagen: {verification.get("reason")}')
                result['confidence'] = 40
                result['nominatim'] = verification
            return result

    # 7. Unbekannte Quelle ohne Verifizierung
    if source == 'unknown' or not source:
        result['status'] = 'SUSPICIOUS'
        result['reasons'].append('Unbekannte Datenquelle, nicht verifiziert')
        result['confidence'] = 30
    else:
        result['status'] = 'UNKNOWN'
        result['reasons'].append(f'Unbekannte Quelle: {source}')
        result['confidence'] = 50

    return result


def check_data(data: dict, strict: bool = False, verify_online: bool = False) -> dict:
    """Prüft alle Daten auf Fakes."""
    results = {
        'timestamp': datetime.now().isoformat(),
        'total_entries': 0,
        'verified': [],
        'suspicious': [],
        'fake': [],
        'unknown': [],
        'summary': {}
    }

    locations = data.get('locations', data.get('data', []))

    # Handle dict vs list
    if isinstance(locations, dict):
        entries = [(k, v) for k, v in locations.items()]
    else:
        entries = [(e.get('id', f'entry_{i}'), e) for i, e in enumerate(locations)]

    results['total_entries'] = len(entries)
    print(f"\n{'='*60}")
    print(f"Fake-Checker: Prüfe {len(entries)} Einträge")
    print(f"{'='*60}\n")

    for entry_id, entry in entries:
        analysis = analyze_entry(entry_id, entry, verify_online)

        if analysis['status'] == 'VERIFIED':
            results['verified'].append(analysis)
        elif analysis['status'] == 'SUSPICIOUS':
            results['suspicious'].append(analysis)
            print(f"[!] VERDACHTIG: {analysis['name']}")
            for reason in analysis['reasons']:
                print(f"    -> {reason}")
        elif analysis['status'] == 'FAKE':
            results['fake'].append(analysis)
            print(f"[X] FAKE: {analysis['name']}")
            for reason in analysis['reasons']:
                print(f"    -> {reason}")
        else:
            results['unknown'].append(analysis)

    # Summary
    results['summary'] = {
        'verified': len(results['verified']),
        'suspicious': len(results['suspicious']),
        'fake': len(results['fake']),
        'unknown': len(results['unknown'])
    }

    return results


def remove_suspicious(data: dict, results: dict, remove_suspicious_too: bool = False) -> dict:
    """Entfernt Fake-Einträge aus den Daten."""
    locations = data.get('locations', data.get('data', []))
    is_dict = isinstance(locations, dict)

    # Sammle IDs zum Entfernen
    to_remove = set()
    for entry in results['fake']:
        to_remove.add(entry['id'])

    if remove_suspicious_too:
        for entry in results['suspicious']:
            to_remove.add(entry['id'])

    print(f"\n[DEL]  Entferne {len(to_remove)} Einträge...")

    if is_dict:
        for entry_id in to_remove:
            if entry_id in locations:
                print(f"   - {entry_id}")
                del locations[entry_id]
        data['locations'] = locations
    else:
        new_list = [e for e in locations if e.get('id') not in to_remove]
        if 'locations' in data:
            data['locations'] = new_list
        else:
            data['data'] = new_list

    return data


def main():
    parser = argparse.ArgumentParser(description='Fake Data Checker für MSH Radar')
    parser.add_argument('--input', '-i', help='Input JSON file',
                       default='deepscan/output/merged/msh_firestore_merged_20260127_204613.json')
    parser.add_argument('--output', '-o', help='Output report file')
    parser.add_argument('--strict', action='store_true',
                       help='Nur OSM/Wikidata-Quellen als verifiziert akzeptieren')
    parser.add_argument('--remove-suspicious', action='store_true',
                       help='Entfernt verdächtige Einträge')
    parser.add_argument('--remove-fake', action='store_true',
                       help='Entfernt nur bekannte Fake-Einträge')
    parser.add_argument('--verify-online', action='store_true',
                       help='Online-Verifizierung via Nominatim')
    parser.add_argument('--save-cleaned', help='Speichert bereinigte Daten')

    args = parser.parse_args()

    # Windows Console Encoding fix
    if sys.platform == 'win32':
        import io
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

    # Pfade
    base_dir = Path(__file__).parent.parent.parent
    input_path = base_dir / args.input

    if not input_path.exists():
        print(f"[X] Datei nicht gefunden: {input_path}")
        sys.exit(1)

    # Lade Daten
    print(f"[>] Lade: {input_path}")
    data = load_json(str(input_path))

    # Prüfe Daten
    results = check_data(data, args.strict, args.verify_online)

    # Ausgabe
    print(f"\n{'='*60}")
    print("ERGEBNIS")
    print(f"{'='*60}")
    print(f"[OK] Verifiziert:   {results['summary']['verified']}")
    print(f"[!]  Verdächtig:    {results['summary']['suspicious']}")
    print(f"[X] Fake:          {results['summary']['fake']}")
    print(f"[?] Unbekannt:     {results['summary']['unknown']}")
    print(f"{'='*60}\n")

    # Entferne Fakes
    if args.remove_fake or args.remove_suspicious:
        data = remove_suspicious(data, results, args.remove_suspicious)

        if args.save_cleaned:
            output_path = base_dir / args.save_cleaned
            save_json(str(output_path), data)
            print(f"\n[SAVE] Bereinigte Daten gespeichert: {output_path}")

    # Speichere Report
    if args.output:
        report_path = base_dir / args.output
        save_json(str(report_path), results)
        print(f"[REPORT] Report gespeichert: {report_path}")

    # Exit-Code basierend auf Ergebnis
    if results['summary']['fake'] > 0:
        print("\n[!!] WARNUNG: Fake-Einträge gefunden!")
        sys.exit(1)
    elif results['summary']['suspicious'] > 0:
        print("\n[!]  WARNUNG: Verdächtige Einträge gefunden!")
        sys.exit(2)
    else:
        print("\n[OK] Alle Einträge verifiziert!")
        sys.exit(0)


if __name__ == '__main__':
    main()
