#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MSH DeepScan - Hauptprogramm
Datensammlung und -analyse für die Region Mansfeld-Südharz
"""

import json
import sys
import io
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any

# Setze UTF-8 für stdout
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')


class DeepScanEngine:
    """Haupt-Engine für MSH DeepScan"""

    def __init__(self):
        self.base_path = Path(__file__).parent
        self.output_path = self.base_path / "output"
        self.seed_file = self.base_path / "msh_data_seed.json"

        # Ausgabe-Ordner sicherstellen
        (self.output_path / "raw").mkdir(parents=True, exist_ok=True)
        (self.output_path / "enriched").mkdir(parents=True, exist_ok=True)
        (self.output_path / "merged").mkdir(parents=True, exist_ok=True)
        (self.output_path / "analytics").mkdir(parents=True, exist_ok=True)

    def load_seed_data(self) -> Dict[str, Any]:
        """Lädt Seed-Daten"""
        print(f"📦 Lade Seed-Daten aus {self.seed_file}...")

        if not self.seed_file.exists():
            raise FileNotFoundError(f"Seed-Datei nicht gefunden: {self.seed_file}")

        with open(self.seed_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        location_count = len(data.get('data', []))
        print(f"✅ {location_count} Orte geladen")

        return data

    def export_geojson(self, data: Dict[str, Any], output_file: Path) -> None:
        """Exportiert Daten als GeoJSON"""
        print(f"🗺️  Erstelle GeoJSON...")

        features = []
        for item in data.get('data', []):
            if not item.get('latitude') or not item.get('longitude'):
                continue

            feature = {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [item['longitude'], item['latitude']]
                },
                "properties": {
                    key: value for key, value in item.items()
                    if key not in ['latitude', 'longitude']
                }
            }
            features.append(feature)

        geojson = {
            "type": "FeatureCollection",
            "features": features,
            "meta": data.get('meta', {})
        }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(geojson, f, ensure_ascii=False, indent=2)

        print(f"✅ GeoJSON gespeichert: {output_file}")

    def export_firestore_format(self, data: Dict[str, Any], output_file: Path) -> None:
        """Exportiert Daten im Firestore-kompatiblen Format"""
        print(f"🔥 Erstelle Firestore-Format...")

        firestore_data = {
            "locations": {},
            "meta": {
                **data.get('meta', {}),
                "exported_at": datetime.now().isoformat(),
                "format": "firestore"
            }
        }

        for item in data.get('data', []):
            location_id = item.get('id')
            if not location_id:
                continue

            # Firestore-Dokument erstellen
            firestore_data["locations"][location_id] = {
                "name": item.get('name', ''),
                "displayName": item.get('displayName', item.get('name', '')),
                "category": item.get('category', 'other'),
                "coordinates": {
                    "latitude": item.get('latitude'),
                    "longitude": item.get('longitude')
                },
                "city": item.get('city', ''),
                "address": item.get('address', ''),
                "description": item.get('description', ''),
                "ageRecommendation": item.get('ageRecommendation', ''),
                "openingHours": item.get('openingHours', ''),
                "admissionFee": item.get('admissionFee', ''),
                "website": item.get('website', ''),
                "tags": item.get('tags', []),
                "accessibility": item.get('accessibility', ''),
                "parking": item.get('parking', False),
                "createdAt": datetime.now().isoformat(),
                "source": "seed"
            }

        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(firestore_data, f, ensure_ascii=False, indent=2)

        print(f"✅ Firestore-Format gespeichert: {output_file}")

    def generate_analytics(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Generiert Basis-Statistiken"""
        print(f"📊 Generiere Analysen...")

        locations = data.get('data', [])

        # Kategorie-Verteilung
        category_counts = {}
        city_counts = {}

        for loc in locations:
            # Kategorien
            cat = loc.get('category', 'other')
            category_counts[cat] = category_counts.get(cat, 0) + 1

            # Städte
            city = loc.get('city', 'Unbekannt')
            city_counts[city] = city_counts.get(city, 0) + 1

        analytics = {
            "overview": {
                "total_locations": len(locations),
                "total_cities": len(city_counts),
                "total_categories": len(category_counts)
            },
            "by_category": category_counts,
            "by_city": city_counts,
            "top_cities": sorted(
                city_counts.items(),
                key=lambda x: x[1],
                reverse=True
            )[:10],
            "top_categories": sorted(
                category_counts.items(),
                key=lambda x: x[1],
                reverse=True
            )[:10]
        }

        return analytics

    def save_analytics(self, analytics: Dict[str, Any], output_file: Path) -> None:
        """Speichert Analytics"""
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(analytics, f, ensure_ascii=False, indent=2)

        print(f"✅ Analytics gespeichert: {output_file}")

    def print_summary(self, analytics: Dict[str, Any]) -> None:
        """Gibt Zusammenfassung aus"""
        print("\n" + "="*60)
        print("📊 MSH DeepScan - Zusammenfassung")
        print("="*60)

        overview = analytics['overview']
        print(f"\n📍 Gesamt: {overview['total_locations']} Orte")
        print(f"🏙️  Städte: {overview['total_cities']}")
        print(f"📁 Kategorien: {overview['total_categories']}")

        print("\n🏆 Top-5 Städte:")
        for city, count in analytics['top_cities'][:5]:
            print(f"   • {city}: {count} Orte")

        print("\n🏆 Top-5 Kategorien:")
        for cat, count in analytics['top_categories'][:5]:
            print(f"   • {cat}: {count} Orte")

        print("\n" + "="*60 + "\n")

    def run_seed_export(self) -> None:
        """Führt Seed-Daten Export aus"""
        print("\n🚀 MSH DeepScan - Seed-Daten Export\n")

        # Seed-Daten laden
        data = self.load_seed_data()

        # Timestamp für Dateinamen
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        # JSON Export
        json_file = self.output_path / "merged" / f"msh_complete_{timestamp}.json"
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"✅ JSON gespeichert: {json_file}")

        # GeoJSON Export
        geojson_file = self.output_path / "merged" / f"msh_complete_{timestamp}.geojson"
        self.export_geojson(data, geojson_file)

        # Firestore Format
        firestore_file = self.output_path / "merged" / f"msh_firestore_{timestamp}.json"
        self.export_firestore_format(data, firestore_file)

        # Analytics
        analytics = self.generate_analytics(data)
        analytics_file = self.output_path / "analytics" / f"report_{timestamp}.json"
        self.save_analytics(analytics, analytics_file)

        # Markdown Report
        self.generate_markdown_report(analytics, timestamp)

        # Zusammenfassung
        self.print_summary(analytics)

        print(f"✅ Alle Dateien erfolgreich erstellt!")
        print(f"📁 Ausgabe-Ordner: {self.output_path}")

    def generate_markdown_report(self, analytics: Dict[str, Any], timestamp: str) -> None:
        """Generiert Markdown-Report"""
        md_file = self.output_path / "analytics" / f"report_{timestamp}.md"

        overview = analytics['overview']

        md_content = f"""# MSH DeepScan - Analyse-Report
**Erstellt:** {datetime.now().strftime("%d.%m.%Y %H:%M Uhr")}

## Übersicht

- **Gesamt-Orte:** {overview['total_locations']}
- **Städte:** {overview['total_cities']}
- **Kategorien:** {overview['total_categories']}

## Top-10 Städte

| Rang | Stadt | Anzahl Orte |
|------|-------|-------------|
"""

        for i, (city, count) in enumerate(analytics['top_cities'], 1):
            md_content += f"| {i} | {city} | {count} |\n"

        md_content += f"""
## Top-10 Kategorien

| Rang | Kategorie | Anzahl Orte |
|------|-----------|-------------|
"""

        for i, (cat, count) in enumerate(analytics['top_categories'], 1):
            md_content += f"| {i} | {cat} | {count} |\n"

        md_content += """
## Kategorie-Verteilung (Alle)

"""

        for cat, count in sorted(analytics['by_category'].items()):
            md_content += f"- **{cat}:** {count} Orte\n"

        with open(md_file, 'w', encoding='utf-8') as f:
            f.write(md_content)

        print(f"📝 Markdown-Report: {md_file}")


def main():
    """Hauptprogramm"""

    # Kommandozeilen-Argument prüfen
    if len(sys.argv) > 1:
        command = sys.argv[1]
    else:
        command = "--seed"  # Default

    engine = DeepScanEngine()

    if command == "--seed":
        engine.run_seed_export()
    else:
        print(f"❌ Unbekannter Befehl: {command}")
        print("\nVerfügbare Befehle:")
        print("  --seed    Exportiert Seed-Daten")
        sys.exit(1)


if __name__ == "__main__":
    main()
