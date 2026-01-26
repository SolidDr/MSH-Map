# PROMPT 06: FINALER SYSTEM-TEST

## Kontext

Du hast die MSH Map App mit folgenden Features implementiert:
- Feature-Flag System
- Altersfilter
- Wetter-Integration
- Events auf Karte + Widget
- ÖPNV-Links
- Problem melden
- Fog of War
- Kategorien-Filter
- Flohmarkt
- Dashboard

Jetzt testen wir ALLES systematisch.

---

## TEIL 1: AUTOMATISIERTE TESTS

### 1.1 Projekt-Gesundheitscheck

Führe folgende Befehle aus und behebe alle Fehler:

```bash
# 1. Dependencies aktuell?
flutter pub get

# 2. Analyzer - KEINE Errors erlaubt
flutter analyze

# 3. Formatierung
dart format lib/ --set-exit-if-changed || echo "Formatierung nötig"

# 4. Build-Test Web
flutter build web --release

# 5. Freezed Models generiert?
dart run build_runner build --delete-conflicting-outputs
```

**Erwartung:** Alle Befehle ohne Errors. Warnings sind okay, Errors nicht.

Wenn Fehler auftreten:
1. Lies die Fehlermeldung
2. Behebe den Fehler
3. Führe den Befehl erneut aus
4. Wiederhole bis fehlerfrei

### 1.2 Import-Check

Prüfe ob alle Imports korrekt sind:

```bash
# Suche nach fehlenden Imports
grep -r "import.*feature_flags" lib/ || echo "Feature Flags Import fehlt irgendwo"
grep -r "import.*age_filter" lib/ || echo "Age Filter Imports prüfen"
grep -r "import.*weather" lib/ || echo "Weather Imports prüfen"
grep -r "import.*events" lib/ || echo "Events Imports prüfen"
```

### 1.3 Feature-Flags Vollständigkeit

Prüfe ob alle Feature-Flags definiert sind:

```dart
// In feature_flags.dart sollten mindestens diese existieren:
// CORE
- enableMap
- enableFogOfWar
- enableCategoryFilter
- enableSearch

// FAMILY
- enableAgeFilter
- enableWeather
- enableFamilyBadges

// EVENTS
- enableEventsOnMap
- enableEventsWidget
- enableNoticesBanner

// MOBILITÄT
- enablePublicTransport
- enableChargingStations
- enableOfflineMaps

// COMMUNITY
- enableSuggestLocation
- enableReportIssue
- enableRatings
- enableCheckIns

// MARKTPLATZ
- enableMarketplace
- enableMarketplaceCreate

// DASHBOARD
- enableDashboard
- enableGapAnalysis
- enableInsights
```

Falls Flags fehlen, füge sie hinzu.

---

## TEIL 2: FEATURE-FLAG TOGGLE-TEST

Teste ob Features korrekt ein/ausgeschaltet werden können.

### 2.1 Alle Features AUS

Setze in `feature_flags.dart` ALLE optionalen Features auf `false`:

```dart
static const bool enableFogOfWar = false;
static const bool enableAgeFilter = false;
static const bool enableWeather = false;
static const bool enableEventsOnMap = false;
static const bool enableEventsWidget = false;
static const bool enablePublicTransport = false;
static const bool enableReportIssue = false;
static const bool enableMarketplace = false;
static const bool enableDashboard = false;
// ... alle anderen auch false
```

Starte die App:
```bash
flutter run -d chrome --web-port=8080
```

**Prüfe:**
- [ ] App startet ohne Fehler
- [ ] Karte wird angezeigt (Grundfunktion)
- [ ] Kein Fog of War sichtbar
- [ ] Keine Altersfilter-Chips
- [ ] Kein Wetter-Widget
- [ ] Keine Event-Marker
- [ ] Kein "Problem melden" Button
- [ ] Kein Flohmarkt im Menü
- [ ] Kein Dashboard im Menü

**Ergebnis:** App funktioniert mit minimalen Features ✓

### 2.2 Alle Features AN

Setze ALLE Features auf `true`:

```dart
static const bool enableFogOfWar = true;
static const bool enableAgeFilter = true;
static const bool enableWeather = true;
// ... alle true
```

Hot Reload oder Neustart.

