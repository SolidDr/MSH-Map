# MSH Map - Data Scraper
# Fokus: Familienaktivitäten & Kinderfreundliche Orte in Mansfeld-Südharz

import requests
from bs4 import BeautifulSoup
import json
import time
import re
from datetime import datetime
from urllib.parse import urlparse, urljoin
from urllib.robotparser import RobotFileParser
from dataclasses import dataclass, asdict
from typing import Optional, List
import hashlib

# ═══════════════════════════════════════════════════════════════════════════════
# KONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

USER_AGENT = 'KOLAN_Systems_MSH_Map_Bot/1.0 (contact@kolan-systems.de; Regionalportal MSH)'
HEADERS = {'User-Agent': USER_AGENT}

# Politeness: Sekunden zwischen Requests (anpassen je nach Server)
REQUEST_DELAY = 1.5

# MSH Bounding Box für Geo-Validierung
MSH_BOUNDS = {
    'lat_min': 51.25,
    'lat_max': 51.75,
    'lng_min': 10.75,
    'lng_max': 11.85
}

# ═══════════════════════════════════════════════════════════════════════════════
# DATENMODELLE
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class ScrapedLocation:
    """Basis-Datenmodell für alle gescrapten Orte."""
    id: str                          # Generierte eindeutige ID
    name: str                        # Name des Ortes
    category: str                    # Kategorie (playground, museum, nature, etc.)
    description: Optional[str]       # Beschreibung
    address: Optional[str]           # Adresse
    latitude: Optional[float]        # GPS Breite
    longitude: Optional[float]       # GPS Länge
    city: Optional[str]              # Stadt/Gemeinde
    
    # Familien-spezifisch
    age_range: Optional[str]         # z.B. "0-6", "6-12", "alle"
    is_free: Optional[bool]          # Kostenlos?
    is_outdoor: Optional[bool]       # Draußen?
    is_indoor: Optional[bool]        # Drinnen?
    is_barrier_free: Optional[bool]  # Barrierefrei?
    
    # Meta
    source_url: str                  # Woher stammt die Info
    scraped_at: str                  # Wann gescrapt
    tags: List[str]                  # Zusätzliche Tags
    
    def to_dict(self):
        return asdict(self)
    
    def is_in_msh_region(self) -> bool:
        """Prüft ob Koordinaten in MSH liegen."""
        if self.latitude is None or self.longitude is None:
            return True  # Ohne Koordinaten erstmal akzeptieren
        return (MSH_BOUNDS['lat_min'] <= self.latitude <= MSH_BOUNDS['lat_max'] and
                MSH_BOUNDS['lng_min'] <= self.longitude <= MSH_BOUNDS['lng_max'])


@dataclass
class FamilyActivity(ScrapedLocation):
    """Erweitert für Familienaktivitäten."""
    activity_type: Optional[str]     # spielplatz, museum, tierpark, etc.
    opening_hours: Optional[str]     # Öffnungszeiten
    price_info: Optional[str]        # Preisinformationen
    contact_phone: Optional[str]
    contact_email: Optional[str]
    website: Optional[str]
    facilities: List[str]            # WC, Parkplatz, Wickelraum, etc.


# ═══════════════════════════════════════════════════════════════════════════════
# BASIS-SCRAPER KLASSE
# ═══════════════════════════════════════════════════════════════════════════════

