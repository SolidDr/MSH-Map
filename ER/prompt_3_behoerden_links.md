# Prompt 3: Behörden komplett neu erstellen + Dead Links entfernen

## Problem

### Behörden
Die Behörden-Daten sind **komplett falsch**. Es werden Behörden aus anderen Landkreisen angezeigt statt MSH-Behörden.

**FALSCH (aktuell vorhanden - ALLES LÖSCHEN):**
- Bad Frankenhausen ❌
- Uhrbach ❌
- Harzgerode ❌
- Kyffhäuser ❌
- Nordhausen ❌
- Artern ❌
- Sondershausen ❌
- Osleben ❌

**RICHTIG (MSH-Behörden - NEU ERSTELLEN):**
- Landkreis Mansfeld-Südharz
- Stadt Sangerhausen
- Stadt Eisleben (Lutherstadt)
- Stadt Hettstedt
- Stadt Mansfeld
- Gemeinde Südharz
- Alle weiteren Gemeinden im Landkreis

### Dead Links
Viele Website-Links führen ins Leere (404, Domain nicht erreichbar, etc.)

---

## Teil A: Behörden komplett neu erstellen

### Schritt 1: Alle falschen Behörden-Daten löschen

```javascript
// Finde die Behörden-Datei
// Wahrscheinlich: src/data/authorities.json oder ähnlich

// LÖSCHE alle Einträge die NICHT zu MSH gehören:
const NICHT_MSH = [
  'bad frankenhausen',
  'uhrbach',
  'harzgerode',
  'kyffhäuser',
  'nordhausen',
  'artern',
  'sondershausen',
  'osleben'
];

// Diese komplett entfernen!
```

### Schritt 2: MSH-Struktur verstehen

```
Landkreis Mansfeld-Südharz
├── Kreisstadt: Sangerhausen
├── Städte:
│   ├── Sangerhausen
│   ├── Lutherstadt Eisleben
│   ├── Hettstedt
│   └── Mansfeld (gehört zu Mansfeld-Südharz!)
├── Einheitsgemeinden:
│   ├── Allstedt
│   ├── Arnstein
│   ├── Gerbstedt
│   └── Seegebiet Mansfelder Land
├── Verbandsgemeinden:
│   ├── Goldene Aue
│   └── Mansfelder Grund-Helbra
└── Gemeinde:
    └── Südharz
```

### Schritt 3: Neue Behörden-Daten erstellen

