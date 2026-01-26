#!/usr/bin/env python3
"""
MSH DeepScan - Engagement Scanner
Findet Tierheime, Vereine, soziale Einrichtungen die Hilfe suchen
"""

import asyncio
import aiohttp
import json
from datetime import datetime, timedelta
from typing import List, Dict, Optional
from pathlib import Path
import logging

logger = logging.getLogger('EngagementScanner')

MSH_BOUNDS = {
    'north': 51.75, 'south': 51.30,
    'east': 11.70, 'west': 10.90,
}

ENGAGEMENT_SOURCES = {
    'animal_shelter': {
        'osm_tags': ['amenity=animal_shelter', 'amenity=animal_boarding'],
        'search_terms': ['Tierheim', 'Tierschutz', 'Tierrettung'],
        'keywords_help': ['Pflegestelle', 'Paten', 'Gassigeher', 'Spenden'],
    },
    'fire_brigade': {
        'osm_tags': ['amenity=fire_station'],
        'search_terms': ['Freiwillige Feuerwehr', 'FFW'],
        'keywords_help': ['Mitglieder gesucht', 'Nachwuchs'],
    },
    'social_service': {
        'osm_tags': ['social_facility=*', 'amenity=social_centre'],
        'search_terms': ['Tafel', 'Sozialkaufhaus', 'Seniorenheim'],
        'keywords_help': ['Ehrenamtliche', 'Helfer', 'Besuchsdienst'],
    },
    'clubs': {
        'osm_tags': ['club=*'],
        'search_terms': ['Sportverein', 'Musikverein', 'Förderverein'],
        'keywords_help': ['Trainer gesucht', 'Übungsleiter'],
    },
    'blood_donation': {
        'osm_tags': ['healthcare=blood_donation'],
        'search_terms': ['Blutspende', 'DRK Blutspendedienst'],
    },
    'environment': {
        'osm_tags': ['office=ngo'],
        'search_terms': ['NABU', 'BUND', 'Naturschutzbund'],
        'keywords_help': ['Biotoppflege', 'Arbeitseinsatz'],
    },
}


class EngagementScanner:
    """Scanner für Engagement-Möglichkeiten in MSH"""

    def __init__(self, output_dir: str = 'data/engagement'):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.session = None
        self.results = {'places': [], 'statistics': {}}

    async def __aenter__(self):
        self.session = aiohttp.ClientSession(
            timeout=aiohttp.ClientTimeout(total=30),
            headers={'User-Agent': 'MSH-Map-EngagementScanner/1.0'}
        )
        return self

    async def __aexit__(self, *args):
        if self.session:
            await self.session.close()

    async def scan(self):
        """Hauptscan-Funktion"""
        logger.info("🤝 Engagement Scanner gestartet")

        # OSM scannen
        for category, config in ENGAGEMENT_SOURCES.items():
            for tag in config.get('osm_tags', []):
                places = await self._query_overpass(tag, category)
                self.results['places'].extend(places)
                await asyncio.sleep(1)

        # Statistiken
        self._calculate_statistics()

        # Speichern
        await self._save_results()

        logger.info(f"✓ {len(self.results['places'])} Orte gefunden")

    async def _query_overpass(self, tag: str, category: str) -> List[Dict]:
        query = f"""[out:json][timeout:60];
        (node[{tag}]({MSH_BOUNDS['south']},{MSH_BOUNDS['west']},{MSH_BOUNDS['north']},{MSH_BOUNDS['east']});
        way[{tag}]({MSH_BOUNDS['south']},{MSH_BOUNDS['west']},{MSH_BOUNDS['north']},{MSH_BOUNDS['east']}););
        out center;"""

        try:
            async with self.session.post(
                'https://overpass-api.de/api/interpreter',
                data={'data': query}
            ) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    return self._parse_elements(data.get('elements', []), category)
        except Exception as e:
            logger.error(f"Error: {e}")
        return []

    def _parse_elements(self, elements: List[Dict], category: str) -> List[Dict]:
        places = []
        for el in elements:
            lat = el.get('lat') or el.get('center', {}).get('lat')
            lon = el.get('lon') or el.get('center', {}).get('lon')
            if not lat or not lon:
                continue

            tags = el.get('tags', {})
            places.append({
                'id': f"osm_{el['type']}_{el['id']}",
                'name': tags.get('name', f"Unbenannt ({category})"),
                'type': category,
                'latitude': lat,
                'longitude': lon,
                'city': tags.get('addr:city'),
                'phone': tags.get('phone'),
                'website': tags.get('website'),
                'currentNeeds': [],
                'adoptableAnimals': [],
                'isVerified': False,
            })
        return places

    def _calculate_statistics(self):
        by_type = {}
        for p in self.results['places']:
            t = p['type']
            by_type[t] = by_type.get(t, 0) + 1
        self.results['statistics'] = {
            'total': len(self.results['places']),
            'by_type': by_type,
            'timestamp': datetime.now().isoformat(),
        }

    async def _save_results(self):
        with open(self.output_dir / 'places.json', 'w', encoding='utf-8') as f:
            json.dump({'places': self.results['places']}, f, ensure_ascii=False, indent=2)


async def run_engagement_scan():
    async with EngagementScanner() as scanner:
        await scanner.scan()
        return scanner.results

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    asyncio.run(run_engagement_scan())
