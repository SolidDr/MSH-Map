# Prompt 5: UI/UX Fixes

## Probleme

| Problem | Beschreibung |
|---------|--------------|
| Warnbanner zu groß | Auf 1/3 der aktuellen Größe reduzieren |
| Mobile Symbolleiste | Untere Leiste weg, in Suchleiste integrieren |
| Entdecken nicht sortiert | Sortierung implementieren (Teil von Prompt 4) |

---

## A: Warnbanner verkleinern

### Aktuell vs. Neu

```
AKTUELL (zu groß):
┌─────────────────────────────────────────────────┐
│  ⚠️  WARNUNG                                    │
│                                                 │
│  Sangerhäuser Straße: Abrissarbeiten            │
│  Umleitung über Bahnhofstraße empfohlen         │
│                                                 │
│  [Mehr Info]                          [Schließen]│
└─────────────────────────────────────────────────┘
Höhe: ~80-100px

NEU (1/3 = kompakt):
┌─────────────────────────────────────────────────┐
│ ⚠️ Sangerhäuser Str: Abrissarbeiten  [→] [✕]   │
└─────────────────────────────────────────────────┘
Höhe: ~30-35px
```

### CSS-Änderungen

```css
/* VORHER */
.warning-banner {
  padding: 15px 20px;
  min-height: 80px;
  /* ... */
}

/* NACHHER - Kompakt */
.warning-banner {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 6px 12px;
  min-height: 32px;
  max-height: 36px;
  font-size: 13px;
}

.warning-banner .warning-icon {
  font-size: 16px;
  flex-shrink: 0;
}

.warning-banner .warning-text {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.warning-banner .warning-actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.warning-banner .warning-btn {
  padding: 4px 8px;
  font-size: 12px;
  border-radius: 4px;
  border: none;
  cursor: pointer;
}

.warning-banner .btn-goto {
  background: rgba(255,255,255,0.2);
  color: inherit;
}

.warning-banner .btn-close {
  background: transparent;
  color: inherit;
  font-size: 16px;
  padding: 4px;
}
```

### HTML-Struktur (kompakt)

```html
<div class="warning-banner" role="alert">
  <span class="warning-icon">⚠️</span>
  <span class="warning-text">Sangerhäuser Str: Abrissarbeiten</span>
  <div class="warning-actions">
    <button class="warning-btn btn-goto" title="Auf Karte zeigen">→</button>
    <button class="warning-btn btn-close" title="Schließen">✕</button>
  </div>
</div>
```

### Bei mehreren Warnungen

```html
<!-- Kompakte Carousel/Slider Version -->
<div class="warning-banner-container">
  <div class="warning-banner">
    <span class="warning-icon">⚠️</span>
    <span class="warning-text" id="current-warning">Warnung 1 von 3</span>
    <div class="warning-nav">
      <button class="nav-prev">‹</button>
      <span class="nav-count">1/3</span>
      <button class="nav-next">›</button>
    </div>
    <button class="warning-btn btn-goto">→</button>
    <button class="warning-btn btn-close">✕</button>
  </div>
</div>
```

```javascript
// Warnungen durchblättern
let currentWarningIndex = 0;
const warnings = getActiveWarnings();

function showWarning(index) {
  const warning = warnings[index];
  document.getElementById('current-warning').textContent = warning.text;
  document.querySelector('.nav-count').textContent = `${index + 1}/${warnings.length}`;
}

document.querySelector('.nav-next').onclick = () => {
  currentWarningIndex = (currentWarningIndex + 1) % warnings.length;
  showWarning(currentWarningIndex);
};
```

---

## B: Mobile Symbolleiste neu strukturieren

### Anforderung
- Untere Symbolleiste auf Mobile **entfernen**
- Symbole in **obere Suchleiste** integrieren
- Bei Klick/Tap **nach unten ausklappen**

### Aktuelle Struktur (falsch)

