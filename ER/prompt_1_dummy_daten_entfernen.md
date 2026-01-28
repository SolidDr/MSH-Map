# Prompt 1: Dummy/Fake-Daten ENDGÜLTIG entfernen

## ⚠️ HÖCHSTE PRIORITÄT - NULLTOLERANZ

> **Diese Aufgabe hat oberste Priorität!**
> 
> Es dürfen KEINE Dummy-, Mockup-, Test- oder Fake-Daten mehr existieren.
> Bei Gesundheitsdaten (Ärzte, Apotheken, AEDs, Notdienste) kann das Leben kosten!

---

## Deine Aufgabe

Führe einen **vollständigen Audit** der gesamten Codebasis durch und entferne ALLE nicht-echten Daten.

---

## Phase 1: Systematische Suche

### 1.1 Textbasierte Suche

Durchsuche ALLE Dateien nach folgenden Begriffen:

```bash
# Dummy-Indikatoren
grep -ri "dummy" --include="*.js" --include="*.ts" --include="*.json" --include="*.tsx" --include="*.jsx"
grep -ri "mock" --include="*.js" --include="*.ts" --include="*.json" --include="*.tsx" --include="*.jsx"
grep -ri "fake" --include="*.js" --include="*.ts" --include="*.json" --include="*.tsx" --include="*.jsx"
grep -ri "test" --include="*.json"  # Vorsicht: nicht Test-Dateien löschen!
grep -ri "example" --include="*.json"
grep -ri "sample" --include="*.json"
grep -ri "placeholder" --include="*.js" --include="*.ts" --include="*.json"
grep -ri "lorem" --include="*.js" --include="*.ts" --include="*.json"
grep -ri "todo" --include="*.json"  # Oft Platzhalter
grep -ri "xxx" --include="*.json"
grep -ri "123" --include="*.json"  # Fake Telefonnummern wie 123456

# Bekannte Dummy-Einträge aus dem Review
grep -ri "lochness" --include="*.js" --include="*.ts" --include="*.json"
grep -ri "loch ness" --include="*.js" --include="*.ts" --include="*.json"
grep -ri "sus pup" --include="*.js" --include="*.ts" --include="*.json"
grep -ri "suspup" --include="*.js" --include="*.ts" --include="*.json"
```

### 1.2 Muster-Erkennung

Suche nach verdächtigen Mustern:

```javascript
// Verdächtige Telefonnummern
/0{5,}/           // 00000...
/1234/            // 1234...
/0800.*000/       // Fake Hotlines
/555/             // Amerikanische Fake-Nummern

// Verdächtige Koordinaten
/0\.0+,\s*0\.0+/  // 0.0, 0.0
/51\.0+,\s*11\.0+/ // Zu runde Koordinaten

// Verdächtige URLs
/example\.com/
/test\.de/
/localhost/
/127\.0\.0\.1/

// Verdächtige Namen
/Max Mustermann/i
/Erika Mustermann/i
/John Doe/i
/Jane Doe/i
/Test.*Apotheke/i
/Dummy/i
```

### 1.3 Datenbank/JSON-Dateien prüfen

Liste ALLE JSON/Daten-Dateien auf:

```bash
find . -name "*.json" -type f | grep -v node_modules | grep -v package
```

Für JEDE Datei:
1. Öffne die Datei
2. Prüfe JEDEN Eintrag auf Echtheit
3. Dokumentiere verdächtige Einträge

---

## Phase 2: Bekannte Dummy-Einträge entfernen

### Sofort löschen:

| Eintrag | Typ | Aktion |
|---------|-----|--------|
| "Lochness" | Dummy | LÖSCHEN |
| "Sus Pup" | Nicht mehr existent | LÖSCHEN |

### Vorgehen:

```javascript
// NICHT einfach auskommentieren - KOMPLETT ENTFERNEN!

// FALSCH:
// { name: "Lochness", ... }  // Dummy - auskommentiert

// RICHTIG:
// Zeile komplett gelöscht, keine Spur mehr vorhanden
```

---

## Phase 3: Gesundheitsdaten-Audit (KRITISCH!)

### 3.1 Apotheken

Für JEDE Apotheke in der Datenbank:

```
□ Name korrekt geschrieben?
□ Adresse existiert? (Google Maps verifizieren)
□ Koordinaten stimmen mit Adresse überein?
□ Telefonnummer gültig? (Format prüfen)
□ Website erreichbar? (HTTP-Request testen)
□ Öffnungszeiten plausibel?
□ Notdienst-Info aktuell?
```

### 3.2 Ärzte

Für JEDEN Arzt in der Datenbank:

```
□ Name und Titel korrekt?
□ Fachrichtung plausibel?
□ Adresse existiert?
□ Koordinaten korrekt?
□ Telefonnummer gültig?
□ Kassenzulassung-Info korrekt?
```

### 3.3 AEDs (Defibrillatoren)

Für JEDEN AED:

```
□ Standort existiert?
□ Koordinaten EXAKT? (Meter-genau!)
□ Zugänglichkeit-Info korrekt?
□ 24/7 oder eingeschränkt?
```

### 3.4 Warnstellen

Für JEDE Warnung:

```
□ Warnung noch aktuell?
□ Position korrekt?
□ Beschreibung akkurat?
□ Veraltete Warnungen entfernt?
```

---

## Phase 4: Code-Säuberung

### 4.1 Entwickler-Kommentare entfernen

```javascript
// ENTFERNEN:
// TODO: Echte Daten einfügen
// FIXME: Dummy-Daten
// HACK: Temporäre Testdaten
// XXX: Placeholder
```

### 4.2 Bedingte Dummy-Logik entfernen

