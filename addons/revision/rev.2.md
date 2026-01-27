# MSH Map Analytics - Rev.2 Bugfix Master-Prompt

## Projektkontext

Du arbeitest an **MSH Map Analytics**, einer interaktiven Karten-Anwendung für den Landkreis Mansfeld-Südharz. Die App zeigt Orte, Events, ÖPNV und mehr.

**Technologie-Stack prüfen:** Identifiziere zuerst welche Frameworks/Libraries verwendet werden (React, Vue, Vanilla JS, Leaflet, etc.)

---

## Arbeitsweise

1. **Vor jeder Änderung:** Analysiere den bestehenden Code
2. **Eine Sache nach der anderen:** Nicht mehrere Bugs gleichzeitig
3. **Teste nach jeder Änderung**
4. **Dokumentiere was du geändert hast**

---

# PHASE 1: KRITISCHE BUGS

## Bug 1.1: Warnbanner komplett fixen

### Problem
Der Warnbanner am oberen Bildschirmrand funktioniert nicht vollständig.

### Anforderungen
- [ ] Banner überall klickbar machen (gesamte Fläche)
- [ ] Warnungen nach Priorität sortieren (höchste zuerst)
- [ ] Warnung auf der Karte als Marker/Icon anzeigen
- [ ] Bei Klick auf Banner → Karte zoomt/springt zum betroffenen Punkt
- [ ] Animation beim Sprung (smooth pan/zoom)

### Implementierung
```javascript
// Pseudo-Code Struktur
const warnings = [
  { id: 1, title: "Straßensperrung", priority: "high", lat: 51.47, lng: 11.29, location: "Sangerhäuser Straße" },
  { id: 2, title: "Baustelle", priority: "medium", lat: 51.48, lng: 11.30, location: "Marktplatz" }
];

// Sortierung nach Priorität
const priorityOrder = { critical: 0, high: 1, medium: 2, low: 3 };
warnings.sort((a, b) => priorityOrder[a.priority] - priorityOrder[b.priority]);

// Klick-Handler
warningBanner.addEventListener('click', () => {
  const warning = getCurrentWarning();
  map.flyTo([warning.lat, warning.lng], 16, { duration: 1.5 });
  openWarningPopup(warning);
});
```

### Test
- Klick auf Banner → Karte springt zum richtigen Punkt
- Mehrere Warnungen → Höchste Priorität wird zuerst angezeigt
- Warnung ist auf Karte sichtbar (Icon/Marker)

---

## Bug 1.2: Entdecken → Kartenpin Navigation

### Problem
In "Entdecken" → z.B. "Kaffee" → Liste der Cafés → Klick auf Eintrag springt NICHT zum Kartenpin.

### Anforderungen
- [ ] Klick auf Listeneintrag → Karte öffnen mit Fokus auf diesen Ort
- [ ] Pin hervorheben (bounce animation oder highlight)
- [ ] Popup/Info-Fenster des Ortes öffnen

### Implementierung
```javascript
// In der Listen-Komponente
function handleLocationClick(location) {
  // 1. Zur Karten-Ansicht wechseln
  navigateToView('karte');
  
  // 2. Zur Position fliegen
  map.flyTo([location.lat, location.lng], 17, { duration: 1 });
  
  // 3. Marker hervorheben
  const marker = findMarkerById(location.id);
  if (marker) {
    marker.openPopup();
    highlightMarker(marker);
  }
}

// Highlight-Animation
function highlightMarker(marker) {
  marker.getElement()?.classList.add('marker-highlight');
  setTimeout(() => {
    marker.getElement()?.classList.remove('marker-highlight');
  }, 3000);
}
```

```css
.marker-highlight {
  animation: bounce 0.5s ease-in-out 3;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}
```

### Test
- Entdecken → Kaffee → Klick auf "Café XY" → Karte zeigt Café XY
- Pin ist sichtbar hervorgehoben
- Popup öffnet sich

---

## Bug 1.3: Verlinkungen global reparieren

### Problem
Verschiedene Links im System führen ins Leere oder funktionieren nicht.

### Vorgehen
```
1. Suche nach allen <a href="...">, router.push(), navigate() etc.
2. Liste alle defekten Links auf
3. Prüfe ob Ziel existiert
4. Repariere oder entferne defekte Links
```

