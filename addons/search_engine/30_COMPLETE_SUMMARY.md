# 30 - MSH MAP: VOLLSTÄNDIGE PROJEKT-ZUSAMMENFASSUNG

## Projekt-Übersicht

**Name:** MSH Map
**Typ:** Regionale Karten-App für Mansfeld-Südharz
**Zielgruppe:** Familien, Einheimische, Touristen
**Entwickler:** KOLAN Systems (Konstantin Lange)
**Technologie:** Flutter Web → Vercel
**Datenschutz:** 100% Cookie-frei, nur Open Source

---

## Vision

> **"Die Region Mansfeld-Südharz auf einen Blick - für Familien, von der Region."**

Eine Karten-App die:
- Alle familienfreundlichen Orte zeigt
- Aktuelle Veranstaltungen bündelt
- Ohne Tracking und Cookies funktioniert
- Von der Community wachsen kann
- Der Region echten Mehrwert bietet

---

## Architektur

### Tech Stack

```
┌─────────────────────────────────────────────────────────────┐
│                        FRONTEND                             │
│                                                             │
│   Flutter Web (Dart)                                        │
│   ├── flutter_map (OpenStreetMap)                          │
│   ├── flutter_riverpod (State Management)                  │
│   ├── freezed (Datenmodelle)                               │
│   └── go_router (Navigation)                               │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                        DATEN                                │
│                                                             │
│   Statische JSON-Dateien (im Build)                        │
│   ├── data/locations.json                                  │
│   ├── data/events/events_current.json                      │
│   └── data/notices/notices_current.json                    │
│                                                             │
│   Optional später: Firebase Firestore                       │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                       HOSTING                               │
│                                                             │
│   Vercel (Static Hosting)                                   │
│   ├── Automatisches HTTPS                                  │
│   ├── CDN weltweit                                         │
│   └── Eigene Domain                                        │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                    DATEN-PIPELINE                           │
│                                                             │
│   Wöchentlicher MSH Radar (Claude Code)                    │
│   ├── Events recherchieren                                 │
│   ├── Hinweise sammeln                                     │
│   ├── JSON aktualisieren                                   │
│   └── Deploy via Vercel CLI                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Datenschutz-Prinzipien

| Prinzip | Umsetzung |
|---------|-----------|
| **Keine Cookies** | Kein Tracking, kein Cookie-Banner |
| **Keine Accounts** | Alles anonym nutzbar |
| **Nur Open Source** | OSM, Open-Meteo, selbst gehostete Fonts |
| **Keine Embeds** | Nur Links zu externen Seiten |
| **localStorage** | Für persönliche Einstellungen (kein Cookie!) |
| **Anonyme Meldungen** | Keine Nutzer-ID bei Feedback |

---

## Feature-Übersicht

### Kern-Features (V1.0)

| Feature | Status | Beschreibung |
|---------|--------|--------------|
| **Interaktive Karte** | ✅ | OSM-basiert, Marker, Zoom, Pan |
| **Fog of War** | ✅ | Nebliger Rand außerhalb MSH |
| **Kategorien-Filter** | ✅ | Spielplätze, Museen, Natur, etc. |
| **Ort-Details** | ✅ | Name, Beschreibung, Adresse, etc. |
| **Flohmarkt** | ✅ | Regionaler Kleinanzeigenmarkt |
| **Dashboard** | ✅ | "MSH in Zahlen" Statistiken |
| **"Fehlt etwas?"** | ✅ | Ort vorschlagen via E-Mail |
| **Responsive Design** | ✅ | Mobile, Tablet, Desktop |

### MUSS-Features (V1.1)

| Feature | Aufwand | Beschreibung |
|---------|---------|--------------|
| **Altersfilter** | 1-2 Tage | Kinder-Alter → passende Orte |
| **Events auf Karte** | 0.5 Tage | Veranstaltungen als Marker |
| **Events-Widget** | 0.5 Tage | "Diese Woche" prominent |
| **Wetter-Integration** | 0.5 Tage | Open-Meteo, Indoor/Outdoor-Tipps |
| **ÖPNV-Links** | 0.5 Tage | Verbindung zu INSA |
| **Melde-Feature** | 1 Tag | Probleme/Gefahren anonym melden |
| **Feature-Flags** | 0.5 Tage | Features ein/ausschalten |

### SOLL-Features (V1.2)

| Feature | Aufwand | Beschreibung |
|---------|---------|--------------|
| **Offline-Karten** | 2-3 Tage | MSH offline verfügbar |
| **Naturschutz-Layer** | 1 Tag | Schutzgebiete anzeigen |
| **E-Ladesäulen** | 0.5 Tage | Aus OSM-Daten |
| **Prognose** | Im Radar | "Wird es voll?" |

### NICE-Features (V1.3+)

| Feature | Aufwand | Beschreibung |
|---------|---------|--------------|
| **Bewertungen** | 2 Tage | Anonym, 1-5 Sterne |
| **Check-ins** | 1 Tag | "Ich war da" (localStorage) |
| **Foto-Uploads** | 3-4 Tage | Mit manueller Moderation |
| **Homescreen Widget** | 2-3 Tage | Für native Apps |
| **Geocaching** | Recherche | MSH Schnitzeljagd |

---

## Feature-Flag System

### Konzept

Alle Features können ohne Code-Änderung ein/ausgeschaltet werden:

```dart
// lib/src/core/config/feature_flags.dart

