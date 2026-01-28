# Prompt 6: Qualitätssicherung - Vollständiger Daten-Audit

## ⚠️ MISSION CRITICAL

> **Dieser Prompt stellt sicher, dass KEINE Dummy/Fake-Daten mehr existieren.**
> 
> Nach Abschluss dieses Audits muss die App zu 100% produktionsreif sein.
> Besonders bei Gesundheitsdaten gibt es NULL Toleranz für Fehler.

---

## Ziel

Nach diesem Audit:
- ✅ 0 Dummy-Einträge
- ✅ 0 Mockup-Daten
- ✅ 0 falsche Koordinaten
- ✅ 0 tote Links
- ✅ 0 nicht-MSH Behörden
- ✅ 100% verifizierte Gesundheitsdaten

---

## Phase 1: Automatisierte Prüfung

### 1.1 Master-Audit-Script erstellen

```javascript
// scripts/master-audit.js
// Führt ALLE Prüfungen durch und erstellt Bericht

const fs = require('fs');
const path = require('path');

// Konfiguration
const DATA_DIR = './src/data';
const REPORT_FILE = './audit-report.json';

// ============ PRÜFUNGEN ============

const FORBIDDEN_PATTERNS = [
  // Dummy-Indikatoren
  { pattern: /dummy/i, severity: 'CRITICAL', message: 'Dummy-Begriff gefunden' },
  { pattern: /mock/i, severity: 'CRITICAL', message: 'Mock-Begriff gefunden' },
  { pattern: /fake/i, severity: 'CRITICAL', message: 'Fake-Begriff gefunden' },
  { pattern: /test(?!er)/i, severity: 'WARNING', message: 'Test-Begriff gefunden (prüfen!)' },
  { pattern: /placeholder/i, severity: 'CRITICAL', message: 'Placeholder gefunden' },
  { pattern: /lorem/i, severity: 'CRITICAL', message: 'Lorem Ipsum gefunden' },
  { pattern: /example\.com/i, severity: 'CRITICAL', message: 'Example.com URL' },
  { pattern: /todo/i, severity: 'WARNING', message: 'TODO gefunden' },
  
  // Bekannte Dummy-Einträge
  { pattern: /loch\s?ness/i, severity: 'CRITICAL', message: 'LOCHNESS Dummy-Eintrag!' },
  { pattern: /sus\s?pup/i, severity: 'CRITICAL', message: 'SUS PUP existiert nicht mehr!' },
  
  // Falsche Behörden
  { pattern: /bad frankenhausen/i, severity: 'CRITICAL', message: 'Nicht-MSH Behörde!' },
  { pattern: /nordhausen/i, severity: 'CRITICAL', message: 'Nicht-MSH Behörde!' },
  { pattern: /sondershausen/i, severity: 'CRITICAL', message: 'Nicht-MSH Behörde!' },
  { pattern: /artern/i, severity: 'CRITICAL', message: 'Nicht-MSH Behörde!' },
  { pattern: /kyffhäuser/i, severity: 'CRITICAL', message: 'Nicht-MSH Behörde!' },
  { pattern: /harzgerode/i, severity: 'CRITICAL', message: 'Nicht-MSH Behörde!' },
  
  // Fake Kontaktdaten
  { pattern: /0{6,}/i, severity: 'CRITICAL', message: 'Fake Telefonnummer (000000)' },
  { pattern: /123456/i, severity: 'WARNING', message: 'Verdächtige Nummer (123456)' },
  { pattern: /max\s?mustermann/i, severity: 'CRITICAL', message: 'Fake Name' },
  { pattern: /erika\s?mustermann/i, severity: 'CRITICAL', message: 'Fake Name' },
];

// MSH Koordinaten-Bereich
const MSH_BOUNDS = {
  lat: { min: 51.35, max: 51.70 },
  lng: { min: 10.95, max: 11.85 }
};

// ============ AUDIT FUNKTIONEN ============

function auditFile(filePath) {
  const issues = [];
  const content = fs.readFileSync(filePath, 'utf8');
  const fileName = path.basename(filePath);
  
  // Pattern-Prüfung
  FORBIDDEN_PATTERNS.forEach(({ pattern, severity, message }) => {
    const matches = content.match(new RegExp(pattern, 'gi'));
    if (matches) {
      issues.push({
        file: fileName,
        severity,
        type: 'FORBIDDEN_PATTERN',
        message,
        matches: matches.slice(0, 5),
        count: matches.length
      });
    }
  });
  
  // JSON-spezifische Prüfungen
  if (filePath.endsWith('.json')) {
    try {
      const data = JSON.parse(content);
      const entries = Array.isArray(data) ? data : [data];
      
      entries.forEach((entry, index) => {
        // Koordinaten-Prüfung
        if (entry.lat !== undefined && entry.lng !== undefined) {
          if (entry.lat === 0 || entry.lng === 0) {
            issues.push({
              file: fileName,
              severity: 'CRITICAL',
              type: 'NULL_COORDINATES',
              message: `Null-Koordinaten bei "${entry.name || index}"`,
              data: { lat: entry.lat, lng: entry.lng }
            });
          }
          
          if (entry.lat < MSH_BOUNDS.lat.min || entry.lat > MSH_BOUNDS.lat.max ||
              entry.lng < MSH_BOUNDS.lng.min || entry.lng > MSH_BOUNDS.lng.max) {
            issues.push({
              file: fileName,
              severity: 'WARNING',
              type: 'COORDS_OUTSIDE_MSH',
              message: `Koordinaten außerhalb MSH bei "${entry.name || index}"`,
              data: { lat: entry.lat, lng: entry.lng }
            });
          }
        }
        
        if (entry.name === '' || entry.name === null) {
          issues.push({
            file: fileName,
            severity: 'CRITICAL',
            type: 'EMPTY_NAME',
            message: `Leerer Name bei Index ${index}`
          });
        }
      });
    } catch (e) {
      // Parse error - ignorieren
    }
  }
  
  return issues;
}

function runFullAudit() {
  console.log('🔍 Starte vollständigen Daten-Audit...\n');
  
  const report = {
    timestamp: new Date().toISOString(),
    files: [],
    summary: {
      totalFiles: 0,
      totalIssues: 0,
      critical: 0,
      warning: 0,
      passed: 0
    }
  };
  
  const files = [];
  
  function walkDir(dir) {
    if (!fs.existsSync(dir)) return;
    const items = fs.readdirSync(dir);
    items.forEach(item => {
      const fullPath = path.join(dir, item);
      if (fs.statSync(fullPath).isDirectory()) {
        if (!item.includes('node_modules') && !item.startsWith('.')) {
          walkDir(fullPath);
        }
      } else if (item.endsWith('.json') || item.endsWith('.js') || item.endsWith('.ts')) {
        files.push(fullPath);
      }
    });
  }
  
  walkDir(DATA_DIR);
  walkDir('./src');
  
  files.forEach(file => {
    const issues = auditFile(file);
    const fileReport = {
      path: file,
      issues,
      status: issues.length === 0 ? 'PASSED' : 
              issues.some(i => i.severity === 'CRITICAL') ? 'FAILED' : 'WARNING'
    };
    
    report.files.push(fileReport);
    report.summary.totalFiles++;
    report.summary.totalIssues += issues.length;
    report.summary.critical += issues.filter(i => i.severity === 'CRITICAL').length;
    report.summary.warning += issues.filter(i => i.severity === 'WARNING').length;
    
    if (issues.length === 0) {
      report.summary.passed++;
      console.log(`✅ ${path.basename(file)}`);
    } else {
      const criticalCount = issues.filter(i => i.severity === 'CRITICAL').length;
      if (criticalCount > 0) {
        console.log(`❌ ${path.basename(file)} - ${criticalCount} KRITISCHE Fehler`);
      } else {
        console.log(`⚠️  ${path.basename(file)} - ${issues.length} Warnungen`);
      }
    }
  });
  
  fs.writeFileSync(REPORT_FILE, JSON.stringify(report, null, 2));
  
  console.log('\n' + '='.repeat(50));
  console.log('📊 AUDIT ZUSAMMENFASSUNG');
  console.log('='.repeat(50));
  console.log(`Geprüfte Dateien:  ${report.summary.totalFiles}`);
  console.log(`Bestanden:         ${report.summary.passed}`);
  console.log(`Kritische Fehler:  ${report.summary.critical}`);
  console.log(`Warnungen:         ${report.summary.warning}`);
  console.log('='.repeat(50));
  
  if (report.summary.critical > 0) {
    console.log('\n🚨 AUDIT FEHLGESCHLAGEN!\n');
    
    report.files.forEach(file => {
      const critical = file.issues.filter(i => i.severity === 'CRITICAL');
      if (critical.length > 0) {
        console.log(`\n❌ ${file.path}:`);
        critical.forEach(issue => {
          console.log(`   - ${issue.message}`);
          if (issue.matches) {
            console.log(`     Gefunden: ${issue.matches.join(', ')}`);
          }
        });
      }
    });
    
    process.exit(1);
  } else {
    console.log('\n✅ AUDIT BESTANDEN!\n');
    process.exit(0);
  }
}

runFullAudit();
```

