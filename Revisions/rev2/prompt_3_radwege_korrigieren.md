# Prompt 3: Radwege korrigieren - Kupferspurenradweg komplett neu

## 🔴 KRITISCH - Radweg ist "völlig falsch"!

---

## Problem

Der **Kupferspurenradweg** ist komplett falsch gezeichnet. Auch andere Radwege sollten kontrolliert werden.

---

## Kupferspurenradweg - Komplette Neuerstellung

### Schritt 1: Offizielle Quellen finden

**Primäre Quellen:**
1. **kupferspurenradweg.de** (falls vorhanden)
2. **Tourismusverband Harz/Südharz**
3. **Komoot**: https://www.komoot.de/discover/kupferspurenradweg
4. **OSM-Relation**: Suche nach "Kupferspuren" in OSM

**OSM Overpass-Abfrage:**
```
[out:json];
relation["name"~"Kupferspur"]["route"="bicycle"](51.3,10.9,51.7,11.9);
out geom;
```

### Schritt 2: GPX-Track beschaffen

**Option A: Von offizieller Website**
- Suche nach "Kupferspurenradweg GPX download"
- Tourismus-Portale bieten oft GPX-Downloads an

**Option B: Aus Komoot extrahieren**
1. Auf komoot.de nach "Kupferspurenradweg" suchen
2. Tour finden und GPX exportieren (Account nötig)

**Option C: Aus OSM extrahieren**
1. OSM-Relation finden
2. Mit JOSM oder Overpass als GPX exportieren

**Option D: Manuell nachzeichnen**
1. Offizielle Karte als Referenz
2. Punkte auf OpenStreetMap nachverfolgen
3. Koordinaten manuell erfassen

### Schritt 3: GPX zu Dart-Code konvertieren

```javascript
// gpx-to-dart.js

const fs = require('fs');
const { DOMParser } = require('xmldom');

function gpxToDart(gpxFilePath, routeName) {
  const gpxContent = fs.readFileSync(gpxFilePath, 'utf8');
  const parser = new DOMParser();
  const doc = parser.parseFromString(gpxContent, 'text/xml');
  
  const trackpoints = doc.getElementsByTagName('trkpt');
  const points = [];
  
  for (let i = 0; i < trackpoints.length; i++) {
    const lat = parseFloat(trackpoints[i].getAttribute('lat'));
    const lon = parseFloat(trackpoints[i].getAttribute('lon'));
    points.push({ lat, lon });
  }
  
  // Punkte reduzieren (jeden 5. Punkt, außer Start/Ende)
  const simplified = [points[0]];
  for (let i = 5; i < points.length - 5; i += 5) {
    simplified.push(points[i]);
  }
  simplified.push(points[points.length - 1]);
  
  // Dart-Code generieren
  let dartCode = `// ${routeName} - Automatisch generiert aus GPX\n`;
  dartCode += `// ${simplified.length} Punkte (reduziert von ${points.length})\n\n`;
  dartCode += `final List<LatLng> ${routeName.toLowerCase().replace(/-/g, '_')}Points = [\n`;
  
  simplified.forEach((p, i) => {
    dartCode += `  LatLng(${p.lat.toFixed(6)}, ${p.lon.toFixed(6)}),`;
    dartCode += i % 3 === 2 ? '\n' : ' ';
  });
  
  dartCode += '\n];\n';
  
  return dartCode;
}

// Verwendung
const dartCode = gpxToDart('./kupferspuren.gpx', 'kupferspuren');
fs.writeFileSync('./kupferspuren_points.dart', dartCode);
console.log('Dart-Code generiert!');
```

### Schritt 4: Route-Datei aktualisieren

**Datei:** `lib/src/modules/radwege/data/routes/kupferspuren_route.dart`

```dart
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import '../radweg_route.dart';

// KOMPLETT NEU ERSTELLT - 2026-01-29
// Quelle: [QUELLE ANGEBEN]

final kupferspurenRoute = RadwegRoute(
  id: 'kupferspuren',
  name: 'Kupferspurenradweg',
  description: '''
Der Kupferspurenradweg führt durch die historische Kupferschieferregion 
im Mansfelder Land. Er verbindet bedeutende Orte der Bergbaugeschichte 
und bietet Einblicke in 800 Jahre Kupfererzgewinnung.
''',
  category: RadwegCategory.themenweg,
  lengthKm: 48.0,
  difficulty: 'Mittel',
  routeColor: Color(0xFFB87333), // Kupferfarben
  
  // NEUE, KORRIGIERTE KOORDINATEN
  routePoints: [
    // Start: [STARTPUNKT]
    LatLng(51.XXXXX, 11.XXXXX),
    
    // Wegpunkte...
    // [HIER KOMMEN DIE KORREKTEN KOORDINATEN]
    
    // Ende: [ENDPUNKT]
    LatLng(51.YYYYY, 11.YYYYY),
  ],
  
  pois: [
    RadwegPoi(
      name: 'Mansfeld Museum',
      description: 'Geschichte des Kupferbergbaus',
      position: LatLng(51.XXXXX, 11.XXXXX),
      type: PoiType.museum,
    ),
    // Weitere POIs...
  ],
  
  elevationGain: 350,
  websiteUrl: 'https://...',
  contactName: 'Tourismusverband Mansfeld-Südharz',
  contactPhone: '+49 ...',
);
```

---

## Alle Radwege kontrollieren

### Prüfmethode für jeden Radweg

```
Für jeden Radweg:
1. [ ] Offizielle Route recherchieren
2. [ ] Mit aktueller Route in App vergleichen
3. [ ] Abweichungen notieren
4. [ ] Bei Abweichungen: Route aktualisieren
```

### Radweg-Checkliste

| Radweg | Länge | Quelle geprüft | Route korrekt | Aktion |
|--------|-------|----------------|---------------|--------|
| Kupferspurenradweg | 48 km | □ | ❌ FALSCH | NEU ERSTELLEN |
| Romanik-Radweg | 156 km | □ | ? | Prüfen |
| Saale-Harz-Radweg | 140 km | □ | ? | Prüfen |
| Kyffhäuser-Radweg | 103 km | □ | ? | Prüfen |
| Wipper-Radweg | 118 km | □ | ? | Prüfen |
| Himmelsscheiben-Radweg | 75 km | □ | ? | Prüfen |
| Salzstraßen-Radweg | 90 km | □ | ? | Prüfen |
| Süßer-See-Radweg | 67 km | □ | ? | Prüfen |
| Lutherweg-Radweg | 103 km | □ | ? | Prüfen |

### Schnell-Prüfung via OSM

```
// Overpass-Abfrage für alle Radwege in MSH
[out:json];
(
  relation["route"="bicycle"](51.3,10.9,51.7,11.9);
);
out geom;
```

Vergleiche OSM-Routen mit App-Routen:
1. Exportiere OSM-Route als GeoJSON
2. Exportiere App-Route als GeoJSON
3. Visueller Vergleich in geojson.io

---

## Radweg-Validierungs-Script

```javascript
// scripts/validate-radwege.js

