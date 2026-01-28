# Prompt 2: Geodaten korrigieren - Kritische Pin-Positionen

## ⚠️ KRITISCH - GESUNDHEITSRELEVANT

> **Falsche Apotheken-Positionen können im Notfall Leben kosten!**
> 
> Diese Korrekturen haben höchste Priorität.

---

## Bekannte falsche Pins

| Eintrag | Problem | Priorität |
|---------|---------|-----------|
| **Mammut Apotheke** | Völlig falscher Ort | 🔴 KRITISCH |
| **Barbarossa Apotheke** | Pin-Position falsch | 🔴 KRITISCH |
| **Tierheim** | Pin falsch | 🟠 HOCH |
| **Tafel** | Pin falsch, "aufblinken" | 🟠 HOCH |

---

## Vorgehen für jede Korrektur

### Schritt 1: Echte Adresse ermitteln

```
Quellen für korrekte Adressen:
1. Google Maps - Suche nach genauem Namen
2. Offizielle Website der Einrichtung
3. Apothekerkammer Sachsen-Anhalt (für Apotheken)
4. Das Örtliche / Gelbe Seiten
5. OpenStreetMap
```

### Schritt 2: Koordinaten bestimmen

**Option A: Google Maps**
1. Adresse in Google Maps eingeben
2. Rechtsklick auf den exakten Standort
3. "Was ist hier?" oder Koordinaten direkt anzeigen
4. Format: `51.XXXXX, 11.XXXXX`

**Option B: OpenStreetMap**
1. Adresse auf openstreetmap.org suchen
2. Rechtsklick → "Adresse anzeigen"
3. Koordinaten aus URL extrahieren

**Option C: Geocoding API**
```javascript
// Einmalige Konvertierung Adresse → Koordinaten
async function geocodeAddress(address) {
  const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}`;
  const response = await fetch(url);
  const data = await response.json();
  
  if (data.length > 0) {
    return {
      lat: parseFloat(data[0].lat),
      lng: parseFloat(data[0].lon)
    };
  }
  return null;
}
```

### Schritt 3: Koordinaten verifizieren

```
PFLICHT-PRÜFUNG vor dem Speichern:
□ Koordinaten in Google Maps eingeben
□ Stimmt der angezeigte Ort mit der Adresse überein?
□ Ist der Pin auf dem GEBÄUDE, nicht auf der Straße?
□ Bei Apotheken: Ist der Eingang erkennbar?
```

---

## Konkrete Korrekturen

### 1. Mammut Apotheke

**Recherche durchführen:**
```
Suchbegriffe:
- "Mammut Apotheke Sangerhausen"
- "Mammut Apotheke Mansfeld-Südharz"
- "Mammut Apotheke Eisleben"
```

**Zu korrigieren:**
```javascript
// VORHER (falsch):
{
  name: "Mammut Apotheke",
  lat: XX.XXXXX,  // FALSCHE Koordinaten
  lng: XX.XXXXX
}

// NACHHER (korrekt):
{
  name: "Mammut Apotheke",
  address: "[ECHTE ADRESSE EINTRAGEN]",
  lat: [KORREKTE LAT],
  lng: [KORREKTE LNG],
  verified: true,
  verifiedDate: "2025-01-28",
  verifiedSource: "Google Maps"
}
```

### 2. Barbarossa Apotheke

**Recherche durchführen:**
```
Suchbegriffe:
- "Barbarossa Apotheke" + Orte in MSH
- Apothekerkammer Sachsen-Anhalt Verzeichnis
```

**Zu korrigieren:**
```javascript
// Format wie oben
{
  name: "Barbarossa Apotheke",
  address: "[ECHTE ADRESSE]",
  lat: [KORREKT],
  lng: [KORREKT],
  verified: true,
  verifiedDate: "2025-01-28",
  verifiedSource: "[Quelle]"
}
```

### 3. Tierheim

**Recherche:**
```
- "Tierheim Sangerhausen"
- "Tierheim Mansfeld-Südharz"
- "Tierschutzverein MSH"
```

### 4. Tafel

**Recherche:**
```
- "Tafel Sangerhausen"
- "Tafel Eisleben"
- "Tafel Mansfeld-Südharz"
```

**Zusätzlich:** Das "Aufblinken" Problem beheben - prüfe ob ein Animation-Bug vorliegt.

---

## Vollständiger Apotheken-Audit

Da zwei Apotheken falsch waren, prüfe ALLE Apotheken:

```javascript
// Erstelle eine Prüfliste
const apotheken = getAllPharmacies();

const auditResults = [];

for (const apotheke of apotheken) {
  const result = {
    name: apotheke.name,
    currentLat: apotheke.lat,
    currentLng: apotheke.lng,
    currentAddress: apotheke.address,
    
    // Manuell zu prüfen:
    googleMapsVerified: false,  // □ In Google Maps geprüft
    addressExists: false,        // □ Adresse existiert
    coordsMatch: false,          // □ Koordinaten = Adresse
    phoneWorks: false,           // □ Telefonnummer gültig
    
    issues: [],
    correctedLat: null,
    correctedLng: null
  };
  
  auditResults.push(result);
}

