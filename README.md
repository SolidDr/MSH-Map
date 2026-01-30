# MSH Map

**Regionale Plattform für Mansfeld-Südharz**

Eine moderne Flutter Web-App, die lokale Orte, Veranstaltungen, ÖPNV-Verbindungen, Gesundheitseinrichtungen und mehr auf einer interaktiven Karte vereint.

![Version](https://img.shields.io/badge/Version-2.5.2-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.38-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green)

**Live:** [msh-map.de](https://msh-map.de)

---

## Features

### Karte & Entdecken
- Interaktive Karte mit allen Points of Interest
- Autocomplete-Suche mit Live-Vorschlägen
- Kategoriebasierte Filter mit Scroll-Indikatoren
- Marker-Clustering für bessere Performance

### Veranstaltungen
- Regionale Events und Termine
- Engagement-Möglichkeiten (Vereine, Ehrenamt)
- Tierheimtiere zur Vermittlung
- Teilen-Funktion (WhatsApp, SMS, etc.)

### ÖPNV (Mobilität)
- Echtzeit-Abfahrten von Haltestellen
- Verbindungssuche mit Autocomplete
- Integration mit INSA Sachsen-Anhalt

### Gesundheit
- Ärzte, Apotheken, Krankenhäuser
- Notdienst-Apotheken (aktuell)
- Defibrillatoren (AED) Standorte
- Klickbare Telefonnummern in Listen

### Soziales
- Behörden und Ämter
- Jugendzentren
- Soziale Einrichtungen
- Seniorentreffs

### Ausgehen & Freizeit
- Restaurants, Cafés, Bars
- Schwimmbäder
- Nachtleben

### Radwege
- Regionale Radrouten mit GPX-Daten
- Animierte Streckenanzeige auf der Karte
- POIs entlang der Routen

### Barrierefreiheit
- Einstellbare Schriftgröße
- Hoher Kontrast Modus
- Große Touch-Targets
- Hinweis auf Startseite

---

## Tech Stack

| Bereich | Technologie |
|---------|-------------|
| Framework | Flutter 3.38 (Web) |
| State Management | Riverpod |
| Routing | go_router |
| Karte | flutter_map + Leaflet |
| Clustering | flutter_map_marker_cluster |
| CI/CD | GitHub Actions |
| Hosting | Vercel |

---

## Entwicklung

### Voraussetzungen

- Flutter SDK 3.38+
- Dart SDK 3.8+

### Installation

```bash
# Repository klonen
git clone https://github.com/SolidDr/MSH-Map.git
cd MSH-Map

# Abhängigkeiten installieren
flutter pub get

# Entwicklungsserver starten
flutter run -d chrome
```

### Build

```bash
# Web Release Build
flutter build web --release

# Der Build liegt in build/web/
```

### Projektstruktur

```
lib/
├── main.dart
├── app.dart
└── src/
    ├── core/           # Theme, Config, Constants
    │   ├── config/
    │   ├── constants/
    │   ├── providers/
    │   ├── shell/      # App Shell (Navigation)
    │   └── theme/
    ├── features/       # Feature-Module
    │   ├── analytics/
    │   ├── discover/   # Entdecken Screen
    │   ├── engagement/ # Veranstaltungen
    │   ├── mobility/   # ÖPNV
    │   └── profile/    # Einstellungen
    ├── modules/        # Daten-Module
    │   ├── civic/      # Soziales
    │   ├── gastro/     # Gastronomie
    │   ├── health/     # Gesundheit
    │   ├── leisure/    # Freizeit
    │   ├── nightlife/  # Ausgehen
    │   └── radwege/    # Radwege
    └── shared/         # Gemeinsame Widgets
        ├── domain/
        └── widgets/
```

---

## Datenquellen

- **OpenStreetMap** - Geodaten, POIs
- **INSA Sachsen-Anhalt** - ÖPNV Echtzeitdaten
- **Kommunale Quellen** - Veranstaltungen, Behörden
- **Eigene Recherche** - Gesundheit, Soziales

---

## CI/CD

GitHub Actions baut automatisch bei Push auf `main`:

1. Flutter Web Release Build
2. Commit der Build-Artefakte
3. Deploy zu Vercel

---

## Lizenz

MIT License - siehe [LICENSE](LICENSE)

---

## Kontakt

**KOLAN Systems**

- Website: [kolansystems.de](https://kolansystems.de)
- GitHub: [@SolidDr](https://github.com/SolidDr)

---

<p align="center">
  <sub>Mit Liebe für Mansfeld-Südharz</sub>
</p>