class FeatureFlags {
  // ═══════════════════════════════════════════════════════════
  // CORE FEATURES
  // ═══════════════════════════════════════════════════════════
  
  /// Interaktive Karte mit Markern
  static const bool enableMap = true;
  
  /// Fog of War Effekt am Kartenrand
  static const bool enableFogOfWar = true;
  
  /// Kategorien-Filter auf der Karte
  static const bool enableCategoryFilter = true;
  
  // ═══════════════════════════════════════════════════════════
  // FAMILY FEATURES
  // ═══════════════════════════════════════════════════════════
  
  /// Altersgerechte Empfehlungen
  static const bool enableAgeFilter = true;
  
  /// Wetter-Integration mit Empfehlungen
  static const bool enableWeather = true;
  
  /// "Perfekt für deine Familie" Badges
  static const bool enableFamilyBadges = true;
  
  // ═══════════════════════════════════════════════════════════
  // EVENTS & AKTUALITÄT
  // ═══════════════════════════════════════════════════════════
  
  /// Events auf der Karte anzeigen
  static const bool enableEventsOnMap = true;
  
  /// "Diese Woche" Widget
  static const bool enableEventsWidget = true;
  
  /// Hinweise/Warnungen Banner
  static const bool enableNoticesBanner = true;
  
  /// Prognose "Wird es voll?"
  static const bool enableCrowdPrediction = false; // Später aktivieren
  
  // ═══════════════════════════════════════════════════════════
  // MOBILITÄT
  // ═══════════════════════════════════════════════════════════
  
  /// ÖPNV-Verbindungen Link
  static const bool enablePublicTransport = true;
  
  /// E-Ladesäulen Layer
  static const bool enableChargingStations = true;
  
  /// Offline-Karten Download
  static const bool enableOfflineMaps = false; // Später aktivieren
  
  // ═══════════════════════════════════════════════════════════
  // KARTEN-LAYER
  // ═══════════════════════════════════════════════════════════
  
  /// Naturschutzgebiete anzeigen
  static const bool enableNatureProtectionLayer = true;
  
  /// Heatmap-Ansicht
  static const bool enableHeatmapLayer = false; // Später aktivieren
  
  // ═══════════════════════════════════════════════════════════
  // COMMUNITY
  // ═══════════════════════════════════════════════════════════
  
  /// "Fehlt etwas?" Ort vorschlagen
  static const bool enableSuggestLocation = true;
  
