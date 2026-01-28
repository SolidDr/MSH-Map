#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Health Data Merge Tool

Kombiniert:
1. OSM-Daten (automatisch gescraped)
2. Manuelle Daten (verifiziert von arzt-auskunft.de etc.)

Regeln:
- Manuelle Daten haben Prioritaet (verifiziert)
- Duplikate werden per Geo-Distance erkannt (100m Radius)
- Namens-Matching als zusaetzlicher Check
- Output geht direkt in assets/data/health/
"""

import json
import math
import time
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple
import argparse


class HealthMerger:
    """Merged Health-Daten aus verschiedenen Quellen"""

    # Pfade relativ zum Projekt-Root
    PROJECT_ROOT = Path(__file__).parent.parent
    OSM_DIR = Path(__file__).parent / "output" / "health"
    MANUAL_DIR = PROJECT_ROOT / "assets" / "data" / "health"
    OUTPUT_DIR = PROJECT_ROOT / "assets" / "data" / "health"

    # Duplikat-Erkennung
    DUPLICATE_RADIUS_METERS = 100  # Zwei Eintraege < 100m = Duplikat

    def __init__(self):
        self.stats = {
            "osm_total": 0,
            "manual_total": 0,
            "duplicates_removed": 0,
            "merged_total": 0
        }

    def haversine_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Berechnet Distanz in Metern zwischen zwei Koordinaten"""
        R = 6371000  # Erdradius in Metern

        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)

        a = math.sin(delta_phi/2)**2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda/2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))

        return R * c

    def normalize_name(self, name: str) -> str:
        """Normalisiert Namen fuer Vergleich"""
        name = name.lower()
        # Entferne Titel
        for title in ["dr.", "dr ", "med.", "dipl.", "dipl-med.", "mr ", "prof."]:
            name = name.replace(title, "")
        # Entferne Sonderzeichen
        name = "".join(c for c in name if c.isalnum() or c == " ")
        return " ".join(name.split())  # Normalisiere Whitespace

    def is_duplicate(self, entry1: Dict, entry2: Dict) -> bool:
        """Prueft ob zwei Eintraege Duplikate sind"""
        lat1 = entry1.get("latitude", 0)
        lon1 = entry1.get("longitude", 0)
        lat2 = entry2.get("latitude", 0)
        lon2 = entry2.get("longitude", 0)

        if not all([lat1, lon1, lat2, lon2]):
            return False

        # Geo-Distance Check
        distance = self.haversine_distance(lat1, lon1, lat2, lon2)
        if distance > self.DUPLICATE_RADIUS_METERS:
            return False

        # Namens-Aehnlichkeit als zusaetzlicher Check
        name1 = self.normalize_name(entry1.get("name", ""))
        name2 = self.normalize_name(entry2.get("name", ""))

        # Wenn Namen sehr unterschiedlich, koennen es verschiedene Praxen im selben Gebaeude sein
        if name1 and name2:
            # Einfacher Substring-Check
            if name1 in name2 or name2 in name1:
                return True
            # Levenshtein waere besser, aber fuer jetzt:
            common_words = set(name1.split()) & set(name2.split())
            if len(common_words) >= 1:  # Mindestens ein gemeinsames Wort (z.B. Nachname)
                return True

        # Bei sehr naher Distanz (<50m) trotzdem als Duplikat werten
        if distance < 50:
            return True

        return False

    def load_osm_data(self, category: str) -> List[Dict]:
        """Laedt OSM-Daten fuer eine Kategorie"""
        filename_map = {
            "doctor": "doctors_osm.json",
            "pharmacy": "pharmacies_osm.json",
            "hospital": "hospitals_osm.json",
            "physiotherapy": "physiotherapy_osm.json",
            "care_service": "care_services_osm.json",
            "medical_supply": "medical_supply_osm.json",
        }

        filepath = self.OSM_DIR / filename_map.get(category, f"{category}_osm.json")
        if not filepath.exists():
            print(f"   [WARN] OSM-Datei nicht gefunden: {filepath}")
            return []

        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            entries = data.get("data", [])
            print(f"   [OSM] {len(entries)} {category} geladen")
            self.stats["osm_total"] += len(entries)
            return entries

    def load_manual_data(self, category: str) -> List[Dict]:
        """Laedt manuell kuratierte Daten"""
        filename_map = {
            "doctor": "doctors.json",
            "pharmacy": "pharmacies.json",
            "hospital": "hospitals.json",
            "physiotherapy": "physiotherapy.json",
            "fitness": "fitness.json",
        }

        filepath = self.MANUAL_DIR / filename_map.get(category, f"{category}.json")
        if not filepath.exists():
            print(f"   [INFO] Keine manuellen Daten fuer: {category}")
            return []

        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            entries = data.get("data", [])
            # Markiere als verifiziert
            for entry in entries:
                entry["verified"] = True
                entry["source"] = data.get("meta", {}).get("source", "manual")
            print(f"   [MANUAL] {len(entries)} {category} geladen (VERIFIZIERT)")
            self.stats["manual_total"] += len(entries)
            return entries

    def merge_entries(self, manual: List[Dict], osm: List[Dict]) -> List[Dict]:
        """Merged manuelle und OSM-Daten, entfernt Duplikate"""
        merged = []

        # 1. Alle manuellen Daten uebernehmen (haben Prioritaet)
        for entry in manual:
            entry["_priority"] = 1  # Hohe Prioritaet
            merged.append(entry)

        # 2. OSM-Daten hinzufuegen wenn kein Duplikat
        duplicates = 0
        for osm_entry in osm:
            is_dup = False
            for existing in merged:
                if self.is_duplicate(osm_entry, existing):
                    is_dup = True
                    duplicates += 1
                    break

            if not is_dup:
                osm_entry["_priority"] = 2  # Niedrigere Prioritaet
                osm_entry["verified"] = False
                merged.append(osm_entry)

        self.stats["duplicates_removed"] += duplicates
        if duplicates > 0:
            print(f"   [DEDUP] {duplicates} Duplikate entfernt")

        return merged

    def generate_id(self, entry: Dict, category: str, index: int) -> str:
        """Generiert eindeutige ID"""
        if entry.get("id") and not entry["id"].startswith("osm-"):
            return entry["id"]  # Manuelle ID behalten

        city_code = {
            "sangerhausen": "sg",
            "lutherstadt eisleben": "el",
            "eisleben": "el",
            "hettstedt": "ht",
            "suedharz": "sh",
            "südharz": "sh",
            "allstedt": "al",
            "mansfeld": "mf",
            "gerbstedt": "gb",
        }

        city = entry.get("city", "").lower()
        code = "msh"  # Default
        for city_name, city_abbr in city_code.items():
            if city_name in city:
                code = city_abbr
                break

        cat_prefix = {
            "doctor": "arzt",
            "pharmacy": "apo",
            "hospital": "kh",
            "physiotherapy": "physio",
            "care_service": "pflege",
            "medical_supply": "sani",
            "fitness": "fit",
        }

        prefix = cat_prefix.get(category, category[:3])
        return f"{prefix}_{code}_{str(index).zfill(3)}"

    def clean_entry(self, entry: Dict, category: str, index: int) -> Dict:
        """Bereinigt und standardisiert einen Eintrag"""
        cleaned = {
            "id": self.generate_id(entry, category, index),
            "type": category,
            "name": entry.get("name", ""),
            "latitude": entry.get("latitude"),
            "longitude": entry.get("longitude"),
        }

        # Optionale Felder
        optional_fields = [
            "street", "postalCode", "city",
            "phone", "phoneFormatted", "website",
            "openingHours", "description",
            "isBarrierFree", "hasParking",
            "languages", "acceptsPublicInsurance", "acceptsPrivateInsurance",
            "hasEmergency", "beds", "departments",
            "specialization", "hasHouseCalls",
            "verified", "source"
        ]

        for field in optional_fields:
            if entry.get(field):
                cleaned[field] = entry[field]

        return cleaned

    def merge_category(self, category: str) -> List[Dict]:
        """Merged eine Kategorie komplett"""
        print(f"\n[MERGE] Kategorie: {category}")

        manual = self.load_manual_data(category)
        osm = self.load_osm_data(category)

        merged = self.merge_entries(manual, osm)

        # Bereinigen und IDs vergeben
        cleaned = []
        for i, entry in enumerate(merged, 1):
            cleaned.append(self.clean_entry(entry, category, i))

        # Nach Prioritaet und Name sortieren
        cleaned.sort(key=lambda x: (x.get("_priority", 2), x.get("name", "")))

        # Prioritaet-Feld entfernen
        for entry in cleaned:
            entry.pop("_priority", None)

        print(f"   [RESULT] {len(cleaned)} Eintraege nach Merge")
        self.stats["merged_total"] += len(cleaned)

        return cleaned

    def save_category(self, category: str, data: List[Dict], source_info: str):
        """Speichert gemergte Daten"""
        filename_map = {
            "doctor": "doctors.json",
            "pharmacy": "pharmacies.json",
            "hospital": "hospitals.json",
            "physiotherapy": "physiotherapy.json",
            "care_service": "care_services.json",
            "medical_supply": "medical_supply.json",
            "fitness": "fitness.json",
        }

        filepath = self.OUTPUT_DIR / filename_map.get(category, f"{category}.json")

        output = {
            "meta": {
                "source": source_info,
                "created_at": time.strftime("%Y-%m-%d"),
                "version": "3.0",
                "region": "Mansfeld-Suedharz",
                "note": "Automatisch gemerged aus OSM + manuellen Daten",
                "total_count": len(data),
                "verified_count": len([d for d in data if d.get("verified")]),
            },
            "data": data
        }

        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(output, f, ensure_ascii=False, indent=2)

        print(f"   [SAVED] {filepath.name}")

    def run(self, categories: List[str] = None):
        """Fuehrt Merge fuer alle Kategorien durch"""
        print("\n" + "="*60)
        print("[HEALTH MERGE] Starte Zusammenfuehrung")
        print("="*60)

        if categories is None:
            categories = ["doctor", "pharmacy", "hospital", "physiotherapy", "care_service", "medical_supply"]

        for category in categories:
            merged = self.merge_category(category)
            if merged:
                self.save_category(category, merged, "openstreetmap, arzt-auskunft.de, manual")

        # Statistik
        print("\n" + "="*60)
        print("[STATS] Zusammenfassung")
        print("="*60)
        print(f"   OSM Eintraege:        {self.stats['osm_total']}")
        print(f"   Manuelle Eintraege:   {self.stats['manual_total']}")
        print(f"   Duplikate entfernt:   {self.stats['duplicates_removed']}")
        print(f"   Gesamt nach Merge:    {self.stats['merged_total']}")

    def find_gaps(self) -> Dict[str, List[str]]:
        """Findet Luecken in der Abdeckung (Orte ohne Eintraege)"""
        print("\n" + "="*60)
        print("[GAP ANALYSIS] Suche nach Luecken")
        print("="*60)

        # MSH Orte die abgedeckt sein sollten
        expected_cities = [
            "Sangerhausen", "Lutherstadt Eisleben", "Hettstedt",
            "Allstedt", "Gerbstedt", "Mansfeld",
            "Roßla", "Südharz", "Stolberg",
            "Kelbra", "Berga", "Bennungen",
            "Wimmelburg", "Helbra", "Klostermansfeld"
        ]

        # Lade alle gemergten Daten
        all_cities = set()
        for filepath in self.OUTPUT_DIR.glob("*.json"):
            if filepath.name.startswith("_"):
                continue
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    for entry in data.get("data", []):
                        city = entry.get("city", "").split()[0] if entry.get("city") else None
                        if city:
                            all_cities.add(city)
            except:
                continue

        # Finde fehlende
        gaps = {
            "missing_cities": [],
            "low_coverage_cities": []
        }

        for city in expected_cities:
            found = any(city.lower() in c.lower() for c in all_cities)
            if not found:
                gaps["missing_cities"].append(city)
                print(f"   [GAP] Keine Eintraege fuer: {city}")

        if gaps["missing_cities"]:
            print(f"\n   [WARNUNG] {len(gaps['missing_cities'])} Orte ohne Abdeckung!")
        else:
            print("   [OK] Alle erwarteten Orte haben Eintraege")

        return gaps


def main():
    parser = argparse.ArgumentParser(description="Health Data Merge Tool")
    parser.add_argument("--category", "-c", help="Nur bestimmte Kategorie mergen")
    parser.add_argument("--gaps", action="store_true", help="Nur Gap-Analyse durchfuehren")
    args = parser.parse_args()

    merger = HealthMerger()

    if args.gaps:
        merger.find_gaps()
    elif args.category:
        merged = merger.merge_category(args.category)
        if merged:
            merger.save_category(args.category, merged, "openstreetmap, arzt-auskunft.de, manual")
    else:
        merger.run()
        merger.find_gaps()


if __name__ == "__main__":
    main()