**Prüfe:**
- [ ] App startet ohne Fehler
- [ ] Alle Features sichtbar
- [ ] Keine Überlappungen in der UI
- [ ] Performance akzeptabel

---

## TEIL 3: EINZELNE FEATURE-TESTS

### 3.1 Karte & Grundfunktionen

```
TEST: Karte laden
├── Aktion: App starten
├── Erwartung: OSM-Karte lädt, zentriert auf MSH
└── Status: [ ] OK  [ ] FEHLER

TEST: Zoom
├── Aktion: Mausrad / Pinch / Zoom-Buttons
├── Erwartung: Smooth Zoom, keine Ruckler
└── Status: [ ] OK  [ ] FEHLER

TEST: Pan/Drag
├── Aktion: Karte verschieben
├── Erwartung: Smooth, keine Verzögerung
└── Status: [ ] OK  [ ] FEHLER

TEST: Marker anzeigen
├── Aktion: Karte ansehen
├── Erwartung: Marker für Orte sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: Marker antippen
├── Aktion: Auf Marker tippen
├── Erwartung: Detail-Sheet öffnet sich
└── Status: [ ] OK  [ ] FEHLER
```

### 3.2 Fog of War

```
TEST: Nebel sichtbar
├── Aktion: Karte auf MSH-Rand bewegen
├── Erwartung: Außenbereich ist neblig/dunkel
└── Status: [ ] OK  [ ] FEHLER

TEST: MSH-Zentrum klar
├── Aktion: Zu Sangerhausen zoomen
├── Erwartung: Kein Nebel im Zentrum
└── Status: [ ] OK  [ ] FEHLER

TEST: Nebel bei Zoom
├── Aktion: Weit herauszoomen
├── Erwartung: Nebel bleibt sichtbar, Performance okay
└── Status: [ ] OK  [ ] FEHLER
```

### 3.3 Altersfilter

```
TEST: Chips sichtbar
├── Aktion: Karte öffnen
├── Erwartung: Altersfilter-Chips über der Karte
└── Status: [ ] OK  [ ] FEHLER

TEST: "Alle" Standard
├── Aktion: Nichts tun
├── Erwartung: "Alle" ist vorausgewählt
└── Status: [ ] OK  [ ] FEHLER

TEST: Filter auswählen
├── Aktion: "Kind (6-11)" antippen
├── Erwartung: Chip wird aktiv, Marker werden gefiltert
└── Status: [ ] OK  [ ] FEHLER

TEST: Mehrfachauswahl
├── Aktion: "Kleinkind" + "Kind" auswählen
├── Erwartung: Beide aktiv, Orte für beide Gruppen sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: Filter zurücksetzen
├── Aktion: "Alle" antippen
├── Erwartung: Alle Marker wieder sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: Korrektes Filtering
├── Aktion: "Baby (0-2)" auswählen
├── Erwartung: Nur Orte mit ageRange die 0-2 einschließt
└── Status: [ ] OK  [ ] FEHLER
```

### 3.4 Wetter

```
TEST: Widget lädt
├── Aktion: Startseite/Home öffnen
├── Erwartung: Wetter-Widget zeigt Daten
└── Status: [ ] OK  [ ] FEHLER

TEST: Temperatur angezeigt
├── Aktion: Widget ansehen
├── Erwartung: Temperatur in °C sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: Emoji passend
├── Aktion: Widget ansehen
├── Erwartung: Wetter-Emoji passt (☀️ bei Sonne, 🌧️ bei Regen)
└── Status: [ ] OK  [ ] FEHLER

TEST: Empfehlung vorhanden
├── Aktion: Widget ansehen
├── Erwartung: Indoor/Outdoor Empfehlung sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: Badge in Header
├── Aktion: AppBar ansehen
├── Erwartung: Kompaktes Wetter-Badge (falls implementiert)
└── Status: [ ] OK  [ ] FEHLER

TEST: Offline-Fallback
├── Aktion: Internet trennen, App neu laden
├── Erwartung: Fallback-Wetter oder leeres Widget, kein Crash
└── Status: [ ] OK  [ ] FEHLER
```

### 3.5 Events

