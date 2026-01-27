#!/usr/bin/env python3
"""
Notice Scraper für MSH Radar

Sammelt Straßensperrungen, Warnungen und Hinweise aus verschiedenen
Quellen im Landkreis Mansfeld-Südharz.

Quellen:
- mansfeldsuedharz.de/baustellenservice
- sangerhausen.de (Bekanntmachungen)
- eisleben.eu (Bekanntmachungen)
- Lokale Blogs und Initiativen

Usage:
    python notice_scraper.py                    # Alle Quellen scrapen
    python notice_scraper.py --source msh       # Nur Landkreis-Website
    python notice_scraper.py --dry-run          # Nur anzeigen, nicht speichern
"""

import json
import re
import time
import argparse
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional
from urllib.parse import urljoin, urlparse
import urllib.request
import urllib.error

try:
    import requests
    from bs4 import BeautifulSoup
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False
    print("HINWEIS: requests/beautifulsoup4 nicht installiert - nutze urllib")

# Pfade
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
NOTICES_FILE = PROJECT_ROOT / "data" / "notices" / "notices_current.json"
OUTPUT_FILE = PROJECT_ROOT / "data" / "notices" / "notices_scraped.json"

# Request Settings
HEADERS = {
    "User-Agent": "MSH-Map-Notice-Scraper/1.0 (https://msh-map.de)",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "de-DE,de;q=0.9,en;q=0.8",
}
TIMEOUT = 15
DELAY_BETWEEN_REQUESTS = 1.5  # Sekunden

# Bounding Box für MSH (erweitert für Randgebiete wie Walbeck)
MSH_BOUNDS = {
    "min_lat": 51.35,
    "max_lat": 51.80,  # Erweitert für nördliche Gebiete
    "min_lon": 10.90,
    "max_lon": 11.85
}

# Bekannte Straßen und ihre ungefähren Koordinaten
KNOWN_ROADS = {
    "B 180": {"lat": 51.65, "lon": 11.45, "direction": "NS"},
    "B 185": {"lat": 51.70, "lon": 11.50, "direction": "EW"},
    "B 86": {"lat": 51.47, "lon": 11.30, "direction": "EW"},
    "B 80": {"lat": 51.50, "lon": 11.55, "direction": "EW"},
    "L 224": {"lat": 51.51, "lon": 11.52, "direction": "NS"},
    "L 85": {"lat": 51.72, "lon": 11.48, "direction": "EW"},
    "L 72": {"lat": 51.60, "lon": 11.35, "direction": "NS"},
    "K 2123": {"lat": 51.60, "lon": 11.68, "direction": "EW"},
}

# Bekannte Orte für Geocoding-Fallback
KNOWN_LOCATIONS = {
    "Sangerhausen": (51.4733, 11.2973),
    "Eisleben": (51.5275, 11.5500),
    "Lutherstadt Eisleben": (51.5275, 11.5500),
    "Hettstedt": (51.6449, 11.5112),
    "Mansfeld": (51.5933, 11.4500),
    "Walbeck": (51.7480, 11.4490),
    "Quenstedt": (51.6960, 11.4410),
    "Sylda": (51.7100, 11.4300),
    "Freist": (51.5950, 11.6850),
    "Friedeburg": (51.5900, 11.6900),
    "Neckendorf": (51.4980, 11.5320),
    "Wolferode": (51.5120, 11.5180),
    "Mehringen": (51.7600, 11.4800),
    "Aschersleben": (51.7575, 11.4600),
    "Sandersleben": (51.6500, 11.3800),
    "Welfesholz": (51.5800, 11.4200),
    "Siersleben": (51.5600, 11.4800),
    "Arnstein": (51.6500, 11.4000),
}


def fetch_url(url: str) -> Optional[str]:
    """Holt HTML-Content von einer URL"""
    try:
        if HAS_REQUESTS:
            response = requests.get(url, headers=HEADERS, timeout=TIMEOUT)
            response.raise_for_status()
            return response.text
        else:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=TIMEOUT) as response:
                return response.read().decode('utf-8')
    except Exception as e:
        print(f"  Fehler beim Abrufen von {url}: {e}")
        return None