class MSHScraperBase:
    """
    Basis-Klasse mit automatischer Robots.txt-Prüfung und Rate-Limiting.
    """
    
    def __init__(self):
        self.robots_cache = {}
        self.request_count = 0
        self.start_time = datetime.now()
    
    def is_allowed_by_robots(self, url: str) -> bool:
        """Prüft robots.txt der Domain."""
        parsed_url = urlparse(url)
        domain = parsed_url.netloc
        scheme = parsed_url.scheme
        robots_url = f"{scheme}://{domain}/robots.txt"
        
        if domain not in self.robots_cache:
            rp = RobotFileParser()
            try:
                print(f"  [ROBOTS] Prüfe: {robots_url}")
                rp.set_url(robots_url)
                rp.read()
                self.robots_cache[domain] = rp
            except Exception as e:
                print(f"  [WARN] robots.txt nicht lesbar ({e}) - erlaube Zugriff")
                return True
        
        return self.robots_cache[domain].can_fetch(USER_AGENT, url)
    
    def fetch_page(self, url: str) -> Optional[BeautifulSoup]:
        """Ruft Seite ab mit Compliance-Check und Rate-Limiting."""
        
        # 1. Robots.txt prüfen
        if not self.is_allowed_by_robots(url):
            print(f"  [BLOCKED] {url} - robots.txt verbietet Zugriff")
            return None
        
        # 2. Rate-Limiting
        time.sleep(REQUEST_DELAY)
        
        # 3. Request
        try:
            self.request_count += 1
            response = requests.get(url, headers=HEADERS, timeout=15)
            response.raise_for_status()
            print(f"  [OK] {url}")
            return BeautifulSoup(response.text, 'html.parser')
        except requests.exceptions.RequestException as e:
            print(f"  [ERROR] {url}: {e}")
            return None
    
    def generate_id(self, name: str, category: str) -> str:
        """Generiert eine eindeutige ID aus Name und Kategorie."""
        raw = f"{name.lower()}_{category}".encode('utf-8')
        return hashlib.md5(raw).hexdigest()[:12]
    
    def save_data(self, data: List[dict], filename: str):
        """Speichert Daten als JSON."""
        output = {
            'meta': {
                'scraped_at': datetime.now().isoformat(),
                'request_count': self.request_count,
                'duration_seconds': (datetime.now() - self.start_time).seconds,
                'item_count': len(data)
            },
            'data': data
        }
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(output, f, ensure_ascii=False, indent=2)
        print(f"\n[SAVED] {len(data)} Einträge -> {filename}")
    
    def extract_coordinates_from_text(self, text: str) -> tuple:
        """Versucht Koordinaten aus Text zu extrahieren."""
        # Pattern für verschiedene Formate
        patterns = [
            r'(\d{1,2}\.\d+)[,\s]+(\d{1,2}\.\d+)',  # 51.466, 11.300
            r'lat[:\s]*(\d{1,2}\.\d+).*?(?:lon|lng)[:\s]*(\d{1,2}\.\d+)',  # lat: 51.4 lon: 11.3
        ]
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                lat, lng = float(match.group(1)), float(match.group(2))
                if 50 < lat < 53 and 10 < lng < 13:  # Grobe Prüfung für Deutschland
                    return (lat, lng)
        return (None, None)


# ═══════════════════════════════════════════════════════════════════════════════
# FAMILIEN-AKTIVITÄTEN SCRAPER
# ═══════════════════════════════════════════════════════════════════════════════

