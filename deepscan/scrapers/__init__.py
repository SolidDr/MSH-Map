"""
MSH DeepScan - Scraper Module
Collection of data scrapers for various sources
"""

from .osm_scraper import OSMScraper
from .wikidata_scraper import WikidataScraper

__all__ = ['OSMScraper', 'WikidataScraper']