  /// Problem/Gefahr melden
  static const bool enableReportIssue = true;
  
  /// Anonyme Bewertungen
  static const bool enableRatings = false; // Später aktivieren
  
  /// "Ich war da" Check-ins
  static const bool enableCheckIns = false; // Später aktivieren
  
  /// Foto-Uploads
  static const bool enablePhotoUploads = false; // Später aktivieren
  
  // ═══════════════════════════════════════════════════════════
  // MARKTPLATZ
  // ═══════════════════════════════════════════════════════════
  
  /// Flohmarkt/Marketplace
  static const bool enableMarketplace = true;
  
  /// Anzeige erstellen (sonst nur ansehen)
  static const bool enableMarketplaceCreate = true;
  
  // ═══════════════════════════════════════════════════════════
  // DASHBOARD & ANALYTICS
  // ═══════════════════════════════════════════════════════════
  
  /// "MSH in Zahlen" Dashboard
  static const bool enableDashboard = true;
  
  /// Lücken-Analyse anzeigen
  static const bool enableGapAnalysis = true;
  
  /// Insights anzeigen
  static const bool enableInsights = true;
  
  // ═══════════════════════════════════════════════════════════
  // EXPERIMENTAL
  // ═══════════════════════════════════════════════════════════
  
  /// Debug-Modus (zeigt extra Infos)
  static const bool enableDebugMode = false;
  
  /// Beta-Features Banner
  static const bool showBetaBanner = false;
}
```

### Verwendung im Code

```dart
// In Widgets:
if (FeatureFlags.enableWeather) {
  WeatherWidget(),
}

// In Navigation:
if (FeatureFlags.enableMarketplace) {
  GoRoute(path: '/marketplace', ...),
}

// In der Sidebar:
if (FeatureFlags.enableDashboard) {
  ListTile(title: Text('MSH in Zahlen'), ...),
}
```

### Feature-Flag Konfigurationsdatei (Optional)

Für noch flexiblere Steuerung ohne Rebuild:

```json
// assets/config/features.json
{
  "enableWeather": true,
  "enableEventsOnMap": true,
  "enableOfflineMaps": false,
  "enableRatings": false
}
```

```dart
// Laden zur Laufzeit:
class RemoteFeatureFlags {
  static Map<String, bool> _flags = {};
  
  static Future<void> load() async {
    final json = await rootBundle.loadString('assets/config/features.json');
    _flags = Map<String, bool>.from(jsonDecode(json));
  }
  
  static bool isEnabled(String flag) => _flags[flag] ?? false;
}
```

---

## Melde-System (Anonym)

### Zwei Melde-Typen

#### 1. "Fehlt etwas?" - Ort vorschlagen
```
Nutzer markiert Punkt auf Karte
     ↓
Wählt Kategorie (Spielplatz, Museum, etc.)
     ↓
Schreibt Beschreibung
     ↓
mailto: Link öffnet E-Mail an feedback@kolan-systems.de
     ↓
Du prüfst und fügst hinzu
```

#### 2. "Problem melden" - Gefahren/Issues
```
Nutzer ist bei einem Ort
     ↓
Klickt "Problem melden"
     ↓
Wählt Problem-Typ:
  - ⚠️ Gefahr (kaputtes Spielgerät, Glasscherben)
  - 🚧 Geschlossen/Baustelle
  - ❌ Existiert nicht mehr
  - 📍 Falsche Position
  - 📝 Falsche Infos
     ↓
Optionale Beschreibung
     ↓
mailto: Link mit Ort-ID, Problem-Typ, Beschreibung
     ↓
Du prüfst und aktualisierst
```

### Implementation

```dart
// lib/src/features/feedback/presentation/report_issue_sheet.dart

