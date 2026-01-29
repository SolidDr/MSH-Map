# Prompt 2: Pin-Koordinaten korrigieren

## 🔴 KRITISCH - Falsche Positionen können zu Verwirrung führen!

---

## Problem

Einige Pins sind "in der Nähe" aber nicht am korrekten Standort.

**Bekanntes Beispiel:**
- Dr. Anaja Ehrke - Pin ist in der Nähe aber nicht richtig positioniert

---

## Ursachen für falsche Koordinaten

1. **OSM-Daten zeigen Gebäudemitte** statt Eingang
2. **Veraltete Daten** - Praxis ist umgezogen
3. **Falsche Zuordnung** - Koordinaten von anderem POI übernommen
4. **Rundungsfehler** - Zu wenige Dezimalstellen

---

## Aufgabe: Systematische Koordinaten-Verifizierung

### Schritt 1: Alle Gesundheits-Einträge exportieren

```javascript
// Script zum Extrahieren aller Koordinaten
const doctors = require('./assets/data/health/doctors.json');
const pharmacies = require('./assets/data/health/pharmacies.json');

const toVerify = [
  ...doctors.data.map(d => ({
    type: 'doctor',
    id: d.id,
    name: d.name,
    lat: d.latitude,
    lng: d.longitude,
    address: `${d.street}, ${d.postalCode} ${d.city}`
  })),
  ...pharmacies.data.map(p => ({
    type: 'pharmacy',
    id: p.id,
    name: p.name,
    lat: p.latitude,
    lng: p.longitude,
    address: `${p.street}, ${p.postalCode} ${p.city}`
  }))
];

// Als CSV für manuelle Prüfung
console.log('type,id,name,lat,lng,address,verified,correct,new_lat,new_lng');
toVerify.forEach(e => {
  console.log(`${e.type},${e.id},"${e.name}",${e.lat},${e.lng},"${e.address}",,,`);
});
```

### Schritt 2: Batch-Verifizierung mit Google Maps

**Für JEDEN Eintrag:**

1. Koordinaten in Google Maps eingeben: `[lat], [lng]`
2. Prüfen ob Pin auf dem richtigen Gebäude liegt
3. Falls nicht: Adresse suchen und korrekte Koordinaten ermitteln

**Prüfkriterien:**
- [ ] Pin liegt auf dem Gebäude (nicht auf Straße)
- [ ] Pin liegt in der Nähe des Eingangs (bei mehreren Eingängen: Haupteingang)
- [ ] Koordinaten haben mindestens 5 Dezimalstellen (±1m Genauigkeit)

### Schritt 3: Korrektur für Dr. Anaja Ehrke

**Aktueller Stand:**
```json
{
  "name": "Dr. Anaja Ehrke",
  "latitude": XX.XXXXX,  // FALSCH
  "longitude": XX.XXXXX  // FALSCH
}
```

**Recherche:**
1. Google Suche: "Dr. Anaja Ehrke [Stadt]"
2. Adresse notieren
3. Adresse in Google Maps eingeben
4. Gebäude finden
5. Koordinaten extrahieren (Rechtsklick → Was ist hier?)

**Korrektur:**
```json
{
  "name": "Dr. Anaja Ehrke",
  "latitude": YY.YYYYY,  // KORRIGIERT
  "longitude": YY.YYYYY, // KORRIGIERT
  "verified": true,
  "verifiedDate": "2026-01-29",
  "verifiedSource": "Google Maps"
}
```

---

## Automatisierte Koordinaten-Validierung

### Script zur Adress-Koordinaten-Prüfung

```javascript
// scripts/verify-coordinates.js

const fetch = require('node-fetch');

async function geocodeAddress(address) {
  const url = `https://nominatim.openstreetmap.org/search?` +
    `q=${encodeURIComponent(address)}&format=json&limit=1`;
  
  const response = await fetch(url, {
    headers: { 'User-Agent': 'MSH-Map-Verification/1.0' }
  });
  const data = await response.json();
  
  if (data.length > 0) {
    return {
      lat: parseFloat(data[0].lat),
      lng: parseFloat(data[0].lon),
      displayName: data[0].display_name
    };
  }
  return null;
}

function haversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371e3; // Erdradius in Metern
  const φ1 = lat1 * Math.PI / 180;
  const φ2 = lat2 * Math.PI / 180;
  const Δφ = (lat2 - lat1) * Math.PI / 180;
  const Δλ = (lon2 - lon1) * Math.PI / 180;

  const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

  return R * c; // Distanz in Metern
}

async function verifyEntry(entry) {
  const address = `${entry.street}, ${entry.postalCode} ${entry.city}`;
  const geocoded = await geocodeAddress(address);
  
  if (!geocoded) {
    return {
      ...entry,
      status: 'ADDRESS_NOT_FOUND',
      suggestion: null
    };
  }
  
  const distance = haversineDistance(
    entry.latitude, entry.longitude,
    geocoded.lat, geocoded.lng
  );
  
  if (distance > 100) { // Mehr als 100m Abweichung
    return {
      ...entry,
      status: 'COORDS_MISMATCH',
      distance: Math.round(distance),
      currentCoords: { lat: entry.latitude, lng: entry.longitude },
      suggestedCoords: { lat: geocoded.lat, lng: geocoded.lng }
    };
  }
  
  return {
    ...entry,
    status: 'OK',
    distance: Math.round(distance)
  };
}

