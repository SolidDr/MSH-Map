# Prompt 4: Heatmap-Visualisierung implementieren

## Problem-Beschreibung

Es existiert ein **Layer-System** mit verschiedenen Ansichten:
- Standard-View (107 Orte)
- Warnung-Layer (69 Orte)
- Soziale Ansicht (69 Orte)
- Event-Layer (57 Orte)

**ABER:** Keine echte **Heatmap** mit Farbgradienten die Dichte/Häufigkeit zeigt.

### Was ist eine Heatmap?
Visualisierung wo viele Punkte nah beieinander sind:
- **Rot/Orange** = Hohe Dichte (viele Orte)
- **Gelb** = Mittlere Dichte
- **Grün/Blau** = Niedrige Dichte (wenige Orte)

---

## Aufgaben

### 1. Analyse

```
Finde heraus:
□ Welche Map-Library wird verwendet? (Leaflet, Mapbox, Google Maps, OpenLayers?)
□ Gibt es bereits ein Heatmap-Plugin?
□ Wo ist das Layer-System implementiert?
□ Wie werden Koordinaten der Orte gespeichert?
```

### 2. Heatmap-Plugin je nach Library

#### Für Leaflet:
```bash
# Plugin installieren falls nötig
npm install leaflet.heat
# oder CDN:
# <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet.heat/0.2.0/leaflet-heat.js"></script>
```

```javascript
// Leaflet Heatmap
import 'leaflet.heat';

function createHeatmap(map, locations) {
  // Koordinaten extrahieren [lat, lng, intensity]
  const heatData = locations.map(loc => [
    loc.lat,
    loc.lng,
    1.0  // Intensität (kann variieren basierend auf Bewertung etc.)
  ]);
  
  const heatLayer = L.heatLayer(heatData, {
    radius: 25,
    blur: 15,
    maxZoom: 17,
    max: 1.0,
    gradient: {
      0.0: '#00ff00',  // Grün (niedrig)
      0.3: '#ffff00',  // Gelb
      0.6: '#ffa500',  // Orange
      1.0: '#ff0000'   // Rot (hoch)
    }
  });
  
  return heatLayer;
}
```

#### Für Mapbox GL:
```javascript
// Mapbox Heatmap Layer
map.addLayer({
  id: 'heatmap-layer',
  type: 'heatmap',
  source: 'locations',
  paint: {
    'heatmap-weight': 1,
    'heatmap-intensity': [
      'interpolate', ['linear'], ['zoom'],
      0, 1,
      15, 3
    ],
    'heatmap-color': [
      'interpolate', ['linear'], ['heatmap-density'],
      0, 'rgba(0,255,0,0)',
      0.2, 'rgb(0,255,0)',
      0.4, 'rgb(255,255,0)',
      0.6, 'rgb(255,165,0)',
      0.8, 'rgb(255,0,0)',
      1, 'rgb(178,0,0)'
    ],
    'heatmap-radius': [
      'interpolate', ['linear'], ['zoom'],
      0, 2,
      15, 20
    ],
    'heatmap-opacity': 0.7
  }
});
```

#### Für Google Maps:
```javascript
// Google Maps Heatmap
const heatmap = new google.maps.visualization.HeatmapLayer({
  data: locations.map(loc => 
    new google.maps.LatLng(loc.lat, loc.lng)
  ),
  map: map,
  radius: 30,
  opacity: 0.7,
  gradient: [
    'rgba(0, 255, 0, 0)',
    'rgba(0, 255, 0, 1)',
    'rgba(255, 255, 0, 1)',
    'rgba(255, 165, 0, 1)',
    'rgba(255, 0, 0, 1)'
  ]
});
```

### 3. Layer-Toggle Integration

```javascript
// Heatmap als zusätzlichen Layer hinzufügen
let heatmapLayer = null;
let heatmapActive = false;

function toggleHeatmap() {
  if (heatmapActive) {
    // Heatmap ausblenden
    map.removeLayer(heatmapLayer);
    heatmapActive = false;
    updateHeatmapButton(false);
  } else {
    // Heatmap einblenden
    if (!heatmapLayer) {
      heatmapLayer = createHeatmap(map, allLocations);
    }
    map.addLayer(heatmapLayer);
    heatmapActive = true;
    updateHeatmapButton(true);
    
    // Optional: Normale Marker ausblenden
    // hideMarkers();
  }
}

function updateHeatmapButton(active) {
  const btn = document.querySelector('.heatmap-toggle');
  btn.classList.toggle('active', active);
  btn.title = active ? 'Heatmap ausblenden' : 'Heatmap anzeigen';
}
```