class ReportIssueSheet extends StatefulWidget {
  final Location location;
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      child: Column(
        children: [
          Text('Problem melden', style: titleStyle),
          Text('Ort: ${location.name}'),
          
          Divider(),
          
          // Problem-Typen
          _IssueTypeButton(
            icon: Icons.warning,
            color: Colors.red,
            label: 'Gefahr/Sicherheit',
            type: 'danger',
          ),
          _IssueTypeButton(
            icon: Icons.construction,
            color: Colors.orange,
            label: 'Geschlossen/Baustelle',
            type: 'closed',
          ),
          _IssueTypeButton(
            icon: Icons.delete_forever,
            color: Colors.grey,
            label: 'Existiert nicht mehr',
            type: 'removed',
          ),
          _IssueTypeButton(
            icon: Icons.location_off,
            color: Colors.blue,
            label: 'Falsche Position',
            type: 'wrong_location',
          ),
          _IssueTypeButton(
            icon: Icons.edit,
            color: Colors.purple,
            label: 'Falsche Informationen',
            type: 'wrong_info',
          ),
          
          // Beschreibung (optional)
          TextField(
            decoration: InputDecoration(
              hintText: 'Beschreibe das Problem (optional)...',
            ),
            maxLines: 3,
          ),
          
          // Absenden
          ElevatedButton.icon(
            icon: Icon(Icons.send),
            label: Text('Per E-Mail melden'),
            onPressed: _sendReport,
          ),
          
          // Info
          Text(
            'Deine Meldung ist anonym. '
            'Wir prüfen sie und aktualisieren die Karte.',
            style: captionStyle,
          ),
        ],
      ),
    );
  }
  
  void _sendReport() {
    final subject = 'MSH Map Problem: ${_selectedType} - ${location.name}';
    final body = '''
Problem-Meldung für MSH Map
===========================

Ort: ${location.name}
ID: ${location.id}
Koordinaten: ${location.latitude}, ${location.longitude}

Problem-Typ: ${_selectedType}

Beschreibung:
${_descriptionController.text.isNotEmpty ? _descriptionController.text : '(Keine Beschreibung)'}

---
Gesendet über MSH Map App
''';
    
    launchUrl(Uri.parse(
      'mailto:feedback@kolan-systems.de'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}'
    ));
  }
}
```

---

## Daten-Quellen (Nur Open Source)

### Karten & Geodaten

| Quelle | Verwendung | Lizenz |
|--------|------------|--------|
| **OpenStreetMap** | Kartentiles, POIs | ODbL |
| **Overpass API** | POI-Abfragen | Frei |
| **Nominatim** | Geocoding | Frei (Rate Limit) |

### Wetter

| Quelle | Verwendung | Lizenz |
|--------|------------|--------|
| **Open-Meteo** | Aktuelles Wetter, Vorhersage | Frei, kein API-Key |

### ÖPNV

| Quelle | Verwendung | Lizenz |
|--------|------------|--------|
| **INSA** | Verbindungsauskunft (nur Link) | - |
| **GTFS** | Optional: Haltestellen | Open Data |

### Veranstaltungen

| Quelle | Verwendung | Methode |
|--------|------------|---------|
| **MZ Events** | Konzerte, Theater | Radar-Scan |
| **Gemeinde-Websites** | Lokale Events | Radar-Scan |
| **Harz-Tourismus** | Regionale Events | Radar-Scan |

---

## Wöchentlicher Workflow

### MSH Radar (jeden Sonntag/Montag)

```
18:00  VS Code öffnen
       Claude Code starten
       "MSH Radar starten" eingeben
       
       ┌─────────────────────────────┐
       │  ☕ PAUSE (20-30 Min)       │
       │  Claude recherchiert:       │
       │  - Neue Events              │
       │  - Hinweise/Warnungen       │
       │  - Orts-Updates             │
       │  - Wetter-Prognose          │
       └─────────────────────────────┘
       
18:30  Ergebnis prüfen
       Report lesen
       
18:35  "Freigabe!"
       
18:36  vercel --prod
       