def geocode_location(query: str) -> Optional[tuple[float, float]]:
    """Geocodiert einen Ort via Nominatim"""
    # Zuerst in bekannten Orten suchen
    for name, coords in KNOWN_LOCATIONS.items():
        if name.lower() in query.lower():
            return coords

    # Nominatim API
    try:
        time.sleep(1)  # Rate limiting
        params = {
            "q": f"{query}, Mansfeld-Südharz, Sachsen-Anhalt, Deutschland",
            "format": "json",
            "limit": 1
        }
        query_string = "&".join(f"{k}={urllib.parse.quote(str(v))}" for k, v in params.items())
        url = f"https://nominatim.openstreetmap.org/search?{query_string}"

        req = urllib.request.Request(url, headers={
            "User-Agent": "MSH-Map-Notice-Scraper/1.0"
        })
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            if data:
                lat = float(data[0]["lat"])
                lon = float(data[0]["lon"])
                if MSH_BOUNDS["min_lat"] <= lat <= MSH_BOUNDS["max_lat"]:
                    return (lat, lon)
    except Exception as e:
        print(f"  Geocoding-Fehler für '{query}': {e}")

    return None


def generate_route_coordinates(
    start_location: str,
    end_location: str,
    road_name: Optional[str] = None
) -> Optional[list[list[float]]]:
    """
    Generiert Route-Koordinaten zwischen zwei Orten.
    Für Polyline-Darstellung auf der Karte.
    """
    start_coords = geocode_location(start_location)
    end_coords = geocode_location(end_location)

    if not start_coords or not end_coords:
        return None

    # Interpoliere Punkte zwischen Start und Ende
    num_points = max(3, int(abs(start_coords[0] - end_coords[0]) * 100))
    num_points = min(num_points, 10)  # Max 10 Punkte

    route = []
    for i in range(num_points):
        t = i / (num_points - 1)
        lat = start_coords[0] + t * (end_coords[0] - start_coords[0])
        lon = start_coords[1] + t * (end_coords[1] - start_coords[1])
        route.append([round(lat, 4), round(lon, 4)])

    return route


def extract_road_and_locations(text: str) -> dict:
    """Extrahiert Straßenbezeichnung und Orte aus Text"""
    result = {
        "road": None,
        "locations": [],
        "start": None,
        "end": None
    }

    # Straßenbezeichnung finden (B 180, L 224, K 2123, etc.)
    road_match = re.search(r'([BLK]\s?\d+)', text, re.IGNORECASE)
    if road_match:
        result["road"] = road_match.group(1).upper().replace(" ", " ")

    # Orte finden
    for location in KNOWN_LOCATIONS.keys():
        if location.lower() in text.lower():
            result["locations"].append(location)

    # Start/Ende ermitteln (oft durch "-" oder "zwischen" getrennt)
    between_match = re.search(
        r'zwischen\s+(\w+(?:\s+\w+)?)\s+und\s+(\w+(?:\s+\w+)?)',
        text, re.IGNORECASE
    )
    if between_match:
        result["start"] = between_match.group(1)
        result["end"] = between_match.group(2)
    elif len(result["locations"]) >= 2:
        result["start"] = result["locations"][0]
        result["end"] = result["locations"][-1]

    return result


def parse_date(date_str: str) -> Optional[str]:
    """Parst verschiedene Datumsformate zu ISO-Format"""
    formats = [
        "%d.%m.%Y",
        "%d.%m.%y",
        "%Y-%m-%d",
        "%d. %B %Y",
        "%d.%m.",
    ]

    # Jahr ergänzen wenn fehlt
    if re.match(r'^\d{1,2}\.\d{1,2}\.$', date_str):
        date_str += str(datetime.now().year)

    for fmt in formats:
        try:
            dt = datetime.strptime(date_str, fmt)
            # Wenn Jahr < 2000, ist es vermutlich ein Fehler
            if dt.year < 2000:
                dt = dt.replace(year=dt.year + 2000)
            return dt.strftime("%Y-%m-%d")
        except ValueError:
            continue

    return None