### Checkliste
- [ ] Navigation Links (Menü)
- [ ] Karten-Popups → Detail-Links
- [ ] Listen → Detail-Links
- [ ] Footer-Links
- [ ] Externe Links (target="_blank" + rel="noopener")

---

## Bug 1.4: Suchbegriffe erweitern

### Problem
Suchbegriff "schwimm" findet nichts, obwohl Schwimmbäder existieren.

### Ursache (zu prüfen)
- Nur exakte Matches?
- Keine Teilwort-Suche?
- Fehlende Synonyme/Tags?

### Lösung
```javascript
// Fuzzy/Partial Search implementieren
function search(query) {
  const lowerQuery = query.toLowerCase();
  
  return locations.filter(loc => {
    // Name
    if (loc.name.toLowerCase().includes(lowerQuery)) return true;
    
    // Kategorie
    if (loc.category.toLowerCase().includes(lowerQuery)) return true;
    
    // Tags/Keywords
    if (loc.tags?.some(tag => tag.toLowerCase().includes(lowerQuery))) return true;
    
    // Synonyme
    const synonyms = getSynonyms(lowerQuery);
    if (synonyms.some(syn => 
      loc.name.toLowerCase().includes(syn) ||
      loc.category.toLowerCase().includes(syn) ||
      loc.tags?.some(tag => tag.toLowerCase().includes(syn))
    )) return true;
    
    return false;
  });
}

// Synonym-Mapping
const SYNONYMS = {
  'schwimm': ['schwimmbad', 'hallenbad', 'freibad', 'pool', 'baden'],
  'essen': ['restaurant', 'gastro', 'küche', 'speisen'],
  'arzt': ['doktor', 'praxis', 'medizin', 'gesundheit'],
  'kaffee': ['café', 'cafe', 'coffee'],
  // ... weitere
};

function getSynonyms(term) {
  for (const [key, values] of Object.entries(SYNONYMS)) {
    if (key.includes(term) || values.some(v => v.includes(term))) {
      return [key, ...values];
    }
  }
  return [term];
}
```

### Test
- "schwimm" → findet Schwimmbäder
- "kaffee" → findet Cafés
- "doc" → findet Ärzte

---

## Bug 1.5: Mobilität - Verbindungen Autocomplete

### Problem
Autocomplete bei Verbindungssuche funktioniert nicht. Soll auf Google Maps weiterleiten.

### Anforderungen
- [ ] Autocomplete für Start und Ziel
- [ ] Haltestellen/Orte vorschlagen
- [ ] Bei Suche → Google Maps öffnen mit Route