```
┌─────────────────────────────────────┐
│ 🔍 Suchen...                        │  ← Suchleiste oben
├─────────────────────────────────────┤
│                                     │
│         KARTEN-INHALT               │
│                                     │
├─────────────────────────────────────┤
│ 🏠  🗺️  📍  ⚙️  👤                  │  ← Symbolleiste unten (WEG!)
└─────────────────────────────────────┘
```

### Neue Struktur

```
┌─────────────────────────────────────┐
│ 🔍 Suchen...              [☰]       │  ← Suchleiste + Menü-Button
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🏠 Karte  🗺️ Entdecken  📍 ...  │ │  ← Ausgeklapptes Menü
│ │ ⚙️ Einstellungen  👤 Profil     │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│                                     │
│         KARTEN-INHALT               │
│                                     │
└─────────────────────────────────────┘
(Keine untere Leiste mehr!)
```

### HTML-Struktur

```html
<header class="mobile-header">
  <div class="search-bar">
    <input type="search" placeholder="Suchen..." class="search-input">
    <button class="menu-toggle" aria-expanded="false" aria-label="Menü öffnen">
      <span class="menu-icon">☰</span>
    </button>
  </div>
  
  <!-- Dropdown-Menü -->
  <nav class="header-dropdown" aria-hidden="true">
    <div class="dropdown-content">
      <a href="#karte" class="dropdown-item">
        <span class="item-icon">🏠</span>
        <span class="item-label">Karte</span>
      </a>
      <a href="#entdecken" class="dropdown-item">
        <span class="item-icon">🔍</span>
        <span class="item-label">Entdecken</span>
      </a>
      <a href="#erleben" class="dropdown-item">
        <span class="item-icon">📅</span>
        <span class="item-label">Erleben</span>
      </a>
      <a href="#mobilitaet" class="dropdown-item">
        <span class="item-icon">🚌</span>
        <span class="item-label">Mobilität</span>
      </a>
      <a href="#gesundheit" class="dropdown-item">
        <span class="item-icon">🏥</span>
        <span class="item-label">Gesundheit</span>
      </a>
      <hr class="dropdown-divider">
      <a href="#einstellungen" class="dropdown-item">
        <span class="item-icon">⚙️</span>
        <span class="item-label">Einstellungen</span>
      </a>
      <a href="#profil" class="dropdown-item">
        <span class="item-icon">👤</span>
        <span class="item-label">Profil</span>
      </a>
    </div>
  </nav>
</header>

<!-- ENTFERNT: Alte untere Leiste -->
<!--
<nav class="bottom-bar">
  ...
</nav>
-->
```

### CSS

```css
/* Mobile Header */
.mobile-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background: #0a0a0d;
}

.search-bar {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  gap: 10px;
}

.search-input {
  flex: 1;
  padding: 10px 15px;
  border-radius: 8px;
  border: 1px solid #333;
  background: #151518;
  color: #fff;
  font-size: 16px;  /* Verhindert Zoom auf iOS */
}

.menu-toggle {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1a1a1d;
  border: 1px solid #333;
  border-radius: 8px;
  color: #fff;
  font-size: 20px;
  cursor: pointer;
}

/* Dropdown */
.header-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #0a0a0d;
  border-bottom: 1px solid #333;
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease;
}

.header-dropdown[aria-hidden="false"] {
  max-height: 400px;  /* Genug für alle Items */
}

.dropdown-content {
  padding: 10px;
  display: grid;
  grid-template-columns: repeat(3, 1fr);  /* 3 Spalten */
  gap: 8px;
}

.dropdown-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px 10px;
  border-radius: 8px;
  background: #151518;
  text-decoration: none;
  color: #ccc;
  transition: background 0.2s;
}

.dropdown-item:active {
  background: #252528;
}

.item-icon {
  font-size: 24px;
  margin-bottom: 6px;
}

.item-label {
  font-size: 12px;
}

.dropdown-divider {
  grid-column: 1 / -1;
  border: none;
  border-top: 1px solid #333;
  margin: 5px 0;
}

/* ENTFERNEN: Alte Bottom Bar */
.bottom-bar {
  display: none !important;
}

/* Mehr Platz für Karte (kein Padding unten mehr nötig) */
.map-container {
  padding-bottom: 0;  /* War vorher ~60px für Bottom Bar */
}

/* Desktop: Normale Sidebar behalten */
@media (min-width: 769px) {
  .mobile-header {
    display: none;
  }
  
  .desktop-sidebar {
    display: block;
  }
}
```