const fs = require('fs');

// Lade alle Radweg-Dateien
const radwege = [
  require('../lib/src/modules/radwege/data/routes/kupferspuren_route.dart'),
  // ... weitere
];

function validateRadweg(route) {
  const issues = [];
  
  // Mindestens 10 Punkte
  if (route.routePoints.length < 10) {
    issues.push(`Zu wenige Punkte: ${route.routePoints.length}`);
  }
  
  // Punkte innerhalb MSH?
  const MSH_BOUNDS = {
    latMin: 51.30, latMax: 51.70,
    lngMin: 10.90, lngMax: 11.90
  };
  
  route.routePoints.forEach((p, i) => {
    if (p.latitude < MSH_BOUNDS.latMin || p.latitude > MSH_BOUNDS.latMax ||
        p.longitude < MSH_BOUNDS.lngMin || p.longitude > MSH_BOUNDS.lngMax) {
      issues.push(`Punkt ${i} außerhalb MSH: ${p.latitude}, ${p.longitude}`);
    }
  });
  
  // Gesamtlänge plausibel?
  const calculatedLength = calculateRouteLength(route.routePoints);
  const diff = Math.abs(calculatedLength - route.lengthKm);
  if (diff > 5) { // Mehr als 5km Abweichung
    issues.push(`Längenabweichung: Angegeben ${route.lengthKm}km, berechnet ${calculatedLength.toFixed(1)}km`);
  }
  
  return {
    name: route.name,
    valid: issues.length === 0,
    issues
  };
}

function calculateRouteLength(points) {
  let totalKm = 0;
  for (let i = 0; i < points.length - 1; i++) {
    totalKm += haversineDistance(
      points[i].latitude, points[i].longitude,
      points[i+1].latitude, points[i+1].longitude
    ) / 1000;
  }
  return totalKm;
}

// Alle prüfen
radwege.forEach(route => {
  const result = validateRadweg(route);
  if (result.valid) {
    console.log(`✅ ${result.name}`);
  } else {
    console.log(`❌ ${result.name}:`);
    result.issues.forEach(i => console.log(`   - ${i}`));
  }
});
```

---

## GPX-Ressourcen

### Offizielle GPX-Quellen für MSH-Radwege

| Radweg | GPX-Quelle |
|--------|------------|
| Alle Harz-Radwege | https://www.harzinfo.de/aktivitaeten/radfahren |
| Saale-Radwege | https://www.saale-radwanderweg.de |
| Romanik-Straße | https://www.strasse-der-romanik.de |

### OSM als GPX exportieren

1. Route auf openstreetmap.org finden
2. Relation-ID notieren
3. Mit overpass-api.de als GPX exportieren:
```
https://overpass-api.de/api/interpreter?data=[out:json];relation(RELATION_ID);out geom;
```

---

## Checkliste

```
KUPFERSPURENRADWEG:
[ ] Offizielle Route recherchiert
[ ] GPX-Track beschafft
[ ] GPX zu Dart konvertiert
[ ] kupferspuren_route.dart aktualisiert
[ ] Route in App getestet
[ ] Visuell korrekt auf Karte

ANDERE RADWEGE:
[ ] Romanik-Radweg geprüft
[ ] Saale-Harz-Radweg geprüft
[ ] Kyffhäuser-Radweg geprüft
[ ] Wipper-Radweg geprüft
[ ] Himmelsscheiben-Radweg geprüft
[ ] Salzstraßen-Radweg geprüft
[ ] Süßer-See-Radweg geprüft
[ ] Lutherweg-Radweg geprüft

VALIDIERUNG:
[ ] validate-radwege.js ausgeführt
[ ] Alle Radwege bestehen Validierung
```

---

## Deliverables

1. **Neue kupferspuren_route.dart** mit korrekten Koordinaten
2. **GPX-Dateien** als Backup/Referenz
3. **Validierungs-Report** für alle Radwege
4. **Korrekturen** für eventuelle andere fehlerhafte Radwege