```
TEST: Event-Marker auf Karte
├── Aktion: Karte ansehen
├── Erwartung: Event-Marker sichtbar (farbige Kreise)
└── Status: [ ] OK  [ ] FEHLER

TEST: Event-Marker Farben
├── Aktion: Verschiedene Events ansehen
├── Erwartung: Farben nach Kategorie (lila=Konzert, orange=Markt, etc.)
└── Status: [ ] OK  [ ] FEHLER

TEST: Event antippen
├── Aktion: Auf Event-Marker tippen
├── Erwartung: Event-Detail-Sheet öffnet sich
└── Status: [ ] OK  [ ] FEHLER

TEST: Event-Details vollständig
├── Aktion: Detail-Sheet ansehen
├── Erwartung: Name, Datum, Zeit, Ort, Preis sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: "Diese Woche" Widget
├── Aktion: Startseite öffnen
├── Erwartung: Events-Widget mit kommenden Events
└── Status: [ ] OK  [ ] FEHLER

TEST: Events nach Datum gruppiert
├── Aktion: Widget ansehen
├── Erwartung: "Heute", "Morgen", Wochentage als Überschriften
└── Status: [ ] OK  [ ] FEHLER

TEST: Event-Karten scrollbar
├── Aktion: Horizontal durch Events wischen
├── Erwartung: Smooth Scrolling
└── Status: [ ] OK  [ ] FEHLER
```

### 3.6 ÖPNV

```
TEST: Button sichtbar
├── Aktion: Ort-Details öffnen
├── Erwartung: "ÖPNV-Verbindung" Button sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: INSA öffnet
├── Aktion: Button antippen
├── Erwartung: INSA Website öffnet sich (neuer Tab)
└── Status: [ ] OK  [ ] FEHLER

TEST: Ziel vorausgefüllt
├── Aktion: INSA URL prüfen
├── Erwartung: Ziel-Feld enthält Ort-Namen
└── Status: [ ] OK  [ ] FEHLER
```

### 3.7 Problem melden

```
TEST: Button sichtbar
├── Aktion: Ort-Details öffnen
├── Erwartung: "Problem melden" Link/Button sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: Sheet öffnet
├── Aktion: "Problem melden" antippen
├── Erwartung: Report-Sheet öffnet sich
└── Status: [ ] OK  [ ] FEHLER

TEST: Problem-Typen sichtbar
├── Aktion: Sheet ansehen
├── Erwartung: 6 Problem-Typen (Gefahr, Geschlossen, etc.)
└── Status: [ ] OK  [ ] FEHLER

TEST: Typ auswählen
├── Aktion: "Gefahr / Sicherheit" antippen
├── Erwartung: Typ wird markiert
└── Status: [ ] OK  [ ] FEHLER

TEST: Beschreibung eingeben
├── Aktion: Text in Beschreibungsfeld eingeben
├── Erwartung: Text wird angenommen
└── Status: [ ] OK  [ ] FEHLER

TEST: E-Mail senden
├── Aktion: "Per E-Mail melden" antippen
├── Erwartung: E-Mail-App öffnet sich
└── Status: [ ] OK  [ ] FEHLER

TEST: E-Mail-Inhalt korrekt
├── Aktion: E-Mail prüfen
├── Erwartung: Ort-Name, ID, Koordinaten, Problem-Typ, Beschreibung enthalten
└── Status: [ ] OK  [ ] FEHLER

TEST: Anonym
├── Aktion: E-Mail prüfen
├── Erwartung: KEINE Nutzer-ID oder persönliche Daten
└── Status: [ ] OK  [ ] FEHLER
```

### 3.8 Kategorien-Filter

```
TEST: Filter sichtbar
├── Aktion: Karte öffnen
├── Erwartung: Kategorie-Filter (Dropdown oder Chips)
└── Status: [ ] OK  [ ] FEHLER

TEST: Kategorie auswählen
├── Aktion: "Spielplätze" auswählen
├── Erwartung: Nur Spielplatz-Marker sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: Filter zurücksetzen
├── Aktion: "Alle" auswählen
├── Erwartung: Alle Marker wieder sichtbar
└── Status: [ ] OK  [ ] FEHLER
```

### 3.9 Navigation & Menü

