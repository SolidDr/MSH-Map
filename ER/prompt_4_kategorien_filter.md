# Prompt 4: Kategorien bereinigen & Filter reparieren

## Probleme

### Kategorisierung
| Problem | Beschreibung |
|---------|--------------|
| Schwimmhallen unter Fitness | Schwimmbäder, Stadtbad etc. falsch kategorisiert |
| Bauernhof-Kategorie leer | Keine Einträge vorhanden |
| Harzer Wandernadel | Nicht als Kategorie auswählbar |

### Filter
| Problem | Beschreibung |
|---------|--------------|
| Altersfilter kaputt | Keine Ergebnisse, Einteilung fraglich |
| Standardeinstellung | Alle Filter an, sollte nur Radwege sein |
| Suche unter Entdecken | Inaktiv/deaktiviert |

---

## Teil A: Kategorien bereinigen

### A1: Sport/Schwimmen Neustrukturierung

**Aktuell (falsch):**
```
Fitness
├── Fitnessstudio A
├── Fitnessstudio B
├── Schwimmhalle  ← FALSCH!
├── Stadtbad      ← FALSCH!
└── Freibad       ← FALSCH!
```

**Neu (korrekt):**
```
Sport & Freizeit
├── Fitness
│   ├── Fitnessstudio A
│   └── Fitnessstudio B
├── Schwimmen
│   ├── Schwimmhalle
│   ├── Stadtbad
│   ├── Freibad
│   └── Hallenbad
├── Sportvereine
└── Sportplätze
```

**ODER einfacher:**
```
Sport
├── Schwimmen (Schwimmhalle, Stadtbad, Freibad, etc.)
├── Fitness (Fitnessstudios)
├── Sportvereine
└── Sportanlagen
```

### Implementierung:

```javascript
// 1. Alle Schwimm-Einträge finden
const SCHWIMM_KEYWORDS = [
  'schwimm',
  'hallenbad',
  'freibad',
  'stadtbad',
  'naturbad',
  'strandbad',
  'pool',
  'aqua',
  'bad '  // Mit Leerzeichen um "Badesee" etc. zu finden
];

function isSchwimmLocation(location) {
  const nameAndDesc = (location.name + ' ' + (location.description || '')).toLowerCase();
  return SCHWIMM_KEYWORDS.some(kw => nameAndDesc.includes(kw));
}

// 2. Kategorie aktualisieren
locations.forEach(loc => {
  if (loc.category === 'Fitness' && isSchwimmLocation(loc)) {
    loc.category = 'Sport';
    loc.subcategory = 'Schwimmen';
  }
});
```

### A2: Kategorie Bauernhof

**Option 1:** Kategorie mit Daten füllen
```javascript
// Recherchiere Bauernhöfe in MSH:
// - Direktvermarkter
// - Hofläden
// - Bauernhofcafés
// - Erlebnisbauernhöfe

const bauernhoefe = [
  // Daten recherchieren und eintragen
];
```

**Option 2:** Leere Kategorie entfernen
```javascript
// Falls keine Daten verfügbar:
// Kategorie aus UI entfernen bis Daten vorhanden
const VISIBLE_CATEGORIES = categories.filter(c => 
  c.count > 0 || c.alwaysShow
);
```

### A3: Harzer Wandernadel als Kategorie

```javascript
// Neue Kategorie erstellen
{
  id: "harzer-wandernadel",
  name: "Harzer Wandernadel",
  icon: "🥾",  // oder eigenes Icon
  description: "Stempelstellen der Harzer Wandernadel",
  color: "#228B22",  // Waldgrün
  parent: "Freizeit",  // oder als Hauptkategorie
  filterable: true
}

// Alle Stempelstellen dieser Kategorie zuordnen
wandernadelStellen.forEach(stelle => {
  stelle.category = "Harzer Wandernadel";
});
```

---

## Teil B: Filter reparieren

### B1: Altersfilter Familie/Kinder

**Problem analysieren:**
```javascript
// Debug: Was passiert beim Filtern?
function applyAgeFilter(ageGroup) {
  console.log('Filter für:', ageGroup);
  
  const filtered = locations.filter(loc => {
    console.log(`Prüfe ${loc.name}:`, loc.ageGroups, loc.familyFriendly);
    return /* Filterbedingung */;
  });
  
  console.log('Ergebnis:', filtered.length, 'Orte');
  return filtered;
}
```

**Mögliche Probleme:**

1. **Keine Altersgruppen-Daten:**
```javascript
// Haben Locations überhaupt ageGroups?
const locationsWithAge = locations.filter(l => l.ageGroups?.length > 0);
console.log(`${locationsWithAge.length} von ${locations.length} haben Altersgruppen`);
```

2. **Falsche Altersgruppen-Einteilung:**
```javascript
// Aktuelle Einteilung prüfen:
// 0-3, 3-6, 6-12, 12+ 

// Besser vielleicht:
const AGE_GROUPS = {
  'baby': { label: 'Baby (0-2)', min: 0, max: 2 },
  'kleinkind': { label: 'Kleinkind (2-5)', min: 2, max: 5 },
  'kind': { label: 'Kind (5-12)', min: 5, max: 12 },
  'jugend': { label: 'Jugendliche (12-18)', min: 12, max: 18 },
  'familie': { label: 'Familien', all: true }
};
```

3. **Filter-Logik falsch:**
```javascript
// FALSCH:
locations.filter(l => l.ageGroup === selectedAge);  // Exakter Match

// RICHTIG:
locations.filter(l => {
  if (!l.ageGroups || l.ageGroups.length === 0) {
    // Keine Altersbeschränkung = für alle geeignet
    return true;
  }
  return l.ageGroups.includes(selectedAge);
});
```

**Fix implementieren:**