### 4. UI-Button für Heatmap

```html
<!-- In der Layer-Icon-Leiste -->
<button class="layer-btn heatmap-toggle" title="Heatmap anzeigen">
  <svg viewBox="0 0 24 24" width="20" height="20">
    <!-- Heatmap Icon -->
    <circle cx="12" cy="12" r="3" fill="#ff6b6b"/>
    <circle cx="12" cy="12" r="6" fill="none" stroke="#ffa500" stroke-width="1.5" opacity="0.7"/>
    <circle cx="12" cy="12" r="9" fill="none" stroke="#ffd93d" stroke-width="1.5" opacity="0.4"/>
  </svg>
</button>
```

```css
.heatmap-toggle {
  /* Gleicher Style wie andere Layer-Buttons */
}

.heatmap-toggle.active {
  background: #c9a227;
  color: #000;
}

.heatmap-toggle.active svg circle {
  /* Invertierte Farben wenn aktiv */
}
```

### 5. Optionen für fortgeschrittene Heatmap

```javascript
// Heatmap basierend auf verschiedenen Metriken
function createAdvancedHeatmap(locations, metric = 'density') {
  const heatData = locations.map(loc => {
    let intensity = 1.0;
    
    switch(metric) {
      case 'density':
        intensity = 1.0; // Standard
        break;
      case 'rating':
        intensity = (loc.rating || 3) / 5; // Bewertung 0-5 → 0-1
        break;
      case 'popularity':
        intensity = Math.min(loc.reviewCount / 100, 1); // Anzahl Reviews
        break;
    }
    
    return [loc.lat, loc.lng, intensity];
  });
  
  return L.heatLayer(heatData, { /* options */ });
}

// UI für Metrik-Auswahl
// <select id="heatmap-metric">
//   <option value="density">Dichte</option>
//   <option value="rating">Bewertung</option>
//   <option value="popularity">Beliebtheit</option>
// </select>
```

### 6. Performance-Optimierung

```javascript
// Heatmap nur bei bestimmten Zoom-Leveln anzeigen
map.on('zoomend', () => {
  const zoom = map.getZoom();
  
  if (heatmapActive) {
    if (zoom > 16) {
      // Bei hohem Zoom: Marker statt Heatmap
      map.removeLayer(heatmapLayer);
      showMarkers();
    } else {
      // Bei niedrigem Zoom: Heatmap
      map.addLayer(heatmapLayer);
      hideMarkers();
    }
  }
});

// Debounce bei Datenänderungen
function updateHeatmapData(newLocations) {
  if (heatmapLayer) {
    heatmapLayer.setLatLngs(
      newLocations.map(loc => [loc.lat, loc.lng, 1.0])
    );
  }
}
```

---

## Test-Kriterien

- [ ] Heatmap-Button existiert in Layer-Leiste
- [ ] Klick aktiviert Heatmap-Visualisierung
- [ ] Farbgradient sichtbar (Rot = viele Orte, Grün = wenige)
- [ ] Heatmap reagiert auf Zoom (Radius passt sich an)
- [ ] Erneuter Klick deaktiviert Heatmap
- [ ] Performance akzeptabel (kein Lag)
- [ ] Mobile: Heatmap funktioniert auf Touch-Geräten
- [ ] Kombination mit anderen Filtern möglich

---

## Fallback falls Library das nicht unterstützt

Falls keine Heatmap-Library verfügbar:

**Alternative: Cluster-Visualisierung**
```javascript
// Marker Cluster als "Light-Heatmap"
import MarkerCluster from 'leaflet.markercluster';

const markers = L.markerClusterGroup({
  maxClusterRadius: 50,
  iconCreateFunction: (cluster) => {
    const count = cluster.getChildCount();
    let color = '#4CAF50'; // Grün
    
    if (count > 20) color = '#ff0000'; // Rot
    else if (count > 10) color = '#ffa500'; // Orange
    else if (count > 5) color = '#ffff00'; // Gelb
    
    return L.divIcon({
      html: `<div style="background:${color}">${count}</div>`,
      className: 'cluster-icon',
      iconSize: [40, 40]
    });
  }
});
```

---

## Deliverables

Nach Abschluss:
1. Welche Map-Library wird genutzt
2. Welches Heatmap-Plugin/Methode verwendet
3. Screenshot der Heatmap-Ansicht
4. Welche Dateien wurden geändert