18:40  ✅ Fertig für diese Woche!
```

### Was Claude im Radar macht

1. **Events recherchieren** (15 Min)
   - MZ, Sangerhausen.de, Eisleben.eu, Harzinfo
   - Nächste 14 Tage
   - JSON generieren

2. **Hinweise sammeln** (5 Min)
   - Straßensperrungen
   - Sonderöffnungszeiten
   - Warnungen

3. **Prognose erstellen** (2 Min)
   - Wetter + Wochentag + Ferienzeit
   - "Süßer See wird voll"

4. **Daten zusammenführen** (3 Min)
   - JSON-Dateien aktualisieren
   - Report erstellen

5. **Build vorbereiten**
   - `flutter build web --release`
   - Auf "Freigabe!" warten

---

## Datei-Struktur

### Projekt-Übersicht

```
msh_map/
├── lib/
│   └── src/
│       ├── core/
│       │   ├── config/
│       │   │   ├── app_config.dart
│       │   │   └── feature_flags.dart      ← Feature-Toggles
│       │   ├── theme/
│       │   │   ├── msh_colors.dart
│       │   │   └── msh_theme.dart
│       │   └── mocks/
│       │       ├── mock_data.dart
│       │       └── mock_repository.dart
│       │
│       ├── shared/
│       │   └── widgets/
│       │       ├── map/
│       │       │   ├── msh_map_view.dart
│       │       │   ├── fog_of_war_layer.dart
│       │       │   └── event_markers.dart
│       │       └── common/
│       │
│       └── features/
│           ├── home/
│           ├── map/
│           ├── events/                      ← Events-Feature
│           ├── weather/                     ← Wetter-Feature
│           ├── feedback/                    ← Meldungen
│           ├── marketplace/
│           ├── dashboard/
│           └── settings/
│
├── data/                                    ← Statische Daten
│   ├── locations.json
│   ├── events/
│   │   └── events_current.json
│   └── notices/
│       └── notices_current.json
│
├── assets/
│   ├── images/
│   ├── fonts/                               ← Selbst gehostet!
│   └── config/
│       └── features.json                    ← Optional: Remote Flags
│
├── reports/                                 ← Radar-Reports
│   └── RADAR_REPORT_YYYY-MM-DD.md
│
└── prompts/                                 ← Claude-Prompts
    └── MSH_RADAR_PROMPT.md
```

### Dokumentation (diese Dateien)

```
msh_migration/
├── 00_OVERVIEW.md              ← Projekt-Überblick
├── 01_ARCHITECTURE.md          ← Technische Architektur
├── 02_CORE_INTERFACES.md       ← Datenmodelle
├── 03-08_PHASES.md             ← Entwicklungsphasen
├── 10_CI_THEME.md              ← Corporate Identity
├── 11_BRANDING_ABOUT.md        ← Branding & Über-Seite
├── 12_APP_STRINGS.md           ← Alle Texte
├── 13_MODULE_MARKETPLACE.md    ← Flohmarkt-Modul
├── 14_UX_IMPROVEMENTS.md       ← UX-Verbesserungen
├── 22_REGIONAL_INSIGHTS.md     ← Dashboard-Konzept
├── 23_DASHBOARD_FLUTTER.md     ← Dashboard-Code
├── 24_CLOUD_FUNCTIONS.md       ← Firebase Functions
├── 25_COMMUNITY_FOG.md         ← Community + Fog of War
├── 26_MSH_POLYGON_DATA.md      ← MSH Grenzen
├── 27_FINAL_TEST_DEPLOY.md     ← Test & Deploy Prompt
├── 28_MSH_RADAR_WEEKLY.md      ← Wöchentlicher Scan
├── 29_ADDONS_ROADMAP.md        ← Feature-Roadmap
├── 30_COMPLETE_SUMMARY.md      ← DIESE DATEI
│
├── deepscan/                   ← Daten-Scraping System
│   ├── 15-21_*.py/md
│   └── requirements.txt
│
├── scraping/                   ← Legacy Scraper
│   └── msh_scraper.py
│
└── prompts/
    └── MSH_RADAR_PROMPT.md     ← Wöchentlicher Scan