```javascript
// Robuster Altersfilter
function filterByAge(locations, ageGroup) {
  if (!ageGroup || ageGroup === 'alle') {
    return locations;
  }
  
  return locations.filter(loc => {
    // Explizit für Altersgruppe markiert
    if (loc.ageGroups?.includes(ageGroup)) return true;
    
    // Als familienfreundlich markiert
    if (loc.familyFriendly && ['0-3', '3-6', '6-12'].includes(ageGroup)) return true;
    
    // Kategorien die typischerweise für Kinder geeignet sind
    const FAMILY_CATEGORIES = ['Spielplatz', 'Zoo', 'Freizeitpark', 'Kindermuseum', 'Schwimmbad'];
    if (FAMILY_CATEGORIES.some(cat => loc.category?.includes(cat))) return true;
    
    // Im Zweifel: lieber anzeigen als verstecken
    return false;
  });
}
```

### B2: Standardeinstellung - Nur Radwege

```javascript
// Initial State setzen
const DEFAULT_FILTERS = {
  // Alle Filter AUS
  categories: [],
  ageGroups: [],
  accessibility: false,
  
  // NUR Radwege AN
  showRadwege: true
};

// Beim App-Start anwenden
function initializeFilters() {
  setFilters(DEFAULT_FILTERS);
  
  // Oder in React:
  const [filters, setFilters] = useState(DEFAULT_FILTERS);
}

// LocalStorage prüfen - falls User eigene Einstellung hat
function loadFilters() {
  const saved = localStorage.getItem('mapFilters');
  if (saved) {
    return JSON.parse(saved);
  }
  return DEFAULT_FILTERS;
}
```

### B3: Suche unter Entdecken reaktivieren

```javascript
// Finde die Suche-Komponente in Entdecken
// Wahrscheinlich ist sie disabled oder hidden

// SUCHE NACH:
grep -r "disabled" --include="*.js" --include="*.tsx" | grep -i "such\|search"
grep -r "display: none\|visibility: hidden" --include="*.css" | grep -i "such\|search"

// FIX:
// Option 1: disabled entfernen
<input type="search" disabled={false} ... />

// Option 2: CSS-Klasse entfernen
searchInput.classList.remove('hidden', 'disabled');

// Option 3: Feature-Flag prüfen
if (FEATURES.searchInDiscover) {  // ← Muss true sein!
  renderSearchBox();
}
```

---

## Teil C: Radweg-Disclaimer

**Anforderung:** Anzeigen ob Radweg vorhanden oder geplant ist.

```javascript
// Datenstruktur erweitern
{
  name: "Radweg Sangerhausen-Eisleben",
  type: "radweg",
  status: "vorhanden",  // "vorhanden" | "geplant" | "im_bau"
  fertigstellung: null,  // Datum bei "geplant"/"im_bau"
  ...
}

// UI anpassen
function RadwegMarker({ radweg }) {
  return (
    <div className="radweg-info">
      <span className="radweg-name">{radweg.name}</span>
      
      {radweg.status === 'vorhanden' && (
        <span className="status status-vorhanden">✓ Vorhanden</span>
      )}
      
      {radweg.status === 'geplant' && (
        <span className="status status-geplant">
          🚧 Geplant
          {radweg.fertigstellung && ` (${radweg.fertigstellung})`}
        </span>
      )}
      
      {radweg.status === 'im_bau' && (
        <span className="status status-bau">
          🏗️ Im Bau
          {radweg.fertigstellung && ` (Fertig: ${radweg.fertigstellung})`}
        </span>
      )}
    </div>
  );
}
```

```css
.status-vorhanden { color: #4CAF50; }
.status-geplant { color: #FF9800; }
.status-bau { color: #2196F3; }
```

---

## Teil D: Entdecken sortieren

**Anforderung:** Alphabetisch und nach Orten sortieren.

```javascript
// Sortieroptionen
const SORT_OPTIONS = {
  'alpha-asc': { label: 'A-Z', fn: (a, b) => a.name.localeCompare(b.name, 'de') },
  'alpha-desc': { label: 'Z-A', fn: (a, b) => b.name.localeCompare(a.name, 'de') },
  'location': { label: 'Nach Ort', fn: (a, b) => (a.city || '').localeCompare(b.city || '', 'de') },
  'distance': { label: 'Entfernung', fn: (a, b) => a.distance - b.distance }  // Falls verfügbar
};

// UI
<select onChange={e => setSortBy(e.target.value)}>
  <option value="alpha-asc">A-Z</option>
  <option value="alpha-desc">Z-A</option>
  <option value="location">Nach Ort</option>
</select>

// Sortierung anwenden
const sortedItems = [...items].sort(SORT_OPTIONS[sortBy].fn);
```

---

## Checkliste

```
KATEGORIEN:
[ ] Schwimmhallen von Fitness nach Sport/Schwimmen verschoben
[ ] Kategorie-Struktur vereinheitlicht
[ ] Bauernhof-Kategorie: Daten hinzufügen ODER ausblenden
[ ] Harzer Wandernadel als Kategorie auswählbar

FILTER:
[ ] Altersfilter funktioniert
[ ] Altersfilter zeigt Ergebnisse
[ ] Standardeinstellung: Nur Radwege an
[ ] Suche unter Entdecken aktiv

ZUSATZ:
[ ] Radweg-Status (vorhanden/geplant) wird angezeigt
[ ] Entdecken-Liste sortierbar (Alphabet, Ort)
```

---

## Deliverables

1. **Kategorie-Mapping:** Was wurde wie umkategorisiert
2. **Filter-Fix:** Was war das Problem, wie wurde es gelöst
3. **Neue Standardeinstellung:** Screenshot/Bestätigung
4. **Sortier-Funktion:** Screenshot der neuen Optionen
