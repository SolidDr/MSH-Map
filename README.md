# 🗺️ MSH Map

**Interaktive Kartenanwendung für den Landkreis Mansfeld-Südharz**

Eine moderne, barrierefreie Web-App die lokale Orte, Events, ÖPNV-Verbindungen und mehr auf einer übersichtlichen Karte vereint – mit besonderem Fokus auf ältere Nutzer und regionale Bedürfnisse.

![MSH Map Analytics](https://img.shields.io/badge/Status-Beta-yellow)
![License](https://img.shields.io/badge/License-MIT-green)
![Made with Claude](https://img.shields.io/badge/Made%20with-Claude%20AI-blueviolet)

---

## ✨ Features

### 🔍 Intelligente Suche
- **Tensor Search Architektur** – Suchsystem basierend auf KOLAN Systems Tensor Search, optimiert für lokale Ausführung ohne externe Abhängigkeiten
- Autocomplete mit Echtzeit-Vorschlägen
- Fuzzy-Matching und Synonym-Erkennung
- Kategoriebasierte Filterung

### 🗺️ Interaktive Karte
- Alle Points of Interest auf einen Blick
- Kategorien: Gastronomie, Kultur, Gesundheit, Bildung, Sport und mehr
- Echtzeit-Warnungen und Hinweise (Baustellen, Sperrungen)
- Heatmap-Visualisierung für Dichte-Analyse

### 📅 Events & Erleben
- Veranstaltungskalender der Region
- Filter nach Kategorie (Konzert, Markt, Theater, Sport, etc.)
- "Mitmachen" – Vereine und Gruppen entdecken

### 🚌 Mobilität
- ÖPNV-Abfahrten in Echtzeit
- Verbindungssuche mit Autocomplete
- Haltestellen in der Nähe
- Alternative Mobilität (Fahrrad, Carsharing)

### 🏥 Gesundheit (NEU)
- Ärzte-Suche mit Öffnungszeiten und Kontaktdaten
- Notdienst-Apotheken – immer aktuell
- Barrierefreie Praxen finden
- Seniorenfreundliche Darstellung mit großen Touch-Targets

### ♿ Barrierefreiheit
- Optimiert für ältere Nutzer
- Hoher Kontrast, große Schriften
- Vollständige Keyboard-Navigation
- Screen-Reader kompatibel

---

## 🚀 Quick Start

### Voraussetzungen

- Node.js 18+ 
- npm oder yarn

### Installation

```bash
# Repository klonen
git clone https://github.com/kolan-systems/msh-map-analytics.git

# In das Verzeichnis wechseln
cd msh-map-analytics

# Abhängigkeiten installieren
npm install

# Entwicklungsserver starten
npm run dev
```

Die App ist nun unter `http://localhost:3000` erreichbar.

### Production Build

```bash
npm run build
npm run start
```

---

## 🏗️ Architektur

### Tensor Search Integration

Die Suchfunktionalität basiert auf der **KOLAN Systems Tensor Search** Architektur. Diese wurde speziell so konzipiert, dass sie:

- **Lokal ausführbar** ist – keine externen API-Aufrufe notwendig
- **Offline-fähig** – Suche funktioniert auch ohne Internetverbindung
- **Datenschutzfreundlich** – alle Daten bleiben auf dem Gerät
- **Performant** – optimiert für schnelle Antwortzeiten auch auf älteren Geräten

```
┌─────────────────────────────────────────────────┐
│                  MSH Map App                     │
├─────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│  │   Tensor    │  │    Map      │  │  Event  │ │
│  │   Search    │  │   Engine    │  │ Handler │ │
│  └──────┬──────┘  └──────┬──────┘  └────┬────┘ │
│         │                │               │      │
│         └────────────────┼───────────────┘      │
│                          │                      │
│              ┌───────────┴───────────┐          │
│              │     Local Data Store   │          │
│              │   (Offline Available)  │          │
│              └───────────────────────┘          │
└─────────────────────────────────────────────────┘
```

### Projektstruktur

```
msh-map-analytics/
├── src/
│   ├── components/     # UI-Komponenten
│   ├── features/       # Feature-Module
│   │   ├── search/     # Tensor Search Implementation
│   │   ├── map/        # Kartenlogik
│   │   ├── events/     # Event-Handling
│   │   ├── mobility/   # ÖPNV-Features
│   │   └── health/     # Gesundheits-Modul
│   ├── data/           # Lokale Datensätze
│   ├── styles/         # CSS/Styling
│   └── utils/          # Hilfsfunktionen
├── public/             # Statische Assets
└── docs/               # Dokumentation
```

---

## 🎯 Roadmap

### ✅ Abgeschlossen
- [x] Interaktive Kartenansicht
- [x] Kategoriebasierte Filter
- [x] Event-Kalender
- [x] ÖPNV-Integration
- [x] Warnungen & Hinweise
- [x] Mobile-optimierte Ansicht

### 🔄 In Arbeit
- [ ] Gesundheits-Modul (Ärzte, Apotheken)
- [ ] Erweiterte Suchfunktionen
- [ ] Offline-Modus (Service Worker)
- [ ] Benutzerprofile

### 📋 Geplant
- [ ] Mehrsprachigkeit (DE/EN)
- [ ] Push-Benachrichtigungen
- [ ] Community-Features
- [ ] API für Drittanbieter

---

## 🛠️ Entwicklung

### Technologie-Stack

| Bereich | Technologie |
|---------|-------------|
| Frontend | Next.js / React |
| Karte | Leaflet |
| Styling | Tailwind CSS |
| State | Zustand / Context |
| Suche | Tensor Search (KOLAN) |
| Deployment | Vercel |

### Lokale Entwicklung

```bash
# Tests ausführen
npm run test

# Linting
npm run lint

# Type-Check
npm run type-check
```

### Daten aktualisieren

Die lokalen Datensätze können über das Admin-Interface oder manuell aktualisiert werden:

```bash
npm run update-data
```

---

## 📊 Datenquellen

MSH Map Analytics aggregiert öffentlich verfügbare Daten aus verschiedenen Quellen:

- OpenStreetMap (Geodaten)
- Kommunale Webseiten (Events, Öffnungszeiten)
- INSA Sachsen-Anhalt (ÖPNV)
- KV Sachsen-Anhalt (Arztverzeichnis)
- Apothekerkammer (Notdienste)

---

## 🤝 Beitragen

Beiträge sind willkommen! Bitte lies zuerst unsere [Contributing Guidelines](CONTRIBUTING.md).

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Committe deine Änderungen (`git commit -m 'Add AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

---

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz – siehe [LICENSE](LICENSE) für Details.

---

## 👏 Credits

Entwickelt von **KOLAN Systems**

Dieses Projekt wurde in Zusammenarbeit mit Claude AI entwickelt.

---

## 📬 Kontakt

**KOLAN Systems**

- Website: [kolansystems.de](https://kolansystems.de)
- E-Mail: kontakt@kolansystems.de
- GitHub: [@kolan-systems](https://github.com/kolan-systems)

---

<p align="center">
  <sub>Mit ❤️ für Mansfeld-Südharz</sub>
</p>