```
TEST: Menü öffnen
├── Aktion: Hamburger-Icon / Sidebar antippen
├── Erwartung: Menü öffnet sich
└── Status: [ ] OK  [ ] FEHLER

TEST: Menüpunkte vorhanden
├── Aktion: Menü ansehen
├── Erwartung: Karte, Flohmarkt, Dashboard, Über, Fehlt etwas?
└── Status: [ ] OK  [ ] FEHLER

TEST: Navigation funktioniert
├── Aktion: Jeden Menüpunkt antippen
├── Erwartung: Jeweilige Seite lädt ohne Fehler
└── Status: [ ] OK  [ ] FEHLER

TEST: Zurück-Navigation
├── Aktion: Zurück-Button / Browser-Back
├── Erwartung: Korrekte Navigation zurück
└── Status: [ ] OK  [ ] FEHLER
```

### 3.10 "Fehlt etwas?" (Ort vorschlagen)

```
TEST: Menüpunkt vorhanden
├── Aktion: Menü öffnen
├── Erwartung: "Fehlt etwas?" Eintrag sichtbar
└── Status: [ ] OK  [ ] FEHLER

TEST: Screen öffnet
├── Aktion: Menüpunkt antippen
├── Erwartung: Karte mit Anleitung öffnet sich
└── Status: [ ] OK  [ ] FEHLER

TEST: Pin setzen
├── Aktion: Auf Karte tippen
├── Erwartung: Pin erscheint an der Stelle
└── Status: [ ] OK  [ ] FEHLER

TEST: Formular erscheint
├── Aktion: Pin setzen
├── Erwartung: Formular-Sheet erscheint
└── Status: [ ] OK  [ ] FEHLER

TEST: Kategorie wählbar
├── Aktion: Formular ansehen
├── Erwartung: Kategorie-Auswahl vorhanden
└── Status: [ ] OK  [ ] FEHLER

TEST: E-Mail senden
├── Aktion: Ausfüllen und Absenden
├── Erwartung: E-Mail-App öffnet mit Koordinaten
└── Status: [ ] OK  [ ] FEHLER
```

### 3.11 Flohmarkt/Marketplace

```
TEST: Seite öffnet
├── Aktion: Flohmarkt im Menü antippen
├── Erwartung: Marketplace-Seite lädt
└── Status: [ ] OK  [ ] FEHLER

TEST: Anzeigen sichtbar
├── Aktion: Seite ansehen
├── Erwartung: Anzeigen werden geladen (Mock-Daten)
└── Status: [ ] OK  [ ] FEHLER

TEST: Anzeige-Details
├── Aktion: Auf Anzeige tippen
├── Erwartung: Detail-Ansicht öffnet sich
└── Status: [ ] OK  [ ] FEHLER

TEST: Filter (falls vorhanden)
├── Aktion: Kategorie-Filter nutzen
├── Erwartung: Anzeigen werden gefiltert
└── Status: [ ] OK  [ ] FEHLER
```

### 3.12 Dashboard

```
TEST: Seite öffnet
├── Aktion: "MSH in Zahlen" im Menü antippen
├── Erwartung: Dashboard lädt
└── Status: [ ] OK  [ ] FEHLER

TEST: Statistiken sichtbar
├── Aktion: Dashboard ansehen
├── Erwartung: Karten mit Zahlen (Orte, Spielplätze, etc.)
└── Status: [ ] OK  [ ] FEHLER

TEST: Charts sichtbar
├── Aktion: Dashboard scrollen
├── Erwartung: Kategorie-Verteilung, Städte-Vergleich
└── Status: [ ] OK  [ ] FEHLER
```

---

## TEIL 4: RESPONSIVE DESIGN

### 4.1 Desktop (> 1200px)

```bash
# Browser-Fenster maximieren
```

**Prüfe:**
- [ ] Sidebar sichtbar (nicht Hamburger)
- [ ] Karte nutzt vollen Platz
- [ ] Keine Overflow-Fehler
- [ ] Alle Widgets richtig angeordnet

### 4.2 Tablet (768px - 1200px)

```bash
# Browser-Fenster auf ~900px Breite
```

**Prüfe:**
- [ ] Layout passt sich an
- [ ] Sidebar oder Hamburger (je nach Design)
- [ ] Filter-Chips umbrechen korrekt
- [ ] Karten-Widgets passen