### Implementierung
```javascript
// Autocomplete für Haltestellen
const stops = await loadStops(); // Alle Haltestellen laden

startInput.addEventListener('input', (e) => {
  const suggestions = filterStops(e.target.value, stops);
  showSuggestions(suggestions, startDropdown);
});

// Google Maps Weiterleitung
function searchConnection(start, destination) {
  const googleMapsUrl = new URL('https://www.google.com/maps/dir/');
  googleMapsUrl.searchParams.set('api', '1');
  googleMapsUrl.searchParams.set('origin', start);
  googleMapsUrl.searchParams.set('destination', destination);
  googleMapsUrl.searchParams.set('travelmode', 'transit');
  
  window.open(googleMapsUrl.toString(), '_blank');
}

// Alternative: Deutsche Bahn
function searchDB(start, destination) {
  const dbUrl = `https://reiseauskunft.bahn.de/bin/query.exe/dn?S=${encodeURIComponent(start)}&Z=${encodeURIComponent(destination)}`;
  window.open(dbUrl, '_blank');
}
```

---

## Bug 1.6: Mobilität - Haltestellen "Keine gefunden"

### Problem
"Haltestellen in der Nähe" zeigt immer "Keine gefunden".

### Mögliche Ursachen
- [ ] Geolocation Permission nicht erteilt
- [ ] Haltestellen-Daten nicht geladen
- [ ] Radius zu klein
- [ ] Koordinaten-Format falsch

### Debugging
```javascript
async function findNearbyStops() {
  // 1. Geolocation prüfen
  console.log('Checking geolocation...');
  
  if (!navigator.geolocation) {
    console.error('Geolocation nicht unterstützt');
    return showError('Standort nicht verfügbar');
  }
  
  try {
    const position = await getCurrentPosition();
    console.log('Position:', position.coords.latitude, position.coords.longitude);
    
    // 2. Haltestellen-Daten prüfen
    const stops = await getStops();
    console.log('Anzahl Haltestellen:', stops.length);
    
    if (stops.length === 0) {
      console.error('Keine Haltestellen-Daten!');
      return showError('Daten nicht verfügbar');
    }
    
    // 3. Suche mit größerem Radius
    const nearbyStops = stops.filter(stop => {
      const distance = calculateDistance(
        position.coords.latitude,
        position.coords.longitude,
        stop.lat,
        stop.lng
      );
      console.log(`${stop.name}: ${distance}m`);
      return distance <= 2000; // 2km Radius
    });
    
    console.log('Gefunden:', nearbyStops.length);
    
    if (nearbyStops.length === 0) {
      return showInfo('Keine Haltestellen im Umkreis von 2km');
    }
    
    displayStops(nearbyStops);
    
  } catch (error) {
    console.error('Fehler:', error);
    showError('Standort konnte nicht ermittelt werden');
  }
}
```

---

# PHASE 2: WICHTIGE FEATURES

## Bug 2.1: Erleben → Mitmachen Verlinkungen

### Problem
Links in "Mitmachen" funktionieren nicht. Daten prüfen, dürfen keine dummys oder Mockups sein!!
### Vorgehen
1. Prüfe welche Daten angezeigt werden (echte Daten vs. Mockup)
2. Prüfe ob Links korrekte IDs/URLs haben
3. Repariere Event-Handler

---

## Bug 2.2: Mobilität Buttons (Dummys)

### Problem
"Abfahrt", "Verbindung", "Liniennetz" sind nur Dummys ohne Funktion.

### Anforderungen
- **Abfahrt:** Live-Abfahrten einer Haltestelle anzeigen (oder extern verlinken)
- **Verbindung:** Bereits in Bug 1.5 behandelt
- **Liniennetz:** PDF/Bild des Liniennetzes anzeigen oder Link zu INSA

```javascript
// Beispiel: INSA Sachsen-Anhalt Links
const INSA_LINKS = {
  abfahrt: 'https://www.insa.de/fahrplan/abfahrtsmonitor',
  verbindung: 'https://www.insa.de/fahrplan/verbindungssuche',
  liniennetz: 'https://www.insa.de/fahrplan/liniennetzplaene'
};

function openAbfahrt(stationId) {
  window.open(`${INSA_LINKS.abfahrt}?station=${stationId}`, '_blank');
}
```

---

## Bug 2.3: Detailkacheln verschoben

### Problem
Visuelle Fehler bei Kachel-Positionierung. kacheln zu weit unten (in web ansicht besonders stark) großteil der detailkachel ist unten vom bildschirmrand abgeschnitten

### Vorgehen
1. Identifiziere welche Kacheln betroffen sind
2. Prüfe CSS (Flexbox/Grid Probleme?)
3. Prüfe responsive Breakpoints
4. Teste auf verschiedenen Bildschirmgrößen

---

## Bug 2.4: Klickmenü rechts (Dummys)

### Problem
Seitenmenü rechts hat viele nicht-funktionale Buttons.

### Vorgehen
1. Liste alle Buttons auf
2. Entscheide pro Button: Implementieren ODER entfernen ODER "Coming Soon"
3. Konsistente Behandlung

---

## Bug 2.5: ESC für Zurück

### Problem
ESC-Taste sollte aktuelle Ansicht schließen / zurück navigieren.

### Implementierung
```javascript
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    // Priorität: Modal → Dropdown → Sidebar → Navigation
    
    if (closeActiveModal()) return;
    if (closeActiveDropdown()) return;
    if (closeSidebar()) return;
    
    // Letzte Option: Zurück navigieren
    if (canGoBack()) {
      navigateBack();
    }
  }
});

