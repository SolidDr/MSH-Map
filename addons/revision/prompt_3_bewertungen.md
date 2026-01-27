# Prompt 3: Bewertungen in Ort-Details anzeigen

## Problem-Beschreibung

Bewertungen sind **NICHT SICHTBAR** in den Ort-Details/Modalen:
- Getestet bei: DRK Blutspendedienst, Freiwillige Feuerwehr, Event-Details
- Kein Bewertungs-Bereich sichtbar
- Auch nach Scrollen nichts gefunden

### Wichtige Frage
> "Wurden die ermittelten Bewertungen aus der Tiefensuche mit eingearbeitet?"

**ZUERST PRÜFEN:** Existieren Bewertungs-Daten überhaupt in der Datenbank?

---

## Aufgaben

### 1. Daten-Analyse (KRITISCH!)

```
Prüfe ZUERST:
□ Gibt es eine Bewertungs-Tabelle/Collection in der Datenbank?
□ Wie ist die Datenstruktur? (rating, comment, user, date, location_id)
□ Sind Bewertungen mit Orten verknüpft?
□ Wie viele Bewertungen existieren?
□ Beispiel-Datensatz ausgeben
```

**Falls KEINE Daten existieren:**
- Stopp! Melde das Problem
- Bewertungen müssen erst importiert/gesammelt werden
- Das ist ein Daten-Problem, kein UI-Problem

**Falls Daten EXISTIEREN:**
- Weiter mit UI-Implementierung

### 2. Ort-Detail-Modal analysieren

```
Finde heraus:
□ Welche Komponente zeigt Ort-Details? (Datei + Zeile)
□ Wie werden Daten geladen? (API-Call, Props, Store)
□ Werden Bewertungen bereits geladen aber nicht angezeigt?
□ Wo sollte der Bewertungs-Bereich platziert werden?
```

### 3. Bewertungen laden

```javascript
// API-Aufruf für Bewertungen eines Ortes
async function loadReviews(locationId) {
  try {
    const response = await fetch(`/api/reviews/${locationId}`);
    const reviews = await response.json();
    return reviews;
  } catch (error) {
    console.error('Fehler beim Laden der Bewertungen:', error);
    return [];
  }
}

// Oder falls bereits in Location-Daten enthalten:
function getReviews(location) {
  return location.reviews || [];
}
```

### 4. UI-Komponente für Bewertungen

#### HTML-Struktur
```html
<div class="reviews-section">
  <h3 class="reviews-title">
    Bewertungen 
    <span class="reviews-count">(12)</span>
  </h3>
  
  <!-- Durchschnitt -->
  <div class="reviews-summary">
    <div class="average-rating">
      <span class="rating-number">4.2</span>
      <div class="stars">★★★★☆</div>
    </div>
    <span class="total-reviews">basierend auf 12 Bewertungen</span>
  </div>
  
  <!-- Einzelne Bewertungen -->
  <div class="reviews-list">
    <div class="review-item">
      <div class="review-header">
        <div class="review-stars">★★★★★</div>
        <span class="review-date">15.01.2025</span>
      </div>
      <p class="review-text">Sehr freundliches Personal...</p>
      <span class="review-source">Quelle: Google</span>
    </div>
    <!-- Weitere Reviews -->
  </div>
  
  <!-- Falls keine Bewertungen -->
  <div class="no-reviews">
    <p>Noch keine Bewertungen vorhanden.</p>
  </div>
</div>
```