### 4.3 Mobile (< 768px)

```bash
# Browser-Fenster auf ~400px Breite
# Oder: Chrome DevTools → Mobile View
```

**Prüfe:**
- [ ] Hamburger-Menü statt Sidebar
- [ ] Bottom-Navigation (falls vorhanden)
- [ ] Alle Inhalte erreichbar
- [ ] Keine horizontalen Scrollbars
- [ ] Touch-freundliche Buttons (min 44px)

---

## TEIL 5: PERFORMANCE-TEST

### 5.1 Ladezeit

```
TEST: Initiales Laden
├── Aktion: App im Inkognito-Fenster öffnen
├── Messen: Zeit bis Karte sichtbar
├── Erwartung: < 3 Sekunden
└── Status: [ ] OK  [ ] ZU LANGSAM

TEST: Navigation
├── Aktion: Zwischen Seiten wechseln
├── Erwartung: Sofort, keine Verzögerung
└── Status: [ ] OK  [ ] ZU LANGSAM
```

### 5.2 Speicher

```
TEST: Memory Leaks
├── Aktion: 5 Minuten navigieren, Seiten wechseln
├── Prüfen: Browser DevTools → Memory
├── Erwartung: Speicher bleibt stabil
└── Status: [ ] OK  [ ] LEAK
```

### 5.3 Karten-Performance

```
TEST: Viele Marker
├── Aktion: Auf Zoom-Level mit vielen Markern
├── Erwartung: Karte bleibt flüssig
└── Status: [ ] OK  [ ] RUCKLER
```

---

## TEIL 6: ERROR HANDLING

### 6.1 Netzwerk-Fehler

```
TEST: Offline-Modus
├── Aktion: Internet trennen, App nutzen
├── Erwartung: Sinnvolle Fehlermeldungen, kein Crash
└── Status: [ ] OK  [ ] CRASH

TEST: API-Fehler Wetter
├── Aktion: Open-Meteo blockieren (DevTools)
├── Erwartung: Fallback oder leeres Widget
└── Status: [ ] OK  [ ] CRASH
```

### 6.2 Fehlende Daten

```
TEST: Keine Events
├── Aktion: Leere events_current.json
├── Erwartung: "Keine Events" Anzeige
└── Status: [ ] OK  [ ] CRASH

TEST: Fehlende Bilder
├── Aktion: Ort ohne Bild-URL
├── Erwartung: Placeholder-Bild
└── Status: [ ] OK  [ ] BROKEN
```

---

## TEIL 7: DATENSCHUTZ-CHECK

### 7.1 Keine Cookies

```
TEST: Cookie-Check
├── Aktion: Browser DevTools → Application → Cookies
├── Erwartung: KEINE Cookies von der App
└── Status: [ ] OK  [ ] COOKIES GEFUNDEN

Falls Cookies gefunden:
- Welche Domain?
- Was für Cookies?
- Entfernen oder ersetzen!
```

### 7.2 Keine externen Tracker

```
TEST: Netzwerk-Check
├── Aktion: DevTools → Network → alle Requests prüfen
├── Erwartung: Nur erlaubte Domains:
│   ✓ tile.openstreetmap.org (Karten)
│   ✓ api.open-meteo.com (Wetter)
│   ✓ Eigene Domain
│   ✗ KEINE Google, Facebook, etc.
└── Status: [ ] OK  [ ] TRACKER GEFUNDEN

Falls Tracker gefunden:
- Welche Domain?
- Wofür?
- ENTFERNEN!
```

### 7.3 localStorage (erlaubt)

```
TEST: localStorage-Nutzung
├── Aktion: DevTools → Application → Local Storage
├── Erwartung: Nur App-eigene Daten (Einstellungen)
├── KEIN: Tracking, Fingerprinting, User-IDs
└── Status: [ ] OK  [ ] PRÜFEN
```

### 7.4 Anonyme Meldungen

```
TEST: E-Mail-Inhalt prüfen
├── Aktion: Problem melden, E-Mail ansehen
├── Erwartung: KEINE User-ID, Device-ID, IP-Adresse
└── Status: [ ] OK  [ ] NICHT ANONYM
```

---

## TEIL 8: BROWSER-KOMPATIBILITÄT