// Hauptfunktion
async function verifyAllEntries() {
  const doctors = require('../assets/data/health/doctors.json');
  
  const results = {
    ok: [],
    mismatch: [],
    notFound: []
  };
  
  for (const entry of doctors.data) {
    console.log(`Prüfe: ${entry.name}...`);
    const result = await verifyEntry(entry);
    
    if (result.status === 'OK') {
      results.ok.push(result);
    } else if (result.status === 'COORDS_MISMATCH') {
      results.mismatch.push(result);
    } else {
      results.notFound.push(result);
    }
    
    // Rate limiting für Nominatim
    await new Promise(r => setTimeout(r, 1100));
  }
  
  // Report
  console.log('\n=== VERIFIZIERUNGS-REPORT ===\n');
  console.log(`✅ OK: ${results.ok.length}`);
  console.log(`⚠️ Abweichung >100m: ${results.mismatch.length}`);
  console.log(`❌ Adresse nicht gefunden: ${results.notFound.length}`);
  
  if (results.mismatch.length > 0) {
    console.log('\n=== KOORDINATEN-ABWEICHUNGEN ===\n');
    results.mismatch.forEach(e => {
      console.log(`${e.name}:`);
      console.log(`  Aktuell: ${e.currentCoords.lat}, ${e.currentCoords.lng}`);
      console.log(`  Vorschlag: ${e.suggestedCoords.lat}, ${e.suggestedCoords.lng}`);
      console.log(`  Abweichung: ${e.distance}m\n`);
    });
  }
  
  return results;
}

verifyAllEntries();
```

---

## Koordinaten-Präzision verbessern

### Problem: Zu wenige Dezimalstellen

```
5 Dezimalstellen = ±1.1m Genauigkeit (EMPFOHLEN)
4 Dezimalstellen = ±11m Genauigkeit
3 Dezimalstellen = ±111m Genauigkeit (UNGENÜGEND!)
```

### Fix: Alle Koordinaten auf 6 Dezimalstellen runden

```javascript
// Koordinaten normalisieren
function normalizeCoord(coord) {
  return Math.round(coord * 1000000) / 1000000; // 6 Dezimalstellen
}

doctors.data.forEach(d => {
  d.latitude = normalizeCoord(d.latitude);
  d.longitude = normalizeCoord(d.longitude);
});
```

---

## Manuelle Korrektur-Checkliste

### Für jeden Eintrag mit Abweichung >50m:

```
Eintrag: ________________
Aktuelle Koordinaten: _______, _______
Aktuelle Adresse: ________________

Recherche:
[ ] Google Maps Suche nach Name
[ ] Google Maps Suche nach Adresse
[ ] Gebäude identifiziert
[ ] Eingang gefunden

Neue Koordinaten: _______, _______
Ermittelt via: [ ] Google Maps  [ ] OSM  [ ] Nominatim

Korrigiert in JSON: [ ] Ja
```

---

## Batch-Korrektur in JSON

```javascript
// corrections.js - Liste aller Korrekturen

const COORDINATE_CORRECTIONS = [
  {
    id: 'arzt_xy_ehrke',
    name: 'Dr. Anaja Ehrke',
    oldLat: 51.XXXXX,
    oldLng: 11.XXXXX,
    newLat: 51.YYYYY,
    newLng: 11.YYYYY,
    reason: 'Pin war 150m vom Gebäude entfernt',
    source: 'Google Maps'
  },
  // Weitere Korrekturen...
];

// Anwenden
function applyCorrections(data) {
  return data.map(entry => {
    const correction = COORDINATE_CORRECTIONS.find(c => c.id === entry.id);
    if (correction) {
      return {
        ...entry,
        latitude: correction.newLat,
        longitude: correction.newLng,
        verified: true,
        verifiedDate: new Date().toISOString().split('T')[0],
        correctionNote: correction.reason
      };
    }
    return entry;
  });
}
```

---

## Checkliste

```
AUTOMATISCHE PRÜFUNG:
[ ] verify-coordinates.js erstellt
[ ] Script auf doctors.json ausgeführt
[ ] Script auf pharmacies.json ausgeführt
[ ] Liste aller Abweichungen >100m erstellt

MANUELLE KORREKTUREN:
[ ] Dr. Anaja Ehrke - Koordinaten korrigiert
[ ] Alle Einträge mit Abweichung >100m geprüft
[ ] Korrekturen in JSON eingetragen

QUALITÄT:
[ ] Alle Koordinaten haben 5-6 Dezimalstellen
[ ] Alle korrigierten Einträge haben verified=true
[ ] Korrektur-Log erstellt
```

---

## Deliverables

1. **verify-coordinates.js** - Automatisches Prüfscript
2. **Korrektur-Log:** Liste aller geänderten Koordinaten
3. **Aktualisierte JSON-Dateien** mit korrigierten Koordinaten
4. **Bestätigung:** "Alle Pins zeigen auf korrekte Standorte"