def scrape_msh_baustellenservice() -> list[dict]:
    """
    Scrapt die Baustellenservice-Seite des Landkreises MSH.
    URL: https://www.mansfeldsuedharz.de/baustellenservice
    """
    print("\n[MSH Baustellenservice]")
    notices = []

    url = "https://www.mansfeldsuedharz.de/baustellenservice"
    html = fetch_url(url)

    if not html:
        print("  Konnte Seite nicht laden")
        return notices

    if not HAS_REQUESTS:
        print("  BeautifulSoup nicht verfügbar - überspringe HTML-Parsing")
        return notices

    soup = BeautifulSoup(html, "html.parser")

    # Suche nach Tabellen oder Listen mit Baustelleninfos
    # Die Struktur variiert - hier ein generischer Ansatz
    content = soup.find("main") or soup.find("div", class_="content") or soup.body

    # Suche nach Überschriften die Sperrungen enthalten
    for heading in content.find_all(["h2", "h3", "h4", "strong"]):
        text = heading.get_text(strip=True)

        # Filter für relevante Einträge
        if any(kw in text.lower() for kw in ["sperrung", "vollsperrung", "baustelle", "umleitung"]):
            # Versuche zugehörigen Beschreibungstext zu finden
            description = ""
            next_elem = heading.find_next_sibling()
            if next_elem:
                description = next_elem.get_text(strip=True)

            # Extrahiere Straßen- und Ortsinformationen
            full_text = f"{text} {description}"
            road_info = extract_road_and_locations(full_text)

            # Koordinaten ermitteln
            lat, lon = None, None
            route_coords = None

            if road_info["start"] and road_info["end"]:
                route_coords = generate_route_coordinates(
                    road_info["start"],
                    road_info["end"],
                    road_info["road"]
                )
                if route_coords:
                    # Mittelpunkt als Hauptkoordinate
                    mid_idx = len(route_coords) // 2
                    lat = route_coords[mid_idx][0]
                    lon = route_coords[mid_idx][1]

            if not lat and road_info["road"] in KNOWN_ROADS:
                road_data = KNOWN_ROADS[road_info["road"]]
                lat = road_data["lat"]
                lon = road_data["lon"]

            if lat and lon:
                notice = {
                    "type": "sperrung",
                    "title": text[:100],
                    "description": description[:500] if description else None,
                    "affected_area": f"{road_info['road'] or ''} ({', '.join(road_info['locations'])})" if road_info["locations"] else None,
                    "severity": "critical" if "vollsperrung" in text.lower() else "warning",
                    "source_url": url,
                    "latitude": round(lat, 4),
                    "longitude": round(lon, 4),
                }
                if route_coords:
                    notice["route_coordinates"] = route_coords

                notices.append(notice)
                print(f"  Gefunden: {text[:50]}...")

    print(f"  {len(notices)} Einträge gefunden")
    return notices


def scrape_sangerhausen() -> list[dict]:
    """Scrapt Bekanntmachungen der Stadt Sangerhausen"""
    print("\n[Sangerhausen Bekanntmachungen]")
    notices = []

    # Haupt-URL für Verkehrsmeldungen und Bekanntmachungen
    urls = [
        "https://www.sangerhausen.de/aktuelles",
        "https://www.sangerhausen.de/bekanntmachungen/stellenausschreibungen",
    ]

    for url in urls:
        time.sleep(DELAY_BETWEEN_REQUESTS)
        html = fetch_url(url)

        if not html or not HAS_REQUESTS:
            continue

        soup = BeautifulSoup(html, "html.parser")

        # Suche nach Meldungen
        for article in soup.find_all(["article", "div"], class_=re.compile(r"news|meldung|article")):
            title_elem = article.find(["h2", "h3", "a"])
            if not title_elem:
                continue

            title = title_elem.get_text(strip=True)

            # Filter für Verkehrsmeldungen
            if not any(kw in title.lower() for kw in ["sperrung", "straße", "verkehr", "umleitung", "baustelle"]):
                continue

            # Beschreibung
            desc_elem = article.find("p") or article.find(class_="teaser")
            description = desc_elem.get_text(strip=True) if desc_elem else ""

            # Koordinaten für Sangerhausen-Zentrum als Fallback
            lat, lon = 51.4728, 11.2982

            # Versuche genauere Position
            full_text = f"{title} {description}"
            if "göpenstraße" in full_text.lower():
                lat, lon = 51.4728, 11.2982
            elif "bahnhofstraße" in full_text.lower():
                lat, lon = 51.4710, 11.2950

            notice = {
                "type": "sperrung",
                "title": title[:100],
                "description": description[:500] if description else None,
                "affected_area": f"Sangerhausen, {title}",
                "severity": "warning",
                "source_url": url,
                "latitude": lat,
                "longitude": lon,
            }
            notices.append(notice)
            print(f"  Gefunden: {title[:50]}...")

    print(f"  {len(notices)} Einträge gefunden")
    return notices