```javascript
// src/data/authorities.json - KOMPLETT NEU

const MSH_AUTHORITIES = [
  // === LANDKREIS ===
  {
    id: "lk-msh",
    name: "Landkreis Mansfeld-Südharz",
    type: "landkreis",
    category: "Behörde",
    subcategory: "Kreisverwaltung",
    address: "Rudolf-Breitscheid-Straße 20/22",
    plz: "06526",
    city: "Sangerhausen",
    lat: 51.4725,  // VERIFIZIEREN!
    lng: 11.2980,  // VERIFIZIEREN!
    phone: "03464 535-0",
    fax: "03464 535-1000",
    email: "info@kreis-msh.de",
    website: "https://www.mansfeldsuedharz.de",
    hours: {
      montag: "09:00-12:00, 13:00-15:00",
      dienstag: "09:00-12:00, 13:00-18:00",
      mittwoch: "geschlossen",
      donnerstag: "09:00-12:00, 13:00-15:00",
      freitag: "09:00-12:00"
    },
    services: [
      "Kfz-Zulassung",
      "Führerscheinstelle",
      "Ausländerbehörde",
      "Bauamt",
      "Sozialamt"
    ],
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  // === STÄDTE ===
  {
    id: "stadt-sangerhausen",
    name: "Stadtverwaltung Sangerhausen",
    type: "stadt",
    category: "Behörde",
    subcategory: "Stadtverwaltung",
    address: "Markt 7",
    plz: "06526",
    city: "Sangerhausen",
    lat: 51.4722,  // VERIFIZIEREN!
    lng: 11.2975,  // VERIFIZIEREN!
    phone: "03464 548-0",
    email: "info@sangerhausen.de",
    website: "https://www.sangerhausen.de",
    hours: {
      // Öffnungszeiten recherchieren
    },
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  {
    id: "stadt-eisleben",
    name: "Stadtverwaltung Lutherstadt Eisleben",
    type: "stadt",
    category: "Behörde",
    subcategory: "Stadtverwaltung",
    address: "Markt 1",
    plz: "06295",
    city: "Lutherstadt Eisleben",
    lat: 51.5275,  // VERIFIZIEREN!
    lng: 11.5480,  // VERIFIZIEREN!
    phone: "03475 655-0",
    email: "info@eisleben.eu",
    website: "https://www.eisleben.eu",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  {
    id: "stadt-hettstedt",
    name: "Stadtverwaltung Hettstedt",
    type: "stadt",
    category: "Behörde",
    subcategory: "Stadtverwaltung",
    address: "Markt 1",
    plz: "06333",
    city: "Hettstedt",
    lat: 51.6505,  // VERIFIZIEREN!
    lng: 11.5090,  // VERIFIZIEREN!
    phone: "03476 806-0",
    website: "https://www.hettstedt.de",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  {
    id: "stadt-mansfeld",
    name: "Stadtverwaltung Mansfeld",
    type: "stadt",
    category: "Behörde",
    subcategory: "Stadtverwaltung",
    address: "Am Rathaus 10",
    plz: "06343",
    city: "Mansfeld",
    lat: 51.5960,  // VERIFIZIEREN!
    lng: 11.4550,  // VERIFIZIEREN!
    phone: "034782 79-0",
    website: "https://www.mansfeld.eu",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  // === GEMEINDEN ===
  {
    id: "gemeinde-suedharz",
    name: "Gemeindeverwaltung Südharz",
    type: "gemeinde",
    category: "Behörde",
    subcategory: "Gemeindeverwaltung",
    address: "Marktplatz 1",
    plz: "06536",
    city: "Südharz OT Roßla",
    lat: 51.4650,  // VERIFIZIEREN!
    lng: 11.0680,  // VERIFIZIEREN!
    phone: "034651 300-0",
    website: "https://www.suedharz-harz.de",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  {
    id: "stadt-allstedt",
    name: "Stadtverwaltung Allstedt",
    type: "stadt",
    category: "Behörde",
    subcategory: "Stadtverwaltung",
    address: "Markt 1",
    plz: "06542",
    city: "Allstedt",
    phone: "034652 650",
    website: "https://www.allstedt.de",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  {
    id: "stadt-arnstein",
    name: "Stadtverwaltung Arnstein",
    type: "stadt",
    category: "Behörde",
    subcategory: "Stadtverwaltung",
    plz: "06456",
    city: "Arnstein",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  {
    id: "stadt-gerbstedt",
    name: "Stadtverwaltung Gerbstedt",
    type: "stadt",
    category: "Behörde",
    subcategory: "Stadtverwaltung",
    address: "Markt 1",
    plz: "06347",
    city: "Gerbstedt",
    phone: "034783 70-0",
    website: "https://www.gerbstedt.de",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  {
    id: "gemeinde-seegebiet",
    name: "Gemeindeverwaltung Seegebiet Mansfelder Land",
    type: "gemeinde",
    category: "Behörde",
    subcategory: "Gemeindeverwaltung",
    address: "Markt 1",
    plz: "06317",
    city: "Seegebiet Mansfelder Land OT Röblingen am See",
    phone: "034772 530-0",
    website: "https://www.seegebiet-mansfelder-land.de",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  // === VERBANDSGEMEINDEN ===
  {
    id: "vg-goldene-aue",
    name: "Verbandsgemeinde Goldene Aue",
    type: "verbandsgemeinde",
    category: "Behörde",
    subcategory: "Verbandsgemeindeverwaltung",
    plz: "06526",
    city: "Sangerhausen",
    verified: true,
    verifiedDate: "2025-01-28"
  },
  
  {
    id: "vg-mansfelder-grund",
    name: "Verbandsgemeinde Mansfelder Grund-Helbra",
    type: "verbandsgemeinde",
    category: "Behörde",
    subcategory: "Verbandsgemeindeverwaltung",
    address: "Rathaus, Am Markt 1",
    plz: "06311",
    city: "Helbra",
    phone: "034772 620-0",
    website: "https://www.mansfelder-grund-helbra.de",
    verified: true,
    verifiedDate: "2025-01-28"
  }
];

module.exports = MSH_AUTHORITIES;
```

### Schritt 4: Alle Daten verifizieren

**Für JEDEN Eintrag:**
```
□ Name korrekt?
□ Adresse auf Google Maps gefunden?
□ Koordinaten aus Google Maps übernommen?
□ Telefonnummer funktioniert?
□ Website erreichbar?
□ Öffnungszeiten aktuell?
```

---

## Teil B: Dead Links finden und entfernen

### Schritt 1: Alle URLs extrahieren

