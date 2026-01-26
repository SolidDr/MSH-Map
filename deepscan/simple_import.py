#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Vereinfachter Firestore Import ohne Service Account
Nutzt Firebase REST API mit Firebase Config aus firebase_options.dart
"""

import json
import sys
import io
import requests
from pathlib import Path

# UTF-8 für stdout
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Firebase Config (aus deinem Projekt)
FIREBASE_CONFIG = {
    "projectId": "lunch-radar-5d984",
    "apiKey": "AIzaSyBrsHzBak1T-V-fIj-Yh6E3jaEXFh_0qFY",  # Web API Key
}


def upload_document(project_id, collection, doc_id, data):
    """Upload ein Dokument via Firestore REST API"""
    url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents/{collection}/{doc_id}"

    # Konvertiere Python dict zu Firestore Format
    fields = {}
    for key, value in data.items():
        if isinstance(value, str):
            fields[key] = {"stringValue": value}
        elif isinstance(value, int):
            fields[key] = {"integerValue": str(value)}
        elif isinstance(value, float):
            fields[key] = {"doubleValue": value}
        elif isinstance(value, bool):
            fields[key] = {"booleanValue": value}
        elif isinstance(value, dict):
            # Nested object (z.B. coordinates)
            fields[key] = {"mapValue": {"fields": convert_to_firestore_fields(value)}}
        elif isinstance(value, list):
            # Array (z.B. tags)
            fields[key] = {"arrayValue": {"values": [{"stringValue": str(v)} for v in value]}}

    payload = {"fields": fields}

    headers = {"Content-Type": "application/json"}
    response = requests.patch(url, json=payload, headers=headers, params={"key": FIREBASE_CONFIG["apiKey"]})

    return response.status_code in [200, 204]


def convert_to_firestore_fields(obj):
    """Konvertiert verschachtelte Objekte zu Firestore Format"""
    fields = {}
    for key, value in obj.items():
        if isinstance(value, str):
            fields[key] = {"stringValue": value}
        elif isinstance(value, (int, float)):
            fields[key] = {"doubleValue": float(value)}
        elif isinstance(value, bool):
            fields[key] = {"booleanValue": value}
    return fields


def main():
    """Main Entry Point"""
    print("\n" + "="*60)
    print("  MSH Locations → Firestore (Simple REST API)")
    print("="*60)

    # Prüfe API Key
    if FIREBASE_CONFIG["apiKey"] == "YOUR_WEB_API_KEY":
        print("\n❌ Fehler: API Key nicht konfiguriert!")
        print("\n📝 So findest du deinen API Key:")
        print("1. Öffne: lib/firebase_options.dart")
        print("2. Suche nach 'apiKey' in der 'web' Configuration")
        print("3. Kopiere den Wert")
        print("4. Ersetze 'YOUR_WEB_API_KEY' in simple_import.py")
        print("\nBeispiel:")
        print("  apiKey: 'AIzaSyC...',")
        print("         ^^^^^^^^^^^ Diesen Wert")
        sys.exit(1)

    # Finde neueste Export-Datei
    base_path = Path(__file__).parent
    output_path = base_path / "output" / "merged"
    firestore_files = sorted(output_path.glob("msh_firestore_*.json"), reverse=True)

    if not firestore_files:
        print("\n❌ Keine Firestore-Datei gefunden!")
        print("Führe zuerst aus: python deepscan_main.py --seed")
        sys.exit(1)

    latest_file = firestore_files[0]
    print(f"\nDatei: {latest_file.name}")

    # Lade JSON
    print(f"\n📂 Lade Export...")
    with open(latest_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    locations = data.get('locations', {})
    print(f"✅ {len(locations)} Locations gefunden\n")

    # Import
    print("📤 Importiere Locations via REST API...")
    print("⏱️  Dies kann einige Minuten dauern...\n")

    success = 0
    failed = 0

    for i, (loc_id, loc_data) in enumerate(locations.items(), 1):
        try:
            if upload_document(
                FIREBASE_CONFIG["projectId"],
                "locations",
                loc_id,
                loc_data
            ):
                success += 1
                if i % 10 == 0:
                    print(f"  ✓ {i}/{len(locations)} Locations hochgeladen...")
            else:
                failed += 1
                print(f"  ✗ Fehler bei: {loc_id}")
        except Exception as e:
            failed += 1
            print(f"  ✗ Exception bei {loc_id}: {e}")

    print(f"\n✨ Import abgeschlossen!")
    print(f"   ✅ Erfolgreich: {success}")
    print(f"   ❌ Fehlgeschlagen: {failed}\n")


if __name__ == "__main__":
    main()