def scrape_eisleben() -> list[dict]:
    """Scrapt Bekanntmachungen der Stadt Eisleben"""
    print("\n[Eisleben Bekanntmachungen]")
    notices = []

    url = "https://www.eisleben.eu/de/rathaus-politik/aktuelles/bekanntmachungen.html"
    html = fetch_url(url)

    if not html or not HAS_REQUESTS:
        print("  Konnte Seite nicht laden oder BeautifulSoup fehlt")
        return notices

    soup = BeautifulSoup(html, "html.parser")

    # Ähnliche Logik wie Sangerhausen
    for item in soup.find_all(["article", "div", "li"], class_=re.compile(r"news|item|meldung")):
        title_elem = item.find(["h2", "h3", "a", "strong"])
        if not title_elem:
            continue

        title = title_elem.get_text(strip=True)

        if not any(kw in title.lower() for kw in ["sperrung", "straße", "verkehr", "abriss", "baustelle"]):
            continue

        lat, lon = 51.5249, 11.5480  # Eisleben Zentrum

        notice = {
            "type": "sperrung",
            "title": title[:100],
            "affected_area": f"Lutherstadt Eisleben",
            "severity": "warning",
            "source_url": url,
            "latitude": lat,
            "longitude": lon,
        }
        notices.append(notice)
        print(f"  Gefunden: {title[:50]}...")

    print(f"  {len(notices)} Einträge gefunden")
    return notices


def scrape_local_blogs() -> list[dict]:
    """Scrapt lokale Blogs und Bürgerinitiativen"""
    print("\n[Lokale Blogs/Initiativen]")
    notices = []

    blogs = [
        {
            "url": "https://initiativewelbsleben.blogspot.com/",
            "name": "Initiative Welbsleben"
        },
        {
            "url": "https://welbsleben.blogspot.com/",
            "name": "Welbsleben Blog"
        }
    ]

    for blog in blogs:
        time.sleep(DELAY_BETWEEN_REQUESTS)
        html = fetch_url(blog["url"])

        if not html:
            continue

        if not HAS_REQUESTS:
            # Einfache Regex-Suche ohne BeautifulSoup
            sperrung_matches = re.findall(
                r'(Sperrung|Vollsperrung)[^<]{0,200}(B\s?\d+|L\s?\d+)',
                html, re.IGNORECASE
            )
            for match in sperrung_matches:
                print(f"  Gefunden (Regex): {match[0]} {match[1]}")
            continue

        soup = BeautifulSoup(html, "html.parser")

        for post in soup.find_all(["article", "div"], class_=re.compile(r"post|entry")):
            title_elem = post.find(["h2", "h3", "a"], class_=re.compile(r"title|entry-title"))
            if not title_elem:
                continue

            title = title_elem.get_text(strip=True)

            if not any(kw in title.lower() for kw in ["sperrung", "b 180", "b180", "straße"]):
                continue

            # Link zum vollständigen Artikel
            link = title_elem.get("href") if title_elem.name == "a" else None
            if not link:
                link_elem = post.find("a")
                link = link_elem.get("href") if link_elem else blog["url"]

            notice = {
                "type": "sperrung",
                "title": title[:100],
                "source_url": link or blog["url"],
                "severity": "warning",
                "latitude": 51.70,  # Welbsleben-Bereich
                "longitude": 11.45,
            }
            notices.append(notice)
            print(f"  Gefunden: {title[:50]}...")

    print(f"  {len(notices)} Einträge gefunden")
    return notices


def deduplicate_notices(notices: list[dict]) -> list[dict]:
    """Entfernt Duplikate basierend auf Titel-Ähnlichkeit"""
    unique = []
    seen_titles = set()

    for notice in notices:
        # Normalisierter Titel für Vergleich
        norm_title = re.sub(r'\s+', ' ', notice["title"].lower().strip())

        # Prüfe auf ähnliche Titel
        is_duplicate = False
        for seen in seen_titles:
            # Jaccard-Ähnlichkeit der Wörter
            words1 = set(norm_title.split())
            words2 = set(seen.split())
            if words1 and words2:
                similarity = len(words1 & words2) / len(words1 | words2)
                if similarity > 0.7:
                    is_duplicate = True
                    break

        if not is_duplicate:
            unique.append(notice)
            seen_titles.add(norm_title)

    return unique