#### JavaScript Rendering
```javascript
function renderReviews(reviews, container) {
  if (!reviews || reviews.length === 0) {
    container.innerHTML = `
      <div class="reviews-section">
        <h3 class="reviews-title">Bewertungen</h3>
        <p class="no-reviews">Noch keine Bewertungen vorhanden.</p>
      </div>
    `;
    return;
  }
  
  const average = calculateAverage(reviews);
  const starsHtml = generateStars(average);
  
  container.innerHTML = `
    <div class="reviews-section">
      <h3 class="reviews-title">
        Bewertungen 
        <span class="reviews-count">(${reviews.length})</span>
      </h3>
      
      <div class="reviews-summary">
        <div class="average-rating">
          <span class="rating-number">${average.toFixed(1)}</span>
          <div class="stars">${starsHtml}</div>
        </div>
        <span class="total-reviews">basierend auf ${reviews.length} Bewertungen</span>
      </div>
      
      <div class="reviews-list">
        ${reviews.slice(0, 5).map(r => renderReviewItem(r)).join('')}
      </div>
      
      ${reviews.length > 5 ? `
        <button class="show-more-reviews">
          Alle ${reviews.length} Bewertungen anzeigen
        </button>
      ` : ''}
    </div>
  `;
}

function renderReviewItem(review) {
  return `
    <div class="review-item">
      <div class="review-header">
        <div class="review-stars">${generateStars(review.rating)}</div>
        <span class="review-date">${formatDate(review.date)}</span>
      </div>
      ${review.text ? `<p class="review-text">${review.text}</p>` : ''}
      ${review.source ? `<span class="review-source">Quelle: ${review.source}</span>` : ''}
    </div>
  `;
}

function generateStars(rating) {
  const fullStars = Math.floor(rating);
  const halfStar = rating % 1 >= 0.5;
  const emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
  
  return '★'.repeat(fullStars) + 
         (halfStar ? '½' : '') + 
         '☆'.repeat(emptyStars);
}

function calculateAverage(reviews) {
  if (reviews.length === 0) return 0;
  const sum = reviews.reduce((acc, r) => acc + r.rating, 0);
  return sum / reviews.length;
}
```

#### CSS-Styling
```css
.reviews-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #333;
}

.reviews-title {
  font-size: 16px;
  margin-bottom: 15px;
  color: #fff;
}

.reviews-count {
  color: #888;
  font-weight: normal;
}

.reviews-summary {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
  padding: 15px;
  background: #1a1a1a;
  border-radius: 8px;
}

.average-rating {
  display: flex;
  align-items: center;
  gap: 8px;
}

.rating-number {
  font-size: 28px;
  font-weight: 600;
  color: #c9a227;
}

.stars {
  color: #c9a227;
  font-size: 16px;
}

.total-reviews {
  color: #888;
  font-size: 13px;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.review-item {
  padding: 12px;
  background: #151515;
  border-radius: 6px;
  border-left: 3px solid #c9a227;
}

.review-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.review-stars {
  color: #c9a227;
  font-size: 14px;
}

.review-date {
  color: #666;
  font-size: 12px;
}

.review-text {
  color: #ccc;
  font-size: 14px;
  line-height: 1.5;
  margin: 0;
}

.review-source {
  display: block;
  margin-top: 8px;
  color: #555;
  font-size: 11px;
}

.no-reviews {
  color: #666;
  font-style: italic;
  padding: 20px;
  text-align: center;
}

.show-more-reviews {
  width: 100%;
  padding: 10px;
  margin-top: 15px;
  background: transparent;
  border: 1px solid #333;
  color: #888;
  border-radius: 6px;
  cursor: pointer;
}

.show-more-reviews:hover {
  border-color: #c9a227;
  color: #c9a227;
}
```

### 5. Integration in Ort-Detail-Modal

```javascript
// Im bestehenden Modal-Code, nach Laden der Ort-Daten:
async function openLocationModal(locationId) {
  const location = await loadLocation(locationId);
  
  // ... bestehender Code für Name, Adresse, etc. ...
  
  // Bewertungen hinzufügen
  const reviewsContainer = modal.querySelector('.reviews-container');
  // Oder Container erstellen falls nicht vorhanden
  
  const reviews = await loadReviews(locationId);
  // Oder: const reviews = location.reviews;
  
  renderReviews(reviews, reviewsContainer);
}
```

---

## Test-Kriterien

- [ ] Ort-Detail öffnen → Bewertungs-Sektion sichtbar
- [ ] Durchschnittliche Bewertung wird angezeigt
- [ ] Sterne-Visualisierung korrekt
- [ ] Einzelne Bewertungen sind lesbar
- [ ] "Keine Bewertungen" wird angezeigt wenn leer
- [ ] Scrollbar falls viele Bewertungen
- [ ] Mobile: Darstellung passt sich an

---

## Wichtig!

**Falls keine Bewertungs-Daten existieren:**
- Melde dies als Blocker
- UI kann implementiert werden, aber ohne Daten nutzlos
- Kläre: Woher sollen Bewertungen kommen? (Google API, manuell, Scraping?)

---

## Deliverables

Nach Abschluss:
1. Status der Bewertungs-Daten (existieren/fehlen)
2. Wenn implementiert: Screenshot der Bewertungs-Anzeige
3. Welche Dateien wurden geändert