```javascript
// ENTFERNEN:
if (process.env.NODE_ENV === 'development') {
  data = dummyData;  // <-- DIESE GANZE LOGIK WEG!
}

// ENTFERNEN:
const useMockData = true;  // <-- WEG!

// ENTFERNEN:
import { mockLocations } from './mocks';  // <-- WEG!
```

### 4.3 Test-Dateien von Produktionsdaten trennen

```
/src/data/
├── locations.json      ← NUR ECHTE DATEN
├── pharmacies.json     ← NUR ECHTE DATEN
└── doctors.json        ← NUR ECHTE DATEN

/src/__tests__/
├── fixtures/
│   └── mock-data.json  ← Test-Daten NUR hier (nicht in Production)
```

---

## Phase 5: Verifikations-Script erstellen

Erstelle ein Script das automatisch prüft:

```javascript
// scripts/verify-data-integrity.js

const fs = require('fs');
const path = require('path');

const FORBIDDEN_PATTERNS = [
  /dummy/i,
  /mock/i,
  /fake/i,
  /placeholder/i,
  /lorem/i,
  /example\.com/i,
  /test\.de/i,
  /lochness/i,
  /sus\s?pup/i,
  /max\s?mustermann/i,
  /0{5,}/,  // Fake Telefonnummern
  /^0\.0+$/,  // Null-Koordinaten
];

const SUSPICIOUS_COORDS = {
  lat: { min: 51.3, max: 51.7 },  // MSH Bereich
  lng: { min: 11.0, max: 11.8 }
};

function verifyDataFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const issues = [];
  
  // Pattern-Check
  FORBIDDEN_PATTERNS.forEach(pattern => {
    if (pattern.test(content)) {
      issues.push(`FORBIDDEN PATTERN FOUND: ${pattern}`);
    }
  });
  
  // JSON-Daten prüfen
  try {
    const data = JSON.parse(content);
    if (Array.isArray(data)) {
      data.forEach((item, index) => {
        // Koordinaten prüfen
        if (item.lat !== undefined && item.lng !== undefined) {
          if (item.lat < SUSPICIOUS_COORDS.lat.min || 
              item.lat > SUSPICIOUS_COORDS.lat.max ||
              item.lng < SUSPICIOUS_COORDS.lng.min || 
              item.lng > SUSPICIOUS_COORDS.lng.max) {
            issues.push(`SUSPICIOUS COORDS at index ${index}: ${item.lat}, ${item.lng}`);
          }
        }
        
        // Null-Koordinaten
        if (item.lat === 0 || item.lng === 0) {
          issues.push(`NULL COORDS at index ${index}: ${item.name}`);
        }
      });
    }
  } catch (e) {
    // Nicht-JSON Datei - nur Pattern-Check
  }
  
  return issues;
}

// Alle relevanten Dateien prüfen
const dataDir = './src/data';
const files = fs.readdirSync(dataDir).filter(f => f.endsWith('.json'));

let hasIssues = false;

files.forEach(file => {
  const issues = verifyDataFile(path.join(dataDir, file));
  if (issues.length > 0) {
    console.error(`\n❌ ISSUES IN ${file}:`);
    issues.forEach(i => console.error(`   - ${i}`));
    hasIssues = true;
  } else {
    console.log(`✅ ${file} - OK`);
  }
});

if (hasIssues) {
  console.error('\n🚨 DATA INTEGRITY CHECK FAILED!');
  process.exit(1);
} else {
  console.log('\n✅ ALL DATA FILES VERIFIED');
}
```

### In package.json einbinden:

```json
{
  "scripts": {
    "verify-data": "node scripts/verify-data-integrity.js",
    "prebuild": "npm run verify-data"
  }
}
```

---

## Checkliste nach Abschluss

```
DUMMY-DATEN ENTFERNT:
[ ] "Lochness" Eintrag gelöscht
[ ] "Sus Pup" Eintrag gelöscht
[ ] Grep nach "dummy" = 0 Ergebnisse in Daten-Dateien
[ ] Grep nach "mock" = 0 Ergebnisse in Daten-Dateien
[ ] Grep nach "fake" = 0 Ergebnisse in Daten-Dateien
[ ] Grep nach "placeholder" = 0 Ergebnisse in Daten-Dateien

GESUNDHEITSDATEN VERIFIZIERT:
[ ] Alle Apotheken-Einträge geprüft
[ ] Alle Arzt-Einträge geprüft
[ ] Alle AED-Einträge geprüft
[ ] Alle Warnstellen geprüft

CODE GESÄUBERT:
[ ] Keine Import-Statements für Mock-Daten
[ ] Keine bedingte Dummy-Logik
[ ] Keine TODO/FIXME für Dummy-Daten

VERIFIKATION:
[ ] verify-data Script erstellt
[ ] Script läuft erfolgreich durch
[ ] Script in Build-Prozess eingebunden
```

---

## Deliverables

Nach Abschluss dokumentiere:

1. **Liste aller entfernten Einträge** (Name, Typ, Datei)
2. **Liste aller korrigierten Einträge** (was war falsch, was ist jetzt richtig)
3. **Ergebnis des Verifikations-Scripts**
4. **Bestätigung:** "Keine Dummy-Daten mehr vorhanden"

---

## ⚠️ WICHTIG

**NIEMALS** Dummy-Daten nur auskommentieren oder verstecken.
**IMMER** komplett entfernen und die Änderung committen.

Bei Unsicherheit ob ein Eintrag echt ist:
1. Google-Suche nach Name + Ort
2. Google Maps überprüfen
3. Offizielle Verzeichnisse prüfen (Apothekerkammer, KV, etc.)
4. Im Zweifel: ENTFERNEN und später mit verifizierten Daten ergänzen