// Exportiere als Checkliste
console.table(auditResults);
```

### Apotheken-Checkliste (manuell ausfüllen)

| Name | Adresse geprüft | Coords geprüft | Korrekt? | Korrektur nötig |
|------|-----------------|----------------|----------|-----------------|
| Mammut Apotheke | □ | □ | ❌ | JA - neu ermitteln |
| Barbarossa Apotheke | □ | □ | ❌ | JA - neu ermitteln |
| [Apotheke 3] | □ | □ | ? | ? |
| [Apotheke 4] | □ | □ | ? | ? |
| ... | | | | |

---

## Koordinaten-Validierung implementieren

### Validierungs-Funktion

```javascript
// utils/validateCoordinates.js

const MSH_BOUNDS = {
  north: 51.65,  // Nördlichste Grenze MSH
  south: 51.35,  // Südlichste Grenze MSH
  east: 11.80,   // Östlichste Grenze MSH
  west: 11.00    // Westlichste Grenze MSH
};

function validateCoordinates(lat, lng, name) {
  const errors = [];
  
  // Null-Check
  if (lat === null || lat === undefined || lng === null || lng === undefined) {
    errors.push(`${name}: Koordinaten fehlen!`);
    return { valid: false, errors };
  }
  
  // Typ-Check
  if (typeof lat !== 'number' || typeof lng !== 'number') {
    errors.push(`${name}: Koordinaten sind keine Zahlen!`);
    return { valid: false, errors };
  }
  
  // Null-Koordinaten
  if (lat === 0 || lng === 0) {
    errors.push(`${name}: Null-Koordinaten (0, 0)!`);
    return { valid: false, errors };
  }
  
  // Bereichs-Check (innerhalb MSH?)
  if (lat < MSH_BOUNDS.south || lat > MSH_BOUNDS.north) {
    errors.push(`${name}: Latitude ${lat} außerhalb MSH!`);
  }
  
  if (lng < MSH_BOUNDS.west || lng > MSH_BOUNDS.east) {
    errors.push(`${name}: Longitude ${lng} außerhalb MSH!`);
  }
  
  // Präzisions-Check (mindestens 4 Dezimalstellen)
  const latDecimals = (lat.toString().split('.')[1] || '').length;
  const lngDecimals = (lng.toString().split('.')[1] || '').length;
  
  if (latDecimals < 4 || lngDecimals < 4) {
    errors.push(`${name}: Koordinaten zu ungenau (min. 4 Dezimalstellen)`);
  }
  
  return {
    valid: errors.length === 0,
    errors
  };
}

// Alle Einträge validieren
function validateAllLocations(locations) {
  const report = {
    total: locations.length,
    valid: 0,
    invalid: 0,
    issues: []
  };
  
  locations.forEach(loc => {
    const result = validateCoordinates(loc.lat, loc.lng, loc.name);
    if (result.valid) {
      report.valid++;
    } else {
      report.invalid++;
      report.issues.push(...result.errors);
    }
  });
  
  return report;
}

module.exports = { validateCoordinates, validateAllLocations, MSH_BOUNDS };
```

### In Build-Prozess einbinden

```json
// package.json
{
  "scripts": {
    "validate-coords": "node scripts/validate-coordinates.js",
    "prebuild": "npm run validate-coords"
  }
}
```

---

## Tierheim "Aufblinken" Bug

### Problem analysieren

```javascript
// Suche nach Animation/Blink-Logik
grep -r "blink" --include="*.js" --include="*.css"
grep -r "flash" --include="*.js" --include="*.css"
grep -r "pulse" --include="*.js" --include="*.css"
grep -r "tierheim" --include="*.js" --include="*.css"
grep -r "tafel" --include="*.js" --include="*.css"
```

### Mögliche Ursachen

1. **CSS Animation auf falschem Element**
2. **Z-Index Problem** (Element überlappt)
3. **State-Flicker** (React/Vue Re-Rendering)
4. **Marker-Update Loop**

### Fix je nach Ursache

```css
/* Falls CSS-Animation das Problem ist */
.marker-tierheim,
.marker-tafel {
  animation: none !important;  /* Temporär zum Testen */
}
```

```javascript
// Falls Re-Rendering das Problem ist
// Prüfe ob useEffect/watch Dependency korrekt ist
useEffect(() => {
  // Dieser Code sollte nicht bei jedem Render laufen
}, [/* Korrekte Dependencies */]);
```

---

## Checkliste nach Abschluss

```
APOTHEKEN:
[ ] Mammut Apotheke - Koordinaten korrigiert & verifiziert
[ ] Barbarossa Apotheke - Koordinaten korrigiert & verifiziert
[ ] ALLE anderen Apotheken geprüft
[ ] Validierungs-Script läuft ohne Fehler

ANDERE PINS:
[ ] Tierheim - Position korrigiert
[ ] Tierheim - Aufblinken-Bug behoben
[ ] Tafel - Position korrigiert
[ ] Tafel - Aufblinken-Bug behoben

VALIDIERUNG:
[ ] Koordinaten-Validierung implementiert
[ ] In Build-Prozess eingebunden
[ ] Alle Locations bestehen Validierung
```

---

## Deliverables

1. **Korrektur-Tabelle:**

| Eintrag | Alt (Lat, Lng) | Neu (Lat, Lng) | Quelle |
|---------|----------------|----------------|--------|
| Mammut Apotheke | XX, XX | YY, YY | Google Maps |
| ... | | | |

2. **Validierungs-Report:** Ausgabe des Scripts
3. **Bestätigung:** "Alle kritischen Pins korrigiert und verifiziert"