### 1.2 In package.json einbinden

```json
{
  "scripts": {
    "audit": "node scripts/master-audit.js",
    "precommit": "npm run audit",
    "prebuild": "npm run audit"
  }
}
```

---

## Phase 2: Manuelle Verifizierung

### 2.1 Gesundheitsdaten Checkliste

**JEDER Eintrag muss manuell geprüft werden!**

#### Apotheken

| Name | Adresse OK | Koordinaten OK | Tel OK | Website OK | ✓ |
|------|------------|----------------|--------|------------|---|
| Mammut Apotheke | □ | □ | □ | □ | □ |
| Barbarossa Apotheke | □ | □ | □ | □ | □ |
| [Weitere...] | □ | □ | □ | □ | □ |

**Prüfmethode:**
1. Name in Google suchen
2. Adresse auf Google Maps verifizieren
3. Koordinaten mit Adresse abgleichen
4. Telefonnummer Format prüfen
5. Website öffnen

#### Ärzte

| Name | Fachrichtung | Adresse OK | Koordinaten OK | ✓ |
|------|--------------|------------|----------------|---|
| Dr. [Name] | [Fach] | □ | □ | □ |

#### AEDs (Defibrillatoren)

| Standort | Koordinaten EXAKT | 24/7? | ✓ |
|----------|-------------------|-------|---|
| [Standort] | □ | □ | □ |

