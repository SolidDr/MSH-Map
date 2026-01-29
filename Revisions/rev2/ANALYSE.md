# MSH Map - Feedback Runde 3 - Analyse

## Übersicht der neuen Probleme

### Nach Kategorie sortiert

---

## 🔴 KRITISCH - Fehlende/Falsche Daten

| # | Problem | Details | Lösung |
|---|---------|---------|--------|
| 1 | **Fehlende Ärzte** | Bsp: Michael Zastava (Hallesche Str. 69, Südharz) | Ärzte-Daten ergänzen |
| 2 | **Fehlende Apotheken** | Bsp: Kyffhäuser Apotheke (Hallesche Str. 59, Südharz) | Apotheken-Daten ergänzen |
| 3 | **Falsche Arzt-Pins** | Bsp: Dr. Anaja Ehrke - in der Nähe aber nicht richtig | Koordinaten korrigieren |
| 4 | **Kupferspurenradweg falsch** | Route völlig falsch gezeichnet | Komplette Neuerstellung |
| 5 | **Entdecken-Einträge ohne Pin** | Einträge anklickbar, aber kein Pin auf Karte | Daten-Sync Problem |

---

## 🟠 HOCH - Fehlende Features

| # | Problem | Details | Lösung |
|---|---------|---------|--------|
| 6 | **Filter-Bug** | Standard sollte NUR Radwege + Gesundheit sein | Default-Filter ändern |
| 7 | **Krankenhäuser-Filter fehlt** | Unter "Gesundheit" kein Hospital-Filter | Filter hinzufügen |
| 8 | **AED ohne Ortsangaben** | Übersicht zeigt nicht wo AEDs sind | Standort in Liste anzeigen |
| 9 | **Unterkategorien nicht klickbar** | "Auf Karte anzeigen" fehlt bei Gesundheit/Sozial | Click-Handler implementieren |
| 10 | **Trackpad-Zoom geht nicht** | Pinch-to-Zoom auf Trackpad funktioniert nicht | Scroll-Zoom aktivieren |

---

## 🟡 MITTEL - UI/UX Verbesserungen

| # | Problem | Details | Lösung |
|---|---------|---------|--------|
| 11 | **Click-to-Zoom Button fehlt** | Kein Button um gezielt zu zoomen | Zoom-Buttons hinzufügen |
| 12 | **Karte ausnorden Button fehlt** | Kein Button um Karte nach Norden auszurichten | Kompass-Button hinzufügen |
| 13 | **Mobile: "Touren" umbenennen** | Soll "Rad/Wege" heißen | Text ändern |
| 14 | **Radwege kontrollieren** | Alle Radwege auf Korrektheit prüfen | Daten-Audit |

---

## Kern-Probleme identifiziert

### 1. Daten-Synchronisation
Einträge unter "Entdecken" haben keine entsprechenden Pins auf der Karte.
→ **Ursache:** `locations.json` und angezeigte Listen sind nicht synchronisiert.

### 2. Unvollständige Gesundheitsdaten
Ärzte und Apotheken fehlen trotz OSM-Extraktion.
→ **Ursache:** OSM-Daten sind unvollständig, manuelle Ergänzung nötig.

### 3. Koordinaten-Qualität
Pins sind "in der Nähe" aber nicht exakt.
→ **Ursache:** OSM-Koordinaten zeigen auf Gebäudemitte, nicht Eingang.

### 4. Radweg-Daten
Kupferspurenradweg komplett falsch.
→ **Ursache:** Manuelle Erfassung war fehlerhaft, OSM-Daten nicht genutzt.

---

## Lösungsansatz nach methods_claude.md

### Für fehlende Ärzte/Apotheken:

1. **Overpass API Abfrage erweitern:**
```
[out:json][timeout:60];
area["name"="Mansfeld-Südharz"]->.msh;
(
  node["amenity"="doctors"](area.msh);
  node["amenity"="pharmacy"](area.msh);
  node["amenity"="hospital"](area.msh);
  way["amenity"="doctors"](area.msh);
  way["amenity"="pharmacy"](area.msh);
);
out body;
```

2. **arzt-auskunft.de Abgleich:**
   - Suche nach "Südharz" + "Arzt"
   - Suche nach "Roßla" + "Arzt"
   - Suche nach "Hallesche Straße"

3. **Manuelle Ergänzung:**
   - Google Maps Suche: "Arzt Hallesche Str Südharz"
   - Koordinaten extrahieren
   - In doctors.json einfügen

### Für Kupferspurenradweg:

1. **Offizielle Quelle finden:**
   - kupferspurenradweg.de
   - Tourismusverband Harz
   - GPX-Track herunterladen

2. **OSM-Relation prüfen:**
```
relation["name"~"Kupferspur"]["route"="bicycle"];
```

3. **Route komplett neu erstellen** mit verifizierten Punkten

---

## Dateien die angepasst werden müssen

| Datei | Änderung |
|-------|----------|
| `assets/data/health/doctors.json` | Fehlende Ärzte ergänzen |
| `assets/data/health/pharmacies.json` | Fehlende Apotheken ergänzen |
| `assets/data/health/aeds.json` | Ortsangaben hinzufügen |
| `lib/src/modules/radwege/data/routes/kupferspuren_route.dart` | Komplett neu |
| `lib/src/modules/map/map_controller.dart` | Zoom-Buttons, Kompass |
| `lib/src/modules/filter/filter_state.dart` | Default-Filter ändern |
| `lib/src/modules/health/health_categories.dart` | Hospital-Filter hinzufügen |
| `lib/src/modules/discover/discover_screen.dart` | Klick → Pin Sync |

---

## Zeitschätzung

| Prompt | Aufwand |
|--------|---------|
| Prompt 1: Fehlende Gesundheitsdaten | 3-4h |
| Prompt 2: Pin-Koordinaten korrigieren | 2-3h |
| Prompt 3: Kupferspurenradweg neu | 2-3h |
| Prompt 4: Karten-Features (Zoom, Kompass) | 2h |
| Prompt 5: Filter & UI Fixes | 2h |
| Prompt 6: Entdecken-Pin-Sync | 2h |
| **Gesamt** | **13-17h** |