```javascript
// scripts/find-all-urls.js

const fs = require('fs');
const path = require('path');

// URL-Pattern
const URL_PATTERN = /https?:\/\/[^\s"'<>]+/g;

function findUrlsInFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const urls = content.match(URL_PATTERN) || [];
  return [...new Set(urls)]; // Duplikate entfernen
}

// Alle relevanten Dateien durchsuchen
const files = [
  ...glob.sync('src/**/*.json'),
  ...glob.sync('src/**/*.js'),
  ...glob.sync('src/**/*.ts'),
  ...glob.sync('src/**/*.tsx'),
];

const allUrls = new Map();

files.forEach(file => {
  const urls = findUrlsInFile(file);
  urls.forEach(url => {
    if (!allUrls.has(url)) {
      allUrls.set(url, []);
    }
    allUrls.get(url).push(file);
  });
});

console.log(`Found ${allUrls.size} unique URLs`);

// Exportieren für Prüfung
fs.writeFileSync('url-list.json', JSON.stringify([...allUrls.entries()], null, 2));
```

### Schritt 2: URLs prüfen

```javascript
// scripts/check-urls.js

const fetch = require('node-fetch');
const urls = require('./url-list.json');

async function checkUrl(url) {
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10000);
    
    const response = await fetch(url, {
      method: 'HEAD',  // Nur Header, schneller
      signal: controller.signal,
      headers: {
        'User-Agent': 'MSH-Map-LinkChecker/1.0'
      }
    });
    
    clearTimeout(timeout);
    
    return {
      url,
      status: response.status,
      ok: response.ok,
      redirected: response.redirected,
      finalUrl: response.url
    };
  } catch (error) {
    return {
      url,
      status: 0,
      ok: false,
      error: error.message
    };
  }
}

async function checkAllUrls() {
  const results = {
    ok: [],
    redirected: [],
    broken: [],
    timeout: []
  };
  
  for (const [url, files] of urls) {
    console.log(`Checking: ${url}`);
    const result = await checkUrl(url);
    result.usedIn = files;
    
    if (result.ok) {
      if (result.redirected) {
        results.redirected.push(result);
      } else {
        results.ok.push(result);
      }
    } else if (result.error?.includes('abort')) {
      results.timeout.push(result);
    } else {
      results.broken.push(result);
    }
    
    // Rate limiting
    await new Promise(r => setTimeout(r, 500));
  }
  
  return results;
}

checkAllUrls().then(results => {
  console.log('\n=== RESULTS ===');
  console.log(`✅ OK: ${results.ok.length}`);
  console.log(`↪️ Redirected: ${results.redirected.length}`);
  console.log(`❌ Broken: ${results.broken.length}`);
  console.log(`⏱️ Timeout: ${results.timeout.length}`);
  
  console.log('\n=== BROKEN URLS ===');
  results.broken.forEach(r => {
    console.log(`${r.url}`);
    console.log(`   Status: ${r.status || r.error}`);
    console.log(`   Used in: ${r.usedIn.join(', ')}`);
  });
  
  fs.writeFileSync('url-check-results.json', JSON.stringify(results, null, 2));
});
```

### Schritt 3: Broken Links beheben

Für jeden kaputten Link:

| URL | Aktion |
|-----|--------|
| 404 - Seite existiert nicht mehr | Entfernen oder neue URL suchen |
| Domain nicht erreichbar | Entfernen |
| Redirect auf andere Domain | Neue URL eintragen |
| SSL-Fehler | http:// versuchen oder entfernen |

```javascript
// Broken Link ersetzen oder entfernen
function fixBrokenUrl(data, oldUrl, newUrl = null) {
  const json = JSON.stringify(data);
  
  if (newUrl) {
    // Ersetzen
    return JSON.parse(json.replace(new RegExp(escapeRegex(oldUrl), 'g'), newUrl));
  } else {
    // Entfernen (website-Feld leeren)
    // Manuell behandeln je nach Datenstruktur
  }
}
```

---

## Checkliste

```
BEHÖRDEN:
[ ] Alle falschen Behörden gelöscht (8 Stück)
[ ] Landkreis MSH eingetragen
[ ] Stadt Sangerhausen eingetragen
[ ] Stadt Eisleben eingetragen
[ ] Stadt Hettstedt eingetragen
[ ] Stadt Mansfeld eingetragen
[ ] Gemeinde Südharz eingetragen
[ ] Alle weiteren Gemeinden eingetragen
[ ] ALLE Koordinaten verifiziert
[ ] ALLE Telefonnummern geprüft
[ ] ALLE Websites erreichbar

DEAD LINKS:
[ ] URL-Extraktion durchgeführt
[ ] Alle URLs geprüft
[ ] Broken Links dokumentiert
[ ] Broken Links behoben/entfernt
[ ] Erneute Prüfung: 0 broken links
```

---

## Deliverables

1. **Behörden-Datei:** Neue, saubere `authorities.json`
2. **Entfernte Behörden:** Liste was gelöscht wurde
3. **URL-Report:** `url-check-results.json`
4. **Behobene Links:** Liste welche URLs korrigiert/entfernt wurden