class FamilyActivityScraper(MSHScraperBase):
    """
    Scraper für familienfreundliche Aktivitäten in MSH.
    Fokus: Spielplätze, Museen, Tierparks, Naturerlebnisse, Indoor-Spielplätze
    """
    
    # Kategorien mit Keywords für Erkennung
    CATEGORIES = {
        'playground': ['spielplatz', 'spielplätze', 'kinderspielplatz'],
        'museum': ['museum', 'ausstellung', 'bergbau', 'heimat'],
        'nature': ['wanderweg', 'naturlehrpfad', 'wald', 'see', 'park'],
        'zoo': ['tierpark', 'zoo', 'wildgehege', 'streichelzoo'],
        'indoor': ['indoorspielplatz', 'spielhalle', 'kletterhalle'],
        'pool': ['schwimmbad', 'freibad', 'hallenbad', 'badesee'],
        'castle': ['burg', 'schloss', 'ruine'],
        'farm': ['bauernhof', 'reiterhof', 'erlebnishof'],
        'adventure': ['kletterpark', 'hochseilgarten', 'sommerrodelbahn'],
    }
    
    # Bekannte Quellen für MSH
    SOURCES = [
        # Tourismus-Seiten
        {
            'name': 'Harz Tourismus',
            'base_url': 'https://www.harzinfo.de',
            'paths': ['/familienurlaub', '/ausflugsziele'],
            'enabled': True
        },
        {
            'name': 'Sangerhausen Tourismus',
            'base_url': 'https://www.sangerhausen-tourist.de',
            'paths': ['/sehenswuerdigkeiten', '/freizeit'],
            'enabled': True
        },
        {
            'name': 'MSH Landkreis',
            'base_url': 'https://www.mansfeldsuedharz.de',
            'paths': ['/tourismus', '/freizeit'],
            'enabled': True
        },
        # Spielplatz-Verzeichnisse
        {
            'name': 'Spielplatztreff',
            'base_url': 'https://www.spielplatztreff.de',
            'paths': ['/spielplaetze/sangerhausen', '/spielplaetze/eisleben', '/spielplaetze/hettstedt'],
            'enabled': True
        },
    ]
    
    def __init__(self):
        super().__init__()
        self.results: List[FamilyActivity] = []
    
    def detect_category(self, text: str) -> str:
        """Erkennt Kategorie anhand von Keywords."""
        text_lower = text.lower()
        for category, keywords in self.CATEGORIES.items():
            if any(kw in text_lower for kw in keywords):
                return category
        return 'other'
    
    def detect_age_range(self, text: str) -> Optional[str]:
        """Versucht Altersangaben zu erkennen."""
        text_lower = text.lower()
        if any(w in text_lower for w in ['kleinkind', 'baby', '0-3', 'unter 3']):
            return '0-3'
        if any(w in text_lower for w in ['kindergarten', '3-6', 'vorschul']):
            return '3-6'
        if any(w in text_lower for w in ['grundschul', '6-10', '6-12']):
            return '6-12'
        if any(w in text_lower for w in ['jugend', 'teenager', '12+']):
            return '12+'
        if any(w in text_lower for w in ['alle alter', 'familien', 'jedes alter']):
            return 'alle'
        return None
    
    def detect_facilities(self, text: str) -> List[str]:
        """Erkennt vorhandene Einrichtungen."""
        facilities = []
        mappings = {
            'wc': ['wc', 'toilette', 'sanitär'],
            'parking': ['parkplatz', 'parken', 'stellplatz'],
            'changing_table': ['wickel', 'wickeltisch'],
            'cafe': ['café', 'cafe', 'kiosk', 'imbiss'],
            'barrier_free': ['barrierefrei', 'rollstuhl', 'behindertengerecht'],
            'playground': ['spielplatz', 'spielgeräte'],
            'picnic': ['picknick', 'grillplatz', 'rastplatz'],
        }
        text_lower = text.lower()
        for facility, keywords in mappings.items():
            if any(kw in text_lower for kw in keywords):
                facilities.append(facility)
        return facilities
    
    def scrape_source(self, source: dict) -> List[FamilyActivity]:
        """Scrapt eine einzelne Quelle."""
        if not source.get('enabled', False):
            print(f"\n[SKIP] {source['name']} (deaktiviert)")
            return []
        
        print(f"\n{'='*60}")
        print(f"[SCRAPE] {source['name']}")
        print(f"{'='*60}")
        
        activities = []
        
        for path in source['paths']:
            url = urljoin(source['base_url'], path)
            soup = self.fetch_page(url)
            
            if not soup:
                continue
            
            # Generische Extraktion - muss pro Quelle angepasst werden
            # Dies ist ein Template, das verfeinert werden muss
            
            # Versuche typische Strukturen zu finden
            for article in soup.find_all(['article', 'div'], class_=re.compile(r'(item|card|entry|listing)')):
                try:
                    # Name extrahieren
                    title_elem = article.find(['h1', 'h2', 'h3', 'h4', 'a'])
                    if not title_elem:
                        continue
                    name = title_elem.get_text(strip=True)
                    
                    if len(name) < 3 or len(name) > 200:
                        continue
                    
                    # Beschreibung
                    desc_elem = article.find(['p', 'div'], class_=re.compile(r'(desc|text|content|excerpt)'))
                    description = desc_elem.get_text(strip=True) if desc_elem else None
                    
                    # Kategorie erkennen
                    full_text = article.get_text()
                    category = self.detect_category(full_text)
                    
                    # Link zur Detailseite
                    link = article.find('a', href=True)
                    detail_url = urljoin(url, link['href']) if link else url
                    
                    # Koordinaten versuchen zu extrahieren
                    lat, lng = self.extract_coordinates_from_text(full_text)
                    
                    activity = FamilyActivity(
                        id=self.generate_id(name, category),
                        name=name,
                        category=category,
                        description=description[:500] if description else None,
                        address=None,  # Müsste aus Detailseite extrahiert werden
                        latitude=lat,
                        longitude=lng,
                        city=None,
                        age_range=self.detect_age_range(full_text),
                        is_free=any(w in full_text.lower() for w in ['kostenlos', 'gratis', 'eintritt frei']),
                        is_outdoor='outdoor' in category or category in ['playground', 'nature', 'zoo'],
                        is_indoor='indoor' in category or category in ['museum'],
                        is_barrier_free='barrierefrei' in full_text.lower(),
                        source_url=detail_url,
                        scraped_at=datetime.now().isoformat(),
                        tags=[],
                        activity_type=category,
                        opening_hours=None,
                        price_info=None,
                        contact_phone=None,
                        contact_email=None,
                        website=detail_url if detail_url != url else None,
                        facilities=self.detect_facilities(full_text)
                    )
                    
                    # Nur hinzufügen wenn in MSH Region (oder ohne Koordinaten)
                    if activity.is_in_msh_region():
                        activities.append(activity)
                        print(f"    + {name} [{category}]")
                    
                except Exception as e:
                    print(f"    [WARN] Parsing-Fehler: {e}")
                    continue
        
        return activities
    
    def run(self, output_file: str = 'msh_family_activities.json'):
        """Führt das Scraping aller Quellen durch."""
        print("\n" + "="*60)
        print("MSH FAMILY ACTIVITY SCRAPER")
        print("="*60)
        print(f"Quellen: {len([s for s in self.SOURCES if s.get('enabled')])}")
        print(f"User-Agent: {USER_AGENT}")
        print(f"Rate-Limit: {REQUEST_DELAY}s")
        
        all_activities = []
        
        for source in self.SOURCES:
            activities = self.scrape_source(source)
            all_activities.extend(activities)
        
        # Duplikate entfernen (nach ID)
        seen_ids = set()
        unique_activities = []
        for act in all_activities:
            if act.id not in seen_ids:
                seen_ids.add(act.id)
                unique_activities.append(act)
        
        # Speichern
        self.save_data([a.to_dict() for a in unique_activities], output_file)
        
        # Statistik
        print("\n" + "="*60)
        print("STATISTIK")
        print("="*60)
        categories = {}
        for act in unique_activities:
            categories[act.category] = categories.get(act.category, 0) + 1
        for cat, count in sorted(categories.items(), key=lambda x: -x[1]):
            print(f"  {cat}: {count}")
        
        return unique_activities


