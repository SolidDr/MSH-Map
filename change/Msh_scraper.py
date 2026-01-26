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
    # ═══════════════════════════════════════════════════════════════════════════════
    # SANGERHAUSEN
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Europa-Rosarium Sangerhausen",
        "category": "nature",
        "description": "Größte Rosensammlung der Welt mit über 8.600 Rosensorten. Weitläufiger Park mit Spielplatz und Café.",
        "address": "Steinberger Weg 3, 06526 Sangerhausen",
        "latitude": 51.4725,
        "longitude": 11.2983,
        "city": "Sangerhausen",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["park", "blumen", "spaziergang", "familienfreundlich", "spielplatz"],
        "activity_type": "park",
        "website": "https://www.europa-rosarium.de"
    },
    {
        "name": "Spengler-Museum Sangerhausen",
        "category": "museum",
        "description": "Naturkunde- und Heimatmuseum mit Mammut-Skelett, Bergbau-Geschichte und Mineraliensammlung",
        "address": "Bahnhofstraße 33, 06526 Sangerhausen",
        "latitude": 51.4731,
        "longitude": 11.2969,
        "city": "Sangerhausen",
        "age_range": "alle",
        "is_free": False,
        "is_indoor": True,
        "tags": ["museum", "mammut", "bergbau", "natur", "fossilien"],
        "activity_type": "museum",
        "website": "https://www.spengler-museum.de"
    },
    {
        "name": "Erlebnisbad Sangerhausen",
        "category": "pool",
        "description": "Freibad mit Rutschen, Sprungturm und Kinderbereich",
        "address": "Erfurter Straße, 06526 Sangerhausen",
        "latitude": 51.4689,
        "longitude": 11.2875,
        "city": "Sangerhausen",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["baden", "schwimmen", "rutschen", "sommer"],
        "activity_type": "pool"
    },
    {
        "name": "Stadtpark Sangerhausen",
        "category": "nature",
        "description": "Historischer Stadtpark mit altem Baumbestand, Teich und Spielplatz",
        "address": "Am Stadtpark, 06526 Sangerhausen",
        "latitude": 51.4698,
        "longitude": 11.3045,
        "city": "Sangerhausen",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["park", "spielplatz", "spaziergang", "natur"],
        "activity_type": "park"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # LUTHERSTADT EISLEBEN
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Luthers Geburtshaus",
        "category": "museum",
        "description": "UNESCO-Weltkulturerbe - Geburtshaus Martin Luthers mit Museum zur Kindheit des Reformators",
        "address": "Lutherstraße 15, 06295 Lutherstadt Eisleben",
        "latitude": 51.5275,
        "longitude": 11.5481,
        "city": "Lutherstadt Eisleben",
        "age_range": "alle",
        "is_free": False,
        "is_indoor": True,
        "tags": ["unesco", "geschichte", "luther", "kultur", "reformation"],
        "activity_type": "museum",
        "website": "https://www.martinluther.de"
    },
    {
        "name": "Luthers Sterbehaus",
        "category": "museum",
        "description": "UNESCO-Weltkulturerbe - Museum zum Leben und Sterben Martin Luthers",
        "address": "Andreaskirchplatz 7, 06295 Lutherstadt Eisleben",
        "latitude": 51.5268,
        "longitude": 11.5503,
        "city": "Lutherstadt Eisleben",
        "age_range": "alle",
        "is_free": False,
        "is_indoor": True,
        "tags": ["unesco", "geschichte", "luther", "kultur", "reformation"],
        "activity_type": "museum",
        "website": "https://www.martinluther.de"
    },
    {
        "name": "Knappenbrunnen Eisleben",
        "category": "nature",
        "description": "Historischer Brunnen am Markt - Treffpunkt mit Bergmann-Figur",
        "address": "Markt, 06295 Lutherstadt Eisleben",
        "latitude": 51.5272,
        "longitude": 11.5511,
        "city": "Lutherstadt Eisleben",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["altstadt", "brunnen", "bergbau", "sehenswürdigkeit"],
        "activity_type": "nature"
    },
    {
        "name": "Bergbaumuseum Röhrigschacht",
        "category": "museum",
        "description": "Authentisches Schaubergwerk - echte Untertage-Führungen im historischen Kupferschiefer-Bergwerk",
        "address": "Mansfelder Straße 46, 06295 Lutherstadt Eisleben OT Hergisdorf",
        "latitude": 51.5089,
        "longitude": 11.4917,
        "city": "Wettelrode",
        "age_range": "6-12",
        "is_free": False,
        "is_indoor": True,
        "tags": ["bergwerk", "bergbau", "untertage", "abenteuer", "kupfer"],
        "activity_type": "museum",
        "website": "https://www.roehrigschacht.de"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # HETTSTEDT
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Mansfeld-Museum Hettstedt",
        "category": "museum",
        "description": "Industrie- und Technikmuseum zur Kupferverarbeitung mit funktionsfähiger Dampfmaschine",
        "address": "Wilhelm-Stiehler-Straße 2, 06333 Hettstedt",
        "latitude": 51.6489,
        "longitude": 11.5064,
        "city": "Hettstedt",
        "age_range": "6-12",
        "is_free": False,
        "is_indoor": True,
        "tags": ["museum", "technik", "dampfmaschine", "industrie", "kupfer"],
        "activity_type": "museum",
        "website": "https://www.mansfeld-museum.com"
    },
    {
        "name": "Saigertor Hettstedt",
        "category": "castle",
        "description": "Historisches Stadttor - letztes erhaltenes von ursprünglich vier Stadttoren",
        "address": "Saigertor, 06333 Hettstedt",
        "latitude": 51.6511,
        "longitude": 11.5083,
        "city": "Hettstedt",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["altstadt", "stadttor", "geschichte", "sehenswürdigkeit"],
        "activity_type": "castle"
    },
    {
        "name": "Freibad Hettstedt",
        "category": "pool",
        "description": "Freibad mit großzügiger Liegewiese und Kinderbereich",
        "address": "Badstraße, 06333 Hettstedt",
        "latitude": 51.6453,
        "longitude": 11.5122,
        "city": "Hettstedt",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["baden", "schwimmen", "sommer", "familie"],
        "activity_type": "pool"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # MANSFELD & UMGEBUNG
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Schloss Mansfeld",
        "category": "castle",
        "description": "Imposante Burganlage oberhalb von Mansfeld mit Jugendbildungsstätte und toller Aussicht",
        "address": "Am Schloss 1, 06343 Mansfeld",
        "latitude": 51.5972,
        "longitude": 11.4528,
        "city": "Mansfeld",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["burg", "schloss", "geschichte", "aussicht", "luther"],
        "activity_type": "castle",
        "website": "https://www.schloss-mansfeld.de"
    },
    {
        "name": "Luthers Elternhaus Mansfeld",
        "category": "museum",
        "description": "Museum zur Kindheit und Jugend Martin Luthers in Mansfeld",
        "address": "Lutherstraße 26, 06343 Mansfeld",
        "latitude": 51.5956,
        "longitude": 11.4544,
        "city": "Mansfeld",
        "age_range": "alle",
        "is_free": False,
        "is_indoor": True,
        "tags": ["luther", "museum", "geschichte", "reformation"],
        "activity_type": "museum",
        "website": "https://www.martinluther.de"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # SÜDHARZ (Stolberg, Rottleberode, etc.)
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Historische Altstadt Stolberg",
        "category": "castle",
        "description": "Mittelalterliche Fachwerkstadt mit Schloss - 'Perle des Südharzes'. Komplett erhaltenes historisches Stadtbild.",
        "address": "Markt, 06536 Südharz OT Stolberg",
        "latitude": 51.5742,
        "longitude": 10.9503,
        "city": "Stolberg (Harz)",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["fachwerk", "altstadt", "mittelalter", "schloss", "historisch"],
        "activity_type": "castle",
        "website": "https://www.stolberg-harz.de"
    },
    {
        "name": "Schloss Stolberg",
        "category": "castle",
        "description": "Renaissance-Schloss hoch über der Fachwerkstadt mit Museum und Aussichtsturm",
        "address": "Schlossberg 1, 06536 Südharz OT Stolberg",
        "latitude": 51.5758,
        "longitude": 10.9478,
        "city": "Stolberg (Harz)",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["schloss", "museum", "aussicht", "renaissance"],
        "activity_type": "castle"
    },
    {
        "name": "Josephskreuz",
        "category": "nature",
        "description": "Größtes eisernes Doppelkreuz der Welt auf dem Großen Auerberg (580m). Aussichtsplattform mit Harz-Panorama.",
        "address": "Auerberg, 06536 Südharz OT Stolberg",
        "latitude": 51.5611,
        "longitude": 10.9567,
        "city": "Stolberg (Harz)",
        "age_range": "6-12",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["aussicht", "wandern", "denkmal", "harz", "panorama"],
        "activity_type": "nature",
        "website": "https://www.josephskreuz.de"
    },
    {
        "name": "Wippertalsperre",
        "category": "nature",
        "description": "Talsperre mit Rundwanderweg (6km), Spielplatz, Gastronomie und Badestelle im Sommer",
        "address": "06536 Südharz OT Wippra",
        "latitude": 51.5589,
        "longitude": 11.0833,
        "city": "Wippra",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["wandern", "baden", "spielplatz", "natur", "talsperre"],
        "activity_type": "nature"
    },
    {
        "name": "Heimkehle Uftrungen",
        "category": "museum",
        "description": "Größte Gipshöhle Deutschlands mit unterirdischem See. Faszinierende Tropfsteinformationen.",
        "address": "Heimkehle 1, 06536 Südharz OT Uftrungen",
        "latitude": 51.4939,
        "longitude": 10.9800,
        "city": "Uftrungen",
        "age_range": "alle",
        "is_free": False,
        "is_indoor": True,
        "tags": ["höhle", "tropfsteine", "geologie", "abenteuer", "unterirdisch"],
        "activity_type": "museum",
        "website": "https://www.heimkehle.de"
    },
    {
        "name": "Questenberg mit Queste",
        "category": "nature",
        "description": "Historisches Dorf mit der berühmten 'Queste' - einem 800 Jahre alten Osterbrauch. Wanderwege und Burgruine.",
        "address": "06536 Südharz OT Questenberg",
        "latitude": 51.4844,
        "longitude": 11.0350,
        "city": "Questenberg",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["wandern", "tradition", "burgruine", "natur", "dorf"],
        "activity_type": "nature"
    },
    {
        "name": "Thyragrotte Rottleberode",
        "category": "museum",
        "description": "Kleine aber feine Tropfsteinhöhle mit beeindruckenden Formationen",
        "address": "Rottleberode, 06536 Südharz",
        "latitude": 51.5111,
        "longitude": 10.9333,
        "city": "Rottleberode",
        "age_range": "alle",
        "is_free": False,
        "is_indoor": True,
        "tags": ["höhle", "tropfsteine", "geologie"],
        "activity_type": "museum"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # SEELAND / SEEGEBIET
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Süßer See",
        "category": "pool",
        "description": "Größter natürlicher See in Sachsen-Anhalt. Badestellen, Campingplatz, Seerundweg.",
        "address": "Seestraße, 06317 Seeburg",
        "latitude": 51.4833,
        "longitude": 11.6167,
        "city": "Seeburg",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["baden", "see", "camping", "wandern", "natur"],
        "activity_type": "pool"
    },
    {
        "name": "Schloss Seeburg",
        "category": "castle",
        "description": "Romanisches Schloss am Süßen See mit Ausstellungen und Veranstaltungen",
        "address": "Schlossstraße, 06317 Seeburg",
        "latitude": 51.4831,
        "longitude": 11.6103,
        "city": "Seeburg",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["schloss", "see", "kultur", "ausstellung"],
        "activity_type": "castle"
    },
    {
        "name": "Concordia See",
        "category": "pool",
        "description": "Gefluteter Tagebau mit Badestrand, Wassersport und Naherholungsgebiet",
        "address": "Concordia See, 06469 Seeland",
        "latitude": 51.6833,
        "longitude": 11.4833,
        "city": "Seeland",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["baden", "see", "wassersport", "strand"],
        "activity_type": "pool"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # GERBSTEDT & UMGEBUNG
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Schloss Gerbstedt",
        "category": "castle",
        "description": "Historische Schlossanlage mit Park",
        "address": "Schlossplatz, 06347 Gerbstedt",
        "latitude": 51.6289,
        "longitude": 11.6222,
        "city": "Gerbstedt",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["schloss", "park", "geschichte"],
        "activity_type": "castle"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # ALLSTEDT
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Burg und Schloss Allstedt",
        "category": "castle",
        "description": "Mittelalterliche Burg mit Schloss. Wirkungsstätte von Thomas Müntzer. Museum und Veranstaltungen.",
        "address": "Schloss 8, 06542 Allstedt",
        "latitude": 51.4031,
        "longitude": 11.3814,
        "city": "Allstedt",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["burg", "schloss", "müntzer", "reformation", "museum"],
        "activity_type": "castle",
        "website": "https://www.burg-allstedt.de"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # HARZ-RAND / UMGEBUNG (etwas außerhalb MSH)
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Burg Falkenstein",
        "category": "castle",
        "description": "Besterhaltene Höhenburg des Harzes. Museum, Falknervorführungen, mittelalterliches Ambiente.",
        "address": "Burg Falkenstein, 06543 Falkenstein/Harz",
        "latitude": 51.6867,
        "longitude": 11.2478,
        "city": "Falkenstein/Harz",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["burg", "falknerei", "mittelalter", "museum", "greifvögel"],
        "activity_type": "castle",
        "website": "https://www.burg-falkenstein.de"
    },
    {
        "name": "Selketal",
        "category": "nature",
        "description": "Romantisches Tal mit Wanderwegen, Harzer Schmalspurbahn und Burgen",
        "address": "Selketal, 06493 Harzgerode",
        "latitude": 51.6500,
        "longitude": 11.1500,
        "city": "Selketal",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["wandern", "bahn", "natur", "tal", "romantisch"],
        "activity_type": "nature"
    },
    {
        "name": "Burg Querfurt",
        "category": "castle",
        "description": "Eine der größten und ältesten Burgen Deutschlands. Imposante Anlage mit Museum und Veranstaltungen.",
        "address": "Burg 1, 06268 Querfurt",
        "latitude": 51.3783,
        "longitude": 11.5983,
        "city": "Querfurt",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["burg", "mittelalter", "museum", "ritter", "veranstaltungen"],
        "activity_type": "castle",
        "website": "https://www.burg-querfurt.de"
    },
    {
        "name": "Kyffhäuser-Denkmal",
        "category": "castle",
        "description": "Monumentales Kaiser-Wilhelm-Denkmal mit Barbarossa-Sage. Aussichtsturm und Burgruine.",
        "address": "Kyffhäuser 2, 06537 Kelbra",
        "latitude": 51.4158,
        "longitude": 11.1003,
        "city": "Kelbra",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["denkmal", "aussicht", "sage", "barbarossa", "geschichte"],
        "activity_type": "castle",
        "website": "https://www.kyffhaeuser-denkmal.de"
    },
    {
        "name": "Bodetal und Rosstrappe",
        "category": "nature",
        "description": "Spektakuläre Schlucht mit Seilbahn, Sommerrodelbahn und Sagenpfad. Der 'Grand Canyon' des Harzes.",
        "address": "Thale, 06502 Thale",
        "latitude": 51.7442,
        "longitude": 11.0250,
        "city": "Thale",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["wandern", "seilbahn", "sommerrodelbahn", "schlucht", "abenteuer"],
        "activity_type": "adventure",
        "website": "https://www.seilbahnen-thale.de"
    },
    {
        "name": "Hexentanzplatz Thale",
        "category": "adventure",
        "description": "Mystischer Ort mit Seilbahn, Tierpark, Sommerrodelbahn und Hexen-Spielplatz",
        "address": "Hexentanzplatz, 06502 Thale",
        "latitude": 51.7400,
        "longitude": 11.0333,
        "city": "Thale",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["hexen", "tierpark", "seilbahn", "spielplatz", "abenteuer"],
        "activity_type": "adventure",
        "website": "https://www.seilbahnen-thale.de"
    },
    {
        "name": "Harzer Schmalspurbahnen - Selketalbahn",
        "category": "adventure",
        "description": "Historische Dampfeisenbahn durch den Harz. Nostalgische Fahrten durch die Natur.",
        "address": "Bahnhof, 06493 Alexisbad",
        "latitude": 51.6528,
        "longitude": 11.1233,
        "city": "Alexisbad",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["bahn", "dampflok", "nostalgie", "harz", "familie"],
        "activity_type": "adventure",
        "website": "https://www.hsb-wr.de"
    },
    {
        "name": "Pullman City Harz",
        "category": "adventure",
        "description": "Western-Freizeitpark mit Shows, Fahrgeschäften und Übernachtungen im Wild-West-Stil",
        "address": "Am Western Village 1, 38899 Hasselfelde",
        "latitude": 51.7083,
        "longitude": 10.8500,
        "city": "Hasselfelde",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["freizeitpark", "western", "shows", "abenteuer"],
        "activity_type": "adventure",
        "website": "https://www.pullmancity-harz.de"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # SPIELPLÄTZE (verteilt im Landkreis)
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Abenteuerspielplatz Sangerhausen",
        "category": "playground",
        "description": "Großer Abenteuerspielplatz mit Klettergerüsten, Seilbahn und Wasserspielbereich",
        "address": "Am Rosarium, 06526 Sangerhausen",
        "latitude": 51.4720,
        "longitude": 11.3000,
        "city": "Sangerhausen",
        "age_range": "3-12",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["spielplatz", "klettern", "kinder", "abenteuer"],
        "activity_type": "playground"
    },
    {
        "name": "Spielplatz Stadtpark Eisleben",
        "category": "playground",
        "description": "Moderner Spielplatz im Stadtpark mit verschiedenen Spielgeräten",
        "address": "Stadtpark, 06295 Lutherstadt Eisleben",
        "latitude": 51.5250,
        "longitude": 11.5450,
        "city": "Lutherstadt Eisleben",
        "age_range": "alle",
        "is_free": True,
        "is_outdoor": True,
        "tags": ["spielplatz", "stadtpark", "kinder"],
        "activity_type": "playground"
    },

    # ═══════════════════════════════════════════════════════════════════════════════
    # TIERPARKS & BAUERNHÖFE
    # ═══════════════════════════════════════════════════════════════════════════════
    {
        "name": "Arche Nebra",
        "category": "museum",
        "description": "Besucherzentrum zur Himmelsscheibe von Nebra - multimediale Ausstellung über die Bronzezeit",
        "address": "An der Steinklöbe 16, 06642 Nebra",
        "latitude": 51.2867,
        "longitude": 11.5350,
        "city": "Nebra",
        "age_range": "alle",
        "is_free": False,
        "is_indoor": True,
        "tags": ["museum", "himmelsscheibe", "archäologie", "bronzezeit", "astronomie"],
        "activity_type": "museum",
        "website": "https://www.himmelsscheibe-erleben.de"
    },
    {
        "name": "Tiergehege Sangerhausen",
        "category": "zoo",
        "description": "Kleiner Tierpark mit heimischen und exotischen Tieren zum Anfassen",
        "address": "Tiergehege, 06526 Sangerhausen",
        "latitude": 51.4700,
        "longitude": 11.2950,
        "city": "Sangerhausen",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["tiere", "streichelzoo", "kinder", "natur"],
        "activity_type": "zoo"
    },
    {
        "name": "Erlebnisbauernhof Mittelhausen",
        "category": "farm",
        "description": "Bauernhof zum Anfassen - Tiere füttern, Reiten und Landwirtschaft erleben",
        "address": "Mittelhausen, 06295 Lutherstadt Eisleben",
        "latitude": 51.5100,
        "longitude": 11.5600,
        "city": "Mittelhausen",
        "age_range": "alle",
        "is_free": False,
        "is_outdoor": True,
        "tags": ["bauernhof", "tiere", "reiten", "kinder", "landleben"],
        "activity_type": "farm"
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