Teste in mindestens 2 Browsern:

### 8.1 Chrome

```
Version: [aktuelle]
├── App lädt: [ ] OK
├── Karte funktioniert: [ ] OK
├── Alle Features: [ ] OK
└── Performance: [ ] OK
```

### 8.2 Firefox

```
Version: [aktuelle]
├── App lädt: [ ] OK
├── Karte funktioniert: [ ] OK
├── Alle Features: [ ] OK
└── Performance: [ ] OK
```

### 8.3 Safari (falls Mac)

```
Version: [aktuelle]
├── App lädt: [ ] OK
├── Karte funktioniert: [ ] OK
├── Alle Features: [ ] OK
└── Performance: [ ] OK
```

### 8.4 Mobile Browser

```
Chrome Mobile (Android):
├── App lädt: [ ] OK
├── Touch funktioniert: [ ] OK
└── Alle Features: [ ] OK

Safari Mobile (iOS):
├── App lädt: [ ] OK
├── Touch funktioniert: [ ] OK
└── Alle Features: [ ] OK
```

---

## TEIL 9: ABSCHLUSS-REPORT

Erstelle einen Report mit dem Status aller Tests:

```markdown
# MSH Map - Test-Report

**Datum:** [DATUM]
**Version:** 1.1.0
**Tester:** Claude Code

## Zusammenfassung

| Bereich | Tests | Bestanden | Fehlgeschlagen |
|---------|-------|-----------|----------------|
| Karte & Grundfunktionen | 5 | ? | ? |
| Fog of War | 3 | ? | ? |
| Altersfilter | 6 | ? | ? |
| Wetter | 6 | ? | ? |
| Events | 7 | ? | ? |
| ÖPNV | 3 | ? | ? |
| Problem melden | 8 | ? | ? |
| Kategorien-Filter | 3 | ? | ? |
| Navigation | 4 | ? | ? |
| Ort vorschlagen | 6 | ? | ? |
| Flohmarkt | 4 | ? | ? |
| Dashboard | 3 | ? | ? |
| Responsive | 3 | ? | ? |
| Performance | 3 | ? | ? |
| Error Handling | 4 | ? | ? |
| Datenschutz | 4 | ? | ? |
| Browser-Kompatibilität | 4 | ? | ? |
| **GESAMT** | **76** | **?** | **?** |

## Kritische Fehler

[Liste aller kritischen Fehler die behoben werden müssen]

## Warnungen

[Liste aller Warnungen/kleineren Issues]

## Empfehlungen

[Verbesserungsvorschläge]

## Fazit

[ ] ✅ FREIGABE - Alle Tests bestanden
[ ] ⚠️ BEDINGTE FREIGABE - Kleinere Issues
[ ] ❌ NICHT FREIGABE - Kritische Fehler
```

---

## TEIL 10: NACH DEM TEST

### Bei FREIGABE:

```bash
# 1. Finale Build erstellen
flutter build web --release --web-renderer canvaskit

# 2. Build-Größe prüfen
du -sh build/web/

# 3. Für Vercel vorbereiten
cd build/web

# 4. vercel.json prüfen/erstellen
cat > vercel.json << 'EOF'
{
  "version": 2,
  "routes": [
    { "handle": "filesystem" },
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
EOF

# 5. Deploy
vercel --prod
```

### Bei FEHLERN:

1. Fehler dokumentieren
2. Beheben
3. Betroffene Tests wiederholen
4. Gesamten Test erneut durchführen

---

## CHECKLISTE VOR DEPLOY

```
[ ] Alle automatisierten Tests bestanden
[ ] Alle manuellen Tests bestanden
[ ] Keine kritischen Fehler
[ ] Keine Cookies
[ ] Keine Tracker
[ ] Performance akzeptabel
[ ] Responsive Design funktioniert
[ ] Mindestens 2 Browser getestet
[ ] Feature-Flags auf Production-Werte gesetzt
[ ] Mock-Daten durch echte ersetzt (oder Mock-Modus dokumentiert)
[ ] README aktualisiert
[ ] Version hochgesetzt
```

---

**Starte jetzt mit TEIL 1: AUTOMATISIERTE TESTS**

Nach Abschluss aller Tests, zeige mir den vollständigen Test-Report.