# ═══════════════════════════════════════════════════════════════════════════════
# MANUELLE DATEN (Bekannte Orte die sicher existieren)
# ═══════════════════════════════════════════════════════════════════════════════

KNOWN_LOCATIONS = [
    {
        "name": "Rosarium Sangerhausen",
        "category": "nature",
        "description": "Europa-Rosarium - größte Rosensammlung der Welt mit über 8.600 Sorten",
        "address": "Steinberger Weg 3, 06526 Sangerhausen",
        "latitude": 51.4725,
        "longitude": 11.2983,
        "city": "Sangerhausen",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["park", "blumen", "spaziergang", "familienfreundlich"],
        "activity_type": "park",
        "website": "https://www.europa-rosarium.de"
    },
    {
        "name": "Mammuthöhle Sangerhausen",
        "category": "museum",
        "description": "Schaubergwerk mit Mammutfunden und Bergbaugeschichte",
        "address": "Gayersche Straße, 06526 Sangerhausen",
        "latitude": 51.4789,
        "longitude": 11.3012,
        "city": "Sangerhausen",
        "age_range": "6-12",
        "is_free": False,
        "is_indoor": True,
        "tags": ["bergbau", "höhle", "museum", "abenteuer"],
        "activity_type": "museum"
    },
    {
        "name": "Lutherstadt Eisleben - Luthers Geburtshaus",
        "category": "museum",
        "description": "UNESCO-Weltkulturerbe - Geburtshaus Martin Luthers",
        "address": "Lutherstraße 15, 06295 Lutherstadt Eisleben",
        "latitude": 51.5275,
        "longitude": 11.5481,
        "city": "Lutherstadt Eisleben",
        "age_range": "alle",
        "is_free": False,
        "is_indoor": True,
        "tags": ["unesco", "geschichte", "luther", "kultur"],
        "activity_type": "museum",
        "website": "https://www.martinluther.de"
    },
    {
        "name": "Süßer See",
        "category": "nature",
        "description": "Natürlicher See mit Badestellen, ideal für Familien",
        "address": "Seeburg, 06317 Seegebiet Mansfelder Land",
        "latitude": 51.4833,
        "longitude": 11.6167,
        "city": "Seeburg",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["baden", "see", "natur", "sommer"],
        "activity_type": "pool"
    },
    {
        "name": "Wippertalsperre",
        "category": "nature",
        "description": "Talsperre mit Rundwanderweg, Spielplatz und Badestelle",
        "address": "06536 Südharz",
        "latitude": 51.5167,
        "longitude": 11.0833,
        "city": "Südharz",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["wandern", "baden", "spielplatz", "natur"],
        "activity_type": "nature"
    },
    {
        "name": "Schloss Mansfeld",
        "category": "castle",
        "description": "Historische Burganlage mit Jugendbildungsstätte",
        "address": "Am Schloss 1, 06343 Mansfeld",
        "latitude": 51.5972,
        "longitude": 11.4528,
        "city": "Mansfeld",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["burg", "geschichte", "aussicht"],
        "activity_type": "castle",
        "website": "https://www.schloss-mansfeld.de"
    },
]