**⚠️ Bei AEDs müssen Koordinaten METER-GENAU sein!**

### 2.2 Behörden Checkliste

| Behörde | Gehört zu MSH | Status |
|---------|---------------|--------|
| Landkreis MSH | ✅ | □ Verifiziert |
| Stadt Sangerhausen | ✅ | □ Verifiziert |
| Bad Frankenhausen | ❌ | □ GELÖSCHT |
| Nordhausen | ❌ | □ GELÖSCHT |

### 2.3 Bekannte Dummy-Einträge

| Eintrag | Status |
|---------|--------|
| Lochness | □ GELÖSCHT |
| Sus Pup | □ GELÖSCHT |

---

## Phase 3: Link-Verifizierung

### 3.1 Link-Check Script

```javascript
// scripts/check-links.js

const fetch = require('node-fetch');
const fs = require('fs');

async function checkAllLinks() {
  const dataFiles = fs.readdirSync('./src/data').filter(f => f.endsWith('.json'));
  const allUrls = new Set();
  
  dataFiles.forEach(file => {
    const content = fs.readFileSync(`./src/data/${file}`, 'utf8');
    const urlMatches = content.match(/https?:\/\/[^\s"',\]]+/g) || [];
    urlMatches.forEach(url => allUrls.add(url.replace(/[",\]]+$/, '')));
  });
  
  console.log(`Prüfe ${allUrls.size} URLs...\n`);
  
  const broken = [];
  
  for (const url of allUrls) {
    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 10000);
      
      const response = await fetch(url, {
        method: 'HEAD',
        signal: controller.signal
      });
      
      clearTimeout(timeout);
      
      if (!response.ok) {
        broken.push({ url, status: response.status });
        process.stdout.write('✗');
      } else {
        process.stdout.write('✓');
      }
    } catch (error) {
      broken.push({ url, error: error.message });
      process.stdout.write('✗');
    }
    
    await new Promise(r => setTimeout(r, 300));
  }
  
  console.log(`\n\n❌ Kaputte Links: ${broken.length}`);
  
  if (broken.length > 0) {
    broken.forEach(r => console.log(`  ${r.url} → ${r.status || r.error}`));
  }
  
  fs.writeFileSync('link-check-results.json', JSON.stringify(broken, null, 2));
  
  return broken.length === 0;
}

checkAllLinks().then(success => process.exit(success ? 0 : 1));
```

---

## Phase 4: Acceptance Criteria

**Das Audit ist NUR bestanden wenn:**

```
[ ] npm run audit → Exit Code 0
[ ] Keine CRITICAL Issues
[ ] Link-Check: 0 broken links
[ ] Alle Apotheken manuell verifiziert
[ ] Alle Ärzte manuell verifiziert
[ ] Alle AEDs manuell verifiziert
[ ] Nur MSH-Behörden in der Liste
[ ] "Lochness" gelöscht
[ ] "Sus Pup" gelöscht
[ ] Mammut Apotheke korrigiert
[ ] Barbarossa Apotheke korrigiert
[ ] Tierheim Pin korrigiert
[ ] Tafel Pin korrigiert
```

---

## Phase 5: Sign-Off

```
DATENQUALITÄTS-BESTÄTIGUNG

Hiermit bestätige ich, dass:

[ ] Alle Dummy-/Mockup-Daten entfernt wurden
[ ] Alle Gesundheitsdaten verifiziert sind
[ ] Alle Koordinaten korrekt sind
[ ] Alle Behörden zum Landkreis MSH gehören
[ ] Alle Links funktionieren
[ ] Das automatische Audit bestanden wurde

Datum: _______________
Name: _______________
```

---

## Deliverables

1. **audit-report.json** - Automatischer Audit-Bericht
2. **link-check-results.json** - Link-Prüfungsergebnis
3. **CHANGELOG.md** - Änderungsprotokoll
4. **Bestätigung:** "Datenqualität zu 100% gewährleistet"

---

## ⚠️ WICHTIG

**Dieser Audit muss VOR jedem Release durchgeführt werden!**

```bash
npm run audit && node scripts/check-links.js && echo "✅ Ready for release"
```

Wenn einer der Checks fehlschlägt → **KEIN RELEASE!**
