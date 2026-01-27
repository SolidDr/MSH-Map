#!/usr/bin/env python3
"""
og:image Extractor für MSH Radar Events

Extrahiert Open Graph Bilder von Event-Quellseiten und reichert
die Event-Daten mit image_url an.

Usage:
    python og_image_extractor.py
"""

import json
import re
import time
from pathlib import Path
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup

# Pfade
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
EVENTS_FILE = PROJECT_ROOT / "data" / "events" / "events_current.json"
OUTPUT_FILE = PROJECT_ROOT / "data" / "events" / "events_current.json"

# Request Settings
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "de-DE,de;q=0.9,en;q=0.8",
}
TIMEOUT = 10
DELAY_BETWEEN_REQUESTS = 1.0  # Sekunden


def extract_og_image(url: str) -> str | None:
    """
    Extrahiert das og:image von einer URL.

    Args:
        url: Die URL der Seite

    Returns:
        Die Bild-URL oder None
    """
    try:
        response = requests.get(url, headers=HEADERS, timeout=TIMEOUT, allow_redirects=True)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, "html.parser")

        # Versuche verschiedene Meta-Tags
        og_image = None

        # 1. Standard og:image
        meta = soup.find("meta", property="og:image")
        if meta and meta.get("content"):
            og_image = meta["content"]

        # 2. Fallback: twitter:image
        if not og_image:
            meta = soup.find("meta", {"name": "twitter:image"})
            if meta and meta.get("content"):
                og_image = meta["content"]

        # 3. Fallback: og:image:url
        if not og_image:
            meta = soup.find("meta", property="og:image:url")
            if meta and meta.get("content"):
                og_image = meta["content"]

        # Relative URLs auflösen
        if og_image and not og_image.startswith(("http://", "https://")):
            og_image = urljoin(url, og_image)

        # Validierung: Nur gültige Bild-URLs
        if og_image:
            parsed = urlparse(og_image)
            if not parsed.scheme or not parsed.netloc:
                return None
            # Prüfe auf typische Bild-Endungen oder CDN-Muster
            if not re.search(r"\.(jpg|jpeg|png|gif|webp|svg)(\?|$)", og_image.lower()):
                # Manche CDNs haben keine Dateiendung - trotzdem akzeptieren
                if "image" not in og_image.lower() and "img" not in og_image.lower():
                    pass  # Akzeptieren auch ohne Extension

        return og_image

    except requests.RequestException as e:
        print(f"  Fehler beim Abrufen von {url}: {e}")
        return None
    except Exception as e:
        print(f"  Parsing-Fehler für {url}: {e}")
        return None


def enrich_events_with_images(events: list[dict]) -> tuple[list[dict], int]:
    """
    Reichert Events mit og:image an.

    Args:
        events: Liste der Events

    Returns:
        Tuple aus (angereicherte Events, Anzahl gefundener Bilder)
    """
    enriched = []
    found_count = 0

    for i, event in enumerate(events):
        source_url = event.get("source_url")
        existing_image = event.get("image_url")

        # Skip wenn bereits ein Bild vorhanden
        if existing_image:
            print(f"[{i+1}/{len(events)}] {event['name'][:40]}... - bereits vorhanden")
            enriched.append(event)
            found_count += 1
            continue

        # Skip wenn keine source_url
        if not source_url:
            print(f"[{i+1}/{len(events)}] {event['name'][:40]}... - keine source_url")
            enriched.append(event)
            continue

        print(f"[{i+1}/{len(events)}] {event['name'][:40]}... ", end="", flush=True)

        # og:image extrahieren
        image_url = extract_og_image(source_url)

        if image_url:
            event["image_url"] = image_url
            found_count += 1
            print(f"OK ({image_url[:50]}...)")
        else:
            print("kein Bild gefunden")

        enriched.append(event)

        # Rate Limiting
        time.sleep(DELAY_BETWEEN_REQUESTS)

    return enriched, found_count


def main():
    """Hauptfunktion"""
    print("=" * 60)
    print("og:image Extractor für MSH Radar Events")
    print("=" * 60)

    # Events laden
    if not EVENTS_FILE.exists():
        print(f"Fehler: Events-Datei nicht gefunden: {EVENTS_FILE}")
        return

    with open(EVENTS_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    events = data.get("events", [])
    print(f"\nGeladene Events: {len(events)}")

    # Mit source_url
    with_source = [e for e in events if e.get("source_url")]
    print(f"Events mit source_url: {len(with_source)}")

    # Bereits mit Bild
    with_image = [e for e in events if e.get("image_url")]
    print(f"Events bereits mit Bild: {len(with_image)}")

    print("\n" + "-" * 60)
    print("Starte Extraktion...")
    print("-" * 60 + "\n")

    # Anreichern
    enriched_events, found_count = enrich_events_with_images(events)

    # Speichern
    data["events"] = enriched_events

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("\n" + "=" * 60)
    print(f"Fertig! Bilder gefunden: {found_count}/{len(events)}")
    print(f"Gespeichert: {OUTPUT_FILE}")
    print("=" * 60)


if __name__ == "__main__":
    main()
