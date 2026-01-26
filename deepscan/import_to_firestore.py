#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Firestore Import Script für MSH Locations
Importiert nur die Locations, keine Analytics (die werden in Flutter geladen)
"""

import json
import sys
import io
from pathlib import Path

# UTF-8 für stdout
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("\n❌ Firebase Admin SDK nicht installiert!")
    print("Installiere mit: pip install firebase-admin")
    sys.exit(1)


def import_locations_to_firestore(firestore_json_path: str):
    """
    Importiert Locations aus Firestore-Format JSON in Firestore

    Args:
        firestore_json_path: Pfad zur msh_firestore_*.json Datei
    """
    print("\n🚀 MSH Locations → Firestore Import\n")

    # Lade JSON
    print(f"📂 Lade {firestore_json_path}...")
    with open(firestore_json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    locations = data.get('locations', {})
    print(f"✅ {len(locations)} Locations gefunden\n")

    # Firebase initialisieren
    if not firebase_admin._apps:
        print("🔑 Initialisiere Firebase Admin SDK...")
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred)
        print("✅ Firebase verbunden\n")

    db = firestore.client()

    # Batch Import
    print("📤 Importiere Locations nach Firestore...")
    batch = db.batch()

    for loc_id, loc_data in locations.items():
        doc_ref = db.collection('locations').document(loc_id)
        batch.set(doc_ref, loc_data)

    # Commit
    batch.commit()
    print(f"✅ {len(locations)} Locations erfolgreich importiert!\n")

    # Verifikation
    print("🔍 Verifikation...")
    count = db.collection('locations').count().get()
    total = count[0][0].value
    print(f"✅ Firestore 'locations' Collection: {total} Dokumente\n")

    print("✨ Import abgeschlossen!")


def main():
    """Main Entry Point"""
    base_path = Path(__file__).parent
    output_path = base_path / "output" / "merged"

    # Finde neueste Firestore-Datei
    firestore_files = sorted(output_path.glob("msh_firestore_*.json"), reverse=True)

    if not firestore_files:
        print("\n❌ Keine Firestore-Datei gefunden!")
        print("Führe zuerst aus: python deepscan_main.py --seed")
        sys.exit(1)

    latest_file = firestore_files[0]

    print("\n" + "="*60)
    print("  MSH Locations Firestore Import")
    print("="*60)
    print(f"\nDatei: {latest_file.name}")
    print("\n⚠️  WICHTIG:")
    print("1. Firebase Admin SDK muss installiert sein")
    print("2. Google Cloud Application Default Credentials müssen gesetzt sein")
    print("   → gcloud auth application-default login")
    print("\nFortfahren? [y/N]: ", end='')

    choice = input().strip().lower()
    if choice != 'y':
        print("\nAbgebrochen.")
        sys.exit(0)

    import_locations_to_firestore(str(latest_file))


if __name__ == "__main__":
    main()