function closeActiveModal() {
  const modal = document.querySelector('.modal.open');
  if (modal) {
    modal.classList.remove('open');
    return true;
  }
  return false;
}
```

---

# PHASE 3: NEUE FEATURES

## Feature 3.1: Ärzte & Gesundheit in Seitenleiste

Siehe separaten Prompt `prompt_6_gesundheit_addon.md` für Details.

**Kurzversion:**
- Neuer Menüpunkt "Gesundheit" mit Icon 🏥
- Notfall-Bereich (112, 116117, Notdienst-Apotheke)
- Ärzte-Suche mit Filtern
- Große Touch-Targets für ältere Nutzer

---

## Feature 3.2: Up Next in Seitenleiste

### Anforderungen
- Zeigt kommende Events/Termine
- Basierend auf Nutzer-Interessen (falls bekannt)
- Oder: Nächste 3-5 Events chronologisch

```javascript
function getUpNextEvents(limit = 5) {
  const now = new Date();
  
  return events
    .filter(e => new Date(e.date) > now)
    .sort((a, b) => new Date(a.date) - new Date(b.date))
    .slice(0, limit);
}
```

---

## Feature 3.3: Welcomescreen Update

### Anforderungen
- Module die "in Bearbeitung" sind kennzeichnen
- Status-Badge: "🚧 In Entwicklung" oder "✅ Verfügbar"
- Kurze Info was kommt

---

## Feature 3.4: Lunch-Radar

### Anforderungen
- im Welcomescreen "Under Construction" Overlay/Banner
- Kurze Beschreibung was das Feature machen wird
- 

---

## Feature 3.5: Profil-Bereich

### Anmeldefunktion
-  bei Login-UI (under construction / "Coming Soon") - hinweiß hinzufügen
-  (under construction / "Coming Soon") - hinweiß hinzufügen

### Benachrichtigungen
- 
### Sprache
- (under construction / "Coming Soon") - hinweiß hinzufügen

### Barrierefreiheit Button
- In Sidebar als Toggle
- Aktiviert: Größere Schrift, höherer Kontrast

---

# PHASE 4: POLISH & DUMMYS

## 4.1: Einheitliche "Coming Soon" Seite

Erstelle EINE wiederverwendbare Komponente für alle Platzhalter:

```html
<div class="coming-soon-page">
  <div class="coming-soon-icon">🚧</div>
  <h2>Demnächst verfügbar</h2>
  <p class="coming-soon-feature">{{ featureName }}</p>
  <p class="coming-soon-desc">Dieses Feature befindet sich noch in Entwicklung.</p>
  <button class="notify-btn">Benachrichtigen wenn verfügbar</button>
</div>
```

Verwende für:
- Daten & Datenschutz
- Suchverlauf
- Nutzungsbedingungen
- Datenschutzerklärung
- Feedback geben

---

## 4.2: Symbole überarbeiten

- wurden die symbole aus dem design overhaul übernommen?
- Konsistenter Icon-Stil (Outline vs Filled)
- Einheitliche Größen
- Accessibility: aria-labels für Screen Reader

---

## 4.3: Designchanges Checkup

- wurde das neue desing aus dem design overhaul übernommen?


---

# CHECKLISTE NACH ABSCHLUSS

```
PHASE 1 - Kritisch
[ ] Warnbanner funktioniert komplett
[ ] Entdecken → Kartenpin funktioniert
[ ] Alle Links repariert
[ ] Suche findet "schwimm" etc.
[ ] Mobilität Verbindungen + Google
[ ] Mobilität Haltestellen gefunden

PHASE 2 - Hoch
[ ] Mitmachen Links funktionieren
[ ] Mobilität Buttons funktionieren
[ ] Detailkacheln richtig positioniert
[ ] Klickmenü rechts aufgeräumt
[ ] ESC schließt/navigiert zurück

PHASE 3 - Features
[ ] Gesundheit in Seitenleiste
[ ] Up Next implementiert
[ ] Welcomescreen aktualisiert
[ ] Lunch-Radar Hinweis
[ ] Profil-Bereich aufgeräumt

PHASE 4 - Polish
[ ] Coming Soon Seite erstellt
[ ] Symbole konsistent
[ ] Design-Check bestanden
[ ] Erscheinungsbild entfernt
```

---

# HINWEISE

- **Teste auf Mobile** - Viele User sind mobil unterwegs
- **Console.log entfernen** - Vor Production
- **Dokumentiere** - Was war das Problem, was war die Lösung