```

---

## Roadmap

### Version 1.0 ✅ (Aktuell)
- Interaktive Karte
- Fog of War
- Kategorien-Filter
- Ort-Details
- Flohmarkt
- Dashboard
- "Fehlt etwas?"

### Version 1.1 📋 (Nächste)
- [ ] Feature-Flag System
- [ ] Altersgerechter Filter
- [ ] Events auf Karte + Widget
- [ ] Wetter-Integration (Open-Meteo)
- [ ] ÖPNV-Links (INSA)
- [ ] Problem-Melde-Feature

### Version 1.2 📋 (Danach)
- [ ] Offline-Karten
- [ ] Naturschutzgebiete Layer
- [ ] E-Ladesäulen
- [ ] Prognose "Wird es voll?"

### Version 1.3 📋 (Später)
- [ ] Anonyme Bewertungen
- [ ] "Ich war da" Check-ins
- [ ] Foto-Uploads (mit Moderation)

### Version 2.0 🔮 (Zukunft)
- [ ] Native Apps (iOS/Android)
- [ ] Homescreen Widget
- [ ] Geocaching/Schnitzeljagd
- [ ] KI-Reiseführer

---

## Datenschutz-Checkliste

```
✅ Keine Cookies
✅ Keine Nutzer-Accounts (optional später)
✅ Keine externen Tracker
✅ OpenStreetMap statt Google Maps
✅ Open-Meteo statt Google Weather
✅ Fonts selbst gehostet
✅ Keine Embeds (nur Links)
✅ Anonyme Meldungen/Feedback
✅ localStorage für Einstellungen (kein Cookie)
✅ Alle Daten lokal oder selbst gehostet
✅ DSGVO-konform ohne Cookie-Banner
```

---

## Kontakt & Links

**Entwickler:** KOLAN Systems
**Kontakt:** feedback@kolan-systems.de
**Region:** Mansfeld-Südharz, Sachsen-Anhalt

**Hosting:** Vercel
**Repository:** (privat)
**Domain:** (deine Domain)

---

## Schnellstart für Entwicklung

```bash
# 1. Projekt klonen
git clone [repo]
cd msh_map

# 2. Dependencies
flutter pub get

# 3. Entwicklungsserver
flutter run -d chrome --web-port=8080

# 4. Production Build
flutter build web --release --web-renderer canvaskit

# 5. Deploy
cd build/web
vercel --prod
```

---

## Wöchentliche Wartung

```bash
# Jeden Sonntag/Montag:

# 1. Claude Code starten
# 2. Prompt eingeben: "MSH Radar starten"
# 3. 20-30 Min warten
# 4. Report prüfen
# 5. "Freigabe!" sagen
# 6. Deploy:
cd build/web && vercel --prod
```

---

## Zusammenfassung

**MSH Map** ist eine datenschutzfreundliche, familienorientierte Karten-App für die Region Mansfeld-Südharz. Sie zeigt Ausflugsziele, Veranstaltungen und lokale Informationen - komplett ohne Cookies und Tracking.

**Kernprinzipien:**
1. **Privacy First** - Keine Cookies, keine Tracker
2. **Open Source** - OSM, Open-Meteo, selbst gehostet
3. **Familie First** - Altersgerechte Empfehlungen
4. **Community** - Nutzer können anonym beitragen
5. **Aktuell** - Wöchentliche Updates via MSH Radar
6. **Flexibel** - Feature-Flags für einfache Steuerung

**Aufwand:**
- Einmalig: App entwickeln und deployen
- Wöchentlich: ~30 Min Radar-Scan + Deploy
- Bei Bedarf: Gemeldete Probleme prüfen

**Ziel:**
> Die beste Informationsquelle für Familien in Mansfeld-Südharz werden.
