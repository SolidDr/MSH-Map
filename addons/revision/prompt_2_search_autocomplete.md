# Prompt 2: Suchfunktion mit Auto-Vervollständigung

## Problem-Beschreibung

Die Suchleiste funktioniert grundsätzlich, aber es fehlt **Auto-Vervollständigung**:
- Benutzer muss kompletten Begriff eintippen
- Kein Dropdown mit Vorschlägen
- Manuelles Enter-Drücken erforderlich

### Erwartetes Verhalten
- Tippen zeigt sofort Vorschläge (nach 2-3 Zeichen)
- Dropdown mit passenden Kategorien/Orten
- Klick oder Enter auf Vorschlag → Navigation
- Keyboard-Navigation (Pfeiltasten + Enter)
- Mobile: Touch-freundliches Dropdown

---

## Aufgaben

### 1. Analyse

```
Finde heraus:
□ Wo ist die Such-Komponente? (Datei + Zeile)
□ Welche Datenquelle wird durchsucht?
□ API-Endpoint oder lokale Daten?
□ Wie ist die Datenstruktur? (Name, Kategorie, etc.)
```

### 2. Datenquelle für Autocomplete

Vorschläge sollten beinhalten:
- **Ort-Namen** (z.B. "DRK Blutspendedienst")
- **Kategorien** (z.B. "Restaurant", "Spielplatz")
- **Stadtteile/Bereiche** (falls vorhanden)

### 3. Implementierung

#### HTML-Struktur
```html
<div class="search-container">
  <input 
    type="text" 
    class="search-input" 
    placeholder="Suchen..."
    autocomplete="off"
  >
  <ul class="autocomplete-dropdown hidden">
    <!-- Dynamisch gefüllt -->
  </ul>
</div>
```

#### JavaScript-Logik
```javascript
const searchInput = document.querySelector('.search-input');
const dropdown = document.querySelector('.autocomplete-dropdown');

// Debounce für Performance
let debounceTimer;

searchInput.addEventListener('input', (e) => {
  clearTimeout(debounceTimer);
  const query = e.target.value.trim();
  
  if (query.length < 2) {
    hideDropdown();
    return;
  }
  
  debounceTimer = setTimeout(() => {
    const suggestions = getSuggestions(query);
    renderDropdown(suggestions);
  }, 150); // 150ms Debounce
});

function getSuggestions(query) {
  const lowerQuery = query.toLowerCase();
  
  return allLocations
    .filter(loc => 
      loc.name.toLowerCase().includes(lowerQuery) ||
      loc.category.toLowerCase().includes(lowerQuery)
    )
    .slice(0, 8); // Max 8 Vorschläge
}

function renderDropdown(suggestions) {
  if (suggestions.length === 0) {
    hideDropdown();
    return;
  }
  
  dropdown.innerHTML = suggestions.map((s, index) => `
    <li class="autocomplete-item" data-index="${index}" data-id="${s.id}">
      <span class="item-name">${highlightMatch(s.name, query)}</span>
      <span class="item-category">${s.category}</span>
    </li>
  `).join('');
  
  showDropdown();
}

function highlightMatch(text, query) {
  const regex = new RegExp(`(${query})`, 'gi');
  return text.replace(regex, '<mark>$1</mark>');
}
```

#### Keyboard-Navigation
```javascript
let activeIndex = -1;

searchInput.addEventListener('keydown', (e) => {
  const items = dropdown.querySelectorAll('.autocomplete-item');
  
  switch(e.key) {
    case 'ArrowDown':
      e.preventDefault();
      activeIndex = Math.min(activeIndex + 1, items.length - 1);
      updateActiveItem(items);
      break;
      
    case 'ArrowUp':
      e.preventDefault();
      activeIndex = Math.max(activeIndex - 1, 0);
      updateActiveItem(items);
      break;
      
    case 'Enter':
      e.preventDefault();
      if (activeIndex >= 0 && items[activeIndex]) {
        selectItem(items[activeIndex]);
      }
      break;
      
    case 'Escape':
      hideDropdown();
      break;
  }
});

function updateActiveItem(items) {
  items.forEach((item, i) => {
    item.classList.toggle('active', i === activeIndex);
  });
  
  // Scroll into view
  if (items[activeIndex]) {
    items[activeIndex].scrollIntoView({ block: 'nearest' });
  }
}
```

#### CSS-Styling
```css
.search-container {
  position: relative;
}

.autocomplete-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 0 0 8px 8px;
  max-height: 300px;
  overflow-y: auto;
  z-index: 1000;
  list-style: none;
  margin: 0;
  padding: 0;
}

.autocomplete-dropdown.hidden {
  display: none;
}

.autocomplete-item {
  padding: 10px 15px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #2a2a2a;
}

.autocomplete-item:hover,
.autocomplete-item.active {
  background: #2a2a2a;
}

.item-name {
  color: #fff;
}

.item-name mark {
  background: #c9a227;
  color: #000;
  padding: 0 2px;
  border-radius: 2px;
}

.item-category {
  color: #888;
  font-size: 12px;
}

/* Mobile Anpassungen */
@media (max-width: 768px) {
  .autocomplete-item {
    padding: 14px 15px; /* Größere Touch-Targets */
  }
  
  .autocomplete-dropdown {
    max-height: 50vh;
  }
}
```

### 4. Auswahl-Aktion

```javascript
function selectItem(item) {
  const locationId = item.dataset.id;
  
  // Option A: Zur Karte navigieren und Ort fokussieren
  navigateToLocation(locationId);
  
  // Option B: Detail-Modal öffnen
  // openLocationModal(locationId);
  
  // Cleanup
  searchInput.value = item.querySelector('.item-name').textContent;
  hideDropdown();
}
```

### 5. Schließen bei Klick außerhalb

```javascript
document.addEventListener('click', (e) => {
  if (!e.target.closest('.search-container')) {
    hideDropdown();
  }
});
```

---

## Test-Kriterien

- [ ] Tippen von "DRK" zeigt passende Vorschläge
- [ ] Tippen von "Rest" zeigt Restaurants
- [ ] Dropdown erscheint nach 2+ Zeichen
- [ ] Klick auf Vorschlag → Navigation zur Karte/Ort
- [ ] Pfeiltasten navigieren durch Liste
- [ ] Enter wählt markierten Eintrag
- [ ] Escape schließt Dropdown
- [ ] Klick außerhalb schließt Dropdown
- [ ] Mobile: Touch auf Vorschlag funktioniert
- [ ] Performance: Kein Lag beim Tippen
- [ ] Match wird hervorgehoben (highlight)

---

## Performance-Hinweise

- **Debounce** nutzen (150-200ms)
- Nicht mehr als 8-10 Vorschläge anzeigen
- Bei großen Datensätzen: Server-seitige Suche erwägen
- Index/Cache für schnellere Suche

---

## Deliverables

Nach Abschluss:
1. Welche Dateien wurden geändert/erstellt
2. Welche Datenquelle wird genutzt
3. Screenshot oder Bestätigung der Funktion