def create_seed_data(output_file: str = 'msh_seed_data.json'):
    """Erstellt initiale Datenbasis aus bekannten Orten."""
    print("\n" + "="*60)
    print("ERSTELLE SEED DATA")
    print("="*60)
    
    seed_data = []
    for loc in KNOWN_LOCATIONS:
        entry = {
            'id': hashlib.md5(loc['name'].lower().encode()).hexdigest()[:12],
            'scraped_at': datetime.now().isoformat(),
            'source_url': loc.get('website', 'manual_entry'),
            'is_indoor': loc.get('is_indoor', False),
            'is_barrier_free': loc.get('is_barrier_free', False),
            'opening_hours': None,
            'price_info': None,
            'contact_phone': None,
            'contact_email': None,
            'facilities': [],
            **loc
        }
        seed_data.append(entry)
        print(f"  + {loc['name']} [{loc['category']}]")
    
    output = {
        'meta': {
            'created_at': datetime.now().isoformat(),
            'type': 'seed_data',
            'item_count': len(seed_data)
        },
        'data': seed_data
    }
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"\n[SAVED] {len(seed_data)} Einträge -> {output_file}")


# ═══════════════════════════════════════════════════════════════════════════════
# HAUPTPROGRAMM
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='MSH Map Data Scraper')
    parser.add_argument('--seed', action='store_true', help='Nur Seed-Daten erstellen')
    parser.add_argument('--scrape', action='store_true', help='Web-Scraping durchführen')
    parser.add_argument('--all', action='store_true', help='Beides')
    parser.add_argument('--output', default='msh_data', help='Output-Prefix')
    
    args = parser.parse_args()
    
    if args.seed or args.all or (not args.seed and not args.scrape):
        create_seed_data(f'{args.output}_seed.json')
    
    if args.scrape or args.all:
        scraper = FamilyActivityScraper()
        scraper.run(f'{args.output}_scraped.json')
    
    print("\n[DONE] Scraping abgeschlossen!")