### JavaScript

```javascript
// Toggle-Logik
const menuToggle = document.querySelector('.menu-toggle');
const dropdown = document.querySelector('.header-dropdown');

menuToggle.addEventListener('click', () => {
  const isExpanded = menuToggle.getAttribute('aria-expanded') === 'true';
  
  menuToggle.setAttribute('aria-expanded', !isExpanded);
  dropdown.setAttribute('aria-hidden', isExpanded);
  
  // Icon ändern
  menuToggle.querySelector('.menu-icon').textContent = isExpanded ? '☰' : '✕';
});

// Schließen bei Klick auf Item
dropdown.querySelectorAll('.dropdown-item').forEach(item => {
  item.addEventListener('click', () => {
    menuToggle.setAttribute('aria-expanded', 'false');
    dropdown.setAttribute('aria-hidden', 'true');
    menuToggle.querySelector('.menu-icon').textContent = '☰';
  });
});

// Schließen bei Klick außerhalb
document.addEventListener('click', (e) => {
  if (!e.target.closest('.mobile-header')) {
    menuToggle.setAttribute('aria-expanded', 'false');
    dropdown.setAttribute('aria-hidden', 'true');
    menuToggle.querySelector('.menu-icon').textContent = '☰';
  }
});

// Schließen bei Scroll
let lastScrollY = window.scrollY;
window.addEventListener('scroll', () => {
  if (Math.abs(window.scrollY - lastScrollY) > 50) {
    menuToggle.setAttribute('aria-expanded', 'false');
    dropdown.setAttribute('aria-hidden', 'true');
    menuToggle.querySelector('.menu-icon').textContent = '☰';
  }
  lastScrollY = window.scrollY;
});
```

---

## C: Animation & Feedback

### Menü-Animation verbessern

```css
/* Sanftes Ein-/Ausblenden */
.header-dropdown {
  opacity: 0;
  transform: translateY(-10px);
  transition: 
    max-height 0.3s ease,
    opacity 0.2s ease,
    transform 0.2s ease;
  pointer-events: none;
}

.header-dropdown[aria-hidden="false"] {
  opacity: 1;
  transform: translateY(0);
  pointer-events: auto;
}

/* Tap-Feedback */
.dropdown-item:active,
.menu-toggle:active {
  transform: scale(0.95);
}
```

---

## Checkliste

```
WARNBANNER:
[ ] Höhe auf 1/3 reduziert (~30-35px)
[ ] Kompakte einzeilige Darstellung
[ ] "Zur Karte" Button funktioniert
[ ] "Schließen" Button funktioniert
[ ] Bei mehreren Warnungen: Navigation funktioniert

MOBILE SYMBOLLEISTE:
[ ] Untere Leiste entfernt
[ ] Menü-Button in Suchleiste
[ ] Dropdown klappt aus
[ ] Alle Navigation-Items vorhanden
[ ] Tap-Feedback funktioniert
[ ] Schließen bei Auswahl
[ ] Schließen bei Tap außerhalb
[ ] Desktop-Ansicht unverändert
```

---

## Deliverables

1. **Warnbanner:** Screenshot vorher/nachher
2. **Mobile Menü:** Screenshot der neuen Struktur
3. **Bestätigung:** Untere Leiste entfernt
4. **Test:** Navigation funktioniert auf Mobile