def merge_with_existing(new_notices: list[dict], existing_path: Path) -> list[dict]:
    """Merged neue Notices mit bestehenden Daten"""
    if not existing_path.exists():
        return new_notices

    with open(existing_path, 'r', encoding='utf-8') as f:
        existing_data = json.load(f)

    existing_notices = existing_data.get("notices", [])

    # Behalte manuell gepflegte Einträge (die mit ID)
    manual_notices = [n for n in existing_notices if n.get("id")]

    # Neue Notices mit IDs versehen
    max_id = 0
    for n in manual_notices:
        match = re.search(r'notice_(\d+)', n.get("id", ""))
        if match:
            max_id = max(max_id, int(match.group(1)))

    for i, notice in enumerate(new_notices):
        if not notice.get("id"):
            max_id += 1
            notice["id"] = f"notice_{max_id:03d}"

    # Merge: Manuelle haben Priorität
    merged = manual_notices.copy()

    for new in new_notices:
        # Prüfe ob ähnlicher Eintrag bereits existiert
        exists = False
        for existing in merged:
            if existing.get("title", "").lower()[:30] == new.get("title", "").lower()[:30]:
                exists = True
                # Update source_urls wenn neue Quelle gefunden
                if new.get("source_url"):
                    existing_urls = existing.get("source_urls", [])
                    if existing.get("source_url"):
                        existing_urls.append(existing["source_url"])
                    if new["source_url"] not in existing_urls:
                        existing_urls.append(new["source_url"])
                        existing["source_urls"] = list(set(existing_urls))
                break

        if not exists:
            merged.append(new)

    return merged


def main():
    parser = argparse.ArgumentParser(description="Scrapt Notices für MSH Radar")
    parser.add_argument("--source", choices=["msh", "sangerhausen", "eisleben", "blogs", "all"],
                        default="all", help="Welche Quelle(n) scrapen")
    parser.add_argument("--dry-run", action="store_true", help="Nur anzeigen, nicht speichern")
    parser.add_argument("--merge", action="store_true", help="Mit bestehenden Notices mergen")
    args = parser.parse_args()

    print("=" * 60)
    print("Notice Scraper für MSH Radar")
    print("=" * 60)

    all_notices = []

    # Quellen scrapen
    if args.source in ["msh", "all"]:
        all_notices.extend(scrape_msh_baustellenservice())
        time.sleep(DELAY_BETWEEN_REQUESTS)

    if args.source in ["sangerhausen", "all"]:
        all_notices.extend(scrape_sangerhausen())
        time.sleep(DELAY_BETWEEN_REQUESTS)

    if args.source in ["eisleben", "all"]:
        all_notices.extend(scrape_eisleben())
        time.sleep(DELAY_BETWEEN_REQUESTS)

    if args.source in ["blogs", "all"]:
        all_notices.extend(scrape_local_blogs())

    # Deduplizieren
    print(f"\n[Deduplizierung]")
    print(f"  Vorher: {len(all_notices)} Einträge")
    all_notices = deduplicate_notices(all_notices)
    print(f"  Nachher: {len(all_notices)} Einträge")

    # Optional: Mit bestehenden Notices mergen
    if args.merge and NOTICES_FILE.exists():
        print(f"\n[Merge mit bestehenden Notices]")
        all_notices = merge_with_existing(all_notices, NOTICES_FILE)
        print(f"  Gesamt: {len(all_notices)} Einträge")

    # Ergebnis
    print("\n" + "=" * 60)
    print(f"Gefundene Notices: {len(all_notices)}")
    print("=" * 60)

    for notice in all_notices:
        severity_icon = "" if notice.get("severity") == "critical" else ""
        route_info = " [ROUTE]" if notice.get("route_coordinates") else ""
        print(f"  {severity_icon} {notice.get('title', '???')[:60]}{route_info}")

    if args.dry_run:
        print("\n[DRY RUN - Nicht gespeichert]")
        return

    # Speichern
    output_data = {
        "meta": {
            "generated_at": datetime.now().isoformat(),
            "source": "notice_scraper",
            "count": len(all_notices)
        },
        "notices": all_notices
    }

    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)

    print(f"\nGespeichert: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
